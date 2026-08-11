import * as admin from 'firebase-admin';
import { onCall, HttpsError } from 'firebase-functions/v2/https';
import {
  generateIntervalSlotLockIds,
  validateCanonical15MinAlignment,
} from './bookingLocks';
import { validateBookingRequirements } from './bookingValidation';

export const createBooking = onCall(async (request) => {
  if (!request.auth) {
    throw new HttpsError(
      'unauthenticated',
      'UNAUTHENTICATED: Authentication is required to create a booking.'
    );
  }

  const customerId = request.auth.uid;
  const data = request.data || {};

  const businessId = data.businessId;
  const serviceId = data.serviceId;
  const staffId = data.staffId;
  const requestedStartRaw = data.requestedStartAt;
  const customerName = data.customerName || '';
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
    // 1. Authoritative Validation & Price/Duration calculation
    const context = await validateBookingRequirements(
      db,
      transaction,
      businessId,
      serviceId,
      staffId,
      requestedStartAt
    );

    // 2. Lock IDs generation
    const lockObjects = generateIntervalSlotLockIds(
      businessId,
      staffId,
      requestedStartAt,
      context.calculatedEndAt
    );

    // 3. Check Lock Availability
    for (const lock of lockObjects) {
      const lockRef = db.collection('booking_slots').doc(lock.lockId);
      const lockSnap = await transaction.get(lockRef);
      if (lockSnap.exists) {
        throw new HttpsError(
          'already-exists',
          'SLOT_CONFLICT: This time slot was just booked by another customer. Please select another time.'
        );
      }
    }

    // 4. Create Non-Sensitive Booking Slots Locks
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

    // 5. Create Authoritative Booking Snapshot Document
    const bookingPayload = {
      id: bookingDocRef.id,
      customerId,
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
      status: 'pending',
      bookingSource: 'app',
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
      status: 'pending',
    };
  });
});
