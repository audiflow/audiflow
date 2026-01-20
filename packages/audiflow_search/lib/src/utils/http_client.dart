import 'package:dio/dio.dart';

import '../exceptions/search_exception.dart';

/// HTTP client wrapper providing error handling and conditional request support.
///
/// This client wraps the Dio HTTP library to provide consistent error handling,
/// timeout configuration, and support for HTTP conditional requests (If-Modified-Since
/// and If-None-Match headers) for efficient caching.
///
/// Example:
/// ```dart
/// final client = HttpClient();
/// final response = await client.get(
///   'https://itunes.apple.com/search',
///   ifModifiedSince: 'Wed, 21 Oct 2015 07:28:00 GMT',
/// );
/// ```
class HttpClient {
  /// Creates an HTTP client with optional configuration.
  ///
  /// [timeout] configures both connect and receive timeouts (default: 10 seconds).
  /// [dio] optionally provides a pre-configured Dio instance for testing.
  /// [providerId] identifies the provider for error tracking (default: 'http').
  HttpClient({
    Duration timeout = const Duration(seconds: 10),
    Dio? dio,
    String providerId = 'http',
  }) : _providerId = providerId,
       _dio =
           dio ??
           Dio(
             BaseOptions(
               connectTimeout: timeout,
               receiveTimeout: timeout,
               responseType: ResponseType.json,
               // Accept all status codes, we'll handle them manually
               validateStatus: (_) => true,
             ),
           ) {
    // Ensure the provided Dio instance also validates all status codes
    if (dio != null) {
      _dio.options.validateStatus = (_) => true;
    }
  }

  /// The underlying Dio HTTP client instance.
  final Dio _dio;

  /// Provider ID used for error context in exceptions.
  final String _providerId;

  /// Performs a GET request with optional conditional request headers.
  ///
  /// [url] is the target URL for the request.
  /// [headers] optionally provides custom HTTP headers.
  /// [ifModifiedSince] adds an If-Modified-Since header for conditional requests.
  /// [ifNoneMatch] adds an If-None-Match header for conditional requests.
  ///
  /// Returns the HTTP response on success.
  ///
  /// Throws:
  /// - [ContentNotModifiedException] on 304 Not Modified responses.
  /// - [RateLimitException] on 429 Too Many Requests.
  /// - [ServiceUnavailableException] on 503 Service Unavailable.
  /// - [SearchApiException] on other 4xx/5xx status codes.
  /// - [SearchNetworkException] on network failures and timeouts.
  Future<Response<dynamic>> get(
    String url, {
    Map<String, String>? headers,
    String? ifModifiedSince,
    String? ifNoneMatch,
  }) async {
    try {
      final requestHeaders = <String, String>{
        ...?headers,
        'If-Modified-Since': ?ifModifiedSince,
        'If-None-Match': ?ifNoneMatch,
      };

      final response = await _dio.get<dynamic>(
        url,
        options: Options(headers: requestHeaders),
      );

      // Handle status codes
      final statusCode = response.statusCode;
      if (statusCode == null) {
        throw SearchNetworkException(
          providerId: _providerId,
          message: 'No status code received from server',
        );
      }

      if (statusCode == 304) {
        throw ContentNotModifiedException(
          providerId: _providerId,
          lastModified: response.headers.value('Last-Modified'),
          etag: response.headers.value('ETag'),
        );
      }

      if (statusCode == 429) {
        final retryAfterHeader = response.headers.value('Retry-After');
        final retryAfter = retryAfterHeader != null
            ? int.tryParse(retryAfterHeader)
            : null;

        throw RateLimitException(
          providerId: _providerId,
          retryAfter: retryAfter,
        );
      }

      if (statusCode == 503) {
        throw ServiceUnavailableException(
          providerId: _providerId,
        );
      }

      if (statusCode < 300 && 200 <= statusCode) {
        // Success (2xx)
        return response;
      }

      // Other error status codes (4xx, 5xx)
      throw SearchApiException(
        providerId: _providerId,
        message: 'HTTP error: $statusCode',
        statusCode: statusCode,
        responseBody: response.data?.toString(),
      );
    } on DioException catch (e) {
      // Re-throw if it's already one of our custom exceptions
      if (e.error is SearchException) {
        throw e.error! as SearchException;
      }

      // Map Dio error types to network exceptions
      final isTimeout =
          e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout;

      final defaultMessage = isTimeout
          ? 'Request timeout'
          : 'Network connection failed';

      throw SearchNetworkException(
        providerId: _providerId,
        message: e.message ?? defaultMessage,
        isTimeout: isTimeout,
      );
    } on SearchException {
      // Re-throw our custom exceptions
      rethrow;
    } catch (e) {
      // Catch-all for unexpected errors
      throw SearchNetworkException(
        providerId: _providerId,
        message: 'Unexpected error: $e',
      );
    }
  }

  /// Closes the client and cleans up resources.
  void close() {
    _dio.close();
  }
}
