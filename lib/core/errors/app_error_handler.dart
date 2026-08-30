import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'app_failure.dart';

typedef ErrorReporter = void Function(Object error, StackTrace stackTrace);

class AppErrorHandler {
  AppErrorHandler._();

  static ErrorReporter reporter = _defaultReporter;

  static void initialize() {
    FlutterError.onError = (details) {
      FlutterError.presentError(details);
      report(details.exception, details.stack ?? StackTrace.current);
    };

    PlatformDispatcher.instance.onError = (error, stackTrace) {
      report(error, stackTrace);
      return true;
    };

    ErrorWidget.builder = (details) => const _FriendlyErrorWidget();
  }

  static void report(Object error, StackTrace stackTrace) {
    reporter(error, stackTrace);
  }

  static void _defaultReporter(Object error, StackTrace stackTrace) {
    if (kDebugMode) {
      debugPrint('Unhandled application error: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
  }
}

class StartupErrorApp extends StatelessWidget {
  const StartupErrorApp({super.key, required this.failure});

  final AppFailure failure;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline_rounded, size: 56),
                  const SizedBox(height: 16),
                  const Text(
                    'Easy Book could not start',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(failure.message, textAlign: TextAlign.center),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FriendlyErrorWidget extends StatelessWidget {
  const _FriendlyErrorWidget();

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(
      color: Colors.transparent,
      child: Center(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            'This content could not be displayed.',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
