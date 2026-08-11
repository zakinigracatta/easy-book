enum BookingFailureReason {
  slotTaken,
  businessClosed,
  notAcceptingBookings,
  employeeUnavailable,
  serviceUnavailable,
  outsideWorkingHours,
  authorizationFailed,
  invalidBookingTime,
  network,
  unknown,
}

class DomainException implements Exception {
  final String message;
  final BookingFailureReason reason;

  DomainException(this.message, {this.reason = BookingFailureReason.unknown});

  @override
  String toString() => message;
}

class SlotConflictException extends DomainException {
  SlotConflictException(
      [String message =
          'This time slot was just booked by another customer. Please choose another available time.'])
      : super(message, reason: BookingFailureReason.slotTaken);
}

class BusinessClosedException extends DomainException {
  BusinessClosedException(
      [String message =
          'The business is currently closed or not accepting online bookings.'])
      : super(message, reason: BookingFailureReason.businessClosed);
}

class EmployeeUnavailableException extends DomainException {
  EmployeeUnavailableException(
      [String message =
          'The selected specialist is unavailable during this time.'])
      : super(message, reason: BookingFailureReason.employeeUnavailable);
}

class ServiceUnavailableException extends DomainException {
  ServiceUnavailableException(
      [String message =
          'The selected service is currently inactive or unavailable.'])
      : super(message, reason: BookingFailureReason.serviceUnavailable);
}

class AuthorizationException extends DomainException {
  AuthorizationException(
      [String message =
          'You do not have authorization to perform this operation.'])
      : super(message, reason: BookingFailureReason.authorizationFailed);
}

class InvalidBookingTimeException extends DomainException {
  InvalidBookingTimeException(
      [String message =
          'Booking start time must be aligned to 15-minute intervals.'])
      : super(message, reason: BookingFailureReason.invalidBookingTime);
}
