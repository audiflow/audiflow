import 'status_code.dart';

/// Base exception class for all search-related errors.
///
/// This exception uses gRPC canonical status codes to categorize errors
/// in a standardized way. All contextual information is preserved in the
/// details map for debugging and error tracking.
class SearchException implements Exception {
  /// Creates a new search exception with the given parameters.
  ///
  /// [code] is the gRPC canonical status code.
  /// [message] describes the error.
  /// [providerId] identifies which provider encountered the error.
  /// [details] optionally includes error-specific information for debugging.
  /// [timestamp] defaults to the current time when the exception is created.
  SearchException({
    required this.code,
    required this.message,
    required this.providerId,
    this.details,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  // Factory constructors for common error scenarios

  /// Creates an INVALID_ARGUMENT exception for validation errors.
  ///
  /// Used when client provides invalid parameters (empty search term,
  /// invalid limit, malformed country code, etc.).
  factory SearchException.invalidArgument({
    required String providerId,
    required String message,
    Map<String, dynamic>? details,
    DateTime? timestamp,
  }) {
    return SearchException(
      code: StatusCode.invalidArgument,
      message: message,
      providerId: providerId,
      details: details,
      timestamp: timestamp,
    );
  }

  /// Creates a NOT_FOUND exception for missing resources.
  ///
  /// Used when a requested podcast or resource cannot be found.
  factory SearchException.notFound({
    required String providerId,
    required String message,
    Map<String, dynamic>? details,
    DateTime? timestamp,
  }) {
    return SearchException(
      code: StatusCode.notFound,
      message: message,
      providerId: providerId,
      details: details,
      timestamp: timestamp,
    );
  }

  /// Creates a RESOURCE_EXHAUSTED exception for rate limiting.
  ///
  /// Used when API rate limits are exceeded (HTTP 429).
  factory SearchException.resourceExhausted({
    required String providerId,
    required String message,
    int? retryAfterSeconds,
    int? statusCode,
    String? responseBody,
    DateTime? timestamp,
  }) {
    return SearchException(
      code: StatusCode.resourceExhausted,
      message: message,
      providerId: providerId,
      details: {
        'statusCode': ?statusCode,
        'retryAfterSeconds': ?retryAfterSeconds,
        'responseBody': ?responseBody,
      },
      timestamp: timestamp,
    );
  }

  /// Creates an UNAVAILABLE exception for service unavailability.
  ///
  /// Used for HTTP 503 errors and network connectivity issues.
  factory SearchException.unavailable({
    required String providerId,
    required String message,
    Map<String, dynamic>? details,
    DateTime? timestamp,
  }) {
    return SearchException(
      code: StatusCode.unavailable,
      message: message,
      providerId: providerId,
      details: details,
      timestamp: timestamp,
    );
  }

  /// Creates a DEADLINE_EXCEEDED exception for timeouts.
  ///
  /// Used when operations exceed their configured timeout duration.
  factory SearchException.deadlineExceeded({
    required String providerId,
    required String message,
    Duration? timeout,
    DateTime? timestamp,
  }) {
    return SearchException(
      code: StatusCode.deadlineExceeded,
      message: message,
      providerId: providerId,
      details: {
        if (timeout != null) 'timeoutSeconds': timeout.inSeconds,
      },
      timestamp: timestamp,
    );
  }

  /// Creates a FAILED_PRECONDITION exception for precondition failures.
  ///
  /// Used for HTTP 304 (Not Modified) and similar cases where the
  /// operation cannot proceed due to current system state.
  factory SearchException.failedPrecondition({
    required String providerId,
    required String message,
    Map<String, dynamic>? details,
    DateTime? timestamp,
  }) {
    return SearchException(
      code: StatusCode.failedPrecondition,
      message: message,
      providerId: providerId,
      details: details,
      timestamp: timestamp,
    );
  }

  /// Creates an INTERNAL exception for internal errors.
  ///
  /// Used for HTTP 500/502 errors and parsing failures.
  factory SearchException.internal({
    required String providerId,
    required String message,
    Map<String, dynamic>? details,
    DateTime? timestamp,
  }) {
    return SearchException(
      code: StatusCode.internal,
      message: message,
      providerId: providerId,
      details: details,
      timestamp: timestamp,
    );
  }

  /// Creates a PERMISSION_DENIED exception for authorization failures.
  ///
  /// Used for HTTP 403 errors.
  factory SearchException.permissionDenied({
    required String providerId,
    required String message,
    Map<String, dynamic>? details,
    DateTime? timestamp,
  }) {
    return SearchException(
      code: StatusCode.permissionDenied,
      message: message,
      providerId: providerId,
      details: details,
      timestamp: timestamp,
    );
  }

  /// Creates an UNAUTHENTICATED exception for authentication failures.
  ///
  /// Used for HTTP 401 errors.
  factory SearchException.unauthenticated({
    required String providerId,
    required String message,
    Map<String, dynamic>? details,
    DateTime? timestamp,
  }) {
    return SearchException(
      code: StatusCode.unauthenticated,
      message: message,
      providerId: providerId,
      details: details,
      timestamp: timestamp,
    );
  }

  /// Creates a DATA_LOSS exception for unrecoverable data corruption.
  ///
  /// Used for critical parsing failures or corrupted responses.
  factory SearchException.dataLoss({
    required String providerId,
    required String message,
    Map<String, dynamic>? details,
    DateTime? timestamp,
  }) {
    return SearchException(
      code: StatusCode.dataLoss,
      message: message,
      providerId: providerId,
      details: details,
      timestamp: timestamp,
    );
  }

  /// Creates an UNKNOWN exception for uncategorized errors.
  ///
  /// Used as a fallback when the error doesn't fit other categories.
  factory SearchException.unknown({
    required String providerId,
    required String message,
    Map<String, dynamic>? details,
    DateTime? timestamp,
  }) {
    return SearchException(
      code: StatusCode.unknown,
      message: message,
      providerId: providerId,
      details: details,
      timestamp: timestamp,
    );
  }

  /// The gRPC canonical status code categorizing this error.
  final StatusCode code;

  /// Human-readable error message describing what went wrong.
  final String message;

  /// Identifier of the provider that generated this error.
  final String providerId;

  /// Optional map containing error-specific details for debugging.
  ///
  /// This may include field names, values, HTTP status codes,
  /// retry information, and other context-specific data.
  final Map<String, dynamic>? details;

  /// Timestamp when the error occurred.
  final DateTime timestamp;

  /// Whether this error indicates a retryable condition.
  ///
  /// Returns true for transient errors that may succeed on retry:
  /// - UNAVAILABLE (service temporarily down)
  /// - DEADLINE_EXCEEDED (timeout)
  /// - RESOURCE_EXHAUSTED (rate limiting with backoff)
  /// - INTERNAL (may be transient)
  bool get isRetryable {
    return code == StatusCode.unavailable ||
        code == StatusCode.deadlineExceeded ||
        code == StatusCode.resourceExhausted ||
        code == StatusCode.internal;
  }

  /// Whether this error is a client error (4xx equivalent).
  ///
  /// Returns true for errors caused by invalid client input.
  bool get isClientError {
    return code == StatusCode.invalidArgument ||
        code == StatusCode.notFound ||
        code == StatusCode.permissionDenied ||
        code == StatusCode.unauthenticated ||
        code == StatusCode.failedPrecondition ||
        code == StatusCode.alreadyExists;
  }

  /// Whether this error is a server error (5xx equivalent).
  ///
  /// Returns true for errors caused by server-side issues.
  bool get isServerError {
    return code == StatusCode.internal ||
        code == StatusCode.unavailable ||
        code == StatusCode.dataLoss ||
        code == StatusCode.unimplemented;
  }

  @override
  String toString() {
    final buffer = StringBuffer('SearchException: $message');
    buffer.write(' [Code: ${code.name}(${code.value})]');
    buffer.write(' [Provider: $providerId]');
    buffer.write(' [Timestamp: $timestamp]');

    if (details != null && details!.isNotEmpty) {
      buffer.write(' [Details: $details]');
    }

    return buffer.toString();
  }
}

// Type aliases for specific exception types

/// Exception thrown when content has not been modified (HTTP 304).
///
/// This exception is thrown when a conditional request (using If-Modified-Since
/// or If-None-Match headers) indicates that the content has not changed.
/// Clients should use their cached version of the data.
class ContentNotModifiedException extends SearchException {
  ContentNotModifiedException({
    required super.providerId,
    String? lastModified,
    String? etag,
    super.timestamp,
  }) : super(
         code: StatusCode.failedPrecondition,
         message: 'Content has not been modified',
         details: {
           'lastModified': ?lastModified,
           'etag': ?etag,
         },
       );

  /// The Last-Modified value from the request headers.
  String? get lastModified => details?['lastModified'] as String?;

  /// The ETag value from the request headers.
  String? get etag => details?['etag'] as String?;
}

/// Exception thrown for network-related errors.
///
/// This includes connection failures, timeouts, and other transport-level issues.
class SearchNetworkException extends SearchException {
  SearchNetworkException({
    required super.providerId,
    required super.message,
    bool isTimeout = false,
    super.details,
    super.timestamp,
  }) : super(
         code: isTimeout ? StatusCode.deadlineExceeded : StatusCode.unavailable,
       );

  /// Whether this error was caused by a timeout.
  bool get isTimeout => code == StatusCode.deadlineExceeded;
}

/// Exception thrown when API rate limits are exceeded (HTTP 429).
///
/// The retryAfter property indicates how many seconds to wait before retrying.
class RateLimitException extends SearchException {
  RateLimitException({
    required super.providerId,
    int? retryAfter,
    super.timestamp,
  }) : super(
         code: StatusCode.resourceExhausted,
         message: 'API rate limit exceeded',
         details: {
           'retryAfterSeconds': ?retryAfter,
         },
       );

  /// Number of seconds to wait before retrying (from Retry-After header).
  int? get retryAfter => details?['retryAfterSeconds'] as int?;
}

/// Exception thrown when the service is unavailable (HTTP 503).
class ServiceUnavailableException extends SearchException {
  ServiceUnavailableException({
    required super.providerId,
    String? message,
    super.timestamp,
  }) : super(
         code: StatusCode.unavailable,
         message: message ?? 'Service temporarily unavailable',
       );
}

/// Exception thrown for other API errors (HTTP 4xx/5xx).
///
/// This is a catch-all for HTTP errors that don't have more specific exception types.
class SearchApiException extends SearchException {
  SearchApiException({
    required super.providerId,
    required super.message,
    int? statusCode,
    String? responseBody,
    super.timestamp,
  }) : super(
         code: _determineCode(statusCode),
         details: {
           'statusCode': ?statusCode,
           'responseBody': ?responseBody,
         },
       );

  /// HTTP status code from the API response.
  int? get statusCode => details?['statusCode'] as int?;

  /// Response body from the failed request.
  String? get responseBody => details?['responseBody'] as String?;

  static StatusCode _determineCode(int? statusCode) {
    if (statusCode == null) return StatusCode.unknown;

    if (statusCode < 500 && 400 <= statusCode) {
      // Client errors
      switch (statusCode) {
        case 400:
          return StatusCode.invalidArgument;
        case 401:
          return StatusCode.unauthenticated;
        case 403:
          return StatusCode.permissionDenied;
        case 404:
          return StatusCode.notFound;
        default:
          return StatusCode.failedPrecondition;
      }
    } else if (statusCode < 600 && 500 <= statusCode) {
      // Server errors
      return StatusCode.internal;
    }

    return StatusCode.unknown;
  }
}
