import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
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
    expect(source, contains('firstDate: businessToday.subtract'));
    expect(source, contains('lastDate: businessToday.add'));
  });

  test('owner business updates rollback optimistic UI on failure', () {
    final providerSource =
        File('lib/providers/owner_providers.dart').readAsStringSync();
    final dashboardSource =
        File('lib/screens/business/owner_dashboard_screen.dart').readAsStringSync();

    expect(providerSource, contains('final previous = state;'));
    expect(providerSource, contains('state = previous;'));
    expect(dashboardSource, contains('Unable to update booking availability. Please try again.'));
  });

  test('admin shell retains responsive compact navigation', () {
    final source =
        File('lib/features/admin/admin_portal_shell.dart').readAsStringSync();

    expect(source, contains('MediaQuery.sizeOf(context).width >= 1050'));
    expect(source, contains('_showCompactMenu'));
    expect(source, contains("context.go(item.route)"));
  });
}
