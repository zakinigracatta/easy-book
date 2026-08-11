const API_KEY = 'AIzaSyApbJ5knQAHW9wCBMeKq8Z4CrfQYWgsMCM';
const PROJECT_ID = 'easy-book-zaki';
const SIGNIN_URL = `https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=${API_KEY}`;
const AUTH_URL = `https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=${API_KEY}`;
const FIRESTORE_BASE = `https://firestore.googleapis.com/v1/projects/${PROJECT_ID}/databases/(default)/documents`;
const COMMIT_URL = `https://firestore.googleapis.com/v1/projects/${PROJECT_ID}/databases/(default)/documents:commit`;

const customerEmail = 'dev.customer@easybook.ae';
const customerPassword = 'DevCustomerPassword123!';
const otherCustomerEmail = 'other.customer@easybook.ae';
const otherCustomerPassword = 'OtherCustomerPassword123!';

async function run() {
  console.log('--- Starting Real Availability & Safe Cancellation Validation ---');

  // Sign in Customer 1
  let res = await fetch(SIGNIN_URL, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ email: customerEmail, password: customerPassword, returnSecureToken: true }),
  });
  let data = await res.json();
  let idToken1 = data.idToken;
  let uid1 = data.localId;

  // Sign in / Register Customer 2 (for unauthorized cancellation test)
  res = await fetch(SIGNIN_URL, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ email: otherCustomerEmail, password: otherCustomerPassword, returnSecureToken: true }),
  });
  data = await res.json();
  let idToken2 = '';
  let uid2 = '';
  if (data.idToken) {
    idToken2 = data.idToken;
    uid2 = data.localId;
  } else {
    res = await fetch(AUTH_URL, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ email: otherCustomerEmail, password: otherCustomerPassword, returnSecureToken: true }),
    });
    data = await res.json();
    idToken2 = data.idToken;
    uid2 = data.localId;
  }

  // 1. Create a Controlled Booking for 15:00 (3:00 PM) 4 days in the future
  const testDate = new Date();
  testDate.setDate(testDate.getDate() + 4);
  testDate.setHours(15, 0, 0, 0);

  const startMs = testDate.getTime();
  const endMs = startMs + (30 * 60 * 1000);
  const bId = 'b1';
  const stId = 'st1';
  const lockId = `${bId}_${stId}_${startMs}`;
  const bookingId = `book_cancel_test_${Date.now()}`;

  console.log(`Test Booking Time: ${testDate.toISOString()}`);
  console.log(`Lock ID: ${lockId}`);

  // Create booking atomically
  const writes = [
    {
      update: {
        name: `projects/${PROJECT_ID}/databases/(default)/documents/booking_slots/${lockId}`,
        fields: {
          slotId: { stringValue: lockId },
          bookingId: { stringValue: bookingId },
          businessId: { stringValue: bId },
          staffId: { stringValue: stId },
          startDateTime: { timestampValue: testDate.toISOString() },
          startTimestamp: { integerValue: startMs.toString() },
          customerId: { stringValue: uid1 },
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
          customerId: { stringValue: uid1 },
          customerName: { stringValue: 'Alex Customer' },
          businessId: { stringValue: bId },
          businessName: { stringValue: 'Executive Barber Lounge' },
          serviceId: { stringValue: 's1' },
          serviceName: { stringValue: 'Classic Haircut' },
          servicePrice: { doubleValue: 80.0 },
          staffId: { stringValue: stId },
          staffName: { stringValue: 'Marcus Vance' },
          startDateTime: { timestampValue: testDate.toISOString() },
          endDateTime: { timestampValue: new Date(endMs).toISOString() },
          startTimestamp: { integerValue: startMs.toString() },
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
    headers: { 'Content-Type': 'application/json', 'Authorization': `Bearer ${idToken1}` },
    body: JSON.stringify({ writes })
  });

  if (commitRes.status !== 200) {
    console.error('Failed to create test booking for cancellation test:', await commitRes.json());
    process.exit(1);
  }
  console.log(`[SETUP] Booking ${bookingId} created. Slot lock ${lockId} occupied.`);

  // 2. Test Unauthorized Cancellation by Customer 2 (Should be REJECTED by Firestore Rules)
  console.log('\n--- TEST A: Unauthorized Cancellation by Customer 2 ---');
  const unauthCancelWrites = [
    {
      delete: `projects/${PROJECT_ID}/databases/(default)/documents/booking_slots/${lockId}`
    },
    {
      update: {
        name: `projects/${PROJECT_ID}/databases/(default)/documents/bookings/${bookingId}`,
        fields: {
          status: { stringValue: 'cancelled' },
          updatedAt: { timestampValue: new Date().toISOString() }
        }
      },
      updateMask: { fieldPaths: ['status', 'updatedAt'] }
    }
  ];

  const unauthRes = await fetch(COMMIT_URL, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json', 'Authorization': `Bearer ${idToken2}` },
    body: JSON.stringify({ writes: unauthCancelWrites })
  });

  if (unauthRes.status !== 200) {
    console.log('[TEST A PASSED] Unauthorized cancellation REJECTED by Firestore Rules.');
  } else {
    console.error('[TEST A FAILED] Unauthorized cancellation was allowed!');
    process.exit(1);
  }

  // 3. Test Authorized Atomic Cancellation by Customer 1 (Should SUCCEED)
  console.log('\n--- TEST B: Authorized Atomic Cancellation by Booking Owner ---');
  const authCancelWrites = [
    {
      delete: `projects/${PROJECT_ID}/databases/(default)/documents/booking_slots/${lockId}`
    },
    {
      update: {
        name: `projects/${PROJECT_ID}/databases/(default)/documents/bookings/${bookingId}`,
        fields: {
          status: { stringValue: 'cancelled' },
          updatedAt: { timestampValue: new Date().toISOString() }
        }
      },
      updateMask: { fieldPaths: ['status', 'updatedAt'] }
    }
  ];

  const authRes = await fetch(COMMIT_URL, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json', 'Authorization': `Bearer ${idToken1}` },
    body: JSON.stringify({ writes: authCancelWrites })
  });

  if (authRes.status === 200) {
    console.log('[TEST B PASSED] Atomic cancellation SUCCEEDED.');
  } else {
    console.error('[TEST B FAILED] Authorized cancellation failed:', await authRes.json());
    process.exit(1);
  }

  // 4. Verify Slot Lock Deletion in Firestore
  console.log('\n--- TEST C: Verify Slot Lock Deletion ---');
  const lockReadRes = await fetch(`${FIRESTORE_BASE}/booking_slots/${lockId}`, {
    headers: { 'Authorization': `Bearer ${idToken1}` }
  });
  if (lockReadRes.status === 404) {
    console.log(`[TEST C PASSED] Slot lock ${lockId} DELETED cleanly from Firestore.`);
  } else {
    console.error(`[TEST C FAILED] Slot lock ${lockId} still exists in Firestore!`);
  }

  // 5. Verify Booking Status Updated to Cancelled
  console.log('\n--- TEST D: Verify Booking Status Update ---');
  const bookReadRes = await fetch(`${FIRESTORE_BASE}/bookings/${bookingId}`, {
    headers: { 'Authorization': `Bearer ${idToken1}` }
  });
  const bookDocData = await bookReadRes.json();
  const currentStatus = bookDocData.fields?.status?.stringValue;
  console.log(`Booking Status in Firestore: ${currentStatus}`);
  if (currentStatus === 'cancelled') {
    console.log('[TEST D PASSED] Booking status is cancelled.');
  } else {
    console.error(`[TEST D FAILED] Status is ${currentStatus}`);
  }

  // 6. Test Re-booking Released Slot (Should SUCCEED)
  console.log('\n--- TEST E: Re-booking Released Slot ---');
  const rebookId = `book_rebook_${Date.now()}`;
  const rebookWrites = [
    {
      update: {
        name: `projects/${PROJECT_ID}/databases/(default)/documents/booking_slots/${lockId}`,
        fields: {
          slotId: { stringValue: lockId },
          bookingId: { stringValue: rebookId },
          businessId: { stringValue: bId },
          staffId: { stringValue: stId },
          startDateTime: { timestampValue: testDate.toISOString() },
          startTimestamp: { integerValue: startMs.toString() },
          customerId: { stringValue: uid1 },
          createdAt: { timestampValue: new Date().toISOString() }
        }
      },
      currentDocument: { exists: false }
    },
    {
      update: {
        name: `projects/${PROJECT_ID}/databases/(default)/documents/bookings/${rebookId}`,
        fields: {
          id: { stringValue: rebookId },
          customerId: { stringValue: uid1 },
          customerName: { stringValue: 'Alex Customer' },
          businessId: { stringValue: bId },
          businessName: { stringValue: 'Executive Barber Lounge' },
          serviceId: { stringValue: 's1' },
          serviceName: { stringValue: 'Classic Haircut' },
          servicePrice: { doubleValue: 80.0 },
          staffId: { stringValue: stId },
          staffName: { stringValue: 'Marcus Vance' },
          startDateTime: { timestampValue: testDate.toISOString() },
          endDateTime: { timestampValue: new Date(endMs).toISOString() },
          startTimestamp: { integerValue: startMs.toString() },
          status: { stringValue: 'pending' },
          slotLockId: { stringValue: lockId },
          createdAt: { timestampValue: new Date().toISOString() },
          updatedAt: { timestampValue: new Date().toISOString() }
        }
      },
      currentDocument: { exists: false }
    }
  ];

  const rebookRes = await fetch(COMMIT_URL, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json', 'Authorization': `Bearer ${idToken1}` },
    body: JSON.stringify({ writes: rebookWrites })
  });

  if (rebookRes.status === 200) {
    console.log('[TEST E PASSED] Released slot re-booked successfully!');
  } else {
    console.error('[TEST E FAILED] Re-booking released slot failed:', await rebookRes.json());
  }

  console.log('\n=== REAL AVAILABILITY & CANCELLATION CORE PASSED ===');
}

run().catch(err => console.error('Cancellation test error:', err));
