import 'dart:io';

import 'package:easy_book/models/booking_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('booking model preserves authoritative currency and timezone', () {
    final booking = BookingModel(
      id: 'booking_1',
      customerId: 'customer_1',
      customerName: 'Customer',
      businessId: 'business_1',
      businessName: 'Business',
      serviceId: 'service_1',
      serviceName: 'Service',
      servicePrice: 42.5,
      currency: 'USD',
      timeZone: 'America/New_York',
      staffId: 'staff_1',
      staffName: 'Alex',
      startDateTime: DateTime.utc(2026, 9, 25, 14),
      endDateTime: DateTime.utc(2026, 9, 25, 14, 30),
      status: BookingStatus.pending,
    );

    final restored = BookingModel.fromJson(booking.toJson());

    expect(restored.currency, 'USD');
    expect(restored.timeZone, 'America/New_York');
    expect(restored.toJson()['currency'], 'USD');
    expect(restored.toJson()['timeZone'], 'America/New_York');
  });

  test('legacy bookings retain safe metadata defaults', () {
    final booking = BookingModel.fromJson({
      'id': 'legacy',
      'customerId': 'customer',
      'businessId': 'business',
      'serviceId': 'service',
      'servicePrice': 50,
      'staffId': 'staff',
      'startDateTime': '2026-09-25T10:00:00Z',
      'endDateTime': '2026-09-25T10:30:00Z',
    });

    expect(booking.currency, 'AED');
    expect(booking.timeZone, 'Asia/Dubai');
  });

  test('trusted booking functions persist currency and timezone', () {
    final create =
        File('functions/src/booking/createBooking.ts').readAsStringSync();
    final walkIn =
        File('functions/src/booking/createWalkInBooking.ts').readAsStringSync();

    for (final source in [create, walkIn]) {
      expect(source, contains('currency: context.currency'));
      expect(source, contains('timeZone: context.timeZone'));
    }
  });

  test('customer and owner booking UI use booking metadata', () {
    final myBookings =
        File('lib/screens/customer/my_bookings_screen.dart').readAsStringSync();
    final details =
        File('lib/screens/customer/booking_details_screen.dart').readAsStringSync();
    final ownerCard =
        File('lib/widgets/business/owner_booking_card.dart').readAsStringSync();
    final summary =
        File('lib/screens/customer/booking_summary_screen.dart').readAsStringSync();

    expect(myBookings, contains('booking.timeZone'));
    expect(myBookings, contains('currency: booking.currency'));
    expect(details, contains('booking.timeZone'));
    expect(details, contains('currency: booking.currency'));
    expect(ownerCard, contains('booking.timeZone'));
    expect(ownerCard, contains('currency: booking.currency'));
    expect(summary, contains('currency: totalCurrency'));
  });


  test('reschedule response preserves backend-resolved specialist metadata', () {
    final source =
        File('lib/services/booking_functions_service.dart').readAsStringSync();

    expect(source, contains("resData['staffId']"));
    expect(source, contains("resData['staffName']"));
    expect(source, contains('staffId: resolvedStaffId'));
    expect(source, contains('staffName: resolvedStaffName'));
  });
}
