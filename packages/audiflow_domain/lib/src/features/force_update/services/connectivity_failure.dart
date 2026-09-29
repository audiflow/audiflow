import 'package:dio/dio.dart';

/// Whether [error] means the device could not reach the config host
/// (offline, DNS failure, stalled network) rather than a problem with the
/// hosted config itself.
///
/// The repository already fails open on these, so callers use this to keep
/// expected offline launches out of error monitoring.
bool isConnectivityFailure(Object? error) {
  if (error is! DioException) return false;
  return switch (error.type) {
    DioExceptionType.connectionError ||
    DioExceptionType.connectionTimeout ||
    DioExceptionType.sendTimeout ||
    DioExceptionType.receiveTimeout => true,
    _ => false,
  };
}
