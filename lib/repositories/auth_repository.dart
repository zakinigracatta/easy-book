import '../models/user_model.dart';
import '../services/auth_service.dart';

abstract class AuthRepository {
  Future<UserModel> login(String email, String password, {UserRole? requestedRole});
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
}

class AuthRepositoryImpl implements AuthRepository {
  final AuthService _authService;

  AuthRepositoryImpl(this._authService);

  @override
  Future<UserModel> login(String email, String password, {UserRole? requestedRole}) {
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
}
