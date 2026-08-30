import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/test.dart';
import 'package:firebase_auth_platform_interface/firebase_auth_platform_interface.dart';

import 'package:easy_book/routes/app_router.dart';
import 'package:easy_book/models/user_model.dart';
import 'package:easy_book/providers/auth_provider.dart';
import 'package:easy_book/repositories/auth_repository.dart';
import 'package:easy_book/screens/auth/welcome_screen.dart';
import 'package:easy_book/screens/auth/login_screen.dart';
import 'fixtures/auth_fixtures.dart';
import 'fixtures/mock_firebase_auth.dart';

final MockFirebaseAuthPlatform globalMockAuthPlatform =
    MockFirebaseAuthPlatform();

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    HttpOverrides.global = TestHttpOverrides();
    setupFirebaseCoreMocks();
    FirebaseAuthPlatform.instance = globalMockAuthPlatform;
    await Firebase.initializeApp();
  });

  setUp(() {
    globalMockAuthPlatform.clearUser();
  });

  String getCurrentLocation() {
    return appRouter.routerDelegate.currentConfiguration.last.matchedLocation;
  }

  Future<void> navigateAndPump(WidgetTester tester, String location) async {
    appRouter.go(location);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
  }

  Widget buildTestApp({UserModel? user, ProviderContainer? container}) {
    if (user != null) {
      globalMockAuthPlatform.setMockUser(user.id, user.email);
    } else {
      globalMockAuthPlatform.clearUser();
    }

    final effectiveContainer = container ??
        ProviderContainer(
          overrides: [
            if (user != null)
              authProvider.overrideWith((ref) {
                final notifier = AuthNotifier(FakeAuthRepository());
                notifier.setUser(user);
                return notifier;
              }),
          ],
        );

    return UncontrolledProviderScope(
      container: effectiveContainer,
      child: MaterialApp.router(
        routerConfig: appRouter,
      ),
    );
  }

  group('Pure evaluateRouteGuard Unit Tests (Web & Mobile Authorization Rules)', () {
    test('1. Fail-Closed: Authenticated user with unresolved/null role cannot access /admin on Web', () {
      final redirectTarget = evaluateRouteGuard(
        location: '/admin/dashboard',
        isWeb: true,
        hasFirebaseUser: true,
        isEmailVerified: true,
        userModel: null, // Profile/role has not loaded yet
      );
      expect(redirectTarget, equals(adminAccessDeniedRoute),
          reason: 'Unresolved role must fail closed and redirect to access-denied');
    });

    test('2. Customer cannot access /admin on Web', () {
      final redirectTarget = evaluateRouteGuard(
        location: '/admin/dashboard',
        isWeb: true,
        hasFirebaseUser: true,
        isEmailVerified: true,
        userModel: AuthFixtures.customerUser,
      );
      expect(redirectTarget, equals(adminAccessDeniedRoute),
          reason: 'Customer user must be denied access to Web Admin routes');
    });

    test('3. Business Owner cannot access /admin on Web', () {
      final redirectTarget = evaluateRouteGuard(
        location: '/admin/dashboard',
        isWeb: true,
        hasFirebaseUser: true,
        isEmailVerified: true,
        userModel: AuthFixtures.ownerUser,
      );
      expect(redirectTarget, equals(adminAccessDeniedRoute),
          reason: 'Business owner user must be denied access to Web Admin routes');
    });

    test('4. Admin CAN access /admin on Web', () {
      final redirectTarget = evaluateRouteGuard(
        location: '/admin/dashboard',
        isWeb: true,
        hasFirebaseUser: true,
        isEmailVerified: true,
        userModel: AuthFixtures.adminUser,
      );
      expect(redirectTarget, isNull,
          reason: 'Admin user must be granted access to Web Admin routes');
    });

    test('5. Super Admin CAN access /admin on Web', () {
      final redirectTarget = evaluateRouteGuard(
        location: '/admin/dashboard',
        isWeb: true,
        hasFirebaseUser: true,
        isEmailVerified: true,
        userModel: AuthFixtures.superAdminUser,
      );
      expect(redirectTarget, isNull,
          reason: 'Super admin user must be granted access to Web Admin routes');
    });

    test('6. Unauthenticated Guest on Web accessing /admin redirects to /admin/login', () {
      final redirectTarget = evaluateRouteGuard(
        location: '/admin/dashboard',
        isWeb: true,
        hasFirebaseUser: false,
        isEmailVerified: true,
        userModel: null,
      );
      expect(redirectTarget, equals(adminLoginRoute));
    });

    test('6b. Customer cannot access /admin/businesses or /admin/businesses/:id on Web', () {
      final redirectTargetBusinesses = evaluateRouteGuard(
        location: '/admin/businesses',
        isWeb: true,
        hasFirebaseUser: true,
        isEmailVerified: true,
        userModel: AuthFixtures.customerUser,
      );
      expect(redirectTargetBusinesses, equals(adminAccessDeniedRoute));

      final redirectTargetDetails = evaluateRouteGuard(
        location: '/admin/businesses/b1',
        isWeb: true,
        hasFirebaseUser: true,
        isEmailVerified: true,
        userModel: AuthFixtures.customerUser,
      );
      expect(redirectTargetDetails, equals(adminAccessDeniedRoute));
    });

    test('6c. Admin CAN access /admin/businesses and /admin/businesses/:id on Web', () {
      final redirectTargetBusinesses = evaluateRouteGuard(
        location: '/admin/businesses',
        isWeb: true,
        hasFirebaseUser: true,
        isEmailVerified: true,
        userModel: AuthFixtures.adminUser,
      );
      expect(redirectTargetBusinesses, isNull);

      final redirectTargetDetails = evaluateRouteGuard(
        location: '/admin/businesses/b1',
        isWeb: true,
        hasFirebaseUser: true,
        isEmailVerified: true,
        userModel: AuthFixtures.adminUser,
      );
      expect(redirectTargetDetails, isNull);
    });

    test('7. Mobile user (any role) accessing /admin redirects to /admin-web-only', () {
      for (final roleUser in [
        null,
        AuthFixtures.customerUser,
        AuthFixtures.ownerUser,
        AuthFixtures.adminUser,
        AuthFixtures.superAdminUser
      ]) {
        final redirectTarget = evaluateRouteGuard(
          location: '/admin/dashboard',
          isWeb: false,
          hasFirebaseUser: roleUser != null,
          isEmailVerified: true,
          userModel: roleUser,
        );
        expect(redirectTarget, equals(adminWebOnlyRoute),
            reason: 'All mobile attempts to access /admin must redirect to /admin-web-only');
      }
    });

    test('8. Existing Customer protected routes remain protected for Guests', () {
      for (final route in customerProtectedRoutes) {
        final redirectTarget = evaluateRouteGuard(
          location: route,
          isWeb: false,
          hasFirebaseUser: false,
          isEmailVerified: true,
          userModel: null,
        );
        expect(redirectTarget, equals('/login'),
            reason: 'Guest accessing customer route $route must redirect to /login');
      }
    });

    test('9. Existing Business Partner protected routes remain protected', () {
      for (final route in ownerProtectedRoutes) {
        // Guest attempt
        final guestRedirect = evaluateRouteGuard(
          location: route,
          isWeb: false,
          hasFirebaseUser: false,
          isEmailVerified: true,
          userModel: null,
        );
        expect(guestRedirect, equals('/owner-login'),
            reason: 'Guest accessing owner route $route must redirect to /owner-login');

        // Customer attempt
        final customerRedirect = evaluateRouteGuard(
          location: route,
          isWeb: false,
          hasFirebaseUser: true,
          isEmailVerified: true,
          userModel: AuthFixtures.customerUser,
        );
        expect(customerRedirect, equals('/home'),
            reason: 'Customer accessing owner route $route must redirect to /home');

        // Owner attempt
        final ownerRedirect = evaluateRouteGuard(
          location: route,
          isWeb: false,
          hasFirebaseUser: true,
          isEmailVerified: true,
          userModel: AuthFixtures.ownerUser,
        );
        expect(ownerRedirect, isNull,
            reason: 'Owner accessing owner route $route must be allowed');
      }
    });
  });

  group('Widget & Router Flow Tests', () {
    testWidgets('Customer cannot access Admin routes on mobile (redirected to /admin-web-only)',
        (tester) async {
      final container = ProviderContainer(
        overrides: [
          authProvider.overrideWith((ref) {
            final notifier = AuthNotifier(FakeAuthRepository());
            notifier.setUser(AuthFixtures.customerUser);
            return notifier;
          }),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(
          buildTestApp(user: AuthFixtures.customerUser, container: container));
      await tester.pump(const Duration(seconds: 2));

      await navigateAndPump(tester, '/admin');
      expect(getCurrentLocation(), equals('/admin-web-only'));

      await navigateAndPump(tester, '/admin/dashboard');
      expect(getCurrentLocation(), equals('/admin-web-only'));
    });

    testWidgets('Business Partner cannot access Admin routes on mobile (redirected to /admin-web-only)',
        (tester) async {
      final container = ProviderContainer(
        overrides: [
          authProvider.overrideWith((ref) {
            final notifier = AuthNotifier(FakeAuthRepository());
            notifier.setUser(AuthFixtures.ownerUser);
            return notifier;
          }),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(
          buildTestApp(user: AuthFixtures.ownerUser, container: container));
      await tester.pump(const Duration(seconds: 2));

      await navigateAndPump(tester, '/admin');
      expect(getCurrentLocation(), equals('/admin-web-only'));
    });

    testWidgets('Admin and Super Admin role models correctly identify admin privileges',
        (tester) async {
      expect(AuthFixtures.adminUser.isAdmin, isTrue);
      expect(AuthFixtures.superAdminUser.isAdmin, isTrue);
      expect(AuthFixtures.customerUser.isAdmin, isFalse);
      expect(AuthFixtures.ownerUser.isAdmin, isFalse);

      expect(AuthFixtures.adminUser.roleString, equals('admin'));
      expect(AuthFixtures.superAdminUser.roleString, equals('super_admin'));
      expect(AuthFixtures.customerUser.roleString, equals('customer'));
      expect(AuthFixtures.ownerUser.roleString, equals('owner'));
    });

    testWidgets('Direct navigation to /admin is protected on mobile',
        (tester) async {
      await tester.pumpWidget(buildTestApp(user: null));
      await tester.pump(const Duration(seconds: 2));

      await navigateAndPump(tester, '/admin');
      expect(getCurrentLocation(), equals('/admin-web-only'));
    });

    testWidgets('Public UI (WelcomeScreen) does not contain Register as Admin or Admin Portal',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: WelcomeScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Admin Portal'), findsNothing);
      expect(find.text('Register as Admin'), findsNothing);
      expect(find.text('Super Admin'), findsNothing);

      expect(find.text('Customer Portal'), findsOneWidget);
      expect(find.text('Business Portal'), findsOneWidget);
    });

    testWidgets('Public LoginScreen does not contain Register as Admin',
        (tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: LoginScreen(),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Register as Admin'), findsNothing);
      expect(find.text('Admin Login'), findsNothing);
    });

    test('Customer registration cannot assign admin role', () async {
      final user = UserModel.fromJson({
        'id': 'u1',
        'email': 'c@test.com',
        'full_name': 'Test',
        'phone': '123',
        'role': 'customer',
      });
      expect(user.role, equals(UserRole.customer));
      expect(user.isAdmin, isFalse);

      final tamperedUser = UserModel.fromJson({
        'id': 'u2',
        'email': 'tampered@test.com',
        'role': 'hacker_role',
      });
      expect(tamperedUser.role, equals(UserRole.customer));
    });

    test('Business registration cannot assign admin role', () async {
      final user = UserModel.fromJson({
        'id': 'u3',
        'email': 'b@test.com',
        'full_name': 'Business',
        'phone': '123',
        'role': 'owner',
      });
      expect(user.role, equals(UserRole.owner));
      expect(user.isAdmin, isFalse);
    });

    testWidgets('Mobile splash screen routes admin user to /admin-web-only',
        (tester) async {
      final container = ProviderContainer(
        overrides: [
          authProvider.overrideWith((ref) {
            final notifier = AuthNotifier(FakeAuthRepository());
            notifier.setUser(AuthFixtures.adminUser);
            return notifier;
          }),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(
          buildTestApp(user: AuthFixtures.adminUser, container: container));
      appRouter.go('/splash');
      await tester.pump();

      await tester.pump(const Duration(seconds: 2, milliseconds: 300));
      expect(getCurrentLocation(), equals('/admin-web-only'));
    });
  });
}

class FakeAuthRepository implements AuthRepository {
  @override
  Stream<UserModel?> authStateChanges() => const Stream.empty();

  @override
  Future<UserModel> login(String email, String password,
      {UserRole? requestedRole}) async {
    throw UnimplementedError();
  }

  @override
  Future<UserModel> registerCustomer({
    required String name,
    required String phone,
    required String email,
    required String password,
    String? profileImageUrl,
  }) async {
    throw UnimplementedError();
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
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<void> logout() async {}

  @override
  Future<void> sendPasswordResetEmail(String email) async {}

  @override
  Future<void> resendEmailVerification() async {}

  @override
  Future<bool> isEmailVerified() async => true;
}

class TestHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return MockHttpClient();
  }
}

class MockHttpClient extends Fake implements HttpClient {
  @override
  bool autoUncompress = true;

  @override
  Future<HttpClientRequest> getUrl(Uri url) async => MockHttpClientRequest();

  @override
  Future<HttpClientRequest> openUrl(String method, Uri url) async =>
      MockHttpClientRequest();
}

class MockHttpClientRequest extends Fake implements HttpClientRequest {
  @override
  HttpHeaders get headers => MockHttpHeaders();

  @override
  Future<HttpClientResponse> close() async => MockHttpClientResponse();
}

class MockHttpHeaders extends Fake implements HttpHeaders {}

class MockHttpClientResponse extends Fake implements HttpClientResponse {
  @override
  int get statusCode => 200;

  @override
  int get contentLength => transparentPixel.length;

  @override
  HttpClientResponseCompressionState get compressionState =>
      HttpClientResponseCompressionState.notCompressed;

  @override
  StreamSubscription<List<int>> listen(void Function(List<int> event)? onData,
      {Function? onError, void Function()? onDone, bool? cancelOnError}) {
    return Stream<List<int>>.value(transparentPixel).listen(onData,
        onError: onError, onDone: onDone, cancelOnError: cancelOnError);
  }
}

final transparentPixel = <int>[
  0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D,
  0x49, 0x48, 0x44, 0x52, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01,
  0x08, 0x06, 0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4, 0x89, 0x00, 0x00, 0x00,
  0x0A, 0x49, 0x44, 0x41, 0x54, 0x78, 0x9C, 0x63, 0x00, 0x01, 0x00, 0x00,
  0x05, 0x00, 0x01, 0x0D, 0x0A, 0x2D, 0xB4, 0x00, 0x00, 0x00, 0x00, 0x49,
  0x45, 0x4E, 0x44, 0xAE, 0x42, 0x60, 0x82
];
