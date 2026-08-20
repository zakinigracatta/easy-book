import * as admin from 'firebase-admin';
import { HttpsError } from 'firebase-functions/v2/https';

export interface ValidatedBookingContext {
  businessName: string;
  serviceName: string;
  servicePrice: number;
  currency: string;
  durationMinutes: number;
  calculatedEndAt: Date;
  staffName: string;
}

export function parseTimeStringToMinutes(raw: string): number {
  try {
    const clean = raw.trim();
    const isPm = clean.toUpperCase().includes('PM');
    const isAm = clean.toUpperCase().includes('AM');
    const numbersStr = clean.replace(/[^\d:]/g, '');
    const parts = numbersStr.split(':');
    let hour = parseInt(parts[0], 10);
    const minute = parts.length > 1 ? parseInt(parts[1], 10) : 0;
    if (isPm && hour < 12) hour += 12;
    if (isAm && hour === 12) hour = 0;
    return hour * 60 + minute;
  } catch (_) {
    return 9 * 60;
  }
}

function getZonedDayAndMinutes(date: Date, timeZone: string): {
  weekday: number;
  minutes: number;
} {
  const formatter = new Intl.DateTimeFormat('en-US', {
    timeZone,
    weekday: 'short',
    hour: '2-digit',
    minute: '2-digit',
    hourCycle: 'h23',
  });
  const parts = formatter.formatToParts(date);
  const weekdayName = parts.find((p) => p.type === 'weekday')?.value ?? 'Mon';
  const hour = Number(parts.find((p) => p.type === 'hour')?.value ?? '0');
  const minute = Number(parts.find((p) => p.type === 'minute')?.value ?? '0');
  const weekdays: Record<string, number> = {
    Mon: 1,
    Tue: 2,
    Wed: 3,
    Thu: 4,
    Fri: 5,
    Sat: 6,
    Sun: 7,
  };
  return {
    weekday: weekdays[weekdayName] ?? 1,
    minutes: hour * 60 + minute,
  };
}

export async function validateBookingRequirements(
  db: admin.firestore.Firestore,
  transaction: admin.firestore.Transaction,
  businessId: string,
  serviceId: string,
  staffId: string,
  requestedStartAt: Date
): Promise<ValidatedBookingContext> {
  const bizRef = db.collection('businesses').doc(businessId);
  const bizSnap = await transaction.get(bizRef);
  if (!bizSnap.exists) {
    throw new HttpsError(
      'failed-precondition',
      'BUSINESS_NOT_FOUND: Business does not exist.'
    );
  }
  const bizData = bizSnap.data() || {};
  const isActive = (bizData.is_active ?? bizData.isActive) !== false;
  const acceptingBookings =
    (bizData.accepting_bookings ?? bizData.acceptingBookings) !== false;
  const businessStatus =
    bizData.business_status ?? bizData.businessStatus ?? 'open';
  const businessTimeZone =
    bizData.timezone ?? bizData.timeZone ?? 'Asia/Dubai';

  if (!isActive || !acceptingBookings || businessStatus !== 'open') {
    throw new HttpsError(
      'failed-precondition',
      'BUSINESS_NOT_ACCEPTING_BOOKINGS: Business is currently closed or not accepting bookings.'
    );
  }

  const srvRef = db
    .collection('businesses')
    .doc(businessId)
    .collection('services')
    .doc(serviceId);
  const srvSnap = await transaction.get(srvRef);
  if (!srvSnap.exists) {
    throw new HttpsError(
      'not-found',
      'SERVICE_NOT_FOUND: Service does not exist.'
    );
  }
  const srvData = srvSnap.data() || {};
  const serviceIsActive = (srvData.is_active ?? srvData.isActive) !== false;
  const serviceIsBookable =
    (srvData.is_bookable ?? srvData.isBookable) !== false;

  if (!serviceIsActive || !serviceIsBookable) {
    throw new HttpsError(
      'failed-precondition',
      'SERVICE_INACTIVE: Selected service is not currently active or bookable.'
    );
  }

  const price = typeof srvData.price === 'number' ? srvData.price : 0;
  const discountPrice =
    typeof srvData.discountPrice === 'number' && srvData.discountPrice > 0
      ? srvData.discountPrice
      : (typeof srvData.discount_price === 'number' && srvData.discount_price > 0
          ? srvData.discount_price
          : null);

  const effectivePrice = discountPrice !== null ? discountPrice : price;
  const durationMinutes =
    typeof srvData.durationMinutes === 'number' && srvData.durationMinutes > 0
      ? srvData.durationMinutes
      : (typeof srvData.duration_minutes === 'number' && srvData.duration_minutes > 0
          ? srvData.duration_minutes
          : 30);

  const calculatedEndAt = new Date(
    requestedStartAt.getTime() + durationMinutes * 60 * 1000
  );

  const staffRef = db
    .collection('businesses')
    .doc(businessId)
    .collection('staff')
    .doc(staffId);
  const staffSnap = await transaction.get(staffRef);
  if (!staffSnap.exists) {
    throw new HttpsError(
      'not-found',
      'STAFF_NOT_FOUND: Staff member does not exist.'
    );
  }
  const staffData = staffSnap.data() || {};
  const staffIsActive = (staffData.is_active ?? staffData.isActive) !== false;
  if (!staffIsActive) {
    throw new HttpsError(
      'failed-precondition',
      'STAFF_INACTIVE: Staff member is currently inactive.'
    );
  }

  const serviceIds: string[] = Array.isArray(staffData.serviceIds)
    ? staffData.serviceIds
    : Array.isArray(staffData.service_ids)
    ? staffData.service_ids
    : [];

  if (serviceIds.length > 0 && !serviceIds.includes(serviceId)) {
    throw new HttpsError(
      'invalid-argument',
      'STAFF_INELIGIBLE: Selected specialist does not perform this service.'
    );
  }

  const zonedStart = getZonedDayAndMinutes(requestedStartAt, businessTimeZone);
  const normalizedDay = zonedStart.weekday;

  const workingDays: number[] | null = Array.isArray(staffData.workingDays)
    ? staffData.workingDays
    : Array.isArray(staffData.working_days)
    ? staffData.working_days
    : null;

  if (workingDays && !workingDays.includes(normalizedDay)) {
    throw new HttpsError(
      'failed-precondition',
      'STAFF_NOT_WORKING_DAY: Specialist does not work on this day of the week.'
    );
  }

  const shiftStartStr = staffData.shiftStart || staffData.shift_start || null;
  const shiftEndStr = staffData.shiftEnd || staffData.shift_end || null;

  const candStartMin = zonedStart.minutes;
  const candEndMin = candStartMin + durationMinutes;

  if (shiftStartStr) {
    const sStartMin = parseTimeStringToMinutes(shiftStartStr);
    if (candStartMin < sStartMin) {
      throw new HttpsError(
        'failed-precondition',
        'OUTSIDE_STAFF_SHIFT: Requested time is before employee shift start.'
      );
    }
  }

  if (shiftEndStr) {
    const sEndMin = parseTimeStringToMinutes(shiftEndStr);
    if (candEndMin > sEndMin) {
      throw new HttpsError(
        'failed-precondition',
        'OUTSIDE_STAFF_SHIFT: Requested appointment exceeds employee shift end.'
      );
    }
  }

  const toffSnap = await db
    .collection('businesses')
    .doc(businessId)
    .collection('timeOffs')
    .where('employeeId', '==', staffId)
    .get();

  const reqStartMs = requestedStartAt.getTime();
  const reqEndMs = calculatedEndAt.getTime();

  for (const doc of toffSnap.docs) {
    const toff = doc.data();
    let toffStartMs = 0;
    let toffEndMs = 0;

    if (toff.startDate && typeof toff.startDate.toMillis === 'function') {
      toffStartMs = toff.startDate.toMillis();
    } else if (typeof toff.startDate === 'string') {
      toffStartMs = new Date(toff.startDate).getTime();
    }

    if (toff.endDate && typeof toff.endDate.toMillis === 'function') {
      toffEndMs = toff.endDate.toMillis();
    } else if (typeof toff.endDate === 'string') {
      toffEndMs = new Date(toff.endDate).getTime();
    }

    if (toffStartMs > 0 && toffEndMs > 0) {
      if (reqStartMs < toffEndMs && reqEndMs > toffStartMs) {
        throw new HttpsError(
          'failed-precondition',
          'STAFF_ON_LEAVE: Specialist is on approved leave/time-off during this interval.'
        );
      }
    }
  }

  return {
    businessName: bizData.name || 'Business',
    serviceName: srvData.name || 'Service',
    servicePrice: effectivePrice,
    currency: srvData.currency || 'AED',
    durationMinutes,
    calculatedEndAt,
    staffName: staffData.name || 'Specialist',
  };
}
