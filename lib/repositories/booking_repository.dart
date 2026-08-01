import '../models/appointment_model.dart';

abstract class BookingRepository {
  Future<List<AppointmentModel>> fetchCustomerAppointments(String customerId);
  Future<AppointmentModel> createAppointment({
    required String customerId,
    required String businessId,
    required String businessName,
    required String serviceName,
    required double servicePrice,
    required String staffName,
    required DateTime dateTime,
  });
  Future<bool> cancelAppointment(String appointmentId);
}

class BookingRepositoryImpl implements BookingRepository {
  final List<AppointmentModel> _appointments = [
    AppointmentModel(
      id: 'apt_101',
      customerId: 'usr_123',
      businessId: 'b1',
      businessName: 'Executive Barber Lounge',
      serviceName: 'Executive Beard & Royal Haircut',
      servicePrice: 75.0,
      staffName: 'Marcus Vance',
      dateTime: DateTime.now().add(const Duration(days: 1, hours: 3)),
      status: AppointmentStatus.confirmed,
    ),
    AppointmentModel(
      id: 'apt_102',
      customerId: 'usr_123',
      businessId: 'b2',
      businessName: 'Velvet Glow Beauty & Spa',
      serviceName: 'Aromatherapy Deep Massage (60 min)',
      servicePrice: 120.0,
      staffName: 'Elena Rostova',
      dateTime: DateTime.now().subtract(const Duration(days: 5)),
      status: AppointmentStatus.completed,
    ),
  ];

  @override
  Future<List<AppointmentModel>> fetchCustomerAppointments(String customerId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _appointments;
  }

  @override
  Future<AppointmentModel> createAppointment({
    required String customerId,
    required String businessId,
    required String businessName,
    required String serviceName,
    required double servicePrice,
    required String staffName,
    required DateTime dateTime,
  }) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final newApt = AppointmentModel(
      id: 'apt_${DateTime.now().millisecondsSinceEpoch}',
      customerId: customerId,
      businessId: businessId,
      businessName: businessName,
      serviceName: serviceName,
      servicePrice: servicePrice,
      staffName: staffName,
      dateTime: dateTime,
      status: AppointmentStatus.confirmed,
    );
    _appointments.insert(0, newApt);
    return newApt;
  }

  @override
  Future<bool> cancelAppointment(String appointmentId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _appointments.indexWhere((a) => a.id == appointmentId);
    if (index != -1) {
      final old = _appointments[index];
      _appointments[index] = AppointmentModel(
        id: old.id,
        customerId: old.customerId,
        businessId: old.businessId,
        businessName: old.businessName,
        serviceName: old.serviceName,
        servicePrice: old.servicePrice,
        staffName: old.staffName,
        dateTime: old.dateTime,
        status: AppointmentStatus.cancelled,
      );
      return true;
    }
    return false;
  }
}
