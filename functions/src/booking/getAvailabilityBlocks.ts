import * as admin from 'firebase-admin';
import { HttpsError, onCall } from 'firebase-functions/v2/https';

function requiredBusinessId(value: unknown): string {
  if (typeof value !== 'string' || value.trim().length === 0 || value.length > 200) {
    throw new HttpsError(
      'invalid-argument',
      'INVALID_BUSINESS_ID: businessId must be a valid identifier.'
    );
  }
  return value.trim();
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

/// Public booking availability needs leave intervals, but it must never expose
/// private owner notes or leave reasons. This callable returns only the minimum
/// non-sensitive interval data required by the customer availability engine.
export const getAvailabilityBlocks = onCall(async (request) => {
  const businessId = requiredBusinessId(request.data?.businessId);
  const db = admin.firestore();

  const businessSnap = await db.collection('businesses').doc(businessId).get();
  if (!businessSnap.exists) {
    throw new HttpsError('not-found', 'BUSINESS_NOT_FOUND: Business does not exist.');
  }

  const business = businessSnap.data() || {};
  const isVerified =
    business.is_verified === true || business.isVerified === true;
  const isActive = (business.is_active ?? business.isActive) !== false;

  if (!isVerified || !isActive) {
    throw new HttpsError(
      'failed-precondition',
      'BUSINESS_NOT_PUBLISHED: Availability is not public for this business.'
    );
  }

  const snapshot = await db
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

  for (const doc of snapshot.docs) {
    const data = doc.data();
    const employeeId = String(data.employeeId ?? data.employee_id ?? '').trim();
    const startDate = asDate(data.startDate ?? data.start_date);
    const endDate = asDate(data.endDate ?? data.end_date);

    if (!employeeId || !startDate || !endDate) continue;
    if (endDate.getTime() < startDate.getTime()) continue;

    blocks.push({
      id: doc.id,
      employeeId,
      startDate: startDate.toISOString(),
      endDate: endDate.toISOString(),
    });
  }

  return { blocks };
});
