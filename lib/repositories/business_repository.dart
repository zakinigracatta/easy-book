import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/business_model.dart';
import '../models/review_model.dart';
import '../models/service_model.dart';
import '../models/staff_model.dart';

abstract class BusinessRepository {
  Future<List<BusinessModel>> fetchBusinesses({
    String? category,
    String? query,
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
    final snapshot = await _firestore.collection('businesses').get();

    final businesses = snapshot.docs
        .map((doc) {
          final data = Map<String, dynamic>.from(doc.data());
          data['id'] = doc.id;
          return BusinessModel.fromJson(data);
        })
        .where((business) => business.isActive)
        .toList();

    return _filterBusinesses(businesses, category, query);
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
            (business) =>
                business.category.toLowerCase().contains(normalizedCategory),
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

    return business.isActive ? business : null;
  }

  @override
  Future<List<ServiceModel>> fetchServices(String businessId) async {
    final normalizedId = businessId.trim();
    if (normalizedId.isEmpty) return [];

    final snapshot = await _firestore
        .collection('businesses')
        .doc(normalizedId)
        .collection('services')
        .get();

    return snapshot.docs.map((doc) {
      final data = Map<String, dynamic>.from(doc.data());
      data['id'] = doc.id;
      return ServiceModel.fromJson(data);
    }).toList();
  }

  @override
  Future<List<StaffModel>> fetchStaff(String businessId) async {
    final normalizedId = businessId.trim();
    if (normalizedId.isEmpty) return [];

    final snapshot = await _firestore
        .collection('businesses')
        .doc(normalizedId)
        .collection('staff')
        .get();

    return snapshot.docs.map((doc) {
      final data = Map<String, dynamic>.from(doc.data());
      data['id'] = doc.id;
      return StaffModel.fromJson(data);
    }).toList();
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
