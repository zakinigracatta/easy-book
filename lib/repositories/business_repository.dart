import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/business_model.dart';
import '../models/gallery_image_model.dart';
import '../models/review_model.dart';
import '../models/service_model.dart';
import '../models/staff_model.dart';

class BusinessPage {
  const BusinessPage({
    required this.items,
    required this.nextCursor,
    required this.hasMore,
  });

  final List<BusinessModel> items;
  final String? nextCursor;
  final bool hasMore;
}

abstract class BusinessRepository {
  Future<List<BusinessModel>> fetchBusinesses({
    String? category,
    String? query,
  });

  Future<BusinessPage> fetchBusinessesPage({
    String? category,
    String? query,
    String? afterId,
    int pageSize = 30,
  });

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
  Future<List<BusinessModel>> fetchBusinesses({
    String? category,
    String? query,
  }) async {
    final page = await fetchBusinessesPage(
      category: category,
      query: query,
    );
    return page.items;
  }

  @override
  Future<BusinessPage> fetchBusinessesPage({
    String? category,
    String? query,
    String? afterId,
    int pageSize = 30,
  }) async {
    final safePageSize = pageSize.clamp(1, 50).toInt();
    Query<Map<String, dynamic>> firestoreQuery = _firestore
        .collection('businesses')
        .where('is_verified', isEqualTo: true)
        .where('is_active', isEqualTo: true)
        .orderBy(FieldPath.documentId)
        .limit(safePageSize);

    final normalizedCursor = afterId?.trim() ?? '';
    if (normalizedCursor.isNotEmpty) {
      firestoreQuery = firestoreQuery.startAfter([normalizedCursor]);
    }

    final snapshot = await firestoreQuery.get();
    final businesses = snapshot.docs
        .map((doc) {
          final data = Map<String, dynamic>.from(doc.data());
          data['id'] = doc.id;
          return BusinessModel.fromJson(data);
        })
        .where((business) => business.isActive && business.isVerified)
        .toList(growable: false);

    final filtered = _filterBusinesses(businesses, category, query);
    return BusinessPage(
      items: filtered,
      nextCursor: snapshot.docs.isEmpty ? null : snapshot.docs.last.id,
      hasMore: snapshot.docs.length == safePageSize,
    );
  }

  List<BusinessModel> _filterBusinesses(
    List<BusinessModel> businesses,
    String? category,
    String? query,
  ) {
    var results = businesses;

    final normalizedCategory = category?.trim().toLowerCase();
    if (normalizedCategory != null &&
        normalizedCategory.isNotEmpty &&
        normalizedCategory != 'all') {
      results = results
          .where(
            (business) => business.category
                .toLowerCase()
                .contains(normalizedCategory),
          )
          .toList();
    }

    final normalizedQuery = query?.trim().toLowerCase();
    if (normalizedQuery != null && normalizedQuery.isNotEmpty) {
      results = results
          .where(
            (business) =>
                business.name.toLowerCase().contains(normalizedQuery) ||
                business.address.toLowerCase().contains(normalizedQuery) ||
                business.category.toLowerCase().contains(normalizedQuery),
          )
          .toList();
    }

    return results;
  }

  @override
  Future<BusinessModel?> fetchBusinessById(String id) async {
    final normalizedId = id.trim();
    if (normalizedId.isEmpty) return null;

    final doc =
        await _firestore.collection('businesses').doc(normalizedId).get();

    if (!doc.exists || doc.data() == null) return null;

    final data = Map<String, dynamic>.from(doc.data()!);
    data['id'] = doc.id;
    final business = BusinessModel.fromJson(data);

    if (!business.isActive || !business.isVerified) return null;

    final gallerySnapshot = await _firestore
        .collection('businesses')
        .doc(normalizedId)
        .collection('gallery')
        .get();
    final galleryImages = gallerySnapshot.docs
        .map((galleryDoc) {
          final galleryData =
              Map<String, dynamic>.from(galleryDoc.data());
          galleryData['id'] = galleryDoc.id;
          return GalleryImageModel.fromJson(galleryData);
        })
        .where((image) => image.imageUrl.trim().isNotEmpty)
        .toList()
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

    final galleryUrls = <String>{
      ...business.galleryUrls
          .map((url) => url.trim())
          .where((url) => url.isNotEmpty),
      ...galleryImages.map((image) => image.imageUrl.trim()),
    }.toList(growable: false);

    return business.copyWith(galleryUrls: galleryUrls);
  }

  @override
  Future<List<ServiceModel>> fetchServices(String businessId) async {
    final normalizedId = businessId.trim();
    if (normalizedId.isEmpty) return [];

    final snapshot = await _firestore
        .collection('businesses')
        .doc(normalizedId)
        .collection('services')
        .where('is_active', isEqualTo: true)
        .where('is_bookable', isEqualTo: true)
        .get();

    return snapshot.docs
        .map((doc) {
          final data = Map<String, dynamic>.from(doc.data());
          data['id'] = doc.id;
          return ServiceModel.fromJson(data);
        })
        .where((service) => service.isActive && service.isBookable)
        .toList();
  }

  @override
  Future<List<StaffModel>> fetchStaff(String businessId) async {
    final normalizedId = businessId.trim();
    if (normalizedId.isEmpty) return [];

    final snapshot = await _firestore
        .collection('businesses')
        .doc(normalizedId)
        .collection('staff')
        .where('is_active', isEqualTo: true)
        .get();

    return snapshot.docs
        .map((doc) {
          final data = Map<String, dynamic>.from(doc.data());
          data['id'] = doc.id;
          return StaffModel.fromJson(data);
        })
        .where((staff) => staff.isActive)
        .toList();
  }

  @override
  Future<List<ReviewModel>> fetchReviews(String businessId) async {
    final normalizedId = businessId.trim();
    if (normalizedId.isEmpty) return [];

    final snapshot = await _firestore
        .collection('businesses')
        .doc(normalizedId)
        .collection('reviews')
        .get();

    return snapshot.docs.map((doc) {
      final data = Map<String, dynamic>.from(doc.data());
      data['id'] = doc.id;
      return ReviewModel.fromJson(data);
    }).toList();
  }
}
