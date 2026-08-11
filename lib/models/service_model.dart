class ServiceModel {
  final String id;
  final String salonId;
  final String name;
  final double price;
  final double? discountPrice;
  final String duration;
  final int durationMinutes;
  final String? imageUrl;
  final String? description;
  final String categoryId;
  final String categoryName;
  final bool isActive;
  final bool isBookable;
  final String currency;

  ServiceModel({
    required this.id,
    required this.salonId,
    required this.name,
    required this.price,
    this.discountPrice,
    required this.duration,
    required this.durationMinutes,
    this.imageUrl,
    this.description,
    this.categoryId = 'general',
    this.categoryName = 'Services',
    this.isActive = true,
    this.isBookable = true,
    this.currency = 'AED',
  });

  double get effectivePrice =>
      (discountPrice != null && discountPrice! > 0) ? discountPrice! : price;

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    int parseDurationMinutes(dynamic raw) {
      if (raw is num) return raw.toInt();
      if (raw is String) {
        final match = RegExp(r'(\d+)').firstMatch(raw);
        if (match != null) return int.parse(match.group(1)!);
      }
      return 30;
    }

    final parsedMinutes = parseDurationMinutes(
      json['duration_minutes'] ?? json['durationMinutes'] ?? json['duration'],
    );

    return ServiceModel(
      id: json['id'] as String? ?? '',
      salonId: json['salon_id'] as String? ??
          json['business_id'] as String? ??
          json['businessId'] as String? ??
          '',
      name: json['name'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      discountPrice: (json['discount_price'] ?? json['discountPrice']) != null
          ? ((json['discount_price'] ?? json['discountPrice']) as num)
              .toDouble()
          : null,
      duration: json['duration'] as String? ?? '$parsedMinutes mins',
      durationMinutes: parsedMinutes,
      imageUrl: json['image_url'] as String? ?? json['imageUrl'] as String?,
      description: json['description'] as String?,
      categoryId: json['category_id'] as String? ??
          json['categoryId'] as String? ??
          'general',
      categoryName: json['category_name'] as String? ??
          json['categoryName'] as String? ??
          json['category'] as String? ??
          'Services',
      isActive: json['is_active'] as bool? ?? json['isActive'] as bool? ?? true,
      isBookable:
          json['is_bookable'] as bool? ?? json['isBookable'] as bool? ?? true,
      currency: json['currency'] as String? ?? 'AED',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'salon_id': salonId,
      'business_id': salonId,
      'name': name,
      'price': price,
      'discount_price': discountPrice,
      'duration': duration,
      'duration_minutes': durationMinutes,
      'image_url': imageUrl,
      'description': description,
      'category_id': categoryId,
      'category_name': categoryName,
      'is_active': isActive,
      'is_bookable': isBookable,
      'currency': currency,
    };
  }
}
