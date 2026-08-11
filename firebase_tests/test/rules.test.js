import { test, before, after, beforeEach } from 'node:test';
import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';
import { resolve } from 'node:path';
import {
  initializeTestEnvironment,
  assertFails,
  assertSucceeds,
} from '@firebase/rules-unit-testing';

const PROJECT_ID = 'demo-easy-book';
let testEnv;

before(async () => {
  const rulesPath = resolve(process.cwd(), '../firestore.rules');
  const rules = readFileSync(rulesPath, 'utf8');

  testEnv = await initializeTestEnvironment({
    projectId: PROJECT_ID,
    firestore: {
      rules,
      host: '127.0.0.1',
      port: 8080,
    },
  });
});

after(async () => {
  if (testEnv) {
    await testEnv.cleanup();
  }
});

beforeEach(async () => {
  if (testEnv) {
    await testEnv.clearFirestore();
  }
});

test('1. Unauthenticated booking read -> DENY', async () => {
  const unauthDb = testEnv.unauthenticatedContext().firestore();
  await assertFails(unauthDb.collection('bookings').doc('b_123').get());
});

test('2. Customer reads own booking -> ALLOW', async () => {
  await testEnv.withSecurityRulesDisabled(async (context) => {
    const adminDb = context.firestore();
    await adminDb.collection('bookings').doc('b_own').set({
      id: 'b_own',
      customerId: 'cust_alice',
      businessId: 'biz_1',
      status: 'pending',
    });
  });

  const aliceDb = testEnv.authenticatedContext('cust_alice').firestore();
  await assertSucceeds(aliceDb.collection('bookings').doc('b_own').get());
});

test('3. Customer reads another customer booking -> DENY', async () => {
  await testEnv.withSecurityRulesDisabled(async (context) => {
    const adminDb = context.firestore();
    await adminDb.collection('bookings').doc('b_alice').set({
      id: 'b_alice',
      customerId: 'cust_alice',
      businessId: 'biz_1',
      status: 'pending',
    });
  });

  const bobDb = testEnv.authenticatedContext('cust_bob').firestore();
  await assertFails(bobDb.collection('bookings').doc('b_alice').get());
});

test('4. Customer direct booking create -> DENY', async () => {
  const aliceDb = testEnv.authenticatedContext('cust_alice').firestore();
  await assertFails(
    aliceDb.collection('bookings').doc('b_new').set({
      id: 'b_new',
      customerId: 'cust_alice',
      businessId: 'biz_1',
      serviceId: 'srv_1',
      staffId: 'st_1',
      status: 'pending',
      bookingSource: 'app',
    })
  );
});

test('5. Customer direct booking update -> DENY', async () => {
  await testEnv.withSecurityRulesDisabled(async (context) => {
    const adminDb = context.firestore();
    await adminDb.collection('bookings').doc('b_alice').set({
      id: 'b_alice',
      customerId: 'cust_alice',
      businessId: 'biz_1',
      status: 'pending',
      servicePrice: 100,
    });
  });

  const aliceDb = testEnv.authenticatedContext('cust_alice').firestore();
  await assertFails(
    aliceDb.collection('bookings').doc('b_alice').update({
      servicePrice: 1,
    })
  );
});

test('6. Customer direct booking delete -> DENY', async () => {
  await testEnv.withSecurityRulesDisabled(async (context) => {
    const adminDb = context.firestore();
    await adminDb.collection('bookings').doc('b_alice').set({
      id: 'b_alice',
      customerId: 'cust_alice',
      businessId: 'biz_1',
      status: 'pending',
    });
  });

  const aliceDb = testEnv.authenticatedContext('cust_alice').firestore();
  await assertFails(aliceDb.collection('bookings').doc('b_alice').delete());
});

test('7. Customer direct booking_slots create -> DENY', async () => {
  const aliceDb = testEnv.authenticatedContext('cust_alice').firestore();
  await assertFails(
    aliceDb.collection('booking_slots').doc('slot_1').set({
      slotId: 'slot_1',
      bookingId: 'b_alice',
      businessId: 'biz_1',
      staffId: 'st_1',
      startTimestamp: 1600000000000,
    })
  );
});

test('8. Customer direct booking_slots update -> DENY', async () => {
  await testEnv.withSecurityRulesDisabled(async (context) => {
    const adminDb = context.firestore();
    await adminDb.collection('booking_slots').doc('slot_1').set({
      slotId: 'slot_1',
      bookingId: 'b_alice',
      businessId: 'biz_1',
      staffId: 'st_1',
    });
  });

  const aliceDb = testEnv.authenticatedContext('cust_alice').firestore();
  await assertFails(
    aliceDb.collection('booking_slots').doc('slot_1').update({
      staffId: 'st_2',
    })
  );
});

test('9. Customer direct booking_slots delete -> DENY', async () => {
  await testEnv.withSecurityRulesDisabled(async (context) => {
    const adminDb = context.firestore();
    await adminDb.collection('booking_slots').doc('slot_1').set({
      slotId: 'slot_1',
      bookingId: 'b_alice',
      businessId: 'biz_1',
      staffId: 'st_1',
    });
  });

  const aliceDb = testEnv.authenticatedContext('cust_alice').firestore();
  await assertFails(aliceDb.collection('booking_slots').doc('slot_1').delete());
});

test('10. Owner direct booking create -> DENY', async () => {
  const ownerDb = testEnv.authenticatedContext('owner_uid').firestore();
  await assertFails(
    ownerDb.collection('bookings').doc('b_walkin').set({
      id: 'b_walkin',
      businessId: 'biz_1',
      bookingSource: 'walkIn',
      status: 'confirmed',
    })
  );
});

test('11. Owner direct booking arbitrary update -> DENY', async () => {
  await testEnv.withSecurityRulesDisabled(async (context) => {
    const adminDb = context.firestore();
    await adminDb.collection('businesses').doc('biz_1').set({
      id: 'biz_1',
      ownerId: 'owner_uid',
    });
    await adminDb.collection('bookings').doc('b_1').set({
      id: 'b_1',
      businessId: 'biz_1',
      status: 'pending',
    });
  });

  const ownerDb = testEnv.authenticatedContext('owner_uid').firestore();
  await assertFails(
    ownerDb.collection('bookings').doc('b_1').update({
      status: 'completed',
    })
  );
});

test('12. Owner direct slot delete -> DENY', async () => {
  await testEnv.withSecurityRulesDisabled(async (context) => {
    const adminDb = context.firestore();
    await adminDb.collection('businesses').doc('biz_1').set({
      id: 'biz_1',
      ownerId: 'owner_uid',
    });
    await adminDb.collection('booking_slots').doc('slot_1').set({
      slotId: 'slot_1',
      businessId: 'biz_1',
    });
  });

  const ownerDb = testEnv.authenticatedContext('owner_uid').firestore();
  await assertFails(ownerDb.collection('booking_slots').doc('slot_1').delete());
});

test('13. Customer reads private customerNotes -> DENY', async () => {
  await testEnv.withSecurityRulesDisabled(async (context) => {
    const adminDb = context.firestore();
    await adminDb
      .collection('businesses')
      .doc('biz_1')
      .collection('customerNotes')
      .doc('cust_alice')
      .set({
        vipNotes: 'Private owner notes',
      });
  });

  const aliceDb = testEnv.authenticatedContext('cust_alice').firestore();
  await assertFails(
    aliceDb
      .collection('businesses')
      .doc('biz_1')
      .collection('customerNotes')
      .doc('cust_alice')
      .get()
  );
});

test('14. Owner reads private notes for own business -> ALLOW', async () => {
  await testEnv.withSecurityRulesDisabled(async (context) => {
    const adminDb = context.firestore();
    await adminDb.collection('users').doc('owner_uid').set({
      id: 'owner_uid',
      role: 'owner',
    });
    await adminDb.collection('businesses').doc('biz_1').set({
      id: 'biz_1',
      ownerId: 'owner_uid',
    });
    await adminDb
      .collection('businesses')
      .doc('biz_1')
      .collection('customerNotes')
      .doc('cust_alice')
      .set({
        vipNotes: 'Private owner notes',
      });
  });

  const ownerDb = testEnv.authenticatedContext('owner_uid').firestore();
  await assertSucceeds(
    ownerDb
      .collection('businesses')
      .doc('biz_1')
      .collection('customerNotes')
      .doc('cust_alice')
      .get()
  );
});

test('15. Owner A reads business B notes -> DENY', async () => {
  await testEnv.withSecurityRulesDisabled(async (context) => {
    const adminDb = context.firestore();
    await adminDb.collection('users').doc('owner_a').set({
      id: 'owner_a',
      role: 'owner',
    });
    await adminDb.collection('businesses').doc('biz_b').set({
      id: 'biz_b',
      ownerId: 'owner_b',
    });
    await adminDb
      .collection('businesses')
      .doc('biz_b')
      .collection('customerNotes')
      .doc('cust_alice')
      .set({
        vipNotes: 'Private owner notes',
      });
  });

  const ownerADb = testEnv.authenticatedContext('owner_a').firestore();
  await assertFails(
    ownerADb
      .collection('businesses')
      .doc('biz_b')
      .collection('customerNotes')
      .doc('cust_alice')
      .get()
  );
});

test('16. Unauthenticated booking_slots read -> DENY', async () => {
  const unauthDb = testEnv.unauthenticatedContext().firestore();
  await assertFails(unauthDb.collection('booking_slots').doc('slot_1').get());
});

test('17. Authenticated availability lock read -> ALLOW', async () => {
  await testEnv.withSecurityRulesDisabled(async (context) => {
    const adminDb = context.firestore();
    await adminDb.collection('booking_slots').doc('slot_public').set({
      slotId: 'slot_public',
      businessId: 'biz_1',
      staffId: 'st_1',
      startTimestamp: 1600000000000,
    });
  });

  const aliceDb = testEnv.authenticatedContext('cust_alice').firestore();
  await assertSucceeds(
    aliceDb.collection('booking_slots').doc('slot_public').get()
  );
});
