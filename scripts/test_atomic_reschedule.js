const API_KEY = 'AIzaSyApbJ5knQAHW9wCBMeKq8Z4CrfQYWgsMCM';
const PROJECT_ID = 'easy-book-zaki';
const SIGNIN_URL = `https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=${API_KEY}`;
const AUTH_URL = `https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=${API_KEY}`;
const FIRESTORE_BASE = `https://firestore.googleapis.com/v1/projects/${PROJECT_ID}/databases/(default)/documents`;
const COMMIT_URL = `https://firestore.googleapis.com/v1/projects/${PROJECT_ID}/databases/(default)/documents:commit`;

const customerEmail1 = 'dev.customer@easybook.ae';
const customerPassword1 = 'DevCustomerPassword123!';
const customerEmail2 = 'other.customer@easybook.ae';
const customerPassword2 = 'OtherCustomerPassword123!';

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
  console.log('--- Starting Atomic Reschedule Core Validation ---');

  // Sign in Customer 1
  let res = await fetch(SIGNIN_URL, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ email: customerEmail1, password: customerPassword1, returnSecureToken: true }),
  });
  let data = await res.json();
  const token1 = data.idToken;
  const uid1 = data.localId;

  // Sign in Customer 2
  res = await fetch(SIGNIN_URL, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ email: customerEmail2, password: customerPassword2, returnSecureToken: true }),
  });
  data = await res.json();
  const token2 = data.idToken;
  const uid2 = data.localId;

  // Ensure User Profile documents exist in Firestore
  await fetch(`${FIRESTORE_BASE}/users/${uid1}`, {
    method: 'PATCH',
    headers: { 'Content-Type': 'application/json', 'Authorization': `Bearer ${token1}` },
    body: JSON.stringify({
      fields: {
        id: { stringValue: uid1 },
        email: { stringValue: customerEmail1 },
        full_name: { stringValue: 'Alex Customer' },
        role: { stringValue: 'customer' }
      }
    })
  });

  await fetch(`${FIRESTORE_BASE}/users/${uid2}`, {
    method: 'PATCH',
    headers: { 'Content-Type': 'application/json', 'Authorization': `Bearer ${token2}` },
    body: JSON.stringify({
      fields: {
        id: { stringValue: uid2 },
        email: { stringValue: customerEmail2 },
        full_name: { stringValue: 'Other Customer' },
        role: { stringValue: 'customer' }
      }
    })
  });

  const bId = 'b1';
  const stId = 'st1';
  const testDateBase = new Date();
  testDateBase.setDate(testDateBase.getDate() + 7); // Clean future date 7 days out

  // Helper to create a clean booking with all its interval locks
  async function helperCreateBooking(token, uid, hour, durationMinutes, serviceId, price, bookingId, staffIdParam = stId) {
    const sTime = new Date(testDateBase);
    sTime.setHours(hour, 0, 0, 0);
    const eTime = new Date(sTime.getTime() + (durationMinutes * 60 * 1000));
    const sMs = sTime.getTime();

    const expectedLocks = generateIntervalSlotLockIds(bId, staffIdParam, sTime, eTime);
    const primaryLockId = `${bId}_${staffIdParam}_${sMs}`;

    const writes = [];
    for (let i = 0; i < expectedLocks.length; i++) {
      const lId = expectedLocks[i];
      const curTs = sMs + (i * 15 * 60 * 1000);
      writes.push({
        update: {
          name: `projects/${PROJECT_ID}/databases/(default)/documents/booking_slots/${lId}`,
          fields: {
            slotId: { stringValue: lId },
            bookingId: { stringValue: bookingId },
            businessId: { stringValue: bId },
            staffId: { stringValue: staffIdParam },
            startDateTime: { timestampValue: new Date(curTs).toISOString() },
            startTimestamp: { integerValue: curTs.toString() },
            customerId: { stringValue: uid },
            createdAt: { timestampValue: new Date().toISOString() }
          }
        },
        currentDocument: { exists: false }
      });
    }

    writes.push({
      update: {
        name: `projects/${PROJECT_ID}/databases/(default)/documents/bookings/${bookingId}`,
        fields: {
          id: { stringValue: bookingId },
          customerId: { stringValue: uid },
          customerName: { stringValue: 'Test Customer' },
          businessId: { stringValue: bId },
          businessName: { stringValue: 'Executive Barber Lounge' },
          serviceId: { stringValue: serviceId },
          serviceName: { stringValue: `${durationMinutes}m Service` },
          servicePrice: { doubleValue: price },
          staffId: { stringValue: staffIdParam },
          staffName: { stringValue: 'Marcus Vance' },
          startDateTime: { timestampValue: sTime.toISOString() },
          endDateTime: { timestampValue: eTime.toISOString() },
          startTimestamp: { integerValue: sMs.toString() },
          status: { stringValue: 'pending' },
          slotLockId: { stringValue: primaryLockId },
          createdAt: { timestampValue: new Date().toISOString() },
          updatedAt: { timestampValue: new Date().toISOString() }
        }
      },
      currentDocument: { exists: false }
    });

    const commitRes = await fetch(COMMIT_URL, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json', 'Authorization': `Bearer ${token}` },
      body: JSON.stringify({ writes })
    });

    if (commitRes.status !== 200) {
      console.error('helperCreateBooking failed:', await commitRes.json());
      return false;
    }
    return true;
  }

  // TEST A: Basic Reschedule (10:00 -> 10:30 shifted to 11:00 -> 11:30)
  console.log('\n=== TEST A: Basic Reschedule (10:00 -> 10:30 to 11:00 -> 11:30) ===');
  const bookAId = `resched_A_${Date.now()}`;
  await helperCreateBooking(token1, uid1, 10, 30, 's1', 80.0, bookAId);

  const oldStartA = new Date(testDateBase); oldStartA.setHours(10, 0, 0, 0);
  const oldEndA = new Date(oldStartA.getTime() + 30*60*1000);
  const newStartA = new Date(testDateBase); newStartA.setHours(11, 0, 0, 0);
  const newEndA = new Date(newStartA.getTime() + 30*60*1000);

  const oldLocksA = generateIntervalSlotLockIds(bId, stId, oldStartA, oldEndA);
  const newLocksA = generateIntervalSlotLockIds(bId, stId, newStartA, newEndA);
  const primaryNewLockA = `${bId}_${stId}_${newStartA.getTime()}`;

  const reschedAWrites = [];
  for (const lId of oldLocksA) {
    reschedAWrites.push({ delete: `projects/${PROJECT_ID}/databases/(default)/documents/booking_slots/${lId}` });
  }
  for (let i = 0; i < newLocksA.length; i++) {
    const lId = newLocksA[i];
    const curTs = newStartA.getTime() + (i * 15 * 60 * 1000);
    reschedAWrites.push({
      update: {
        name: `projects/${PROJECT_ID}/databases/(default)/documents/booking_slots/${lId}`,
        fields: {
          slotId: { stringValue: lId },
          bookingId: { stringValue: bookAId },
          businessId: { stringValue: bId },
          staffId: { stringValue: stId },
          startDateTime: { timestampValue: new Date(curTs).toISOString() },
          startTimestamp: { integerValue: curTs.toString() },
          customerId: { stringValue: uid1 },
          createdAt: { timestampValue: new Date().toISOString() }
        }
      },
      currentDocument: { exists: false }
    });
  }
  reschedAWrites.push({
    update: {
      name: `projects/${PROJECT_ID}/databases/(default)/documents/bookings/${bookAId}`,
      fields: {
        startDateTime: { timestampValue: newStartA.toISOString() },
        endDateTime: { timestampValue: newEndA.toISOString() },
        startTimestamp: { integerValue: newStartA.getTime().toString() },
        slotLockId: { stringValue: primaryNewLockA },
        updatedAt: { timestampValue: new Date().toISOString() }
      }
    },
    updateMask: { fieldPaths: ['startDateTime', 'endDateTime', 'startTimestamp', 'slotLockId', 'updatedAt'] }
  });

  const commitResA = await fetch(COMMIT_URL, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json', 'Authorization': `Bearer ${token1}` },
    body: JSON.stringify({ writes: reschedAWrites })
  });

  let passA = false;
  if (commitResA.status === 200) {
    // Verify old locks deleted & new locks created
    const oldCheck = await fetch(`${FIRESTORE_BASE}/booking_slots/${oldLocksA[0]}`, { headers: { 'Authorization': `Bearer ${token1}` } });
    const newCheck = await fetch(`${FIRESTORE_BASE}/booking_slots/${newLocksA[0]}`, { headers: { 'Authorization': `Bearer ${token1}` } });
    if (oldCheck.status === 404 && newCheck.status === 200) {
      passA = true;
      console.log('[TEST A PASSED] Basic reschedule succeeded. Same booking ID preserved, old locks deleted (404), new locks created (200).');
    } else {
      console.error('[TEST A FAILED] Lock check failed:', oldCheck.status, newCheck.status);
    }
  } else {
    console.error('[TEST A FAILED] Reschedule commit failed:', await commitResA.json());
  }

  // TEST B: Partial Bucket Shift (10:00 -> 10:30 shifted to 10:15 -> 10:45)
  console.log('\n=== TEST B: Partial Bucket Shift (10:00 -> 10:30 to 10:15 -> 10:45) ===');
  const bookBId = `resched_B_${Date.now()}`;
  await helperCreateBooking(token1, uid1, 10, 30, 's1', 80.0, bookBId);

  const startB_1000 = new Date(testDateBase); startB_1000.setHours(10, 0, 0, 0);
  const startB_1015 = new Date(testDateBase); startB_1015.setHours(10, 15, 0, 0);
  const endB_1045 = new Date(testDateBase); endB_1045.setHours(10, 45, 0, 0);

  const lock_1000 = `${bId}_${stId}_${startB_1000.getTime()}`;
  const lock_1015 = `${bId}_${stId}_${startB_1015.getTime()}`;
  const lock_1030 = `${bId}_${stId}_${startB_1000.getTime() + (30*60*1000)}`;

  // Set difference: Delete 10:00 lock, Keep 10:15 lock, Create 10:30 lock
  const reschedBWrites = [
    { delete: `projects/${PROJECT_ID}/databases/(default)/documents/booking_slots/${lock_1000}` },
    {
      update: {
        name: `projects/${PROJECT_ID}/databases/(default)/documents/booking_slots/${lock_1030}`,
        fields: {
          slotId: { stringValue: lock_1030 },
          bookingId: { stringValue: bookBId },
          businessId: { stringValue: bId },
          staffId: { stringValue: stId },
          startDateTime: { timestampValue: new Date(startB_1000.getTime() + (30*60*1000)).toISOString() },
          startTimestamp: { integerValue: (startB_1000.getTime() + (30*60*1000)).toString() },
          customerId: { stringValue: uid1 },
          createdAt: { timestampValue: new Date().toISOString() }
        }
      },
      currentDocument: { exists: false }
    },
    {
      update: {
        name: `projects/${PROJECT_ID}/databases/(default)/documents/bookings/${bookBId}`,
        fields: {
          startDateTime: { timestampValue: startB_1015.toISOString() },
          endDateTime: { timestampValue: endB_1045.toISOString() },
          startTimestamp: { integerValue: startB_1015.getTime().toString() },
          slotLockId: { stringValue: lock_1015 },
          updatedAt: { timestampValue: new Date().toISOString() }
        }
      },
      updateMask: { fieldPaths: ['startDateTime', 'endDateTime', 'startTimestamp', 'slotLockId', 'updatedAt'] }
    }
  ];

  const commitResB = await fetch(COMMIT_URL, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json', 'Authorization': `Bearer ${token1}` },
    body: JSON.stringify({ writes: reschedBWrites })
  });

  let passB = false;
  if (commitResB.status === 200) {
    const check1000 = await fetch(`${FIRESTORE_BASE}/booking_slots/${lock_1000}`, { headers: { 'Authorization': `Bearer ${token1}` } });
    const check1015 = await fetch(`${FIRESTORE_BASE}/booking_slots/${lock_1015}`, { headers: { 'Authorization': `Bearer ${token1}` } });
    const check1030 = await fetch(`${FIRESTORE_BASE}/booking_slots/${lock_1030}`, { headers: { 'Authorization': `Bearer ${token1}` } });
    if (check1000.status === 404 && check1015.status === 200 && check1030.status === 200) {
      passB = true;
      console.log('[TEST B PASSED] Partial bucket shift succeeded. 10:00 deleted (404), 10:15 kept (200), 10:30 created (200).');
    }
  } else {
    console.error('[TEST B FAILED] Partial shift failed:', await commitResB.json());
  }

  // TEST C: Occupied Destination Rejection
  console.log('\n=== TEST C: Occupied Destination Rejection ===');
  const bookC1Id = `resched_C1_${Date.now()}`;
  const bookC2Id = `resched_C2_${Date.now()}`;
  await helperCreateBooking(token1, uid1, 14, 30, 's1', 80.0, bookC1Id);
  await helperCreateBooking(token2, uid2, 15, 30, 's1', 80.0, bookC2Id);

  const startC1_1400 = new Date(testDateBase); startC1_1400.setHours(14, 0, 0, 0);
  const startC1_1500 = new Date(testDateBase); startC1_1500.setHours(15, 0, 0, 0);
  const endC1_1530 = new Date(testDateBase); endC1_1530.setHours(15, 30, 0, 0);

  const lock_1400 = `${bId}_${stId}_${startC1_1400.getTime()}`;
  const lock_1500 = `${bId}_${stId}_${startC1_1500.getTime()}`;

  // Customer 1 tries to reschedule to 15:00 (which Customer 2 owns with currentDocument: { exists: false })
  const reschedCWrites = [
    { delete: `projects/${PROJECT_ID}/databases/(default)/documents/booking_slots/${lock_1400}` },
    {
      update: {
        name: `projects/${PROJECT_ID}/databases/(default)/documents/booking_slots/${lock_1500}`,
        fields: {
          slotId: { stringValue: lock_1500 },
          bookingId: { stringValue: bookC1Id },
          businessId: { stringValue: bId },
          staffId: { stringValue: stId },
          startDateTime: { timestampValue: startC1_1500.toISOString() },
          startTimestamp: { integerValue: startC1_1500.getTime().toString() },
          customerId: { stringValue: uid1 },
          createdAt: { timestampValue: new Date().toISOString() }
        }
      },
      currentDocument: { exists: false }
    },
    {
      update: {
        name: `projects/${PROJECT_ID}/databases/(default)/documents/bookings/${bookC1Id}`,
        fields: {
          startDateTime: { timestampValue: startC1_1500.toISOString() },
          endDateTime: { timestampValue: endC1_1530.toISOString() },
          startTimestamp: { integerValue: startC1_1500.getTime().toString() },
          slotLockId: { stringValue: lock_1500 },
          updatedAt: { timestampValue: new Date().toISOString() }
        }
      },
      updateMask: { fieldPaths: ['startDateTime', 'endDateTime', 'startTimestamp', 'slotLockId', 'updatedAt'] }
    }
  ];

  const commitResC = await fetch(COMMIT_URL, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json', 'Authorization': `Bearer ${token1}` },
    body: JSON.stringify({ writes: reschedCWrites })
  });

  let passC = false;
  if (commitResC.status !== 200) {
    const origCheck = await fetch(`${FIRESTORE_BASE}/booking_slots/${lock_1400}`, { headers: { 'Authorization': `Bearer ${token1}` } });
    if (origCheck.status === 200) {
      passC = true;
      console.log('[TEST C PASSED] Occupied destination reschedule REJECTED by transaction. Original booking & lock intact (200).');
    }
  } else {
    console.error('[TEST C FAILED] Occupied destination reschedule was allowed!');
  }

  // TEST K: Unauthorized Reschedule
  console.log('\n=== TEST K: Unauthorized Reschedule Attempt ===');
  const reschedKWrites = [
    {
      update: {
        name: `projects/${PROJECT_ID}/databases/(default)/documents/bookings/${bookAId}`,
        fields: {
          startDateTime: { timestampValue: newStartA.toISOString() },
          endDateTime: { timestampValue: newEndA.toISOString() },
          startTimestamp: { integerValue: newStartA.getTime().toString() },
          slotLockId: { stringValue: primaryNewLockA },
          updatedAt: { timestampValue: new Date().toISOString() }
        }
      },
      updateMask: { fieldPaths: ['startDateTime', 'endDateTime', 'startTimestamp', 'slotLockId', 'updatedAt'] }
    }
  ];

  const commitResK = await fetch(COMMIT_URL, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json', 'Authorization': `Bearer ${token2}` }, // Customer 2 token!
    body: JSON.stringify({ writes: reschedKWrites })
  });

  let passK = false;
  if (commitResK.status !== 200) {
    passK = true;
    console.log('[TEST K PASSED] Unauthorized reschedule attempt REJECTED by Firestore Rules.');
  } else {
    console.error('[TEST K FAILED] Unauthorized reschedule was allowed!');
  }

  console.log('\n=== ATOMIC RESCHEDULE CORE INTEGRITY SUMMARY ===');
  console.log('Test A (Basic Reschedule & Lock Transfer):', passA ? 'PASSED' : 'FAILED');
  console.log('Test B (Partial Bucket Shift):', passB ? 'PASSED' : 'FAILED');
  console.log('Test C (Occupied Destination Rejection):', passC ? 'PASSED' : 'FAILED');
  console.log('Test K (Unauthorized Reschedule Rejection):', passK ? 'PASSED' : 'FAILED');

  if (passA && passB && passC && passK) {
    console.log('ATOMIC RESCHEDULE CORE PASSED');
  } else {
    console.log('ATOMIC RESCHEDULE CORE NOT READY');
    process.exit(1);
  }
}

run().catch(err => console.error('Atomic Reschedule test error:', err));
