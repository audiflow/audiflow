import 'dart:io';

import 'package:audiflow_app/app/errors/user_facing_error.dart';
import 'package:audiflow_app/l10n/app_localizations.dart';
import 'package:audiflow_core/audiflow_core.dart';
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:audiflow_search/audiflow_search.dart';
import 'package:checks/checks.dart';
import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

/// Stands in for IsarError: an [Error] (not an [Exception]) whose
/// toString carries internal storage detail.
class _FakeStorageError extends Error {
  @override
  String toString() => 'IsarError: Unique index violated.';
}

DioException _dio(DioExceptionType type, {Object? error}) => DioException(
  requestOptions: RequestOptions(path: 'https://example.com/feed.xml'),
  type: type,
  error: error,
);

void main() {
  group('classifyUserFacingError', () {
    final networkErrors = <String, Object>{
      'DioException connectionError': _dio(DioExceptionType.connectionError),
      'DioException connectionTimeout': _dio(
        DioExceptionType.connectionTimeout,
      ),
      'DioException receiveTimeout': _dio(DioExceptionType.receiveTimeout),
      'DioException sendTimeout': _dio(DioExceptionType.sendTimeout),
      'DioException wrapping SocketException': _dio(
        DioExceptionType.unknown,
        error: const SocketException('Failed host lookup'),
      ),
      'SocketException': const SocketException('Network is unreachable'),
      'NetworkException': NetworkException(),
      'SearchNetworkException': SearchNetworkException(
        providerId: 'itunes',
        message: 'offline',
      ),
      'DownloadException networkUnavailable': DownloadException(
        DownloadErrorType.networkUnavailable,
      ),
      'PodcastException.network without status': PodcastException.network(
        'Network error: connection refused',
      ),
    };

    for (final MapEntry(:key, :value) in networkErrors.entries) {
      test('$key is a network failure', () {
        check(
          classifyUserFacingError(value),
        ).equals(UserFacingErrorKind.network);
      });
    }

    final genericErrors = <String, Object>{
      'storage Error': _FakeStorageError(),
      'DioException badResponse': _dio(DioExceptionType.badResponse),
      'DioException cancel': _dio(DioExceptionType.cancel),
      'PodcastException.network with HTTP status': PodcastException.network(
        'Not found',
        statusCode: 404,
      ),
      'PodcastException parse failure': PodcastException.parsing('bad xml'),
      'DownloadException insufficientStorage': DownloadException(
        DownloadErrorType.insufficientStorage,
      ),
      'FormatException': const FormatException('bad'),
      'StateError': StateError('boom'),
      'plain string': 'boom',
    };

    for (final MapEntry(:key, :value) in genericErrors.entries) {
      test('$key is a generic failure', () {
        check(
          classifyUserFacingError(value),
        ).equals(UserFacingErrorKind.generic);
      });
    }
  });

  group('userFacingErrorMessage', () {
    final ja = lookupAppLocalizations(const Locale('ja'));
    final en = lookupAppLocalizations(const Locale('en'));

    test('maps a network failure to the connection message', () {
      final error = _dio(DioExceptionType.connectionTimeout);

      check(userFacingErrorMessage(ja, error)).equals(ja.errorNetwork);
      check(userFacingErrorMessage(en, error)).equals(en.errorNetwork);
    });

    test('maps anything else to the generic message', () {
      check(
        userFacingErrorMessage(ja, _FakeStorageError()),
      ).equals(ja.errorGeneric);
      check(userFacingErrorMessage(en, Exception('x'))).equals(en.errorGeneric);
    });

    test('never exposes the raw error text', () {
      final errors = <Object>[
        _FakeStorageError(),
        Exception('Unique index violated'),
        PodcastException(message: 'Network error: secret detail'),
        _dio(DioExceptionType.connectionError, error: 'socket detail'),
      ];

      for (final l10n in [ja, en]) {
        for (final error in errors) {
          final message = userFacingErrorMessage(l10n, error);
          check(message).not((it) => it.contains(error.toString()));
          check(message).not((it) => it.contains('Isar'));
          check(message).not((it) => it.contains('detail'));
        }
      }
    });

    test('the two messages differ', () {
      check(ja.errorNetwork).not((it) => it.equals(ja.errorGeneric));
      check(en.errorNetwork).not((it) => it.equals(en.errorGeneric));
    });
  });
}
