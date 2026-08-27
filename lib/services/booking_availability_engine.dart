import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

import '../core/domain_exceptions.dart';
import '../models/available_slot.dart';
import '../models/business_model.dart';
import '../models/employee_time_off_model.dart';
import '../models/service_model.dart';
import '../models/staff_model.dart';
import '../models/staff_schedule_model.dart';

export 'package:cloud_firestore/cloud_firestore.dart' show FirebaseFirestore;
export '../models/employee_time_off_model.dart' show EmployeeTimeOffModel;

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
    if (!business.isActive ||
        !business.acceptingBookings ||
        business.businessStatus != 'open' ||
        selectedServices.isEmpty) {
      return [];
    }

    final now = nowOverride ?? DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final maxDate = today.add(const Duration(days: maxAdvanceBookingDays));
    final targetDateOnly = DateTime(date.year, date.month, date.day);
    if (targetDateOnly.isBefore(today) || targetDateOnly.isAfter(maxDate)) {
      return [];
    }

    const dayNames = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    final dayName = dayNames[date.weekday - 1];
    final dailyHours = business.workingHours.schedule[dayName];
    if (dailyHours == null || dailyHours.isClosed) return [];

    final bOpenMinutes = _parseTimeStringToMinutes(dailyHours.openTime);
    final bCloseMinutes = _parseTimeStringToMinutes(dailyHours.closeTime);
    if (bCloseMinutes <= bOpenMinutes) return [];

    final eligibleStaff = filterEligibleStaff(allStaff, selectedServices);
    if (eligibleStaff.isEmpty) return [];

    final targetStaffList =
        (specialistId != null && specialistId.isNotEmpty && !anySpecialist)
            ? eligibleStaff.where((s) => s.id == specialistId).toList()
            : eligibleStaff;
    if (targetStaffList.isEmpty) return [];

    final totalDurationMinutes = selectedServices.fold<int>(
      0,
      (runningTotal, service) =>
          runningTotal + service.durationMinutes,
    );
    if (totalDurationMinutes <= 0) return [];

    final occupiedBucketsMap = <String, Set<int>>{};
    final dayStartMs = targetDateOnly.millisecondsSinceEpoch;
    final nextDayMs = targetDateOnly
        .add(const Duration(days: 1))
        .millisecondsSinceEpoch;

    for (final staff in targetStaffList) {
      occupiedBucketsMap[staff.id] = <int>{};
      final db = _db;
      if (db == null) continue;

      try {
        // Only fetch lock buckets that can affect the requested day. The old
        // query downloaded the employee's entire booking history every time a
        // customer changed the calendar date.
        final lockSnap = await db
            .collection('booking_slots')
            .where('businessId', isEqualTo: business.id)
            .where('staffId', isEqualTo: staff.id)
            .where('startTimestamp', isGreaterThanOrEqualTo: dayStartMs)
            .where('startTimestamp', isLessThan: nextDayMs)
            .get();

        for (final doc in lockSnap.docs) {
          final data = doc.data();
          final ts = (data['startTimestamp'] as num?)?.toInt();
          if (ts != null) occupiedBucketsMap[staff.id]!.add(ts);
        }
      } on FirebaseException catch (e) {
        debugPrint('AVAILABILITY_SLOTS_FETCH_ERROR: ${e.code} - ${e.message}');
        throw DomainException(
          'Unable to confirm real-time slot availability. Please try again.',
        );
      } catch (e) {
        if (e is DomainException) rethrow;
        debugPrint('AVAILABILITY_ENGINE_ERROR: $e');
        throw DomainException('Unable to verify slot availability.');
      }
    }

    final resultSlots = <AvailableSlot>[];
    final isToday = targetDateOnly == today;
    final leadTimeCutoff = now.add(
      const Duration(minutes: minimumLeadTimeMinutes),
    );

    for (int minutes = bOpenMinutes;
        minutes + totalDurationMinutes <= bCloseMinutes;
        minutes += defaultStepMinutes) {
      final hour = minutes ~/ 60;
      final minute = minutes % 60;
      final candStart = DateTime(date.year, date.month, date.day, hour, minute);
      final candEnd = candStart.add(Duration(minutes: totalDurationMinutes));

      if (isToday && candStart.isBefore(leadTimeCutoff)) continue;

      final availableStaffForThisSlot = <String>[];
      for (final staff in targetStaffList) {
        if (_isStaffAvailableForSlot(
          staff: staff,
          candStart: candStart,
          candEnd: candEnd,
          totalDurationMinutes: totalDurationMinutes,
          occupiedBuckets: occupiedBucketsMap[staff.id] ?? const <int>{},
          blockedPeriods: blockedPeriods,
          staffBreaks: staffBreaks,
          employeeTimeOffs: employeeTimeOffs,
          bOpenMinutes: bOpenMinutes,
          bCloseMinutes: bCloseMinutes,
          targetDateWeekday: date.weekday,
          targetDayName: dayName,
        )) {
          availableStaffForThisSlot.add(staff.id);
        }
      }

      if (availableStaffForThisSlot.isNotEmpty) {
        resultSlots.add(
          AvailableSlot(
            startAt: candStart,
            endAt: candEnd,
            timeString: DateFormat('hh:mm a').format(candStart),
            availableStaffIds: availableStaffForThisSlot,
            period: AvailableSlot.derivePeriod(candStart),
          ),
        );
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
    required String targetDayName,
  }) {
    final candStartMs = candStart.millisecondsSinceEpoch;
    final candEndMs = candEnd.millisecondsSinceEpoch;
    final candStartMin = candStart.hour * 60 + candStart.minute;
    final candEndMin = candStartMin + totalDurationMinutes;

    final perDaySchedule = staff.weeklySchedule[targetDayName];
    if (perDaySchedule != null) {
      if (!perDaySchedule.isWorking) return false;
    } else if (staff.workingDays != null &&
        !staff.workingDays!.contains(targetDateWeekday)) {
      return false;
    }

    final staffShiftStartMin = perDaySchedule != null
        ? _parseTimeStringToMinutes(perDaySchedule.openTime)
        : (staff.shiftStart != null
            ? _parseTimeStringToMinutes(staff.shiftStart!)
            : bOpenMinutes);
    final staffShiftEndMin = perDaySchedule != null
        ? _parseTimeStringToMinutes(perDaySchedule.closeTime)
        : (staff.shiftEnd != null
            ? _parseTimeStringToMinutes(staff.shiftEnd!)
            : bCloseMinutes);

    if (candStartMin < staffShiftStartMin || candEndMin > staffShiftEndMin) {
      return false;
    }

    if (perDaySchedule?.breakStart != null &&
        perDaySchedule?.breakEnd != null) {
      final breakStartMin =
          _parseTimeStringToMinutes(perDaySchedule!.breakStart!);
      final breakEndMin = _parseTimeStringToMinutes(perDaySchedule.breakEnd!);
      if (candStartMin < breakEndMin && candEndMin > breakStartMin) {
        return false;
      }
    }

    const stepMs = defaultStepMinutes * 60 * 1000;
    for (int t = candStartMs; t < candEndMs; t += stepMs) {
      if (occupiedBuckets.contains(t)) return false;
    }

    for (final timeOff in employeeTimeOffs) {
      if (timeOff.employeeId != staff.id) continue;

      final timeOffStartMs = timeOff.startDate.millisecondsSinceEpoch;
      var normalizedEnd = timeOff.endDate;
      // The owner UI selects leave by calendar date. A stored midnight end date
      // therefore represents an inclusive end day, not an empty interval.
      if (normalizedEnd.hour == 0 &&
          normalizedEnd.minute == 0 &&
          normalizedEnd.second == 0 &&
          normalizedEnd.millisecond == 0) {
        normalizedEnd = normalizedEnd.add(const Duration(days: 1));
      }
      final timeOffEndMs = normalizedEnd.millisecondsSinceEpoch;

      if (candStartMs < timeOffEndMs && candEndMs > timeOffStartMs) {
        return false;
      }
    }

    for (final blockedPeriod in blockedPeriods) {
      if ((blockedPeriod.staffId == null || blockedPeriod.staffId == staff.id) &&
          blockedPeriod.overlaps(candStart, candEnd)) {
        return false;
      }
    }

    for (final staffBreak in staffBreaks) {
      if (staffBreak.staffId != staff.id) continue;
      final breakStartMin = _parseTimeStringToMinutes(staffBreak.startTime);
      final breakEndMin = _parseTimeStringToMinutes(staffBreak.endTime);
      if (candStartMin < breakEndMin && candEndMin > breakStartMin) {
        return false;
      }
    }

    return true;
  }

  static int _parseTimeStringToMinutes(String raw) {
    try {
      final clean = raw.trim();
      final isPm = clean.toUpperCase().contains('PM');
      final isAm = clean.toUpperCase().contains('AM');
      final numbersStr = clean.replaceAll(RegExp(r'[^\d:]'), '');
      final parts = numbersStr.split(':');
      var hour = int.parse(parts[0]);
      final minute = parts.length > 1 ? int.parse(parts[1]) : 0;
      if (isPm && hour < 12) hour += 12;
      if (isAm && hour == 12) hour = 0;
      return hour * 60 + minute;
    } catch (_) {
      return 9 * 60;
    }
  }
}
