import 'package:flutter/foundation.dart';
import '../models/user_model.dart';

/// Authentication state manager for managing guest vs logged-in state.
/// Prepared for clean compatibility with future Firebase Authentication integration.
class AuthState extends ChangeNotifier {
  UserModel? _currentUser;
  bool _isLoggedIn = false;

  /// Whether a user is currently logged in.
  bool get isLoggedIn => _isLoggedIn;

  /// Current user model if logged in, or null if guest.
  UserModel? get currentUser => _currentUser;

  /// Whether current session is in Guest mode.
  bool get isGuest => !_isLoggedIn;

  /// Log in user (defaults to mock user if none passed) and notify listeners.
  void login([UserModel? user]) {
    _isLoggedIn = true;
    _currentUser = user ??
        UserModel(
          id: 'user_authenticated',
          email: 'user@easybook.com',
          fullName: 'Authenticated User',
          phone: '+1 555-0199',
          role: UserRole.customer,
        );
    notifyListeners();
  }

  /// Log out current user and revert to Guest mode.
  void logout() {
    _isLoggedIn = false;
    _currentUser = null;
    notifyListeners();
  }
}
