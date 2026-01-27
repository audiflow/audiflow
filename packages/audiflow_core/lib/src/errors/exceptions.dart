/// Base exception for application errors
class AppException implements Exception {
  AppException(this.message, [this.code]);

  final String message;
  final String? code;

  @override
  String toString() => code != null ? '[$code] $message' : message;
}

/// Exception for network-related errors
class NetworkException extends AppException {
  NetworkException([String message = 'Network error occurred'])
    : super(message, 'NETWORK_ERROR');
}

/// Exception for server errors
class ServerException extends AppException {
  ServerException([String message = 'Server error occurred', int? statusCode])
    : super(message, 'SERVER_ERROR_$statusCode');
}

/// Exception for cache errors
class CacheException extends AppException {
  CacheException([String message = 'Cache error occurred'])
    : super(message, 'CACHE_ERROR');
}

/// Exception for validation errors
class ValidationException extends AppException {
  ValidationException([String message = 'Validation error occurred'])
    : super(message, 'VALIDATION_ERROR');
}

/// Error types for download operations
enum DownloadErrorType {
  networkUnavailable,
  serverError,
  insufficientStorage,
  fileWriteError,
  cancelled,
  unknown,
}

/// Exception for download-related errors
class DownloadException extends AppException {
  DownloadException(this.type, [String message = 'Download error occurred'])
    : super(message, 'DOWNLOAD_ERROR_${type.name.toUpperCase()}');

  final DownloadErrorType type;
}
