import 'package:intl/intl.dart';

class StaffWorkingHours {
  final String dayName;
  final String openTime;
  final String closeTime;
  final bool isWorking;

  StaffWorkingHours({
    required this.dayName,
    required this.openTime,
    required this.closeTime,
    this.isWorking = true,
  });

  factory StaffWorkingHours.fromJson(String day, Map<String, dynamic>? json) {
    if (json == null) {
      return StaffWorkingHours(
        dayName: day,
        openTime: '09:00 AM',
        closeTime: '10:00 PM',
        isWorking: true,
      );
    }
    return StaffWorkingHours(
      dayName: day,
      openTime:
          json['openTime'] as String? ?? json['open'] as String? ?? '09:00 AM',
      closeTime: json['closeTime'] as String? ??
          json['close'] as String? ??
          '10:00 PM',
      isWorking:
          json['isWorking'] as bool? ?? json['is_working'] as bool? ?? true,
    );
  }
}

class StaffBreakModel {
  final String staffId;
  final String startTime; // e.g. "13:00" or "01:00 PM"
  final String endTime; // e.g. "14:00" or "02:00 PM"

  StaffBreakModel({
    required this.staffId,
    required this.startTime,
    required this.endTime,
  });
}

class BlockedPeriodModel {
  final String id;
  final String? staffId; // null if business-wide
  final DateTime startAt;
  final DateTime endAt;
  final String? reason;

  BlockedPeriodModel({
    required this.id,
    this.staffId,
    required this.startAt,
    required this.endAt,
    this.reason,
  });

  bool overlaps(DateTime candidateStart, DateTime candidateEnd) {
    return candidateStart.isBefore(endAt) && candidateEnd.isAfter(startAt);
  }
}
