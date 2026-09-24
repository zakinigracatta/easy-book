import 'package:easy_book/models/booking_model.dart';
import 'package:easy_book/services/booking_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('owner transition policy mirrors callable backend', () {
    expect(
      BookingService.canTransitionBookingStatus(
        from: BookingStatus.pending,
        to: BookingStatus.confirmed,
        actorRole: 'owner',
      ),
      isTrue,
    );
    expect(
      BookingService.canTransitionBookingStatus(
        from: BookingStatus.confirmed,
        to: BookingStatus.inProgress,
        actorRole: 'owner',
      ),
      isTrue,
    );
    expect(
      BookingService.canTransitionBookingStatus(
        from: BookingStatus.confirmed,
        to: BookingStatus.noShow,
        actorRole: 'owner',
      ),
      isTrue,
    );
    expect(
      BookingService.canTransitionBookingStatus(
        from: BookingStatus.pending,
        to: BookingStatus.noShow,
        actorRole: 'owner',
      ),
      isFalse,
    );
    expect(
      BookingService.canTransitionBookingStatus(
        from: BookingStatus.arrived,
        to: BookingStatus.completed,
        actorRole: 'owner',
      ),
      isFalse,
    );
  });

  test('customer can cancel only pending or confirmed bookings', () {
    for (final from in [BookingStatus.pending, BookingStatus.confirmed]) {
      expect(
        BookingService.canTransitionBookingStatus(
          from: from,
          to: BookingStatus.cancelled,
          actorRole: 'customer',
        ),
        isTrue,
      );
    }

    for (final from in [
      BookingStatus.arrived,
      BookingStatus.inProgress,
      BookingStatus.completed,
      BookingStatus.noShow,
    ]) {
      expect(
        BookingService.canTransitionBookingStatus(
          from: from,
          to: BookingStatus.cancelled,
          actorRole: 'customer',
        ),
        isFalse,
      );
    }
  });
}
