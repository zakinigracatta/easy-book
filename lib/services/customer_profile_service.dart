import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../models/user_model.dart';

class CustomerProfileService {
  CustomerProfileService({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  Future<UserModel?> fetchCurrentProfile() async {
    final firebaseUser = _auth.currentUser;
    if (firebaseUser == null) return null;

    final doc = await _firestore.collection('users').doc(firebaseUser.uid).get();
    final raw = doc.data();

    if (!doc.exists || raw == null) {
      return UserModel(
        id: firebaseUser.uid,
        email: (firebaseUser.email ?? '').trim().toLowerCase(),
        fullName: firebaseUser.displayName?.trim().isNotEmpty == true
            ? firebaseUser.displayName!.trim()
            : 'Easy Book User',
        phone: firebaseUser.phoneNumber ?? '',
        avatarUrl: firebaseUser.photoURL,
        role: UserRole.customer,
      );
    }

    final data = Map<String, dynamic>.from(raw)
      ..['id'] = firebaseUser.uid
      ..['email'] = (firebaseUser.email ?? raw['email'] ?? '')
          .toString()
          .trim()
          .toLowerCase();

    return UserModel.fromJson(data);
  }

  Future<UserModel> updateCurrentCustomerProfile({
    required String fullName,
    required String phone,
    String? avatarUrl,
    bool clearAvatar = false,
  }) async {
    final firebaseUser = _auth.currentUser;
    if (firebaseUser == null) {
      throw FirebaseAuthException(
        code: 'no-current-user',
        message: 'Please sign in again before updating your profile.',
      );
    }

    final cleanName = fullName.trim();
    final cleanPhone = phone.trim();
    if (cleanName.isEmpty) {
      throw ArgumentError.value(fullName, 'fullName', 'Full name is required.');
    }
    if (cleanName.length > 60) {
      throw ArgumentError.value(
        fullName,
        'fullName',
        'Full name must be 60 characters or less.',
      );
    }
    if (cleanPhone.length > 25) {
      throw ArgumentError.value(
        phone,
        'phone',
        'Phone number must be 25 characters or less.',
      );
    }

    final userRef = _firestore.collection('users').doc(firebaseUser.uid);
    final snapshot = await userRef.get();
    final raw = snapshot.data();
    if (!snapshot.exists || raw == null) {
      throw StateError('Your customer profile could not be found.');
    }

    final data = Map<String, dynamic>.from(raw)
      ..['id'] = firebaseUser.uid
      ..['email'] = (firebaseUser.email ?? raw['email'] ?? '')
          .toString()
          .trim()
          .toLowerCase();
    final current = UserModel.fromJson(data);

    if (current.role != UserRole.customer) {
      throw StateError('Only customer accounts can be edited from this screen.');
    }

    final updates = <String, dynamic>{
      'full_name': cleanName,
      'phone': cleanPhone,
      'updated_at': FieldValue.serverTimestamp(),
    };

    String? nextAvatar = current.avatarUrl;
    if (clearAvatar) {
      updates['avatar_url'] = FieldValue.delete();
      updates['profile_image'] = FieldValue.delete();
      nextAvatar = null;
    } else if (avatarUrl != null && avatarUrl.trim().isNotEmpty) {
      nextAvatar = avatarUrl.trim();
      updates['avatar_url'] = nextAvatar;
      updates['profile_image'] = nextAvatar;
    }

    // Firestore is the canonical app profile. Only update the in-memory/auth
    // mirrors after this write succeeds.
    await userRef.update(updates);

    try {
      await firebaseUser.updateDisplayName(cleanName);
      if (clearAvatar) {
        await firebaseUser.updatePhotoURL(null);
      } else if (nextAvatar != null && nextAvatar.isNotEmpty) {
        await firebaseUser.updatePhotoURL(nextAvatar);
      }
    } on FirebaseAuthException catch (e) {
      // The Firestore profile is already safely updated. A metadata mirror
      // failure must not roll back or incorrectly report the whole save as lost.
      if (kDebugMode) {
        debugPrint('FirebaseAuth profile mirror update failed: ${e.code}');
      }
    }

    return UserModel(
      id: current.id,
      email: current.email,
      fullName: cleanName,
      phone: cleanPhone,
      avatarUrl: nextAvatar,
      role: current.role,
      walletBalance: current.walletBalance,
      favoriteBusinessIds: current.favoriteBusinessIds,
      businessName: current.businessName,
      category: current.category,
      location: current.location,
      businessImageUrl: current.businessImageUrl,
    );
  }
}
