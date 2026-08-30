import '../models/user_model.dart';
import '../services/auth_service.dart';

abstract class AuthRepository {
  Stream<UserModel?> authStateChanges();
  Future<UserModel?> restoreSession();
  Future<UserModel> login(String email, String password,
      {UserRole? requestedRole});
  Future<UserModel> registerCustomer({
    required String name,
    required String phone,
    required String email,
    required String password,
    String? profileImageUrl,
  });
  Future<UserModel> registerBusinessOwner({
    required String businessName,
    required String category,
    required String phone,
    required String email,
    required String password,
    required String location,
    String? businessImageUrl,
  });
  Future<void> signOut();
  Future<void> sendEmailVerification();
  Future<bool> isCurrentEmailVerified();
  Future<void> sendPasswordResetEmail(String email);
}

class AuthRepositoryImpl implements AuthRepository {
  final AuthService _authService;

  AuthRepositoryImpl(this._authService);

  @override
  Stream<UserModel?> authStateChanges() => _authService.authStateChanges();

  @override
  Future<UserModel?> restoreSession() => _authService.restoreSession();

  @override
  Future<UserModel> login(String email, String password,
      {UserRole? requestedRole}) {
    return _authService.login(email, password, requestedRole: requestedRole);
  }

  @override
  Future<UserModel> registerCustomer({
    required String name,
    required String phone,
    required String email,
    required String password,
    String? profileImageUrl,
  }) {
    return _authService.registerCustomer(
      name: name,
      phone: phone,
      email: email,
      password: password,
      profileImageUrl: profileImageUrl,
    );
  }

  @override
  Future<UserModel> registerBusinessOwner({
    required String businessName,
    required String category,
    required String phone,
    required String email,
    required String password,
    required String location,
    String? businessImageUrl,
  }) {
    return _authService.registerBusinessOwner(
      businessName: businessName,
      category: category,
      phone: phone,
      email: email,
      password: password,
      location: location,
      businessImageUrl: businessImageUrl,
    );
  }

  @override
  Future<void> signOut() => _authService.signOut();

  @override
  Future<void> sendEmailVerification() => _authService.sendEmailVerification();

  @override
  Future<bool> isCurrentEmailVerified() =>
      _authService.isCurrentEmailVerified();

  @override
  Future<void> sendPasswordResetEmail(String email) =>
      _authService.sendPasswordResetEmail(email);
}
