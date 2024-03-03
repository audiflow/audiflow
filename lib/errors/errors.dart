class NotFoundError extends Error {
  NotFoundError() : message = 'Not found';

  final String message;
}

enum NetworkErrorType {
  connectivity,
  timeout,
  unknown,
}

class NetworkError {
  const NetworkError.connectivity() : type = NetworkErrorType.connectivity;

  const NetworkError.timeout() : type = NetworkErrorType.timeout;

  const NetworkError.unknown() : type = NetworkErrorType.unknown;

  final NetworkErrorType type;
}
