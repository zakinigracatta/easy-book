import 'staff_schedule_model.dart';

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
  final String? shiftStart;
  final String? shiftEnd;
  final List<int>? workingDays;
  final String? bio;
  final List<String> galleryUrls;
  final Map<String, StaffWorkingHours> weeklySchedule;

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
    this.bio,
    this.galleryUrls = const [],
    this.weeklySchedule = const {},
  });

  factory StaffModel.fromJson(Map<String, dynamic> json) {
    List<String> parseStringList(dynamic value) {
      if (value is List) return value.map((e) => e.toString()).toList();
      return [];
    }

    List<int>? parseDays(dynamic value) {
      if (value is List) {
        return value.map((e) => int.tryParse(e.toString()) ?? 1).toList();
      }
      return null;
    }

    Map<String, StaffWorkingHours> parseWeeklySchedule(dynamic value) {
      if (value is! Map) return const {};
      final result = <String, StaffWorkingHours>{};
      value.forEach((key, raw) {
        final day = key.toString();
        if (raw is Map) {
          result[day] = StaffWorkingHours.fromJson(
            day,
            Map<String, dynamic>.from(raw),
          );
        }
      });
      return result;
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
      serviceIds: parseStringList(json['service_ids'] ?? json['serviceIds']),
      isActive: json['is_active'] as bool? ?? json['isActive'] as bool? ?? true,
      shiftStart:
          json['shift_start'] as String? ?? json['shiftStart'] as String?,
      shiftEnd: json['shift_end'] as String? ?? json['shiftEnd'] as String?,
      workingDays: parseDays(json['working_days'] ?? json['workingDays']),
      bio: json['bio'] as String?,
      galleryUrls:
          parseStringList(json['gallery_urls'] ?? json['galleryUrls']),
      weeklySchedule: parseWeeklySchedule(
        json['weekly_schedule'] ?? json['weeklySchedule'],
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'business_id': businessId,
      'businessId': businessId,
      'name': name,
      'role_title': roleTitle,
      'roleTitle': roleTitle,
      'avatar_url': avatarUrl,
      'avatarUrl': avatarUrl,
      'rating': rating,
      'review_count': reviewCount,
      'experience_years': experienceYears,
      'service_ids': serviceIds,
      'is_active': isActive,
      'isActive': isActive,
      if (shiftStart != null) 'shift_start': shiftStart,
      if (shiftEnd != null) 'shift_end': shiftEnd,
      if (workingDays != null) 'working_days': workingDays,
      if (bio != null) 'bio': bio,
      'gallery_urls': galleryUrls,
      'weekly_schedule': {
        for (final entry in weeklySchedule.entries)
          entry.key: entry.value.toJson(),
      },
    };
  }

  StaffModel copyWith({
    String? name,
    String? roleTitle,
    String? avatarUrl,
    double? rating,
    int? reviewCount,
    int? experienceYears,
    List<String>? serviceIds,
    bool? isActive,
    String? shiftStart,
    String? shiftEnd,
    List<int>? workingDays,
    String? bio,
    List<String>? galleryUrls,
    Map<String, StaffWorkingHours>? weeklySchedule,
  }) {
    return StaffModel(
      id: id,
      businessId: businessId,
      name: name ?? this.name,
      roleTitle: roleTitle ?? this.roleTitle,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      experienceYears: experienceYears ?? this.experienceYears,
      serviceIds: serviceIds ?? this.serviceIds,
      isActive: isActive ?? this.isActive,
      shiftStart: shiftStart ?? this.shiftStart,
      shiftEnd: shiftEnd ?? this.shiftEnd,
      workingDays: workingDays ?? this.workingDays,
      bio: bio ?? this.bio,
      galleryUrls: galleryUrls ?? this.galleryUrls,
      weeklySchedule: weeklySchedule ?? this.weeklySchedule,
    );
  }
}
