import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:easy_book/main.dart';
import 'package:easy_book/providers/auth_provider.dart';
import 'package:easy_book/providers/app_providers.dart';
import 'package:easy_book/services/auth_service.dart';

void main() {
  testWidgets('App load test', (WidgetTester tester) async {
    final container = ProviderContainer(
      overrides: [
        authServiceProvider.overrideWithValue(
          AuthService(
            firebaseAuth: MockFirebaseAuth(),
            firestore: FakeFirebaseFirestore(),
          ),
        ),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const EasyBookApp(),
      ),
    );
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();

    expect(find.byType(EasyBookApp), findsOneWidget);
    final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(app.themeMode, ThemeMode.light);
    expect(app.theme?.brightness, Brightness.light);

    container.read(themeModeProvider.notifier).state = ThemeMode.dark;
    await tester.pump();
    expect(
      tester.widget<MaterialApp>(find.byType(MaterialApp)).themeMode,
      ThemeMode.dark,
    );

    container.read(themeModeProvider.notifier).state = ThemeMode.light;
    await tester.pump();
    expect(
      tester.widget<MaterialApp>(find.byType(MaterialApp)).themeMode,
      ThemeMode.light,
    );
  });
}
