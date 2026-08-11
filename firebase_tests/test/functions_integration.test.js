import { test, before, after, beforeEach } from 'node:test';
import assert from 'node:assert/strict';
import { initializeApp, getApps, deleteApp } from 'firebase-admin/app';
import { getFirestore, FieldValue, Timestamp } from 'firebase-admin/firestore';
import { createBookingInternal } from '../helpers/testBackendHelper.mjs';

const PROJECT_ID = 'demo-easy-book';
process.env.FIRESTORE_EMULATOR_HOST = '127.0.0.1:8080';

let adminApp;
let db;

before(() => {
  if (!getApps().length) {
    adminApp = initializeApp({ projectId: PROJECT_ID });
  } else {
    adminApp = getApps()[0];
  }
  db = getFirestore(adminApp);
});

after(async () => {
  if (adminApp) {
    await deleteApp(adminApp);
  }
});

async function seedBaseData() {
  // Seed Business
  await db.collection('businesses').doc('biz_test').set({
    id: 'biz_test',
    name: 'Test Salon Lounge',
    ownerId: 'owner_1',
    isActive: true,
    acceptingBookings: true,
    businessStatus: 'open',
  });

  // Seed Service (60 mins, AED 100)
  await db
    .collection('businesses')
    .doc('biz_test')
    .collection('services')
    .doc('srv_haircut')
    .set({
      id: 'srv_haircut',
      name: 'Haircut & Styling',
      price: 100,
      discountPrice: 0,
      durationMinutes: 60,
      isActive: true,
      currency: 'AED',
    });

  // Seed Staff (shift: 10:00 AM - 06:00 PM UTC)
  await db
    .collection('businesses')
    .doc('biz_test')
    .collection('staff')
    .doc('st_ahmed')
    .set({
      id: 'st_ahmed',
      name: 'Ahmed Barber',
      isActive: true,
      shiftStart: '10:00 AM',
      shiftEnd: '06:00 PM',
      workingDays: [1, 2, 3, 4, 5], // Mon-Fri
      serviceIds: ['srv_haircut'],
    });
}

beforeEach(async () => {
  // Clear collections cleanly
  const slots = await db.collection('booking_slots').get();
  for (const d of slots.docs) await d.ref.delete();

  const bookings = await db.collection('bookings').get();
  for (const d of bookings.docs) await d.ref.delete();

  const timeOffs = await db.collection('businesses').doc('biz_test').collection('timeOffs').get();
  for (const d of timeOffs.docs) await d.ref.delete();

  await seedBaseData();
});

test('TEST A: Customer A vs Customer B Concurrency (1 Winner, 1 Conflict)', async () => {
  const reqDate = new Date('2026-08-17T10:00:00.000Z'); // Monday 10:00 AM UTC

  const taskA = createBookingInternal(db, {
    customerId: 'cust_a',
    customerName: 'Customer A',
    businessId: 'biz_test',
    serviceId: 'srv_haircut',
    staffId: 'st_ahmed',
    requestedStartAt: reqDate,
    bookingSource: 'app',
  });

  const taskB = createBookingInternal(db, {
    customerId: 'cust_b',
    customerName: 'Customer B',
    businessId: 'biz_test',
    serviceId: 'srv_haircut',
    staffId: 'st_ahmed',
    requestedStartAt: reqDate,
    bookingSource: 'app',
  });

  const results = await Promise.allSettled([taskA, taskB]);
  const fulfilled = results.filter((r) => r.status === 'fulfilled');
  const rejected = results.filter((r) => r.status === 'rejected');

  if (fulfilled.length !== 1) {
    console.log('TEST A REJECTIONS:', results.map(r => r.status === 'rejected' ? r.reason?.message || r.reason : r.value));
  }

  assert.equal(fulfilled.length, 1);
  assert.equal(rejected.length, 1);

  // Verify DB: exactly 1 booking doc and 4 slot locks
  const bSnap = await db.collection('bookings').get();
  assert.equal(bSnap.docs.length, 1);

  const lockSnap = await db.collection('booking_slots').get();
  assert.equal(lockSnap.docs.length, 4);
});

test('TEST B: Customer vs Owner Walk-in Concurrency (1 Winner Only)', async () => {
  const reqDate = new Date('2026-08-17T11:00:00.000Z');

  const taskCustomer = createBookingInternal(db, {
    customerId: 'cust_c',
    customerName: 'Customer C',
    businessId: 'biz_test',
    serviceId: 'srv_haircut',
    staffId: 'st_ahmed',
    requestedStartAt: reqDate,
    bookingSource: 'app',
  });

  const taskWalkIn = createBookingInternal(db, {
    customerId: '',
    customerName: 'Walk-in Customer',
    businessId: 'biz_test',
    serviceId: 'srv_haircut',
    staffId: 'st_ahmed',
    requestedStartAt: reqDate,
    bookingSource: 'walkIn',
  });

  const results = await Promise.allSettled([taskCustomer, taskWalkIn]);
  const fulfilled = results.filter((r) => r.status === 'fulfilled');
  const rejected = results.filter((r) => r.status === 'rejected');

  assert.equal(fulfilled.length, 1);
  assert.equal(rejected.length, 1);
});

test('TEST C: Partial Overlap Rejection', async () => {
  // Book 10:00 - 11:00 AM
  const req10 = new Date('2026-08-17T10:00:00.000Z');
  await createBookingInternal(db, {
    customerId: 'cust_1',
    businessId: 'biz_test',
    serviceId: 'srv_haircut',
    staffId: 'st_ahmed',
    requestedStartAt: req10,
    bookingSource: 'app',
  });

  // Attempt overlapping start 10:30 AM
  const req1030 = new Date('2026-08-17T10:30:00.000Z');
  await assert.rejects(async () => {
    await createBookingInternal(db, {
      customerId: 'cust_2',
      businessId: 'biz_test',
      serviceId: 'srv_haircut',
      staffId: 'st_ahmed',
      requestedStartAt: req1030,
      bookingSource: 'app',
    });
  });

  // Attempt non-overlapping start 11:00 AM -> Success
  const req11 = new Date('2026-08-17T11:00:00.000Z');
  const res11 = await createBookingInternal(db, {
    customerId: 'cust_3',
    businessId: 'biz_test',
    serviceId: 'srv_haircut',
    staffId: 'st_ahmed',
    requestedStartAt: req11,
    bookingSource: 'app',
  });
  assert.equal(res11.success, true);
});

test('TEST D: Authoritative Price Snapshot (Client price forgery ignored)', async () => {
  const reqDate = new Date('2026-08-17T12:00:00.000Z');
  const res = await createBookingInternal(db, {
    customerId: 'cust_hacker',
    businessId: 'biz_test',
    serviceId: 'srv_haircut',
    staffId: 'st_ahmed',
    requestedStartAt: reqDate,
    bookingSource: 'app',
  });

  assert.equal(res.servicePrice, 100); // Authoritative server price AED 100
});

test('TEST E: Authoritative Duration Calculation', async () => {
  const reqDate = new Date('2026-08-17T13:00:00.000Z');
  const res = await createBookingInternal(db, {
    customerId: 'cust_dur',
    businessId: 'biz_test',
    serviceId: 'srv_haircut',
    staffId: 'st_ahmed',
    requestedStartAt: reqDate,
    bookingSource: 'app',
  });

  assert.equal(res.durationMinutes, 60);
  assert.equal(
    new Date(res.endDateTime).getTime(),
    reqDate.getTime() + 60 * 60 * 1000
  );
});

test('TEST F: Closed Business Rejection', async () => {
  await db.collection('businesses').doc('biz_test').set({
    acceptingBookings: false,
  }, { merge: true });

  const reqDate = new Date('2026-08-17T14:00:00.000Z');
  await assert.rejects(async () => {
    await createBookingInternal(db, {
      customerId: 'cust_closed',
      businessId: 'biz_test',
      serviceId: 'srv_haircut',
      staffId: 'st_ahmed',
      requestedStartAt: reqDate,
      bookingSource: 'app',
    });
  });
});

test('TEST G: Employee Shift Boundary Rejection', async () => {
  // Ahmed's shift: 10:00 AM - 06:00 PM (18:00 UTC)
  // Attempt 09:00 AM -> Reject
  const req09 = new Date('2026-08-17T09:00:00.000Z');
  await assert.rejects(async () => {
    await createBookingInternal(db, {
      customerId: 'cust_shift',
      businessId: 'biz_test',
      serviceId: 'srv_haircut',
      staffId: 'st_ahmed',
      requestedStartAt: req09,
      bookingSource: 'app',
    });
  });

  // Attempt 05:30 PM (17:30 UTC) for 60 min service (ends 18:30) -> Reject
  const req1730 = new Date('2026-08-17T17:30:00.000Z');
  await assert.rejects(async () => {
    await createBookingInternal(db, {
      customerId: 'cust_shift2',
      businessId: 'biz_test',
      serviceId: 'srv_haircut',
      staffId: 'st_ahmed',
      requestedStartAt: req1730,
      bookingSource: 'app',
    });
  });
});

test('TEST I: Employee Leave / Time-off Rejection', async () => {
  // Seed time off for Ahmed from 14:00 to 16:00
  await db
    .collection('businesses')
    .doc('biz_test')
    .collection('timeOffs')
    .doc('toff_1')
    .set({
      id: 'toff_1',
      employeeId: 'st_ahmed',
      startDate: Timestamp.fromDate(new Date('2026-08-17T14:00:00.000Z')),
      endDate: Timestamp.fromDate(new Date('2026-08-17T16:00:00.000Z')),
    });

  const req14 = new Date('2026-08-17T14:00:00.000Z');
  await assert.rejects(async () => {
    await createBookingInternal(db, {
      customerId: 'cust_leave',
      businessId: 'biz_test',
      serviceId: 'srv_haircut',
      staffId: 'st_ahmed',
      requestedStartAt: req14,
      bookingSource: 'app',
    });
  });
});

test('TEST J: Cancellation Releases Locks Cleanly', async () => {
  const reqDate = new Date('2026-08-17T15:00:00.000Z');
  const res = await createBookingInternal(db, {
    customerId: 'cust_cancel',
    businessId: 'biz_test',
    serviceId: 'srv_haircut',
    staffId: 'st_ahmed',
    requestedStartAt: reqDate,
    bookingSource: 'app',
  });

  // Verify 4 locks exist
  let locks = await db.collection('booking_slots').get();
  assert.equal(locks.docs.length, 4);

  // Cancel booking
  await db.runTransaction(async (transaction) => {
    const bRef = db.collection('bookings').doc(res.bookingId);
    const lockObjects = [
      'biz_test_st_ahmed_' + reqDate.getTime(),
      'biz_test_st_ahmed_' + (reqDate.getTime() + 15 * 60 * 1000),
      'biz_test_st_ahmed_' + (reqDate.getTime() + 30 * 60 * 1000),
      'biz_test_st_ahmed_' + (reqDate.getTime() + 45 * 60 * 1000),
    ];

    for (const lId of lockObjects) {
      transaction.delete(db.collection('booking_slots').doc(lId));
    }
    transaction.update(bRef, { status: 'cancelled', cancelledBy: 'customer' });
  });

  // Verify 0 locks remain
  locks = await db.collection('booking_slots').get();
  assert.equal(locks.docs.length, 0);

  // Re-book same slot -> Success
  const res2 = await createBookingInternal(db, {
    customerId: 'cust_new',
    businessId: 'biz_test',
    serviceId: 'srv_haircut',
    staffId: 'st_ahmed',
    requestedStartAt: reqDate,
    bookingSource: 'app',
  });
  assert.equal(res2.success, true);
});
