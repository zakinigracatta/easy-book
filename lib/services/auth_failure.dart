import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';

/// A safe, user-facing authentication error.
class AuthFailure implements Exception {
  const AuthFailure(this.code, this.message);

  final String code;
  final String message;

  factory AuthFailure.from(
    Object error, {
    String fallbackMessage = 'Authentication failed. Please try again.',
  }) {
    if (error is AuthFailure) return error;

    if (error is FirebaseAuthException) {
      return AuthFailure(error.code, _authMessage(error.code));
    }

    if (error is FirebaseException) {
      return AuthFailure(error.code, _firebaseMessage(error.code));
    }

    if (error is TimeoutException) {
      return const AuthFailure(
        'timeout',
        'The request took too long. Check your connection and try again.',
      );
    }

    return AuthFailure('unknown', fallbackMessage);
  }

  static String _authMessage(String code) {
    switch (code) {
      case 'invalid-email':
        return 'Enter a valid email address.';
      case 'invalid-credential':
      case 'user-not-found':
      case 'wrong-password':
        return 'The email or password is incorrect.';
      case 'email-already-in-use':
        return 'An account already exists for this email.';
      case 'weak-password':
        return 'Use a stronger password with at least 6 characters.';
      case 'user-disabled':
        return 'This account has been disabled. Contact support.';
      case 'network-request-failed':
        return 'Unable to connect. Check your internet connection.';
      case 'too-many-requests':
        return 'Too many attempts. Please wait before trying again.';
      case 'operation-not-allowed':
        return 'Email sign-in is not enabled for this app.';
      case 'requires-recent-login':
        return 'Please sign in again before continuing.';
      default:
        return 'Authentication failed. Please try again.';
    }
  }

  static String _firebaseMessage(String code) {
    switch (code) {
      case 'permission-denied':
        return 'Your account does not have permission for this operation.';
      case 'unavailable':
        return 'The service is temporarily unavailable. Please try again.';
      default:
        return 'Unable to access your account data. Please try again.';
    }
  }

  @override
  String toString() => message;
}

String authErrorMessage(Object error) => AuthFailure.from(error).message;
