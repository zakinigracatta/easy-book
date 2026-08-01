class ReviewModel {
  final String id;
  final String businessId;
  final String userName;
  final String userAvatar;
  final double rating;
  final String comment;
  final DateTime createdAt;

  ReviewModel({
    required this.id,
    required this.businessId,
    required this.userName,
    required this.userAvatar,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      id: json['id'] as String? ?? '',
      businessId: json['business_id'] as String? ?? '',
      userName: json['user_name'] as String? ?? 'Anonymous',
      userAvatar: json['user_avatar'] as String? ?? '',
      rating: (json['rating'] as num?)?.toDouble() ?? 5.0,
      comment: json['comment'] as String? ?? '',
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at'] as String) 
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'business_id': businessId,
      'user_name': userName,
      'user_avatar': userAvatar,
      'rating': rating,
      'comment': comment,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
