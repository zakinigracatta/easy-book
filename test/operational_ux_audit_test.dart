import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('owner walk-in uses business time and valid booking inputs', () {
    final source =
        File('lib/screens/business/quick_walk_in_booking_screen.dart')
            .readAsStringSync();

    expect(source, contains('BusinessClock.now(timeZone)'));
    expect(source, contains('BusinessClock.wallClock('));
    expect(source, contains('picked.minute % 15 != 0'));
    expect(source, contains('service.isActive && service.isBookable'));
    expect(source, contains('staff.isActive &&'));
    expect(source, contains('staff.serviceIds'));
    expect(source, contains('_selectedService!.effectivePrice'));
    expect(source, contains('_nameController.dispose()'));
    expect(source, isNot(contains('_isNewCustomer')));
    expect(source, isNot(contains('ThemeData.dark()')));
  });

  test('customer search is debounced before repository refresh', () {
    final source =
        File('lib/screens/customer/search_screen.dart').readAsStringSync();

    expect(source, contains('Timer? _searchDebounce;'));
    expect(source, contains('Duration(milliseconds: 300)'));
    expect(source, contains('_searchDebounce?.cancel();'));
  });

  test('booking success copy matches pending backend state', () {
    final source =
        File('lib/screens/customer/booking_success_screen.dart').readAsStringSync();

    expect(source, contains("context.tr('Booking Submitted!')"));
    expect(source, contains('pending confirmation'));
    expect(source, isNot(contains("context.tr('Booking Confirmed!')")));
  });

  test('owner dashboard upcoming list is future-only and timezone-aware', () {
    final source =
        File('lib/screens/business/owner_dashboard_screen.dart').readAsStringSync();

    expect(source, contains('BusinessClock.now(timeZone)'));
    expect(source, contains('BusinessClock.inTimeZone(booking.startDateTime, timeZone)'));
    expect(source, contains('localStart.isAfter(now)'));
    expect(source, contains('booking.status != BookingStatus.noShow'));
    expect(source, contains('a.startDateTime.compareTo(b.startDateTime)'));
  });

  test('owner calendar groups bookings by business timezone', () {
    final source =
        File('lib/screens/business/booking_calendar_screen.dart').readAsStringSync();

    expect(source, contains('BusinessClock.calendarToday(timeZone)'));
    expect(source, contains('BusinessClock.inTimeZone(b.startDateTime, timeZone)'));
    expect(
      source,
      contains("businessToday.subtract(const Duration(days: 90))"),
    );
    expect(source, contains('lastDate: businessToday.add'));
  });

  test('owner booking actions respect backend timing and capabilities', () {
    final cardSource =
        File('lib/widgets/business/owner_booking_card.dart').readAsStringSync();
    final listSource =
        File('lib/screens/business/owner_bookings_screen.dart').readAsStringSync();

    expect(cardSource, contains('final canStartService ='));
    expect(cardSource, contains('onPressed: canStartService'));
    expect(cardSource, contains('if (onRescheduleTap != null)'));
    expect(cardSource, contains("if (!DateTime.now().isBefore(booking.startDateTime))"));
    expect(listSource, isNot(contains("context.push('/booking-calendar')")));
  });

  test('owner dashboard refresh waits for live providers', () {
    final source =
        File('lib/screens/business/owner_dashboard_screen.dart').readAsStringSync();

    expect(source, contains('await Future.wait<void>(['));
    expect(source, contains('loadBusiness()'));
    expect(source, contains('loadBookings()'));
    expect(source, isNot(contains('Future<void>.delayed(Duration.zero)')));
  });

  test('owner business updates rollback optimistic UI on failure', () {
    final providerSource =
        File('lib/providers/owner_providers.dart').readAsStringSync();
    final dashboardSource =
        File('lib/screens/business/owner_dashboard_screen.dart').readAsStringSync();

    final repositoryWriteIndex =
        providerSource.indexOf('await _repo.updateOwnerBusiness(updated);');
    final committedStateIndex = providerSource.indexOf(
      'state = AsyncValue.data(updated);',
      repositoryWriteIndex,
    );

    expect(repositoryWriteIndex, greaterThanOrEqualTo(0));
    expect(committedStateIndex, greaterThan(repositoryWriteIndex));
    expect(
      dashboardSource,
      contains('Unable to update booking availability. Please try again.'),
    );
  });

  test('customer booking recovers stale services and waits for business timezone', () {
    final serviceSource =
        File('lib/screens/customer/booking_service_screen.dart')
            .readAsStringSync();
    final dateSource =
        File('lib/screens/customer/booking_date_screen.dart').readAsStringSync();

    expect(serviceSource, contains('final selectionIsValid ='));
    expect(serviceSource, contains('_selectedServiceId = services.first.id'));
    expect(dateSource, contains('body: businessState.when('));
    expect(dateSource, contains('BusinessClock.calendarToday(business.timeZone)'));
    expect(dateSource, isNot(contains("business?.timeZone ?? 'Asia/Dubai'")));
  });

  test('customer cancel and reschedule preserve safe domain errors', () {
    final cancelSource =
        File('lib/screens/customer/cancel_booking_screen.dart')
            .readAsStringSync();
    final rescheduleSource =
        File('lib/screens/customer/reschedule_booking_screen.dart')
            .readAsStringSync();

    expect(cancelSource, contains('on DomainException catch (e)'));
    expect(cancelSource, contains('context.tr(e.message)'));
    expect(rescheduleSource, contains('on DomainException catch (e)'));
    expect(rescheduleSource, contains('context.tr(e.message)'));
  });

  test('reschedule availability excludes only the current authorized booking', () {
    final screenSource =
        File('lib/screens/customer/reschedule_booking_screen.dart')
            .readAsStringSync();
    final providerSource =
        File('lib/providers/app_providers.dart').readAsStringSync();
    final availabilitySource =
        File('lib/services/availability_service.dart').readAsStringSync();
    final functionSource =
        File('functions/src/booking/getAvailabilityBlocks.ts')
            .readAsStringSync();

    expect(screenSource, contains('bookingId: booking.id'));
    expect(providerSource, contains('excludeBookingId: arg.bookingId'));
    expect(availabilitySource, contains("'excludeBookingId': excludeBookingId.trim()"));
    expect(functionSource, contains('approvedExcludedBookingId'));
    expect(functionSource, contains('booking.customerId === request.auth.uid'));
    expect(functionSource, contains('slotData.bookingId === approvedExcludedBookingId'));
  });

  test('owner employee management keeps staff context and service eligibility', () {
    final listSource =
        File('lib/screens/business/employee_management_screen.dart')
            .readAsStringSync();
    final scheduleSource =
        File('lib/screens/business/employee_schedule_screen.dart')
            .readAsStringSync();
    final editorSource =
        File('lib/screens/business/add_edit_employee_screen.dart')
            .readAsStringSync();

    expect(listSource, contains("'/employee-schedule',"));
    expect(listSource, contains('extra: st.id'));
    expect(scheduleSource, contains('final routeStaffId = GoRouterState.of(context).extra'));
    expect(editorSource, contains('_selectedServiceIds'));
    expect(editorSource, contains('final serviceIdsToSave = loadedServices == null'));
    expect(editorSource, contains('service.isActive &&'));
    expect(editorSource, contains('service.isBookable'));
    expect(editorSource, contains('serviceIds: serviceIdsToSave'));
    expect(editorSource, contains('on DomainException catch (e)'));
    expect(editorSource, contains('extra: _staffId'));
  });

  test('owner service mutations surface failures instead of throwing silently', () {
    final source =
        File('lib/screens/business/services_management_screen.dart')
            .readAsStringSync();

    expect(source, contains('Future<void> _toggleService('));
    expect(source, contains('on DomainException catch (e)'));
    expect(source, contains("context.tr('Service disabled')"));
  });


  test('customer booking horizon is enforced by trusted backend', () {
    final validation = File(
      'functions/src/booking/bookingValidation.ts',
    ).readAsStringSync();
    final create = File(
      'functions/src/booking/createBooking.ts',
    ).readAsStringSync();
    final reschedule = File(
      'functions/src/booking/rescheduleBooking.ts',
    ).readAsStringSync();

    expect(validation, contains('validateMaximumAdvanceDate'));
    expect(validation, contains('START_TIME_TOO_FAR'));
    expect(create, contains('validateMaximumAdvanceDate(requestedStartAt'));
    expect(reschedule, contains("if (actor === 'customer')"));
    expect(reschedule, contains('validateMaximumAdvanceDate(newStartAt'));
  });

  test('owner schedule editor preserves explicit no-working-days state', () {
    final source = File(
      'lib/screens/business/employee_schedule_screen.dart',
    ).readAsStringSync();

    expect(
      source,
      contains(
        'final working = staff.workingDays == null ||\n'
        '          staff.workingDays!.contains(weekday);',
      ),
    );
    expect(
      source,
      isNot(contains('staff.workingDays!.isEmpty ||')),
    );
  });


  test('admin business details honors canonical publication fields first', () {
    final source = File(
      'lib/features/admin/business_details_screen.dart',
    ).readAsStringSync();

    expect(source, contains("business['is_verified'] is bool"));
    expect(source, contains("business['is_active'] is bool"));
    expect(
      source,
      isNot(contains(
        "business['is_verified'] == true || business['isVerified'] == true",
      )),
    );
  });

  test('booking horizon error has specific customer feedback', () {
    final source = File(
      'lib/services/booking_functions_service.dart',
    ).readAsStringSync();

    expect(source, contains("msg.contains('START_TIME_TOO_FAR')"));
    expect(
      source,
      contains('Please select an appointment within the next 60 days.'),
    );
  });

  test('slot lock cleanup verifies booking ownership before deleting', () {
    for (final path in [
      'functions/src/booking/cancelBooking.ts',
      'functions/src/booking/updateBookingStatus.ts',
      'functions/src/booking/rescheduleBooking.ts',
    ]) {
      final source = File(path).readAsStringSync();
      expect(source, contains("lockSnap.data()?.bookingId === bookingId"));
    }
  });


  test('partial owner weekly schedules keep missing days off', () {
    final source = File(
      'lib/screens/business/employee_schedule_screen.dart',
    ).readAsStringSync();

    expect(source, contains('final hasWeeklySchedule = staff.weeklySchedule.isNotEmpty;'));
    expect(source, contains('final working = hasWeeklySchedule'));
    expect(source, contains('? false'));
  });


  test('email verification routes all privileged role variants correctly', () {
    final source = File(
      'lib/screens/auth/verify_email_screen.dart',
    ).readAsStringSync();

    expect(source, contains('profile?.isOwnerRole == true'));
    expect(source, contains('profile?.isAdmin == true'));
    expect(source, contains("context.go('/admin/dashboard')"));
    expect(source, isNot(contains('if (role == UserRole.admin)')));
  });


  test('staff-first customer flow keeps specialist on first service choice', () {
    final bookingService = File(
      'lib/screens/customer/booking_service_screen.dart',
    ).readAsStringSync();
    final serviceDetails = File(
      'lib/screens/customer/service_details_screen.dart',
    ).readAsStringSync();

    expect(
      bookingService,
      contains('currentDraft.serviceId?.isNotEmpty == true'),
    );
    expect(
      serviceDetails,
      contains('draft.serviceId?.isNotEmpty == true'),
    );
  });

  test('reschedule repairs missing overlapping deterministic locks', () {
    final source = File(
      'functions/src/booking/rescheduleBooking.ts',
    ).readAsStringSync();

    expect(source, contains('const missingNewLocks'));
    expect(source, contains('for (const lock of newLockObjects)'));
    expect(source, contains('missingNewLocks.push'));
  });

  test('public availability uses canonical timezone fallback', () {
    final source = File(
      'functions/src/booking/getAvailabilityBlocks.ts',
    ).readAsStringSync();

    expect(source, contains('resolveTimeZone(business.timeZone ?? business.timezone)'));
    expect(source, contains('normalizeInclusiveTimeOffEndMs'));
  });


  test('owner service availability requires active and bookable flags', () {
    final screen = File(
      'lib/screens/business/services_management_screen.dart',
    ).readAsStringSync();
    final provider =
        File('lib/providers/owner_providers.dart').readAsStringSync();
    final repository =
        File('lib/repositories/owner_repository.dart').readAsStringSync();

    expect(screen, contains('service.isActive && service.isBookable'));
    expect(provider, contains('final nextAvailable ='));
    expect(provider, contains('isBookable: nextAvailable'));
    expect(repository, contains("'is_bookable': false"));
  });

  test('admin shell retains responsive compact navigation', () {
    final source =
        File('lib/features/admin/admin_portal_shell.dart').readAsStringSync();

    expect(source, contains('MediaQuery.sizeOf(context).width >= 1050'));
    expect(source, contains('_showCompactMenu'));
    expect(source, contains("context.go(item.route)"));
  });
}
