class EmployeeModel {
  final String id;
  final String salonId;
  final String name;
  final String role;
  final double rating;
  final String avatarUrl;
  final bool isAvailable;
  final String shiftHours;

  EmployeeModel({
    required this.id,
    required this.salonId,
    required this.name,
    required this.role,
    this.rating = 4.9,
    required this.avatarUrl,
    this.isAvailable = true,
    this.shiftHours = '09:00 AM - 05:00 PM',
  });

  factory EmployeeModel.fromJson(Map<String, dynamic> json) {
    return EmployeeModel(
      id: json['id'] as String? ?? '',
      salonId: json['salon_id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      role: json['role'] as String? ?? 'Stylist',
      rating: (json['rating'] as num?)?.toDouble() ?? 4.9,
      avatarUrl: json['avatar_url'] as String? ?? '',
      isAvailable: json['is_available'] as bool? ?? true,
      shiftHours: json['shift_hours'] as String? ?? '09:00 AM - 05:00 PM',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'salon_id': salonId,
      'name': name,
      'role': role,
      'rating': rating,
      'avatar_url': avatarUrl,
      'is_available': isAvailable,
      'shift_hours': shiftHours,
    };
  }
}
