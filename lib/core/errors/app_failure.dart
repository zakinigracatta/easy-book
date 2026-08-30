import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:firebase_core/firebase_core.dart';

enum AppFailureType {
  network,
  timeout,
  unauthorized,
  forbidden,
  notFound,
  validation,
  server,
  cancelled,
  unknown,
}

/// A normalized failure that is safe to display to users.
class AppFailure implements Exception {
  const AppFailure({
    required this.type,
    required this.message,
    this.code,
    this.cause,
  });

  final AppFailureType type;
  final String message;
  final String? code;
  final Object? cause;

  bool get canRetry => switch (type) {
        AppFailureType.network ||
        AppFailureType.timeout ||
        AppFailureType.server =>
          true,
        _ => false,
      };

  factory AppFailure.from(
    Object error, {
    String fallbackMessage = 'Something went wrong. Please try again.',
  }) {
    if (error is AppFailure) return error;
    if (error is DioException) return AppFailure.fromDio(error);

    if (error is TimeoutException) {
      return AppFailure(
        type: AppFailureType.timeout,
        code: 'timeout',
        message: 'The request took too long. Please try again.',
        cause: error,
      );
    }

    if (error is SocketException) {
      return AppFailure(
        type: AppFailureType.network,
        code: 'network-unavailable',
        message: 'Unable to connect. Check your internet connection.',
        cause: error,
      );
    }

    if (error is FirebaseException) {
      return AppFailure(
        type: _firebaseType(error.code),
        code: error.code,
        message: _firebaseMessage(error.code),
        cause: error,
      );
    }

    if (error is FormatException) {
      return AppFailure(
        type: AppFailureType.validation,
        code: 'invalid-data',
        message: 'Some of the received data is invalid.',
        cause: error,
      );
    }

    return AppFailure(
      type: AppFailureType.unknown,
      code: 'unknown',
      message: fallbackMessage,
      cause: error,
    );
  }

  factory AppFailure.fromDio(DioException error) {
    if (error.error is AppFailure) return error.error! as AppFailure;

    final type = switch (error.type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.sendTimeout ||
      DioExceptionType.receiveTimeout =>
        AppFailureType.timeout,
      DioExceptionType.connectionError => AppFailureType.network,
      DioExceptionType.cancel => AppFailureType.cancelled,
      _ => _statusType(error.response?.statusCode),
    };

    return AppFailure(
      type: type,
      code: error.response?.statusCode?.toString() ?? error.type.name,
      message: _messageFor(type),
      cause: error,
    );
  }

  static AppFailureType _statusType(int? statusCode) {
    if (statusCode == null) return AppFailureType.unknown;

    return switch (statusCode) {
      400 || 422 => AppFailureType.validation,
      401 => AppFailureType.unauthorized,
      403 => AppFailureType.forbidden,
      404 => AppFailureType.notFound,
      >= 500 => AppFailureType.server,
      _ => AppFailureType.unknown,
    };
  }

  static AppFailureType _firebaseType(String code) {
    return switch (code) {
      'permission-denied' => AppFailureType.forbidden,
      'unavailable' || 'network-request-failed' => AppFailureType.network,
      'deadline-exceeded' => AppFailureType.timeout,
      'not-found' => AppFailureType.notFound,
      _ => AppFailureType.unknown,
    };
  }

  static String _firebaseMessage(String code) {
    return switch (code) {
      'permission-denied' => 'You do not have permission for this operation.',
      'unavailable' ||
      'network-request-failed' =>
        'Unable to connect. Check your internet connection.',
      'deadline-exceeded' => 'The request took too long. Please try again.',
      'not-found' => 'The requested information could not be found.',
      _ => 'The service is temporarily unavailable. Please try again.',
    };
  }

  static String _messageFor(AppFailureType type) {
    return switch (type) {
      AppFailureType.network =>
        'Unable to connect. Check your internet connection.',
      AppFailureType.timeout => 'The request took too long. Please try again.',
      AppFailureType.unauthorized =>
        'Your session has expired. Please sign in.',
      AppFailureType.forbidden =>
        'You do not have permission for this operation.',
      AppFailureType.notFound =>
        'The requested information could not be found.',
      AppFailureType.validation => 'Please check the submitted information.',
      AppFailureType.server =>
        'The service is temporarily unavailable. Please try again.',
      AppFailureType.cancelled => 'The request was cancelled.',
      AppFailureType.unknown => 'Something went wrong. Please try again.',
    };
  }

  @override
  String toString() => message;
}
