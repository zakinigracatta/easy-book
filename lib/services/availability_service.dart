import 'package:cloud_functions/cloud_functions.dart';
import 'package:timezone/timezone.dart' show TZDateTime;

import '../core/utils/business_clock.dart';
import '../models/business_model.dart';
import '../models/employee_time_off_model.dart';

class AvailabilitySnapshot {
  const AvailabilitySnapshot({
    required this.timeOffs,
    required this.occupiedSlotsByStaff,
  });

  final List<EmployeeTimeOffModel> timeOffs;
  final Map<String, Set<int>> occupiedSlotsByStaff;
}

class AvailabilityService {
  final FirebaseFunctions _functions;

  AvailabilityService([FirebaseFunctions? functions])
      : _functions = functions ?? FirebaseFunctions.instance;

  Future<AvailabilitySnapshot> getAvailabilitySnapshot({
    required BusinessModel business,
    required DateTime date,
    required List<String> staffIds,
  }) async {
    final normalizedBusinessId = business.id.trim();
    final normalizedStaffIds = staffIds
        .map((id) => id.trim())
        .where((id) => id.isNotEmpty)
        .toSet()
        .toList(growable: false);

    if (normalizedBusinessId.isEmpty || normalizedStaffIds.isEmpty) {
      return const AvailabilitySnapshot(
        timeOffs: [],
        occupiedSlotsByStaff: {},
      );
    }

    final location = BusinessClock.locationFor(business.timeZone);
    final start = TZDateTime(
      location,
      date.year,
      date.month,
      date.day,
    );
    final end = TZDateTime(
      location,
      date.year,
      date.month,
      date.day + 1,
    );

    final callable = _functions.httpsCallable('getAvailabilityBlocks');
    final response = await callable.call({
      'businessId': normalizedBusinessId,
      'staffIds': normalizedStaffIds,
      'startAt': start.toUtc().toIso8601String(),
      'endAt': end.toUtc().toIso8601String(),
    });

    if (response.data is! Map) {
      return const AvailabilitySnapshot(
        timeOffs: [],
        occupiedSlotsByStaff: {},
      );
    }

    final payload = Map<String, dynamic>.from(response.data as Map);
    final timeOffs = _parseTimeOffs(
      payload['blocks'],
      businessId: normalizedBusinessId,
    );
    final occupied = _parseOccupiedSlots(payload['occupiedSlots']);

    return AvailabilitySnapshot(
      timeOffs: timeOffs,
      occupiedSlotsByStaff: occupied,
    );
  }

  List<EmployeeTimeOffModel> _parseTimeOffs(
    dynamic rawBlocks, {
    required String businessId,
  }) {
    if (rawBlocks is! List) return const [];

    final result = <EmployeeTimeOffModel>[];
    for (final item in rawBlocks) {
      if (item is! Map) continue;
      final data = Map<String, dynamic>.from(item);
      final employeeId = (data['employeeId'] ?? '').toString().trim();
      final start = DateTime.tryParse((data['startDate'] ?? '').toString());
      final end = DateTime.tryParse((data['endDate'] ?? '').toString());
      if (employeeId.isEmpty || start == null || end == null) continue;

      result.add(
        EmployeeTimeOffModel(
          id: (data['id'] ?? '').toString(),
          businessId: businessId,
          employeeId: employeeId,
          employeeName: '',
          startDate: start,
          endDate: end,
          reason: '',
        ),
      );
    }
    return result;
  }

  Map<String, Set<int>> _parseOccupiedSlots(dynamic rawSlots) {
    if (rawSlots is! List) return const {};

    final result = <String, Set<int>>{};
    for (final item in rawSlots) {
      if (item is! Map) continue;
      final data = Map<String, dynamic>.from(item);
      final staffId = (data['staffId'] ?? '').toString().trim();
      final timestamp = (data['startTimestamp'] as num?)?.toInt();
      if (staffId.isEmpty || timestamp == null) continue;
      result.putIfAbsent(staffId, () => <int>{}).add(timestamp);
    }
    return result;
  }
}
