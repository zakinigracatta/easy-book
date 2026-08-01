class SalonModel {
  final String id;
  final String name;
  final String category;
  final String address;
  final double rating;
  final int reviewCount;
  final String imageUrl;
  final bool isVerified;
  final String ownerId;
  final String description;

  SalonModel({
    required this.id,
    required this.name,
    required this.category,
    required this.address,
    required this.rating,
    required this.reviewCount,
    required this.imageUrl,
    this.isVerified = true,
    required this.ownerId,
    required this.description,
  });

  factory SalonModel.fromJson(Map<String, dynamic> json) {
    return SalonModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      category: json['category'] as String? ?? 'Barber',
      address: json['address'] as String? ?? '',
      rating: (json['rating'] as num?)?.toDouble() ?? 4.9,
      reviewCount: json['review_count'] as int? ?? 100,
      imageUrl: json['image_url'] as String? ?? '',
      isVerified: json['is_verified'] as bool? ?? true,
      ownerId: json['owner_id'] as String? ?? '',
      description: json['description'] as String? ?? '',
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
      'owner_id': ownerId,
      'description': description,
    };
  }
}
