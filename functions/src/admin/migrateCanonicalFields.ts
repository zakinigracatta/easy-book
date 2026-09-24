import * as admin from 'firebase-admin';

if (!admin.apps.length) {
  admin.initializeApp();
}

type Mapping = readonly [canonical: string, legacy: string];

const BUSINESS_MAPPINGS: Mapping[] = [
  ['owner_id', 'ownerId'],
  ['is_verified', 'isVerified'],
  ['is_active', 'isActive'],
  ['business_status', 'businessStatus'],
  ['accepting_bookings', 'acceptingBookings'],
  ['working_hours', 'workingHours'],
  ['review_count', 'reviewCount'],
  ['image_url', 'imageUrl'],
];

const SERVICE_MAPPINGS: Mapping[] = [
  ['business_id', 'salon_id'],
  ['business_id', 'businessId'],
  ['is_active', 'isActive'],
  ['is_bookable', 'isBookable'],
  ['duration_minutes', 'durationMinutes'],
  ['discount_price', 'discountPrice'],
  ['image_url', 'imageUrl'],
  ['category_id', 'categoryId'],
  ['category_name', 'categoryName'],
];

const STAFF_MAPPINGS: Mapping[] = [
  ['business_id', 'businessId'],
  ['is_active', 'isActive'],
  ['service_ids', 'serviceIds'],
  ['weekly_schedule', 'weeklySchedule'],
  ['working_days', 'workingDays'],
  ['shift_start', 'shiftStart'],
  ['shift_end', 'shiftEnd'],
  ['avatar_url', 'avatarUrl'],
  ['role_title', 'roleTitle'],
  ['review_count', 'reviewCount'],
];

function canonicalPatch(
  data: admin.firestore.DocumentData,
  mappings: Mapping[]
): admin.firestore.DocumentData {
  const patch: admin.firestore.DocumentData = {};

  for (const [canonical, legacy] of mappings) {
    const hasCanonical = Object.prototype.hasOwnProperty.call(data, canonical);
    const hasQueuedCanonical = Object.prototype.hasOwnProperty.call(
      patch,
      canonical
    );
    const hasLegacy = Object.prototype.hasOwnProperty.call(data, legacy);
    if (!hasCanonical && !hasQueuedCanonical && hasLegacy) {
      patch[canonical] = data[legacy];
    }
  }

  return patch;
}

function queuePatch(
  writer: admin.firestore.BulkWriter,
  ref: admin.firestore.DocumentReference,
  data: admin.firestore.DocumentData,
  mappings: Mapping[],
  dryRun: boolean
): number {
  const patch = canonicalPatch(data, mappings);
  if (Object.keys(patch).length === 0) return 0;

  if (!dryRun) {
    writer.set(ref, patch, { merge: true });
  }
  return 1;
}

async function main(): Promise<void> {
  const dryRun = process.argv.includes('--dry-run');
  const db = admin.firestore();
  const writer = db.bulkWriter();

  let businessesUpdated = 0;
  let servicesUpdated = 0;
  let staffUpdated = 0;

  const businesses = await db.collection('businesses').get();
  for (const business of businesses.docs) {
    businessesUpdated += queuePatch(
      writer,
      business.ref,
      business.data(),
      BUSINESS_MAPPINGS,
      dryRun
    );

    const [services, staff] = await Promise.all([
      business.ref.collection('services').get(),
      business.ref.collection('staff').get(),
    ]);

    for (const service of services.docs) {
      servicesUpdated += queuePatch(
        writer,
        service.ref,
        service.data(),
        SERVICE_MAPPINGS,
        dryRun
      );
    }

    for (const employee of staff.docs) {
      staffUpdated += queuePatch(
        writer,
        employee.ref,
        employee.data(),
        STAFF_MAPPINGS,
        dryRun
      );
    }
  }

  await writer.close();

  const mode = dryRun ? 'DRY RUN' : 'APPLIED';
  console.log(
    `Canonical migration ${mode}: businesses=${businessesUpdated}, services=${servicesUpdated}, staff=${staffUpdated}`
  );
}

main().catch((error: unknown) => {
  console.error('Canonical migration failed:', error);
  process.exitCode = 1;
});
