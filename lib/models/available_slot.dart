enum SlotPeriod {
  morning,
  afternoon,
  evening,
}

class AvailableSlot {
  final DateTime startAt;
  final DateTime endAt;
  final String timeString;
  final List<String> availableStaffIds;
  final SlotPeriod period;

  AvailableSlot({
    required this.startAt,
    required this.endAt,
    required this.timeString,
    required this.availableStaffIds,
    required this.period,
  });

  bool get isAvailable => availableStaffIds.isNotEmpty;

  static SlotPeriod derivePeriod(DateTime dt) {
    final hour = dt.hour;
    if (hour < 12) {
      return SlotPeriod.morning;
    } else if (hour < 17) {
      return SlotPeriod.afternoon;
    } else {
      return SlotPeriod.evening;
    }
  }

  @override
  String toString() => '$timeString (${period.name})';
}
