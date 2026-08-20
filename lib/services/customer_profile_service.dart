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

    final userRef = _firestore.collection('users').doc(firebaseUser.uid);
    DocumentSnapshot<Map<String, dynamic>> doc;

    // Prefer the server so reopening Profile cannot silently show stale local
    // data after a successful edit. Fall back to the normal Firestore behavior
    // only when the device cannot currently reach the backend.
    try {
      doc = await userRef.get(const GetOptions(source: Source.server));
    } on FirebaseException {
      doc = await userRef.get();
    }

    final raw = doc.data();
    if (!doc.exists || raw == null) {
      return _fallbackCustomer(firebaseUser);
    }

    return _modelFromDocument(firebaseUser, raw);
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
    final before = await userRef.get();
    final rawBefore = before.data();
    final current = rawBefore == null
        ? _fallbackCustomer(firebaseUser)
        : _modelFromDocument(firebaseUser, rawBefore);

    final email = (firebaseUser.email ?? current.email).trim().toLowerCase();
    if (email.isEmpty) {
      throw FirebaseAuthException(
        code: 'missing-email',
        message: 'This account has no email address.',
      );
    }

    String? nextAvatar = current.avatarUrl;
    if (clearAvatar) {
      nextAvatar = null;
    } else if (avatarUrl != null && avatarUrl.trim().isNotEmpty) {
      nextAvatar = avatarUrl.trim();
    }

    // One canonical write path for both modern and legacy accounts. Including
    // id/email/role is safe because their values are preserved; Firestore rules
    // still reject any attempt to actually change role or email.
    final writeData = <String, dynamic>{
      'id': firebaseUser.uid,
      'email': email,
      'role': current.roleString,
      'full_name': cleanName,
      'phone': cleanPhone,
      'updated_at': FieldValue.serverTimestamp(),
      if (!before.exists) 'created_at': FieldValue.serverTimestamp(),
    };

    if (clearAvatar) {
      if (before.exists) {
        writeData['avatar_url'] = FieldValue.delete();
        writeData['profile_image'] = FieldValue.delete();
      }
    } else if (nextAvatar != null && nextAvatar.isNotEmpty) {
      writeData['avatar_url'] = nextAvatar;
      writeData['profile_image'] = nextAvatar;
    }

    await userRef.set(writeData, SetOptions(merge: true));

    // Do not report success from an optimistic/in-memory object. Verify the
    // values from the Firestore server after the write acknowledgement.
    final verifiedSnapshot =
        await userRef.get(const GetOptions(source: Source.server));
    final verifiedRaw = verifiedSnapshot.data();
    if (!verifiedSnapshot.exists || verifiedRaw == null) {
      throw StateError('Profile save could not be verified on the server.');
    }

    final savedName = (verifiedRaw['full_name'] ?? '').toString().trim();
    final savedPhone = (verifiedRaw['phone'] ?? '').toString().trim();
    if (savedName != cleanName || savedPhone != cleanPhone) {
      throw StateError(
        'Profile save verification failed. The server did not return the new values.',
      );
    }

    final verified = _modelFromDocument(firebaseUser, verifiedRaw);

    try {
      await firebaseUser.updateDisplayName(verified.fullName);
      if (clearAvatar) {
        await firebaseUser.updatePhotoURL(null);
      } else if (verified.avatarUrl != null && verified.avatarUrl!.isNotEmpty) {
        await firebaseUser.updatePhotoURL(verified.avatarUrl);
      }
    } on FirebaseAuthException catch (e) {
      // Firestore is canonical. A Firebase Auth metadata mirror failure should
      // not turn a verified Firestore save into an apparent failure.
      if (kDebugMode) {
        debugPrint('FirebaseAuth profile mirror update failed: ${e.code}');
      }
    }

    return verified;
  }

  UserModel _modelFromDocument(
    User firebaseUser,
    Map<String, dynamic> raw,
  ) {
    final data = Map<String, dynamic>.from(raw)
      ..['id'] = firebaseUser.uid
      ..['email'] = (firebaseUser.email ?? raw['email'] ?? '')
          .toString()
          .trim()
          .toLowerCase();
    return UserModel.fromJson(data);
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
