import { FieldValue, Timestamp } from 'firebase-admin/firestore';

export function generateIntervalSlotLockIds(businessId, staffId, start, end) {
  const locks = [];
  const bucketMs = 15 * 60 * 1000;
  const startMs = start.getTime();
  const endMs = end.getTime();

  for (let t = startMs; t < endMs; t += bucketMs) {
    locks.push({
      lockId: `${businessId}_${staffId}_${t}`,
      startTimestamp: t,
      startDateTime: new Date(t),
    });
  }

  if (locks.length === 0) {
    locks.push({
      lockId: `${businessId}_${staffId}_${startMs}`,
      startTimestamp: startMs,
      startDateTime: new Date(startMs),
    });
  }

  return locks;
}

export function parseTimeStringToMinutes(raw) {
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

export async function createBookingInternal(db, params) {
  const {
    customerId,
    customerName = 'Customer',
    businessId,
    serviceId,
    staffId,
    requestedStartAt,
    bookingSource = 'app',
    notes = '',
  } = params;

  if (
    requestedStartAt.getUTCMinutes() % 15 !== 0 ||
    requestedStartAt.getUTCSeconds() !== 0 ||
    requestedStartAt.getUTCMilliseconds() !== 0
  ) {
    throw new Error('INVALID_CANONICAL_ALIGNMENT');
  }

  // Pre-query timeOffs outside transaction
  const toffSnap = await db
    .collection('businesses')
    .doc(businessId)
    .collection('timeOffs')
    .where('employeeId', '==', staffId)
    .get();

  return await db.runTransaction(async (transaction) => {
    // 1. Business Check
    const bizRef = db.collection('businesses').doc(businessId);
    const bizSnap = await transaction.get(bizRef);
    if (!bizSnap.exists) throw new Error('BUSINESS_NOT_FOUND');
    const bizData = bizSnap.data() || {};
    if (
      bizData.isActive === false ||
      bizData.acceptingBookings === false ||
      (bizData.businessStatus && bizData.businessStatus !== 'open')
    ) {
      throw new Error('BUSINESS_NOT_ACCEPTING_BOOKINGS');
    }

    // 2. Service Check
    const srvRef = db
      .collection('businesses')
      .doc(businessId)
      .collection('services')
      .doc(serviceId);
    const srvSnap = await transaction.get(srvRef);
    if (!srvSnap.exists) throw new Error('SERVICE_NOT_FOUND');
    const srvData = srvSnap.data() || {};
    if (srvData.isActive === false) throw new Error('SERVICE_INACTIVE');

    const price = typeof srvData.price === 'number' ? srvData.price : 0;
    const discountPrice =
      typeof srvData.discountPrice === 'number' && srvData.discountPrice > 0
        ? srvData.discountPrice
        : null;
    const effectivePrice = discountPrice !== null ? discountPrice : price;
    const durationMinutes = srvData.durationMinutes || 30;

    const calculatedEndAt = new Date(
      requestedStartAt.getTime() + durationMinutes * 60 * 1000
    );

    // 3. Staff Check
    const staffRef = db
      .collection('businesses')
      .doc(businessId)
      .collection('staff')
      .doc(staffId);
    const staffSnap = await transaction.get(staffRef);
    if (!staffSnap.exists) throw new Error('STAFF_NOT_FOUND');
    const staffData = staffSnap.data() || {};
    if (staffData.isActive === false) throw new Error('STAFF_INACTIVE');

    // Shift Check (UTC)
    const candStartMin =
      requestedStartAt.getUTCHours() * 60 + requestedStartAt.getUTCMinutes();
    const candEndMin = candStartMin + durationMinutes;

    if (staffData.shiftStart) {
      const sStartMin = parseTimeStringToMinutes(staffData.shiftStart);
      if (candStartMin < sStartMin) throw new Error('BEFORE_STAFF_SHIFT');
    }
    if (staffData.shiftEnd) {
      const sEndMin = parseTimeStringToMinutes(staffData.shiftEnd);
      if (candEndMin > sEndMin) throw new Error('EXCEEDS_STAFF_SHIFT');
    }

    // Time Off Check
    const reqStartMs = requestedStartAt.getTime();
    const reqEndMs = calculatedEndAt.getTime();

    for (const doc of toffSnap.docs) {
      const toff = doc.data();
      let toffStartMs = toff.startDate?.toMillis
        ? toff.startDate.toMillis()
        : new Date(toff.startDate).getTime();
      let toffEndMs = toff.endDate?.toMillis
        ? toff.endDate.toMillis()
        : new Date(toff.endDate).getTime();

      if (reqStartMs < toffEndMs && reqEndMs > toffStartMs) {
        throw new Error('STAFF_ON_LEAVE');
      }
    }

    // Locks Check
    const lockObjects = generateIntervalSlotLockIds(
      businessId,
      staffId,
      requestedStartAt,
      calculatedEndAt
    );

    for (const lock of lockObjects) {
      const lockRef = db.collection('booking_slots').doc(lock.lockId);
      const lockSnap = await transaction.get(lockRef);
      if (lockSnap.exists) {
        throw new Error('SLOT_CONFLICT');
      }
    }

    const bookingDocRef = db.collection('bookings').doc();
    const primarySlotLockId = lockObjects[0].lockId;

    for (const lock of lockObjects) {
      const lockRef = db.collection('booking_slots').doc(lock.lockId);
      transaction.set(lockRef, {
        slotId: lock.lockId,
        bookingId: bookingDocRef.id,
        businessId,
        staffId,
        startDateTime: Timestamp.fromDate(lock.startDateTime),
        startTimestamp: lock.startTimestamp,
        createdAt: FieldValue.serverTimestamp(),
      });
    }

    const status = bookingSource === 'walkIn' ? 'confirmed' : 'pending';

    transaction.set(bookingDocRef, {
      id: bookingDocRef.id,
      customerId,
      customerName,
      customerPhone: '',
      businessId,
      businessName: bizData.name || 'Business',
      serviceId,
      serviceName: srvData.name || 'Service',
      servicePrice: effectivePrice,
      currency: srvData.currency || 'AED',
      durationMinutes,
      staffId,
      staffName: staffData.name || 'Specialist',
      startDateTime: Timestamp.fromDate(requestedStartAt),
      endDateTime: Timestamp.fromDate(calculatedEndAt),
      startTimestamp: requestedStartAt.getTime(),
      status,
      bookingSource,
      notes,
      slotLockId: primarySlotLockId,
      createdAt: FieldValue.serverTimestamp(),
      updatedAt: FieldValue.serverTimestamp(),
    });

    return {
      success: true,
      bookingId: bookingDocRef.id,
      servicePrice: effectivePrice,
      durationMinutes,
      endDateTime: calculatedEndAt.toISOString(),
      status,
    };
  });
}
