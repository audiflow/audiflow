import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';

/// Telemetry-safe description of a notification artwork failure.
///
/// Holds no error message or full URL: both can carry feed-supplied
/// credentials or tokens (CWE-532).
class ArtworkFailureReport {
  const ArtworkFailureReport({required this.url, required this.category});

  /// Scheme, host and path of the artwork URL.
  final String url;

  /// Error type, refined with the Dio failure type and HTTP status.
  final String category;
}

/// Report for a failure worth recording, or null for network noise
/// (timeouts, cancellations, connectivity) that is expected on poor
/// connections and not actionable.
ArtworkFailureReport? artworkFailureReport(String artworkUrl, Object error) {
  if (_isNetworkNoise(error)) return null;
  return ArtworkFailureReport(
    url: sanitizeArtworkUrl(artworkUrl),
    category: _category(error),
  );
}

/// [url] reduced to scheme, host and path; `<invalid>` when it has no host.
String sanitizeArtworkUrl(String url) {
  final uri = Uri.tryParse(url);
  if (uri == null || uri.host.isEmpty) return '<invalid>';
  return Uri(scheme: uri.scheme, host: uri.host, path: uri.path).toString();
}

const _noiseDioTypes = {
  DioExceptionType.connectionTimeout,
  DioExceptionType.sendTimeout,
  DioExceptionType.receiveTimeout,
  DioExceptionType.cancel,
  DioExceptionType.connectionError,
};

bool _isNetworkNoise(Object error) => switch (error) {
  TimeoutException() || SocketException() || HttpException() => true,
  DioException(:final type, error: final cause) =>
    _noiseDioTypes.contains(type) || (cause != null && _isNetworkNoise(cause)),
  _ => false,
};

String _category(Object error) => switch (error) {
  DioException(:final type, :final response) => [
    'DioException',
    type.name,
    if (response?.statusCode case final status?) '$status',
  ].join('.'),
  _ => error.runtimeType.toString(),
};
