import 'package:cloud_firestore/cloud_firestore.dart';

class ReviewModel {
  final String id;
  final String businessId;
  final String userName;
  final String userAvatar;
  final double rating;
  final String comment;
  final DateTime createdAt;
  final String? serviceName;
  final String? businessReply;
  final DateTime? businessReplyAt;

  ReviewModel({
    required this.id,
    required this.businessId,
    required this.userName,
    required this.userAvatar,
    required this.rating,
    required this.comment,
    required this.createdAt,
    this.serviceName,
    this.businessReply,
    this.businessReplyAt,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(dynamic value) {
      if (value == null) return null;
      if (value is Timestamp) return value.toDate();
      if (value is DateTime) return value;
      if (value is String) return DateTime.tryParse(value);
      return null;
    }

    return ReviewModel(
      id: json['id'] as String? ?? '',
      businessId:
          json['business_id'] as String? ?? json['businessId'] as String? ?? '',
      userName: json['user_name'] as String? ??
          json['userName'] as String? ??
          'Anonymous',
      userAvatar:
          json['user_avatar'] as String? ?? json['userAvatar'] as String? ?? '',
      rating: (json['rating'] as num?)?.toDouble() ?? 5.0,
      comment: json['comment'] as String? ?? '',
      createdAt:
          parseDate(json['created_at'] ?? json['createdAt']) ?? DateTime.now(),
      serviceName:
          json['service_name'] as String? ?? json['serviceName'] as String?,
      businessReply:
          json['businessReply'] as String? ?? json['business_reply'] as String?,
      businessReplyAt:
          parseDate(json['businessReplyAt'] ?? json['business_reply_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'business_id': businessId,
      'businessId': businessId,
      'user_name': userName,
      'user_avatar': userAvatar,
      'rating': rating,
      'comment': comment,
      'created_at': createdAt.toIso8601String(),
      'service_name': serviceName,
      if (businessReply != null) 'businessReply': businessReply,
      if (businessReplyAt != null)
        'businessReplyAt': businessReplyAt!.toIso8601String(),
    };
  }

  ReviewModel copyWith({
    String? businessReply,
    DateTime? businessReplyAt,
  }) {
    return ReviewModel(
      id: id,
      businessId: businessId,
      userName: userName,
      userAvatar: userAvatar,
      rating: rating,
      comment: comment,
      createdAt: createdAt,
      serviceName: serviceName,
      businessReply: businessReply ?? this.businessReply,
      businessReplyAt: businessReplyAt ?? this.businessReplyAt,
    );
  }
}
