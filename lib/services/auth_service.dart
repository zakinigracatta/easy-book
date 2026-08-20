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
      await _ensureOwnerBusiness(user);

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

      if (_isOwner(user.role)) {
        try {
          await _ensureOwnerBusiness(user);
        } catch (e) {
          debugPrint(
              'Unable to repair owner business link for uid=${user.id}: $e');
        }
      }

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

  Future<void> _saveProfile(UserModel user) async {
    final data = user.toJson()..removeWhere((key, value) => value == null);

    if (kDebugMode) {
      debugPrint('Creating Firestore user profile...');
    }

    await _users.doc(user.id).set({
      ...data,
      'created_at': FieldValue.serverTimestamp(),
      'updated_at': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> _ensureOwnerBusiness(UserModel user) async {
    if (!_isOwner(user.role) || user.id.isEmpty) return;

    final deterministicRef = _businesses.doc(user.id);
    final deterministicDoc = await deterministicRef.get();
    if (deterministicDoc.exists) return;

    final modernMatch = await _businesses
        .where('ownerId', isEqualTo: user.id)
        .limit(1)
        .get();
    if (modernMatch.docs.isNotEmpty) return;

    final legacyMatch = await _businesses
        .where('owner_id', isEqualTo: user.id)
        .limit(1)
        .get();
    if (legacyMatch.docs.isNotEmpty) return;

    final rawBusinessName = user.businessName?.trim() ?? '';
    final rawFullName = user.fullName.trim();
    final businessName = rawBusinessName.isNotEmpty
        ? rawBusinessName
        : (rawFullName.isNotEmpty ? rawFullName : 'Easy Book Business');
    final category = user.category?.trim() ?? '';
    final location = user.location?.trim() ?? '';
    final imageUrl = user.businessImageUrl?.trim() ?? '';

    debugPrint('Creating missing business record for owner uid=${user.id}');

    await deterministicRef.set({
      'id': user.id,
      'name': businessName,
      'category': category.isNotEmpty ? category : 'Salon',
      'address': location,
      'rating': 0.0,
      'review_count': 0,
      'image_url': imageUrl,
      'is_verified': false,
      'description': '',
      'ownerId': user.id,
      'owner_id': user.id,
      'latitude': 0.0,
      'longitude': 0.0,
      'amenities': <String>[],
      'phone': user.phone.trim(),
      'gallery_urls': <String>[],
      'isActive': true,
      'is_active': true,
      'businessStatus': 'open',
      'business_status': 'open',
      'acceptingBookings': true,
      'accepting_bookings': true,
      'created_at': FieldValue.serverTimestamp(),
      'updated_at': FieldValue.serverTimestamp(),
    });
  }

  bool _isOwner(UserRole role) {
    return role == UserRole.owner || role == UserRole.businessOwner;
  }

  bool _matchesRequestedRole(UserRole actual, UserRole requested) {
    if (_isOwner(requested)) {
      return _isOwner(actual);
    }

    return actual == requested;
  }
}
