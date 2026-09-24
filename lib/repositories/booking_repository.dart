import '../models/booking_model.dart';
import '../services/booking_service.dart';

abstract class BookingRepository {
  Future<List<BookingModel>> fetchCustomerBookings(String customerId);
  Future<CustomerBookingsPage> fetchCustomerBookingsPage(
    String customerId, {
    DateTime? afterStartDateTime,
    String? afterBookingId,
    int pageSize = 50,
  });
  Future<BookingModel?> fetchCustomerBookingById({
    required String bookingId,
    required String customerId,
  });
  Future<BookingModel> createBooking(BookingModel booking);
  Future<bool> cancelBooking(String bookingId);
  Future<BookingModel> rescheduleBooking({
    required String bookingId,
    required DateTime newStartDateTime,
    String? newStaffId,
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
  Future<CustomerBookingsPage> fetchCustomerBookingsPage(
    String customerId, {
    DateTime? afterStartDateTime,
    String? afterBookingId,
    int pageSize = 50,
  }) {
    return _service.getBookingsPage(
      customerId,
      afterStartDateTime: afterStartDateTime,
      afterBookingId: afterBookingId,
      pageSize: pageSize,
    );
  }

  @override
  Future<BookingModel?> fetchCustomerBookingById({
    required String bookingId,
    required String customerId,
  }) {
    return _service.getBookingForCustomer(
      bookingId: bookingId,
      customerId: customerId,
    );
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
    String? newStaffId,
  }) {
    return _service.rescheduleBooking(
      bookingId: bookingId,
      newStartDateTime: newStartDateTime,
      newStaffId: newStaffId,
    );
  }
}
