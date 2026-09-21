import 'dart:io';

import 'package:easy_book/models/booking_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('booking model preserves any-specialist preference', () {
    final booking = BookingModel(
      id: 'booking_1',
      customerId: 'customer_1',
      customerName: 'Customer',
      businessId: 'business_1',
      businessName: 'Business',
      serviceId: 'service_1',
      serviceName: 'Haircut',
      servicePrice: 75,
      staffId: 'staff_1',
      staffName: 'Alex',
      startDateTime: DateTime(2026, 9, 25, 10),
      endDateTime: DateTime(2026, 9, 25, 10, 30),
      status: BookingStatus.pending,
      anySpecialist: true,
    );

    final serialized = booking.toJson();
    final restored = BookingModel.fromJson(serialized);

    expect(serialized['anySpecialist'], isTrue);
    expect(restored.anySpecialist, isTrue);
  });

  test('service changes clear stale specialist state at customer entry points', () {
    final serviceScreen =
        File('lib/screens/customer/booking_service_screen.dart').readAsStringSync();
    final salonDetails =
        File('lib/screens/customer/salon_details_screen.dart').readAsStringSync();
    final serviceDetails =
        File('lib/screens/customer/service_details_screen.dart').readAsStringSync();

    expect(
      serviceScreen,
      contains('currentDraft.serviceId?.isNotEmpty == true'),
    );
    expect(
      serviceScreen,
      contains('currentDraft.serviceId != selected.id'),
    );
    expect(
      salonDetails,
      contains('currentDraft.serviceId != selectedService.id'),
    );
    expect(
      salonDetails,
      contains('currentDraft.serviceId != service.id'),
    );
    expect(
      serviceDetails,
      contains('resetStaffSelection:'),
    );
    expect(
      serviceDetails,
      contains('draft.serviceId != item.id'),
    );
  });

  test('customer booking status labels handle camel-case statuses explicitly', () {
    final source =
        File('lib/screens/customer/my_bookings_screen.dart').readAsStringSync();

    expect(source, contains("BookingStatus.inProgress => 'In Progress'"));
    expect(source, contains("BookingStatus.noShow => 'No Show'"));
    expect(
      source,
      contains(
        'BookingStatus.cancelled || BookingStatus.noShow => AppColors.error',
      ),
    );
    expect(
      source,
      contains(
        'BookingStatus.confirmed || BookingStatus.completed => AppColors.success',
      ),
    );
    expect(
      source,
      isNot(contains(
        'booking.status.name[0].toUpperCase() +',
      )),
    );
  });

  test('customer bookings prioritize the nearest upcoming appointment', () {
    final source =
        File('lib/services/booking_service.dart').readAsStringSync();

    expect(source, contains('final isUpcoming = booking.startDateTime.isAfter(now)'));
    expect(source, contains('return isUpcoming ? 0 : 1;'));
    expect(
      source,
      contains('a.startDateTime.compareTo(b.startDateTime)'),
    );
  });

  test('cancel and reschedule surface domain errors from trusted backend', () {
    final cancel =
        File('lib/screens/customer/cancel_booking_screen.dart').readAsStringSync();
    final reschedule =
        File('lib/screens/customer/reschedule_booking_screen.dart').readAsStringSync();

    expect(cancel, contains('on DomainException catch (e)'));
    expect(cancel, contains('context.tr(e.message)'));
    expect(reschedule, contains('on DomainException catch (e)'));
    expect(reschedule, contains('context.tr(e.message)'));
  });

  test('any-specialist reschedule stays flexible end to end', () {
    final provider = File('lib/providers/app_providers.dart').readAsStringSync();
    final screen =
        File('lib/screens/customer/reschedule_booking_screen.dart').readAsStringSync();
    final client =
        File('lib/services/booking_functions_service.dart').readAsStringSync();
    final createFunction =
        File('functions/src/booking/createBooking.ts').readAsStringSync();
    final rescheduleFunction =
        File('functions/src/booking/rescheduleBooking.ts').readAsStringSync();

    expect(provider, contains('bool anySpecialist,'));
    expect(provider, contains('arg.anySpecialist ? null : arg.staffId'));
    expect(provider, contains('anySpecialist: arg.anySpecialist'));
    expect(provider, contains('excludeBookingId: arg.bookingId'));
    expect(screen, contains('bookingId: booking.id'));

    expect(screen, contains('booking.anySpecialist'));
    expect(screen, contains('booking.anySpecialist ? null : booking.staffId'));
    expect(screen, isNot(contains('slot.availableStaffIds.first')));
    expect(screen, contains('newStaffId: newStaffId'));

    expect(client, contains("'anySpecialist': anySpecialist"));
    expect(client, contains("'newStaffId': newStaffId.trim()"));

    expect(
      createFunction,
      contains('const anySpecialist = data.anySpecialist === true;'),
    );
    expect(createFunction, contains('resolveAnyAvailableStaff'));
    expect(createFunction, contains('staffId: resolvedStaffId'));

    expect(
      rescheduleFunction,
      contains("bookingData.anySpecialist === true"),
    );
    expect(rescheduleFunction, contains('resolveAnyAvailableStaff'));
    expect(
      rescheduleFunction,
      contains("STAFF_CHANGE_NOT_ALLOWED"),
    );
    expect(rescheduleFunction, contains('staffId: targetStaffId'));
    expect(rescheduleFunction, contains('NO_RESCHEDULE_CHANGE'));
    expect(client, contains("msg.contains('NO_RESCHEDULE_CHANGE')"));
  });
  test('customer booking retries use a stable idempotency key', () {
    final confirmation = File(
      'lib/screens/customer/booking_confirmation_screen.dart',
    ).readAsStringSync();
    final client = File(
      'lib/services/booking_functions_service.dart',
    ).readAsStringSync();
    final backend = File(
      'functions/src/booking/createBooking.ts',
    ).readAsStringSync();

    expect(confirmation, contains('final String _clientRequestId = const Uuid().v4();'));
    expect(confirmation, contains('clientRequestId: _clientRequestId'));
    expect(client, contains("'clientRequestId': clientRequestId.trim()"));
    expect(backend, contains("createHash('sha256')"));
    expect(backend, contains('IDEMPOTENCY_KEY_REUSED'));
    expect(backend, contains('idempotentReplay: true'));

    final replayLookup = backend.indexOf('if (clientRequestId) {');
    final leadTimeCheck = backend.indexOf('const minimumLeadTimeMs');
    expect(replayLookup, greaterThanOrEqualTo(0));
    expect(leadTimeCheck, greaterThan(replayLookup));
  });

  test('any-specialist UI does not promise a provisional employee', () {
    final summary = File(
      'lib/screens/customer/booking_summary_screen.dart',
    ).readAsStringSync();
    final confirmation = File(
      'lib/screens/customer/booking_confirmation_screen.dart',
    ).readAsStringSync();

    expect(summary, contains("if (draft.anySpecialist)"));
    expect(confirmation, contains("if (draft.anySpecialist)"));
    expect(summary, contains("context.tr('Any Available Specialist')"));
    expect(confirmation, contains("context.tr('Any Available Specialist')"));
  });

  test('customer minimum lead time is enforced on trusted backend', () {
    final createFunction =
        File('functions/src/booking/createBooking.ts').readAsStringSync();
    final rescheduleFunction =
        File('functions/src/booking/rescheduleBooking.ts').readAsStringSync();
    final client =
        File('lib/services/booking_functions_service.dart').readAsStringSync();

    expect(createFunction, contains('START_TIME_TOO_SOON'));
    expect(createFunction, contains('30 * 60 * 1000'));
    expect(rescheduleFunction, contains("actor === 'customer'"));
    expect(rescheduleFunction, contains('START_TIME_TOO_SOON'));
    expect(client, contains("msg.contains('START_TIME_TOO_SOON')"));
  });

  test('any-specialist legacy flag cannot override current explicit false', () {
    final model = File('lib/models/booking_model.dart').readAsStringSync();
    final backend = File(
      'functions/src/booking/rescheduleBooking.ts',
    ).readAsStringSync();

    expect(model, contains("json['anySpecialist'] is bool"));
    expect(
      backend,
      contains("typeof bookingData.anySpecialist === 'boolean'"),
    );
    expect(
      backend,
      isNot(contains(
        "bookingData.anySpecialist === true || bookingData.any_specialist === true",
      )),
    );
  });


  test('cancel and reschedule enforce verified email on trusted backend', () {
    for (final path in [
      'functions/src/booking/cancelBooking.ts',
      'functions/src/booking/rescheduleBooking.ts',
    ]) {
      final source = File(path).readAsStringSync();
      expect(source, contains('request.auth.token.email_verified !== true'));
      expect(source, contains('EMAIL_NOT_VERIFIED'));
    }
  });


}
