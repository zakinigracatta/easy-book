import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:easy_book/models/user_model.dart';
import 'package:easy_book/services/auth_failure.dart';
import 'package:easy_book/services/auth_service.dart';

void main() {
  group('AuthService registration', () {
    test('creates a customer account and Firestore profile', () async {
      final auth = MockFirebaseAuth(verifyEmailAutomatically: false);
      final firestore = FakeFirebaseFirestore();
      final service = AuthService(firebaseAuth: auth, firestore: firestore);

      final profile = await service.registerCustomer(
        name: 'Alex Vance',
        phone: '+971500000000',
        email: '  ALEX@Example.COM ',
        password: 'secure123',
      );

      expect(profile.role, UserRole.customer);
      expect(profile.email, 'alex@example.com');
      expect(auth.currentUser?.uid, profile.id);

      final snapshot =
          await firestore.collection('users').doc(profile.id).get();
      expect(snapshot.exists, isTrue);
      expect(snapshot.data()?['full_name'], 'Alex Vance');
      expect(snapshot.data()?['role'], 'customer');
      expect(snapshot.data()?['created_at'], isNotNull);
    });

    test('creates an owner profile with business data', () async {
      final auth = MockFirebaseAuth();
      final firestore = FakeFirebaseFirestore();
      final service = AuthService(firebaseAuth: auth, firestore: firestore);

      final profile = await service.registerBusinessOwner(
        businessName: 'Easy Salon',
        category: 'Hair Salon',
        phone: '+971500000001',
        email: 'owner@example.com',
        password: 'secure123',
        location: 'Dubai',
      );

      final data =
          (await firestore.collection('users').doc(profile.id).get()).data();
      expect(profile.role, UserRole.owner);
      expect(data?['role'], 'owner');
      expect(data?['business_name'], 'Easy Salon');
      expect(data?['location'], 'Dubai');
    });

    test('auth state resolves the profile created during sign-up', () async {
      final auth = MockFirebaseAuth();
      final firestore = FakeFirebaseFirestore();
      final service = AuthService(firebaseAuth: auth, firestore: firestore);
      final signedInProfile =
          service.authStateChanges().where((user) => user != null).first;

      final registered = await service.registerCustomer(
        name: 'Maya',
        phone: '+971500000002',
        email: 'maya@example.com',
        password: 'secure123',
      );

      expect((await signedInProfile)?.id, registered.id);
    });
  });

  group('AuthService sign-in and session restoration', () {
    test('loads the stored profile after sign-in', () async {
      const uid = 'customer-1';
      final mockUser = MockUser(
        uid: uid,
        email: 'customer@example.com',
        isEmailVerified: true,
      );
      final auth = MockFirebaseAuth(mockUser: mockUser);
      final firestore = FakeFirebaseFirestore();
      await firestore.collection('users').doc(uid).set({
        'id': uid,
        'email': 'customer@example.com',
        'full_name': 'Customer One',
        'phone': '+971500000003',
        'role': 'customer',
      });
      final service = AuthService(firebaseAuth: auth, firestore: firestore);

      final profile = await service.login(
        ' CUSTOMER@example.com ',
        'secure123',
        requestedRole: UserRole.customer,
      );

      expect(profile.id, uid);
      expect(profile.fullName, 'Customer One');
      expect(auth.currentUser, isNotNull);
    });

    test('rejects the wrong portal role and signs out', () async {
      const uid = 'customer-2';
      final auth = MockFirebaseAuth(
        mockUser: MockUser(uid: uid, email: 'customer2@example.com'),
      );
      final firestore = FakeFirebaseFirestore();
      await firestore.collection('users').doc(uid).set({
        'id': uid,
        'email': 'customer2@example.com',
        'full_name': 'Customer Two',
        'phone': '',
        'role': 'customer',
      });
      final service = AuthService(firebaseAuth: auth, firestore: firestore);

      await expectLater(
        service.login(
          'customer2@example.com',
          'secure123',
          requestedRole: UserRole.owner,
        ),
        throwsA(
          isA<AuthFailure>().having(
            (failure) => failure.code,
            'code',
            'role-mismatch',
          ),
        ),
      );
      expect(auth.currentUser, isNull);
    });

    test('restores a signed-in user and signs out a missing profile', () async {
      const uid = 'restored-user';
      final firestore = FakeFirebaseFirestore();
      await firestore.collection('users').doc(uid).set({
        'id': uid,
        'email': 'restored@example.com',
        'full_name': 'Restored User',
        'phone': '',
        'role': 'customer',
      });
      final auth = MockFirebaseAuth(
        signedIn: true,
        mockUser: MockUser(uid: uid, email: 'restored@example.com'),
      );
      final service = AuthService(firebaseAuth: auth, firestore: firestore);

      expect((await service.restoreSession())?.id, uid);

      final missingAuth = MockFirebaseAuth(
        signedIn: true,
        mockUser: MockUser(uid: 'missing', email: 'missing@example.com'),
      );
      final missingService = AuthService(
        firebaseAuth: missingAuth,
        firestore: FakeFirebaseFirestore(),
      );
      await expectLater(
        missingService.restoreSession(),
        throwsA(
          isA<AuthFailure>().having(
            (failure) => failure.code,
            'code',
            'profile-not-found',
          ),
        ),
      );
      expect(missingAuth.currentUser, isNull);
    });
  });

  group('AuthService verification and recovery', () {
    test('reports the current verification status', () async {
      final unverifiedService = AuthService(
        firebaseAuth: MockFirebaseAuth(
          signedIn: true,
          mockUser: MockUser(
            email: 'pending@example.com',
            isEmailVerified: false,
          ),
        ),
        firestore: FakeFirebaseFirestore(),
      );
      expect(await unverifiedService.isCurrentEmailVerified(), isFalse);
      await expectLater(
        unverifiedService.sendEmailVerification(),
        completes,
      );

      final verifiedService = AuthService(
        firebaseAuth: MockFirebaseAuth(
          signedIn: true,
          mockUser: MockUser(
            email: 'verified@example.com',
            isEmailVerified: true,
          ),
        ),
        firestore: FakeFirebaseFirestore(),
      );
      expect(await verifiedService.isCurrentEmailVerified(), isTrue);
    });

    test('normalizes password reset email', () async {
      final auth = _RecordingFirebaseAuth();
      final service = AuthService(
        firebaseAuth: auth,
        firestore: FakeFirebaseFirestore(),
      );

      await service.sendPasswordResetEmail('  USER@Example.COM  ');

      expect(auth.lastResetEmail, 'user@example.com');
    });

    test('maps Firebase authentication errors to safe messages', () async {
      final service = AuthService(
        firebaseAuth: _FailingLoginFirebaseAuth(),
        firestore: FakeFirebaseFirestore(),
      );

      await expectLater(
        service.login('user@example.com', 'wrong-password'),
        throwsA(
          isA<AuthFailure>()
              .having((failure) => failure.code, 'code', 'invalid-credential')
              .having(
                (failure) => failure.message,
                'message',
                'The email or password is incorrect.',
              ),
        ),
      );
    });
  });
}

class _RecordingFirebaseAuth extends MockFirebaseAuth {
  String? lastResetEmail;

  @override
  Future<void> sendPasswordResetEmail({
    required String email,
    ActionCodeSettings? actionCodeSettings,
  }) async {
    lastResetEmail = email;
  }
}

class _FailingLoginFirebaseAuth extends MockFirebaseAuth {
  @override
  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) {
    throw FirebaseAuthException(code: 'invalid-credential');
  }
}
