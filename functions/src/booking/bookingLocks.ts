import { HttpsError } from 'firebase-functions/v2/https';

export interface IntervalSlotLock {
  lockId: string;
  startTimestamp: number;
  startDateTime: Date;
}

export function generateIntervalSlotLockIds(
  businessId: string,
  staffId: string,
  start: Date,
  end: Date
): IntervalSlotLock[] {
  const locks: IntervalSlotLock[] = [];
  const bucketMs = 15 * 60 * 1000;
  const startMs = start.getTime();
  const endMs = end.getTime();

  if (!Number.isFinite(startMs) || !Number.isFinite(endMs) || endMs <= startMs) {
    throw new HttpsError(
      'invalid-argument',
      'INVALID_BOOKING_INTERVAL: Appointment end time must be after its start time.'
    );
  }

  for (let t = startMs; t < endMs; t += bucketMs) {
    const lockId = `${businessId}_${staffId}_${t}`;
    locks.push({
      lockId,
      startTimestamp: t,
      startDateTime: new Date(t),
    });
  }

  return locks;
}

export function validateCanonical15MinAlignment(date: Date): void {
  if (
    !Number.isFinite(date.getTime()) ||
    date.getUTCMinutes() % 15 !== 0 ||
    date.getUTCSeconds() !== 0 ||
    date.getUTCMilliseconds() !== 0
  ) {
    throw new HttpsError(
      'invalid-argument',
      'INVALID_CANONICAL_ALIGNMENT: Appointment start time must be aligned to 15-minute intervals.'
    );
  }
}
