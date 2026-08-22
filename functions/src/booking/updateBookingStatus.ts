import * as admin from 'firebase-admin';
import { onCall, HttpsError } from 'firebase-functions/v2/https';
import { generateIntervalSlotLockIds } from './bookingLocks';

export const updateBookingStatus = onCall(async (request) => {
  if (!request.auth) {
    throw new HttpsError(
      'unauthenticated',
      'UNAUTHENTICATED: Authentication is required to update booking status.'
    );
  }

  const callerUid = request.auth.uid;
  const data = request.data || {};
  const bookingId = data.bookingId;
  const newStatus = data.newStatus;

  if (!bookingId || !newStatus) {
    throw new HttpsError(
      'invalid-argument',
      'MISSING_ARGUMENTS: bookingId and newStatus are required.'
    );
  }

  const db = admin.firestore();

  return await db.runTransaction(async (transaction) => {
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
    const isDeterministicOwner = businessId === callerUid;
    if (!isDeterministicOwner && ownerId !== callerUid) {
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

    if (newStatus === 'cancelled') {
      let startAt: Date;
      let endAt: Date;

      if (bookingData.startDateTime && typeof bookingData.startDateTime.toDate === 'function') {
        startAt = bookingData.startDateTime.toDate();
      } else {
        startAt = new Date(bookingData.startTimestamp || Date.now());
      }

      if (bookingData.endDateTime && typeof bookingData.endDateTime.toDate === 'function') {
        endAt = bookingData.endDateTime.toDate();
      } else {
        const dur = bookingData.durationMinutes || 30;
        endAt = new Date(startAt.getTime() + dur * 60 * 1000);
      }

      const lockObjects = generateIntervalSlotLockIds(
        businessId,
        bookingData.staffId,
        startAt,
        endAt
      );

      for (const lock of lockObjects) {
        const lockRef = db.collection('booking_slots').doc(lock.lockId);
        transaction.delete(lockRef);
      }

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
