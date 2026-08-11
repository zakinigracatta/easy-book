import 'package:intl/intl.dart';

class DailyHours {
  final String dayName;
  final String openTime;
  final String closeTime;
  final bool isClosed;

  DailyHours({
    required this.dayName,
    required this.openTime,
    required this.closeTime,
    this.isClosed = false,
  });

  factory DailyHours.fromJson(String day, Map<String, dynamic>? json) {
    if (json == null) {
      return DailyHours(
        dayName: day,
        openTime: '09:00 AM',
        closeTime: '10:00 PM',
        isClosed: false,
      );
    }

    final isClosed =
        json['is_closed'] as bool? ?? json['isClosed'] as bool? ?? false;
    final open = json['open'] as String? ?? '09:00 AM';
    final close = json['close'] as String? ?? '10:00 PM';

    return DailyHours(
      dayName: day,
      openTime: _formatTimeString(open),
      closeTime: _formatTimeString(close),
      isClosed: isClosed,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'open': openTime,
      'close': closeTime,
      'is_closed': isClosed,
    };
  }

  static String _formatTimeString(String raw) {
    if (raw.toUpperCase().contains('AM') || raw.toUpperCase().contains('PM')) {
      return raw;
    }
    final parts = raw.split(':');
    if (parts.length >= 2) {
      final hour = int.tryParse(parts[0]) ?? 9;
      final minute = int.tryParse(parts[1]) ?? 0;
      final dt = DateTime(2026, 1, 1, hour, minute);
      return DateFormat('hh:mm a').format(dt);
    }
    return raw;
  }

  @override
  String toString() {
    if (isClosed) return 'Closed';
    return '$openTime – $closeTime';
  }
}

class WorkingHoursModel {
  final Map<String, DailyHours> schedule;

  WorkingHoursModel({required this.schedule});

  factory WorkingHoursModel.fromJson(Map<String, dynamic>? json) {
    const days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];

    if (json == null || json.isEmpty) {
      return WorkingHoursModel.defaultSchedule();
    }

    final map = <String, DailyHours>{};
    for (final day in days) {
      final lowerKey = day.toLowerCase();
      final dayData = json[lowerKey] ?? json[day];
      if (dayData is Map<String, dynamic>) {
        map[day] = DailyHours.fromJson(day, dayData);
      } else {
        map[day] = DailyHours(
          dayName: day,
          openTime: '09:00 AM',
          closeTime: '10:00 PM',
          isClosed: false,
        );
      }
    }

    return WorkingHoursModel(schedule: map);
  }

  factory WorkingHoursModel.defaultSchedule() {
    const days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    final map = <String, DailyHours>{};
    for (final day in days) {
      final isFriday = day == 'Friday';
      map[day] = DailyHours(
        dayName: day,
        openTime: isFriday ? '02:00 PM' : '09:00 AM',
        closeTime: isFriday ? '11:00 PM' : '10:00 PM',
        isClosed: false,
      );
    }
    return WorkingHoursModel(schedule: map);
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    schedule.forEach((day, hours) {
      map[day.toLowerCase()] = hours.toJson();
    });
    return map;
  }

  /// Evaluates current status ("Open Now • Closes at 10:00 PM" or "Closed • Opens tomorrow at 09:00 AM")
  ({bool isOpen, String statusText}) getStatus({DateTime? now}) {
    final current = now ?? DateTime.now();
    final dayNames = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday'
    ];
    final currentDayIndex = current.weekday - 1; // 0 for Mon ... 6 for Sun
    final currentDayName = dayNames[currentDayIndex];

    final todayHours = schedule[currentDayName];

    if (todayHours == null || todayHours.isClosed) {
      final nextDayName = dayNames[(currentDayIndex + 1) % 7];
      final nextHours = schedule[nextDayName];
      final opensNext = (nextHours != null && !nextHours.isClosed)
          ? ' at ${nextHours.openTime}'
          : '';
      return (isOpen: false, statusText: 'Closed • Opens tomorrow$opensNext');
    }

    final nowMinutes = current.hour * 60 + current.minute;
    final openMinutes = _parseMinutes(todayHours.openTime);
    final closeMinutes = _parseMinutes(todayHours.closeTime);

    if (nowMinutes >= openMinutes && nowMinutes < closeMinutes) {
      return (
        isOpen: true,
        statusText: 'Open Now • Closes at ${todayHours.closeTime}'
      );
    } else if (nowMinutes < openMinutes) {
      return (
        isOpen: false,
        statusText: 'Closed • Opens today at ${todayHours.openTime}'
      );
    } else {
      final nextDayName = dayNames[(currentDayIndex + 1) % 7];
      final nextHours = schedule[nextDayName];
      final opensNext = (nextHours != null && !nextHours.isClosed)
          ? ' at ${nextHours.openTime}'
          : '';
      return (isOpen: false, statusText: 'Closed • Opens tomorrow$opensNext');
    }
  }

  static int _parseMinutes(String timeStr) {
    try {
      final clean = timeStr.trim();
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
