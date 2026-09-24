import * as admin from 'firebase-admin';
import { onCall, HttpsError } from 'firebase-functions/v2/https';
import {
  generateIntervalSlotLockIds,
  validateCanonical15MinAlignment,
} from './bookingLocks';
import {
  validateBookingRequirements,
  validateMaximumAdvanceDate,
} from './bookingValidation';
import { resolveAnyAvailableStaff } from './staffResolution';

export const rescheduleBooking = onCall(async (request) => {
  if (!request.auth) {
    throw new HttpsError(
      'unauthenticated',
      'UNAUTHENTICATED: Authentication is required to reschedule a booking.'
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
      typeof bookingData.anySpecialist === 'boolean'
        ? bookingData.anySpecialist === true
        : bookingData.any_specialist === true;
    const customerId = bookingData.customerId;
    const currentStatus = bookingData.status;

    let actor: 'customer' | 'owner' | '' = '';
    if (customerId && customerId === callerUid) {
      actor = 'customer';
    } else if (businessId) {
      const bizRef = db.collection('businesses').doc(businessId);
      const bizSnap = await transaction.get(bizRef);
      if (bizSnap.exists) {
        const bizData = bizSnap.data() || {};
        const ownerId = bizData.owner_id ?? bizData.ownerId;
        if (ownerId === callerUid) actor = 'owner';
      }
    }

    if (!actor) {
      throw new HttpsError(
        'permission-denied',
        'PERMISSION_DENIED: You are not authorized to reschedule this booking.'
      );
    }

    const customerUsesAnySpecialist = actor === 'customer' && anySpecialist;
    let targetStaffId = staffId;

    if (requestedNewStaffId && requestedNewStaffId !== staffId) {
      if (actor === 'customer' && !anySpecialist) {
        throw new HttpsError(
          'permission-denied',
          'STAFF_CHANGE_NOT_ALLOWED: This booking was made with a specific specialist.'
        );
      }
      if (!customerUsesAnySpecialist) {
        targetStaffId = requestedNewStaffId;
      }
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

    if (
      bookingData.endDateTime &&
      typeof bookingData.endDateTime.toDate === 'function'
    ) {
      oldEndAt = bookingData.endDateTime.toDate();
    } else {
      const duration = bookingData.durationMinutes || 30;
      oldEndAt = new Date(oldStartAt.getTime() + duration * 60 * 1000);
    }

    // Treat an exact retry as an idempotent success. A callable response can be
    // lost after Firestore commits, and retrying the same reschedule must not
    // report a false failure to the customer.
    if (
      oldStartAt.getTime() === newStartAt.getTime() &&
      (customerUsesAnySpecialist || targetStaffId === staffId)
    ) {
      return {
        success: true,
        bookingId,
        startDateTime: oldStartAt.toISOString(),
        endDateTime: oldEndAt.toISOString(),
        staffId,
        staffName:
          typeof bookingData.staffName === 'string'
            ? bookingData.staffName
            : 'Specialist',
        status: currentStatus,
        idempotentReplay: true,
      };
    }

    if (currentStatus !== 'pending' && currentStatus !== 'confirmed') {
      throw new HttpsError(
        'failed-precondition',
        `CANNOT_RESCHEDULE: Cannot reschedule a ${currentStatus} appointment.`
      );
    }

    if (oldStartAt.getTime() <= Date.now()) {
      throw new HttpsError(
        'failed-precondition',
        'CANNOT_RESCHEDULE: The original appointment has already started.'
      );
    }

    if (newStartAt.getTime() <= Date.now()) {
      throw new HttpsError(
        'failed-precondition',
        'START_TIME_IN_PAST: A rescheduled appointment must start in the future.'
      );
    }

    if (
      actor === 'customer' &&
      newStartAt.getTime() < Date.now() + 30 * 60 * 1000
    ) {
      throw new HttpsError(
        'failed-precondition',
        'START_TIME_TOO_SOON: Customer reschedules require at least 30 minutes lead time.'
      );
    }

    let context: Awaited<ReturnType<typeof validateBookingRequirements>>;
    let newLockObjects: ReturnType<typeof generateIntervalSlotLockIds>;

    if (customerUsesAnySpecialist) {
      const resolved = await resolveAnyAvailableStaff(db, transaction, {
        businessId,
        serviceId,
        requestedStartAt: newStartAt,
        seed: `${bookingId}:${newStartAt.toISOString()}`,
        existingBookingId: bookingId,
      });
      targetStaffId = resolved.staffId;
      context = resolved.context;
      newLockObjects = resolved.lockObjects;
    } else {
      context = await validateBookingRequirements(
        db,
        transaction,
        businessId,
        serviceId,
        targetStaffId,
        newStartAt,
        {
          requireAcceptingBookings: actor === 'customer',
          requireVerifiedBusiness: actor === 'customer',
        }
      );
      newLockObjects = generateIntervalSlotLockIds(
        businessId,
        targetStaffId,
        newStartAt,
        context.calculatedEndAt
      );
    }

    if (actor === 'customer') {
      validateMaximumAdvanceDate(newStartAt, context.timeZone);
    }

    const oldLockObjects = generateIntervalSlotLockIds(
      businessId,
      staffId,
      oldStartAt,
      oldEndAt
    );

    const oldLockIds = new Set(oldLockObjects.map((lock) => lock.lockId));
    const newLockIds = new Set(newLockObjects.map((lock) => lock.lockId));
    const locksToDelete = [...oldLockIds].filter(
      (lockId) => !newLockIds.has(lockId)
    );

    const missingNewLocks: Array<{
      ref: admin.firestore.DocumentReference;
      lock: (typeof newLockObjects)[number];
    }> = [];

    // Every target lock is authoritative. Do not assume an overlapping old
    // lock still exists just because its deterministic ID is unchanged.
    for (const lock of newLockObjects) {
      const lockRef = db.collection('booking_slots').doc(lock.lockId);
      const lockSnap = await transaction.get(lockRef);
      if (lockSnap.exists) {
        if (lockSnap.data()?.bookingId !== bookingId) {
          throw new HttpsError(
            'already-exists',
            'SLOT_CONFLICT: The target time slot is already booked by another customer.'
          );
        }
      } else {
        missingNewLocks.push({ ref: lockRef, lock });
      }
    }

    const ownedOldLockRefs: admin.firestore.DocumentReference[] = [];
    for (const lockId of locksToDelete) {
      const lockRef = db.collection('booking_slots').doc(lockId);
      const lockSnap = await transaction.get(lockRef);
      if (lockSnap.exists && lockSnap.data()?.bookingId === bookingId) {
        ownedOldLockRefs.push(lockRef);
      }
    }

    for (const lockRef of ownedOldLockRefs) {
      transaction.delete(lockRef);
    }

    for (const item of missingNewLocks) {
      transaction.set(item.ref, {
        slotId: item.lock.lockId,
        bookingId,
        businessId,
        staffId: targetStaffId,
        startDateTime: admin.firestore.Timestamp.fromDate(item.lock.startDateTime),
        startTimestamp: item.lock.startTimestamp,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
      });
    }

    const primarySlotLockId = newLockObjects[0].lockId;
    const nextStatus = actor === 'owner' ? currentStatus : 'pending';
    transaction.update(bookingRef, {
      startDateTime: admin.firestore.Timestamp.fromDate(newStartAt),
      endDateTime: admin.firestore.Timestamp.fromDate(context.calculatedEndAt),
      durationMinutes: context.durationMinutes,
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
      idempotentReplay: false,
    };
  });
});
