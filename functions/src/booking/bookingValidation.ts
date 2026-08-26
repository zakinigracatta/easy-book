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
  timeZone: string;
}

const DEFAULT_TIME_ZONE = 'Asia/Dubai';

const WEEKDAY_NUMBER: Record<string, number> = {
  Monday: 1,
  Tuesday: 2,
  Wednesday: 3,
  Thursday: 4,
  Friday: 5,
  Saturday: 6,
  Sunday: 7,
};

export function parseTimeStringToMinutes(raw: string): number {
  const clean = raw.trim();
  const isPm = clean.toUpperCase().includes('PM');
  const isAm = clean.toUpperCase().includes('AM');
  const numbersStr = clean.replace(/[^\d:]/g, '');
  const parts = numbersStr.split(':');
  let hour = Number.parseInt(parts[0], 10);
  const minute = parts.length > 1 ? Number.parseInt(parts[1], 10) : 0;

  if (!Number.isInteger(hour) || !Number.isInteger(minute)) {
    throw new HttpsError(
      'failed-precondition',
      'INVALID_WORKING_HOURS: A configured working-hours value is invalid.'
    );
  }
  if (minute < 0 || minute > 59 || hour < 0 || hour > 23) {
    throw new HttpsError(
      'failed-precondition',
      'INVALID_WORKING_HOURS: A configured working-hours value is invalid.'
    );
  }
  if ((isAm || isPm) && hour > 12) {
    throw new HttpsError(
      'failed-precondition',
      'INVALID_WORKING_HOURS: A configured 12-hour time value is invalid.'
    );
  }

  if (isPm && hour < 12) hour += 12;
  if (isAm && hour === 12) hour = 0;
  return hour * 60 + minute;
}

function resolveTimeZone(raw: unknown): string {
  const candidate = typeof raw === 'string' && raw.trim().length > 0
    ? raw.trim()
    : DEFAULT_TIME_ZONE;
  try {
    new Intl.DateTimeFormat('en-US', { timeZone: candidate }).format(new Date());
    return candidate;
  } catch (_) {
    return DEFAULT_TIME_ZONE;
  }
}

function zonedParts(date: Date, timeZone: string): {
  dayName: string;
  dayNumber: number;
  minuteOfDay: number;
  dateKey: string;
} {
  const parts = new Intl.DateTimeFormat('en-US', {
    timeZone,
    weekday: 'long',
    year: 'numeric',
    month: '2-digit',
    day: '2-digit',
    hour: '2-digit',
    minute: '2-digit',
    hourCycle: 'h23',
  }).formatToParts(date);

  const values: Record<string, string> = {};
  for (const part of parts) {
    if (part.type !== 'literal') values[part.type] = part.value;
  }

  const dayName = values.weekday;
  const hour = Number.parseInt(values.hour, 10);
  const minute = Number.parseInt(values.minute, 10);
  const dayNumber = WEEKDAY_NUMBER[dayName];
  if (!dayNumber || !Number.isInteger(hour) || !Number.isInteger(minute)) {
    throw new HttpsError(
      'internal',
      'TIMEZONE_CONVERSION_FAILED: Could not validate the appointment time.'
    );
  }

  return {
    dayName,
    dayNumber,
    minuteOfDay: hour * 60 + minute,
    dateKey: `${values.year}-${values.month}-${values.day}`,
  };
}

function validateWithinInterval(
  startMinute: number,
  endMinute: number,
  intervalStart: number,
  intervalEnd: number,
  code: string,
  message: string
): void {
  // Same-day schedules are canonical in the current Easy Book model. If an
  // owner configures an overnight shift (end <= start), accept the part after
  // start or before end instead of treating every late appointment as invalid.
  const inside = intervalEnd > intervalStart
    ? startMinute >= intervalStart && endMinute <= intervalEnd
    : startMinute >= intervalStart || endMinute <= intervalEnd;

  if (!inside) {
    throw new HttpsError('failed-precondition', `${code}: ${message}`);
  }
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
  const isActive = (bizData.isActive ?? bizData.is_active) !== false;
  const acceptingBookings =
    (bizData.acceptingBookings ?? bizData.accepting_bookings) !== false;
  const businessStatus =
    bizData.businessStatus || bizData.business_status || 'open';

  if (!isActive || !acceptingBookings || businessStatus !== 'open') {
    throw new HttpsError(
      'failed-precondition',
      'BUSINESS_NOT_ACCEPTING_BOOKINGS: Business is currently closed or not accepting bookings.'
    );
  }

  const timeZone = resolveTimeZone(bizData.timeZone ?? bizData.timezone);

  const srvRef = db
    .collection('businesses')
    .doc(businessId)
    .collection('services')
    .doc(serviceId);
  const srvSnap = await transaction.get(srvRef);
  if (!srvSnap.exists) {
    throw new HttpsError('not-found', 'SERVICE_NOT_FOUND: Service does not exist.');
  }
  const srvData = srvSnap.data() || {};
  if ((srvData.isActive ?? srvData.is_active) === false) {
    throw new HttpsError(
      'failed-precondition',
      'SERVICE_INACTIVE: Selected service is not currently active.'
    );
  }

  const price = typeof srvData.price === 'number' ? srvData.price : 0;
  const discountPrice =
    typeof srvData.discountPrice === 'number' && srvData.discountPrice >= 0
      ? srvData.discountPrice
      : typeof srvData.discount_price === 'number' && srvData.discount_price >= 0
        ? srvData.discount_price
        : null;
  const effectivePrice = discountPrice ?? price;

  if (!Number.isFinite(effectivePrice) || effectivePrice < 0) {
    throw new HttpsError(
      'failed-precondition',
      'INVALID_SERVICE_PRICE: The selected service has an invalid price.'
    );
  }

  const durationRaw =
    typeof srvData.durationMinutes === 'number'
      ? srvData.durationMinutes
      : typeof srvData.duration_minutes === 'number'
        ? srvData.duration_minutes
        : 30;
  const durationMinutes = Math.round(durationRaw);
  if (
    !Number.isFinite(durationMinutes) ||
    durationMinutes <= 0 ||
    durationMinutes > 24 * 60
  ) {
    throw new HttpsError(
      'failed-precondition',
      'INVALID_SERVICE_DURATION: The selected service has an invalid duration.'
    );
  }

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
    throw new HttpsError('not-found', 'STAFF_NOT_FOUND: Staff member does not exist.');
  }
  const staffData = staffSnap.data() || {};
  if ((staffData.isActive ?? staffData.is_active) === false) {
    throw new HttpsError(
      'failed-precondition',
      'STAFF_INACTIVE: Staff member is currently inactive.'
    );
  }

  const serviceIds: string[] = Array.isArray(staffData.serviceIds)
    ? staffData.serviceIds.map(String)
    : Array.isArray(staffData.service_ids)
      ? staffData.service_ids.map(String)
      : [];
  if (serviceIds.length > 0 && !serviceIds.includes(serviceId)) {
    throw new HttpsError(
      'invalid-argument',
      'STAFF_INELIGIBLE: Selected specialist does not perform this service.'
    );
  }

  // Appointment schedule checks must use the business timezone, not the Cloud
  // Functions server timezone (UTC). This prevents UAE bookings from shifting
  // four hours and being compared against the wrong work shift.
  const localStart = zonedParts(requestedStartAt, timeZone);
  const localEnd = zonedParts(calculatedEndAt, timeZone);

  const workingDays: number[] | null = Array.isArray(staffData.workingDays)
    ? staffData.workingDays.map(Number)
    : Array.isArray(staffData.working_days)
      ? staffData.working_days.map(Number)
      : null;
  if (workingDays && !workingDays.includes(localStart.dayNumber)) {
    throw new HttpsError(
      'failed-precondition',
      'STAFF_NOT_WORKING_DAY: Specialist does not work on this day of the week.'
    );
  }

  // Business opening hours are authoritative as well. Older records may not
  // contain them, in which case staff hours remain the limiting schedule.
  const businessHours = bizData.workingHours ?? bizData.working_hours;
  if (businessHours && typeof businessHours === 'object') {
    const dayConfig =
      businessHours[localStart.dayName.toLowerCase()] ??
      businessHours[localStart.dayName];
    if (dayConfig && typeof dayConfig === 'object') {
      if ((dayConfig.isClosed ?? dayConfig.is_closed) === true) {
        throw new HttpsError(
          'failed-precondition',
          'OUTSIDE_BUSINESS_HOURS: Business is closed on the selected day.'
        );
      }
      const openRaw = dayConfig.open;
      const closeRaw = dayConfig.close;
      if (typeof openRaw === 'string' && typeof closeRaw === 'string') {
        const openMinute = parseTimeStringToMinutes(openRaw);
        const closeMinute = parseTimeStringToMinutes(closeRaw);
        validateWithinInterval(
          localStart.minuteOfDay,
          localEnd.minuteOfDay,
          openMinute,
          closeMinute,
          'OUTSIDE_BUSINESS_HOURS',
          'Requested appointment is outside business operating hours.'
        );
      }
    }
  }

  const shiftStartStr = staffData.shiftStart || staffData.shift_start || null;
  const shiftEndStr = staffData.shiftEnd || staffData.shift_end || null;
  if (typeof shiftStartStr === 'string' && typeof shiftEndStr === 'string') {
    const shiftStart = parseTimeStringToMinutes(shiftStartStr);
    const shiftEnd = parseTimeStringToMinutes(shiftEndStr);
    validateWithinInterval(
      localStart.minuteOfDay,
      localEnd.minuteOfDay,
      shiftStart,
      shiftEnd,
      'OUTSIDE_STAFF_SHIFT',
      'Requested appointment is outside the employee shift.'
    );
  } else {
    if (typeof shiftStartStr === 'string') {
      const shiftStart = parseTimeStringToMinutes(shiftStartStr);
      if (localStart.minuteOfDay < shiftStart) {
        throw new HttpsError(
          'failed-precondition',
          'OUTSIDE_STAFF_SHIFT: Requested time is before employee shift start.'
        );
      }
    }
    if (typeof shiftEndStr === 'string') {
      const shiftEnd = parseTimeStringToMinutes(shiftEndStr);
      if (
        localStart.dateKey !== localEnd.dateKey ||
        localEnd.minuteOfDay > shiftEnd
      ) {
        throw new HttpsError(
          'failed-precondition',
          'OUTSIDE_STAFF_SHIFT: Requested appointment exceeds employee shift end.'
        );
      }
    }
  }

  const timeOffQuery = db
    .collection('businesses')
    .doc(businessId)
    .collection('timeOffs')
    .where('employeeId', '==', staffId);
  const toffSnap = await transaction.get(timeOffQuery);

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

    if (
      toffStartMs > 0 &&
      toffEndMs > 0 &&
      reqStartMs < toffEndMs &&
      reqEndMs > toffStartMs
    ) {
      throw new HttpsError(
        'failed-precondition',
        'STAFF_ON_LEAVE: Specialist is on approved leave/time-off during this interval.'
      );
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
    timeZone,
  };
}
