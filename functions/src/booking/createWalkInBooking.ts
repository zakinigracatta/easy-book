import { createHash } from 'crypto';
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

function optionalRequestId(value: unknown): string {
  if (value == null) return '';
  if (typeof value !== 'string') {
    throw new HttpsError(
      'invalid-argument',
      'INVALID_CLIENT_REQUEST_ID: clientRequestId must be a string.'
    );
  }
  const normalized = value.trim();
  if (normalized.length === 0 || normalized.length > 200) {
    throw new HttpsError(
      'invalid-argument',
      'INVALID_CLIENT_REQUEST_ID: clientRequestId must contain 1 to 200 characters.'
    );
  }
  return normalized;
}

function storedDate(value: unknown): Date | null {
  if (value instanceof admin.firestore.Timestamp) return value.toDate();
  if (value instanceof Date) return value;
  if (typeof value === 'string') {
    const parsed = new Date(value);
    return Number.isNaN(parsed.getTime()) ? null : parsed;
  }
  return null;
}

function idempotentResponse(
  bookingId: string,
  data: Record<string, unknown>
): Record<string, unknown> {
  const endDateTime = storedDate(data.endDateTime);
  if (!endDateTime) {
    throw new HttpsError(
      'internal',
      'IDEMPOTENCY_RECORD_INVALID: Existing walk-in booking is missing its end time.'
    );
  }
  return {
    success: true,
    bookingId,
    servicePrice:
      typeof data.servicePrice === 'number' ? data.servicePrice : 0,
    currency: typeof data.currency === 'string' ? data.currency : 'AED',
    timeZone: typeof data.timeZone === 'string' ? data.timeZone : 'Asia/Dubai',
    durationMinutes:
      typeof data.durationMinutes === 'number' ? data.durationMinutes : 0,
    endDateTime: endDateTime.toISOString(),
    staffId: typeof data.staffId === 'string' ? data.staffId : '',
    staffName: typeof data.staffName === 'string' ? data.staffName : 'Specialist',
    status: typeof data.status === 'string' ? data.status : 'confirmed',
    idempotentReplay: true,
  };
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
  const clientRequestId = optionalRequestId(data.clientRequestId);
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

  const db = admin.firestore();
  const deterministicId = clientRequestId
    ? createHash('sha256')
        .update(`${ownerUid}:${clientRequestId}`)
        .digest('hex')
        .slice(0, 40)
    : '';
  const bookingDocRef = deterministicId
    ? db.collection('bookings').doc(`wb_${deterministicId}`)
    : db.collection('bookings').doc();

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
    const ownerId = bizData.owner_id ?? bizData.ownerId;
    if (ownerId !== ownerUid) {
      throw new HttpsError(
        'permission-denied',
        'PERMISSION_DENIED: Caller is not the owner of this business.'
      );
    }

    if (clientRequestId) {
      const existingSnap = await transaction.get(bookingDocRef);
      if (existingSnap.exists) {
        const existing = existingSnap.data() || {};
        const sameRequest =
          existing.businessId === businessId &&
          existing.serviceId === serviceId &&
          existing.staffId === staffId &&
          Number(existing.startTimestamp) === requestedStartAt.getTime() &&
          existing.bookingSource === 'walkIn';

        if (!sameRequest) {
          throw new HttpsError(
            'invalid-argument',
            'IDEMPOTENCY_KEY_REUSED: This clientRequestId was already used for a different walk-in booking.'
          );
        }
        return idempotentResponse(bookingDocRef.id, existing);
      }
    }

    // New walk-ins may be entered at the current quarter-hour, but never as
    // old historical appointments. This check intentionally runs after the
    // idempotency replay lookup so a delayed retry can still return the
    // already-committed booking instead of a false START_TIME_IN_PAST error.
    if (requestedStartAt.getTime() < Date.now() - 15 * 60 * 1000) {
      throw new HttpsError(
        'failed-precondition',
        'START_TIME_IN_PAST: Walk-in booking time is too far in the past.'
      );
    }

    const context = await validateBookingRequirements(
      db,
      transaction,
      businessId,
      serviceId,
      staffId,
      requestedStartAt,
      {
        requireAcceptingBookings: false,
        requireVerifiedBusiness: false,
      }
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
      timeZone: context.timeZone,
      durationMinutes: context.durationMinutes,
      staffId,
      staffName: context.staffName,
      startDateTime: admin.firestore.Timestamp.fromDate(requestedStartAt),
      endDateTime: admin.firestore.Timestamp.fromDate(context.calculatedEndAt),
      startTimestamp: requestedStartAt.getTime(),
      status: 'confirmed',
      bookingSource: 'walkIn',
      notes,
      createdByOwnerId: ownerUid,
      slotLockId: primarySlotLockId,
      ...(clientRequestId ? { clientRequestId } : {}),
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    return {
      success: true,
      bookingId: bookingDocRef.id,
      servicePrice: context.servicePrice,
      currency: context.currency,
      timeZone: context.timeZone,
      durationMinutes: context.durationMinutes,
      endDateTime: context.calculatedEndAt.toISOString(),
      staffId,
      staffName: context.staffName,
      status: 'confirmed',
      idempotentReplay: false,
    };
  });
});
