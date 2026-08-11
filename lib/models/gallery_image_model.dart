import 'package:cloud_firestore/cloud_firestore.dart';

class GalleryImageModel {
  final String id;
  final String businessId;
  final String imageUrl;
  final String? thumbnailUrl;
  final String
      category; // interior, exterior, service, portfolio, beforeAfter, other
  final String caption;
  final int sortOrder;
  final DateTime createdAt;

  GalleryImageModel({
    required this.id,
    required this.businessId,
    required this.imageUrl,
    this.thumbnailUrl,
    this.category = 'portfolio',
    this.caption = '',
    this.sortOrder = 0,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory GalleryImageModel.fromJson(Map<String, dynamic> json) {
    DateTime parseDate(dynamic d) {
      if (d is Timestamp) return d.toDate();
      if (d is String) return DateTime.tryParse(d) ?? DateTime.now();
      return DateTime.now();
    }

    return GalleryImageModel(
      id: json['id'] as String? ?? '',
      businessId:
          json['businessId'] as String? ?? json['business_id'] as String? ?? '',
      imageUrl:
          json['imageUrl'] as String? ?? json['image_url'] as String? ?? '',
      thumbnailUrl:
          json['thumbnailUrl'] as String? ?? json['thumbnail_url'] as String?,
      category: json['category'] as String? ?? 'portfolio',
      caption: json['caption'] as String? ?? '',
      sortOrder: json['sortOrder'] as int? ?? json['sort_order'] as int? ?? 0,
      createdAt: parseDate(json['createdAt'] ?? json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'businessId': businessId,
      'imageUrl': imageUrl,
      if (thumbnailUrl != null) 'thumbnailUrl': thumbnailUrl,
      'category': category,
      'caption': caption,
      'sortOrder': sortOrder,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
