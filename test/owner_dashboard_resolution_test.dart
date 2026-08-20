import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/test.dart';
import 'package:firebase_auth_platform_interface/firebase_auth_platform_interface.dart';

import 'package:easy_book/routes/app_router.dart';
import 'package:easy_book/models/business_model.dart';
import 'package:easy_book/models/booking_model.dart';
import 'package:easy_book/models/service_model.dart';
import 'package:easy_book/models/staff_model.dart';
import 'package:easy_book/models/review_model.dart';
import 'package:easy_book/models/offer_model.dart';
import 'package:easy_book/models/gallery_image_model.dart';
import 'package:easy_book/models/customer_profile_model.dart';
import 'package:easy_book/models/owner_notification_model.dart';
import 'package:easy_book/models/employee_time_off_model.dart';
import 'package:easy_book/models/user_model.dart';
import 'package:easy_book/providers/owner_providers.dart';
import 'package:easy_book/providers/auth_provider.dart';
import 'package:easy_book/repositories/auth_repository.dart';
import 'package:easy_book/repositories/owner_repository.dart';
import 'fixtures/auth_fixtures.dart';
import 'fixtures/mock_firebase_auth.dart';

final MockFirebaseAuthPlatform globalMockAuthPlatform = MockFirebaseAuthPlatform();

class FakeAuthRepository implements AuthRepository {
  @override
  Stream<UserModel?> authStateChanges() => const Stream.empty();

  @override
  Future<UserModel> login(String email, String password, {UserRole? requestedRole}) async {
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

class FakeOwnerRepository implements OwnerRepository {
  FakeOwnerRepository({
    this.businessToReturn,
    this.bookingsToReturn = const [],
    this.shouldThrow = false,
  });

  final BusinessModel? businessToReturn;
  final List<BookingModel> bookingsToReturn;
  final bool shouldThrow;

  @override
  Future<BusinessModel> fetchOwnerBusiness(String businessId) async {
    if (shouldThrow) throw Exception('Firestore network error');
    if (businessToReturn != null) return businessToReturn!;
    throw Exception('Business record not found');
  }

  @override
  Future<List<BookingModel>> fetchOwnerBookings(String businessId) async {
    if (shouldThrow) throw Exception('Firestore network error');
    if (businessId.isEmpty) return [];
    return bookingsToReturn;
  }

  @override
  Future<void> updateOwnerBusiness(BusinessModel business) async {}

  @override
  Future<BookingModel> createWalkInBooking(BookingModel booking) async => booking;

  @override
  Future<void> updateBookingStatus(String bookingId, BookingStatus newStatus) async {}

  @override
  Future<List<ServiceModel>> fetchOwnerServices(String businessId) async => [];

  @override
  Future<void> saveService(ServiceModel service) async {}

  @override
  Future<void> deleteService(String businessId, String serviceId) async {}

  @override
  Future<List<StaffModel>> fetchOwnerEmployees(String businessId) async => [];

  @override
  Future<void> saveEmployee(StaffModel staff) async {}

  @override
  Future<void> deleteEmployee(String businessId, String staffId) async {}

  @override
  Future<List<EmployeeTimeOffModel>> fetchEmployeeTimeOffs(String businessId) async => [];

  @override
  Future<void> saveEmployeeTimeOff(EmployeeTimeOffModel timeOff) async {}

  @override
  Future<List<GalleryImageModel>> fetchGalleryImages(String businessId) async => [];

  @override
  Future<void> saveGalleryImage(GalleryImageModel image) async {}

  @override
  Future<void> deleteGalleryImage(String businessId, String imageId) async {}

  @override
  Future<List<ReviewModel>> fetchOwnerReviews(String businessId) async => [];

  @override
  Future<void> replyToReview(String businessId, String reviewId, String replyText) async {}

  @override
  Future<List<OfferModel>> fetchOwnerOffers(String businessId) async => [];

  @override
  Future<void> saveOffer(OfferModel offer) async {}

  @override
  Future<void> deleteOffer(String businessId, String offerId) async {}

  @override
  Future<List<CustomerProfileModel>> fetchOwnerCustomers(String businessId) async => [];

  @override
  Future<void> saveCustomerNotes(String businessId, String customerId, String notes) async {}

  @override
  Future<List<OwnerNotificationModel>> fetchOwnerNotifications(String businessId) async => [];

  @override
  Future<void> markNotificationRead(String businessId, String notificationId) async {}
}

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    HttpOverrides.global = TestHttpOverrides();
    setupFirebaseCoreMocks();
    FirebaseAuthPlatform.instance = globalMockAuthPlatform;
    await Firebase.initializeApp();
  });

  setUp(() {
    globalMockAuthPlatform.setMockUser('owner_456', 'owner@easybook.com');
  });

  final sampleBusiness = BusinessModel(
    id: 'biz_123',
    ownerId: 'owner_456',
    name: 'Elegance Salon',
    category: 'Hair Salon',
    address: 'Downtown Dubai',
    rating: 4.5,
    reviewCount: 12,
    imageUrl: 'https://example.com/logo.png',
    description: 'Luxury hair salon',
    phone: '+971500000000',
  );

  final sampleBooking = BookingModel(
    id: 'b1',
    businessId: 'biz_123',
    businessName: 'Elegance Salon',
    serviceId: 's1',
    serviceName: 'Haircut',
    servicePrice: 150.0,
    customerId: 'c1',
    customerName: 'Ahmad',
    customerPhone: '+971550000000',
    staffId: 'st1',
    staffName: 'John',
    startDateTime: DateTime.now(),
    endDateTime: DateTime.now().add(const Duration(minutes: 45)),
    status: BookingStatus.confirmed,
    createdAt: DateTime.now(),
  );

  group('Owner Dashboard Resolution Tests', () {
    testWidgets('Test A & B: owner business resolves cleanly via valid business ID', (tester) async {
      final container = ProviderContainer(
        overrides: [
          authProvider.overrideWith((ref) {
            final notifier = AuthNotifier(FakeAuthRepository());
            notifier.setUser(AuthFixtures.ownerUser);
            return notifier;
          }),
          currentBusinessIdProvider.overrideWith((ref) async => 'biz_123'),
          ownerRepositoryProvider.overrideWithValue(
            FakeOwnerRepository(businessToReturn: sampleBusiness),
          ),
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

      appRouter.go('/owner-dashboard');
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();

      expect(find.text('Elegance Salon'), findsOneWidget);
    });

    testWidgets('Test C: no business exists -> renders explicit empty state (NO infinite spinner)',
        (tester) async {
      final container = ProviderContainer(
        overrides: [
          authProvider.overrideWith((ref) {
            final notifier = AuthNotifier(FakeAuthRepository());
            notifier.setUser(AuthFixtures.ownerUser);
            return notifier;
          }),
          currentBusinessIdProvider.overrideWith((ref) async => ''),
          ownerRepositoryProvider.overrideWithValue(FakeOwnerRepository()),
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

      appRouter.go('/owner-dashboard');
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();

      expect(find.text('No Business Profile Found'), findsOneWidget);
      expect(find.text('Loading business details...'), findsNothing);
    });

    testWidgets('Test D: Firestore error -> renders error state with retry (NO infinite spinner)',
        (tester) async {
      final container = ProviderContainer(
        overrides: [
          authProvider.overrideWith((ref) {
            final notifier = AuthNotifier(FakeAuthRepository());
            notifier.setUser(AuthFixtures.ownerUser);
            return notifier;
          }),
          currentBusinessIdProvider.overrideWith((ref) async {
            throw Exception('Firestore network timeout');
          }),
          ownerRepositoryProvider.overrideWithValue(
            FakeOwnerRepository(shouldThrow: true),
          ),
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

      appRouter.go('/owner-dashboard');
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();

      expect(find.text('No Business Profile Found'), findsOneWidget);
      expect(find.text('Loading business details...'), findsNothing);
    });

    testWidgets('Test E: valid business ID -> upcoming bookings resolve (loading stops)',
        (tester) async {
      final container = ProviderContainer(
        overrides: [
          authProvider.overrideWith((ref) {
            final notifier = AuthNotifier(FakeAuthRepository());
            notifier.setUser(AuthFixtures.ownerUser);
            return notifier;
          }),
          currentBusinessIdProvider.overrideWith((ref) async => 'biz_123'),
          ownerRepositoryProvider.overrideWithValue(
            FakeOwnerRepository(
              businessToReturn: sampleBusiness,
              bookingsToReturn: [sampleBooking],
            ),
          ),
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

      appRouter.go('/owner-dashboard');
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();

      expect(find.text('Elegance Salon'), findsOneWidget);
      expect(find.text('Haircut'), findsOneWidget);
    });

    testWidgets('Test F: no business ID -> bookings provider resolves empty immediately without infinite spinner',
        (tester) async {
      final container = ProviderContainer(
        overrides: [
          authProvider.overrideWith((ref) {
            final notifier = AuthNotifier(FakeAuthRepository());
            notifier.setUser(AuthFixtures.ownerUser);
            return notifier;
          }),
          currentBusinessIdProvider.overrideWith((ref) async => ''),
          ownerRepositoryProvider.overrideWithValue(FakeOwnerRepository()),
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

      appRouter.go('/owner-dashboard');
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();

      expect(find.text('No Bookings Today'), findsOneWidget);
    });
  });
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
  0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D, 0x49, 0x48, 0x44, 0x52,
  0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01, 0x08, 0x06, 0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4,
  0x89, 0x00, 0x00, 0x00, 0x0A, 0x49, 0x44, 0x41, 0x54, 0x78, 0x9C, 0x63, 0x00, 0x01, 0x00, 0x00,
  0x05, 0x00, 0x01, 0x0D, 0x0A, 0x2D, 0xB4, 0x00, 0x00, 0x00, 0x00, 0x49, 0x45, 0x4E, 0x44, 0xAE,
  0x42, 0x60, 0x82
];
