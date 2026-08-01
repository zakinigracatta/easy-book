import '../models/user_model.dart';
import '../data/mock_data.dart';

/// UserService Abstraction
/// Firebase Future Migration Note:
/// Replace Mock implementation with:
/// FirebaseFirestore.instance.collection('users').doc(userId).get()
class UserService {
  static const bool useFirebase = false;

  Future<UserModel?> getUserProfile(String userId) async {
    if (useFirebase) {
      // final doc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
      // return doc.exists ? UserModel.fromJson(doc.data()!) : null;
    }

    await Future.delayed(const Duration(milliseconds: 200));
    return MockData.customerUser;
  }

  Future<UserModel> updateUserProfile(UserModel user) async {
    if (useFirebase) {
      // await FirebaseFirestore.instance.collection('users').doc(user.id).update(user.toJson());
    }

    await Future.delayed(const Duration(milliseconds: 300));
    return user;
  }
}
