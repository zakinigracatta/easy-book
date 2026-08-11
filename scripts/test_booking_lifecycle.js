const API_KEY = 'AIzaSyApbJ5knQAHW9wCBMeKq8Z4CrfQYWgsMCM';
const PROJECT_ID = 'easy-book-zaki';
const SIGNIN_URL = `https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=${API_KEY}`;
const AUTH_URL = `https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=${API_KEY}`;
const FIRESTORE_BASE = `https://firestore.googleapis.com/v1/projects/${PROJECT_ID}/databases/(default)/documents`;
const COMMIT_URL = `https://firestore.googleapis.com/v1/projects/${PROJECT_ID}/databases/(default)/documents:commit`;

const customerEmail = 'dev.customer@easybook.ae';
const customerPassword = 'DevCustomerPassword123!';
const ownerEmail = 'dev.owner.b1@executivebarber.com';
const ownerPassword = 'DevOwnerPassword123!';

function generateIntervalSlotLockIds(businessId, staffId, start, end) {
  const ids = [];
  const bucketMs = 15 * 60 * 1000;
  const baseMs = Math.floor(Date.now() / 900000) * 900000 + 86400000 * 5;
  const startMs = start.getTime();
  const endMs = end.getTime();
  for (let t = startMs; t < endMs; t += bucketMs) {
    ids.push(`${businessId}_${staffId}_${t}`);
  }
  return ids;
}

async function run() {
  console.log('--- Starting Production Booking Status Lifecycle Validation ---');

  // 1. Sign in Customer
  let res = await fetch(SIGNIN_URL, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ email: customerEmail, password: customerPassword, returnSecureToken: true }),
  });
  let data = await res.json();
  const custToken = data.idToken;
  const custUid = data.localId;

  // 2. Sign in / Register Business Owner
  res = await fetch(SIGNIN_URL, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ email: ownerEmail, password: ownerPassword, returnSecureToken: true }),
  });
  data = await res.json();
  let ownerToken = '';
  let ownerUid = '';
  if (data.idToken) {
    ownerToken = data.idToken;
    ownerUid = data.localId;
  } else {
    res = await fetch(AUTH_URL, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ email: ownerEmail, password: ownerPassword, returnSecureToken: true }),
    });
    data = await res.json();
    ownerToken = data.idToken;
    ownerUid = data.localId;
  }

  // Fetch current business b1 document from Firestore
  const bizCheckRes = await fetch(`${FIRESTORE_BASE}/businesses/b1`, {
    headers: { 'Authorization': `Bearer ${ownerToken}` }
  });
  const bizDoc = await bizCheckRes.json();
  console.log('Business b1 doc in Firestore:', JSON.stringify(bizDoc.fields));

  // Fetch current owner user document from Firestore
  const userCheckRes = await fetch(`${FIRESTORE_BASE}/users/${ownerUid}`, {
    headers: { 'Authorization': `Bearer ${ownerToken}` }
  });
  const userDoc = await userCheckRes.json();
  console.log('Owner user doc in Firestore:', JSON.stringify(userDoc.fields));

  // Fetch s1 and st1
  const s1Res = await fetch(`${FIRESTORE_BASE}/businesses/b1/services/s1`, { headers: { 'Authorization': `Bearer ${ownerToken}` } });
  const st1Res = await fetch(`${FIRESTORE_BASE}/businesses/b1/staff/st1`, { headers: { 'Authorization': `Bearer ${ownerToken}` } });
  console.log('s1 doc:', JSON.stringify(await s1Res.json()));
  console.log('st1 doc:', JSON.stringify(await st1Res.json()));

  const bId = 'b1';
  const stId = 'st1';
  const dayOffset = 10 + (Math.floor(Date.now() / 1000) % 500);
  const testDateBase = new Date(Date.now() + dayOffset * 86400000);

  async function createTestBooking(bookingId, hour = 10, durationMinutes = 30) {
    const sTime = new Date(testDateBase);
    sTime.setHours(hour, 0, 0, 0);
    const eTime = new Date(sTime.getTime() + (durationMinutes * 60 * 1000));
    const sMs = sTime.getTime();

    const expectedLocks = generateIntervalSlotLockIds(bId, stId, sTime, eTime);
    const primaryLockId = `${bId}_${stId}_${sMs}`;

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
            staffId: { stringValue: stId },
            startDateTime: { timestampValue: new Date(curTs).toISOString() },
            startTimestamp: { integerValue: curTs.toString() },
            customerId: { stringValue: custUid },
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
          customerId: { stringValue: custUid },
          customerName: { stringValue: 'Alex Customer' },
          businessId: { stringValue: bId },
          businessName: { stringValue: 'Executive Barber Lounge' },
          serviceId: { stringValue: 's1' },
          serviceName: { stringValue: 'Classic Haircut' },
          servicePrice: { doubleValue: 80.0 },
          staffId: { stringValue: stId },
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

    const res = await fetch(COMMIT_URL, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json', 'Authorization': `Bearer ${custToken}` },
      body: JSON.stringify({ writes })
    });
    console.log(`createTestBooking ${bookingId} status: ${res.status}`);
    if (res.status !== 200) {
      console.log('createTestBooking FAIL BODY:', JSON.stringify(await res.json()));
    }

    return res.status === 200;
  }

  // TEST A: Customer Attempts Confirm (pending -> confirmed)
  console.log('\n=== TEST A: Customer Attempts Self-Confirm ===');
  const bookAId = `lifecycle_A_${Date.now()}`;
  await createTestBooking(bookAId, 10);

  const custConfirmWrites = [{
    update: {
      name: `projects/${PROJECT_ID}/databases/(default)/documents/bookings/${bookAId}`,
      fields: { status: { stringValue: 'confirmed' }, updatedAt: { timestampValue: new Date().toISOString() } }
    },
    updateMask: { fieldPaths: ['status', 'updatedAt'] }
  }];

  const custConfirmRes = await fetch(COMMIT_URL, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json', 'Authorization': `Bearer ${custToken}` },
    body: JSON.stringify({ writes: custConfirmWrites })
  });

  const passA = custConfirmRes.status !== 200;
  console.log(`TEST A RESULT: ${passA ? 'PASSED (Customer confirm REJECTED)' : 'FAILED'}`);

  // TEST B: Customer Attempts Self-Complete
  console.log('\n=== TEST B: Customer Attempts Self-Complete ===');
  const custCompleteWrites = [{
    update: {
      name: `projects/${PROJECT_ID}/databases/(default)/documents/bookings/${bookAId}`,
      fields: { status: { stringValue: 'completed' }, updatedAt: { timestampValue: new Date().toISOString() } }
    },
    updateMask: { fieldPaths: ['status', 'updatedAt'] }
  }];

  const custCompleteRes = await fetch(COMMIT_URL, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json', 'Authorization': `Bearer ${custToken}` },
    body: JSON.stringify({ writes: custCompleteWrites })
  });

  const passB = custCompleteRes.status !== 200;
  console.log(`TEST B RESULT: ${passB ? 'PASSED (Customer complete REJECTED)' : 'FAILED'}`);

  // TEST D: Authorized Business Owner Confirms (pending -> confirmed)
  console.log('\n=== TEST D: Authorized Business Owner Confirms (pending -> confirmed) ===');
  const ownerConfirmWrites = [{
    update: {
      name: `projects/${PROJECT_ID}/databases/(default)/documents/bookings/${bookAId}`,
      fields: { status: { stringValue: 'confirmed' }, updatedAt: { timestampValue: new Date().toISOString() } }
    },
    updateMask: { fieldPaths: ['status', 'updatedAt'] }
  }];

  const ownerConfirmRes = await fetch(COMMIT_URL, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json', 'Authorization': `Bearer ${ownerToken}` },
    body: JSON.stringify({ writes: ownerConfirmWrites })
  });

  const passD = ownerConfirmRes.status === 200;
  if (!passD) {
    console.log('TEST D FAIL BODY:', JSON.stringify(await ownerConfirmRes.json()));
  }
  console.log(`TEST D RESULT: ${passD ? 'PASSED (Business Owner confirm SUCCEEDED)' : 'FAILED'}`);

  // TEST E: Authorized Business Owner Completes (confirmed -> completed)
  console.log('\n=== TEST E: Authorized Business Owner Completes (confirmed -> completed) ===');
  const ownerCompleteWrites = [{
    update: {
      name: `projects/${PROJECT_ID}/databases/(default)/documents/bookings/${bookAId}`,
      fields: { status: { stringValue: 'completed' }, updatedAt: { timestampValue: new Date().toISOString() } }
    },
    updateMask: { fieldPaths: ['status', 'updatedAt'] }
  }];

  const ownerCompleteRes = await fetch(COMMIT_URL, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json', 'Authorization': `Bearer ${ownerToken}` },
    body: JSON.stringify({ writes: ownerCompleteWrites })
  });

  const passE = ownerCompleteRes.status === 200;
  console.log(`TEST E RESULT: ${passE ? 'PASSED (Business Owner complete SUCCEEDED)' : 'FAILED'}`);

  // TEST F: Invalid pending -> completed Transition
  console.log('\n=== TEST F: Invalid Direct pending -> completed Transition ===');
  const bookFId = `lifecycle_F_${Date.now()}`;
  await createTestBooking(bookFId, 11);

  const ownerDirectCompleteWrites = [{
    update: {
      name: `projects/${PROJECT_ID}/databases/(default)/documents/bookings/${bookFId}`,
      fields: { status: { stringValue: 'completed' }, updatedAt: { timestampValue: new Date().toISOString() } }
    },
    updateMask: { fieldPaths: ['status', 'updatedAt'] }
  }];

  const ownerDirectCompleteRes = await fetch(COMMIT_URL, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json', 'Authorization': `Bearer ${ownerToken}` },
    body: JSON.stringify({ writes: ownerDirectCompleteWrites })
  });

  const passF = ownerDirectCompleteRes.status !== 200;
  console.log(`TEST F RESULT: ${passF ? 'PASSED (Direct pending->completed REJECTED)' : 'FAILED'}`);

  // TEST H: Invalid completed -> cancelled Transition
  console.log('\n=== TEST H: Invalid completed -> cancelled Transition ===');
  const ownerCancelCompletedWrites = [{
    update: {
      name: `projects/${PROJECT_ID}/databases/(default)/documents/bookings/${bookAId}`, // bookAId is completed
      fields: { status: { stringValue: 'cancelled' }, updatedAt: { timestampValue: new Date().toISOString() } }
    },
    updateMask: { fieldPaths: ['status', 'updatedAt'] }
  }];

  const ownerCancelCompletedRes = await fetch(COMMIT_URL, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json', 'Authorization': `Bearer ${ownerToken}` },
    body: JSON.stringify({ writes: ownerCancelCompletedWrites })
  });

  const passH = ownerCancelCompletedRes.status !== 200;
  console.log(`TEST H RESULT: ${passH ? 'PASSED (completed->cancelled REJECTED)' : 'FAILED'}`);

  // TEST J: Field Tampering During Status Update
  console.log('\n=== TEST J: Field Tampering During Status Update ===');
  const bookJId = `lifecycle_J_${Date.now()}`;
  await createTestBooking(bookJId, 12);

  const tamperWrites = [{
    update: {
      name: `projects/${PROJECT_ID}/databases/(default)/documents/bookings/${bookJId}`,
      fields: { status: { stringValue: 'confirmed' }, servicePrice: { doubleValue: 0.0 }, updatedAt: { timestampValue: new Date().toISOString() } }
    },
    updateMask: { fieldPaths: ['status', 'servicePrice', 'updatedAt'] }
  }];

  const tamperRes = await fetch(COMMIT_URL, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json', 'Authorization': `Bearer ${ownerToken}` },
    body: JSON.stringify({ writes: tamperWrites })
  });

  const passJ = tamperRes.status !== 200;
  console.log(`TEST J RESULT: ${passJ ? 'PASSED (Field tampering REJECTED)' : 'FAILED'}`);

  console.log('\n=== BOOKING STATUS LIFECYCLE SUMMARY ===');
  console.log('Test A (Customer Confirm Rejection):', passA ? 'PASSED' : 'FAILED');
  console.log('Test B (Customer Complete Rejection):', passB ? 'PASSED' : 'FAILED');
  console.log('Test D (Owner Confirm):', passD ? 'PASSED' : 'FAILED');
  console.log('Test E (Owner Complete):', passE ? 'PASSED' : 'FAILED');
  console.log('Test F (Direct pending->completed Rejection):', passF ? 'PASSED' : 'FAILED');
  console.log('Test H (completed->cancelled Rejection):', passH ? 'PASSED' : 'FAILED');
  console.log('Test J (Field Tampering Rejection):', passJ ? 'PASSED' : 'FAILED');

  if (passA && passB && passD && passE && passF && passH && passJ) {
    console.log('BOOKING STATUS LIFECYCLE PASSED');
  } else {
    console.log('BOOKING STATUS LIFECYCLE NOT READY');
    process.exit(1);
  }
}

run().catch(err => console.error('Lifecycle test error:', err));
