class StaffWorkingHours {
  final String dayName;
  final String openTime;
  final String closeTime;
  final bool isWorking;
  final String? breakStart;
  final String? breakEnd;

  const StaffWorkingHours({
    required this.dayName,
    required this.openTime,
    required this.closeTime,
    this.isWorking = true,
    this.breakStart,
    this.breakEnd,
  });

  factory StaffWorkingHours.fromJson(String day, Map<String, dynamic>? json) {
    if (json == null) {
      return StaffWorkingHours(
        dayName: day,
        openTime: '09:00 AM',
        closeTime: '06:00 PM',
        isWorking: true,
      );
    }

    return StaffWorkingHours(
      dayName: day,
      openTime: json['openTime'] as String? ??
          json['open_time'] as String? ??
          json['open'] as String? ??
          '09:00 AM',
      closeTime: json['closeTime'] as String? ??
          json['close_time'] as String? ??
          json['close'] as String? ??
          '06:00 PM',
      isWorking:
          json['isWorking'] as bool? ?? json['is_working'] as bool? ?? true,
      breakStart:
          json['breakStart'] as String? ?? json['break_start'] as String?,
      breakEnd: json['breakEnd'] as String? ?? json['break_end'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'day_name': dayName,
      'open_time': openTime,
      'close_time': closeTime,
      'is_working': isWorking,
      if (breakStart != null && breakStart!.isNotEmpty)
        'break_start': breakStart,
      if (breakEnd != null && breakEnd!.isNotEmpty) 'break_end': breakEnd,
    };
  }

  StaffWorkingHours copyWith({
    String? openTime,
    String? closeTime,
    bool? isWorking,
    String? breakStart,
    String? breakEnd,
  }) {
    return StaffWorkingHours(
      dayName: dayName,
      openTime: openTime ?? this.openTime,
      closeTime: closeTime ?? this.closeTime,
      isWorking: isWorking ?? this.isWorking,
      breakStart: breakStart ?? this.breakStart,
      breakEnd: breakEnd ?? this.breakEnd,
    );
  }
}

class StaffBreakModel {
  final String staffId;
  final String startTime;
  final String endTime;

  StaffBreakModel({
    required this.staffId,
    required this.startTime,
    required this.endTime,
  });
}

class BlockedPeriodModel {
  final String id;
  final String? staffId;
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
