import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';
import '../repositories/auth_repository.dart';
import '../services/auth_service.dart';
import '../services/navigation_service.dart';

/// Provider for NavigationService singleton
final navigationServiceProvider = Provider<NavigationService>((ref) {
  return NavigationService();
});

/// Riverpod AuthNotifier managing Guest user vs Logged in user state.
///
/// Designed so FirebaseAuth listener (authStateChanges) or Firestore user fetching
/// can replace the underlying mock logic without modifying any screen code.
class AuthNotifier extends StateNotifier<UserModel?> {
  final AuthRepository? _repository;

  /// Default state is null (Guest mode)
  AuthNotifier([this._repository]) : super(null);

  /// Whether current user is logged in
  bool get isLoggedIn => state != null;

  /// Whether user is currently browsing as Guest
  bool get isGuest => state == null;

  /// Set explicit user state (e.g. from Firebase Auth state changes listener)
  void setUser(UserModel? user) {
    state = user;
  }

  /// Entry point for future FirebaseAuth.instance.authStateChanges() listener
  void onAuthStateChanged(UserModel? user) {
    state = user;
  }

  /// Login with email & password (compatible with future Firebase Auth signInWithEmailAndPassword)
  Future<UserModel> login(String email, String password, {UserRole? requestedRole}) async {
    final repo = _repository;
    if (repo != null) {
      final user = await repo.login(email, password, requestedRole: requestedRole);
      state = user;
      return user;
    }

    final isOwner = requestedRole == UserRole.owner || email.contains('owner') || email.contains('business');
    final mockUser = UserModel(
      id: 'usr_${DateTime.now().millisecondsSinceEpoch}',
      email: email,
      fullName: isOwner ? 'Master Salon Partner' : 'Alex Vance',
      phone: '+1 234 567 8900',
      role: isOwner ? UserRole.owner : UserRole.customer,
      walletBalance: 250.00,
      businessName: isOwner ? 'Executive Barber Lounge' : null,
      category: isOwner ? 'Barber' : null,
      location: isOwner ? '142 Luxury Blvd, NYC' : null,
    );
    state = mockUser;
    return mockUser;
  }

  /// Register new Customer (compatible with future Firebase Auth createUserWithEmailAndPassword + Firestore)
  Future<UserModel> registerCustomer({
    required String name,
    required String phone,
    required String email,
    required String password,
    String? profileImageUrl,
  }) async {
    final repo = _repository;
    if (repo != null) {
      final user = await repo.registerCustomer(
        name: name,
        phone: phone,
        email: email,
        password: password,
        profileImageUrl: profileImageUrl,
      );
      state = user;
      return user;
    }

    final mockUser = UserModel(
      id: 'cust_${DateTime.now().millisecondsSinceEpoch}',
      email: email,
      fullName: name,
      phone: phone,
      avatarUrl: profileImageUrl ?? 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?auto=format&fit=crop&w=150&q=80',
      role: UserRole.customer,
      walletBalance: 100.00,
    );
    state = mockUser;
    return mockUser;
  }

  /// Signup alias for customer registration
  Future<UserModel> signup({
    required String name,
    required String phone,
    required String email,
    required String password,
  }) => registerCustomer(name: name, phone: phone, email: email, password: password);

  /// Register new Business Owner (compatible with future Firebase Auth + Firestore business user)
  Future<UserModel> registerBusinessOwner({
    required String businessName,
    required String category,
    required String phone,
    required String email,
    required String password,
    required String location,
    String? businessImageUrl,
  }) async {
    final repo = _repository;
    if (repo != null) {
      final user = await repo.registerBusinessOwner(
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

    final mockUser = UserModel(
      id: 'owner_${DateTime.now().millisecondsSinceEpoch}',
      email: email,
      fullName: businessName,
      phone: phone,
      role: UserRole.owner,
      businessName: businessName,
      category: category,
      location: location,
      businessImageUrl: businessImageUrl ?? 'https://images.unsplash.com/photo-1503951914875-452162b0f3f1?auto=format&fit=crop&w=600&q=80',
    );
    state = mockUser;
    return mockUser;
  }

  /// Logout user and return state to Guest mode (null)
  void logout() {
    state = null;
  }

  /// Update user role (useful for role-switching between Customer, Owner, Admin)
  void updateUserRole(UserRole role) {
    if (state != null) {
      state = UserModel(
        id: state!.id,
        email: state!.email,
        fullName: state!.fullName,
        phone: state!.phone,
        avatarUrl: state!.avatarUrl,
        role: role,
        walletBalance: state!.walletBalance,
        favoriteBusinessIds: state!.favoriteBusinessIds,
        businessName: state!.businessName,
        category: state!.category,
        location: state!.location,
        businessImageUrl: state!.businessImageUrl,
      );
    }
  }

  /// Update wallet balance
  void updateWalletBalance(double amount) {
    if (state != null) {
      state = UserModel(
        id: state!.id,
        email: state!.email,
        fullName: state!.fullName,
        phone: state!.phone,
        avatarUrl: state!.avatarUrl,
        role: state!.role,
        walletBalance: state!.walletBalance + amount,
        favoriteBusinessIds: state!.favoriteBusinessIds,
        businessName: state!.businessName,
        category: state!.category,
        location: state!.location,
        businessImageUrl: state!.businessImageUrl,
      );
    }
  }
}

/// Main Auth Provider
final authProvider = StateNotifierProvider<AuthNotifier, UserModel?>((ref) {
  final service = AuthService();
  final repo = AuthRepositoryImpl(service);
  return AuthNotifier(repo);
});

/// Convenience provider checking if current user is authenticated
final isLoggedInProvider = Provider<bool>((ref) {
  return ref.watch(authProvider) != null;
});

/// Convenience provider checking if session is in Guest mode
final isGuestProvider = Provider<bool>((ref) {
  return ref.watch(authProvider) == null;
});
