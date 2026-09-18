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
  if (value == null) return [];
  if (!Array.isArray(value) || value.length > 50) {
    throw new HttpsError(
      'invalid-argument',
      'INVALID_STAFF_IDS: staffIds must be an array with at most 50 items.'
    );
  }

  const result = value
    .map((item) => (typeof item === 'string' ? item.trim() : ''))
    .filter((item) => item.length > 0 && item.length <= 200);
  return [...new Set(result)];
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
} | null {
  const hasStart = data.startAt != null;
  const hasEnd = data.endAt != null;
  if (!hasStart && !hasEnd) return null;

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

  if (!isVerified || !isActive) {
    throw new HttpsError(
      'failed-precondition',
      'BUSINESS_NOT_PUBLISHED: Availability is not public for this business.'
    );
  }

  const timeOffSnapshot = await db
    .collection('businesses')
    .doc(businessId)
    .collection('timeOffs')
    .get();

  const blocks: Array<{
    id: string;
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
    if (endDate.getTime() < startDate.getTime()) continue;
    if (
      range &&
      (startDate.getTime() >= range.end.getTime() ||
        endDate.getTime() <= range.start.getTime())
    ) {
      continue;
    }

    blocks.push({
      id: doc.id,
      employeeId,
      startDate: startDate.toISOString(),
      endDate: endDate.toISOString(),
    });
  }

  const occupiedSlots: Array<{
    staffId: string;
    startTimestamp: number;
  }> = [];

  if (range && staffIds.length > 0) {
    for (const staffId of staffIds) {
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
