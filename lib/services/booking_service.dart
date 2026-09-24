import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../core/domain_exceptions.dart';
import '../models/booking_model.dart';
import 'booking_functions_service.dart';

class CustomerBookingsPage {
  const CustomerBookingsPage({
    required this.items,
    required this.cursorStartDateTime,
    required this.cursorBookingId,
    required this.hasMore,
  });

  final List<BookingModel> items;
  final DateTime? cursorStartDateTime;
  final String? cursorBookingId;
  final bool hasMore;
}

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
        'Booking start time must be aligned to 15-minute intervals (e.g., 10:00, 10:15, 10:30, 10:45).',
      );
    }
  }

  List<BookingModel> _sortCustomerBookings(
    Iterable<BookingModel> bookings,
  ) {
    final list = bookings.toList(growable: false);
    final now = DateTime.now();

    int bookingGroup(BookingModel booking) {
      final isUpcoming = booking.startDateTime.isAfter(now) &&
          (booking.status == BookingStatus.pending ||
              booking.status == BookingStatus.confirmed);
      return isUpcoming ? 0 : 1;
    }

    list.sort((a, b) {
      final groupCompare = bookingGroup(a).compareTo(bookingGroup(b));
      if (groupCompare != 0) return groupCompare;
      return bookingGroup(a) == 0
          ? a.startDateTime.compareTo(b.startDateTime)
          : b.startDateTime.compareTo(a.startDateTime);
    });
    return list;
  }

  Future<CustomerBookingsPage> getBookingsPage(
    String customerId, {
    DateTime? afterStartDateTime,
    String? afterBookingId,
    int pageSize = 50,
  }) async {
    final normalizedCustomerId = customerId.trim();
    if (normalizedCustomerId.isEmpty) {
      return const CustomerBookingsPage(
        items: <BookingModel>[],
        cursorStartDateTime: null,
        cursorBookingId: null,
        hasMore: false,
      );
    }

    final safePageSize = pageSize.clamp(1, 100).toInt();

    try {
      Query<Map<String, dynamic>> query = _firestore
          .collection('bookings')
          .where('customerId', isEqualTo: normalizedCustomerId)
          .orderBy('startDateTime', descending: true)
          .orderBy(FieldPath.documentId, descending: true)
          .limit(safePageSize);

      final cursorId = afterBookingId?.trim() ?? '';
      if (afterStartDateTime != null && cursorId.isNotEmpty) {
        query = query.startAfter([
          Timestamp.fromDate(afterStartDateTime),
          cursorId,
        ]);
      }

      final snap = await query.get();
      final items = snap.docs.map((doc) {
        final data = Map<String, dynamic>.from(doc.data());
        // Firestore's document ID is canonical even for legacy records.
        data['id'] = doc.id;
        return BookingModel.fromJson(data);
      }).toList(growable: false);

      DateTime? cursorStartDateTime;
      String? cursorBookingId;
      if (snap.docs.isNotEmpty) {
        final lastDoc = snap.docs.last;
        final lastData = Map<String, dynamic>.from(lastDoc.data());
        lastData['id'] = lastDoc.id;
        final lastBooking = BookingModel.fromJson(lastData);
        cursorStartDateTime = lastBooking.startDateTime;
        cursorBookingId = lastDoc.id;
      }

      return CustomerBookingsPage(
        items: _sortCustomerBookings(items),
        cursorStartDateTime: cursorStartDateTime,
        cursorBookingId: cursorBookingId,
        hasMore: snap.docs.length == safePageSize,
      );
    } catch (e) {
      debugPrint('getBookingsPage error: $e');
      throw DomainException('Failed to fetch bookings for customer.');
    }
  }

  Future<List<BookingModel>> getBookings(String customerId) async {
    final page = await getBookingsPage(customerId);
    return page.items;
  }

  Future<BookingModel?> getBookingForCustomer({
    required String bookingId,
    required String customerId,
  }) async {
    final normalizedBookingId = bookingId.trim();
    final normalizedCustomerId = customerId.trim();
    if (normalizedBookingId.isEmpty || normalizedCustomerId.isEmpty) {
      return null;
    }

    try {
      final doc =
          await _firestore.collection('bookings').doc(normalizedBookingId).get();
      if (!doc.exists || doc.data() == null) return null;

      final data = Map<String, dynamic>.from(doc.data()!);
      if ((data['customerId'] ?? '').toString() != normalizedCustomerId) {
        return null;
      }
      data['id'] = doc.id;
      return BookingModel.fromJson(data);
    } on FirebaseException catch (e) {
      debugPrint('getBookingForCustomer error: ${e.code}');
      throw DomainException('Failed to load booking details.');
    }
  }

  static List<String> generateIntervalSlotLockIds(
    String businessId,
    String staffId,
    DateTime start,
    DateTime end,
  ) {
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
        clientRequestId: booking.clientRequestId,
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
      expectedServicePrice: booking.servicePrice,
      expectedDurationMinutes:
          booking.endDateTime.difference(booking.startDateTime).inMinutes,
      expectedCurrency: booking.currency,
      anySpecialist: booking.anySpecialist,
      clientRequestId: booking.clientRequestId,
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
    String? newStaffId,
  }) async {
    validateCanonical15MinAlignment(newStartDateTime);
    return _functionsService.rescheduleBooking(
      bookingId: bookingId,
      newRequestedStartAt: newStartDateTime,
      newStaffId: newStaffId,
    );
  }

  static bool canTransitionBookingStatus({
    required BookingStatus from,
    required BookingStatus to,
    required String actorRole,
  }) {
    if (actorRole == 'customer') {
      return to == BookingStatus.cancelled &&
          (from == BookingStatus.pending || from == BookingStatus.confirmed);
    }

    if (actorRole != 'owner') return false;

    final allowed = <BookingStatus, Set<BookingStatus>>{
      BookingStatus.pending: {
        BookingStatus.confirmed,
        BookingStatus.cancelled,
      },
      BookingStatus.confirmed: {
        BookingStatus.arrived,
        BookingStatus.inProgress,
        BookingStatus.noShow,
        BookingStatus.cancelled,
      },
      BookingStatus.arrived: {
        BookingStatus.inProgress,
        BookingStatus.cancelled,
      },
      BookingStatus.inProgress: {
        BookingStatus.completed,
        BookingStatus.cancelled,
      },
    };

    return allowed[from]?.contains(to) ?? false;
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
