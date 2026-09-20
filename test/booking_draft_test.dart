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
}
