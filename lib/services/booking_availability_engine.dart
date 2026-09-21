import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart' show TZDateTime;
import '../core/utils/business_clock.dart';
import '../models/available_slot.dart';
import '../models/business_model.dart';
import '../models/employee_time_off_model.dart';
import '../models/service_model.dart';
import '../models/staff_model.dart';
import '../models/staff_schedule_model.dart';

export '../models/employee_time_off_model.dart' show EmployeeTimeOffModel;

class BookingAvailabilityEngine {
  static const int defaultStepMinutes = 15;
  static const int minimumLeadTimeMinutes = 30;
  static const int maxAdvanceBookingDays = 60;

  const BookingAvailabilityEngine();

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
    Map<String, Set<int>> occupiedSlotsByStaff = const {},
  }) async {
    if (!business.isActive ||
        !business.acceptingBookings ||
        business.businessStatus != 'open' ||
        selectedServices.isEmpty) {
      return [];
    }

    final businessLocation = BusinessClock.locationFor(business.timeZone);
    final now = nowOverride == null
        ? BusinessClock.now(business.timeZone)
        : BusinessClock.wallClock(nowOverride, business.timeZone);
    final today = TZDateTime(
      businessLocation,
      now.year,
      now.month,
      now.day,
    );
    final maxDate = TZDateTime(
      businessLocation,
      today.year,
      today.month,
      today.day + maxAdvanceBookingDays,
    );
    final targetDateOnly = TZDateTime(
      businessLocation,
      date.year,
      date.month,
      date.day,
    );
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
    final dayName = dayNames[targetDateOnly.weekday - 1];
    final dailyHours = business.workingHours.schedule[dayName];
    if (dailyHours == null || dailyHours.isClosed) return [];

    final bOpenMinutes = _tryParseTimeStringToMinutes(dailyHours.openTime);
    final bCloseMinutes = _tryParseTimeStringToMinutes(dailyHours.closeTime);
    if (bOpenMinutes == null ||
        bCloseMinutes == null ||
        bCloseMinutes <= bOpenMinutes) {
      return [];
    }

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

    final occupiedBucketsMap = <String, Set<int>>{
      for (final staff in targetStaffList)
        staff.id: occupiedSlotsByStaff[staff.id] ?? const <int>{},
    };

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
      final candStart = TZDateTime(
        businessLocation,
        date.year,
        date.month,
        date.day,
        hour,
        minute,
      );
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
          targetDateWeekday: targetDateOnly.weekday,
          targetDayName: dayName,
          businessTimeZone: business.timeZone,
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
    required String businessTimeZone,
  }) {
    final candStartMs = candStart.millisecondsSinceEpoch;
    final candEndMs = candEnd.millisecondsSinceEpoch;
    final candStartMin = candStart.hour * 60 + candStart.minute;
    final candEndMin = candStartMin + totalDurationMinutes;

    final perDaySchedule = staff.weeklySchedule[targetDayName];
    if (staff.weeklySchedule.isNotEmpty) {
      if (perDaySchedule == null || !perDaySchedule.isWorking) return false;
    } else {
      final workingDays = staff.workingDays;
      final hasShiftStart = staff.shiftStart?.trim().isNotEmpty == true;
      final hasShiftEnd = staff.shiftEnd?.trim().isNotEmpty == true;

      // Completely missing scheduling data must not make an active employee
      // bookable across the full business day.
      if (workingDays == null && !hasShiftStart && !hasShiftEnd) {
        return false;
      }
      if (workingDays != null &&
          (workingDays.isEmpty || !workingDays.contains(targetDateWeekday))) {
        return false;
      }
      if (hasShiftStart != hasShiftEnd) return false;
    }

    final staffShiftStartMin = perDaySchedule != null
        ? _tryParseTimeStringToMinutes(perDaySchedule.openTime)
        : (staff.shiftStart?.trim().isNotEmpty == true
            ? _tryParseTimeStringToMinutes(staff.shiftStart!)
            : bOpenMinutes);
    final staffShiftEndMin = perDaySchedule != null
        ? _tryParseTimeStringToMinutes(perDaySchedule.closeTime)
        : (staff.shiftEnd?.trim().isNotEmpty == true
            ? _tryParseTimeStringToMinutes(staff.shiftEnd!)
            : bCloseMinutes);

    if (staffShiftStartMin == null ||
        staffShiftEndMin == null ||
        staffShiftEndMin <= staffShiftStartMin ||
        candStartMin < staffShiftStartMin ||
        candEndMin > staffShiftEndMin) {
      return false;
    }

    if (perDaySchedule?.breakStart != null &&
        perDaySchedule?.breakEnd != null) {
      final breakStartMin =
          _tryParseTimeStringToMinutes(perDaySchedule!.breakStart!);
      final breakEndMin =
          _tryParseTimeStringToMinutes(perDaySchedule.breakEnd!);
      if (breakStartMin == null ||
          breakEndMin == null ||
          breakEndMin <= breakStartMin) {
        return false;
      }
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
      // Interpret legacy midnight values in the business timezone, not the
      // device/UTC timezone carried by the parsed ISO instant.
      final endLocal = BusinessClock.inTimeZone(
        normalizedEnd,
        businessTimeZone,
      );
      if (endLocal.hour == 0 &&
          endLocal.minute == 0 &&
          endLocal.second == 0 &&
          endLocal.millisecond == 0) {
        normalizedEnd = TZDateTime(
          BusinessClock.locationFor(businessTimeZone),
          endLocal.year,
          endLocal.month,
          endLocal.day + 1,
        );
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
      final breakStartMin =
          _tryParseTimeStringToMinutes(staffBreak.startTime);
      final breakEndMin =
          _tryParseTimeStringToMinutes(staffBreak.endTime);
      if (breakStartMin == null ||
          breakEndMin == null ||
          breakEndMin <= breakStartMin) {
        return false;
      }
      if (candStartMin < breakEndMin && candEndMin > breakStartMin) {
        return false;
      }
    }

    return true;
  }

  static int? _tryParseTimeStringToMinutes(String raw) {
    try {
      final clean = raw.trim();
      final isPm = clean.toUpperCase().contains('PM');
      final isAm = clean.toUpperCase().contains('AM');
      final numbersStr = clean.replaceAll(RegExp(r'[^\d:]'), '');
      final parts = numbersStr.split(':');
      var hour = int.parse(parts[0]);
      final minute = parts.length > 1 ? int.parse(parts[1]) : 0;
      if (minute < 0 || minute > 59 || hour < 0 || hour > 23) return null;
      if ((isAm || isPm) && hour > 12) return null;
      if (isPm && hour < 12) hour += 12;
      if (isAm && hour == 12) hour = 0;
      return hour * 60 + minute;
    } catch (_) {
      return null;
    }
  }
}
