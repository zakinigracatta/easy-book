import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';

import 'package:easy_book/admin/permissions/admin_permissions.dart';
import 'package:easy_book/admin/routing/admin_access.dart';
import 'package:easy_book/models/user_model.dart';
import 'package:easy_book/admin/screens/admin_portal_screen.dart';

UserModel user(UserRole role) => UserModel(
      id: 'user-id',
      email: 'user@example.com',
      fullName: 'Test User',
      phone: '',
      role: role,
    );

void main() {
  group('admin route guard', () {
    test('requires authentication', () {
      expect(
        AdminAccess.evaluate(user: null, isWeb: true),
        AdminAccessDecision.signIn,
      );
    });

    test('denies a normal user', () {
      expect(
        AdminAccess.evaluate(user: user(UserRole.customer), isWeb: true),
        AdminAccessDecision.forbidden,
      );
    });

    test('allows admin on web', () {
      expect(
        AdminAccess.evaluate(user: user(UserRole.admin), isWeb: true),
        AdminAccessDecision.allow,
      );
    });

    test('redirects admin to web-only experience on mobile', () {
      expect(
        AdminAccess.evaluate(user: user(UserRole.admin), isWeb: false),
        AdminAccessDecision.webOnly,
      );
    });
  });

  test('super admin has settings permission while admin does not', () {
    expect(
      AdminPermissions.allows(
        UserRole.superAdmin,
        AdminPermission.changePlatformSettings,
      ),
      isTrue,
    );
    expect(
      AdminPermissions.allows(
        UserRole.admin,
        AdminPermission.changePlatformSettings,
      ),
      isFalse,
    );
  });

  test('admin roles survive Firestore serialization', () {
    expect(user(UserRole.admin).toJson()['role'], 'admin');
    expect(user(UserRole.superAdmin).toJson()['role'], 'super_admin');
    expect(
        UserModel.fromJson({'role': 'super_admin'}).role, UserRole.superAdmin);
  });

  testWidgets('dashboard empty state is clear and stable', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: AdminEmptyState())),
    );
    expect(find.text('لا توجد بيانات متاحة حاليًا.'), findsOneWidget);
  });
}
