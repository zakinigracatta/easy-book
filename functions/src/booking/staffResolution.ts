import * as admin from 'firebase-admin';
import { HttpsError } from 'firebase-functions/v2/https';

import { generateIntervalSlotLockIds } from './bookingLocks';
import { validateBookingRequirements } from './bookingValidation';

type ValidationContext = Awaited<
  ReturnType<typeof validateBookingRequirements>
>;

export interface ResolvedStaffBooking {
  staffId: string;
  context: ValidationContext;
  lockObjects: ReturnType<typeof generateIntervalSlotLockIds>;
}

function canonicalBool(
  data: Record<string, unknown>,
  canonical: string,
  legacy: string
): boolean {
  if (typeof data[canonical] === 'boolean') return data[canonical] === true;
  return data[legacy] === true;
}

function staffSupportsService(
  data: Record<string, unknown>,
  serviceId: string
): boolean {
  const rawIds = Array.isArray(data.service_ids)
    ? data.service_ids
    : Array.isArray(data.serviceIds)
      ? data.serviceIds
      : [];
  if (rawIds.length === 0) return true;
  return rawIds.map(String).includes(serviceId);
}

function isRecoverableStaffAvailabilityError(error: unknown): boolean {
  if (!(error instanceof HttpsError)) return false;
  const message = error.message || '';
  return (
    message.includes('STAFF_INACTIVE') ||
    message.includes('STAFF_NOT_WORKING_DAY') ||
    message.includes('OUTSIDE_STAFF_SHIFT') ||
    message.includes('STAFF_ON_BREAK') ||
    message.includes('STAFF_ON_LEAVE') ||
    message.includes('STAFF_INELIGIBLE') ||
    message.includes('STAFF_SCHEDULE_NOT_CONFIGURED')
  );
}

function rotateIds(ids: string[], seed: string): string[] {
  if (ids.length <= 1) return ids;

  let hash = 0;
  for (let i = 0; i < seed.length; i += 1) {
    hash = (hash * 31 + seed.charCodeAt(i)) >>> 0;
  }
  const offset = hash % ids.length;
  return [...ids.slice(offset), ...ids.slice(0, offset)];
}

/// Resolves "Any Available Specialist" entirely on the trusted backend.
///
/// The caller supplies only the business/service/time. Candidate staff are
/// discovered from Firestore, validated against their schedule/time-off, and
/// checked against deterministic booking-slot locks inside the same
/// transaction. A client-provided staff ID is never authoritative for this
/// flow.
export async function resolveAnyAvailableStaff(
  db: admin.firestore.Firestore,
  transaction: admin.firestore.Transaction,
  params: {
    businessId: string;
    serviceId: string;
    requestedStartAt: Date;
    seed: string;
    existingBookingId?: string;
  }
): Promise<ResolvedStaffBooking> {
  const { businessId, serviceId, requestedStartAt, seed, existingBookingId } =
    params;

  const staffQuery = db
    .collection('businesses')
    .doc(businessId)
    .collection('staff');
  const staffSnapshot = await transaction.get(staffQuery);

  const candidateIds = staffSnapshot.docs
    .filter((doc) => {
      const data = doc.data() as Record<string, unknown>;
      return (
        canonicalBool(data, 'is_active', 'isActive') &&
        staffSupportsService(data, serviceId)
      );
    })
    .map((doc) => doc.id)
    .sort();

  if (candidateIds.length === 0) {
    throw new HttpsError(
      'failed-precondition',
      'STAFF_INELIGIBLE: No active specialist is configured for this service.'
    );
  }

  for (const staffId of rotateIds(candidateIds, seed)) {
    let context: ValidationContext;
    try {
      context = await validateBookingRequirements(
        db,
        transaction,
        businessId,
        serviceId,
        staffId,
        requestedStartAt
      );
    } catch (error) {
      if (isRecoverableStaffAvailabilityError(error)) continue;
      throw error;
    }

    const lockObjects = generateIntervalSlotLockIds(
      businessId,
      staffId,
      requestedStartAt,
      context.calculatedEndAt
    );

    let hasConflict = false;
    for (const lock of lockObjects) {
      const lockRef = db.collection('booking_slots').doc(lock.lockId);
      const lockSnap = await transaction.get(lockRef);
      if (
        lockSnap.exists &&
        (!existingBookingId ||
          lockSnap.data()?.bookingId !== existingBookingId)
      ) {
        hasConflict = true;
      }
    }

    if (!hasConflict) {
      return { staffId, context, lockObjects };
    }
  }

  throw new HttpsError(
    'already-exists',
    'NO_SPECIALIST_AVAILABLE: No eligible specialist is still available for this time slot.'
  );
}
