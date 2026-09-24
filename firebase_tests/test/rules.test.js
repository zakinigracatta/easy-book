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

test('17. Authenticated raw booking_slots read -> DENY', async () => {
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
  await assertFails(
    aliceDb.collection('booking_slots').doc('slot_public').get()
  );
});

test('18. Customer reads admin_config -> DENY', async () => {
  await testEnv.withSecurityRulesDisabled(async (context) => {
    const adminDb = context.firestore();
    await adminDb.collection('admin_config').doc('sys_cfg').set({
      setting: 'secret',
    });
  });

  const aliceDb = testEnv.authenticatedContext('cust_alice').firestore();
  await assertFails(aliceDb.collection('admin_config').doc('sys_cfg').get());
});

test('19. Owner reads admin_config -> DENY', async () => {
  await testEnv.withSecurityRulesDisabled(async (context) => {
    const adminDb = context.firestore();
    await adminDb.collection('users').doc('owner_uid').set({
      id: 'owner_uid',
      role: 'owner',
    });
    await adminDb.collection('admin_config').doc('sys_cfg').set({
      setting: 'secret',
    });
  });

  const ownerDb = testEnv.authenticatedContext('owner_uid').firestore();
  await assertFails(ownerDb.collection('admin_config').doc('sys_cfg').get());
});

test('20. Admin reads admin_config -> ALLOW', async () => {
  await testEnv.withSecurityRulesDisabled(async (context) => {
    const adminDb = context.firestore();
    await adminDb.collection('users').doc('admin_uid').set({
      id: 'admin_uid',
      role: 'admin',
    });
    await adminDb.collection('admin_config').doc('sys_cfg').set({
      setting: 'secret',
    });
  });

  const adminUserDb = testEnv.authenticatedContext('admin_uid').firestore();
  await assertSucceeds(adminUserDb.collection('admin_config').doc('sys_cfg').get());
});


test('21. Super admin reads admin_config -> ALLOW', async () => {
  await testEnv.withSecurityRulesDisabled(async (context) => {
    const adminDb = context.firestore();
    await adminDb.collection('users').doc('super_uid').set({
      id: 'super_uid',
      role: 'super_admin',
    });
    await adminDb.collection('admin_config').doc('sys_cfg').set({
      setting: 'secret',
    });
  });

  const superDb = testEnv.authenticatedContext('super_uid').firestore();
  await assertSucceeds(superDb.collection('admin_config').doc('sys_cfg').get());
});

test('22. Admin reads another user profile -> ALLOW', async () => {
  await testEnv.withSecurityRulesDisabled(async (context) => {
    const adminDb = context.firestore();
    await adminDb.collection('users').doc('admin_uid').set({
      id: 'admin_uid',
      role: 'admin',
    });
    await adminDb.collection('users').doc('owner_uid').set({
      id: 'owner_uid',
      role: 'owner',
      email: 'owner@example.com',
    });
  });

  const adminUserDb = testEnv.authenticatedContext('admin_uid').firestore();
  await assertSucceeds(adminUserDb.collection('users').doc('owner_uid').get());
});


test('23. Customer profile create with zero wallet -> ALLOW', async () => {
  const db = testEnv
    .authenticatedContext('cust_profile', { email: 'cust@example.com' })
    .firestore();

  await assertSucceeds(
    db.collection('users').doc('cust_profile').set({
      id: 'cust_profile',
      email: 'cust@example.com',
      full_name: 'Customer',
      phone: '+971500000000',
      role: 'customer',
      wallet_balance: 0,
    })
  );
});

test('24. Customer profile create with forged wallet balance -> DENY', async () => {
  const db = testEnv
    .authenticatedContext('cust_profile', { email: 'cust@example.com' })
    .firestore();

  await assertFails(
    db.collection('users').doc('cust_profile').set({
      id: 'cust_profile',
      email: 'cust@example.com',
      role: 'customer',
      wallet_balance: 999999,
    })
  );
});

test('25. Customer cannot update wallet balance -> DENY', async () => {
  await testEnv.withSecurityRulesDisabled(async (context) => {
    await context.firestore().collection('users').doc('cust_wallet').set({
      id: 'cust_wallet',
      email: 'wallet@example.com',
      role: 'customer',
      wallet_balance: 0,
      phone: '',
    });
  });

  const db = testEnv.authenticatedContext('cust_wallet').firestore();
  await assertFails(
    db.collection('users').doc('cust_wallet').update({
      wallet_balance: 500,
    })
  );
});

test('26. Customer can update normal profile fields -> ALLOW', async () => {
  await testEnv.withSecurityRulesDisabled(async (context) => {
    await context.firestore().collection('users').doc('cust_profile').set({
      id: 'cust_profile',
      email: 'profile@example.com',
      role: 'customer',
      wallet_balance: 0,
      phone: '',
    });
  });

  const db = testEnv.authenticatedContext('cust_profile').firestore();
  await assertSucceeds(
    db.collection('users').doc('cust_profile').update({
      phone: '+971511111111',
    })
  );
});

test('27. Customer cannot add arbitrary privileged profile field -> DENY', async () => {
  await testEnv.withSecurityRulesDisabled(async (context) => {
    await context.firestore().collection('users').doc('cust_profile').set({
      id: 'cust_profile',
      email: 'profile@example.com',
      role: 'customer',
      wallet_balance: 0,
    });
  });

  const db = testEnv.authenticatedContext('cust_profile').firestore();
  await assertFails(
    db.collection('users').doc('cust_profile').update({
      isSuperAdmin: true,
    })
  );
});

test('28. Verified business missing active flag is not public -> DENY', async () => {
  await testEnv.withSecurityRulesDisabled(async (context) => {
    await context.firestore().collection('businesses').doc('biz_missing_active').set({
      id: 'biz_missing_active',
      is_verified: true,
      ownerId: 'owner_missing_active',
    });
  });

  const publicDb = testEnv.unauthenticatedContext().firestore();
  await assertFails(
    publicDb.collection('businesses').doc('biz_missing_active').get()
  );
});

test('29. Explicitly verified and active business is public -> ALLOW', async () => {
  await testEnv.withSecurityRulesDisabled(async (context) => {
    await context.firestore().collection('businesses').doc('biz_public').set({
      id: 'biz_public',
      is_verified: true,
      is_active: true,
      ownerId: 'owner_public',
    });
  });

  const publicDb = testEnv.unauthenticatedContext().firestore();
  await assertSucceeds(publicDb.collection('businesses').doc('biz_public').get());
});

test('30. Legacy ownerId query resolves unpublished owner business -> ALLOW', async () => {
  await testEnv.withSecurityRulesDisabled(async (context) => {
    const adminDb = context.firestore();
    await adminDb.collection('users').doc('owner_query').set({
      id: 'owner_query',
      role: 'owner',
    });
    await adminDb.collection('businesses').doc('legacy_business').set({
      id: 'legacy_business',
      ownerId: 'owner_query',
      is_verified: false,
      is_active: true,
    });
  });

  const ownerDb = testEnv.authenticatedContext('owner_query').firestore();
  await assertSucceeds(
    ownerDb.collection('businesses')
      .where('ownerId', '==', 'owner_query')
      .limit(1)
      .get()
  );
});

test('31. Legacy owner_id query resolves unpublished owner business -> ALLOW', async () => {
  await testEnv.withSecurityRulesDisabled(async (context) => {
    const adminDb = context.firestore();
    await adminDb.collection('users').doc('owner_query_legacy').set({
      id: 'owner_query_legacy',
      role: 'owner',
    });
    await adminDb.collection('businesses').doc('legacy_business_snake').set({
      id: 'legacy_business_snake',
      owner_id: 'owner_query_legacy',
      is_verified: false,
      is_active: true,
    });
  });

  const ownerDb = testEnv.authenticatedContext('owner_query_legacy').firestore();
  await assertSucceeds(
    ownerDb.collection('businesses')
      .where('owner_id', '==', 'owner_query_legacy')
      .limit(1)
      .get()
  );
});

async function seedFinanceRulesFixture() {
  await testEnv.withSecurityRulesDisabled(async (context) => {
    const adminDb = context.firestore();
    await adminDb.collection('users').doc('finance_owner').set({
      id: 'finance_owner',
      role: 'owner',
    });
    await adminDb.collection('users').doc('finance_other_owner').set({
      id: 'finance_other_owner',
      role: 'owner',
    });
    await adminDb.collection('businesses').doc('finance_biz').set({
      id: 'finance_biz',
      ownerId: 'finance_owner',
      is_verified: false,
      is_active: true,
    });
    await adminDb.collection('bookings').doc('finance_booking').set({
      id: 'finance_booking',
      customerId: 'finance_customer',
      businessId: 'finance_biz',
      startDateTime: new Date('2026-09-07T12:00:00Z'),
      status: 'completed',
      servicePrice: 100,
    });
    await adminDb.collection('businesses').doc('finance_biz')
      .collection('expenses').doc('finance_expense').set({
        businessId: 'finance_biz',
        category: 'rent',
        description: 'September rent',
        amount: 50,
        expenseDate: new Date('2026-09-07T08:00:00Z'),
        paymentMethod: 'cash',
        frequency: 'monthly',
        isActive: true,
        createdBy: 'finance_owner',
        createdAt: new Date('2026-09-01T08:00:00Z'),
        updatedAt: new Date('2026-09-01T08:00:00Z'),
      });
  });
}

test('32. Finance owner can execute booking report query -> ALLOW', async () => {
  await seedFinanceRulesFixture();
  const ownerDb = testEnv.authenticatedContext('finance_owner').firestore();

  await assertSucceeds(
    ownerDb.collection('bookings')
      .where('businessId', '==', 'finance_biz')
      .where('startDateTime', '>=', new Date('2026-09-01T00:00:00Z'))
      .where('startDateTime', '<', new Date('2026-10-01T00:00:00Z'))
      .get()
  );
});

test('33. Finance owner can query own expenses -> ALLOW', async () => {
  await seedFinanceRulesFixture();
  const ownerDb = testEnv.authenticatedContext('finance_owner').firestore();

  await assertSucceeds(
    ownerDb.collection('businesses').doc('finance_biz')
      .collection('expenses')
      .where('expenseDate', '>=', new Date('2026-09-01T00:00:00Z'))
      .where('expenseDate', '<', new Date('2026-10-01T00:00:00Z'))
      .get()
  );
});

test('34. Another owner cannot read finance expenses -> DENY', async () => {
  await seedFinanceRulesFixture();
  const otherDb = testEnv.authenticatedContext('finance_other_owner').firestore();

  await assertFails(
    otherDb.collection('businesses').doc('finance_biz')
      .collection('expenses').get()
  );
});

test('35. Customer cannot query all bookings for a finance report -> DENY', async () => {
  await seedFinanceRulesFixture();
  const customerDb = testEnv.authenticatedContext('finance_customer').firestore();

  await assertFails(
    customerDb.collection('bookings')
      .where('businessId', '==', 'finance_biz')
      .get()
  );
});


test('36. Canonical publication flags override conflicting legacy flags -> DENY', async () => {
  await testEnv.withSecurityRulesDisabled(async (context) => {
    await context.firestore().collection('businesses').doc('biz_conflict').set({
      id: 'biz_conflict',
      is_verified: false,
      isVerified: true,
      is_active: false,
      isActive: true,
      ownerId: 'owner_conflict',
    });
  });

  const publicDb = testEnv.unauthenticatedContext().firestore();
  await assertFails(
    publicDb.collection('businesses').doc('biz_conflict').get()
  );
});

test('37. Legacy publication flags remain valid when canonical flags are absent -> ALLOW', async () => {
  await testEnv.withSecurityRulesDisabled(async (context) => {
    await context.firestore().collection('businesses').doc('biz_legacy_public').set({
      id: 'biz_legacy_public',
      isVerified: true,
      isActive: true,
      ownerId: 'owner_legacy_public',
    });
  });

  const publicDb = testEnv.unauthenticatedContext().firestore();
  await assertSucceeds(
    publicDb.collection('businesses').doc('biz_legacy_public').get()
  );
});


test('38. Canonical owner_id overrides conflicting legacy ownerId', async () => {
  await testEnv.withSecurityRulesDisabled(async (context) => {
    await context.firestore().collection('businesses').doc('biz_owner_conflict').set({
      id: 'biz_owner_conflict',
      owner_id: 'canonical_owner',
      ownerId: 'legacy_owner',
      is_verified: false,
      is_active: true,
    });
  });

  const canonicalDb = testEnv.authenticatedContext('canonical_owner').firestore();
  const legacyDb = testEnv.authenticatedContext('legacy_owner').firestore();

  await assertSucceeds(
    canonicalDb.collection('businesses').doc('biz_owner_conflict').get()
  );
  await assertFails(
    legacyDb.collection('businesses').doc('biz_owner_conflict').get()
  );
});

test('39. Business create rejects conflicting owner aliases', async () => {
  await testEnv.withSecurityRulesDisabled(async (context) => {
    await context.firestore().collection('users').doc('owner_creator').set({
      id: 'owner_creator',
      role: 'owner',
    });
  });

  const ownerDb = testEnv.authenticatedContext('owner_creator').firestore();
  await assertFails(
    ownerDb.collection('businesses').doc('biz_bad_owner_aliases').set({
      id: 'biz_bad_owner_aliases',
      owner_id: 'owner_creator',
      ownerId: 'someone_else',
      is_verified: false,
      is_active: true,
      rating: 0,
      review_count: 0,
    })
  );
});


test('40. Owner cannot forge staff rating or review count', async () => {
  await testEnv.withSecurityRulesDisabled(async (context) => {
    const adminDb = context.firestore();
    await adminDb.collection('users').doc('staff_owner').set({
      id: 'staff_owner',
      role: 'owner',
    });
    await adminDb.collection('businesses').doc('staff_biz').set({
      id: 'staff_biz',
      ownerId: 'staff_owner',
      is_verified: true,
      is_active: true,
    });
  });

  const ownerDb = testEnv.authenticatedContext('staff_owner').firestore();
  await assertFails(
    ownerDb.collection('businesses').doc('staff_biz')
      .collection('staff').doc('staff_forged').set({
        id: 'staff_forged',
        business_id: 'staff_biz',
        businessId: 'staff_biz',
        name: 'Forged Specialist',
        is_active: true,
        isActive: true,
        rating: 5,
        review_count: 999,
      })
  );
});

test('41. Owner can create staff with zero trust counters', async () => {
  await testEnv.withSecurityRulesDisabled(async (context) => {
    const adminDb = context.firestore();
    await adminDb.collection('users').doc('staff_owner_zero').set({
      id: 'staff_owner_zero',
      role: 'owner',
    });
    await adminDb.collection('businesses').doc('staff_biz_zero').set({
      id: 'staff_biz_zero',
      ownerId: 'staff_owner_zero',
      is_verified: true,
      is_active: true,
    });
  });

  const ownerDb = testEnv.authenticatedContext('staff_owner_zero').firestore();
  await assertSucceeds(
    ownerDb.collection('businesses').doc('staff_biz_zero')
      .collection('staff').doc('staff_ok').set({
        id: 'staff_ok',
        business_id: 'staff_biz_zero',
        businessId: 'staff_biz_zero',
        name: 'New Specialist',
        is_active: true,
        isActive: true,
        rating: 0,
        review_count: 0,
      })
  );
});

test('42. Owner cannot move a staff record to another business identity', async () => {
  await testEnv.withSecurityRulesDisabled(async (context) => {
    const adminDb = context.firestore();
    await adminDb.collection('users').doc('staff_owner_identity').set({
      id: 'staff_owner_identity',
      role: 'owner',
    });
    await adminDb.collection('businesses').doc('staff_biz_identity').set({
      id: 'staff_biz_identity',
      ownerId: 'staff_owner_identity',
      is_verified: true,
      is_active: true,
    });
  });

  const ownerDb = testEnv.authenticatedContext('staff_owner_identity').firestore();
  await assertFails(
    ownerDb.collection('businesses').doc('staff_biz_identity')
      .collection('staff').doc('staff_bad_identity').set({
        id: 'staff_bad_identity',
        business_id: 'another_business',
        businessId: 'another_business',
        name: 'Wrong Business',
        is_active: true,
        isActive: true,
        rating: 0,
        review_count: 0,
      })
  );
});
