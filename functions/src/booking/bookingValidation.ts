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
  const candidate =
    typeof raw === 'string' && raw.trim().length > 0
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
  // The Flutter availability engine currently models one calendar-day window.
  // Reject overnight configuration here as well so client and server never
  // disagree about a slot that crosses midnight.
  if (intervalEnd <= intervalStart) {
    throw new HttpsError(
      'failed-precondition',
      'INVALID_WORKING_HOURS: Overnight working-hour intervals are not supported yet.'
    );
  }

  if (startMinute < intervalStart || endMinute > intervalEnd) {
    throw new HttpsError('failed-precondition', `${code}: ${message}`);
  }
}

function readString(
  source: Record<string, unknown>,
  ...keys: string[]
): string | null {
  for (const key of keys) {
    const value = source[key];
    if (typeof value === 'string' && value.trim().length > 0) {
      return value.trim();
    }
  }
  return null;
}

function readServiceDurationMinutes(
  source: Record<string, unknown>
): number | null {
  const numeric =
    typeof source.durationMinutes === 'number'
      ? source.durationMinutes
      : typeof source.duration_minutes === 'number'
        ? source.duration_minutes
        : null;
  if (numeric !== null) return Math.round(numeric);

  if (typeof source.duration === 'string') {
    const match = source.duration.match(/\d+/);
    if (match) return Number.parseInt(match[0], 10);
  }

  return null;
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
  const isActive = (bizData.isActive ?? bizData.is_active) === true;
  const acceptingBookings =
    (bizData.acceptingBookings ?? bizData.accepting_bookings) === true;
  const businessStatus =
    bizData.businessStatus || bizData.business_status || 'closed';

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
    throw new HttpsError(
      'not-found',
      'SERVICE_NOT_FOUND: Service does not exist.'
    );
  }
  const srvData = srvSnap.data() || {};
  const serviceActive = (srvData.isActive ?? srvData.is_active) === true;
  const serviceBookable =
    (srvData.isBookable ?? srvData.is_bookable) === true;
  if (!serviceActive || !serviceBookable) {
    throw new HttpsError(
      'failed-precondition',
      'SERVICE_INACTIVE: Selected service is not currently bookable.'
    );
  }

  const price =
    typeof srvData.price === 'number' && Number.isFinite(srvData.price)
      ? srvData.price
      : null;
  if (price === null || price < 0) {
    throw new HttpsError(
      'failed-precondition',
      'INVALID_SERVICE_PRICE: The selected service has an invalid price.'
    );
  }

  const rawDiscount =
    typeof srvData.discountPrice === 'number'
      ? srvData.discountPrice
      : typeof srvData.discount_price === 'number'
        ? srvData.discount_price
        : null;
  const discountPrice =
    rawDiscount !== null &&
    Number.isFinite(rawDiscount) &&
    rawDiscount > 0 &&
    rawDiscount < price
      ? rawDiscount
      : null;
  const effectivePrice = discountPrice ?? price;

  const durationMinutes = readServiceDurationMinutes(srvData);
  if (
    durationMinutes === null ||
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
    throw new HttpsError(
      'not-found',
      'STAFF_NOT_FOUND: Staff member does not exist.'
    );
  }
  const staffData = staffSnap.data() || {};
  if ((staffData.isActive ?? staffData.is_active) !== true) {
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
  if (localStart.dateKey !== localEnd.dateKey) {
    throw new HttpsError(
      'failed-precondition',
      'OUTSIDE_BUSINESS_HOURS: Appointments crossing midnight are not supported.'
    );
  }

  // Business opening hours are authoritative and required for online booking.
  // Missing or partial schedules fail closed instead of inventing hours.
  const businessHours = bizData.workingHours ?? bizData.working_hours;
  if (!businessHours || typeof businessHours !== 'object') {
    throw new HttpsError(
      'failed-precondition',
      'BUSINESS_HOURS_NOT_CONFIGURED: Business working hours are required before accepting bookings.'
    );
  }

  const dayConfig =
    businessHours[localStart.dayName.toLowerCase()] ??
    businessHours[localStart.dayName];
  if (!dayConfig || typeof dayConfig !== 'object') {
    throw new HttpsError(
      'failed-precondition',
      'OUTSIDE_BUSINESS_HOURS: Business is closed on the selected day.'
    );
  }
  if ((dayConfig.isClosed ?? dayConfig.is_closed) === true) {
    throw new HttpsError(
      'failed-precondition',
      'OUTSIDE_BUSINESS_HOURS: Business is closed on the selected day.'
    );
  }

  const openRaw = readString(dayConfig, 'openTime', 'open_time', 'open');
  const closeRaw = readString(dayConfig, 'closeTime', 'close_time', 'close');
  if (!openRaw || !closeRaw) {
    throw new HttpsError(
      'failed-precondition',
      'INVALID_WORKING_HOURS: Open and close times must be configured for the selected day.'
    );
  }

  validateWithinInterval(
    localStart.minuteOfDay,
    localEnd.minuteOfDay,
    parseTimeStringToMinutes(openRaw),
    parseTimeStringToMinutes(closeRaw),
    'OUTSIDE_BUSINESS_HOURS',
    'Requested appointment is outside business operating hours.'
  );

  // Mirror the Flutter availability engine: a per-day weekly schedule takes
  // precedence over the legacy workingDays + global shift fields.
  let usedWeeklySchedule = false;
  const weeklySchedule = staffData.weeklySchedule ?? staffData.weekly_schedule;
  if (weeklySchedule && typeof weeklySchedule === 'object') {
    const rawDaySchedule =
      weeklySchedule[localStart.dayName] ??
      weeklySchedule[localStart.dayName.toLowerCase()];
    if (rawDaySchedule && typeof rawDaySchedule === 'object') {
      usedWeeklySchedule = true;
      const daySchedule = rawDaySchedule as Record<string, unknown>;
      if ((daySchedule.isWorking ?? daySchedule.is_working) === false) {
        throw new HttpsError(
          'failed-precondition',
          'STAFF_NOT_WORKING_DAY: Specialist does not work on this day of the week.'
        );
      }

      const dayOpen = readString(
        daySchedule,
        'openTime',
        'open_time',
        'open'
      );
      const dayClose = readString(
        daySchedule,
        'closeTime',
        'close_time',
        'close'
      );
      if (dayOpen && dayClose) {
        validateWithinInterval(
          localStart.minuteOfDay,
          localEnd.minuteOfDay,
          parseTimeStringToMinutes(dayOpen),
          parseTimeStringToMinutes(dayClose),
          'OUTSIDE_STAFF_SHIFT',
          'Requested appointment is outside the employee shift.'
        );
      }

      const breakStart = readString(
        daySchedule,
        'breakStart',
        'break_start'
      );
      const breakEnd = readString(daySchedule, 'breakEnd', 'break_end');
      if (breakStart && breakEnd) {
        const breakStartMinute = parseTimeStringToMinutes(breakStart);
        const breakEndMinute = parseTimeStringToMinutes(breakEnd);
        if (breakEndMinute <= breakStartMinute) {
          throw new HttpsError(
            'failed-precondition',
            'INVALID_WORKING_HOURS: Employee break end must be after break start.'
          );
        }
        if (
          localStart.minuteOfDay < breakEndMinute &&
          localEnd.minuteOfDay > breakStartMinute
        ) {
          throw new HttpsError(
            'failed-precondition',
            'STAFF_ON_BREAK: Specialist is on a scheduled break during this interval.'
          );
        }
      }
    }
  }

  if (!usedWeeklySchedule) {
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

    const shiftStartStr =
      typeof staffData.shiftStart === 'string'
        ? staffData.shiftStart
        : typeof staffData.shift_start === 'string'
          ? staffData.shift_start
          : null;
    const shiftEndStr =
      typeof staffData.shiftEnd === 'string'
        ? staffData.shiftEnd
        : typeof staffData.shift_end === 'string'
          ? staffData.shift_end
          : null;

    if (shiftStartStr && shiftEndStr) {
      validateWithinInterval(
        localStart.minuteOfDay,
        localEnd.minuteOfDay,
        parseTimeStringToMinutes(shiftStartStr),
        parseTimeStringToMinutes(shiftEndStr),
        'OUTSIDE_STAFF_SHIFT',
        'Requested appointment is outside the employee shift.'
      );
    } else {
      if (
        shiftStartStr &&
        localStart.minuteOfDay < parseTimeStringToMinutes(shiftStartStr)
      ) {
        throw new HttpsError(
          'failed-precondition',
          'OUTSIDE_STAFF_SHIFT: Requested time is before employee shift start.'
        );
      }
      if (
        shiftEndStr &&
        localEnd.minuteOfDay > parseTimeStringToMinutes(shiftEndStr)
      ) {
        throw new HttpsError(
          'failed-precondition',
          'OUTSIDE_STAFF_SHIFT: Requested appointment exceeds employee shift end.'
        );
      }
    }
  }

  const timeOffCollection = db
    .collection('businesses')
    .doc(businessId)
    .collection('timeOffs');
  const currentTimeOffSnap = await transaction.get(
    timeOffCollection.where('employeeId', '==', staffId)
  );
  const legacyTimeOffSnap = await transaction.get(
    timeOffCollection.where('employee_id', '==', staffId)
  );
  const timeOffDocs = new Map<string, admin.firestore.QueryDocumentSnapshot>();
  for (const doc of currentTimeOffSnap.docs) timeOffDocs.set(doc.id, doc);
  for (const doc of legacyTimeOffSnap.docs) timeOffDocs.set(doc.id, doc);

  const reqStartMs = requestedStartAt.getTime();
  const reqEndMs = calculatedEndAt.getTime();
  for (const doc of timeOffDocs.values()) {
    const timeOff = doc.data();
    let timeOffStartMs = 0;
    let timeOffEndMs = 0;

    if (
      timeOff.startDate &&
      typeof timeOff.startDate.toMillis === 'function'
    ) {
      timeOffStartMs = timeOff.startDate.toMillis();
    } else if (typeof timeOff.startDate === 'string') {
      timeOffStartMs = new Date(timeOff.startDate).getTime();
    }

    if (timeOff.endDate && typeof timeOff.endDate.toMillis === 'function') {
      timeOffEndMs = timeOff.endDate.toMillis();
    } else if (typeof timeOff.endDate === 'string') {
      timeOffEndMs = new Date(timeOff.endDate).getTime();
    }

    if (
      timeOffStartMs > 0 &&
      timeOffEndMs > 0 &&
      reqStartMs < timeOffEndMs &&
      reqEndMs > timeOffStartMs
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
