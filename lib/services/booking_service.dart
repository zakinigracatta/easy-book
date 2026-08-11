import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/booking_model.dart';
import '../core/domain_exceptions.dart';
import 'booking_functions_service.dart';

class BookingService {
  BookingService({
    FirebaseFirestore? firestore,
    BookingFunctionsService? functionsService,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _functionsService = functionsService ?? BookingFunctionsService();

  final FirebaseFirestore _firestore;
  final BookingFunctionsService _functionsService;

  /// Verifies that booking start time is strictly aligned to 15-minute intervals.
  static void validateCanonical15MinAlignment(DateTime start) {
    if (start.minute % 15 != 0 || start.second != 0 || start.millisecond != 0) {
      throw InvalidBookingTimeException(
          'Booking start time must be aligned to 15-minute intervals (e.g., 10:00, 10:15, 10:30, 10:45).');
    }
  }

  Future<List<BookingModel>> getBookings(String customerId) async {
    if (customerId.isEmpty) return [];
    try {
      final snap = await _firestore
          .collection('bookings')
          .where('customerId', isEqualTo: customerId)
          .get();

      final list =
          snap.docs.map((doc) => BookingModel.fromJson(doc.data())).toList();
      list.sort((a, b) => b.startDateTime.compareTo(a.startDateTime));
      return list;
    } catch (e) {
      debugPrint('getBookings error: $e');
      throw DomainException('Failed to fetch bookings for customer.');
    }
  }

  static List<String> generateIntervalSlotLockIds(
      String businessId, String staffId, DateTime start, DateTime end) {
    final List<String> ids = [];
    const int bucketMs = 15 * 60 * 1000;
    final int startMs = start.millisecondsSinceEpoch;
    final int endMs = end.millisecondsSinceEpoch;

    for (int t = startMs; t < endMs; t += bucketMs) {
      ids.add('${businessId}_${staffId}_$t');
    }
    if (ids.isEmpty) {
      ids.add('${businessId}_${staffId}_$startMs');
    }
    return ids;
  }

  /// Creates a booking (App or Walk-in) via trusted Callable Cloud Function.
  Future<BookingModel> createBooking(BookingModel booking) async {
    validateCanonical15MinAlignment(booking.startDateTime);

    if (booking.bookingSource == 'walkIn') {
      return _functionsService.createWalkInBooking(
        businessId: booking.businessId,
        serviceId: booking.serviceId,
        staffId: booking.staffId,
        requestedStartAt: booking.startDateTime,
        customerName: booking.customerName,
        customerPhone: booking.customerPhone ?? '',
        notes: booking.notes ?? '',
      );
    }

    return _functionsService.createBooking(
      businessId: booking.businessId,
      serviceId: booking.serviceId,
      staffId: booking.staffId,
      requestedStartAt: booking.startDateTime,
      customerName: booking.customerName,
      customerPhone: booking.customerPhone ?? '',
      notes: booking.notes ?? '',
    );
  }

  /// Canonical cancellation path via trusted Callable Cloud Function.
  Future<bool> cancelBooking({
    required String bookingId,
    required String cancelledBy,
    String? cancelReason,
  }) async {
    return _functionsService.cancelBooking(
      bookingId: bookingId,
      cancelReason: cancelReason,
    );
  }

  /// Reschedules an existing booking via trusted Callable Cloud Function.
  Future<BookingModel> rescheduleBooking({
    required String bookingId,
    required DateTime newStartDateTime,
    required DateTime newEndDateTime,
  }) async {
    validateCanonical15MinAlignment(newStartDateTime);
    return _functionsService.rescheduleBooking(
      bookingId: bookingId,
      newRequestedStartAt: newStartDateTime,
    );
  }

  static bool canTransitionBookingStatus({
    required BookingStatus from,
    required BookingStatus to,
    required String actorRole,
  }) {
    if (from == BookingStatus.cancelled || from == BookingStatus.completed) {
      return false;
    }

    if (actorRole == 'customer') {
      if (to == BookingStatus.cancelled) return true;
      return false;
    }

    if (actorRole == 'owner') {
      if (from == BookingStatus.pending && to == BookingStatus.confirmed) {
        return true;
      }
      if (from == BookingStatus.confirmed && to == BookingStatus.arrived) {
        return true;
      }
      if (from == BookingStatus.arrived && to == BookingStatus.inProgress) {
        return true;
      }
      if (from == BookingStatus.inProgress && to == BookingStatus.completed) {
        return true;
      }
      if (to == BookingStatus.cancelled || to == BookingStatus.noShow) {
        return true;
      }
      return false;
    }

    return false;
  }

  /// Updates booking status via trusted Callable Cloud Function.
  Future<bool> updateBookingStatusByOwner({
    required String bookingId,
    required BookingStatus newStatus,
  }) async {
    return _functionsService.updateBookingStatus(
      bookingId: bookingId,
      newStatus: newStatus,
    );
  }
}
