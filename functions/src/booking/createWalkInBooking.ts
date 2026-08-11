import * as admin from 'firebase-admin';
import { onCall, HttpsError } from 'firebase-functions/v2/https';
import {
  generateIntervalSlotLockIds,
  validateCanonical15MinAlignment,
} from './bookingLocks';
import { validateBookingRequirements } from './bookingValidation';

export const createWalkInBooking = onCall(async (request) => {
  if (!request.auth) {
    throw new HttpsError(
      'unauthenticated',
      'UNAUTHENTICATED: Authentication is required to create a walk-in booking.'
    );
  }

  const ownerUid = request.auth.uid;
  const data = request.data || {};

  const businessId = data.businessId;
  const serviceId = data.serviceId;
  const staffId = data.staffId;
  const requestedStartRaw = data.requestedStartAt;
  const customerName = data.customerName || 'Walk-in Customer';
  const customerPhone = data.customerPhone || '';
  const notes = data.notes || '';

  if (!businessId || !serviceId || !staffId || !requestedStartRaw) {
    throw new HttpsError(
      'invalid-argument',
      'MISSING_ARGUMENTS: businessId, serviceId, staffId, and requestedStartAt are required.'
    );
  }

  const requestedStartAt = new Date(requestedStartRaw);
  if (isNaN(requestedStartAt.getTime())) {
    throw new HttpsError(
      'invalid-argument',
      'INVALID_START_TIME: requestedStartAt must be a valid date.'
    );
  }

  validateCanonical15MinAlignment(requestedStartAt);

  const db = admin.firestore();

  return await db.runTransaction(async (transaction) => {
    // 1. Verify Business Ownership
    const bizRef = db.collection('businesses').doc(businessId);
    const bizSnap = await transaction.get(bizRef);
    if (!bizSnap.exists) {
      throw new HttpsError(
        'not-found',
        'BUSINESS_NOT_FOUND: Business does not exist.'
      );
    }
    const bizData = bizSnap.data() || {};
    const ownerId = bizData.ownerId || bizData.owner_id;
    if (ownerId !== ownerUid) {
      throw new HttpsError(
        'permission-denied',
        'PERMISSION_DENIED: Caller is not the owner of this business.'
      );
    }

    // 2. Authoritative Validation & Price/Duration calculation
    const context = await validateBookingRequirements(
      db,
      transaction,
      businessId,
      serviceId,
      staffId,
      requestedStartAt
    );

    // 3. Lock IDs generation
    const lockObjects = generateIntervalSlotLockIds(
      businessId,
      staffId,
      requestedStartAt,
      context.calculatedEndAt
    );

    // 4. Check Lock Availability (Competes for exact same slot lock documents)
    for (const lock of lockObjects) {
      const lockRef = db.collection('booking_slots').doc(lock.lockId);
      const lockSnap = await transaction.get(lockRef);
      if (lockSnap.exists) {
        throw new HttpsError(
          'already-exists',
          'SLOT_CONFLICT: This time slot is already locked by another appointment.'
        );
      }
    }

    // 5. Create Non-Sensitive Booking Slots Locks
    const bookingDocRef = db.collection('bookings').doc();
    const primarySlotLockId = lockObjects[0].lockId;

    for (const lock of lockObjects) {
      const lockRef = db.collection('booking_slots').doc(lock.lockId);
      transaction.set(lockRef, {
        slotId: lock.lockId,
        bookingId: bookingDocRef.id,
        businessId,
        staffId,
        startDateTime: admin.firestore.Timestamp.fromDate(lock.startDateTime),
        startTimestamp: lock.startTimestamp,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
      });
    }

    // 6. Create Authoritative Walk-in Booking Snapshot Document
    const bookingPayload = {
      id: bookingDocRef.id,
      customerId: '',
      customerName,
      customerPhone,
      businessId,
      businessName: context.businessName,
      serviceId,
      serviceName: context.serviceName,
      servicePrice: context.servicePrice,
      currency: context.currency,
      durationMinutes: context.durationMinutes,
      staffId,
      staffName: context.staffName,
      startDateTime: admin.firestore.Timestamp.fromDate(requestedStartAt),
      endDateTime: admin.firestore.Timestamp.fromDate(context.calculatedEndAt),
      startTimestamp: requestedStartAt.getTime(),
      status: 'confirmed',
      bookingSource: 'walkIn',
      notes,
      slotLockId: primarySlotLockId,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    };

    transaction.set(bookingDocRef, bookingPayload);

    return {
      success: true,
      bookingId: bookingDocRef.id,
      servicePrice: context.servicePrice,
      durationMinutes: context.durationMinutes,
      endDateTime: context.calculatedEndAt.toISOString(),
      status: 'confirmed',
    };
  });
});
