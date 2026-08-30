enum UserRole { customer, owner, businessOwner, admin, superAdmin }

class UserModel {
  final String id;
  final String email;
  final String fullName;
  final String phone;
  final String? avatarUrl;
  final UserRole role;
  final double walletBalance;
  final List<String> favoriteBusinessIds;
  final String? businessName;
  final String? category;
  final String? location;
  final String? businessImageUrl;

  UserModel({
    required this.id,
    required this.email,
    required this.fullName,
    required this.phone,
    this.avatarUrl,
    required this.role,
    this.walletBalance = 0.0,
    this.favoriteBusinessIds = const [],
    this.businessName,
    this.category,
    this.location,
    this.businessImageUrl,
  });

  String get roleString => switch (role) {
        UserRole.owner || UserRole.businessOwner => 'owner',
        UserRole.admin => 'admin',
        UserRole.superAdmin => 'super_admin',
        UserRole.customer => 'customer',
      };

  bool get isAdmin => role == UserRole.admin || role == UserRole.superAdmin;

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final roleStr = json['role'] as String? ?? 'customer';
    return UserModel(
      id: json['id'] as String? ?? '',
      email: json['email'] as String? ?? '',
      fullName: json['full_name'] as String? ??
          json['name'] as String? ??
          'Valued User',
      phone: json['phone'] as String? ?? '',
      avatarUrl:
          json['avatar_url'] as String? ?? json['profile_image'] as String?,
      role: switch (roleStr) {
        'owner' || 'businessOwner' || 'business_owner' => UserRole.owner,
        'admin' => UserRole.admin,
        'super_admin' || 'superAdmin' => UserRole.superAdmin,
        _ => UserRole.customer,
      },
      walletBalance: (json['wallet_balance'] as num?)?.toDouble() ?? 0.0,
      favoriteBusinessIds:
          List<String>.from(json['favorite_business_ids'] ?? []),
      businessName: json['business_name'] as String?,
      category: json['category'] as String?,
      location: json['location'] as String?,
      businessImageUrl: json['business_image_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'phone': phone,
      'avatar_url': avatarUrl,
      'role': roleString,
      'wallet_balance': walletBalance,
      'favorite_business_ids': favoriteBusinessIds,
      'business_name': businessName,
      'category': category,
      'location': location,
      'business_image_url': businessImageUrl,
    };
  }
}
