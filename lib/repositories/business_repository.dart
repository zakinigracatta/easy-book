import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/business_model.dart';
import '../models/service_model.dart';
import '../models/staff_model.dart';
import '../models/review_model.dart';
import '../models/working_hours_model.dart';

abstract class BusinessRepository {
  Future<List<BusinessModel>> fetchBusinesses(
      {String? category, String? query});
  Future<BusinessModel?> fetchBusinessById(String id);
  Future<List<ServiceModel>> fetchServices(String businessId);
  Future<List<StaffModel>> fetchStaff(String businessId);
  Future<List<ReviewModel>> fetchReviews(String businessId);
}

class BusinessRepositoryImpl implements BusinessRepository {
  BusinessRepositoryImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  @override
  Future<List<BusinessModel>> fetchBusinesses(
      {String? category, String? query}) async {
    try {
      final snap = await _firestore.collection('businesses').get();
      final list = snap.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return BusinessModel.fromJson(data);
      }).toList();

      if (list.isEmpty) {
        return _parseAndFilter(_getMockBusinesses(), category, query);
      }
      return _parseAndFilter(list, category, query);
    } catch (e) {
      if (e is FirebaseException && e.code == 'permission-denied') {
        rethrow;
      }
      return _parseAndFilter(_getMockBusinesses(), category, query);
    }
  }

  List<BusinessModel> _parseAndFilter(
      List<BusinessModel> list, String? category, String? query) {
    var results = list;
    if (category != null && category != 'all' && category.isNotEmpty) {
      results = results
          .where(
              (b) => b.category.toLowerCase().contains(category.toLowerCase()))
          .toList();
    }
    if (query != null && query.isNotEmpty) {
      results = results
          .where((b) =>
              b.name.toLowerCase().contains(query.toLowerCase()) ||
              b.address.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
    return results;
  }

  @override
  Future<BusinessModel?> fetchBusinessById(String id) async {
    if (id.isEmpty) return null;
    try {
      final doc = await _firestore.collection('businesses').doc(id).get();
      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        data['id'] = doc.id;
        return BusinessModel.fromJson(data);
      }
    } catch (e) {
      if (e is FirebaseException && e.code == 'permission-denied') {
        rethrow;
      }
    }
    // Fallback for mock/sample business IDs
    final mocks = _getMockBusinesses();
    final match = mocks.where((b) => b.id == id).toList();
    if (match.isNotEmpty) return match.first;
    return mocks.isNotEmpty ? mocks.first : null;
  }

  @override
  Future<List<ServiceModel>> fetchServices(String businessId) async {
    if (businessId.isEmpty) return [];
    try {
      final snap = await _firestore
          .collection('businesses')
          .doc(businessId)
          .collection('services')
          .get();
      final list = snap.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return ServiceModel.fromJson(data);
      }).toList();

      if (list.isNotEmpty) return list;
    } catch (e) {
      if (e is FirebaseException && e.code == 'permission-denied') {
        rethrow;
      }
    }
    return _getMockServices(businessId);
  }

  @override
  Future<List<StaffModel>> fetchStaff(String businessId) async {
    if (businessId.isEmpty) return [];
    try {
      final snap = await _firestore
          .collection('businesses')
          .doc(businessId)
          .collection('staff')
          .get();
      final list = snap.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return StaffModel.fromJson(data);
      }).toList();

      if (list.isNotEmpty) return list;
    } catch (e) {
      if (e is FirebaseException && e.code == 'permission-denied') {
        rethrow;
      }
    }
    return _getMockStaff(businessId);
  }

  @override
  Future<List<ReviewModel>> fetchReviews(String businessId) async {
    if (businessId.isEmpty) return [];
    try {
      final snap = await _firestore
          .collection('businesses')
          .doc(businessId)
          .collection('reviews')
          .get();
      final list = snap.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return ReviewModel.fromJson(data);
      }).toList();

      if (list.isNotEmpty) return list;
    } catch (e) {
      if (e is FirebaseException && e.code == 'permission-denied') {
        rethrow;
      }
    }
    return _getMockReviews(businessId);
  }

  // --- Fallback Mock Data ---
  List<BusinessModel> _getMockBusinesses() {
    return [
      BusinessModel(
        id: 'b1',
        name: 'Executive Barber Lounge',
        category: 'Men\'s Salon • Barber',
        address: 'Dubai Marina, Marina Gate 2, Dubai, UAE',
        rating: 4.9,
        reviewCount: 326,
        imageUrl:
            'https://images.unsplash.com/photo-1503951914875-452162b0f3f1?auto=format&fit=crop&w=800&q=80',
        isVerified: true,
        description:
            'Premium luxury grooming lounge offering master haircutting, hot towel beard sculpting, executive skin treatments, and complimentary espresso.',
        ownerId: 'owner_202',
        phone: '+971 4 399 1234',
        website: 'https://executivebarber.ae',
        latitude: 25.07725,
        longitude: 55.13998,
        amenities: [
          'Wi-Fi',
          'VIP Parking',
          'Card Payment',
          'Beverage Bar',
          'Wheelchair Access'
        ],
        galleryUrls: [
          'https://images.unsplash.com/photo-1503951914875-452162b0f3f1?auto=format&fit=crop&w=800&q=80',
          'https://images.unsplash.com/photo-1585747860715-2ba37e788b70?auto=format&fit=crop&w=800&q=80',
          'https://images.unsplash.com/photo-1621605815971-fbc98d665033?auto=format&fit=crop&w=800&q=80',
          'https://images.unsplash.com/photo-1599351431202-1e0f0137899a?auto=format&fit=crop&w=800&q=80',
        ],
        workingHours: WorkingHoursModel.defaultSchedule(),
      ),
      BusinessModel(
        id: 'b2',
        name: 'Royal Spa & Wellness',
        category: 'Spa & Wellness Center',
        address: 'Downtown Dubai, Boulevard Plaza Tower 1',
        rating: 4.8,
        reviewCount: 210,
        imageUrl:
            'https://images.unsplash.com/photo-1560066984-138dadb4c035?auto=format&fit=crop&w=800&q=80',
        isVerified: true,
        description:
            'Tranquil sanctuary providing deep tissue massages, Moroccan bath therapies, radiant facial care, and holistic mind-body wellness.',
        ownerId: 'owner_203',
        phone: '+971 4 456 7890',
        website: 'https://royalspa.ae',
        latitude: 25.1972,
        longitude: 55.2744,
        amenities: [
          'Wi-Fi',
          'Valet Parking',
          'Sauna',
          'Private Rooms',
          'Card Payment'
        ],
        galleryUrls: [
          'https://images.unsplash.com/photo-1560066984-138dadb4c035?auto=format&fit=crop&w=800&q=80',
          'https://images.unsplash.com/photo-1544161515-4ab6ce6db874?auto=format&fit=crop&w=800&q=80',
        ],
        workingHours: WorkingHoursModel.defaultSchedule(),
      ),
      BusinessModel(
        id: 'b3',
        name: 'Elegance Hair Couture',
        category: 'Women\'s Beauty & Hair Salon',
        address: 'Jumeirah Beach Road, Villa 42, Dubai',
        rating: 4.95,
        reviewCount: 540,
        imageUrl:
            'https://images.unsplash.com/photo-1522337360788-8b13dee7a37e?auto=format&fit=crop&w=800&q=80',
        isVerified: true,
        description:
            'High-end beauty hair house specializing in balayage, keratin treatments, bridal hair design, and manicures.',
        ownerId: 'owner_204',
        phone: '+971 4 344 5566',
        website: 'https://elegancehair.ae',
        latitude: 25.2048,
        longitude: 55.2708,
        amenities: [
          'Wi-Fi',
          'Private Ladies Lounge',
          'Card Payment',
          'Parking'
        ],
        galleryUrls: [
          'https://images.unsplash.com/photo-1522337360788-8b13dee7a37e?auto=format&fit=crop&w=800&q=80',
        ],
        workingHours: WorkingHoursModel.defaultSchedule(),
      ),
    ];
  }

  List<ServiceModel> _getMockServices(String businessId) {
    return [
      ServiceModel(
        id: 's1',
        salonId: businessId,
        name: 'Classic Executive Haircut',
        price: 75.0,
        discountPrice: 60.0,
        duration: '45 min',
        durationMinutes: 45,
        description:
            'Personalized consultation, precision cut, scalp wash, blow dry & styling.',
        categoryId: 'hair',
        categoryName: 'Hair Services',
      ),
      ServiceModel(
        id: 's2',
        salonId: businessId,
        name: 'Royal Beard Sculpting & Hot Towel',
        price: 50.0,
        duration: '30 min',
        durationMinutes: 30,
        description:
            'Beard trimming, razor edging, essential oil hot towel treatment.',
        categoryId: 'beard',
        categoryName: 'Beard Services',
      ),
      ServiceModel(
        id: 's3',
        salonId: businessId,
        name: 'Full VIP Haircut & Beard Combo',
        price: 110.0,
        discountPrice: 95.0,
        duration: '75 min',
        durationMinutes: 75,
        description:
            'Complete signature transformation package including wash, cut, beard, and facial steam.',
        categoryId: 'packages',
        categoryName: 'Packages',
      ),
      ServiceModel(
        id: 's4',
        salonId: businessId,
        name: 'Deep Cleansing Charcoal Facial',
        price: 130.0,
        duration: '45 min',
        durationMinutes: 45,
        description:
            'Deep pore exfoliation, blackhead extraction, and soothing organic hydration mask.',
        categoryId: 'facial',
        categoryName: 'Facial Care',
      ),
      ServiceModel(
        id: 's5',
        salonId: businessId,
        name: 'Head & Shoulder Stress Relief Massage',
        price: 85.0,
        duration: '30 min',
        durationMinutes: 30,
        description:
            'Targeted acupressure massage focusing on neck, shoulder, and upper scalp tension.',
        categoryId: 'massage',
        categoryName: 'Massage',
      ),
    ];
  }

  List<StaffModel> _getMockStaff(String businessId) {
    return [
      StaffModel(
        id: 'st1',
        businessId: businessId,
        name: 'Marcus Vance',
        roleTitle: 'Master Barber & Stylist',
        avatarUrl:
            'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=300&q=80',
        rating: 4.9,
        reviewCount: 142,
        experienceYears: 8,
      ),
      StaffModel(
        id: 'st2',
        businessId: businessId,
        name: 'Ahmed Hassan',
        roleTitle: 'Senior Beard Specialist',
        avatarUrl:
            'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=300&q=80',
        rating: 4.8,
        reviewCount: 98,
        experienceYears: 6,
      ),
      StaffModel(
        id: 'st3',
        businessId: businessId,
        name: 'Elena Rostova',
        roleTitle: 'Skin & Facial Therapist',
        avatarUrl:
            'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?auto=format&fit=crop&w=300&q=80',
        rating: 5.0,
        reviewCount: 86,
        experienceYears: 10,
      ),
    ];
  }

  List<ReviewModel> _getMockReviews(String businessId) {
    return [
      ReviewModel(
        id: 'r1',
        businessId: businessId,
        userName: 'Tariq Al-Mansoor',
        userAvatar:
            'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=150&q=80',
        rating: 5.0,
        comment:
            'Hands down the best grooming experience in Dubai! Marcus is an absolute artist with scissors and the hot towel finish is unmatched.',
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        serviceName: 'Full VIP Haircut & Beard Combo',
      ),
      ReviewModel(
        id: 'r2',
        businessId: businessId,
        userName: 'David Miller',
        userAvatar:
            'https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?auto=format&fit=crop&w=150&q=80',
        rating: 5.0,
        comment:
            'Super clean salon, punctual appointment start, and high attention to detail. Will definitely return next week!',
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
        serviceName: 'Classic Executive Haircut',
      ),
      ReviewModel(
        id: 'r3',
        businessId: businessId,
        userName: 'Sami Kabbani',
        userAvatar:
            'https://images.unsplash.com/photo-1522075469751-3a6694fb2f61?auto=format&fit=crop&w=150&q=80',
        rating: 4.5,
        comment:
            'Great atmosphere and polite staff. Loved the charcoal facial treatment.',
        createdAt: DateTime.now().subtract(const Duration(days: 12)),
        serviceName: 'Deep Cleansing Charcoal Facial',
      ),
    ];
  }
}
