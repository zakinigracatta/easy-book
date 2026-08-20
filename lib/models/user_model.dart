enum UserRole { customer, owner, businessOwner, admin }

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

  String get roleString {
    if (role == UserRole.admin) return 'admin';
    if (role == UserRole.owner || role == UserRole.businessOwner) return 'owner';
    return 'customer';
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final roleStr = json['role'] as String? ?? 'customer';
    final UserRole parsedRole;
    if (roleStr == 'admin') {
      parsedRole = UserRole.admin;
    } else if (roleStr == 'owner' || roleStr == 'businessOwner') {
      parsedRole = UserRole.owner;
    } else {
      parsedRole = UserRole.customer;
    }
    return UserModel(
      id: json['id'] as String? ?? '',
      email: json['email'] as String? ?? '',
      fullName: json['full_name'] as String? ??
          json['name'] as String? ??
          'Valued User',
      phone: json['phone'] as String? ?? '',
      avatarUrl:
          json['avatar_url'] as String? ?? json['profile_image'] as String?,
      role: parsedRole,
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
