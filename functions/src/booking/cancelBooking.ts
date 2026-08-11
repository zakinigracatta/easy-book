import * as admin from 'firebase-admin';
import { onCall, HttpsError } from 'firebase-functions/v2/https';
import { generateIntervalSlotLockIds } from './bookingLocks';

export const cancelBooking = onCall(async (request) => {
  if (!request.auth) {
    throw new HttpsError(
      'unauthenticated',
      'UNAUTHENTICATED: Authentication is required to cancel a booking.'
    );
  }

  const callerUid = request.auth.uid;
  const data = request.data || {};
  const bookingId = data.bookingId;
  const cancelReason = data.cancelReason || '';

  if (!bookingId) {
    throw new HttpsError(
      'invalid-argument',
      'MISSING_ARGUMENT: bookingId is required.'
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
    const customerId = bookingData.customerId;
    const currentStatus = bookingData.status;

    if (currentStatus === 'cancelled') {
      return { success: true, message: 'Booking is already cancelled.' };
    }

    // Authorization check
    let cancelledBy = '';
    if (customerId && customerId === callerUid) {
      cancelledBy = 'customer';
    } else if (businessId) {
      const bizRef = db.collection('businesses').doc(businessId);
      const bizSnap = await transaction.get(bizRef);
      if (bizSnap.exists) {
        const bizData = bizSnap.data() || {};
        const ownerId = bizData.ownerId || bizData.owner_id;
        if (ownerId === callerUid) {
          cancelledBy = 'owner';
        }
      }
    }

    if (!cancelledBy) {
      throw new HttpsError(
        'permission-denied',
        'PERMISSION_DENIED: You are not authorized to cancel this booking.'
      );
    }

    // Determine lock IDs from authoritative startDateTime & endDateTime
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

    // Delete all booking locks
    for (const lock of lockObjects) {
      const lockRef = db.collection('booking_slots').doc(lock.lockId);
      transaction.delete(lockRef);
    }

    // Update booking document
    const updatePayload: Record<string, any> = {
      status: 'cancelled',
      cancelledBy,
      cancelledAt: admin.firestore.FieldValue.serverTimestamp(),
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    };
    if (cancelReason) {
      updatePayload.cancelReason = cancelReason;
    }

    transaction.update(bookingRef, updatePayload);

    return {
      success: true,
      bookingId,
      status: 'cancelled',
      cancelledBy,
    };
  });
});
