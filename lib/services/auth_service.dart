import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/user_model.dart';

class AuthService {
  AuthService({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _users =>
      _firestore.collection('users');

  CollectionReference<Map<String, dynamic>> get _businesses =>
      _firestore.collection('businesses');

  User? get currentFirebaseUser => _auth.currentUser;

  Stream<UserModel?> authStateChanges() {
    return _auth.authStateChanges().asyncMap((firebaseUser) async {
      if (firebaseUser == null) return null;
      return _loadOrCreateProfile(firebaseUser);
    });
  }

  Future<UserModel> login(
    String email,
    String password, {
    UserRole? requestedRole,
  }) async {
    final normalizedEmail = email.trim().toLowerCase();
    final credential = await _auth.signInWithEmailAndPassword(
      email: normalizedEmail,
      password: password,
    );

    final firebaseUser = credential.user;
    if (firebaseUser == null) {
      throw FirebaseAuthException(
        code: 'user-not-found',
        message: 'Unable to load the signed-in user.',
      );
    }

    final user = await _loadOrCreateProfile(firebaseUser);

    if (requestedRole != null &&
        !_matchesRequestedRole(user.role, requestedRole)) {
      await _auth.signOut();
      throw FirebaseAuthException(
        code: 'role-mismatch',
        message: 'This account does not match the selected account type.',
      );
    }

    return user;
  }

  Future<UserModel> registerCustomer({
    required String name,
    required String phone,
    required String email,
    required String password,
    String? profileImageUrl,
  }) async {
    final normalizedEmail = email.trim().toLowerCase();
    final credential = await _auth.createUserWithEmailAndPassword(
      email: normalizedEmail,
      password: password,
    );

    final firebaseUser = credential.user;
    if (firebaseUser == null) {
      throw FirebaseAuthException(
        code: 'user-not-created',
        message: 'Unable to create the user account.',
      );
    }

    final user = UserModel(
      id: firebaseUser.uid,
      email: (firebaseUser.email ?? normalizedEmail).trim().toLowerCase(),
      fullName: name.trim(),
      phone: phone.trim(),
      avatarUrl: profileImageUrl,
      role: UserRole.customer,
      walletBalance: 0.0,
    );

    try {
      await firebaseUser.updateDisplayName(name.trim());
      await _saveProfile(user);

      if (!firebaseUser.emailVerified) {
        await firebaseUser.sendEmailVerification();
      }

      return user;
    } catch (_) {
      try {
        await firebaseUser.delete();
      } catch (_) {}
      rethrow;
    }
  }

  Future<UserModel> registerBusinessOwner({
    required String businessName,
    required String category,
    required String phone,
    required String email,
    required String password,
    required String location,
    String? businessImageUrl,
  }) async {
    final normalizedEmail = email.trim().toLowerCase();
    final credential = await _auth.createUserWithEmailAndPassword(
      email: normalizedEmail,
      password: password,
    );

    final firebaseUser = credential.user;
    if (firebaseUser == null) {
      throw FirebaseAuthException(
        code: 'user-not-created',
        message: 'Unable to create the business account.',
      );
    }

    final user = UserModel(
      id: firebaseUser.uid,
      email: (firebaseUser.email ?? normalizedEmail).trim().toLowerCase(),
      fullName: businessName.trim(),
      phone: phone.trim(),
      role: UserRole.owner,
      walletBalance: 0.0,
      businessName: businessName.trim(),
      category: category.trim(),
      location: location.trim(),
      businessImageUrl: businessImageUrl,
    );

    try {
      await firebaseUser.updateDisplayName(businessName.trim());
      await _saveProfile(user);
      await _ensureBusinessForOwner(user);

      if (!firebaseUser.emailVerified) {
        await firebaseUser.sendEmailVerification();
      }

      return user;
    } catch (_) {
      try {
        await firebaseUser.delete();
      } catch (_) {}
      rethrow;
    }
  }

  Future<void> logout() => _auth.signOut();

  Future<void> sendPasswordResetEmail(String email) {
    return _auth.sendPasswordResetEmail(email: email.trim().toLowerCase());
  }

  Future<void> resendEmailVerification() async {
    final user = _auth.currentUser;

    if (user == null) {
      throw FirebaseAuthException(
        code: 'no-current-user',
        message: 'No signed-in user is available.',
      );
    }

    await user.reload();

    final refreshedUser = _auth.currentUser;
    if (refreshedUser != null && !refreshedUser.emailVerified) {
      await refreshedUser.sendEmailVerification();
    }
  }

  Future<bool> isEmailVerified() async {
    final user = _auth.currentUser;
    if (user == null) return false;

    await user.reload();
    return _auth.currentUser?.emailVerified ?? false;
  }

  Future<UserModel> _loadOrCreateProfile(User firebaseUser) async {
    final doc = await _users.doc(firebaseUser.uid).get();

    if (doc.exists && doc.data() != null) {
      final data = Map<String, dynamic>.from(doc.data()!);
      data['id'] = firebaseUser.uid;
      data['email'] = (firebaseUser.email ?? data['email'] ?? '')
          .toString()
          .trim()
          .toLowerCase();

      final user = UserModel.fromJson(data);
      await _ensureBusinessForOwner(user);
      return user;
    }

    return UserModel(
      id: firebaseUser.uid,
      email: (firebaseUser.email ?? '').trim().toLowerCase(),
      fullName: firebaseUser.displayName?.trim().isNotEmpty == true
          ? firebaseUser.displayName!.trim()
          : 'Easy Book User',
      phone: firebaseUser.phoneNumber ?? '',
      role: UserRole.customer,
      walletBalance: 0.0,
    );
  }

  Future<void> _ensureBusinessForOwner(UserModel user) async {
    if (user.role != UserRole.owner && user.role != UserRole.businessOwner) {
      return;
    }

    final ownerIdQuery =
        await _businesses.where('ownerId', isEqualTo: user.id).limit(1).get();
    if (ownerIdQuery.docs.isNotEmpty) {
      return;
    }

    final legacyOwnerIdQuery =
        await _businesses.where('owner_id', isEqualTo: user.id).limit(1).get();
    if (legacyOwnerIdQuery.docs.isNotEmpty) {
      return;
    }

    final businessName = (user.businessName?.trim().isNotEmpty ?? false)
        ? user.businessName!.trim()
        : user.fullName.trim();

    await _businesses.doc(user.id).set({
      'id': user.id,
      'name': businessName,
      'category': user.category?.trim().isNotEmpty == true
          ? user.category!.trim()
          : 'Salon',
      'address': user.location?.trim() ?? '',
      'phone': user.phone.trim(),
      'image_url': user.businessImageUrl ?? '',
      // Keep both owner field styles for legacy/current compatibility.
      'ownerId': user.id,
      'owner_id': user.id,
      'rating': 0.0,
      'review_count': 0,
      'is_verified': true,
      'description': '',
      'latitude': 0.0,
      'longitude': 0.0,
      'gallery_urls': <String>[],
      'amenities': <String>[],
      'is_active': true,
      'business_status': 'open',
      'accepting_bookings': true,
      'created_at': FieldValue.serverTimestamp(),
      'updated_at': FieldValue.serverTimestamp(),
    });
  }

  Future<void> _saveProfile(UserModel user) async {
    final data = user.toJson()..removeWhere((key, value) => value == null);

    debugPrint('Creating Firestore profile for uid=${user.id}');
    debugPrint('Profile keys: ${data.keys.toList()}');
    debugPrint('Profile role: ${data['role']}');
    debugPrint('Profile email: ${data['email']}');
    debugPrint('Wallet initial value: ${data['wallet_balance']}');

    await _users.doc(user.id).set({
      ...data,
      'created_at': FieldValue.serverTimestamp(),
      'updated_at': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  bool _matchesRequestedRole(UserRole actual, UserRole requested) {
    if (requested == UserRole.owner || requested == UserRole.businessOwner) {
      return actual == UserRole.owner || actual == UserRole.businessOwner;
    }

    return actual == requested;
  }
}
