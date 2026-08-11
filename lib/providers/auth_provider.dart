import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/user_model.dart';
import '../repositories/auth_repository.dart';
import '../services/auth_service.dart';
import '../services/navigation_service.dart';

final navigationServiceProvider = Provider<NavigationService>((ref) {
  return NavigationService();
});

class AuthNotifier extends StateNotifier<UserModel?> {
  AuthNotifier(this._repository) : super(null) {
    _authSubscription = _repository.authStateChanges().listen(
          (user) => state = user,
        );
  }

  final AuthRepository _repository;
  StreamSubscription<UserModel?>? _authSubscription;

  bool get isLoggedIn => state != null;
  bool get isGuest => state == null;

  void setUser(UserModel? user) {
    state = user;
  }

  void onAuthStateChanged(UserModel? user) {
    state = user;
  }

  Future<UserModel> login(
    String email,
    String password, {
    UserRole? requestedRole,
  }) async {
    final user = await _repository.login(
      email,
      password,
      requestedRole: requestedRole,
    );

    state = user;
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

  Future<UserModel> signup({
    required String name,
    required String phone,
    required String email,
    required String password,
  }) {
    return registerCustomer(
      name: name,
      phone: phone,
      email: email,
      password: password,
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

  Future<void> logout() async {
    await _repository.logout();
    state = null;
  }

  Future<void> sendPasswordResetEmail(String email) {
    return _repository.sendPasswordResetEmail(email);
  }

  Future<void> resendEmailVerification() {
    return _repository.resendEmailVerification();
  }

  Future<bool> isEmailVerified() {
    return _repository.isEmailVerified();
  }

  void updateUserRole(UserRole role) {
    final current = state;
    if (current == null) return;

    state = UserModel(
      id: current.id,
      email: current.email,
      fullName: current.fullName,
      phone: current.phone,
      avatarUrl: current.avatarUrl,
      role: role,
      walletBalance: current.walletBalance,
      favoriteBusinessIds: current.favoriteBusinessIds,
      businessName: current.businessName,
      category: current.category,
      location: current.location,
      businessImageUrl: current.businessImageUrl,
    );
  }

  void updateWalletBalance(double amount) {
    final current = state;
    if (current == null) return;

    state = UserModel(
      id: current.id,
      email: current.email,
      fullName: current.fullName,
      phone: current.phone,
      avatarUrl: current.avatarUrl,
      role: current.role,
      walletBalance: current.walletBalance + amount,
      favoriteBusinessIds: current.favoriteBusinessIds,
      businessName: current.businessName,
      category: current.category,
      location: current.location,
      businessImageUrl: current.businessImageUrl,
    );
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, UserModel?>((ref) {
  final service = AuthService();
  final repository = AuthRepositoryImpl(service);
  return AuthNotifier(repository);
});

final isLoggedInProvider = Provider<bool>((ref) {
  return ref.watch(authProvider) != null;
});

final isGuestProvider = Provider<bool>((ref) {
  return ref.watch(authProvider) == null;
});
