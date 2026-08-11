import 'package:flutter_test/flutter_test.dart';
import 'package:easy_book/services/booking_availability_engine.dart';
import 'package:easy_book/models/business_model.dart';
import 'package:easy_book/models/service_model.dart';
import 'package:easy_book/models/staff_model.dart';
import 'package:easy_book/models/working_hours_model.dart';
import 'package:easy_book/models/employee_time_off_model.dart';

void main() {
  late BookingAvailabilityEngine engine;
  late BusinessModel testBusiness;
  late ServiceModel testService;
  late StaffModel testStaff;

  setUp(() {
    engine = BookingAvailabilityEngine();
    testBusiness = BusinessModel(
      id: 'biz_1',
      name: 'Test Barber Lounge',
      category: 'Barber',
      address: 'Dubai Marina',
      rating: 4.9,
      reviewCount: 100,
      imageUrl: '',
      description: 'Test Description',
      ownerId: 'owner_1',
      workingHours: WorkingHoursModel.defaultSchedule(),
      isActive: true,
    );

    testService = ServiceModel(
      id: 'srv_1',
      salonId: 'biz_1',
      name: 'Classic Haircut',
      price: 60.0,
      duration: '30 min',
      durationMinutes: 30,
      isActive: true,
    );

    testStaff = StaffModel(
      id: 'st_1',
      businessId: 'biz_1',
      name: 'Ahmed Specialist',
      roleTitle: 'Barber',
      avatarUrl: '',
      rating: 4.9,
      isActive: true,
    );
  });

  group('BookingAvailabilityEngine Unit Tests', () {
    test('1. Computes available slots for normal working day', () async {
      final targetDate = DateTime(2026, 8, 17); // A Monday
      final slots = await engine.computeAvailableSlots(
        business: testBusiness,
        selectedServices: [testService],
        allStaff: [testStaff],
        date: targetDate,
        nowOverride: DateTime(2026, 8, 1, 9, 0),
      );

      expect(slots.isNotEmpty, isTrue);
      expect(slots.first.timeString, equals('09:00 AM'));
    });

    test('2. Returns empty list if business is inactive', () async {
      final inactiveBiz = BusinessModel(
        id: 'biz_1',
        name: 'Inactive Lounge',
        category: 'Barber',
        address: 'Dubai Marina',
        rating: 4.9,
        reviewCount: 100,
        imageUrl: '',
        description: '',
        ownerId: 'owner_1',
        isActive: false,
      );

      final slots = await engine.computeAvailableSlots(
        business: inactiveBiz,
        selectedServices: [testService],
        allStaff: [testStaff],
        date: DateTime(2026, 8, 17),
        nowOverride: DateTime(2026, 8, 1, 9, 0),
      );

      expect(slots.isEmpty, isTrue);
    });

    test('3. Filters out staff who do not support the service', () async {
      final restrictedStaff = StaffModel(
        id: 'st_2',
        businessId: 'biz_1',
        name: 'Facial Specialist Only',
        roleTitle: 'Therapist',
        avatarUrl: '',
        rating: 5.0,
        serviceIds: ['other_srv_id'],
        isActive: true,
      );

      final eligible = BookingAvailabilityEngine.filterEligibleStaff(
        [restrictedStaff],
        [testService],
      );

      expect(eligible.isEmpty, isTrue);
    });

    test('4. Excludes slots during employee time off / leave', () async {
      final targetDate = DateTime(2026, 8, 17); // Monday
      final timeOff = EmployeeTimeOffModel(
        id: 'toff_1',
        employeeId: 'st_1',
        employeeName: 'Ahmed Specialist',
        startDate: DateTime(2026, 8, 17, 0, 0),
        endDate: DateTime(2026, 8, 17, 23, 59),
        reason: 'Vacation',
      );

      final slots = await engine.computeAvailableSlots(
        business: testBusiness,
        selectedServices: [testService],
        allStaff: [testStaff],
        date: targetDate,
        nowOverride: DateTime(2026, 8, 1, 9, 0),
        employeeTimeOffs: [timeOff],
      );

      expect(slots.isEmpty, isTrue);
    });

    test('5. Enforces minimum lead time for today bookings', () async {
      final now = DateTime(2026, 8, 17, 10, 0); // 10:00 AM today
      final slots = await engine.computeAvailableSlots(
        business: testBusiness,
        selectedServices: [testService],
        allStaff: [testStaff],
        date: now,
        nowOverride: now,
      );

      // Lead time cutoff is 10:30 AM (now + 30 mins)
      final earlySlots =
          slots.where((s) => s.startAt.isBefore(DateTime(2026, 8, 17, 10, 30)));
      expect(earlySlots.isEmpty, isTrue);
    });
  });
}
