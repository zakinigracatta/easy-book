import '../models/booking_model.dart';
import '../services/booking_service.dart';

abstract class BookingRepository {
  Future<List<BookingModel>> fetchCustomerBookings(String customerId);
  Future<BookingModel> createBooking(BookingModel booking);
  Future<bool> cancelBooking(String bookingId);
  Future<BookingModel> rescheduleBooking({
    required String bookingId,
    required DateTime newStartDateTime,
    required DateTime newEndDateTime,
  });
}

class BookingRepositoryImpl implements BookingRepository {
  BookingRepositoryImpl([BookingService? bookingService])
      : _service = bookingService ?? BookingService();

  final BookingService _service;

  @override
  Future<List<BookingModel>> fetchCustomerBookings(String customerId) {
    return _service.getBookings(customerId);
  }

  @override
  Future<BookingModel> createBooking(BookingModel booking) {
    return _service.createBooking(booking);
  }

  @override
  Future<bool> cancelBooking(String bookingId) {
    return _service.cancelBooking(
        bookingId: bookingId, cancelledBy: 'customer');
  }

  @override
  Future<BookingModel> rescheduleBooking({
    required String bookingId,
    required DateTime newStartDateTime,
    required DateTime newEndDateTime,
  }) {
    return _service.rescheduleBooking(
      bookingId: bookingId,
      newStartDateTime: newStartDateTime,
      newEndDateTime: newEndDateTime,
    );
  }
}
