import 'package:cloud_firestore/cloud_firestore.dart';

enum DiscountType { percentage, fixed }

class OfferModel {
  final String id;
  final String businessId;
  final String title;
  final String description;
  final DiscountType discountType;
  final double discountValue;
  final DateTime startDate;
  final DateTime endDate;
  final List<String> serviceIds;
  final bool isActive;
  final DateTime? createdAt;

  OfferModel({
    required this.id,
    required this.businessId,
    required this.title,
    required this.description,
    required this.discountType,
    required this.discountValue,
    required this.startDate,
    required this.endDate,
    this.serviceIds = const [],
    this.isActive = true,
    this.createdAt,
  });

  factory OfferModel.fromJson(Map<String, dynamic> json) {
    DateTime parseDate(dynamic d) {
      if (d is Timestamp) return d.toDate();
      if (d is String) return DateTime.tryParse(d) ?? DateTime.now();
      return DateTime.now();
    }

    final discTypeStr = json['discountType'] as String? ??
        json['discount_type'] as String? ??
        'percentage';
    final parsedType =
        discTypeStr == 'fixed' ? DiscountType.fixed : DiscountType.percentage;

    List<String> parseServices(dynamic s) {
      if (s is List) return s.map((e) => e.toString()).toList();
      return [];
    }

    return OfferModel(
      id: json['id'] as String? ?? '',
      businessId:
          json['businessId'] as String? ?? json['business_id'] as String? ?? '',
      title: json['title'] as String? ?? 'Special Offer',
      description: json['description'] as String? ?? '',
      discountType: parsedType,
      discountValue: (json['discountValue'] as num?)?.toDouble() ??
          (json['discount_value'] as num?)?.toDouble() ??
          10.0,
      startDate: parseDate(json['startDate'] ?? json['start_date']),
      endDate: parseDate(json['endDate'] ?? json['end_date']),
      serviceIds: parseServices(json['serviceIds'] ?? json['service_ids']),
      isActive: json['isActive'] as bool? ?? json['is_active'] as bool? ?? true,
      createdAt:
          json['createdAt'] != null ? parseDate(json['createdAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'businessId': businessId,
      'title': title,
      'description': description,
      'discountType': discountType.name,
      'discountValue': discountValue,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'serviceIds': serviceIds,
      'isActive': isActive,
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
    };
  }
}
