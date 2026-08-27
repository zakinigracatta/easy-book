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
import 'package:easy_book/services/auth_guard.dart';
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

  group('Modern Startup Flow & Runtime Failsafe Tests', () {
    testWidgets(
        'Test A: Guest Startup Resolves immediately to /home without waiting for profile',
        (tester) async {
      await tester.pumpWidget(buildTestApp(user: null));
      appRouter.go('/splash');
      await tester.pump();
      expect(getCurrentLocation(), equals('/splash'));

      await tester.pump(const Duration(seconds: 2));
      await tester.pump(const Duration(milliseconds: 300));

      expect(getCurrentLocation(), equals('/home'));
      expect(find.text('Customer Portal'), findsNothing);
    });

    testWidgets(
        'Test B: Auth Provider Error / Slow Profile does not spin forever, falls back to /home',
        (tester) async {
      globalMockAuthPlatform.setMockUser('user123', 'slow@test.com');
      final container = ProviderContainer(
        overrides: [
          authProvider
              .overrideWith((ref) => AuthNotifier(FakeAuthRepository())),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(routerConfig: appRouter),
      ));
      appRouter.go('/splash');
      await tester.pump();
      expect(getCurrentLocation(), equals('/splash'));

      // Advance time past minimum delay and bounded timeout (2s + 3s = 5s)
      await tester.pump(const Duration(seconds: 5, milliseconds: 500));

      expect(getCurrentLocation(), equals('/home'));
    });

    testWidgets('Test C: Owner Startup resolves to /owner-dashboard',
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
      appRouter.go('/splash');
      await tester.pump();

      await tester.pump(const Duration(seconds: 2, milliseconds: 300));
      expect(getCurrentLocation(), equals('/owner-dashboard'));
    });

    testWidgets('Test D: Admin Startup on mobile resolves to /admin-web-only',
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

    testWidgets(
        'Test E: Stale Owner State (null FirebaseAuth) denies owner access and opens /home',
        (tester) async {
      globalMockAuthPlatform.clearUser();
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

      await tester.pumpWidget(UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(routerConfig: appRouter),
      ));
      appRouter.go('/splash');
      await tester.pump();

      await tester.pump(const Duration(seconds: 2, milliseconds: 300));
      expect(getCurrentLocation(), equals('/home'));
    });

    testWidgets(
        'Test F: Stale Admin State (null FirebaseAuth) denies admin access and opens /home',
        (tester) async {
      globalMockAuthPlatform.clearUser();
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

      await tester.pumpWidget(UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(routerConfig: appRouter),
      ));
      appRouter.go('/splash');
      await tester.pump();

      await tester.pump(const Duration(seconds: 2, milliseconds: 300));
      expect(getCurrentLocation(), equals('/home'));
    });

    testWidgets(
        'Test G: Bounded Timeout Failsafe guarantees resolution past timeout',
        (tester) async {
      globalMockAuthPlatform.setMockUser('user_timeout', 'timeout@test.com');
      final container = ProviderContainer(
        overrides: [
          authProvider
              .overrideWith((ref) => AuthNotifier(FakeAuthRepository())),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(routerConfig: appRouter),
      ));
      appRouter.go('/splash');
      await tester.pump();

      await tester.pump(const Duration(seconds: 6));
      expect(getCurrentLocation(), isNot(equals('/splash')));
    });
  });

  group('Route Authorization & Navigation Regression Tests', () {
    testWidgets(
        'Scenario 1: Guest -> /owner-dashboard redirects to /owner-login',
        (tester) async {
      await tester.pumpWidget(buildTestApp(user: null));
      await tester.pump(const Duration(seconds: 2));
      await tester.pump(const Duration(milliseconds: 600));

      await navigateAndPump(tester, '/owner-dashboard');

      expect(getCurrentLocation(), equals('/owner-login'));
    });

    testWidgets(
        'Scenario 2: Guest -> /admin-dashboard on mobile redirects to /admin-web-only',
        (tester) async {
      await tester.pumpWidget(buildTestApp(user: null));
      await tester.pump(const Duration(seconds: 2));
      await tester.pump(const Duration(milliseconds: 600));

      await navigateAndPump(tester, '/admin-dashboard');

      expect(getCurrentLocation(), equals('/admin-web-only'));
    });

    testWidgets(
        'Scenario 3: Customer -> /owner-dashboard redirects to /home & admin routes redirect to /admin-web-only',
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
      await tester.pump(const Duration(milliseconds: 600));

      // Attempt owner route
      await navigateAndPump(tester, '/owner-dashboard');
      expect(getCurrentLocation(), equals('/home'));

      // Attempt salon management route
      await navigateAndPump(tester, '/salon-management');
      expect(getCurrentLocation(), equals('/home'));

      // Attempt admin route
      await navigateAndPump(tester, '/admin-dashboard');
      expect(getCurrentLocation(), equals('/admin-web-only'));

      // Attempt users management route
      await navigateAndPump(tester, '/users-management');
      expect(getCurrentLocation(), equals('/admin-web-only'));
    });

    testWidgets(
        'Scenario 4: Owner -> /owner-dashboard & /salon-management CAN access',
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
      await tester.pump(const Duration(milliseconds: 600));

      await navigateAndPump(tester, '/owner-dashboard');
      expect(getCurrentLocation(), equals('/owner-dashboard'));

      await navigateAndPump(tester, '/salon-management');
      expect(getCurrentLocation(), equals('/salon-management'));
    });

    testWidgets(
        'Scenario 5: Admin -> /admin-dashboard on mobile redirects to /admin-web-only',
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
      await tester.pump(const Duration(seconds: 2));
      await tester.pump(const Duration(milliseconds: 600));

      await navigateAndPump(tester, '/admin-dashboard');
      expect(getCurrentLocation(), equals('/admin-web-only'));

      await navigateAndPump(tester, '/users-management');
      expect(getCurrentLocation(), equals('/admin-web-only'));
    });

    testWidgets('Scenario 8: Guest Customer Browsing remains functional',
        (tester) async {
      await tester.pumpWidget(buildTestApp(user: null));
      await tester.pump(const Duration(seconds: 2));
      await tester.pump(const Duration(milliseconds: 600));

      const publicRoutes = [
        '/welcome',
        '/home',
        '/search',
        '/categories',
        '/salon-list',
        '/service-details',
        '/staff-profile',
        '/gallery',
        '/reviews',
        '/location',
        '/booking',
        '/booking-service',
        '/booking-specialist',
        '/booking-date',
        '/booking-time',
      ];

      for (final route in publicRoutes) {
        await navigateAndPump(tester, route);
        expect(getCurrentLocation(), equals(route),
            reason: 'Guest should be allowed to view public route $route');
      }
    });

    testWidgets(
        'Scenario 8b: Protected Customer Action triggers requireLogin auth prompt',
        (tester) async {
      final container = ProviderContainer(
        overrides: [
          authProvider
              .overrideWith((ref) => AuthNotifier(FakeAuthRepository())),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) => ElevatedButton(
                  onPressed: () =>
                      requireLogin(context, targetRoute: '/my-bookings'),
                  child: const Text('Book Action'),
                ),
              ),
            ),
          ),
        ),
      );

      expect(container.read(authProvider), isNull);
    });

    testWidgets(
        'Scenario 10: Logout Routing clears auth state & enforces guest protection',
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

      expect(container.read(authProvider)?.role, equals(UserRole.owner));

      await container.read(authProvider.notifier).logout();
      await tester.pump();

      expect(container.read(authProvider), isNull);
      expect(container.read(isLoggedInProvider), isFalse);
      expect(container.read(isGuestProvider), isTrue);
    });

    testWidgets(
        'Scenario 11 (Security Regression): Stale Riverpod Owner/Admin state DENIED when FirebaseAuth currentUser is null',
        (tester) async {
      // 1. Explicitly clear FirebaseAuth currentUser (session revoked/null)
      globalMockAuthPlatform.clearUser();

      // 2. Mock Riverpod authProvider with a stale in-memory Owner UserModel
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
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp.router(
            routerConfig: appRouter,
          ),
        ),
      );
      await tester.pump(const Duration(seconds: 2));
      await tester.pump(const Duration(milliseconds: 600));

      // 3. Stale owner attempting /owner-dashboard MUST BE DENIED and redirected to /owner-login
      await navigateAndPump(tester, '/owner-dashboard');
      expect(getCurrentLocation(), equals('/owner-login'),
          reason:
              'Stale Riverpod owner user without FirebaseAuth session must be denied');

      // 4. Stale admin attempting /admin-dashboard MUST BE DENIED and redirected to /admin-login
      final adminContainer = ProviderContainer(
        overrides: [
          authProvider.overrideWith((ref) {
            final notifier = AuthNotifier(FakeAuthRepository());
            notifier.setUser(AuthFixtures.adminUser);
            return notifier;
          }),
        ],
      );
      addTearDown(adminContainer.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: adminContainer,
          child: MaterialApp.router(
            routerConfig: appRouter,
          ),
        ),
      );
      await tester.pump(const Duration(seconds: 2));
      await tester.pump(const Duration(milliseconds: 600));

      await navigateAndPump(tester, '/admin-dashboard');
      expect(getCurrentLocation(), equals('/admin-web-only'),
          reason:
              'Stale Riverpod admin user on mobile must be redirected to web-only access notice');
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
  0x89,
  0x50,
  0x4E,
  0x47,
  0x0D,
  0x0A,
  0x1A,
  0x0A,
  0x00,
  0x00,
  0x00,
  0x0D,
  0x49,
  0x48,
  0x44,
  0x52,
  0x00,
  0x00,
  0x00,
  0x01,
  0x00,
  0x00,
  0x00,
  0x01,
  0x08,
  0x06,
  0x00,
  0x00,
  0x00,
  0x1F,
  0x15,
  0xC4,
  0x89,
  0x00,
  0x00,
  0x00,
  0x0A,
  0x49,
  0x44,
  0x41,
  0x54,
  0x78,
  0x9C,
  0x63,
  0x00,
  0x01,
  0x00,
  0x00,
  0x05,
  0x00,
  0x01,
  0x0D,
  0x0A,
  0x2D,
  0xB4,
  0x00,
  0x00,
  0x00,
  0x00,
  0x49,
  0x45,
  0x4E,
  0x44,
  0xAE,
  0x42,
  0x60,
  0x82
];
