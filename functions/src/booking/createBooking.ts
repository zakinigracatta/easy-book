import * as admin from 'firebase-admin';
import { onCall, HttpsError } from 'firebase-functions/v2/https';
import { generateIntervalSlotLockIds } from './bookingLocks';
import { validateBookingRequirements } from './bookingValidation';

function requiredId(value: unknown, name: string): string {
  if (typeof value !== 'string' || value.trim().length === 0 || value.length > 200) {
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

export const createBooking = onCall(async (request) => {
  if (!request.auth) {
    throw new HttpsError(
      'unauthenticated',
      'UNAUTHENTICATED: Authentication is required to create a booking.'
    );
  }

  if (request.auth.token.email && request.auth.token.email_verified !== true) {
    throw new HttpsError(
      'failed-precondition',
      'EMAIL_NOT_VERIFIED: Verify your email address before creating a booking.'
    );
  }

  const customerId = request.auth.uid;
  const data = request.data || {};
  const businessId = requiredId(data.businessId, 'businessId');
  const serviceId = requiredId(data.serviceId, 'serviceId');
  const staffId = requiredId(data.staffId, 'staffId');
  const requestedStartRaw = data.requestedStartAt;
  const customerName = cleanText(data.customerName, 120) || 'Valued Customer';
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
  if (requestedStartAt.getTime() <= Date.now()) {
    throw new HttpsError(
      'failed-precondition',
      'START_TIME_IN_PAST: A customer booking must start in the future.'
    );
  }

  const db = admin.firestore();

  return db.runTransaction(async (transaction) => {
    const businessRef = db.collection('businesses').doc(businessId);
    const businessSnap = await transaction.get(businessRef);
    if (!businessSnap.exists) {
      throw new HttpsError(
        'not-found',
        'BUSINESS_NOT_FOUND: Business does not exist.'
      );
    }

    const businessData = businessSnap.data() || {};
    const isVerified =
      businessData.is_verified === true || businessData.isVerified === true;
    const isActive =
      (businessData.is_active ?? businessData.isActive) !== false;

    if (!isVerified || !isActive) {
      throw new HttpsError(
        'failed-precondition',
        'BUSINESS_NOT_VERIFIED: This business is not approved for public booking.'
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
          'SLOT_CONFLICT: This time slot was just booked by another customer. Please select another time.'
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
