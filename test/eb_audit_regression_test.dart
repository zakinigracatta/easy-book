import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('EB-01 user-scoped state follows the authenticated uid', () {
    final ownerProviders =
        File('lib/providers/owner_providers.dart').readAsStringSync();
    final appProviders =
        File('lib/providers/app_providers.dart').readAsStringSync();
    final drawer = File('lib/widgets/app_drawer.dart').readAsStringSync();

    expect(ownerProviders, contains('ref.watch(authProvider)'));
    expect(
      appProviders,
      contains("authProvider.select((user) => user?.id ?? '')"),
    );
    expect(appProviders, contains('final String _customerId;'));
    expect(drawer, contains('ref.read(authProvider.notifier).logout()'));
    expect(drawer, contains('ref.invalidate(bookingDraftProvider)'));
    expect(drawer, contains('ref.invalidate(appointmentsProvider)'));
  });

  test('EB-02 published media is not deleted before persistence succeeds', () {
    final service =
        File('lib/screens/business/add_service_screen.dart').readAsStringSync();
    final employee =
        File('lib/screens/business/add_edit_employee_screen.dart')
            .readAsStringSync();
    final business =
        File('lib/screens/business/salon_management_screen.dart')
            .readAsStringSync();

    expect(service, contains('_stagedImageUrls'));
    expect(service, contains('_persistedImageUrl'));
    expect(employee, contains('_stagedMediaUrls'));
    expect(employee, contains('_persistedAvatarUrl'));
    expect(business, contains('_stagedLogoUrls'));
    expect(business, contains('_persistedLogoUrl'));

    expect(
      service.indexOf('saveService(service)'),
      lessThan(service.indexOf('_media.deleteByUrl(_persistedImageUrl)')),
    );
    expect(
      employee.indexOf('saveEmployee(staff)'),
      lessThan(employee.indexOf('_media.deleteByUrl(obsolete)')),
    );
    expect(
      business.indexOf('updateBusiness(updated)'),
      lessThan(business.indexOf('_media.deleteByUrl(oldPersistedLogoUrl)')),
    );
  });

  test('EB-03 verification email is best-effort after persistence', () {
    final source = File('lib/services/auth_service.dart').readAsStringSync();

    expect(source, contains('_createOwnerRegistrationRecords(user)'));
    expect(source, contains('final batch = _firestore.batch()'));
    expect(source, contains('await batch.commit()'));
    expect(source, contains('_sendVerificationBestEffort(firebaseUser)'));
    expect(source, contains('await firebaseUser.sendEmailVerification()'));
  });

  test('EB-04 backend rejects stale customer-approved booking terms', () {
    final client =
        File('lib/services/booking_functions_service.dart').readAsStringSync();
    final server =
        File('functions/src/booking/createBooking.ts').readAsStringSync();

    expect(client, contains("'expectedServicePrice': expectedServicePrice"));
    expect(
      client,
      contains("'expectedDurationMinutes': expectedDurationMinutes"),
    );
    expect(server, contains('BOOKING_TERMS_CHANGED'));
    expect(server, contains('context.servicePrice - expectedServicePrice'));
    expect(
      server,
      contains('context.durationMinutes !== expectedDurationMinutes'),
    );
  });

  test('EB-05 validation supports legacy snake-case leave dates', () {
    final source =
        File('functions/src/booking/bookingValidation.ts').readAsStringSync();

    expect(source, contains('timeOff.startDate ?? timeOff.start_date'));
    expect(source, contains('timeOff.endDate ?? timeOff.end_date'));
    expect(source, contains('readStoredDate('));
  });

  test('EB-06 and EB-07 reschedule is consistent and replay-safe', () {
    final source =
        File('functions/src/booking/rescheduleBooking.ts').readAsStringSync();

    expect(source, contains('durationMinutes: context.durationMinutes'));
    final replayIndex = source.indexOf('idempotentReplay: true');
    final leadTimeIndex = source.indexOf(
      'Customer reschedules require at least 30 minutes lead time.',
    );
    expect(replayIndex, greaterThanOrEqualTo(0));
    expect(leadTimeIndex, greaterThan(replayIndex));
  });

  test('EB-08 walk-in creation has stable idempotency', () {
    final screen =
        File('lib/screens/business/quick_walk_in_booking_screen.dart')
            .readAsStringSync();
    final server =
        File('functions/src/booking/createWalkInBooking.ts')
            .readAsStringSync();

    expect(screen, contains('final String _clientRequestId = const Uuid().v4()'));
    expect(server, contains('optionalRequestId(data.clientRequestId)'));
    expect(server, contains('wb_'));
    expect(server, contains('idempotentReplay: true'));
  });

  test('EB-09 leave staff selection is rebound by id', () {
    final source =
        File('lib/screens/business/employee_time_off_screen.dart')
            .readAsStringSync();

    expect(source, contains('final selectedStaffId = _selectedStaff?.id'));
    expect(source, contains('staff.id == selectedStaffId'));
    expect(source, contains('orElse: () => activeStaff.first'));
  });

  test('EB-10 leave creation checks live appointment conflicts', () {
    final source =
        File('lib/repositories/owner_repository.dart').readAsStringSync();

    expect(source, contains('fetchOwnerBookingsInRange('));
    expect(source, contains('booking.staffId != timeOff.employeeId'));
    expect(source, contains('booking.startDateTime.isBefore(timeOff.endDate)'));
    expect(source, contains('Employee leave conflicts with'));
  });

  test('EB-11 admin analytics prioritizes canonical publication fields', () {
    final source =
        File('lib/screens/admin/analytics_screen.dart').readAsStringSync();

    expect(source, contains("data.containsKey('is_verified')"));
    expect(source, contains("data.containsKey('is_active')"));
    expect(
      source,
      isNot(
        contains(
          "data['is_verified'] == true || data['isVerified'] == true",
        ),
      ),
    );
  });

  test('EB-12 booking confirmation handles auth refresh failures', () {
    final source =
        File('lib/screens/customer/booking_confirmation_screen.dart')
            .readAsStringSync();

    expect(source, contains('await currentUser.reload()'));
    expect(source, contains('on FirebaseAuthException'));
    expect(source, contains('Unable to refresh your sign-in session'));
  });

  test('EB-13 availability batches teams beyond server limit', () {
    final source =
        File('lib/services/availability_service.dart').readAsStringSync();

    expect(source, contains('const maxStaffPerRequest = 50'));
    expect(source, contains('offset += maxStaffPerRequest'));
    expect(source, contains('normalizedStaffIds.sublist(offset, endOffset)'));
    expect(source, contains('occupied.putIfAbsent'));
  });

  test('EB-14 large customer and owner lists use bounded pages', () {
    final businesses =
        File('lib/repositories/business_repository.dart').readAsStringSync();
    final owner =
        File('lib/repositories/owner_repository.dart').readAsStringSync();
    final admin =
        File('lib/screens/admin/users_management_screen.dart')
            .readAsStringSync();

    expect(businesses, contains('fetchBusinessesPage('));
    expect(businesses, contains('.limit(safePageSize)'));
    expect(owner, contains('fetchOwnerBookingsPage('));
    expect(owner, contains('.limit(safePageSize)'));
    expect(admin, contains('static const _pageSize = 50'));
    expect(admin, contains('startAfterDocument(_cursor!)'));
  });

  test('EB-15 booking action routes carry booking id', () {
    final router = File('lib/routes/app_router.dart').readAsStringSync();
    final bookings =
        File('lib/screens/customer/my_bookings_screen.dart').readAsStringSync();

    expect(router, contains("path: '/booking-details/:bookingId'"));
    expect(router, contains("path: '/reschedule-booking/:bookingId'"));
    expect(router, contains("path: '/cancel-booking/:bookingId'"));
    expect(bookings, contains("'/booking-details/"));
    expect(bookings, contains("'/reschedule-booking/"));
    expect(bookings, contains("'/cancel-booking/"));
  });

  test('EB-16 expense mutations invalidate today profit summary', () {
    final source =
        File('lib/screens/business/owner_expenses_screen.dart')
            .readAsStringSync();

    expect(
      RegExp(r'ref\.invalidate\(ownerTodayProfitAndLossProvider\)')
          .allMatches(source)
          .length,
      greaterThanOrEqualTo(2),
    );
  });
}
