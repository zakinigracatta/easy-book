import * as admin from 'firebase-admin';
import { HttpsError, onCall } from 'firebase-functions/v2/https';

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

/// Returns only the minimum scheduling data required by the customer
/// availability engine. Raw booking IDs and private leave metadata never leave
/// the trusted backend.
export const getAvailabilityBlocks = onCall(async (request) => {
  const data = (request.data || {}) as Record<string, unknown>;
  const businessId = requiredBusinessId(data.businessId);
  const staffIds = requestedStaffIds(data.staffIds);
  const range = requestedRange(data);
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
    business.is_verified === true || business.isVerified === true;
  const isActive = (business.is_active ?? business.isActive) === true;
  const acceptingBookings =
    (business.accepting_bookings ?? business.acceptingBookings) === true;
  const businessStatus =
    business.business_status ?? business.businessStatus ?? 'closed';

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

  // Public availability accepts only active staff IDs that actually belong to
  // this business. This prevents callers from probing arbitrary employee IDs.
  const activeStaffIds: string[] = [];
  for (const staffId of staffIds) {
    const staffSnap = await db
      .collection('businesses')
      .doc(businessId)
      .collection('staff')
      .doc(staffId)
      .get();
    if (!staffSnap.exists) continue;
    const staff = staffSnap.data() || {};
    if ((staff.is_active ?? staff.isActive) === true) {
      activeStaffIds.push(staffId);
    }
  }
  const activeStaffIdSet = new Set(activeStaffIds);

  const timeOffSnapshot = await db
    .collection('businesses')
    .doc(businessId)
    .collection('timeOffs')
    .get();

  const blocks: Array<{
    employeeId: string;
    startDate: string;
    endDate: string;
  }> = [];

  for (const doc of timeOffSnapshot.docs) {
    const item = doc.data();
    const employeeId = String(
      item.employeeId ?? item.employee_id ?? ''
    ).trim();
    const startDate = asDate(item.startDate ?? item.start_date);
    const endDate = asDate(item.endDate ?? item.end_date);

    if (!employeeId || !startDate || !endDate) continue;
    if (!activeStaffIdSet.has(employeeId)) continue;
    if (endDate.getTime() < startDate.getTime()) continue;
    if (
      startDate.getTime() >= range.end.getTime() ||
      endDate.getTime() <= range.start.getTime()
    ) {
      continue;
    }

    blocks.push({
      employeeId,
      startDate: startDate.toISOString(),
      endDate: endDate.toISOString(),
    });
  }

  const occupiedSlots: Array<{
    staffId: string;
    startTimestamp: number;
  }> = [];

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
        const startTimestamp = Number(doc.data().startTimestamp);
        if (!Number.isFinite(startTimestamp)) continue;
        occupiedSlots.push({ staffId, startTimestamp });
      }
    }
  }

  return { blocks, occupiedSlots };
});
