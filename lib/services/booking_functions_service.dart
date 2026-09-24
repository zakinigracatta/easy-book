import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';

import '../core/domain_exceptions.dart';
import '../models/booking_model.dart';

class BookingFunctionsService {
  final FirebaseFunctions _functions;

  BookingFunctionsService([FirebaseFunctions? functions])
      : _functions = functions ?? FirebaseFunctions.instance;

  String _utcIso(DateTime value) => value.toUtc().toIso8601String();

  Future<BookingModel> createBooking({
    required String businessId,
    required String serviceId,
    required String staffId,
    required DateTime requestedStartAt,
    required String customerName,
    required String customerPhone,
    required double expectedServicePrice,
    required int expectedDurationMinutes,
    required String expectedCurrency,
    bool anySpecialist = false,
    String? clientRequestId,
    String notes = '',
  }) async {
    try {
      final callable = _functions.httpsCallable('createBooking');
      final response = await callable.call({
        'businessId': businessId,
        'serviceId': serviceId,
        'staffId': staffId,
        'requestedStartAt': _utcIso(requestedStartAt),
        'customerName': customerName,
        'customerPhone': customerPhone,
        'expectedServicePrice': expectedServicePrice,
        'expectedDurationMinutes': expectedDurationMinutes,
        'expectedCurrency': expectedCurrency.trim().isEmpty
            ? 'AED'
            : expectedCurrency.trim(),
        'anySpecialist': anySpecialist,
        if (clientRequestId != null && clientRequestId.trim().isNotEmpty)
          'clientRequestId': clientRequestId.trim(),
        'notes': notes,
      });

      final resData = Map<String, dynamic>.from(response.data as Map);
      final bookingId = resData['bookingId'] as String;
      final servicePrice = (resData['servicePrice'] as num).toDouble();
      final currency = (resData['currency'] ?? 'AED').toString();
      final timeZone = (resData['timeZone'] ?? 'Asia/Dubai').toString();
      final endDateTime =
          DateTime.parse(resData['endDateTime'] as String).toLocal();
      final resolvedStaffId = (resData['staffId'] ?? staffId).toString();
      final resolvedStaffName = (resData['staffName'] ?? '').toString();

      return BookingModel(
        id: bookingId,
        customerId: '',
        customerName: customerName,
        customerPhone: customerPhone,
        businessId: businessId,
        businessName: '',
        serviceId: serviceId,
        serviceName: '',
        servicePrice: servicePrice,
        currency: currency,
        timeZone: timeZone,
        staffId: resolvedStaffId,
        staffName: resolvedStaffName,
        startDateTime: requestedStartAt,
        endDateTime: endDateTime,
        status: BookingStatus.pending,
        bookingSource: 'app',
        notes: notes,
        slotLockId:
            '${businessId}_${resolvedStaffId}_${requestedStartAt.millisecondsSinceEpoch}',
        clientRequestId: clientRequestId,
        anySpecialist: anySpecialist,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    } on FirebaseFunctionsException catch (e) {
      debugPrint('CREATE_BOOKING_FUNCTION_ERROR: ${e.code} - ${e.message}');
      throw _mapFunctionException(e);
    } catch (e) {
      if (e is DomainException) rethrow;
      debugPrint('CREATE_BOOKING_UNKNOWN_ERROR: $e');
      throw DomainException(
        'Failed to process booking request. Please try again.',
      );
    }
  }

  Future<BookingModel> createWalkInBooking({
    required String businessId,
    required String serviceId,
    required String staffId,
    required DateTime requestedStartAt,
    required String customerName,
    required String customerPhone,
    String notes = '',
  }) async {
    try {
      final callable = _functions.httpsCallable('createWalkInBooking');
      final response = await callable.call({
        'businessId': businessId,
        'serviceId': serviceId,
        'staffId': staffId,
        'requestedStartAt': _utcIso(requestedStartAt),
        'customerName': customerName,
        'customerPhone': customerPhone,
        'notes': notes,
      });

      final resData = Map<String, dynamic>.from(response.data as Map);
      final bookingId = resData['bookingId'] as String;
      final servicePrice = (resData['servicePrice'] as num).toDouble();
      final currency = (resData['currency'] ?? 'AED').toString();
      final timeZone = (resData['timeZone'] ?? 'Asia/Dubai').toString();
      final endDateTime =
          DateTime.parse(resData['endDateTime'] as String).toLocal();

      return BookingModel(
        id: bookingId,
        customerId: '',
        customerName: customerName,
        customerPhone: customerPhone,
        businessId: businessId,
        businessName: '',
        serviceId: serviceId,
        serviceName: '',
        servicePrice: servicePrice,
        currency: currency,
        timeZone: timeZone,
        staffId: staffId,
        staffName: '',
        startDateTime: requestedStartAt,
        endDateTime: endDateTime,
        status: BookingStatus.confirmed,
        bookingSource: 'walkIn',
        notes: notes,
        slotLockId:
            '${businessId}_${staffId}_${requestedStartAt.millisecondsSinceEpoch}',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    } on FirebaseFunctionsException catch (e) {
      debugPrint('CREATE_WALK_IN_FUNCTION_ERROR: ${e.code} - ${e.message}');
      throw _mapFunctionException(e);
    } catch (e) {
      if (e is DomainException) rethrow;
      debugPrint('CREATE_WALK_IN_UNKNOWN_ERROR: $e');
      throw DomainException(
        'Failed to create walk-in booking. Please try again.',
      );
    }
  }

  Future<bool> cancelBooking({
    required String bookingId,
    String? cancelReason,
  }) async {
    try {
      final callable = _functions.httpsCallable('cancelBooking');
      final response = await callable.call({
        'bookingId': bookingId,
        if (cancelReason != null && cancelReason.isNotEmpty)
          'cancelReason': cancelReason,
      });

      final resData = Map<String, dynamic>.from(response.data as Map);
      return resData['success'] as bool? ?? true;
    } on FirebaseFunctionsException catch (e) {
      debugPrint('CANCEL_BOOKING_FUNCTION_ERROR: ${e.code} - ${e.message}');
      throw _mapFunctionException(e);
    } catch (e) {
      if (e is DomainException) rethrow;
      throw DomainException('Failed to cancel booking. Please try again.');
    }
  }

  Future<BookingModel> rescheduleBooking({
    required String bookingId,
    required DateTime newRequestedStartAt,
    String? newStaffId,
  }) async {
    try {
      final callable = _functions.httpsCallable('rescheduleBooking');
      final response = await callable.call({
        'bookingId': bookingId,
        'newRequestedStartAt': _utcIso(newRequestedStartAt),
        if (newStaffId != null && newStaffId.trim().isNotEmpty)
          'newStaffId': newStaffId.trim(),
      });

      final resData = Map<String, dynamic>.from(response.data as Map);
      final endDateTime =
          DateTime.parse(resData['endDateTime'] as String).toLocal();
      final responseStatus = (resData['status'] ?? 'pending').toString();
      final status = BookingStatus.values.firstWhere(
        (value) => value.name == responseStatus,
        orElse: () => BookingStatus.pending,
      );
      final resolvedStaffId = (resData['staffId'] ?? newStaffId ?? '').toString();
      final resolvedStaffName = (resData['staffName'] ?? '').toString();

      return BookingModel(
        id: bookingId,
        customerId: '',
        customerName: '',
        customerPhone: '',
        businessId: '',
        businessName: '',
        serviceId: '',
        serviceName: '',
        servicePrice: 0.0,
        staffId: resolvedStaffId,
        staffName: resolvedStaffName,
        startDateTime: newRequestedStartAt,
        endDateTime: endDateTime,
        status: status,
        bookingSource: 'app',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    } on FirebaseFunctionsException catch (e) {
      debugPrint('RESCHEDULE_BOOKING_FUNCTION_ERROR: ${e.code} - ${e.message}');
      throw _mapFunctionException(e);
    } catch (e) {
      if (e is DomainException) rethrow;
      throw DomainException(
        'Failed to reschedule appointment. Please try again.',
      );
    }
  }

  Future<bool> updateBookingStatus({
    required String bookingId,
    required BookingStatus newStatus,
  }) async {
    try {
      final callable = _functions.httpsCallable('updateBookingStatus');
      final response = await callable.call({
        'bookingId': bookingId,
        'newStatus': newStatus.name,
      });

      final resData = Map<String, dynamic>.from(response.data as Map);
      return resData['success'] as bool? ?? true;
    } on FirebaseFunctionsException catch (e) {
      debugPrint('UPDATE_STATUS_FUNCTION_ERROR: ${e.code} - ${e.message}');
      throw _mapFunctionException(e);
    } catch (e) {
      if (e is DomainException) rethrow;
      throw DomainException(
        'Failed to update booking status. Please try again.',
      );
    }
  }

  DomainException _mapFunctionException(FirebaseFunctionsException e) {
    final msg = e.message ?? e.code;

    if (e.code == 'already-exists' || msg.contains('SLOT_CONFLICT')) {
      return SlotConflictException(
        'This time slot was just booked by another customer. Please select another available time.',
      );
    }
    if (msg.contains('BUSINESS_NOT_ACCEPTING_BOOKINGS') ||
        msg.contains('BUSINESS_NOT_FOUND') ||
        msg.contains('BUSINESS_NOT_VERIFIED') ||
        msg.contains('BUSINESS_NOT_PUBLISHED') ||
        msg.contains('OUTSIDE_BUSINESS_HOURS')) {
      return BusinessClosedException(
        msg.contains('OUTSIDE_BUSINESS_HOURS')
            ? 'The selected time is outside the business operating hours.'
            : 'The business is not currently available for public booking.',
      );
    }
    if (msg.contains('STAFF_INACTIVE') ||
        msg.contains('STAFF_NOT_WORKING_DAY') ||
        msg.contains('OUTSIDE_STAFF_SHIFT') ||
        msg.contains('STAFF_ON_BREAK') ||
        msg.contains('STAFF_ON_LEAVE') ||
        msg.contains('STAFF_INELIGIBLE') ||
        msg.contains('STAFF_SCHEDULE_NOT_CONFIGURED')) {
      return EmployeeUnavailableException(
        'The selected specialist is unavailable during this time slot.',
      );
    }
    if (msg.contains('BOOKING_TERMS_CHANGED')) {
      return ServiceUnavailableException(
        'The service price or duration changed. Please review the service again before confirming.',
      );
    }
    if (msg.contains('SERVICE_NOT_FOUND') ||
        msg.contains('SERVICE_INACTIVE') ||
        msg.contains('INVALID_SERVICE_PRICE') ||
        msg.contains('INVALID_SERVICE_DURATION')) {
      return ServiceUnavailableException(
        'The selected service is currently unavailable.',
      );
    }
    if (msg.contains('EMAIL_NOT_VERIFIED')) {
      return AuthorizationException(
        'Please verify your email address before booking.',
      );
    }
    if (e.code == 'permission-denied' || e.code == 'unauthenticated') {
      return AuthorizationException(
        'You are not authorized to perform this booking operation.',
      );
    }
    if (msg.contains('CANNOT_CANCEL')) {
      return DomainException(
        'This appointment can no longer be cancelled.',
      );
    }
    if (msg.contains('CANNOT_RESCHEDULE')) {
      return DomainException(
        'This appointment can no longer be rescheduled.',
      );
    }
    if (msg.contains('INVALID_CANONICAL_ALIGNMENT') ||
        msg.contains('START_TIME_IN_PAST') ||
        msg.contains('START_TIME_TOO_SOON') ||
        msg.contains('START_TIME_TOO_FAR') ||
        msg.contains('INVALID_BOOKING_INTERVAL')) {
      return InvalidBookingTimeException(
        msg.contains('START_TIME_TOO_SOON')
            ? 'Please select an appointment at least 30 minutes from now.'
            : msg.contains('START_TIME_TOO_FAR')
                ? 'Please select an appointment within the next 60 days.'
                : msg.contains('START_TIME_IN_PAST')
                    ? 'Please select a future appointment time.'
                    : 'Appointment start time must be aligned to 15-minute intervals.',
      );
    }

    return DomainException(
      'We could not complete the booking operation. Please try again.',
    );
  }
}
