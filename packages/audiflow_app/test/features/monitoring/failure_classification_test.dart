import 'dart:async';
import 'dart:io';

import 'package:audiflow_app/features/monitoring/services/failure_classification.dart';
import 'package:audiflow_core/audiflow_core.dart';
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:checks/checks.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

DioException _dio(DioExceptionType type, {Object? error, int? status}) {
  final options = RequestOptions(path: 'https://feeds.example.com/rss');
  return DioException(
    requestOptions: options,
    type: type,
    error: error,
    response: status == null
        ? null
        : Response<void>(requestOptions: options, statusCode: status),
  );
}

void main() {
  group('isExpectedFailure', () {
    final expected = <String, Object>{
      'timeout': TimeoutException('slow'),
      'socket error': const SocketException('offline'),
      'http transport error': const HttpException('connection closed'),
      'network exception': NetworkException(),
      'dio connection error': _dio(DioExceptionType.connectionError),
      'dio connection timeout': _dio(DioExceptionType.connectionTimeout),
      'dio send timeout': _dio(DioExceptionType.sendTimeout),
      'dio receive timeout': _dio(DioExceptionType.receiveTimeout),
      'dio cancellation': _dio(DioExceptionType.cancel),
      'dio wrapping a socket error': _dio(
        DioExceptionType.unknown,
        error: const SocketException('offline'),
      ),
      'cancelled download': DownloadException.cancelled(),
      'download without network': DownloadException(
        DownloadErrorType.networkUnavailable,
      ),
      'podcast transport failure': PodcastException.network('offline'),
    };
    for (final MapEntry(key: name, value: error) in expected.entries) {
      test('treats $name as expected', () {
        check(isExpectedFailure(error)).isTrue();
      });
    }

    final unexpected = <String, Object>{
      'state error': StateError('Unique index violated.'),
      'format exception': const FormatException('bad'),
      'dio bad response': _dio(DioExceptionType.badResponse, status: 500),
      'dio unknown failure': _dio(DioExceptionType.unknown),
      'failed download write': DownloadException(
        DownloadErrorType.fileWriteError,
      ),
      'podcast server error': PodcastException.network('gone', statusCode: 404),
      'podcast parse failure': PodcastException.parsing('bad xml'),
    };
    for (final MapEntry(key: name, value: error) in unexpected.entries) {
      test('reports $name', () {
        check(isExpectedFailure(error)).isFalse();
      });
    }
  });

  group('errorCategory', () {
    test('refines Dio failures with type and status', () {
      check(
        errorCategory(_dio(DioExceptionType.badResponse, status: 503)),
      ).equals('DioException.badResponse.503');
    });

    test('uses the runtime type for other errors', () {
      check(errorCategory(StateError('x'))).equals('StateError');
    });
  });
}
