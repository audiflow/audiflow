class NotFoundError implements Exception {
  NotFoundError() : message = 'Not found';

  final String message;
}

enum NetworkErrorType {
  connectivity,
  timeout,
  unknown,
}

class NetworkError implements Exception {
  NetworkError(this.type);

  final NetworkErrorType type;
}

class NoConnectivityError extends NetworkError {
  NoConnectivityError() : super(NetworkErrorType.connectivity);

  @override
  String toString() => 'NoConnectivityError';
}

class NetworkTimeoutError extends NetworkError {
  NetworkTimeoutError() : super(NetworkErrorType.timeout);

  @override
  String toString() => 'NetworkTimeoutError';
}

class NetworkUnknownError extends NetworkError {
  NetworkUnknownError() : super(NetworkErrorType.unknown);

  @override
  String toString() => 'NetworkUnknownError';
}
