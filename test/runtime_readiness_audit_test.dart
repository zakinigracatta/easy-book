import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Android release keeps production networking and real-signing guard', () {
    final manifest =
        File('android/app/src/main/AndroidManifest.xml').readAsStringSync();
    final gradle =
        File('android/app/build.gradle.kts').readAsStringSync();

    expect(manifest, contains('android.permission.INTERNET'));
    expect(manifest, contains('android:label="Easy Book"'));
    expect(gradle, contains('rootProject.file("key.properties")'));
    expect(
      gradle.indexOf('plugins {'),
      lessThan(gradle.indexOf('val keystoreProperties = Properties()')),
    );
    expect(gradle, contains('releaseTaskRequested'));
    expect(gradle, contains('Release signing is not configured.'));
    expect(
      gradle,
      isNot(contains('signingConfig = signingConfigs.getByName("debug")')),
    );
  });

  test('Firebase Android runtime identifiers stay aligned', () {
    final firebaseJson =
        jsonDecode(File('firebase.json').readAsStringSync())
            as Map<String, dynamic>;
    final firebaseOptions =
        File('lib/firebase_options.dart').readAsStringSync();
    final googleServices =
        jsonDecode(File('android/app/google-services.json').readAsStringSync())
            as Map<String, dynamic>;

    const expectedPackage = 'ae.easybook.app';
    const expectedAppId =
        '1:669700001010:android:a47c10c1fe440d6a47946b';

    final flutter = firebaseJson['flutter'] as Map<String, dynamic>;
    final platforms = flutter['platforms'] as Map<String, dynamic>;
    final android = platforms['android'] as Map<String, dynamic>;
    final androidDefault = android['default'] as Map<String, dynamic>;

    expect(androidDefault['appId'], expectedAppId);
    expect(firebaseOptions, contains("appId: '$expectedAppId'"));

    final clients = googleServices['client'] as List<dynamic>;
    final matchingClient = clients
        .cast<Map<String, dynamic>>()
        .where((client) {
          final info = client['client_info'] as Map<String, dynamic>;
          final androidInfo =
              info['android_client_info'] as Map<String, dynamic>;
          return androidInfo['package_name'] == expectedPackage &&
              info['mobilesdk_app_id'] == expectedAppId;
        })
        .toList();

    expect(matchingClient, hasLength(1));
  });

  test('Firebase Hosting preserves Flutter SPA routes on refresh', () {
    final firebaseJson =
        jsonDecode(File('firebase.json').readAsStringSync())
            as Map<String, dynamic>;
    final hosting = firebaseJson['hosting'] as Map<String, dynamic>;

    expect(hosting['public'], 'build/web');
    final rewrites = hosting['rewrites'] as List<dynamic>;
    expect(
      rewrites.any((entry) {
        final rewrite = entry as Map<String, dynamic>;
        return rewrite['source'] == '**' &&
            rewrite['destination'] == '/index.html';
      }),
      isTrue,
    );
  });
  test('authenticated startup does not silently downgrade unresolved roles', () {
    final auth =
        File('lib/services/auth_service.dart').readAsStringSync();
    final splash =
        File('lib/screens/auth/splash_screen.dart').readAsStringSync();

    expect(auth, contains("code: 'user-profile-missing'"));
    expect(
      auth,
      isNot(contains('final recoveredCustomer = UserModel(')),
    );
    expect(auth, contains('Future<UserModel?> refreshCurrentProfile() async'));
    expect(splash, contains('.refreshCurrentProfile()'));
    expect(splash, contains('.timeout(const Duration(seconds: 8))'));
    expect(splash, contains('needsProfileRecovery = true;'));
    expect(
      splash,
      contains("context.tr('Unable to restore your account profile.')"),
    );
    expect(splash, contains("context.tr('Retry')"));
    expect(splash, contains("context.tr('Sign out')"));
    expect(auth, isNot(contains('Profile email:')));
    expect(auth, isNot(contains('Creating Firestore profile for uid=')));
    expect(auth, isNot(contains('owner uid=')));
    expect(
      splash,
      isNot(contains('destination resolved: guest/customer fallback')),
    );
  });

  test('pending auth navigation survives a process or browser restart', () {
    final navigation =
        File('lib/services/navigation_service.dart').readAsStringSync();

    expect(navigation, contains('pending_navigation_route'));
    expect(navigation, contains('Hive.isBoxOpen(AppConstants.hiveSettingsBox)'));
    expect(navigation, contains('_storedPendingRoute()'));
    expect(navigation, contains('_persistPendingRoute(normalized)'));
    expect(navigation, contains('_persistPendingRoute(null)'));
  });

  test('local storage failures do not block app startup or auth navigation', () {
    final mainSource = File('lib/main.dart').readAsStringSync();
    final storage =
        File('lib/services/local_storage_service.dart').readAsStringSync();
    final navigation =
        File('lib/services/navigation_service.dart').readAsStringSync();

    expect(mainSource, contains('try {'));
    expect(mainSource, contains('await LocalStorageService.initHive();'));
    expect(mainSource, contains('await Firebase.initializeApp('));
    expect(storage, contains('Hive.isBoxOpen'));
    expect(storage, contains('return const <String>[];'));
    expect(navigation, contains('Future<void> _writePendingRoute'));
    expect(navigation, contains('unawaited(_writePendingRoute(route))'));
    expect(navigation, contains('In-memory navigation remains functional'));
  });

}
