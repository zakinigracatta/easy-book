enum BookingStatus { confirmed, pending, completed, cancelled }

class BookingModel {
  final String id;
  final String customerId;
  final String customerName;
  final String salonId;
  final String salonName;
  final String serviceName;
  final double servicePrice;
  final String employeeName;
  final DateTime dateTime;
  final BookingStatus status;

  BookingModel({
    required this.id,
    required this.customerId,
    required this.customerName,
    required this.salonId,
    required this.salonName,
    required this.serviceName,
    required this.servicePrice,
    required this.employeeName,
    required this.dateTime,
    required this.status,
  });

  String get statusString => status.name;

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      id: json['id'] as String? ?? '',
      customerId: json['customer_id'] as String? ?? '',
      customerName: json['customer_name'] as String? ?? 'Customer',
      salonId: json['salon_id'] as String? ?? '',
      salonName: json['salon_name'] as String? ?? 'Salon',
      serviceName: json['service_name'] as String? ?? 'Service',
      servicePrice: (json['service_price'] as num?)?.toDouble() ?? 0.0,
      employeeName: json['employee_name'] as String? ?? 'Specialist',
      dateTime: json['date_time'] != null ? DateTime.parse(json['date_time']) : DateTime.now(),
      status: BookingStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => BookingStatus.confirmed,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customer_id': customerId,
      'customer_name': customerName,
      'salon_id': salonId,
      'salon_name': salonName,
      'service_name': serviceName,
      'service_price': servicePrice,
      'employee_name': employeeName,
      'date_time': dateTime.toIso8601String(),
      'status': status.name,
    };
  }
}
