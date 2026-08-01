import '../models/user_model.dart';

class AuthService {
  // Simulates Firebase / Supabase Auth & Firestore Role storage
  Future<UserModel> login(String email, String password, {UserRole? requestedRole}) async {
    await Future.delayed(const Duration(milliseconds: 600));
    final isOwner = requestedRole == UserRole.owner || email.contains('owner') || email.contains('business');
    final role = isOwner ? UserRole.owner : UserRole.customer;

    return UserModel(
      id: 'usr_${DateTime.now().millisecondsSinceEpoch}',
      email: email,
      fullName: isOwner ? 'Master Salon Partner' : 'Alex Vance',
      phone: '+1 234 567 8900',
      role: role,
      walletBalance: 250.00,
      businessName: isOwner ? 'Executive Barber Lounge' : null,
      category: isOwner ? 'Barber' : null,
      location: isOwner ? '142 Luxury Blvd, NYC' : null,
    );
  }

  // Register Customer -> role: 'customer' saved in Firebase/Supabase
  Future<UserModel> registerCustomer({
    required String name,
    required String phone,
    required String email,
    required String password,
    String? profileImageUrl,
  }) async {
    await Future.delayed(const Duration(milliseconds: 600));
    return UserModel(
      id: 'cust_${DateTime.now().millisecondsSinceEpoch}',
      email: email,
      fullName: name,
      phone: phone,
      avatarUrl: profileImageUrl ?? 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?auto=format&fit=crop&w=150&q=80',
      role: UserRole.customer,
      walletBalance: 100.00,
    );
  }

  // Register Business Owner -> role: 'owner' saved in Firebase/Supabase
  Future<UserModel> registerBusinessOwner({
    required String businessName,
    required String category,
    required String phone,
    required String email,
    required String password,
    required String location,
    String? businessImageUrl,
  }) async {
    await Future.delayed(const Duration(milliseconds: 600));
    return UserModel(
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
  }
}
