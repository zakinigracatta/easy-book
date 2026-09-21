import 'package:flutter_test/flutter_test.dart';
import 'package:easy_book/models/service_model.dart';
import 'package:easy_book/providers/app_providers.dart';

void main() {
  group('BookingDraft pricing', () {
    test('zero discount uses the regular service price', () {
      final service = ServiceModel(
        id: 'srv_1',
        salonId: 'biz_1',
        name: 'Haircut',
        price: 100,
        discountPrice: 0,
        duration: '30 min',
        durationMinutes: 30,
      );

      final draft = BookingDraft(selectedServices: [service]);

      expect(service.effectivePrice, 100);
      expect(draft.totalPrice, 100);
    });

    test('valid positive discount is used in the booking total', () {
      final service = ServiceModel(
        id: 'srv_1',
        salonId: 'biz_1',
        name: 'Haircut',
        price: 100,
        discountPrice: 80,
        duration: '30 min',
        durationMinutes: 30,
      );

      final draft = BookingDraft(selectedServices: [service]);

      expect(service.effectivePrice, 80);
      expect(draft.totalPrice, 80);
    });

    test('discount greater than the regular price is ignored', () {
      final service = ServiceModel(
        id: 'srv_1',
        salonId: 'biz_1',
        name: 'Haircut',
        price: 100,
        discountPrice: 120,
        duration: '30 min',
        durationMinutes: 30,
      );

      final draft = BookingDraft(selectedServices: [service]);

      expect(service.effectivePrice, 100);
      expect(draft.totalPrice, 100);
    });
  });

  group('BookingDraft downstream invalidation', () {
    test('clearing staff selection also clears resolved staff and schedule', () {
      final draft = BookingDraft(
        businessId: 'biz_1',
        businessName: 'Salon',
        serviceId: 'srv_1',
        serviceName: 'Haircut',
        staffId: 'staff_1',
        staffName: 'Alex',
        resolvedStaffId: 'staff_1',
        resolvedStaffName: 'Alex',
        date: DateTime(2026, 9, 22),
        timeSlot: '10:00 AM',
        resolvedStartAt: DateTime(2026, 9, 22, 10),
      );

      final updated = draft.copyWith(
        clearStaffSelection: true,
        clearSchedule: true,
      );

      expect(updated.staffId, isNull);
      expect(updated.staffName, isNull);
      expect(updated.resolvedStaffId, isNull);
      expect(updated.resolvedStaffName, isNull);
      expect(updated.date, isNull);
      expect(updated.timeSlot, isNull);
      expect(updated.resolvedStartAt, isNull);
    });

    test('replacing date while clearing schedule keeps only the new date', () {
      final draft = BookingDraft(
        date: DateTime(2026, 9, 22),
        timeSlot: '10:00 AM',
        resolvedStartAt: DateTime(2026, 9, 22, 10),
      );
      final nextDate = DateTime(2026, 9, 23);

      final updated = draft.copyWith(
        date: nextDate,
        clearSchedule: true,
      );

      expect(updated.date, nextDate);
      expect(updated.timeSlot, isNull);
      expect(updated.resolvedStartAt, isNull);
    });
  });
}
