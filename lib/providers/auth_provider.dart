import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/user_model.dart';
import '../repositories/auth_repository.dart';
import '../services/auth_service.dart';
import '../services/navigation_service.dart';

final navigationServiceProvider = Provider<NavigationService>((ref) {
  return NavigationService();
});

final authServiceProvider = Provider<AuthService>((ref) => AuthService());
final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepositoryImpl(ref.watch(authServiceProvider)),
);

/// Riverpod auth state backed by Firebase Auth and the Firestore user profile.
class AuthNotifier extends StateNotifier<UserModel?> {
  AuthNotifier(this._repository, this._setSessionResolved) : super(null) {
    _authSubscription = _repository.authStateChanges().listen(
          (user) {
            state = user;
            _setSessionResolved(true);
          },
          onError: (_, __) {
            state = null;
            _setSessionResolved(true);
          },
        );
  }

  final AuthRepository _repository;
  final void Function(bool value) _setSessionResolved;
  late final StreamSubscription<UserModel?> _authSubscription;

  bool get isLoggedIn => state != null;
  bool get isGuest => state == null;

  Future<UserModel?> restoreSession() async {
    try {
      final user = await _repository.restoreSession();
      state = user;
      return user;
    } finally {
      _setSessionResolved(true);
    }
  }

  Future<UserModel> login(String email, String password,
      {UserRole? requestedRole}) async {
    final user = await _repository.login(
      email,
      password,
      requestedRole: requestedRole,
    );
    state = user;
    _setSessionResolved(true);
    return user;
  }

  Future<UserModel> registerCustomer({
    required String name,
    required String phone,
    required String email,
    required String password,
    String? profileImageUrl,
  }) async {
    final user = await _repository.registerCustomer(
      name: name,
      phone: phone,
      email: email,
      password: password,
      profileImageUrl: profileImageUrl,
    );
    state = user;
    return user;
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
    final user = await _repository.registerBusinessOwner(
      businessName: businessName,
      category: category,
      phone: phone,
      email: email,
      password: password,
      location: location,
      businessImageUrl: businessImageUrl,
    );
    state = user;
    return user;
  }

  Future<UserModel> signup({
    required String fullName,
    required String phone,
    required String email,
    required String password,
    required UserRole role,
  }) {
    if (role == UserRole.owner || role == UserRole.businessOwner) {
      return registerBusinessOwner(
        businessName: fullName,
        category: 'Other',
        phone: phone,
        email: email,
        password: password,
        location: '',
      );
    }
    return registerCustomer(
      name: fullName,
      phone: phone,
      email: email,
      password: password,
    );
  }

  Future<void> logout() async {
    await _repository.signOut();
    state = null;
    _setSessionResolved(true);
  }

  Future<void> sendEmailVerification() => _repository.sendEmailVerification();

  Future<bool> isCurrentEmailVerified() => _repository.isCurrentEmailVerified();

  Future<void> sendPasswordResetEmail(String email) =>
      _repository.sendPasswordResetEmail(email);

  /// Updates the locally displayed role. Role persistence is managed by the
  /// account registration flow and will be expanded with admin management.
  void updateUserRole(UserRole role) {
    final user = state;
    if (user == null) return;
    state = UserModel(
      id: user.id,
      email: user.email,
      fullName: user.fullName,
      phone: user.phone,
      avatarUrl: user.avatarUrl,
      role: role,
      walletBalance: user.walletBalance,
      favoriteBusinessIds: user.favoriteBusinessIds,
      businessName: user.businessName,
      category: user.category,
      location: user.location,
      businessImageUrl: user.businessImageUrl,
    );
  }

  /// Keeps the current wallet UI responsive; wallet persistence is outside the
  /// authentication scope.
  void updateWalletBalance(double amount) {
    final user = state;
    if (user == null) return;
    state = UserModel(
      id: user.id,
      email: user.email,
      fullName: user.fullName,
      phone: user.phone,
      avatarUrl: user.avatarUrl,
      role: user.role,
      walletBalance: user.walletBalance + amount,
      favoriteBusinessIds: user.favoriteBusinessIds,
      businessName: user.businessName,
      category: user.category,
      location: user.location,
      businessImageUrl: user.businessImageUrl,
    );
  }

  @override
  void dispose() {
    _authSubscription.cancel();
    super.dispose();
  }
}

final authSessionResolvedProvider = StateProvider<bool>((ref) => false);

final authProvider = StateNotifierProvider<AuthNotifier, UserModel?>((ref) {
  return AuthNotifier(
    ref.watch(authRepositoryProvider),
    (value) => ref.read(authSessionResolvedProvider.notifier).state = value,
  );
});

final isLoggedInProvider =
    Provider<bool>((ref) => ref.watch(authProvider) != null);
final isGuestProvider =
    Provider<bool>((ref) => ref.watch(authProvider) == null);
