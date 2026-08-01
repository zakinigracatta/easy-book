import '../models/business_model.dart';

abstract class BusinessRepository {
  Future<List<BusinessModel>> fetchBusinesses({String? category, String? query});
  Future<BusinessModel?> fetchBusinessById(String id);
}

class BusinessRepositoryImpl implements BusinessRepository {
  static final List<BusinessModel> _seedBusinesses = [
    BusinessModel(
      id: 'b1',
      name: 'Executive Barber Lounge',
      category: 'Barbers',
      address: '142 Luxury Blvd, Downtown',
      rating: 4.9,
      reviewCount: 328,
      imageUrl: 'https://images.unsplash.com/photo-1503951914875-452162b0f3f1?auto=format&fit=crop&w=600&q=80',
      isVerified: true,
      description: 'Premimum grooming experience for the modern gentleman with luxury drinks and hot towel treatment.',
      ownerId: 'own_1',
    ),
    BusinessModel(
      id: 'b2',
      name: 'Velvet Glow Beauty & Spa',
      category: 'Spa & Massage',
      address: '88 Serenity Way, Upper West',
      rating: 4.8,
      reviewCount: 215,
      imageUrl: 'https://images.unsplash.com/photo-1560750588-73207b1ef5b8?auto=format&fit=crop&w=600&q=80',
      isVerified: true,
      description: 'Holistic skin rejuvenation, therapeutic deep tissue massages, and organic body wraps.',
      ownerId: 'own_2',
    ),
    BusinessModel(
      id: 'b3',
      name: 'Aura Hair & Style Studio',
      category: 'Hair Salons',
      address: '504 Fashion St, Arts District',
      rating: 4.95,
      reviewCount: 540,
      imageUrl: 'https://images.unsplash.com/photo-1522337360788-8b13dee7a37e?auto=format&fit=crop&w=600&q=80',
      isVerified: true,
      description: 'Master colorists, balayage specialists, and precision hair couture styling.',
      ownerId: 'own_3',
    ),
    BusinessModel(
      id: 'b4',
      name: 'Opal Couture Nail Bar',
      category: 'Nail Salons',
      address: '22 Crystal Galleria, Midtown',
      rating: 4.7,
      reviewCount: 180,
      imageUrl: 'https://images.unsplash.com/photo-1604654894610-df63bc536371?auto=format&fit=crop&w=600&q=80',
      isVerified: true,
      description: 'Custom Japanese gel nail art, luxury pedicure spa chairs, and non-toxic treatments.',
      ownerId: 'own_4',
    ),
  ];

  @override
  Future<List<BusinessModel>> fetchBusinesses({String? category, String? query}) async {
    await Future.delayed(const Duration(milliseconds: 300));
    var results = _seedBusinesses;
    if (category != null && category != 'all') {
      results = results.where((b) => b.category.toLowerCase().contains(category.toLowerCase())).toList();
    }
    if (query != null && query.isNotEmpty) {
      results = results.where((b) => 
        b.name.toLowerCase().contains(query.toLowerCase()) || 
        b.address.toLowerCase().contains(query.toLowerCase())
      ).toList();
    }
    return results;
  }

  @override
  Future<BusinessModel?> fetchBusinessById(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    try {
      return _seedBusinesses.firstWhere((b) => b.id == id);
    } catch (_) {
      return _seedBusinesses.first;
    }
  }
}
