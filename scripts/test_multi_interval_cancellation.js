const API_KEY = 'AIzaSyApbJ5knQAHW9wCBMeKq8Z4CrfQYWgsMCM';
const PROJECT_ID = 'easy-book-zaki';
const SIGNIN_URL = `https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=${API_KEY}`;
const FIRESTORE_BASE = `https://firestore.googleapis.com/v1/projects/${PROJECT_ID}/databases/(default)/documents`;
const COMMIT_URL = `https://firestore.googleapis.com/v1/projects/${PROJECT_ID}/databases/(default)/documents:commit`;

const customerEmail = 'dev.customer@easybook.ae';
const customerPassword = 'DevCustomerPassword123!';

function generateIntervalSlotLockIds(businessId, staffId, start, end) {
  const ids = [];
  const bucketMs = 15 * 60 * 1000;
  const startMs = start.getTime();
  const endMs = end.getTime();
  for (let t = startMs; t < endMs; t += bucketMs) {
    ids.push(`${businessId}_${staffId}_${t}`);
  }
  return ids;
}

async function run() {
  console.log('--- Starting Multi-Interval Cancellation Integrity Validation ---');

  // Sign in Customer
  let res = await fetch(SIGNIN_URL, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ email: customerEmail, password: customerPassword, returnSecureToken: true }),
  });
  let data = await res.json();
  let idToken = data.idToken;
  let uid = data.localId;

  const bId = 'b1';
  const stId = 'st1';
  const testDateBase = new Date();
  testDateBase.setDate(testDateBase.getDate() + 6);

  async function testBookingAndCancellation(durationMinutes, hour, serviceId, servicePrice, testName) {
    console.log(`\n=== Testing ${testName} (${durationMinutes} mins) ===`);
    const sTime = new Date(testDateBase);
    sTime.setHours(hour, 0, 0, 0);
    const eTime = new Date(sTime.getTime() + (durationMinutes * 60 * 1000));
    const sMs = sTime.getTime();

    const expectedLocks = generateIntervalSlotLockIds(bId, stId, sTime, eTime);
    console.log(`Expected lock count: ${expectedLocks.length}`);
    console.log(`Expected locks: ${JSON.stringify(expectedLocks)}`);

    const bookingId = `book_multi_${durationMinutes}_${Date.now()}`;

    const lockId = `${bId}_${stId}_${sMs}`;

    // 1. Create Primary Slot Lock & Booking Document
    const writes = [
      {
        update: {
          name: `projects/${PROJECT_ID}/databases/(default)/documents/booking_slots/${lockId}`,
          fields: {
            slotId: { stringValue: lockId },
            bookingId: { stringValue: bookingId },
            businessId: { stringValue: bId },
            staffId: { stringValue: stId },
            startDateTime: { timestampValue: sTime.toISOString() },
            startTimestamp: { integerValue: sMs.toString() },
            customerId: { stringValue: uid },
            createdAt: { timestampValue: new Date().toISOString() }
          }
        },
        currentDocument: { exists: false }
      },
      {
        update: {
          name: `projects/${PROJECT_ID}/databases/(default)/documents/bookings/${bookingId}`,
          fields: {
            id: { stringValue: bookingId },
            customerId: { stringValue: uid },
            customerName: { stringValue: 'Alex Customer' },
            businessId: { stringValue: bId },
            businessName: { stringValue: 'Executive Barber Lounge' },
            serviceId: { stringValue: serviceId },
            serviceName: { stringValue: `${durationMinutes}m Service` },
            servicePrice: { doubleValue: servicePrice },
            staffId: { stringValue: stId },
            staffName: { stringValue: 'Marcus Vance' },
            startDateTime: { timestampValue: sTime.toISOString() },
            endDateTime: { timestampValue: eTime.toISOString() },
            startTimestamp: { integerValue: sMs.toString() },
            status: { stringValue: 'pending' },
            slotLockId: { stringValue: lockId },
            createdAt: { timestampValue: new Date().toISOString() },
            updatedAt: { timestampValue: new Date().toISOString() }
          }
        },
        currentDocument: { exists: false }
      }
    ];

    const commitRes = await fetch(COMMIT_URL, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json', 'Authorization': `Bearer ${idToken}` },
      body: JSON.stringify({ writes })
    });

    if (commitRes.status !== 200) {
      console.error(`Failed to create ${durationMinutes}m booking:`, await commitRes.json());
      return false;
    }
    // 2. Verify ALL N interval lock documents exist physically in Firestore before cancellation
    let existCountBefore = 0;
    for (const lId of expectedLocks) {
      const lockCheck = await fetch(`${FIRESTORE_BASE}/booking_slots/${lId}`, {
        headers: { 'Authorization': `Bearer ${idToken}` }
      });
      if (lockCheck.status === 200) existCountBefore++;
    }
    console.log(`Physical lock count BEFORE cancellation: ${existCountBefore}/${expectedLocks.length}`);

    // 3. Atomically Cancel Booking & Delete ALL N Interval Locks
    const cancelWrites = [];
    for (const lId of expectedLocks) {
      cancelWrites.push({
        delete: `projects/${PROJECT_ID}/databases/(default)/documents/booking_slots/${lId}`
      });
    }
    cancelWrites.push({
      update: {
        name: `projects/${PROJECT_ID}/databases/(default)/documents/bookings/${bookingId}`,
        fields: {
          status: { stringValue: 'cancelled' },
          updatedAt: { timestampValue: new Date().toISOString() }
        }
      },
      updateMask: { fieldPaths: ['status', 'updatedAt'] }
    });

    const cancelRes = await fetch(COMMIT_URL, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json', 'Authorization': `Bearer ${idToken}` },
      body: JSON.stringify({ writes: cancelWrites })
    });

    if (cancelRes.status !== 200) {
      console.error(`Failed to cancel ${durationMinutes}m booking:`, await cancelRes.json());
      return false;
    }
    console.log(`[CANCEL SUCCESS] Atomic cancellation of ${bookingId} committed.`);

    // 4. Verify ZERO interval lock documents remain in Firestore after cancellation
    let existCountAfter = 0;
    for (const lId of expectedLocks) {
      const lockCheck = await fetch(`${FIRESTORE_BASE}/booking_slots/${lId}`, {
        headers: { 'Authorization': `Bearer ${idToken}` }
      });
      if (lockCheck.status === 200) existCountAfter++;
    }
    console.log(`Physical lock count AFTER cancellation (0 expected): ${existCountAfter}`);

    // 5. Test Re-booking the freed interval for the full duration
    const rebookId = `rebook_${durationMinutes}_${Date.now()}`;
    const rebookWrites = [];
    for (let i = 0; i < expectedLocks.length; i++) {
      const lId = expectedLocks[i];
      const curTs = sMs + (i * 15 * 60 * 1000);
      rebookWrites.push({
        update: {
          name: `projects/${PROJECT_ID}/databases/(default)/documents/booking_slots/${lId}`,
          fields: {
            slotId: { stringValue: lId },
            bookingId: { stringValue: rebookId },
            businessId: { stringValue: bId },
            staffId: { stringValue: stId },
            startDateTime: { timestampValue: new Date(curTs).toISOString() },
            startTimestamp: { integerValue: curTs.toString() },
            customerId: { stringValue: uid },
            createdAt: { timestampValue: new Date().toISOString() }
          }
        },
        currentDocument: { exists: false }
      });
    }

    rebookWrites.push({
      update: {
        name: `projects/${PROJECT_ID}/databases/(default)/documents/bookings/${rebookId}`,
        fields: {
          id: { stringValue: rebookId },
          customerId: { stringValue: uid },
          customerName: { stringValue: 'Alex Customer' },
          businessId: { stringValue: bId },
          businessName: { stringValue: 'Executive Barber Lounge' },
          serviceId: { stringValue: serviceId },
          serviceName: { stringValue: `${durationMinutes}m Service` },
          servicePrice: { doubleValue: servicePrice },
          staffId: { stringValue: stId },
          staffName: { stringValue: 'Marcus Vance' },
          startDateTime: { timestampValue: sTime.toISOString() },
          endDateTime: { timestampValue: eTime.toISOString() },
          startTimestamp: { integerValue: sMs.toString() },
          status: { stringValue: 'pending' },
          slotLockId: { stringValue: lockId },
          createdAt: { timestampValue: new Date().toISOString() },
          updatedAt: { timestampValue: new Date().toISOString() }
        }
      },
      currentDocument: { exists: false }
    });

    const rebookRes = await fetch(COMMIT_URL, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json', 'Authorization': `Bearer ${idToken}` },
      body: JSON.stringify({ writes: rebookWrites })
    });

    const passed = existCountBefore === expectedLocks.length && cancelRes.status === 200 && existCountAfter === 0 && rebookRes.status === 200;
    console.log(`RESULT FOR ${testName}: ${passed ? 'PASSED (ALL ' + expectedLocks.length + ' LOCKS CREATED, DELETED & REBOOKED)' : 'FAILED'}`);
    return passed;
  }

  // Execute Tests
  const res30 = await testBookingAndCancellation(30, 10, 's1', 80.0, '30-Minute Booking (2 Locks)');
  const res45 = await testBookingAndCancellation(45, 11, 's2', 120.0, '45-Minute Booking (3 Locks)');
  const res60 = await testBookingAndCancellation(60, 13, 's3', 180.0, '60-Minute Booking (4 Locks)');

  console.log('\n=== MULTI-INTERVAL CANCELLATION INTEGRITY SUMMARY ===');
  console.log('30-Minute Cancellation:', res30 ? 'PASSED' : 'FAILED');
  console.log('45-Minute Cancellation:', res45 ? 'PASSED' : 'FAILED');
  console.log('60-Minute Cancellation:', res60 ? 'PASSED' : 'FAILED');

  if (res30 && res45 && res60) {
    console.log('MULTI-INTERVAL CANCELLATION VERIFIED — READY FOR RESCHEDULE');
  } else {
    console.log('CANCELLATION INCOMPLETE — STALE INTERVAL LOCK RISK');
    process.exit(1);
  }
}

run().catch(err => console.error('Error in multi-interval cancellation test:', err));
