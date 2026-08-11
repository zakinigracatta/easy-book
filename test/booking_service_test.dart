import 'package:flutter_test/flutter_test.dart';
import 'package:easy_book/services/booking_service.dart';
import 'package:easy_book/models/booking_model.dart';
import 'package:easy_book/core/domain_exceptions.dart';

void main() {
  group('BookingService Unit Tests', () {
    test('1. Validates canonical 15-minute start alignment correctly', () {
      final validStart = DateTime(2026, 8, 17, 10, 15, 0, 0);
      expect(() => BookingService.validateCanonical15MinAlignment(validStart),
          returnsNormally);

      final invalidStart = DateTime(2026, 8, 17, 10, 17, 0, 0);
      expect(() => BookingService.validateCanonical15MinAlignment(invalidStart),
          throwsA(isA<InvalidBookingTimeException>()));
    });

    test(
        '2. Generates correct 15-minute interval lock IDs for continuous duration',
        () {
      final start = DateTime(2026, 8, 17, 10, 0);
      final end = DateTime(
          2026, 8, 17, 10, 45); // 45 minutes = 3 buckets (10:00, 10:15, 10:30)

      final lockIds =
          BookingService.generateIntervalSlotLockIds('biz1', 'st1', start, end);

      expect(lockIds.length, equals(3));
      expect(lockIds[0], contains('biz1_st1_'));
    });

    test('3. Enforces valid booking status transitions', () {
      // Customer transitions
      expect(
        BookingService.canTransitionBookingStatus(
          from: BookingStatus.pending,
          to: BookingStatus.cancelled,
          actorRole: 'customer',
        ),
        isTrue,
      );

      expect(
        BookingService.canTransitionBookingStatus(
          from: BookingStatus.pending,
          to: BookingStatus.completed,
          actorRole: 'customer',
        ),
        isFalse,
      );

      // Owner transitions
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
          from: BookingStatus.completed,
          to: BookingStatus.pending,
          actorRole: 'owner',
        ),
        isFalse,
      );
    });
  });
}
