import 'package:cloud_firestore/cloud_firestore.dart';

enum OwnerNotificationType { newBooking, bookingCancelled, bookingRescheduled, newReview, customerArrived, system }

class OwnerNotificationModel {
  final String id;
  final String businessId;
  final String title;
  final String body;
  final OwnerNotificationType type;
  final DateTime createdAt;
  final DateTime? readAt;
  final bool isRead;
  final String? relatedBookingId;

  OwnerNotificationModel({
    required this.id,
    required this.businessId,
    required this.title,
    required this.body,
    required this.type,
    DateTime? createdAt,
    this.readAt,
    this.isRead = false,
    this.relatedBookingId,
  }) : createdAt = createdAt ?? DateTime.now();

  factory OwnerNotificationModel.fromJson(Map<String, dynamic> json) {
    DateTime parseDate(dynamic d) {
      if (d is Timestamp) return d.toDate();
      if (d is String) return DateTime.tryParse(d) ?? DateTime.now();
      return DateTime.now();
    }

    final typeStr = json['type'] as String? ?? 'newBooking';
    final parsedType = OwnerNotificationType.values.firstWhere(
      (e) => e.name == typeStr,
      orElse: () => OwnerNotificationType.system,
    );

    return OwnerNotificationModel(
      id: json['id'] as String? ?? '',
      businessId: json['businessId'] as String? ?? json['business_id'] as String? ?? '',
      title: json['title'] as String? ?? 'Notification',
      body: json['body'] as String? ?? '',
      type: parsedType,
      createdAt: parseDate(json['createdAt'] ?? json['created_at']),
      readAt: json['readAt'] != null ? parseDate(json['readAt']) : null,
      isRead: json['isRead'] as bool? ?? json['is_read'] as bool? ?? false,
      relatedBookingId: json['relatedBookingId'] as String? ?? json['related_booking_id'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'businessId': businessId,
      'title': title,
      'body': body,
      'type': type.name,
      'createdAt': createdAt.toIso8601String(),
      if (readAt != null) 'readAt': readAt!.toIso8601String(),
      'isRead': isRead,
      if (relatedBookingId != null) 'relatedBookingId': relatedBookingId,
    };
  }
}
