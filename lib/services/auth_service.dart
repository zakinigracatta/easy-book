import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

import '../models/user_model.dart';
import 'auth_failure.dart';

/// Authentication and user-profile persistence backed by Firebase.
class AuthService {
  AuthService({
    firebase_auth.FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
  })  : _firebaseAuth = firebaseAuth ?? firebase_auth.FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  final firebase_auth.FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _users =>
      _firestore.collection('users');

  Stream<UserModel?> authStateChanges() {
    return _firebaseAuth.authStateChanges().asyncMap((firebaseUser) async {
      if (firebaseUser == null) return null;
      try {
        return await _loadUser(firebaseUser, retryIfMissing: true);
      } on AuthFailure {
        return null;
      }
    });
  }

  Future<UserModel?> restoreSession() async {
    final firebaseUser = _firebaseAuth.currentUser;
    if (firebaseUser == null) return null;

    try {
      return await _loadUser(firebaseUser);
    } catch (error) {
      await _safeSignOut();
      throw AuthFailure.from(
        error,
        fallbackMessage:
            'Unable to restore your session. Please sign in again.',
      );
    }
  }

  Future<UserModel> login(
    String email,
    String password, {
    UserRole? requestedRole,
  }) async {
    firebase_auth.User? firebaseUser;
    try {
      final credential = await _withTimeout(
        _firebaseAuth.signInWithEmailAndPassword(
          email: _normalizeEmail(email),
          password: password,
        ),
        'Signing in',
      );
      firebaseUser = credential.user;
      if (firebaseUser == null) {
        throw const AuthFailure(
          'missing-user',
          'Unable to sign in. Please try again.',
        );
      }

      final user = await _loadUser(firebaseUser);
      if (requestedRole != null && user.role != requestedRole) {
        throw const AuthFailure(
          'role-mismatch',
          'This account is not registered for the selected portal.',
        );
      }
      return user;
    } catch (error) {
      if (firebaseUser != null) await _safeSignOut();
      throw AuthFailure.from(error);
    }
  }

  Future<UserModel> registerCustomer({
    required String name,
    required String phone,
    required String email,
    required String password,
    String? profileImageUrl,
  }) {
    final normalizedEmail = _normalizeEmail(email);
    return _register(
      email: normalizedEmail,
      password: password,
      buildUser: (uid) => UserModel(
        id: uid,
        email: normalizedEmail,
        fullName: name,
        phone: phone,
        avatarUrl: profileImageUrl,
        role: UserRole.customer,
      ),
    );
  }

  Future<UserModel> registerBusinessOwner({
    required String businessName,
    required String category,
    required String phone,
    required String email,
    required String password,
    required String location,
    String? businessImageUrl,
  }) {
    final normalizedEmail = _normalizeEmail(email);
    return _register(
      email: normalizedEmail,
      password: password,
      buildUser: (uid) => UserModel(
        id: uid,
        email: normalizedEmail,
        fullName: businessName,
        phone: phone,
        role: UserRole.owner,
        businessName: businessName,
        category: category,
        location: location,
        businessImageUrl: businessImageUrl,
      ),
    );
  }

  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
    } catch (error) {
      throw AuthFailure.from(error, fallbackMessage: 'Unable to sign out.');
    }
  }

  Future<void> sendEmailVerification() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        throw const AuthFailure(
          'not-signed-in',
          'Sign in before requesting a verification email.',
        );
      }
      if (!user.emailVerified) {
        await _withTimeout(
          user.sendEmailVerification(),
          'Sending verification email',
        );
      }
    } catch (error) {
      throw AuthFailure.from(error);
    }
  }

  Future<bool> isCurrentEmailVerified() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) return false;
      await _withTimeout(user.reload(), 'Checking email verification');
      return _firebaseAuth.currentUser?.emailVerified ?? false;
    } catch (error) {
      throw AuthFailure.from(error);
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _withTimeout(
        _firebaseAuth.sendPasswordResetEmail(email: _normalizeEmail(email)),
        'Sending password reset email',
      );
    } catch (error) {
      throw AuthFailure.from(error);
    }
  }

  Future<UserModel> _register({
    required String email,
    required String password,
    required UserModel Function(String uid) buildUser,
  }) async {
    firebase_auth.User? firebaseUser;
    try {
      final credential = await _withTimeout(
        _firebaseAuth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        ),
        'Creating the account',
      );
      firebaseUser = credential.user;
      if (firebaseUser == null) {
        throw const AuthFailure(
          'missing-user',
          'Unable to create the account. Please try again.',
        );
      }

      final user = buildUser(firebaseUser.uid);
      await _withTimeout(
        _users.doc(user.id).set({
          ...user.toJson(),
          'created_at': FieldValue.serverTimestamp(),
          'updated_at': FieldValue.serverTimestamp(),
        }),
        'Saving the user profile',
      );
      return user;
    } catch (error) {
      if (firebaseUser != null) {
        try {
          await firebaseUser.delete();
        } catch (_) {
          await _safeSignOut();
        }
      }
      throw AuthFailure.from(
        error,
        fallbackMessage: 'Unable to create the account. Please try again.',
      );
    }
  }

  Future<UserModel> _loadUser(
    firebase_auth.User firebaseUser, {
    bool retryIfMissing = false,
  }) async {
    final attempts = retryIfMissing ? 3 : 1;
    for (var attempt = 0; attempt < attempts; attempt++) {
      final snapshot = await _withTimeout(
        _users.doc(firebaseUser.uid).get(),
        'Loading the user profile',
      );
      if (snapshot.exists && snapshot.data() != null) {
        _validateStoredRole(snapshot.data()!['role']);
        return UserModel.fromJson({
          ...snapshot.data()!,
          'id': firebaseUser.uid,
          'email': firebaseUser.email ?? snapshot.data()!['email'],
        });
      }
      if (attempt + 1 < attempts) {
        await Future<void>.delayed(const Duration(milliseconds: 200));
      }
    }
    throw const AuthFailure(
      'profile-not-found',
      'No Easy Book profile was found for this account.',
    );
  }

  Future<T> _withTimeout<T>(Future<T> operation, String operationName) {
    return operation.timeout(
      const Duration(seconds: 20),
      onTimeout: () => throw TimeoutException('$operationName timed out.'),
    );
  }

  String _normalizeEmail(String email) => email.trim().toLowerCase();

  void _validateStoredRole(Object? value) {
    const supportedRoles = {
      'customer',
      'owner',
      'businessOwner',
      'business_owner',
      'admin',
      'super_admin',
      'superAdmin',
    };
    if (value is! String || !supportedRoles.contains(value)) {
      throw const AuthFailure(
        'invalid-role',
        'The account profile has a missing or invalid role. Contact support.',
      );
    }
  }

  Future<void> _safeSignOut() async {
    try {
      await _firebaseAuth.signOut();
    } catch (_) {
      // Preserve the original authentication error.
    }
  }
}
