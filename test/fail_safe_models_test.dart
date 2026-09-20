import 'package:easy_book/models/booking_model.dart';
import 'package:easy_book/models/business_model.dart';
import 'package:easy_book/models/service_model.dart';
import 'package:easy_book/models/working_hours_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Fail-safe model parsing', () {
    test('missing business working hours parse as closed', () {
      final business = BusinessModel.fromJson({
        'id': 'biz_missing_hours',
        'name': 'Missing Hours',
        'category': 'Salon',
        'address': '',
        'rating': 0,
        'review_count': 0,
        'image_url': '',
        'description': '',
        'owner_id': 'owner_1',
        'is_active': true,
        'is_verified': true,
        'business_status': 'open',
        'accepting_bookings': true,
      });

      expect(
        business.workingHours.schedule.values.every((day) => day.isClosed),
        isTrue,
      );
    });

    test('partial working hours keep missing days closed', () {
      final hours = WorkingHoursModel.fromJson({
        'monday': {
          'open': '09:00 AM',
          'close': '06:00 PM',
          'is_closed': false,
        },
      });

      expect(hours.schedule['Monday']?.isClosed, isFalse);
      expect(hours.schedule['Tuesday']?.isClosed, isTrue);
      expect(hours.schedule['Sunday']?.isClosed, isTrue);
    });


    test('missing business active flag parses as inactive', () {
      final business = BusinessModel.fromJson({
        'id': 'biz_missing_active',
        'name': 'Missing Active Flag',
        'category': 'Salon',
        'address': '',
        'rating': 0,
        'review_count': 0,
        'image_url': '',
        'description': '',
        'owner_id': 'owner_1',
        'is_verified': true,
        'business_status': 'open',
        'accepting_bookings': true,
      });

      expect(business.isActive, isFalse);
    });

    test('incomplete service records fail closed for booking', () {
      final service = ServiceModel.fromJson({
        'id': 'srv_incomplete',
        'business_id': 'biz_1',
        'name': 'Incomplete Service',
      });

      expect(service.isActive, isFalse);
      expect(service.isBookable, isFalse);
      expect(service.durationMinutes, 0);
    });

    test('complete service record stays bookable', () {
      final service = ServiceModel.fromJson({
        'id': 'srv_complete',
        'business_id': 'biz_1',
        'name': 'Haircut',
        'price': 100,
        'duration_minutes': 30,
        'is_active': true,
        'is_bookable': true,
      });

      expect(service.isActive, isTrue);
      expect(service.isBookable, isTrue);
      expect(service.durationMinutes, 30);
    });

    test('booking parser does not invent entity IDs or current timestamps', () {
      final booking = BookingModel.fromJson({
        'status': 'pending',
      });

      expect(booking.businessId, isEmpty);
      expect(booking.serviceId, isEmpty);
      expect(booking.staffId, isEmpty);
      expect(booking.businessName, equals('Business'));
      expect(
        booking.startDateTime.millisecondsSinceEpoch,
        equals(0),
      );
      expect(
        booking.endDateTime.millisecondsSinceEpoch,
        equals(0),
      );
    });
  });
}
