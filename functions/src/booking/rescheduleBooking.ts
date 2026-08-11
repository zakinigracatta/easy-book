import * as admin from 'firebase-admin';
import { onCall, HttpsError } from 'firebase-functions/v2/https';
import {
  generateIntervalSlotLockIds,
  validateCanonical15MinAlignment,
} from './bookingLocks';
import { validateBookingRequirements } from './bookingValidation';

export const rescheduleBooking = onCall(async (request) => {
  if (!request.auth) {
    throw new HttpsError(
      'unauthenticated',
      'UNAUTHENTICATED: Authentication is required to reschedule a booking.'
    );
  }

  const callerUid = request.auth.uid;
  const data = request.data || {};
  const bookingId = data.bookingId;
  const newRequestedStartRaw = data.newRequestedStartAt;

  if (!bookingId || !newRequestedStartRaw) {
    throw new HttpsError(
      'invalid-argument',
      'MISSING_ARGUMENTS: bookingId and newRequestedStartAt are required.'
    );
  }

  const newStartAt = new Date(newRequestedStartRaw);
  if (isNaN(newStartAt.getTime())) {
    throw new HttpsError(
      'invalid-argument',
      'INVALID_START_TIME: newRequestedStartAt must be a valid date.'
    );
  }

  validateCanonical15MinAlignment(newStartAt);

  const db = admin.firestore();

  return await db.runTransaction(async (transaction) => {
    // 1. Read existing booking
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
    const serviceId = bookingData.serviceId;
    const staffId = bookingData.staffId;
    const customerId = bookingData.customerId;
    const currentStatus = bookingData.status;

    if (currentStatus === 'cancelled' || currentStatus === 'completed') {
      throw new HttpsError(
        'failed-precondition',
        `CANNOT_RESCHEDULE: Cannot reschedule a ${currentStatus} appointment.`
      );
    }

    // Verify caller authorization
    let isAuthorized = false;
    if (customerId && customerId === callerUid) {
      isAuthorized = true;
    } else if (businessId) {
      const bizRef = db.collection('businesses').doc(businessId);
      const bizSnap = await transaction.get(bizRef);
      if (bizSnap.exists) {
        const bizData = bizSnap.data() || {};
        const ownerId = bizData.ownerId || bizData.owner_id;
        if (ownerId === callerUid) {
          isAuthorized = true;
        }
      }
    }

    if (!isAuthorized) {
      throw new HttpsError(
        'permission-denied',
        'PERMISSION_DENIED: You are not authorized to reschedule this booking.'
      );
    }

    // 2. Validate new start time against Business, Service, Staff, Shift, Breaks, Leave
    const context = await validateBookingRequirements(
      db,
      transaction,
      businessId,
      serviceId,
      staffId,
      newStartAt
    );

    // Calculate old vs new locks
    let oldStartAt: Date;
    let oldEndAt: Date;

    if (bookingData.startDateTime && typeof bookingData.startDateTime.toDate === 'function') {
      oldStartAt = bookingData.startDateTime.toDate();
    } else {
      oldStartAt = new Date(bookingData.startTimestamp || Date.now());
    }

    if (bookingData.endDateTime && typeof bookingData.endDateTime.toDate === 'function') {
      oldEndAt = bookingData.endDateTime.toDate();
    } else {
      const dur = bookingData.durationMinutes || 30;
      oldEndAt = new Date(oldStartAt.getTime() + dur * 60 * 1000);
    }

    const oldLockObjects = generateIntervalSlotLockIds(
      businessId,
      staffId,
      oldStartAt,
      oldEndAt
    );
    const newLockObjects = generateIntervalSlotLockIds(
      businessId,
      staffId,
      newStartAt,
      context.calculatedEndAt
    );

    const oldLockIds = new Set(oldLockObjects.map((l) => l.lockId));
    const newLockIds = new Set(newLockObjects.map((l) => l.lockId));

    const locksToKeep = new Set(
      [...oldLockIds].filter((x) => newLockIds.has(x))
    );
    const locksToDelete = [...oldLockIds].filter((x) => !newLockIds.has(x));
    const locksToCreate = newLockObjects.filter((l) => !locksToKeep.has(l.lockId));

    // Check availability of new locks
    for (const lock of locksToCreate) {
      const lockRef = db.collection('booking_slots').doc(lock.lockId);
      const lockSnap = await transaction.get(lockRef);
      if (lockSnap.exists) {
        const data = lockSnap.data() || {};
        if (data.bookingId !== bookingId) {
          throw new HttpsError(
            'already-exists',
            'SLOT_CONFLICT: The target time slot is already booked by another customer.'
          );
        }
      }
    }

    // Delete obsolete old locks
    for (const lockId of locksToDelete) {
      const lockRef = db.collection('booking_slots').doc(lockId);
      transaction.delete(lockRef);
    }

    // Create new required locks
    for (const lock of locksToCreate) {
      const lockRef = db.collection('booking_slots').doc(lock.lockId);
      transaction.set(lockRef, {
        slotId: lock.lockId,
        bookingId,
        businessId,
        staffId,
        startDateTime: admin.firestore.Timestamp.fromDate(lock.startDateTime),
        startTimestamp: lock.startTimestamp,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
      });
    }

    // Update booking document
    const primarySlotLockId = newLockObjects[0].lockId;
    transaction.update(bookingRef, {
      startDateTime: admin.firestore.Timestamp.fromDate(newStartAt),
      endDateTime: admin.firestore.Timestamp.fromDate(context.calculatedEndAt),
      startTimestamp: newStartAt.getTime(),
      slotLockId: primarySlotLockId,
      status: 'pending',
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    return {
      success: true,
      bookingId,
      startDateTime: newStartAt.toISOString(),
      endDateTime: context.calculatedEndAt.toISOString(),
      status: 'pending',
    };
  });
});
