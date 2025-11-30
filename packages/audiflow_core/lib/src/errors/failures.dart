/// Base class for failures
abstract class Failure {
  const Failure(this.message, [this.code]);

  final String message;
  final String? code;

  @override
  String toString() => code != null ? '[$code] $message' : message;
}

/// Failure for network-related errors
class NetworkFailure extends Failure {
  const NetworkFailure([String message = 'Network failure'])
    : super(message, 'NETWORK_FAILURE');
}

/// Failure for server errors
class ServerFailure extends Failure {
  const ServerFailure([String message = 'Server failure', int? statusCode])
    : super(message, 'SERVER_FAILURE_$statusCode');
}

/// Failure for cache errors
class CacheFailure extends Failure {
  const CacheFailure([String message = 'Cache failure'])
    : super(message, 'CACHE_FAILURE');
}

/// Failure for validation errors
class ValidationFailure extends Failure {
  const ValidationFailure([String message = 'Validation failure'])
    : super(message, 'VALIDATION_FAILURE');
}
