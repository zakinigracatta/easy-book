import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('admin analytics counts legacy and canonical approval flags', () {
    final source =
        File('lib/screens/admin/analytics_screen.dart').readAsStringSync();

    expect(source, contains("data['is_verified'] == true"));
    expect(source, contains("data['isVerified'] == true"));
    expect(source, contains("data['is_active'] == true"));
    expect(source, contains("data['isActive'] == true"));
    expect(source, isNot(contains(".where('is_verified', isEqualTo: false)")));
  });

  test('booking confirmation fallback resolves business timezone', () {
    final source = File(
      'lib/screens/customer/booking_confirmation_screen.dart',
    ).readAsStringSync();

    expect(
      source,
      contains('businessDetailProvider(businessId).future'),
    );
    expect(source, contains('BusinessClock.wallClock('));
    expect(source, contains('business.timeZone'));
  });

  test('owner promotions use business clock for offer dates', () {
    final source = File(
      'lib/screens/business/promotion_management_screen.dart',
    ).readAsStringSync();

    expect(source, contains('BusinessClock.now(business.timeZone)'));
    expect(source, contains('startDate: businessNow'));
    expect(
      source,
      contains('endDate: businessNow.add(const Duration(days: 30))'),
    );
  });

  test('employee leave dates use business timezone', () {
    final source = File(
      'lib/screens/business/employee_time_off_screen.dart',
    ).readAsStringSync();

    expect(source, contains('BusinessClock.calendarToday(timeZone)'));
    expect(source, contains('BusinessClock.inTimeZone('));
    expect(source, contains('BusinessClock.wallClock('));
    expect(source, isNot(contains('firstDate: DateTime.now()')));
  });

  test('finance report boundaries use the business timezone', () {
    final repositorySource = File(
      'lib/repositories/owner_finance_repository.dart',
    ).readAsStringSync();
    final providerSource = File(
      'lib/providers/owner_finance_providers.dart',
    ).readAsStringSync();
    final screenSource = File(
      'lib/screens/business/owner_finance_screen.dart',
    ).readAsStringSync();
    final expenseSource = File(
      'lib/screens/business/owner_expenses_screen.dart',
    ).readAsStringSync();

    expect(repositorySource, contains("businessData['timeZone']"));
    expect(repositorySource, contains('BusinessClock.wallClock('));
    expect(providerSource, contains('BusinessClock.calendarToday(timeZone)'));
    expect(screenSource, contains('BusinessClock.calendarToday(timeZone)'));
    expect(screenSource, isNot(contains('final now = DateTime.now()')));
    expect(expenseSource, contains('BusinessClock.calendarToday(widget.timeZone)'));
    expect(expenseSource, contains('BusinessClock.wallClock('));
  });
}
