import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:checks/checks.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

DioException _dioError(DioExceptionType type) => DioException(
  requestOptions: RequestOptions(path: '/config.json'),
  type: type,
);

void main() {
  group('isConnectivityFailure', () {
    for (final type in [
      DioExceptionType.connectionError,
      DioExceptionType.connectionTimeout,
      DioExceptionType.sendTimeout,
      DioExceptionType.receiveTimeout,
    ]) {
      test('treats ${type.name} as a connectivity failure', () {
        check(isConnectivityFailure(_dioError(type))).isTrue();
      });
    }

    for (final type in [
      DioExceptionType.badResponse,
      DioExceptionType.badCertificate,
      DioExceptionType.cancel,
      DioExceptionType.unknown,
    ]) {
      test('does not treat ${type.name} as a connectivity failure', () {
        check(isConnectivityFailure(_dioError(type))).isFalse();
      });
    }

    test('does not treat non-Dio errors as connectivity failures', () {
      check(isConnectivityFailure(const FormatException('bad'))).isFalse();
      check(isConnectivityFailure(null)).isFalse();
    });
  });
}
