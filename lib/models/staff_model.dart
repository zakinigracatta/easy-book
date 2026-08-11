class StaffModel {
  final String id;
  final String businessId;
  final String name;
  final String roleTitle;
  final String avatarUrl;
  final double rating;
  final int reviewCount;
  final int experienceYears;
  final List<String> serviceIds;
  final bool isActive;
  final String? shiftStart; // e.g. '09:00 AM'
  final String? shiftEnd; // e.g. '06:00 PM'
  final List<int>? workingDays; // 1 = Mon, 7 = Sun

  StaffModel({
    required this.id,
    required this.businessId,
    required this.name,
    required this.roleTitle,
    required this.avatarUrl,
    required this.rating,
    this.reviewCount = 0,
    this.experienceYears = 5,
    this.serviceIds = const [],
    this.isActive = true,
    this.shiftStart,
    this.shiftEnd,
    this.workingDays,
  });

  factory StaffModel.fromJson(Map<String, dynamic> json) {
    List<String> parseServices(dynamic s) {
      if (s is List) return s.map((e) => e.toString()).toList();
      return [];
    }

    List<int>? parseDays(dynamic d) {
      if (d is List) {
        return d.map((e) => int.tryParse(e.toString()) ?? 1).toList();
      }
      return null;
    }

    return StaffModel(
      id: json['id'] as String? ?? '',
      businessId:
          json['business_id'] as String? ?? json['businessId'] as String? ?? '',
      name: json['name'] as String? ?? '',
      roleTitle: json['role_title'] as String? ??
          json['roleTitle'] as String? ??
          'Specialist',
      avatarUrl:
          json['avatar_url'] as String? ?? json['avatarUrl'] as String? ?? '',
      rating: (json['rating'] as num?)?.toDouble() ?? 5.0,
      reviewCount:
          json['review_count'] as int? ?? json['reviewCount'] as int? ?? 0,
      experienceYears: json['experience_years'] as int? ??
          json['experienceYears'] as int? ??
          5,
      serviceIds: parseServices(json['service_ids'] ?? json['serviceIds']),
      isActive: json['is_active'] as bool? ?? json['isActive'] as bool? ?? true,
      shiftStart:
          json['shift_start'] as String? ?? json['shiftStart'] as String?,
      shiftEnd: json['shift_end'] as String? ?? json['shiftEnd'] as String?,
      workingDays: parseDays(json['working_days'] ?? json['workingDays']),
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
      'review_count': reviewCount,
      'experience_years': experienceYears,
      'service_ids': serviceIds,
      'is_active': isActive,
      if (shiftStart != null) 'shift_start': shiftStart,
      if (shiftEnd != null) 'shift_end': shiftEnd,
      if (workingDays != null) 'working_days': workingDays,
    };
  }
}
