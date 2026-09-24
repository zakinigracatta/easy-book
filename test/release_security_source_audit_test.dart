import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('owner business resolution does not probe businesses/{uid} first', () {
    final source =
        File('lib/providers/owner_providers.dart').readAsStringSync();

    expect(source, contains(".where('ownerId', isEqualTo: user.uid)"));
    expect(source, contains(".where('owner_id', isEqualTo: user.uid)"));
    expect(
      source,
      isNot(contains(".collection('businesses')\n      .doc(user.uid)\n      .get()")),
    );
  });

  test('public availability is range-scoped and active-staff scoped', () {
    final source = File(
      'functions/src/booking/getAvailabilityBlocks.ts',
    ).readAsStringSync();

    expect(source, contains('startAt and endAt are required'));
    expect(source, contains('activeStaffIdSet'));
    expect(source, contains('activeStaffIds'));
    expect(source, contains('businessStatus !== \'open\''));
    expect(source, isNot(contains('id: doc.id')));
  });

  test('any-specialist selection is server-owned and atomic', () {
    final create = File(
      'functions/src/booking/createBooking.ts',
    ).readAsStringSync();
    final reschedule = File(
      'functions/src/booking/rescheduleBooking.ts',
    ).readAsStringSync();
    final resolver = File(
      'functions/src/booking/staffResolution.ts',
    ).readAsStringSync();

    expect(create, contains('resolveAnyAvailableStaff'));
    expect(reschedule, contains('resolveAnyAvailableStaff'));
    expect(resolver, contains('transaction.get(staffQuery)'));
    expect(resolver, contains("db.collection('booking_slots').doc(lock.lockId)"));
    expect(resolver, contains('NO_SPECIALIST_AVAILABLE'));
  });

  test('booking backend requires explicit active staff', () {
    final source =
        File('functions/src/booking/bookingValidation.ts').readAsStringSync();

    expect(
      source,
      contains('(staffData.is_active ?? staffData.isActive) !== true'),
    );
    expect(source, contains('STAFF_SCHEDULE_NOT_CONFIGURED'));
    expect(source, contains('Object.keys(weeklySchedule'));
    expect(source, contains('nextLocalMidnightMs(endDate, timeZone)'));
  });

  test('user wallet balance remains server-owned in Firestore rules', () {
    final source = File('firestore.rules').readAsStringSync();

    expect(
      source,
      contains(
        "(!('wallet_balance' in request.resource.data) || request.resource.data.wallet_balance == 0)",
      ),
    );
    expect(
      source,
      isNot(
        contains(
          "affectedKeys().hasOnly(['role', 'email'])",
        ),
      ),
    );
  });

  test('business media reads are gated by publication or privileged access', () {
    final source = File('storage.rules').readAsStringSync();

    expect(source, contains('function canReadBusinessAsset(businessId)'));
    expect(
      RegExp(
        r'match /businesses/\{businessId\}/profile/\{allPaths=\*\*\} \{[\s\S]*?allow read: if canReadBusinessAsset\(businessId\);',
      ).hasMatch(source),
      isTrue,
    );
    expect(
      RegExp(
        r'match /businesses/\{businessId\}/gallery/\{imageId\}/\{fileName\} \{[\s\S]*?allow read: if canReadBusinessAsset\(businessId\);',
      ).hasMatch(source),
      isTrue,
    );
  });

  test('runtime booking and owner flows wait for authoritative state', () {
    final serviceSource =
        File('lib/screens/business/add_service_screen.dart').readAsStringSync();
    final walkInSource = File(
      'lib/screens/business/quick_walk_in_booking_screen.dart',
    ).readAsStringSync();

    expect(
      serviceSource,
      contains('await ref.read(currentBusinessIdProvider.future)'),
    );
    expect(
      walkInSource,
      contains('await ref.read(currentBusinessIdProvider.future)'),
    );
    expect(walkInSource, contains('_nextQuarterHour'));
    expect(walkInSource, contains('picked.minute % 15 != 0'));
    expect(walkInSource, contains('BusinessClock.wallClock'));
  });

  test('admin approvals include legacy camelCase publication fields', () {
    final source =
        File('lib/screens/admin/salon_approval_screen.dart').readAsStringSync();

    expect(source, contains("data['is_verified'] == true"));
    expect(source, contains("data['isVerified'] == true"));
    expect(source, contains("data['is_active'] == true"));
    expect(source, contains("data['isActive'] == true"));
    expect(source, isNot(contains(".where('is_verified', isEqualTo: false)")));
  });

  test('owner schedule and promotion forms reject invalid runtime state', () {
    final businessHoursSource = File(
      'lib/screens/business/business_working_hours_screen.dart',
    ).readAsStringSync();
    final staffScheduleSource = File(
      'lib/screens/business/employee_schedule_screen.dart',
    ).readAsStringSync();
    final promotionSource = File(
      'lib/screens/business/promotion_management_screen.dart',
    ).readAsStringSync();

    expect(businessHoursSource, contains('_workingHoursAreValid()'));
    expect(staffScheduleSource, contains('_scheduleIsValid()'));
    expect(
      promotionSource,
      contains('await ref.read(currentBusinessIdProvider.future)'),
    );
    expect(promotionSource, isNot(contains('?? 20.0')));
    expect(promotionSource, contains('discount > 100'));
  });

  test('service and staff detail booking flows bind to their real business', () {
    final serviceSource = File(
      'lib/screens/customer/service_details_screen.dart',
    ).readAsStringSync();
    final staffSource = File(
      'lib/screens/customer/staff_profile_screen.dart',
    ).readAsStringSync();

    expect(serviceSource, contains('businessName: business.name'));
    expect(staffSource, contains('businessName: business.name'));
    expect(serviceSource, contains('BookingDraft('));
    expect(staffSource, contains('BookingDraft('));
  });

  test('protected customer routes preserve their post-login destination', () {
    final source = File('lib/routes/app_router.dart').readAsStringSync();

    expect(
      source,
      contains('NavigationService().setPendingRoute(state.matchedLocation)'),
    );
    expect(source, contains("redirectTarget == '/login'"));
  });

  test('owner profile updates avoid protected business fields', () {
    final source =
        File('lib/repositories/owner_repository.dart').readAsStringSync();

    expect(source, contains("doc(business.id).update({"));
    expect(
      source,
      isNot(contains(".set(business.toJson(), SetOptions(merge: true))")),
    );
  });

  test('customer business details include real gallery subcollection uploads', () {
    final source =
        File('lib/repositories/business_repository.dart').readAsStringSync();

    expect(source, contains(".collection('gallery')"));
    expect(source, contains('GalleryImageModel.fromJson'));
    expect(source, contains('business.copyWith(galleryUrls: galleryUrls)'));
  });

  test('owner dashboard only shows future bookings as upcoming', () {
    final source = File(
      'lib/screens/business/owner_dashboard_screen.dart',
    ).readAsStringSync();

    expect(source, contains('localStart.isAfter(now)'));
    expect(
      source,
      contains('a.startDateTime.compareTo(b.startDateTime)'),
    );
    expect(source, contains('BusinessClock.inTimeZone'));
  });

  test('owner calendar passes selected date into walk-in booking', () {
    final calendarSource = File(
      'lib/screens/business/booking_calendar_screen.dart',
    ).readAsStringSync();
    final routerSource = File('lib/routes/app_router.dart').readAsStringSync();

    expect(
      calendarSource,
      contains("context.push('/quick-walk-in', extra: effectiveSelectedDate)"),
    );
    expect(
      routerSource,
      contains('QuickWalkInBookingScreen(initialDate: state.extra as DateTime?)'),
    );
  });

  test('walk-in creation is not blocked by the online-booking toggle', () {
    final validationSource = File(
      'functions/src/booking/bookingValidation.ts',
    ).readAsStringSync();
    final walkInSource = File(
      'functions/src/booking/createWalkInBooking.ts',
    ).readAsStringSync();

    expect(
      validationSource,
      contains('requireAcceptingBookings?: boolean'),
    );
    expect(
      walkInSource,
      contains('requireAcceptingBookings: false'),
    );
    expect(
      walkInSource,
      contains('requireVerifiedBusiness: false'),
    );
  });

  test('customer booking prefers authoritative Firestore profile identity', () {
    final source = File(
      'functions/src/booking/createBooking.ts',
    ).readAsStringSync();

    expect(source, contains("db.collection('users').doc(customerId)"));
    expect(source, contains('userData.full_name ?? userData.name'));
    expect(source, contains("cleanText(userData.phone, 40)"));
  });

  test('reschedule retries return idempotent success instead of false failure', () {
    final source = File(
      'functions/src/booking/rescheduleBooking.ts',
    ).readAsStringSync();

    expect(source, contains('idempotentReplay: true'));
    expect(source, contains('idempotentReplay: false'));
    expect(source, isNot(contains('NO_RESCHEDULE_CHANGE')));
  });

  test('owner reschedules are not blocked by the public booking toggle', () {
    final source = File(
      'functions/src/booking/rescheduleBooking.ts',
    ).readAsStringSync();

    expect(
      source,
      contains("requireAcceptingBookings: actor === 'customer'"),
    );
    expect(
      source,
      contains("requireVerifiedBusiness: actor === 'customer'"),
    );
  });

  test('customer reschedules fail closed when business approval is withdrawn', () {
    final validationSource = File(
      'functions/src/booking/bookingValidation.ts',
    ).readAsStringSync();
    final rescheduleSource = File(
      'functions/src/booking/rescheduleBooking.ts',
    ).readAsStringSync();

    expect(
      validationSource,
      contains('requireVerifiedBusiness?: boolean'),
    );
    expect(
      validationSource,
      contains('BUSINESS_NOT_VERIFIED'),
    );
    expect(
      rescheduleSource,
      contains("requireVerifiedBusiness: actor === 'customer'"),
    );
  });
  test('legacy canonical migration never overwrites existing canonical fields', () {
    final migration = File(
      'functions/src/admin/migrateCanonicalFields.ts',
    ).readAsStringSync();

    expect(
      migration,
      contains('!hasCanonical && !hasQueuedCanonical && hasLegacy'),
    );
    expect(migration, contains("['is_verified', 'isVerified']"));
    expect(migration, contains("['is_active', 'isActive']"));
    expect(migration, contains("['is_bookable', 'isBookable']"));
    expect(migration, contains("['business_id', 'businessId']"));
    expect(migration, contains("['review_count', 'reviewCount']"));
    expect(migration, contains('hasQueuedCanonical'));
    expect(migration, contains("process.argv.includes('--dry-run')"));
  });


}
