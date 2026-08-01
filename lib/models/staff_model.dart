class StaffModel {
  final String id;
  final String businessId;
  final String name;
  final String roleTitle;
  final String avatarUrl;
  final double rating;

  StaffModel({
    required this.id,
    required this.businessId,
    required this.name,
    required this.roleTitle,
    required this.avatarUrl,
    required this.rating,
  });

  factory StaffModel.fromJson(Map<String, dynamic> json) {
    return StaffModel(
      id: json['id'] as String? ?? '',
      businessId: json['business_id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      roleTitle: json['role_title'] as String? ?? 'Specialist',
      avatarUrl: json['avatar_url'] as String? ?? '',
      rating: (json['rating'] as num?)?.toDouble() ?? 5.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'business_id': businessId,
      'name': name,
      'role_title': roleTitle,
      'avatar_url': avatarUrl,
      'rating': rating,
    };
  }
}
