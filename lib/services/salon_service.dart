import '../models/salon_model.dart';
import '../data/mock_data.dart';

/// SalonService Abstraction
/// Firebase Future Migration Note:
/// Replace Mock implementation with:
/// FirebaseFirestore.instance.collection('businesses').where(...).get()
class SalonService {
  static const bool useFirebase = false;

  Future<List<SalonModel>> getSalons({String? category, String? query}) async {
    if (useFirebase) {
      // Future Firebase Firestore collection query:
      // final snap = await FirebaseFirestore.instance.collection('businesses').get();
      // return snap.docs.map((doc) => SalonModel.fromJson(doc.data())).toList();
    }

    await Future.delayed(const Duration(milliseconds: 300));
    var list = MockData.salons;
    if (category != null && category != 'all') {
      list = list.where((s) => s.category.toLowerCase().contains(category.toLowerCase())).toList();
    }
    if (query != null && query.isNotEmpty) {
      list = list.where((s) => s.name.toLowerCase().contains(query.toLowerCase()) || s.address.toLowerCase().contains(query.toLowerCase())).toList();
    }
    return list;
  }

  Future<SalonModel?> getSalonById(String id) async {
    if (useFirebase) {
      // final doc = await FirebaseFirestore.instance.collection('businesses').doc(id).get();
      // return doc.exists ? SalonModel.fromJson(doc.data()!) : null;
    }

    await Future.delayed(const Duration(milliseconds: 200));
    try {
      return MockData.salons.firstWhere((s) => s.id == id);
    } catch (_) {
      return MockData.salons.first;
    }
  }

  Future<SalonModel> createSalon(SalonModel salon) async {
    if (useFirebase) {
      // await FirebaseFirestore.instance.collection('businesses').doc(salon.id).set(salon.toJson());
    }

    await Future.delayed(const Duration(milliseconds: 400));
    MockData.salons.add(salon);
    return salon;
  }
}
