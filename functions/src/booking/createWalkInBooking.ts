import * as admin from 'firebase-admin';
import { onCall, HttpsError } from 'firebase-functions/v2/https';
import {
  generateIntervalSlotLockIds,
  validateCanonical15MinAlignment,
} from './bookingLocks';
import { validateBookingRequirements } from './bookingValidation';

function requiredId(value: unknown, name: string): string {
  if (
    typeof value !== 'string' ||
    value.trim().length === 0 ||
    value.length > 200
  ) {
    throw new HttpsError(
      'invalid-argument',
      `INVALID_${name.toUpperCase()}: ${name} must be a valid identifier.`
    );
  }
  return value.trim();
}

function cleanText(value: unknown, maxLength: number): string {
  if (typeof value !== 'string') return '';
  return value.trim().slice(0, maxLength);
}

export const createWalkInBooking = onCall(async (request) => {
  if (!request.auth) {
    throw new HttpsError(
      'unauthenticated',
      'UNAUTHENTICATED: Authentication is required to create a walk-in booking.'
    );
  }

  if (request.auth.token.email && request.auth.token.email_verified !== true) {
    throw new HttpsError(
      'failed-precondition',
      'EMAIL_NOT_VERIFIED: Verify your email address before creating a walk-in booking.'
    );
  }

  const ownerUid = request.auth.uid;
  const data = request.data || {};
  const businessId = requiredId(data.businessId, 'businessId');
  const serviceId = requiredId(data.serviceId, 'serviceId');
  const staffId = requiredId(data.staffId, 'staffId');
  const requestedStartRaw = data.requestedStartAt;
  const customerName = cleanText(data.customerName, 120) || 'Walk-in Customer';
  const customerPhone = cleanText(data.customerPhone, 40);
  const notes = cleanText(data.notes, 1000);

  if (typeof requestedStartRaw !== 'string' || requestedStartRaw.length > 80) {
    throw new HttpsError(
      'invalid-argument',
      'INVALID_START_TIME: requestedStartAt must be an ISO-8601 date string.'
    );
  }

  const requestedStartAt = new Date(requestedStartRaw);
  if (Number.isNaN(requestedStartAt.getTime())) {
    throw new HttpsError(
      'invalid-argument',
      'INVALID_START_TIME: requestedStartAt must be a valid date.'
    );
  }

  validateCanonical15MinAlignment(requestedStartAt);

  // Walk-ins may be entered at the current quarter-hour, but never as old
  // historical appointments through this live booking endpoint.
  if (requestedStartAt.getTime() < Date.now() - 15 * 60 * 1000) {
    throw new HttpsError(
      'failed-precondition',
      'START_TIME_IN_PAST: Walk-in booking time is too far in the past.'
    );
  }

  const db = admin.firestore();

  return db.runTransaction(async (transaction) => {
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

    const context = await validateBookingRequirements(
      db,
      transaction,
      businessId,
      serviceId,
      staffId,
      requestedStartAt
    );

    const lockObjects = generateIntervalSlotLockIds(
      businessId,
      staffId,
      requestedStartAt,
      context.calculatedEndAt
    );

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

    transaction.set(bookingDocRef, {
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
    });

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
