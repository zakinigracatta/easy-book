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
  });

  factory BusinessModel.fromJson(Map<String, dynamic> json) {
    return BusinessModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? 'Unnamed Business',
      category: json['category'] as String? ?? 'Salons',
      address: json['address'] as String? ?? '',
      rating: (json['rating'] as num?)?.toDouble() ?? 5.0,
      reviewCount: json['review_count'] as int? ?? 0,
      imageUrl: json['image_url'] as String? ?? '',
      isVerified: json['is_verified'] as bool? ?? true,
      description: json['description'] as String? ?? '',
      ownerId: json['owner_id'] as String? ?? '',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
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
    };
  }
}
