import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth_platform_interface/firebase_auth_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

/// Test platform implementation for mocking FirebaseAuth.instance in widget/unit tests.
class MockFirebaseAuthPlatform extends FirebaseAuthPlatform with MockPlatformInterfaceMixin {
  MockFirebaseAuthPlatform();

  UserPlatform? mockUser;

  void setMockUser(String uid, String email, {bool isEmailVerified = true}) {
    mockUser = TestUserPlatform(this, uid, email, isEmailVerified: isEmailVerified);
  }

  void clearUser() {
    mockUser = null;
  }

  @override
  FirebaseAuthPlatform delegateFor({required dynamic app}) => this;

  @override
  FirebaseAuthPlatform setInitialValues({
    PigeonUserDetails? currentUser,
    String? languageCode,
  }) => this;

  @override
  UserPlatform? get currentUser => mockUser;

  @override
  Stream<UserPlatform?> authStateChanges() => Stream.value(mockUser);

  @override
  Stream<UserPlatform?> userChanges() => Stream.value(mockUser);

  @override
  Stream<UserPlatform?> idTokenChanges() => Stream.value(mockUser);
}

class TestUserPlatform extends UserPlatform {
  TestUserPlatform(FirebaseAuthPlatform auth, String uid, String email, {bool isEmailVerified = true})
      : super(
          auth,
          FakeMultiFactorPlatform(),
          PigeonUserDetails(
            userInfo: PigeonUserInfo(
              uid: uid,
              email: email,
              isAnonymous: false,
              isEmailVerified: isEmailVerified,
            ),
            providerData: [],
          ),
        );
}

class FakeMultiFactorPlatform extends Fake implements MultiFactorPlatform {}
