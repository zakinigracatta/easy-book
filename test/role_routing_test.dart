import 'package:flutter_test/flutter_test.dart';

import 'package:easy_book/models/user_model.dart';
import 'package:easy_book/routes/role_routing.dart';

UserModel _user(UserRole role) => UserModel(
      id: 'id',
      email: 'test@example.com',
      fullName: 'Test',
      phone: '',
      role: role,
    );

void main() {
  group('role routing', () {
    test('waits for session resolution on a web deep link', () {
      expect(
        RoleRouting.redirect(
          path: '/admin',
          user: null,
          sessionResolved: false,
        ),
        '/splash',
      );
    });

    test('signed-out admin route opens the admin login', () {
      expect(
        RoleRouting.redirect(
          path: '/admin/reports',
          user: null,
          sessionResolved: true,
        ),
        '/admin-login',
      );
    });

    test('admin can only remain in the admin area', () {
      final admin = _user(UserRole.admin);
      expect(
        RoleRouting.redirect(
          path: '/admin/customers',
          user: admin,
          sessionResolved: true,
        ),
        isNull,
      );
      expect(
        RoleRouting.redirect(
          path: '/admin/businesses/business-123',
          user: admin,
          sessionResolved: true,
        ),
        isNull,
      );
      expect(
        RoleRouting.redirect(
          path: '/home',
          user: admin,
          sessionResolved: true,
        ),
        '/admin',
      );
      expect(
        RoleRouting.redirect(
          path: '/owner-dashboard',
          user: admin,
          sessionResolved: true,
        ),
        '/admin',
      );
    });

    test('customer and owner cannot cross protected areas', () {
      expect(
        RoleRouting.redirect(
          path: '/admin',
          user: _user(UserRole.customer),
          sessionResolved: true,
        ),
        '/home',
      );
      expect(
        RoleRouting.redirect(
          path: '/admin/businesses/business-123',
          user: _user(UserRole.customer),
          sessionResolved: true,
        ),
        '/home',
      );
      expect(
        RoleRouting.redirect(
          path: '/home',
          user: _user(UserRole.owner),
          sessionResolved: true,
        ),
        '/owner-dashboard',
      );
    });
  });
}
