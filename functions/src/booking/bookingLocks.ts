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

  for (let t = startMs; t < endMs; t += bucketMs) {
    const lockId = `${businessId}_${staffId}_${t}`;
    locks.push({
      lockId,
      startTimestamp: t,
      startDateTime: new Date(t),
    });
  }

  if (locks.length === 0) {
    const lockId = `${businessId}_${staffId}_${startMs}`;
    locks.push({
      lockId,
      startTimestamp: startMs,
      startDateTime: new Date(startMs),
    });
  }

  return locks;
}

export function validateCanonical15MinAlignment(date: Date): void {
  if (
    date.getMinutes() % 15 !== 0 ||
    date.getSeconds() !== 0 ||
    date.getMilliseconds() !== 0
  ) {
    throw new Error(
      'INVALID_CANONICAL_ALIGNMENT: Appointment start time must be aligned to 15-minute intervals.'
    );
  }
}
