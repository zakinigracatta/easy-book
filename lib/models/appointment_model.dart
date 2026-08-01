enum AppointmentStatus { pending, confirmed, completed, cancelled }

class AppointmentModel {
  final String id;
  final String customerId;
  final String businessId;
  final String businessName;
  final String serviceName;
  final double servicePrice;
  final String staffName;
  final DateTime dateTime;
  final AppointmentStatus status;

  AppointmentModel({
    required this.id,
    required this.customerId,
    required this.businessId,
    required this.businessName,
    required this.serviceName,
    required this.servicePrice,
    required this.staffName,
    required this.dateTime,
    required this.status,
  });

  factory AppointmentModel.fromJson(Map<String, dynamic> json) {
    return AppointmentModel(
      id: json['id'] as String? ?? '',
      customerId: json['customer_id'] as String? ?? '',
      businessId: json['business_id'] as String? ?? '',
      businessName: json['business_name'] as String? ?? '',
      serviceName: json['service_name'] as String? ?? '',
      servicePrice: (json['service_price'] as num?)?.toDouble() ?? 0.0,
      staffName: json['staff_name'] as String? ?? '',
      dateTime: json['date_time'] != null
          ? DateTime.parse(json['date_time'] as String)
          : DateTime.now(),
      status: AppointmentStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => AppointmentStatus.confirmed,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customer_id': customerId,
      'business_id': businessId,
      'business_name': businessName,
      'service_name': serviceName,
      'service_price': servicePrice,
      'staff_name': staffName,
      'date_time': dateTime.toIso8601String(),
      'status': status.name,
    };
  }
}
