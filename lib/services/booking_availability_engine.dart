import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../models/business_model.dart';
import '../models/service_model.dart';
import '../models/staff_model.dart';
import '../models/staff_schedule_model.dart';
import '../models/available_slot.dart';
import '../models/employee_time_off_model.dart';
import '../core/domain_exceptions.dart';

class BookingAvailabilityEngine {
  final FirebaseFirestore? _firestore;

  static const int defaultStepMinutes = 15;
  static const int minimumLeadTimeMinutes = 30;
  static const int maxAdvanceBookingDays = 60;

  BookingAvailabilityEngine([FirebaseFirestore? firestore])
      : _firestore = firestore;

  FirebaseFirestore? get _db {
    if (_firestore != null) return _firestore;
    try {
      return FirebaseFirestore.instance;
    } catch (_) {
      return null;
    }
  }

  /// Filters staff who can perform ALL of the selected services.
  static List<StaffModel> filterEligibleStaff(
    List<StaffModel> allStaff,
    List<ServiceModel> selectedServices,
  ) {
    if (selectedServices.isEmpty) return allStaff;
    final selectedServiceIds = selectedServices.map((s) => s.id).toSet();

    return allStaff.where((staff) {
      if (!staff.isActive) return false;
      if (staff.serviceIds.isEmpty) return true;
      return staff.serviceIds.toSet().containsAll(selectedServiceIds);
    }).toList();
  }

  /// Calculates available slots for a given business, selected services, specialist (or any specialist), and date.
  /// Customer availability queries non-sensitive booking_slots to preserve customer privacy.
  Future<List<AvailableSlot>> computeAvailableSlots({
    required BusinessModel business,
    required List<ServiceModel> selectedServices,
    required List<StaffModel> allStaff,
    String? specialistId,
    bool anySpecialist = false,
    required DateTime date,
    DateTime? nowOverride,
    List<BlockedPeriodModel> blockedPeriods = const [],
    List<StaffBreakModel> staffBreaks = const [],
    List<EmployeeTimeOffModel> employeeTimeOffs = const [],
  }) async {
    // 1. Business Operational & Accepting Bookings Check (Blocker 5)
    if (!business.isActive ||
        !business.acceptingBookings ||
        business.businessStatus != 'open' ||
        selectedServices.isEmpty) {
      return [];
    }

    final now = nowOverride ?? DateTime.now();

    // 2. Horizon Check (maxAdvanceBookingDays & Past Date Check)
    final maxDate = DateTime(now.year, now.month, now.day)
        .add(const Duration(days: maxAdvanceBookingDays));
    final targetDateOnly = DateTime(date.year, date.month, date.day);
    if (targetDateOnly.isBefore(DateTime(now.year, now.month, now.day)) ||
        targetDateOnly.isAfter(maxDate)) {
      return [];
    }

    // 3. Business Working Hours Check
    final dayNames = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday'
    ];
    final dayName = dayNames[date.weekday - 1];
    final dailyHours = business.workingHours.schedule[dayName];

    if (dailyHours == null || dailyHours.isClosed) {
      return []; // Closed day
    }

    // Parse business open/close time
    final bOpenMinutes = _parseTimeStringToMinutes(dailyHours.openTime);
    final bCloseMinutes = _parseTimeStringToMinutes(dailyHours.closeTime);

    if (bCloseMinutes <= bOpenMinutes) return [];

    // 4. Filter Eligible Staff
    final eligibleStaff = filterEligibleStaff(allStaff, selectedServices);
    if (eligibleStaff.isEmpty) return [];

    final targetStaffList =
        (specialistId != null && specialistId.isNotEmpty && !anySpecialist)
            ? eligibleStaff.where((s) => s.id == specialistId).toList()
            : eligibleStaff;

    if (targetStaffList.isEmpty) return [];

    // Total Continuous Service Duration
    final totalDurationMinutes = selectedServices.fold(
        0, (runningTotal, s) => runningTotal + s.durationMinutes);
    if (totalDurationMinutes <= 0) return [];

    // 5. Query Non-Sensitive booking_slots Collection (Privacy Preserving)
    final occupiedBucketsMap = <String, Set<int>>{};

    for (final staff in targetStaffList) {
      occupiedBucketsMap[staff.id] = {};

      final db = _db;
      if (db != null) {
        try {
          final lockSnap = await db
              .collection('booking_slots')
              .where('businessId', isEqualTo: business.id)
              .where('staffId', isEqualTo: staff.id)
              .get();

          for (final doc in lockSnap.docs) {
            final data = doc.data();
            final ts = (data['startTimestamp'] as num?)?.toInt();
            if (ts != null) {
              occupiedBucketsMap[staff.id]!.add(ts);
            }
          }
        } on FirebaseException catch (e) {
          // Blocker 11: Do NOT swallow error and claim slots are free
          debugPrint(
              'AVAILABILITY_SLOTS_FETCH_ERROR: ${e.code} - ${e.message}');
          throw DomainException(
              'Unable to confirm real-time slot availability. Please try again.');
        } catch (e) {
          debugPrint('AVAILABILITY_ENGINE_ERROR: $e');
          throw DomainException('Unable to verify slot availability.');
        }
      }
    }

    // 6. Generate Candidate Start Times (Canonical 15-Minute Alignment)
    final resultSlots = <AvailableSlot>[];
    final isToday =
        date.year == now.year && date.month == now.month && date.day == now.day;
    final leadTimeCutoff =
        now.add(const Duration(minutes: minimumLeadTimeMinutes));

    for (int minutes = bOpenMinutes;
        minutes + totalDurationMinutes <= bCloseMinutes;
        minutes += defaultStepMinutes) {
      final hour = minutes ~/ 60;
      final min = minutes % 60;

      final candStart = DateTime(date.year, date.month, date.day, hour, min);
      final candEnd = candStart.add(Duration(minutes: totalDurationMinutes));

      // Lead time check for today
      if (isToday && candStart.isBefore(leadTimeCutoff)) {
        continue;
      }

      final availableStaffForThisSlot = <String>[];

      for (final staff in targetStaffList) {
        if (_isStaffAvailableForSlot(
          staff: staff,
          candStart: candStart,
          candEnd: candEnd,
          totalDurationMinutes: totalDurationMinutes,
          occupiedBuckets: occupiedBucketsMap[staff.id] ?? {},
          blockedPeriods: blockedPeriods,
          staffBreaks: staffBreaks,
          employeeTimeOffs: employeeTimeOffs,
          bOpenMinutes: bOpenMinutes,
          bCloseMinutes: bCloseMinutes,
          targetDateWeekday: date.weekday,
        )) {
          availableStaffForThisSlot.add(staff.id);
        }
      }

      if (availableStaffForThisSlot.isNotEmpty) {
        final timeStr = DateFormat('hh:mm a').format(candStart);
        resultSlots.add(AvailableSlot(
          startAt: candStart,
          endAt: candEnd,
          timeString: timeStr,
          availableStaffIds: availableStaffForThisSlot,
          period: AvailableSlot.derivePeriod(candStart),
        ));
      }
    }

    return resultSlots;
  }

  static bool _isStaffAvailableForSlot({
    required StaffModel staff,
    required DateTime candStart,
    required DateTime candEnd,
    required int totalDurationMinutes,
    required Set<int> occupiedBuckets,
    required List<BlockedPeriodModel> blockedPeriods,
    required List<StaffBreakModel> staffBreaks,
    required List<EmployeeTimeOffModel> employeeTimeOffs,
    required int bOpenMinutes,
    required int bCloseMinutes,
    required int targetDateWeekday,
  }) {
    final candStartMs = candStart.millisecondsSinceEpoch;
    final candEndMs = candEnd.millisecondsSinceEpoch;

    // Blocker 9: Check Employee Shift Boundaries and Working Days
    if (staff.workingDays != null &&
        !staff.workingDays!.contains(targetDateWeekday)) {
      return false;
    }

    final staffShiftStartMin = staff.shiftStart != null
        ? _parseTimeStringToMinutes(staff.shiftStart!)
        : bOpenMinutes;
    final staffShiftEndMin = staff.shiftEnd != null
        ? _parseTimeStringToMinutes(staff.shiftEnd!)
        : bCloseMinutes;

    final candStartMin = candStart.hour * 60 + candStart.minute;
    final candEndMin = candStartMin + totalDurationMinutes;
    if (candStartMin < staffShiftStartMin || candEndMin > staffShiftEndMin) {
      return false;
    }

    // 2. Check 15-minute Slot Lock Buckets
    const stepMs = defaultStepMinutes * 60 * 1000;
    for (int t = candStartMs; t < candEndMs; t += stepMs) {
      if (occupiedBuckets.contains(t)) {
        return false;
      }
    }

    // 3. Check Employee Time-Offs (Leave / Vacation)
    for (final toff in employeeTimeOffs) {
      if (toff.employeeId == staff.id) {
        final toffStartMs = toff.startDate.millisecondsSinceEpoch;
        final toffEndMs = toff.endDate.millisecondsSinceEpoch;
        if (candStartMs < toffEndMs && candEndMs > toffStartMs) {
          return false;
        }
      }
    }

    // 4. Check Blocked Periods
    for (final bp in blockedPeriods) {
      if (bp.staffId == null || bp.staffId == staff.id) {
        if (bp.overlaps(candStart, candEnd)) {
          return false;
        }
      }
    }

    // 5. Check Staff Breaks (Multiple Breaks Supported)
    for (final brk in staffBreaks) {
      if (brk.staffId == staff.id) {
        final bStartMin = _parseTimeStringToMinutes(brk.startTime);
        final bEndMin = _parseTimeStringToMinutes(brk.endTime);

        if (candStartMin < bEndMin && candEndMin > bStartMin) {
          return false;
        }
      }
    }

    return true;
  }

  static int _parseTimeStringToMinutes(String raw) {
    try {
      final clean = raw.trim();
      bool isPm = clean.toUpperCase().contains('PM');
      bool isAm = clean.toUpperCase().contains('AM');
      final numbersStr = clean.replaceAll(RegExp(r'[^\d:]'), '');
      final parts = numbersStr.split(':');
      int hour = int.parse(parts[0]);
      int minute = parts.length > 1 ? int.parse(parts[1]) : 0;
      if (isPm && hour < 12) hour += 12;
      if (isAm && hour == 12) hour = 0;
      return hour * 60 + minute;
    } catch (_) {
      return 9 * 60;
    }
  }
}
