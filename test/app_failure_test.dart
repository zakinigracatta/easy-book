import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:easy_book/core/errors/app_failure.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppFailure', () {
    test('preserves an existing normalized failure', () {
      const failure = AppFailure(
        type: AppFailureType.validation,
        message: 'Safe message',
      );

      expect(AppFailure.from(failure), same(failure));
    });

    test('maps connection and timeout failures to retryable messages', () {
      final network = AppFailure.from(
        const SocketException('sensitive host details'),
      );
      final timeout = AppFailure.from(TimeoutException('internal operation'));

      expect(network.type, AppFailureType.network);
      expect(network.canRetry, isTrue);
      expect(network.message, isNot(contains('sensitive')));
      expect(timeout.type, AppFailureType.timeout);
      expect(timeout.canRetry, isTrue);
    });

    test('maps HTTP status codes without exposing response contents', () {
      final request = RequestOptions(path: '/private');
      final error = DioException(
        requestOptions: request,
        response: Response<Object?>(
          requestOptions: request,
          statusCode: 403,
          data: {'secret': 'server detail'},
        ),
      );

      final failure = AppFailure.fromDio(error);

      expect(failure.type, AppFailureType.forbidden);
      expect(failure.code, '403');
      expect(failure.message, isNot(contains('secret')));
      expect(failure.canRetry, isFalse);
    });

    test('marks server errors as retryable', () {
      final request = RequestOptions(path: '/resource');
      final failure = AppFailure.fromDio(
        DioException(
          requestOptions: request,
          response: Response<void>(
            requestOptions: request,
            statusCode: 503,
          ),
        ),
      );

      expect(failure.type, AppFailureType.server);
      expect(failure.canRetry, isTrue);
    });
  });
}
