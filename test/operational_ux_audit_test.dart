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
    expect(source, contains('sort((a, b) => a.startDateTime.compareTo(b.startDateTime))'));
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

  test('admin shell retains responsive compact navigation', () {
    final source =
        File('lib/features/admin/admin_portal_shell.dart').readAsStringSync();

    expect(source, contains('MediaQuery.sizeOf(context).width >= 1050'));
    expect(source, contains('_showCompactMenu'));
    expect(source, contains("context.go(item.route)"));
  });
}
