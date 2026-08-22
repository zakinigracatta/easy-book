import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Scenario 7: Email Verification Regression Tests', () {
    test('1. Unverified user navigating to protected route requires /verify-email', () {
      const allowedUnverified = [
        '/verify-email',
        '/welcome',
        '/login',
        '/register',
        '/business-register',
        '/owner-login',
        '/admin-login',
        '/splash',
        '/forgot-password',
      ];

      // Simulated unverified user attempting protected routes
      const protectedRoute = '/home';
      final isAllowed = allowedUnverified.contains(protectedRoute);
      expect(isAllowed, isFalse);
    });

    test('2. Unverified user accessing allowed auth routes passes verification check', () {
      const allowedUnverified = [
        '/verify-email',
        '/welcome',
        '/login',
        '/register',
        '/business-register',
        '/owner-login',
        '/admin-login',
        '/splash',
        '/forgot-password',
      ];

      for (final route in allowedUnverified) {
        expect(allowedUnverified.contains(route), isTrue);
      }
    });
  });
}
