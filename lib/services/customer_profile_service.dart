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
      return _fallbackCustomer(firebaseUser);
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

    final UserModel current;
    final bool isLegacyProfileMissing;

    if (!snapshot.exists || raw == null) {
      // Older accounts can exist in Firebase Auth without a Firestore profile.
      // Create the canonical profile on first save instead of blocking editing.
      current = _fallbackCustomer(firebaseUser);
      isLegacyProfileMissing = true;
    } else {
      final data = Map<String, dynamic>.from(raw)
        ..['id'] = firebaseUser.uid
        ..['email'] = (firebaseUser.email ?? raw['email'] ?? '')
            .toString()
            .trim()
            .toLowerCase();
      current = UserModel.fromJson(data);
      isLegacyProfileMissing = false;
    }

    String? nextAvatar = current.avatarUrl;
    if (clearAvatar) {
      nextAvatar = null;
    } else if (avatarUrl != null && avatarUrl.trim().isNotEmpty) {
      nextAvatar = avatarUrl.trim();
    }

    if (isLegacyProfileMissing) {
      final email = (firebaseUser.email ?? '').trim().toLowerCase();
      if (email.isEmpty) {
        throw FirebaseAuthException(
          code: 'missing-email',
          message: 'This account has no email address.',
        );
      }

      final newProfile = UserModel(
        id: firebaseUser.uid,
        email: email,
        fullName: cleanName,
        phone: cleanPhone,
        avatarUrl: nextAvatar,
        role: UserRole.customer,
        walletBalance: current.walletBalance,
        favoriteBusinessIds: current.favoriteBusinessIds,
      );
      final createData = newProfile.toJson()
        ..removeWhere((key, value) => value == null);

      await userRef.set({
        ...createData,
        if (nextAvatar != null && nextAvatar.isNotEmpty)
          'profile_image': nextAvatar,
        'created_at': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
      });
    } else {
      final updates = <String, dynamic>{
        'full_name': cleanName,
        'phone': cleanPhone,
        'updated_at': FieldValue.serverTimestamp(),
      };

      if (clearAvatar) {
        updates['avatar_url'] = FieldValue.delete();
        updates['profile_image'] = FieldValue.delete();
      } else if (nextAvatar != null && nextAvatar.isNotEmpty) {
        updates['avatar_url'] = nextAvatar;
        updates['profile_image'] = nextAvatar;
      }

      // The signed-in user can only write their own users/{uid} document.
      // Firestore rules independently prevent role/email modification.
      await userRef.update(updates);
    }

    try {
      await firebaseUser.updateDisplayName(cleanName);
      if (clearAvatar) {
        await firebaseUser.updatePhotoURL(null);
      } else if (nextAvatar != null && nextAvatar.isNotEmpty) {
        await firebaseUser.updatePhotoURL(nextAvatar);
      }
    } on FirebaseAuthException catch (e) {
      // Firestore is canonical. A Firebase Auth metadata mirror failure should
      // not turn a successful profile save into an apparent failure.
      if (kDebugMode) {
        debugPrint('FirebaseAuth profile mirror update failed: ${e.code}');
      }
    }

    return UserModel(
      id: current.id,
      email: (firebaseUser.email ?? current.email).trim().toLowerCase(),
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

  UserModel _fallbackCustomer(User firebaseUser) {
    return UserModel(
      id: firebaseUser.uid,
      email: (firebaseUser.email ?? '').trim().toLowerCase(),
      fullName: firebaseUser.displayName?.trim().isNotEmpty == true
          ? firebaseUser.displayName!.trim()
          : 'Easy Book User',
      phone: firebaseUser.phoneNumber ?? '',
      avatarUrl: firebaseUser.photoURL,
      role: UserRole.customer,
      walletBalance: 0.0,
    );
  }
}
