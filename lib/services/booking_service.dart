import '../models/booking_model.dart';
import '../data/mock_data.dart';

/// BookingService Abstraction
/// Firebase Future Migration Note:
/// Replace Mock implementation with:
/// FirebaseFirestore.instance.collection('appointments').where('customer_id', isEqualTo: customerId).get()
class BookingService {
  static const bool useFirebase = false;

  Future<List<BookingModel>> getBookings(String customerId) async {
    if (useFirebase) {
      // final snap = await FirebaseFirestore.instance
      //     .collection('appointments')
      //     .where('customer_id', isEqualTo: customerId)
      //     .get();
      // return snap.docs.map((doc) => BookingModel.fromJson(doc.data())).toList();
    }

    await Future.delayed(const Duration(milliseconds: 300));
    return MockData.bookings;
  }

  Future<BookingModel> createBooking(BookingModel booking) async {
    if (useFirebase) {
      // await FirebaseFirestore.instance.collection('appointments').doc(booking.id).set(booking.toJson());
    }

    await Future.delayed(const Duration(milliseconds: 400));
    MockData.bookings.insert(0, booking);
    return booking;
  }

  Future<bool> cancelBooking(String bookingId) async {
    if (useFirebase) {
      // await FirebaseFirestore.instance.collection('appointments').doc(bookingId).update({'status': 'cancelled'});
    }

    await Future.delayed(const Duration(milliseconds: 300));
    final idx = MockData.bookings.indexWhere((b) => b.id == bookingId);
    if (idx != -1) {
      final old = MockData.bookings[idx];
      MockData.bookings[idx] = BookingModel(
        id: old.id,
        customerId: old.customerId,
        customerName: old.customerName,
        salonId: old.salonId,
        salonName: old.salonName,
        serviceName: old.serviceName,
        servicePrice: old.servicePrice,
        employeeName: old.employeeName,
        dateTime: old.dateTime,
        status: BookingStatus.cancelled,
      );
      return true;
    }
    return false;
  }
}
