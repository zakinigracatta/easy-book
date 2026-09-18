import 'package:easy_book/models/booking_model.dart';
import 'package:easy_book/models/business_model.dart';
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
