import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../models/business_model.dart';
import '../models/appointment_model.dart';
import '../mock/mock_data.dart';

/// FirebaseService Abstraction
/// Outlines Cloud Firestore collections structure & Firebase Authentication logic.
/// Currently powered by MockData for zero-setup execution, fully ready for live Firebase initialization.
class FirebaseService {
  static const bool useLiveFirebase = false;

  // Firestore Collection Constants
  static const String usersCollection = 'users';
  static const String businessesCollection = 'businesses';
  static const String appointmentsCollection = 'appointments';
  static const String servicesCollection = 'services';
  static const String reviewsCollection = 'reviews';

  // --- Auth Operations ---
  Future<UserModel> signInWithEmailAndPassword(String email, String password, {UserRole? requestedRole}) async {
    if (useLiveFirebase) {
      // TODO: Replace with await FirebaseAuth.instance.signInWithEmailAndPassword(...)
      // and read document from FirebaseFirestore.instance.collection('users').doc(uid).get()
      debugPrint('Connecting to live Firebase Firestore...');
    }

    await Future.delayed(const Duration(milliseconds: 400));
    final isOwner = requestedRole == UserRole.owner || email.contains('owner') || email.contains('business');
    return isOwner ? MockData.sampleOwner : MockData.sampleCustomer;
  }

  Future<UserModel> registerCustomerUser({
    required String name,
    required String phone,
    required String email,
    required String password,
    String? profileImageUrl,
  }) async {
    if (useLiveFirebase) {
      // TODO: UserCredential cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(email: email, password: password);
      // await FirebaseFirestore.instance.collection('users').doc(cred.user!.uid).set({
      //   'full_name': name,
      //   'phone': phone,
      //   'email': email,
      //   'role': 'customer',
      //   'avatar_url': profileImageUrl,
      //   'wallet_balance': 100.0,
      // });
    }

    await Future.delayed(const Duration(milliseconds: 500));
    return UserModel(
      id: 'cust_${DateTime.now().millisecondsSinceEpoch}',
      email: email,
      fullName: name,
      phone: phone,
      avatarUrl: profileImageUrl ?? MockData.defaultCustomerAvatar,
      role: UserRole.customer,
      walletBalance: 100.0,
    );
  }

  Future<UserModel> registerOwnerUser({
    required String businessName,
    required String category,
    required String phone,
    required String email,
    required String password,
    required String location,
    String? businessImageUrl,
  }) async {
    if (useLiveFirebase) {
      // TODO: UserCredential cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(email: email, password: password);
      // await FirebaseFirestore.instance.collection('users').doc(cred.user!.uid).set({
      //   'business_name': businessName,
      //   'category': category,
      //   'phone': phone,
      //   'email': email,
      //   'role': 'owner',
      //   'location': location,
      //   'business_image_url': businessImageUrl,
      // });
    }

    await Future.delayed(const Duration(milliseconds: 500));
    return UserModel(
      id: 'owner_${DateTime.now().millisecondsSinceEpoch}',
      email: email,
      fullName: businessName,
      phone: phone,
      role: UserRole.owner,
      businessName: businessName,
      category: category,
      location: location,
      businessImageUrl: businessImageUrl ?? MockData.defaultSalonBanner,
    );
  }

  // --- Firestore Businesses Query ---
  Future<List<BusinessModel>> getBusinesses({String? category, String? query}) async {
    await Future.delayed(const Duration(milliseconds: 300));
    var list = MockData.businesses;
    if (category != null && category != 'all') {
      list = list.where((b) => b.category.toLowerCase().contains(category.toLowerCase())).toList();
    }
    if (query != null && query.isNotEmpty) {
      list = list.where((b) => b.name.toLowerCase().contains(query.toLowerCase()) || b.address.toLowerCase().contains(query.toLowerCase())).toList();
    }
    return list;
  }

  // --- Firestore Appointments Query ---
  Future<List<AppointmentModel>> getCustomerAppointments(String customerId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return MockData.appointments;
  }
}
