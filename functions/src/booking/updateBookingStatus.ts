import * as admin from 'firebase-admin';
import { onCall, HttpsError } from 'firebase-functions/v2/https';
import { generateIntervalSlotLockIds } from './bookingLocks';

const ALLOWED_STATUSES = new Set([
  'confirmed',
  'arrived',
  'inProgress',
  'completed',
  'cancelled',
  'noShow',
]);

export const updateBookingStatus = onCall(async (request) => {
  if (!request.auth) {
    throw new HttpsError(
      'unauthenticated',
      'UNAUTHENTICATED: Authentication is required to update booking status.'
    );
  }

  if (request.auth.token.email && request.auth.token.email_verified !== true) {
    throw new HttpsError(
      'failed-precondition',
      'EMAIL_NOT_VERIFIED: Verify your email address before managing bookings.'
    );
  }

  const callerUid = request.auth.uid;
  const data = request.data || {};
  const bookingId =
    typeof data.bookingId === 'string' ? data.bookingId.trim() : '';
  const newStatus =
    typeof data.newStatus === 'string' ? data.newStatus.trim() : '';

  if (!bookingId || bookingId.length > 200 || !ALLOWED_STATUSES.has(newStatus)) {
    throw new HttpsError(
      'invalid-argument',
      'INVALID_ARGUMENTS: bookingId and a supported newStatus are required.'
    );
  }

  const db = admin.firestore();

  return db.runTransaction(async (transaction) => {
    const bookingRef = db.collection('bookings').doc(bookingId);
    const bookingSnap = await transaction.get(bookingRef);
    if (!bookingSnap.exists) {
      throw new HttpsError(
        'not-found',
        'BOOKING_NOT_FOUND: Booking document does not exist.'
      );
    }

    const bookingData = bookingSnap.data() || {};
    const businessId = bookingData.businessId;
    const currentStatus = bookingData.status;

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
    if (ownerId !== callerUid) {
      throw new HttpsError(
        'permission-denied',
        'PERMISSION_DENIED: Only the business owner can update booking status.'
      );
    }

    const allowedTransitions: Record<string, string[]> = {
      pending: ['confirmed', 'cancelled'],
      confirmed: ['arrived', 'inProgress', 'noShow', 'cancelled'],
      arrived: ['inProgress', 'cancelled'],
      inProgress: ['completed', 'cancelled'],
    };

    const validNextStatuses = allowedTransitions[currentStatus] || [];
    if (!validNextStatuses.includes(newStatus)) {
      throw new HttpsError(
        'failed-precondition',
        `INVALID_STATUS_TRANSITION: Cannot transition booking from ${currentStatus} to ${newStatus}.`
      );
    }

    let startAt: Date;
    let endAt: Date;
    if (
      bookingData.startDateTime &&
      typeof bookingData.startDateTime.toDate === 'function'
    ) {
      startAt = bookingData.startDateTime.toDate();
    } else {
      startAt = new Date(bookingData.startTimestamp || Date.now());
    }

    if (
      bookingData.endDateTime &&
      typeof bookingData.endDateTime.toDate === 'function'
    ) {
      endAt = bookingData.endDateTime.toDate();
    } else {
      const duration = bookingData.durationMinutes || 30;
      endAt = new Date(startAt.getTime() + duration * 60 * 1000);
    }

    const nowMs = Date.now();
    if (newStatus === 'noShow' && nowMs < startAt.getTime()) {
      throw new HttpsError(
        'failed-precondition',
        'STATUS_TOO_EARLY: A booking cannot be marked no-show before its start time.'
      );
    }
    if (
      (newStatus === 'inProgress' || newStatus === 'completed') &&
      nowMs < startAt.getTime()
    ) {
      throw new HttpsError(
        'failed-precondition',
        'STATUS_TOO_EARLY: Service cannot start or complete before the appointment time.'
      );
    }

    const shouldReleaseLocks =
      newStatus === 'cancelled' || newStatus === 'noShow';
    if (shouldReleaseLocks) {
      const lockObjects = generateIntervalSlotLockIds(
        businessId,
        bookingData.staffId,
        startAt,
        endAt
      );
      for (const lock of lockObjects) {
        transaction.delete(db.collection('booking_slots').doc(lock.lockId));
      }
    }

    if (newStatus === 'cancelled') {
      transaction.update(bookingRef, {
        status: 'cancelled',
        cancelledBy: 'owner',
        cancelledAt: admin.firestore.FieldValue.serverTimestamp(),
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      });
    } else {
      transaction.update(bookingRef, {
        status: newStatus,
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      });
    }

    return {
      success: true,
      bookingId,
      previousStatus: currentStatus,
      newStatus,
    };
  });
});
