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
  const bookingId =
    typeof data.bookingId === 'string' ? data.bookingId.trim() : '';
  const newRequestedStartRaw = data.newRequestedStartAt;
  const requestedNewStaffId =
    typeof data.newStaffId === 'string' ? data.newStaffId.trim() : '';

  if (
    !bookingId ||
    bookingId.length > 200 ||
    typeof newRequestedStartRaw !== 'string'
  ) {
    throw new HttpsError(
      'invalid-argument',
      'MISSING_ARGUMENTS: bookingId and newRequestedStartAt are required.'
    );
  }

  const newStartAt = new Date(newRequestedStartRaw);
  if (Number.isNaN(newStartAt.getTime())) {
    throw new HttpsError(
      'invalid-argument',
      'INVALID_START_TIME: newRequestedStartAt must be a valid date.'
    );
  }

  validateCanonical15MinAlignment(newStartAt);
  if (newStartAt.getTime() <= Date.now()) {
    throw new HttpsError(
      'failed-precondition',
      'START_TIME_IN_PAST: A rescheduled appointment must start in the future.'
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
    const serviceId = bookingData.serviceId;
    const staffId = bookingData.staffId;
    const anySpecialist =
      bookingData.anySpecialist === true || bookingData.any_specialist === true;
    const customerId = bookingData.customerId;
    const currentStatus = bookingData.status;

    if (currentStatus !== 'pending' && currentStatus !== 'confirmed') {
      throw new HttpsError(
        'failed-precondition',
        `CANNOT_RESCHEDULE: Cannot reschedule a ${currentStatus} appointment.`
      );
    }

    let actor: 'customer' | 'owner' | '' = '';
    if (customerId && customerId === callerUid) {
      actor = 'customer';
    } else if (businessId) {
      const bizRef = db.collection('businesses').doc(businessId);
      const bizSnap = await transaction.get(bizRef);
      if (bizSnap.exists) {
        const bizData = bizSnap.data() || {};
        const ownerId = bizData.ownerId || bizData.owner_id;
        if (ownerId === callerUid) actor = 'owner';
      }
    }

    if (!actor) {
      throw new HttpsError(
        'permission-denied',
        'PERMISSION_DENIED: You are not authorized to reschedule this booking.'
      );
    }

    let targetStaffId = staffId;
    if (requestedNewStaffId && requestedNewStaffId !== staffId) {
      if (actor === 'customer' && !anySpecialist) {
        throw new HttpsError(
          'permission-denied',
          'STAFF_CHANGE_NOT_ALLOWED: This booking was made with a specific specialist.'
        );
      }
      targetStaffId = requestedNewStaffId;
    }

    let oldStartAt: Date;
    let oldEndAt: Date;
    if (
      bookingData.startDateTime &&
      typeof bookingData.startDateTime.toDate === 'function'
    ) {
      oldStartAt = bookingData.startDateTime.toDate();
    } else {
      oldStartAt = new Date(bookingData.startTimestamp || Date.now());
    }

    if (oldStartAt.getTime() <= Date.now()) {
      throw new HttpsError(
        'failed-precondition',
        'CANNOT_RESCHEDULE: The original appointment has already started.'
      );
    }

    if (
      bookingData.endDateTime &&
      typeof bookingData.endDateTime.toDate === 'function'
    ) {
      oldEndAt = bookingData.endDateTime.toDate();
    } else {
      const duration = bookingData.durationMinutes || 30;
      oldEndAt = new Date(oldStartAt.getTime() + duration * 60 * 1000);
    }

    const context = await validateBookingRequirements(
      db,
      transaction,
      businessId,
      serviceId,
      targetStaffId,
      newStartAt
    );

    const oldLockObjects = generateIntervalSlotLockIds(
      businessId,
      staffId,
      oldStartAt,
      oldEndAt
    );
    const newLockObjects = generateIntervalSlotLockIds(
      businessId,
      targetStaffId,
      newStartAt,
      context.calculatedEndAt
    );

    const oldLockIds = new Set(oldLockObjects.map((lock) => lock.lockId));
    const newLockIds = new Set(newLockObjects.map((lock) => lock.lockId));
    const locksToKeep = new Set(
      [...oldLockIds].filter((lockId) => newLockIds.has(lockId))
    );
    const locksToDelete = [...oldLockIds].filter(
      (lockId) => !newLockIds.has(lockId)
    );
    const locksToCreate = newLockObjects.filter(
      (lock) => !locksToKeep.has(lock.lockId)
    );

    for (const lock of locksToCreate) {
      const lockRef = db.collection('booking_slots').doc(lock.lockId);
      const lockSnap = await transaction.get(lockRef);
      if (lockSnap.exists && lockSnap.data()?.bookingId !== bookingId) {
        throw new HttpsError(
          'already-exists',
          'SLOT_CONFLICT: The target time slot is already booked by another customer.'
        );
      }
    }

    for (const lockId of locksToDelete) {
      transaction.delete(db.collection('booking_slots').doc(lockId));
    }

    for (const lock of locksToCreate) {
      const lockRef = db.collection('booking_slots').doc(lock.lockId);
      transaction.set(lockRef, {
        slotId: lock.lockId,
        bookingId,
        businessId,
        staffId: targetStaffId,
        startDateTime: admin.firestore.Timestamp.fromDate(lock.startDateTime),
        startTimestamp: lock.startTimestamp,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
      });
    }

    const primarySlotLockId = newLockObjects[0].lockId;
    const nextStatus = actor === 'owner' ? currentStatus : 'pending';
    transaction.update(bookingRef, {
      startDateTime: admin.firestore.Timestamp.fromDate(newStartAt),
      endDateTime: admin.firestore.Timestamp.fromDate(context.calculatedEndAt),
      startTimestamp: newStartAt.getTime(),
      slotLockId: primarySlotLockId,
      staffId: targetStaffId,
      staffName: context.staffName,
      status: nextStatus,
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    return {
      success: true,
      bookingId,
      startDateTime: newStartAt.toISOString(),
      endDateTime: context.calculatedEndAt.toISOString(),
      staffId: targetStaffId,
      staffName: context.staffName,
      status: nextStatus,
    };
  });
});
