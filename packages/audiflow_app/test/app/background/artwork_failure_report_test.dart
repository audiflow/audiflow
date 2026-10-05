import 'dart:async';
import 'dart:io';

import 'package:audiflow_app/app/background/artwork_failure_report.dart';
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:checks/checks.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

const _url = 'https://user:secret@cdn.example.com/art/cover.jpg?token=abc#x';

DioException _dio(DioExceptionType type, {Object? error, int? status}) {
  final options = RequestOptions(path: _url);
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
  group('sanitizeArtworkUrl', () {
    test('keeps scheme, host and path only', () {
      check(
        sanitizeArtworkUrl(_url),
      ).equals('https://cdn.example.com/art/cover.jpg');
    });

    test('hides unparseable or host-less values', () {
      check(sanitizeArtworkUrl('::not a url')).equals('<invalid>');
      check(sanitizeArtworkUrl('/relative/path.jpg')).equals('<invalid>');
    });
  });

  group('artworkFailureReport', () {
    final noise = <String, Object>{
      'our timeout': TimeoutException('artwork'),
      'connection timeout': _dio(DioExceptionType.connectionTimeout),
      'receive timeout': _dio(DioExceptionType.receiveTimeout),
      'send timeout': _dio(DioExceptionType.sendTimeout),
      'cancellation': _dio(DioExceptionType.cancel),
      'connection error': _dio(DioExceptionType.connectionError),
      'socket error': const SocketException('offline'),
      'wrapped socket error': _dio(
        DioExceptionType.unknown,
        error: const SocketException('offline'),
      ),
    };
    for (final MapEntry(key: name, value: error) in noise.entries) {
      test('skips $name', () {
        check(artworkFailureReport(_url, error)).isNull();
      });
    }

    test('records an unsupported format by type', () {
      final report = artworkFailureReport(
        _url,
        const UnsupportedArtworkFormatException(),
      );

      check(report).isNotNull()
        ..has(
          (r) => r.url,
          'url',
        ).equals('https://cdn.example.com/art/cover.jpg')
        ..has(
          (r) => r.category,
          'category',
        ).equals('UnsupportedArtworkFormatException');
    });

    test('records a bad HTTP status with its code', () {
      final report = artworkFailureReport(
        _url,
        _dio(DioExceptionType.badResponse, status: 404),
      );

      check(report)
          .isNotNull()
          .has((r) => r.category, 'category')
          .equals('DioException.badResponse.404');
    });

    test('records decode or size failures without their message', () {
      final report = artworkFailureReport(
        _url,
        StateError('Artwork exceeds 5 bytes: $_url'),
      );

      check(
        report,
      ).isNotNull().has((r) => r.category, 'category').equals('StateError');
    });
  });
}
