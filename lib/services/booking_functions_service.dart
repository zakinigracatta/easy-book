import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';
import '../core/domain_exceptions.dart';
import '../models/booking_model.dart';

class BookingFunctionsService {
  final FirebaseFunctions _functions;

  BookingFunctionsService([FirebaseFunctions? functions])
      : _functions = functions ?? FirebaseFunctions.instance;

  String _isoWithOffset(DateTime value) {
    if (value.isUtc) return value.toIso8601String();
    final base = value.toIso8601String();
    final offset = value.timeZoneOffset;
    final sign = offset.isNegative ? '-' : '+';
    final totalMinutes = offset.inMinutes.abs();
    final hours = (totalMinutes ~/ 60).toString().padLeft(2, '0');
    final minutes = (totalMinutes % 60).toString().padLeft(2, '0');
    return '$base$sign$hours:$minutes';
  }

  Map<String, dynamic> _responseMap(dynamic raw) {
    if (raw is Map) {
      return Map<String, dynamic>.from(raw);
    }
    throw DomainException('Unexpected response from the booking server.');
  }

  String _stringValue(dynamic value, [String fallback = '']) {
    final text = value?.toString().trim();
    return (text == null || text.isEmpty) ? fallback : text;
  }

  double _doubleValue(dynamic value, [double fallback = 0.0]) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? fallback;
  }

  int _intValue(dynamic value, [int fallback = 0]) {
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? fallback;
  }

  DateTime _dateValue(dynamic value, DateTime fallback) {
    if (value is DateTime) return value.toLocal();
    final parsed = DateTime.tryParse(value?.toString() ?? '');
    return (parsed ?? fallback).toLocal();
  }

  BookingStatus _statusValue(dynamic value, BookingStatus fallback) {
    final raw = value?.toString();
    if (raw == null || raw.isEmpty) return fallback;
    return BookingStatus.values.firstWhere(
      (status) => status.name == raw,
      orElse: () => fallback,
    );
  }

  String? _nullableString(dynamic value) {
    final text = value?.toString().trim();
    return (text == null || text.isEmpty) ? null : text;
  }

  /// Invokes trusted backend createBooking Cloud Function.
  Future<BookingModel> createBooking({
    required String businessId,
    required String serviceId,
    required String staffId,
    required DateTime requestedStartAt,
    required String customerName,
    required String customerPhone,
    String notes = '',
  }) async {
    try {
      final callable = _functions.httpsCallable('createBooking');
      final response = await callable.call({
        'businessId': businessId,
        'serviceId': serviceId,
        'staffId': staffId,
        'requestedStartAt': _isoWithOffset(requestedStartAt),
        'customerName': customerName,
        'customerPhone': customerPhone,
        'notes': notes,
      });

      final resData = _responseMap(response.data);
      if (kDebugMode) {
        debugPrint('CREATE_BOOKING_RESPONSE_KEYS: ${resData.keys.toList()}');
      }

      final bookingId = _stringValue(resData['bookingId']);
      if (bookingId.isEmpty) {
        throw DomainException(
          'The booking server did not return a booking reference. Check My Bookings before trying again.',
        );
      }

      final durationMinutes = _intValue(resData['durationMinutes'], 30);
      final safeDuration = durationMinutes > 0 ? durationMinutes : 30;
      final startDateTime =
          _dateValue(resData['startDateTime'], requestedStartAt);
      final endDateTime = _dateValue(
        resData['endDateTime'],
        startDateTime.add(Duration(minutes: safeDuration)),
      );
      final slotLockId = _nullableString(resData['slotLockId']) ??
          '${businessId}_${staffId}_${startDateTime.millisecondsSinceEpoch}';

      return BookingModel(
        id: bookingId,
        customerId: _stringValue(resData['customerId']),
        customerName: _stringValue(resData['customerName'], customerName),
        customerPhone:
            _stringValue(resData['customerPhone'], customerPhone),
        businessId: _stringValue(resData['businessId'], businessId),
        businessName: _stringValue(resData['businessName']),
        serviceId: _stringValue(resData['serviceId'], serviceId),
        serviceName: _stringValue(resData['serviceName']),
        servicePrice: _doubleValue(resData['servicePrice']),
        staffId: _stringValue(resData['staffId'], staffId),
        staffName: _stringValue(resData['staffName']),
        startDateTime: startDateTime,
        endDateTime: endDateTime,
        status: _statusValue(resData['status'], BookingStatus.pending),
        bookingSource: _stringValue(resData['bookingSource'], 'app'),
        notes: _stringValue(resData['notes'], notes),
        slotLockId: slotLockId,
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
          'Failed to process booking request. Please try again.');
    }
  }

  /// Invokes trusted backend createWalkInBooking Cloud Function for business owners.
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
        'requestedStartAt': _isoWithOffset(requestedStartAt),
        'customerName': customerName,
        'customerPhone': customerPhone,
        'notes': notes,
      });

      final resData = _responseMap(response.data);
      if (kDebugMode) {
        debugPrint('CREATE_WALK_IN_RESPONSE_KEYS: ${resData.keys.toList()}');
      }

      final bookingId = _stringValue(resData['bookingId']);
      if (bookingId.isEmpty) {
        throw DomainException(
          'The booking server did not return a walk-in booking reference.',
        );
      }

      final durationMinutes = _intValue(resData['durationMinutes'], 30);
      final safeDuration = durationMinutes > 0 ? durationMinutes : 30;
      final startDateTime =
          _dateValue(resData['startDateTime'], requestedStartAt);
      final endDateTime = _dateValue(
        resData['endDateTime'],
        startDateTime.add(Duration(minutes: safeDuration)),
      );
      final slotLockId = _nullableString(resData['slotLockId']) ??
          '${businessId}_${staffId}_${startDateTime.millisecondsSinceEpoch}';

      return BookingModel(
        id: bookingId,
        customerId: _stringValue(resData['customerId']),
        customerName: _stringValue(resData['customerName'], customerName),
        customerPhone:
            _stringValue(resData['customerPhone'], customerPhone),
        businessId: _stringValue(resData['businessId'], businessId),
        businessName: _stringValue(resData['businessName']),
        serviceId: _stringValue(resData['serviceId'], serviceId),
        serviceName: _stringValue(resData['serviceName']),
        servicePrice: _doubleValue(resData['servicePrice']),
        staffId: _stringValue(resData['staffId'], staffId),
        staffName: _stringValue(resData['staffName']),
        startDateTime: startDateTime,
        endDateTime: endDateTime,
        status: _statusValue(resData['status'], BookingStatus.confirmed),
        bookingSource: _stringValue(resData['bookingSource'], 'walkIn'),
        notes: _stringValue(resData['notes'], notes),
        slotLockId: slotLockId,
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
          'Failed to create walk-in booking. Please try again.');
    }
  }

  /// Canonical cancellation path via trusted Callable Cloud Function.
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

      final resData = _responseMap(response.data);
      final success = resData['success'];
      return success is bool ? success : true;
    } on FirebaseFunctionsException catch (e) {
      debugPrint('CANCEL_BOOKING_FUNCTION_ERROR: ${e.code} - ${e.message}');
      throw _mapFunctionException(e);
    } catch (e) {
      if (e is DomainException) rethrow;
      throw DomainException('Failed to cancel booking. Please try again.');
    }
  }

  /// Reschedules an existing booking via trusted Callable Cloud Function.
  Future<BookingModel> rescheduleBooking({
    required String bookingId,
    required DateTime newRequestedStartAt,
  }) async {
    try {
      final callable = _functions.httpsCallable('rescheduleBooking');
      final response = await callable.call({
        'bookingId': bookingId,
        'newRequestedStartAt': _isoWithOffset(newRequestedStartAt),
      });

      final resData = _responseMap(response.data);
      final durationMinutes = _intValue(resData['durationMinutes'], 30);
      final safeDuration = durationMinutes > 0 ? durationMinutes : 30;
      final startDateTime =
          _dateValue(resData['startDateTime'], newRequestedStartAt);
      final endDateTime = _dateValue(
        resData['endDateTime'],
        startDateTime.add(Duration(minutes: safeDuration)),
      );

      return BookingModel(
        id: _stringValue(resData['bookingId'], bookingId),
        customerId: _stringValue(resData['customerId']),
        customerName: _stringValue(resData['customerName']),
        customerPhone: _stringValue(resData['customerPhone']),
        businessId: _stringValue(resData['businessId']),
        businessName: _stringValue(resData['businessName']),
        serviceId: _stringValue(resData['serviceId']),
        serviceName: _stringValue(resData['serviceName']),
        servicePrice: _doubleValue(resData['servicePrice']),
        staffId: _stringValue(resData['staffId']),
        staffName: _stringValue(resData['staffName']),
        startDateTime: startDateTime,
        endDateTime: endDateTime,
        status: _statusValue(resData['status'], BookingStatus.pending),
        bookingSource: _stringValue(resData['bookingSource'], 'app'),
        slotLockId: _nullableString(resData['slotLockId']),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    } on FirebaseFunctionsException catch (e) {
      debugPrint('RESCHEDULE_BOOKING_FUNCTION_ERROR: ${e.code} - ${e.message}');
      throw _mapFunctionException(e);
    } catch (e) {
      if (e is DomainException) rethrow;
      throw DomainException(
          'Failed to reschedule appointment. Please try again.');
    }
  }

  /// Updates booking status via trusted Callable Cloud Function for owners.
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

      final resData = _responseMap(response.data);
      final success = resData['success'];
      return success is bool ? success : true;
    } on FirebaseFunctionsException catch (e) {
      debugPrint('UPDATE_STATUS_FUNCTION_ERROR: ${e.code} - ${e.message}');
      throw _mapFunctionException(e);
    } catch (e) {
      if (e is DomainException) rethrow;
      throw DomainException(
          'Failed to update booking status. Please try again.');
    }
  }

  DomainException _mapFunctionException(FirebaseFunctionsException e) {
    final msg = e.message ?? e.code;

    if (e.code == 'already-exists' || msg.contains('SLOT_CONFLICT')) {
      return SlotConflictException(
          'This time slot was just booked by another customer. Please select another available time.');
    }
    if (msg.contains('BUSINESS_NOT_ACCEPTING_BOOKINGS') ||
        msg.contains('BUSINESS_NOT_FOUND')) {
      return BusinessClosedException(
          'The business is currently closed or not accepting online bookings.');
    }
    if (msg.contains('STAFF_INACTIVE') ||
        msg.contains('STAFF_NOT_WORKING_DAY') ||
        msg.contains('OUTSIDE_STAFF_SHIFT') ||
        msg.contains('STAFF_ON_LEAVE') ||
        msg.contains('STAFF_INELIGIBLE')) {
      return EmployeeUnavailableException(
          'The selected specialist is unavailable during this time slot.');
    }
    if (msg.contains('SERVICE_NOT_FOUND') || msg.contains('SERVICE_INACTIVE')) {
      return ServiceUnavailableException(
          'The selected service is currently unavailable.');
    }
    if (e.code == 'permission-denied' || e.code == 'unauthenticated') {
      return AuthorizationException(
          'You are not authorized to perform this booking operation.');
    }
    if (msg.contains('INVALID_CANONICAL_ALIGNMENT')) {
      return InvalidBookingTimeException(
          'Appointment start time must be aligned to 15-minute intervals.');
    }

    return DomainException('Booking transaction error: $msg');
  }
}
