import { test, before, after, beforeEach } from 'node:test';
import {
  initializeTestEnvironment,
  assertFails,
  assertSucceeds,
} from '@firebase/rules-unit-testing';
import { readFileSync } from 'node:fs';
import { resolve } from 'node:path';

const PROJECT_ID = 'demo-easy-book-finance';
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
  if (testEnv) await testEnv.cleanup();
});

beforeEach(async () => {
  if (testEnv) await testEnv.clearFirestore();
});

async function seedFinanceFixture() {
  await testEnv.withSecurityRulesDisabled(async (context) => {
    const adminDb = context.firestore();

    await adminDb.collection('users').doc('owner_uid').set({
      id: 'owner_uid',
      role: 'owner',
    });
    await adminDb.collection('users').doc('other_uid').set({
      id: 'other_uid',
      role: 'owner',
    });

    await adminDb.collection('businesses').doc('biz_1').set({
      id: 'biz_1',
      ownerId: 'owner_uid',
      is_verified: false,
      is_active: true,
    });

    await adminDb.collection('bookings').doc('booking_1').set({
      id: 'booking_1',
      customerId: 'customer_uid',
      businessId: 'biz_1',
      startDateTime: new Date('2026-09-07T12:00:00Z'),
      status: 'completed',
      servicePrice: 100,
    });

    await adminDb
      .collection('businesses')
      .doc('biz_1')
      .collection('expenses')
      .doc('expense_1')
      .set({
        businessId: 'biz_1',
        category: 'rent',
        description: 'September rent',
        amount: 50,
        expenseDate: new Date('2026-09-07T08:00:00Z'),
        paymentMethod: 'cash',
        frequency: 'monthly',
        isActive: true,
        createdBy: 'owner_uid',
        createdAt: new Date('2026-09-01T08:00:00Z'),
        updatedAt: new Date('2026-09-01T08:00:00Z'),
      });
  });
}

test('finance bootstrap: signed-in owner can check missing businesses/{uid}', async () => {
  const ownerDb = testEnv.authenticatedContext('owner_uid').firestore();
  await assertSucceeds(
    ownerDb.collection('businesses').doc('owner_uid').get(),
  );
});

test('finance bootstrap: ownerId fallback query resolves legacy business', async () => {
  await seedFinanceFixture();
  const ownerDb = testEnv.authenticatedContext('owner_uid').firestore();

  await assertSucceeds(
    ownerDb
      .collection('businesses')
      .where('ownerId', '==', 'owner_uid')
      .limit(1)
      .get(),
  );
});

test('finance report: owner can execute bookings query used by report', async () => {
  await seedFinanceFixture();
  const ownerDb = testEnv.authenticatedContext('owner_uid').firestore();

  await assertSucceeds(
    ownerDb
      .collection('bookings')
      .where('businessId', '==', 'biz_1')
      .where('startDateTime', '>=', new Date('2026-09-01T00:00:00Z'))
      .where('startDateTime', '<', new Date('2026-10-01T00:00:00Z'))
      .get(),
  );
});

test('finance report: owner can execute expense date-range query', async () => {
  await seedFinanceFixture();
  const ownerDb = testEnv.authenticatedContext('owner_uid').firestore();

  await assertSucceeds(
    ownerDb
      .collection('businesses')
      .doc('biz_1')
      .collection('expenses')
      .where('expenseDate', '>=', new Date('2026-09-01T00:00:00Z'))
      .where('expenseDate', '<', new Date('2026-10-01T00:00:00Z'))
      .get(),
  );
});

test('finance privacy: another owner cannot read expenses', async () => {
  await seedFinanceFixture();
  const otherDb = testEnv.authenticatedContext('other_uid').firestore();

  await assertFails(
    otherDb
      .collection('businesses')
      .doc('biz_1')
      .collection('expenses')
      .get(),
  );
});

test('finance privacy: customer cannot query all bookings for a business', async () => {
  await seedFinanceFixture();
  const customerDb = testEnv.authenticatedContext('customer_uid').firestore();

  await assertFails(
    customerDb
      .collection('bookings')
      .where('businessId', '==', 'biz_1')
      .get(),
  );
});
