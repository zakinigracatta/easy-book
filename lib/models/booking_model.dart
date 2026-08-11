import 'package:cloud_firestore/cloud_firestore.dart';

enum BookingStatus {
  pending,
  confirmed,
  arrived,
  inProgress,
  completed,
  cancelled,
  noShow
}

class BookingModel {
  final String id;
  final String customerId;
  final String customerName;
  final String? customerPhone;
  final String businessId;
  final String businessName;
  final String serviceId;
  final String serviceName;
  final double servicePrice;
  final String staffId;
  final String staffName;
  final DateTime startDateTime;
  final DateTime endDateTime;
  final BookingStatus status;
  final String bookingSource; // 'app' or 'walkIn'
  final String? notes;
  final String? ownerNotes;
  final String? slotLockId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  BookingModel({
    required this.id,
    required this.customerId,
    required this.customerName,
    this.customerPhone,
    required this.businessId,
    required this.businessName,
    required this.serviceId,
    required this.serviceName,
    required this.servicePrice,
    required this.staffId,
    required this.staffName,
    required this.startDateTime,
    required this.endDateTime,
    required this.status,
    this.bookingSource = 'app',
    this.notes,
    this.ownerNotes,
    this.slotLockId,
    this.createdAt,
    this.updatedAt,
  });

  // Backward compatibility getters
  String get salonId => businessId;
  String get salonName => businessName;
  String get employeeName => staffName;
  DateTime get dateTime => startDateTime;
  String get statusString => status.name;
  String get computedSlotLockId =>
      slotLockId ??
      '${businessId}_${staffId}_${startDateTime.millisecondsSinceEpoch}';
  int get startTimestamp => startDateTime.millisecondsSinceEpoch;

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    DateTime parseDate(dynamic val) {
      if (val == null) return DateTime.now();
      if (val is Timestamp) return val.toDate();
      if (val is String) return DateTime.tryParse(val) ?? DateTime.now();
      if (val is int) return DateTime.fromMillisecondsSinceEpoch(val);
      return DateTime.now();
    }

    final statusStr = json['status'] as String? ?? 'pending';
    final parsedStatus = BookingStatus.values.firstWhere(
      (e) => e.name == statusStr,
      orElse: () => BookingStatus.pending,
    );

    return BookingModel(
      id: json['id'] as String? ?? json['booking_id'] as String? ?? '',
      customerId:
          json['customerId'] as String? ?? json['customer_id'] as String? ?? '',
      customerName: json['customerName'] as String? ??
          json['customer_name'] as String? ??
          'Valued Customer',
      customerPhone:
          json['customerPhone'] as String? ?? json['customer_phone'] as String?,
      businessId: json['businessId'] as String? ??
          json['business_id'] as String? ??
          json['salon_id'] as String? ??
          'b1',
      businessName: json['businessName'] as String? ??
          json['business_name'] as String? ??
          json['salon_name'] as String? ??
          'Executive Barber Lounge',
      serviceId:
          json['serviceId'] as String? ?? json['service_id'] as String? ?? 's1',
      serviceName: json['serviceName'] as String? ??
          json['service_name'] as String? ??
          'Service',
      servicePrice: (json['servicePrice'] as num?)?.toDouble() ??
          (json['service_price'] as num?)?.toDouble() ??
          0.0,
      staffId:
          json['staffId'] as String? ?? json['staff_id'] as String? ?? 'st1',
      staffName: json['staffName'] as String? ??
          json['staff_name'] as String? ??
          json['employee_name'] as String? ??
          'Specialist',
      startDateTime: parseDate(json['startDateTime'] ??
          json['start_date_time'] ??
          json['date_time']),
      endDateTime: parseDate(
          json['endDateTime'] ?? json['end_date_time'] ?? json['date_time']),
      status: parsedStatus,
      bookingSource: json['bookingSource'] as String? ??
          json['booking_source'] as String? ??
          'app',
      notes: json['notes'] as String?,
      ownerNotes:
          json['ownerNotes'] as String? ?? json['owner_notes'] as String?,
      slotLockId:
          json['slotLockId'] as String? ?? json['slot_lock_id'] as String?,
      createdAt:
          json['createdAt'] != null ? parseDate(json['createdAt']) : null,
      updatedAt:
          json['updatedAt'] != null ? parseDate(json['updatedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customerId': customerId,
      'customerName': customerName,
      if (customerPhone != null) 'customerPhone': customerPhone,
      'businessId': businessId,
      'businessName': businessName,
      'serviceId': serviceId,
      'serviceName': serviceName,
      'servicePrice': servicePrice,
      'staffId': staffId,
      'staffName': staffName,
      'startDateTime': startDateTime.toIso8601String(),
      'endDateTime': endDateTime.toIso8601String(),
      'startTimestamp': startTimestamp,
      'status': status.name,
      'bookingSource': bookingSource,
      if (notes != null) 'notes': notes,
      'slotLockId': computedSlotLockId,
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
    };
  }

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'customerId': customerId,
      'customerName': customerName,
      if (customerPhone != null) 'customerPhone': customerPhone,
      'businessId': businessId,
      'businessName': businessName,
      'serviceId': serviceId,
      'serviceName': serviceName,
      'servicePrice': servicePrice,
      'staffId': staffId,
      'staffName': staffName,
      'startDateTime': Timestamp.fromDate(startDateTime),
      'endDateTime': Timestamp.fromDate(endDateTime),
      'startTimestamp': startTimestamp,
      'status': status.name,
      'bookingSource': bookingSource,
      if (notes != null) 'notes': notes,
      'slotLockId': computedSlotLockId,
      'createdAt': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),
      'updatedAt': updatedAt != null
          ? Timestamp.fromDate(updatedAt!)
          : FieldValue.serverTimestamp(),
    };
  }

  BookingModel copyWith({
    String? id,
    String? customerId,
    String? customerName,
    String? customerPhone,
    String? businessId,
    String? businessName,
    String? serviceId,
    String? serviceName,
    double? servicePrice,
    String? staffId,
    String? staffName,
    DateTime? startDateTime,
    DateTime? endDateTime,
    BookingStatus? status,
    String? bookingSource,
    String? notes,
    String? ownerNotes,
    String? slotLockId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return BookingModel(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      businessId: businessId ?? this.businessId,
      businessName: businessName ?? this.businessName,
      serviceId: serviceId ?? this.serviceId,
      serviceName: serviceName ?? this.serviceName,
      servicePrice: servicePrice ?? this.servicePrice,
      staffId: staffId ?? this.staffId,
      staffName: staffName ?? this.staffName,
      startDateTime: startDateTime ?? this.startDateTime,
      endDateTime: endDateTime ?? this.endDateTime,
      status: status ?? this.status,
      bookingSource: bookingSource ?? this.bookingSource,
      notes: notes ?? this.notes,
      ownerNotes: ownerNotes ?? this.ownerNotes,
      slotLockId: slotLockId ?? this.slotLockId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
