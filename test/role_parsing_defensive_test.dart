import 'package:flutter_test/flutter_test.dart';
import 'package:easy_book/models/user_model.dart';

void main() {
  group('Scenario 6: Role Parsing & Defensive Authorization Tests', () {
    test('1. Valid "admin" role maps explicitly to UserRole.admin', () {
      final user = UserModel.fromJson({'id': 'u1', 'role': 'admin'});
      expect(user.role, equals(UserRole.admin));
      expect(user.roleString, equals('admin'));
    });

    test('2. Valid "owner" and "businessOwner" roles map to UserRole.owner', () {
      final user1 = UserModel.fromJson({'id': 'u1', 'role': 'owner'});
      expect(user1.role, equals(UserRole.owner));
      expect(user1.roleString, equals('owner'));

      final user2 = UserModel.fromJson({'id': 'u2', 'role': 'businessOwner'});
      expect(user2.role, equals(UserRole.owner));
      expect(user2.roleString, equals('owner'));
    });

    test('3. Valid "customer" role maps to UserRole.customer', () {
      final user = UserModel.fromJson({'id': 'u1', 'role': 'customer'});
      expect(user.role, equals(UserRole.customer));
      expect(user.roleString, equals('customer'));
    });

    test('4. Missing role defaults safely to UserRole.customer (never admin)', () {
      final user = UserModel.fromJson({'id': 'u1'});
      expect(user.role, equals(UserRole.customer));
      expect(user.role, isNot(equals(UserRole.admin)));
      expect(user.role, isNot(equals(UserRole.owner)));
    });

    test('5. Unknown role "superadmin" does not escalate privileges to admin or owner', () {
      final user = UserModel.fromJson({'id': 'u1', 'role': 'superadmin'});
      expect(user.role, equals(UserRole.customer));
      expect(user.role, isNot(equals(UserRole.admin)));
      expect(user.role, isNot(equals(UserRole.owner)));
    });

    test('6. Malformed and unexpected role values map safely to UserRole.customer', () {
      final inputs = [
        'ADMIN',
        'OWNER',
        'root',
        'operator',
        'sysadmin',
        '12345',
        '',
        '   admin   ',
      ];

      for (final input in inputs) {
        final user = UserModel.fromJson({'id': 'u1', 'role': input});
        expect(
          user.role,
          equals(UserRole.customer),
          reason: 'Failed for input: "$input"',
        );
      }
    });

    test('7. Numeric and boolean string role payloads map safely to UserRole.customer', () {
      final userInt = UserModel.fromJson({'id': 'u1', 'role': '999'});
      expect(userInt.role, equals(UserRole.customer));

      final userBool = UserModel.fromJson({'id': 'u1', 'role': 'true'});
      expect(userBool.role, equals(UserRole.customer));
    });
  });
}
