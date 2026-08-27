import 'package:easy_book/models/user_model.dart';

/// Reusable test fixtures for authentication & authorization regression tests.
class AuthFixtures {
  static final UserModel customerUser = UserModel(
    id: 'cust_test_101',
    email: 'customer@easybook.com',
    fullName: 'Test Customer',
    phone: '+1 555-0101',
    role: UserRole.customer,
  );

  static final UserModel ownerUser = UserModel(
    id: 'owner_test_202',
    email: 'owner@easybook.com',
    fullName: 'Test Salon Owner',
    phone: '+1 555-0202',
    role: UserRole.owner,
    businessName: 'Luxury Salon Lounge',
  );

  static final UserModel adminUser = UserModel(
    id: 'admin_test_303',
    email: 'admin@easybook.com',
    fullName: 'Admin User',
    phone: '+1 555-0303',
    role: UserRole.admin,
  );

  static final UserModel superAdminUser = UserModel(
    id: 'super_admin_test_404',
    email: 'superadmin@easybook.com',
    fullName: 'Super Admin',
    phone: '+1 555-0404',
    role: UserRole.superAdmin,
  );
}
