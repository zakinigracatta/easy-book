import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/test.dart';
import 'package:easy_book/routes/app_router.dart';
import 'package:easy_book/theme/app_theme.dart';

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    HttpOverrides.global = TestHttpOverrides();
    setupFirebaseCoreMocks();
    await Firebase.initializeApp();
  });

  Widget createWidgetUnderTest() {
    return ProviderScope(
      child: MaterialApp.router(
        theme: AppTheme.darkTheme,
        routerConfig: appRouter,
      ),
    );
  }

  Future<void> openRegisterScreen(WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
    appRouter.go('/register');
    await tester.pumpAndSettle();
  }

  group('Scenario 9: Registration Length Validation Tests', () {
    testWidgets('1. Full Name exactly 60 chars is accepted by UI length limits',
        (tester) async {
      await openRegisterScreen(tester);

      final name60 = 'A' * 60;
      final nameField = find.byWidgetPredicate((widget) =>
          widget is TextField && widget.decoration?.labelText == 'Full Name');

      await tester.enterText(nameField, name60);
      await tester.pump();

      expect((tester.widget(nameField) as TextField).controller?.text,
          equals(name60));
    });

    testWidgets(
        '2. Full Name 61 chars is truncated/rejected by client maxLength',
        (tester) async {
      await openRegisterScreen(tester);

      final name61 = 'A' * 61;
      final nameField = find.byWidgetPredicate((widget) =>
          widget is TextField && widget.decoration?.labelText == 'Full Name');

      await tester.enterText(nameField, name61);
      await tester.pump();

      final text = (tester.widget(nameField) as TextField).controller?.text;
      expect(text?.length, lessThanOrEqualTo(60));
    });

    testWidgets(
        '3. Phone Number exactly 25 chars is accepted by UI length limits',
        (tester) async {
      await openRegisterScreen(tester);

      final phone25 = '1' * 25;
      final phoneField = find.byWidgetPredicate((widget) =>
          widget is TextField &&
          widget.decoration?.labelText == 'Phone Number');

      await tester.enterText(phoneField, phone25);
      await tester.pump();

      expect((tester.widget(phoneField) as TextField).controller?.text,
          equals(phone25));
    });

    testWidgets(
        '4. Phone Number 26 chars is truncated/rejected by client maxLength',
        (tester) async {
      await openRegisterScreen(tester);

      final phone26 = '1' * 26;
      final phoneField = find.byWidgetPredicate((widget) =>
          widget is TextField &&
          widget.decoration?.labelText == 'Phone Number');

      await tester.enterText(phoneField, phone26);
      await tester.pump();

      final text = (tester.widget(phoneField) as TextField).controller?.text;
      expect(text?.length, lessThanOrEqualTo(25));
    });

    testWidgets(
        '5. Email Address exactly 100 chars is accepted by UI length limits',
        (tester) async {
      await openRegisterScreen(tester);

      final email100 = '${'a' * 88}@example.com';
      final emailField = find.byWidgetPredicate((widget) =>
          widget is TextField &&
          widget.decoration?.labelText == 'Email Address');

      await tester.enterText(emailField, email100);
      await tester.pump();

      expect((tester.widget(emailField) as TextField).controller?.text,
          equals(email100));
    });

    testWidgets(
        '6. Email Address 101 chars is truncated/rejected by client maxLength',
        (tester) async {
      await openRegisterScreen(tester);

      final email101 = '${'a' * 89}@example.com';
      final emailField = find.byWidgetPredicate((widget) =>
          widget is TextField &&
          widget.decoration?.labelText == 'Email Address');

      await tester.enterText(emailField, email101);
      await tester.pump();

      final text = (tester.widget(emailField) as TextField).controller?.text;
      expect(text?.length, lessThanOrEqualTo(100));
    });

    testWidgets('7. Password exactly 128 chars is accepted by UI length limits',
        (tester) async {
      await openRegisterScreen(tester);

      final pass128 = 'P' * 128;
      final passField = find.byWidgetPredicate((widget) =>
          widget is TextField && widget.decoration?.labelText == 'Password');

      await tester.enterText(passField, pass128);
      await tester.pump();

      expect((tester.widget(passField) as TextField).controller?.text,
          equals(pass128));
    });

    testWidgets(
        '8. Password 129 chars is truncated/rejected by client maxLength',
        (tester) async {
      await openRegisterScreen(tester);

      final pass129 = 'P' * 129;
      final passField = find.byWidgetPredicate((widget) =>
          widget is TextField && widget.decoration?.labelText == 'Password');

      await tester.enterText(passField, pass129);
      await tester.pump();

      final text = (tester.widget(passField) as TextField).controller?.text;
      expect(text?.length, lessThanOrEqualTo(128));
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
