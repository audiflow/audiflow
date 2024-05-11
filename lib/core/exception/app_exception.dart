sealed class AppException implements Exception {
  const AppException(this.message);

  final String message;
}

class UnknownException extends AppException {
  const UnknownException() : super('Unknown error occurred');
}

class NotFoundException extends AppException {
  NotFoundException() : super('Not found');
}

sealed class NetworkException extends AppException {
  NetworkException(super.message);
}

class NoConnectivityException extends NetworkException {
  NoConnectivityException() : super('No connectivity');
}

class NetworkTimeoutException extends NetworkException {
  NetworkTimeoutException() : super('Network timeout error occurred');
}

sealed class HttpException extends NetworkException {
  HttpException(super.message);

  factory HttpException.fromStatusCode(int? statusCode) {
    if (statusCode == null) {
      return UnknownNetworkException();
    }

    return switch (statusCode) {
      >= 400 && < 500 => ClientNetworkException(
          'Client error occurred($statusCode)',
        ),
      >= 500 && < 600 => ServerNetworkException(
          'Server error occurred($statusCode)',
        ),
      _ => throw ArgumentError(
          'Invalid status code: $statusCode.',
          'statusCode',
        ),
    };
  }
}

class ClientNetworkException extends HttpException {
  ClientNetworkException(super.message);
}

class ServerNetworkException extends HttpException {
  ServerNetworkException(super.message);
}

class UnknownNetworkException extends HttpException {
  UnknownNetworkException() : super('Unknown network error occurred');
}
