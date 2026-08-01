class ServiceModel {
  final String id;
  final String salonId;
  final String name;
  final double price;
  final String duration;
  final String? imageUrl;
  final String? description;

  ServiceModel({
    required this.id,
    required this.salonId,
    required this.name,
    required this.price,
    required this.duration,
    this.imageUrl,
    this.description,
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    return ServiceModel(
      id: json['id'] as String? ?? '',
      salonId: json['salon_id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      duration: json['duration'] as String? ?? '30 mins',
      imageUrl: json['image_url'] as String?,
      description: json['description'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'salon_id': salonId,
      'name': name,
      'price': price,
      'duration': duration,
      'image_url': imageUrl,
      'description': description,
    };
  }
}
