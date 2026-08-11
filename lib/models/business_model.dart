import 'working_hours_model.dart';

enum BusinessOperationalStatus { open, closed, temporarilyClosed }

class BusinessModel {
  final String id;
  final String name;
  final String category;
  final String address;
  final double rating;
  final int reviewCount;
  final String imageUrl;
  final bool isVerified;
  final String description;
  final String ownerId;
  final double latitude;
  final double longitude;
  final WorkingHoursModel workingHours;
  final List<String> amenities;
  final String? phone;
  final String? website;
  final List<String> galleryUrls;
  final bool isActive; // Platform level entity active state
  final String businessStatus; // 'open', 'closed', 'temporarilyClosed'
  final bool acceptingBookings; // Online booking availability state
  final DateTime? createdAt;
  final DateTime? updatedAt;

  BusinessModel({
    required this.id,
    required this.name,
    required this.category,
    required this.address,
    required this.rating,
    required this.reviewCount,
    required this.imageUrl,
    this.isVerified = true,
    required this.description,
    required this.ownerId,
    this.latitude = 0.0,
    this.longitude = 0.0,
    WorkingHoursModel? workingHours,
    this.amenities = const [
      'Wi-Fi',
      'Parking',
      'Card Payment',
      'Wheelchair Access'
    ],
    this.phone,
    this.website,
    this.galleryUrls = const [],
    this.isActive = true,
    String? businessStatus,
    bool? acceptingBookings,
    this.createdAt,
    this.updatedAt,
  })  : workingHours = workingHours ?? WorkingHoursModel.defaultSchedule(),
        businessStatus = businessStatus ?? 'open',
        acceptingBookings = (businessStatus == 'closed' ||
                businessStatus == 'temporarilyClosed')
            ? false
            : (acceptingBookings ?? true);

  factory BusinessModel.fromJson(Map<String, dynamic> json) {
    List<String> parseStringList(dynamic list) {
      if (list is List) {
        return list.map((e) => e.toString()).toList();
      }
      return [];
    }

    final rawStatus = json['business_status'] as String? ??
        json['businessStatus'] as String? ??
        'open';
    final rawAccepting = json['accepting_bookings'] as bool? ??
        json['acceptingBookings'] as bool? ??
        true;

    return BusinessModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? 'Unnamed Business',
      category: json['category'] as String? ?? 'Salons',
      address: json['address'] as String? ?? '',
      rating: (json['rating'] as num?)?.toDouble() ?? 5.0,
      reviewCount:
          json['review_count'] as int? ?? json['reviewCount'] as int? ?? 0,
      imageUrl:
          json['image_url'] as String? ?? json['imageUrl'] as String? ?? '',
      isVerified:
          json['is_verified'] as bool? ?? json['isVerified'] as bool? ?? true,
      description: json['description'] as String? ?? '',
      ownerId: json['owner_id'] as String? ?? json['ownerId'] as String? ?? '',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      workingHours: json['working_hours'] is Map<String, dynamic>
          ? WorkingHoursModel.fromJson(
              json['working_hours'] as Map<String, dynamic>)
          : json['workingHours'] is Map<String, dynamic>
              ? WorkingHoursModel.fromJson(
                  json['workingHours'] as Map<String, dynamic>)
              : WorkingHoursModel.defaultSchedule(),
      amenities: json['amenities'] != null
          ? parseStringList(json['amenities'])
          : const ['Wi-Fi', 'Parking', 'Card Payment', 'Wheelchair Access'],
      phone: json['phone'] as String?,
      website: json['website'] as String?,
      galleryUrls: parseStringList(json['gallery_urls'] ?? json['galleryUrls']),
      isActive: json['is_active'] as bool? ?? json['isActive'] as bool? ?? true,
      businessStatus: rawStatus,
      acceptingBookings: rawAccepting,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'address': address,
      'rating': rating,
      'review_count': reviewCount,
      'image_url': imageUrl,
      'is_verified': isVerified,
      'description': description,
      'owner_id': ownerId,
      'latitude': latitude,
      'longitude': longitude,
      'working_hours': workingHours.toJson(),
      'amenities': amenities,
      'phone': phone,
      'website': website,
      'gallery_urls': galleryUrls,
      'is_active': isActive,
      'business_status': businessStatus,
      'accepting_bookings': acceptingBookings,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  BusinessModel copyWith({
    String? id,
    String? name,
    String? category,
    String? address,
    double? rating,
    int? reviewCount,
    String? imageUrl,
    bool? isVerified,
    String? description,
    String? ownerId,
    double? latitude,
    double? longitude,
    WorkingHoursModel? workingHours,
    List<String>? amenities,
    String? phone,
    String? website,
    List<String>? galleryUrls,
    bool? isActive,
    String? businessStatus,
    bool? acceptingBookings,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    final nextStatus = businessStatus ?? this.businessStatus;
    final nextAccepting =
        (nextStatus == 'closed' || nextStatus == 'temporarilyClosed')
            ? false
            : (acceptingBookings ?? this.acceptingBookings);

    return BusinessModel(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      address: address ?? this.address,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      imageUrl: imageUrl ?? this.imageUrl,
      isVerified: isVerified ?? this.isVerified,
      description: description ?? this.description,
      ownerId: ownerId ?? this.ownerId,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      workingHours: workingHours ?? this.workingHours,
      amenities: amenities ?? this.amenities,
      phone: phone ?? this.phone,
      website: website ?? this.website,
      galleryUrls: galleryUrls ?? this.galleryUrls,
      isActive: isActive ?? this.isActive,
      businessStatus: nextStatus,
      acceptingBookings: nextAccepting,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
