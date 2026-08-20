import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/business_model.dart';
import '../models/service_model.dart';
import '../models/staff_model.dart';
import '../models/review_model.dart';

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
    final snap = await _firestore.collection('businesses').get();
    final list = snap.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return BusinessModel.fromJson(data);
    }).toList();

    return _filter(list, category, query);
  }

  List<BusinessModel> _filter(
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

    final doc = await _firestore.collection('businesses').doc(id).get();
    if (!doc.exists || doc.data() == null) return null;

    final data = doc.data()!;
    data['id'] = doc.id;
    return BusinessModel.fromJson(data);
  }

  @override
  Future<List<ServiceModel>> fetchServices(String businessId) async {
    if (businessId.isEmpty) return [];

    final snap = await _firestore
        .collection('businesses')
        .doc(businessId)
        .collection('services')
        .get();

    return snap.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return ServiceModel.fromJson(data);
    }).toList();
  }

  @override
  Future<List<StaffModel>> fetchStaff(String businessId) async {
    if (businessId.isEmpty) return [];

    final snap = await _firestore
        .collection('businesses')
        .doc(businessId)
        .collection('staff')
        .get();

    return snap.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return StaffModel.fromJson(data);
    }).toList();
  }

  @override
  Future<List<ReviewModel>> fetchReviews(String businessId) async {
    if (businessId.isEmpty) return [];

    final snap = await _firestore
        .collection('businesses')
        .doc(businessId)
        .collection('reviews')
        .get();

    return snap.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return ReviewModel.fromJson(data);
    }).toList();
  }
}
