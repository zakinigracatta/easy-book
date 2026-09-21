import 'package:cloud_functions/cloud_functions.dart';
import 'package:timezone/timezone.dart' show TZDateTime;

import '../core/utils/business_clock.dart';
import '../models/business_model.dart';

class AvailabilitySnapshot {
  const AvailabilitySnapshot({
    required this.occupiedSlotsByStaff,
  });

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
    String? excludeBookingId,
  }) async {
    final normalizedBusinessId = business.id.trim();
    final normalizedStaffIds = staffIds
        .map((id) => id.trim())
        .where((id) => id.isNotEmpty)
        .toSet()
        .toList(growable: false);

    if (normalizedBusinessId.isEmpty || normalizedStaffIds.isEmpty) {
      return const AvailabilitySnapshot(
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
      if (excludeBookingId != null && excludeBookingId.trim().isNotEmpty)
        'excludeBookingId': excludeBookingId.trim(),
    });

    if (response.data is! Map) {
      throw StateError('Availability service returned an invalid response.');
    }

    final payload = Map<String, dynamic>.from(response.data as Map);
    if (payload['unavailableSlots'] is! List) {
      throw StateError('Availability service returned incomplete scheduling data.');
    }

    final occupied = _parseUnavailableSlots(payload['unavailableSlots']);

    return AvailabilitySnapshot(
      occupiedSlotsByStaff: occupied,
    );
  }

  Map<String, Set<int>> _parseUnavailableSlots(dynamic rawSlots) {
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
