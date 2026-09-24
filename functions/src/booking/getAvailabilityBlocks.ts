import * as admin from 'firebase-admin';
import { HttpsError, onCall } from 'firebase-functions/v2/https';
import {
  normalizeInclusiveTimeOffEndMs,
  resolveTimeZone,
} from './bookingValidation';

function requiredBusinessId(value: unknown): string {
  if (
    typeof value !== 'string' ||
    value.trim().length === 0 ||
    value.length > 200
  ) {
    throw new HttpsError(
      'invalid-argument',
      'INVALID_BUSINESS_ID: businessId must be a valid identifier.'
    );
  }
  return value.trim();
}

function requestedStaffIds(value: unknown): string[] {
  if (!Array.isArray(value) || value.length === 0 || value.length > 50) {
    throw new HttpsError(
      'invalid-argument',
      'INVALID_STAFF_IDS: staffIds must contain between 1 and 50 identifiers.'
    );
  }

  const result = [
    ...new Set(
      value
        .map((item) => (typeof item === 'string' ? item.trim() : ''))
        .filter((item) => item.length > 0 && item.length <= 200)
    ),
  ];

  if (result.length === 0) {
    throw new HttpsError(
      'invalid-argument',
      'INVALID_STAFF_IDS: At least one valid staff identifier is required.'
    );
  }
  return result;
}

function asDate(value: unknown): Date | null {
  if (value instanceof admin.firestore.Timestamp) return value.toDate();
  if (value instanceof Date) return value;
  if (typeof value === 'string') {
    const parsed = new Date(value);
    return Number.isNaN(parsed.getTime()) ? null : parsed;
  }
  return null;
}

function requestedRange(data: Record<string, unknown>): {
  start: Date;
  end: Date;
} {
  const hasStart = data.startAt != null;
  const hasEnd = data.endAt != null;
  if (!hasStart || !hasEnd) {
    throw new HttpsError(
      'invalid-argument',
      'INVALID_RANGE: startAt and endAt are required.'
    );
  }

  const start = asDate(data.startAt);
  const end = asDate(data.endAt);
  if (!start || !end || end.getTime() <= start.getTime()) {
    throw new HttpsError(
      'invalid-argument',
      'INVALID_RANGE: startAt and endAt must define a valid interval.'
    );
  }

  const maxRangeMs = 48 * 60 * 60 * 1000;
  if (end.getTime() - start.getTime() > maxRangeMs) {
    throw new HttpsError(
      'invalid-argument',
      'INVALID_RANGE: Availability range cannot exceed 48 hours.'
    );
  }

  const now = Date.now();
  const pastGraceMs = 24 * 60 * 60 * 1000;
  const maxAdvanceMs = 61 * 24 * 60 * 60 * 1000;
  if (
    start.getTime() < now - pastGraceMs ||
    end.getTime() > now + maxAdvanceMs
  ) {
    throw new HttpsError(
      'invalid-argument',
      'INVALID_RANGE: Availability may only be requested for the active booking window.'
    );
  }

  return { start, end };
}

/// Returns only blended 15-minute unavailability buckets required by the
/// customer scheduling engine. Booking IDs, leave reasons, and exact time-off
/// boundaries never leave the trusted backend, so callers cannot distinguish a
/// booking from leave or another private source of unavailability.
export const getAvailabilityBlocks = onCall(async (request) => {
  const data = (request.data || {}) as Record<string, unknown>;
  const businessId = requiredBusinessId(data.businessId);
  const staffIds = requestedStaffIds(data.staffIds);
  const range = requestedRange(data);
  const excludeBookingId =
    typeof data.excludeBookingId === 'string'
      ? data.excludeBookingId.trim().slice(0, 200)
      : '';
  const db = admin.firestore();

  const businessSnap = await db.collection('businesses').doc(businessId).get();
  if (!businessSnap.exists) {
    throw new HttpsError(
      'not-found',
      'BUSINESS_NOT_FOUND: Business does not exist.'
    );
  }

  const business = businessSnap.data() || {};
  const isVerified =
    (business.is_verified ?? business.isVerified) === true;
  const isActive = (business.is_active ?? business.isActive) === true;
  const acceptingBookings =
    (business.accepting_bookings ?? business.acceptingBookings) === true;
  const businessStatus =
    business.business_status ?? business.businessStatus ?? 'closed';
  const timeZone = resolveTimeZone(business.timeZone ?? business.timezone);

  if (
    !isVerified ||
    !isActive ||
    !acceptingBookings ||
    businessStatus !== 'open'
  ) {
    throw new HttpsError(
      'failed-precondition',
      'BUSINESS_NOT_PUBLISHED: Availability is not public for this business.'
    );
  }

  let approvedExcludedBookingId = '';
  if (excludeBookingId) {
    if (!request.auth) {
      throw new HttpsError(
        'unauthenticated',
        'UNAUTHENTICATED: Authentication is required to exclude a booking.'
      );
    }

    const bookingSnap = await db.collection('bookings').doc(excludeBookingId).get();
    if (bookingSnap.exists) {
      const booking = bookingSnap.data() || {};
      const ownerId = business.owner_id ?? business.ownerId;
      const ownsBooking = booking.customerId === request.auth.uid;
      const ownsBusiness = ownerId === request.auth.uid;
      if (
        booking.businessId === businessId &&
        (ownsBooking || ownsBusiness)
      ) {
        approvedExcludedBookingId = excludeBookingId;
      }
    }
  }

  // Public availability accepts only active staff IDs that actually belong to
  // this business. This prevents callers from probing arbitrary employee IDs.
  const staffRefs = staffIds.map((staffId) =>
    db.collection('businesses').doc(businessId).collection('staff').doc(staffId)
  );
  const staffSnapshots = await db.getAll(...staffRefs);
  const activeStaffIds = staffSnapshots
    .filter((staffSnap) => {
      if (!staffSnap.exists) return false;
      const staff = staffSnap.data() || {};
      return (staff.is_active ?? staff.isActive) === true;
    })
    .map((staffSnap) => staffSnap.id);
  const activeStaffIdSet = new Set(activeStaffIds);

  const bucketMs = 15 * 60 * 1000;
  const unavailableBucketKeys = new Set<string>();
  const addUnavailableBucket = (staffId: string, startTimestamp: number) => {
    unavailableBucketKeys.add(`${staffId}|${startTimestamp}`);
  };

  // Convert private leave intervals into the same opaque occupancy buckets used
  // for bookings. The client learns only that a slot is unavailable.
  const timeOffSnapshot = await db
    .collection('businesses')
    .doc(businessId)
    .collection('timeOffs')
    .get();

  for (const doc of timeOffSnapshot.docs) {
    const item = doc.data();
    const employeeId = String(
      item.employeeId ?? item.employee_id ?? ''
    ).trim();
    const startDate = asDate(item.startDate ?? item.start_date);
    const endDate = asDate(item.endDate ?? item.end_date);

    if (!employeeId || !startDate || !endDate) continue;
    if (!activeStaffIdSet.has(employeeId)) continue;

    const effectiveEndMs = normalizeInclusiveTimeOffEndMs(endDate, timeZone);
    const overlapStart = Math.max(startDate.getTime(), range.start.getTime());
    const overlapEnd = Math.min(effectiveEndMs, range.end.getTime());
    if (overlapEnd <= overlapStart) continue;

    let bucketStart = Math.floor(overlapStart / bucketMs) * bucketMs;
    for (; bucketStart < overlapEnd; bucketStart += bucketMs) {
      if (bucketStart + bucketMs <= overlapStart) continue;
      if (
        bucketStart >= range.start.getTime() &&
        bucketStart < range.end.getTime()
      ) {
        addUnavailableBucket(employeeId, bucketStart);
      }
    }
  }

  if (activeStaffIds.length > 0) {
    for (const staffId of activeStaffIds) {
      const snapshot = await db
        .collection('booking_slots')
        .where('businessId', '==', businessId)
        .where('staffId', '==', staffId)
        .where('startTimestamp', '>=', range.start.getTime())
        .where('startTimestamp', '<', range.end.getTime())
        .get();

      for (const doc of snapshot.docs) {
        const slotData = doc.data();
        if (
          approvedExcludedBookingId &&
          slotData.bookingId === approvedExcludedBookingId
        ) {
          continue;
        }
        const startTimestamp = Number(slotData.startTimestamp);
        if (!Number.isFinite(startTimestamp)) continue;
        addUnavailableBucket(staffId, startTimestamp);
      }
    }
  }

  const unavailableSlots = [...unavailableBucketKeys].map((key) => {
    const separator = key.lastIndexOf('|');
    return {
      staffId: key.slice(0, separator),
      startTimestamp: Number(key.slice(separator + 1)),
    };
  });

  return { unavailableSlots };
});
