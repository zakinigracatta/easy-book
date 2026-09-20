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

  group('BookingDraft downstream reset', () {
    test('changing service clears stale specialist and appointment state', () {
      final draft = BookingDraft(
        businessId: 'biz_1',
        businessName: 'Salon',
        serviceId: 'srv_old',
        serviceName: 'Old service',
        staffId: 'staff_1',
        staffName: 'Alex',
        resolvedStaffId: 'staff_1',
        resolvedStaffName: 'Alex',
        date: DateTime(2026, 9, 22),
        timeSlot: '10:00 AM',
        resolvedStartAt: DateTime(2026, 9, 22, 10),
      );

      final updated = draft.copyWith(
        serviceId: 'srv_new',
        serviceName: 'New service',
        resetStaffSelection: true,
        resetAppointmentSelection: true,
      );

      expect(updated.serviceId, 'srv_new');
      expect(updated.staffId, isNull);
      expect(updated.staffName, isNull);
      expect(updated.resolvedStaffId, isNull);
      expect(updated.resolvedStaffName, isNull);
      expect(updated.date, isNull);
      expect(updated.timeSlot, isNull);
      expect(updated.resolvedStartAt, isNull);
    });

    test('changing date keeps the new date but clears stale time resolution', () {
      final draft = BookingDraft(
        businessId: 'biz_1',
        businessName: 'Salon',
        staffId: 'staff_1',
        staffName: 'Alex',
        resolvedStaffId: 'staff_1',
        resolvedStaffName: 'Alex',
        date: DateTime(2026, 9, 22),
        timeSlot: '10:00 AM',
        resolvedStartAt: DateTime(2026, 9, 22, 10),
      );
      final newDate = DateTime(2026, 9, 23);

      final updated = draft.copyWith(
        date: newDate,
        resetAppointmentSelection: true,
      );

      expect(updated.date, newDate);
      expect(updated.staffId, 'staff_1');
      expect(updated.staffName, 'Alex');
      expect(updated.resolvedStaffId, isNull);
      expect(updated.resolvedStaffName, isNull);
      expect(updated.timeSlot, isNull);
      expect(updated.resolvedStartAt, isNull);
    });
  });
}
