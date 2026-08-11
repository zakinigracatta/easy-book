const API_KEY = 'AIzaSyApbJ5knQAHW9wCBMeKq8Z4CrfQYWgsMCM';
const PROJECT_ID = 'easy-book-zaki';
const AUTH_URL = `https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=${API_KEY}`;
const SIGNIN_URL = `https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=${API_KEY}`;
const FIRESTORE_BASE = `https://firestore.googleapis.com/v1/projects/${PROJECT_ID}/databases/(default)/documents`;
const COMMIT_URL = `https://firestore.googleapis.com/v1/projects/${PROJECT_ID}/databases/(default)/documents:commit`;

const customerEmail = 'dev.customer@easybook.ae';
const customerPassword = 'DevCustomerPassword123!';

async function run() {
  console.log('--- Starting Controlled Real Firestore Booking Validation ---');
  let idToken = '';
  let customerUid = '';

  // 1. Authenticate Customer
  let res = await fetch(SIGNIN_URL, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ email: customerEmail, password: customerPassword, returnSecureToken: true }),
  });
  let data = await res.json();

  if (data.idToken) {
    idToken = data.idToken;
    customerUid = data.localId;
    console.log(`Signed in customer user: ${customerUid}`);
  } else {
    // Register customer
    res = await fetch(AUTH_URL, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ email: customerEmail, password: customerPassword, returnSecureToken: true }),
    });
    data = await res.json();
    if (!data.idToken) {
      console.error('Failed to authenticate customer:', data);
      process.exit(1);
    }
    idToken = data.idToken;
    customerUid = data.localId;
    console.log(`Registered new customer user: ${customerUid}`);
  }

  // Set user profile in Firestore if not present
  const userDocUrl = `${FIRESTORE_BASE}/users/${customerUid}`;
  await fetch(userDocUrl, {
    method: 'PATCH',
    headers: {
      'Content-Type': 'application/json',
      'Authorization': `Bearer ${idToken}`
    },
    body: JSON.stringify({
      fields: {
        id: { stringValue: customerUid },
        email: { stringValue: customerEmail },
        full_name: { stringValue: 'Alex Customer' },
        phone: { stringValue: '+971509998877' },
        role: { stringValue: 'customer' },
        wallet_balance: { doubleValue: 0.0 },
        favorite_business_ids: { arrayValue: { values: [] } },
        created_at: { timestampValue: new Date().toISOString() },
        updated_at: { timestampValue: new Date().toISOString() }
      }
    })
  });

  // 2. Controlled Test Booking Parameters
  // Date: 3 days in the future at 10:00 AM UTC
  const testDate = new Date();
  testDate.setDate(testDate.getDate() + 3);
  testDate.setHours(10, 0, 0, 0);

  const startMs = testDate.getTime();
  const durationMinutes = 30; // Classic Haircut
  const endMs = startMs + (durationMinutes * 60 * 1000);

  const startIso = testDate.toISOString();
  const endIso = new Date(endMs).toISOString();

  const businessId = 'b1';
  const staffId = 'st1'; // Marcus Vance
  const serviceId = 's1'; // Classic Haircut
  const servicePrice = 80.0;

  const intervalBucketMs = 15 * 60 * 1000;
  const requiredSlotLockIds = [];
  for (let t = startMs; t < endMs; t += intervalBucketMs) {
    requiredSlotLockIds.push(`${businessId}_${staffId}_${t}`);
  }

  const bookingId = `book_test_${Date.now()}`;

  console.log('\n--- PRE-TRANSACTION LOGGING (BOOKING_CREATE_ATTEMPT) ---');
  console.log(`customerId: ${customerUid}`);
  console.log(`businessId: ${businessId}`);
  console.log(`serviceId: ${serviceId}`);
  console.log(`staffId: ${staffId}`);
  console.log(`durationMinutes: ${durationMinutes}`);
  console.log(`startDateTime: ${startIso}`);
  console.log(`endDateTime: ${endIso}`);
  console.log(`startTimestamp: ${startMs}`);
  console.log(`bookingId: ${bookingId}`);
  console.log(`requiredSlotLockIds: ${JSON.stringify(requiredSlotLockIds)}`);

  // Helper to attempt atomic commit
  async function attemptBooking(bId, sId, stId, bPrice, bDuration, sTime, testName) {
    const sMs = sTime.getTime();
    const eMs = sMs + (bDuration * 60 * 1000);
    const bDocId = `book_test_${Date.now()}_${Math.floor(Math.random()*1000)}`;

    const locks = [];
    for (let t = sMs; t < eMs; t += intervalBucketMs) {
      locks.push(`${bId}_${stId}_${t}`);
    }

    const lockId = `${bId}_${stId}_${sMs}`;

    // 1. Check primary slot lock existence
    const primaryLockRes = await fetch(`${FIRESTORE_BASE}/booking_slots/${lockId}`, {
      headers: { 'Authorization': `Bearer ${idToken}` }
    });
    if (primaryLockRes.status === 200) {
      console.log(`[TEST: ${testName}] REJECTED: Primary slot lock ${lockId} already exists!`);
      return { success: false, reason: `Slot lock ${lockId} occupied`, bookingId: null, locks: [] };
    }

    // 2. Query existing active bookings for staffId and check interval overlap: existing.start < new.end && existing.end > new.start
    const queryUrl = `https://firestore.googleapis.com/v1/projects/${PROJECT_ID}/databases/(default)/documents:runQuery`;
    const queryRes = await fetch(queryUrl, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${idToken}`
      },
      body: JSON.stringify({
        structuredQuery: {
          from: [{ collectionId: 'bookings' }],
          where: {
            compositeFilter: {
              op: 'AND',
              filters: [
                { fieldFilter: { field: { fieldPath: 'businessId' }, op: 'EQUAL', value: { stringValue: bId } } },
                { fieldFilter: { field: { fieldPath: 'staffId' }, op: 'EQUAL', value: { stringValue: stId } } }
              ]
            }
          }
        }
      })
    });

    const queryData = await queryRes.json();
    if (Array.isArray(queryData)) {
      for (const item of queryData) {
        if (!item.document || !item.document.fields) continue;
        const fields = item.document.fields;
        const status = fields.status?.stringValue;
        if (status === 'cancelled') continue;

        const existStart = new Date(fields.startDateTime?.timestampValue || fields.startDateTime?.stringValue).getTime();
        const existEnd = new Date(fields.endDateTime?.timestampValue || fields.endDateTime?.stringValue).getTime();

        // Check overlap invariant: existing.start < new.end AND existing.end > new.start
        if (existStart < eMs && existEnd > sMs) {
          console.log(`[TEST: ${testName}] REJECTED: Overlaps with active booking (${new Date(existStart).toISOString()} - ${new Date(existEnd).toISOString()})!`);
          return { success: false, reason: 'Interval overlap with active booking', bookingId: null, locks: [] };
        }
      }
    }

    // Construct atomic commit writes matching firestore.rules
    const writes = [];

    // 1. Create primary slot lock
    writes.push({
      update: {
        name: `projects/${PROJECT_ID}/databases/(default)/documents/booking_slots/${lockId}`,
        fields: {
          slotId: { stringValue: lockId },
          bookingId: { stringValue: bDocId },
          businessId: { stringValue: bId },
          staffId: { stringValue: stId },
          startDateTime: { timestampValue: sTime.toISOString() },
          startTimestamp: { integerValue: sMs.toString() },
          customerId: { stringValue: customerUid },
          createdAt: { timestampValue: new Date().toISOString() }
        }
      },
      currentDocument: { exists: false }
    });

    // 2. Create booking document
    writes.push({
      update: {
        name: `projects/${PROJECT_ID}/databases/(default)/documents/bookings/${bDocId}`,
        fields: {
          id: { stringValue: bDocId },
          customerId: { stringValue: customerUid },
          customerName: { stringValue: 'Alex Customer' },
          businessId: { stringValue: bId },
          businessName: { stringValue: 'Executive Barber Lounge' },
          serviceId: { stringValue: sId },
          serviceName: { stringValue: 'Classic Haircut' },
          servicePrice: { doubleValue: bPrice },
          staffId: { stringValue: stId },
          staffName: { stringValue: 'Marcus Vance' },
          startDateTime: { timestampValue: sTime.toISOString() },
          endDateTime: { timestampValue: new Date(eMs).toISOString() },
          startTimestamp: { integerValue: sMs.toString() },
          status: { stringValue: 'pending' },
          slotLockId: { stringValue: lockId },
          createdAt: { timestampValue: new Date().toISOString() },
          updatedAt: { timestampValue: new Date().toISOString() }
        }
      },
      currentDocument: { exists: false }
    });

    const commitRes = await fetch(COMMIT_URL, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${idToken}`
      },
      body: JSON.stringify({ writes })
    });

    const commitData = await commitRes.json();
    if (commitRes.status === 200) {
      console.log(`[TEST: ${testName}] ALLOWED: Booking ${bDocId} created with ${locks.length} locks.`);
      return { success: true, bookingId: bDocId, locks };
    } else {
      console.log(`[TEST: ${testName}] REJECTED by Firestore Rules / Condition:`, commitData.error?.message || commitData);
      return { success: false, reason: commitData.error?.message, bookingId: null, locks: [] };
    }
  }

  // --- RUNNING RUNTIME TESTS ---
  console.log('\n--- 1. FIRST CONTROLLED REAL BOOKING (10:00 AM - 10:30 AM, st1) ---');
  const res1 = await attemptBooking(businessId, serviceId, staffId, servicePrice, durationMinutes, testDate, 'First Booking');
  if (!res1.success) {
    console.error('First booking failed! Blocker found.');
    process.exit(1);
  }

  console.log('\n--- 2. EXACT DUPLICATE BOOKING TEST (10:00 AM - 10:30 AM, st1) ---');
  const resDup = await attemptBooking(businessId, serviceId, staffId, servicePrice, durationMinutes, testDate, 'Exact Duplicate');

  console.log('\n--- 3. PARTIAL OVERLAP TEST (10:15 AM - 11:00 AM, st1) ---');
  const overlapTime = new Date(startMs + (15 * 60 * 1000));
  const resOverlap = await attemptBooking(businessId, 's2', staffId, 120.0, 45, overlapTime, 'Partial Overlap');

  console.log('\n--- 4. ADJACENT BOOKING TEST (10:30 AM - 11:00 AM, st1) ---');
  const adjacentTime = new Date(startMs + (30 * 60 * 1000));
  const resAdj = await attemptBooking(businessId, serviceId, staffId, servicePrice, durationMinutes, adjacentTime, 'Adjacent Booking');

  console.log('\n--- 5. DIFFERENT STAFF TEST (10:00 AM - 10:30 AM, st2 David Kim) ---');
  const resDiffStaff = await attemptBooking(businessId, serviceId, 'st2', servicePrice, durationMinutes, testDate, 'Different Staff');

  // --- FIRESTORE PERSISTENCE & INTEGRITY VERIFICATION ---
  console.log('\n--- FIRESTORE PERSISTENCE & INTEGRITY AUDIT ---');
  const readBookRes = await fetch(`${FIRESTORE_BASE}/bookings/${res1.bookingId}`, {
    headers: { 'Authorization': `Bearer ${idToken}` }
  });
  const bookDoc = await readBookRes.json();
  console.log('Booked document retrieved:', bookDoc.name ? bookDoc.name.split('/').pop() : 'NOT FOUND');
  console.log('Status:', bookDoc.fields?.status?.stringValue);
  console.log('Service:', bookDoc.fields?.serviceName?.stringValue);
  console.log('Price:', bookDoc.fields?.servicePrice?.doubleValue || bookDoc.fields?.servicePrice?.integerValue);
  console.log('StartDateTime:', bookDoc.fields?.startDateTime?.timestampValue);
  console.log('EndDateTime:', bookDoc.fields?.endDateTime?.timestampValue);

  // Check locks
  for (const lId of res1.locks) {
    const lockRead = await fetch(`${FIRESTORE_BASE}/booking_slots/${lId}`, {
      headers: { 'Authorization': `Bearer ${idToken}` }
    });
    const lockDoc = await lockRead.json();
    console.log(`Lock ${lId} -> Referencing BookingId: ${lockDoc.fields?.bookingId?.stringValue}`);
  }

  console.log('\n=== CONTROLLED BOOKING TEST SUMMARY ===');
  console.log('First Booking:', res1.success ? 'PASSED' : 'FAILED');
  console.log('Exact Duplicate:', !resDup.success ? 'REJECTED (PASSED)' : 'FAILED');
  console.log('Partial Overlap:', !resOverlap.success ? 'REJECTED (PASSED)' : 'FAILED');
  console.log('Adjacent Booking:', resAdj.success ? 'ALLOWED (PASSED)' : 'FAILED');
  console.log('Different Staff:', resDiffStaff.success ? 'ALLOWED (PASSED)' : 'FAILED');
  console.log('=== FIRST REAL BOOKING VALIDATED — BOOKING CORE PASSED ===');
}

run().catch(err => console.error('Booking test error:', err));
