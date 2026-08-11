import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/booking_model.dart';

class AvailabilityService {
  final FirebaseFirestore _firestore;

  AvailabilityService([FirebaseFirestore? firestore])
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<List<String>> getAvailableSlots({
    required String businessId,
    required String staffId,
    required int durationMinutes,
    required DateTime date,
  }) async {
    if (businessId.isEmpty || staffId.isEmpty) return [];

    // Operating & Working Hours: 09:00 AM to 09:00 PM (12 hours)
    const int startHour = 9;
    const int endHour = 21;

    // Fetch active bookings for business + staff
    final bookingsQuery = await _firestore
        .collection('bookings')
        .where('businessId', isEqualTo: businessId)
        .where('staffId', isEqualTo: staffId)
        .get();

    final activeBookings = <BookingModel>[];
    for (final doc in bookingsQuery.docs) {
      final data = doc.data();
      if (data['status'] == BookingStatus.cancelled.name) continue;
      final model = BookingModel.fromJson(data);
      if (model.startDateTime.year == date.year &&
          model.startDateTime.month == date.month &&
          model.startDateTime.day == date.day) {
        activeBookings.add(model);
      }
    }

    // Fetch active slot lock documents for business + staff
    final locksQuery = await _firestore
        .collection('booking_slots')
        .where('businessId', isEqualTo: businessId)
        .where('staffId', isEqualTo: staffId)
        .get();

    final occupiedBucketTimestamps = <int>{};
    for (final doc in locksQuery.docs) {
      final data = doc.data();
      final ts = (data['startTimestamp'] as num?)?.toInt();
      if (ts != null) {
        occupiedBucketTimestamps.add(ts);
      }
    }

    final availableSlotStrings = <String>[];
    final now = DateTime.now();
    const int stepMinutes = 15;

    // Generate candidate start times in 15-min steps
    for (int hour = startHour; hour < endHour; hour++) {
      for (int min = 0; min < 60; min += stepMinutes) {
        final candidateStart =
            DateTime(date.year, date.month, date.day, hour, min);
        final candidateEnd =
            candidateStart.add(Duration(minutes: durationMinutes));

        // Check shift end (cannot exceed closing hour 21:00)
        final closingTime =
            DateTime(date.year, date.month, date.day, endHour, 0);
        if (candidateEnd.isAfter(closingTime)) {
          continue;
        }

        // Past-time check for today
        if (date.year == now.year &&
            date.month == now.month &&
            date.day == now.day) {
          if (candidateStart.isBefore(now.add(const Duration(minutes: 5)))) {
            continue;
          }
        }

        final candStartMs = candidateStart.millisecondsSinceEpoch;
        final candEndMs = candidateEnd.millisecondsSinceEpoch;

        // 1. Check against active bookings: existing.start < candidate.end && existing.end > candidate.start
        bool overlaps = false;
        for (final b in activeBookings) {
          final bStartMs = b.startDateTime.millisecondsSinceEpoch;
          final bEndMs = b.endDateTime.millisecondsSinceEpoch;
          if (bStartMs < candEndMs && bEndMs > candStartMs) {
            overlaps = true;
            break;
          }
        }

        if (overlaps) continue;

        // 2. Check against occupied slot locks
        for (int t = candStartMs;
            t < candEndMs;
            t += (stepMinutes * 60 * 1000)) {
          if (occupiedBucketTimestamps.contains(t)) {
            overlaps = true;
            break;
          }
        }

        if (overlaps) continue;

        // Format slot string (e.g., "09:00 AM", "02:30 PM")
        final hour12 = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
        final amPm = hour >= 12 ? 'PM' : 'AM';
        final timeStr =
            '${hour12.toString().padLeft(2, '0')}:${min.toString().padLeft(2, '0')} $amPm';

        availableSlotStrings.add(timeStr);
      }
    }

    return availableSlotStrings;
  }
}
