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
  SlotConflictException([
    super.message =
        'This time slot was just booked by another customer. Please choose another available time.',
  ]) : super(reason: BookingFailureReason.slotTaken);
}

class BusinessClosedException extends DomainException {
  BusinessClosedException([
    super.message =
        'The business is currently closed or not accepting online bookings.',
  ]) : super(reason: BookingFailureReason.businessClosed);
}

class EmployeeUnavailableException extends DomainException {
  EmployeeUnavailableException([
    super.message = 'The selected specialist is unavailable during this time.',
  ]) : super(reason: BookingFailureReason.employeeUnavailable);
}

class ServiceUnavailableException extends DomainException {
  ServiceUnavailableException([
    super.message =
        'The selected service is currently inactive or unavailable.',
  ]) : super(reason: BookingFailureReason.serviceUnavailable);
}

class AuthorizationException extends DomainException {
  AuthorizationException([
    super.message = 'You do not have authorization to perform this operation.',
  ]) : super(reason: BookingFailureReason.authorizationFailed);
}

class InvalidBookingTimeException extends DomainException {
  InvalidBookingTimeException([
    super.message =
        'Booking start time must be aligned to 15-minute intervals.',
  ]) : super(reason: BookingFailureReason.invalidBookingTime);
}
