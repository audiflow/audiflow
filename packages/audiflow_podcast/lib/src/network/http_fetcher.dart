import 'dart:io';
import 'dart:async';

/// Contains HTTP caching information extracted from response headers.
class CacheInfo {
  /// The ETag header value for cache validation.
  final String? etag;

  /// The Last-Modified header value for cache validation.
  final DateTime? lastModified;

  /// The max-age directive from Cache-Control header.
  final Duration? maxAge;

  /// Whether the no-cache directive is present.
  final bool noCache;

  /// Whether the no-store directive is present.
  final bool noStore;

  const CacheInfo({
    this.etag,
    this.lastModified,
    this.maxAge,
    this.noCache = false,
    this.noStore = false,
  });

  /// Whether this cache info indicates the content should not be cached.
  bool get shouldNotCache => noStore;

  /// Whether this cache info requires revalidation before use.
  bool get requiresRevalidation => noCache;

  /// Whether this cache info has validation headers (ETag or Last-Modified).
  bool get hasValidationHeaders => etag != null || lastModified != null;

  @override
  String toString() {
    return 'CacheInfo(etag: $etag, lastModified: $lastModified, '
        'maxAge: $maxAge, noCache: $noCache, noStore: $noStore)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CacheInfo &&
        other.etag == etag &&
        other.lastModified == lastModified &&
        other.maxAge == maxAge &&
        other.noCache == noCache &&
        other.noStore == noStore;
  }

  @override
  int get hashCode {
    return Object.hash(etag, lastModified, maxAge, noCache, noStore);
  }
}

/// Manages HTTP requests with streaming support and error handling.
class HttpFetcher {
  static const String _defaultUserAgent = 'PodcastRssParser/1.0.0 (Dart)';

  final HttpClient _client;
  final String _userAgent;
  final Duration _timeout;

  /// Creates an HttpFetcher with optional configuration.
  HttpFetcher({String? userAgent, Duration? timeout, HttpClient? client})
      : _userAgent = userAgent ?? _defaultUserAgent,
        _timeout = timeout ?? const Duration(seconds: 30),
        _client = client ?? HttpClient();

  /// Fetches content from the given URL as a stream of bytes.
  ///
  /// Returns a stream that emits chunks of data as they are received.
  /// Throws [HttpException] for HTTP errors or [SocketException] for network errors.
  Stream<List<int>> fetchStream(String url) async* {
    HttpClientRequest? request;
    HttpClientResponse? response;

    try {
      final uri = Uri.parse(url);
      request = await _client.getUrl(uri).timeout(_timeout);

      // Set headers
      request.headers.set(HttpHeaders.userAgentHeader, _userAgent);
      request.headers.set(
        HttpHeaders.acceptHeader,
        'application/rss+xml, application/xml, text/xml, */*',
      );

      response = await request.close().timeout(_timeout);

      if (response.statusCode == 200) {
        yield* response;
      } else {
        throw HttpException(
          'HTTP ${response.statusCode}: ${response.reasonPhrase}',
          uri: uri,
        );
      }
    } on TimeoutException {
      throw HttpException('Request timeout after ${_timeout.inSeconds}s');
    } on SocketException catch (e) {
      throw HttpException('Network error: ${e.message}');
    } catch (e) {
      if (e is HttpException) rethrow;
      throw HttpException('Unexpected error: $e');
    }
  }

  /// Fetches the HTTP response with headers for caching support.
  ///
  /// Returns the full [HttpClientResponse] to access headers like ETag and Last-Modified.
  /// Supports conditional requests with If-None-Match and If-Modified-Since headers.
  /// Returns 304 Not Modified responses without throwing - caller should check status code.
  /// Throws [HttpException] for HTTP errors or [SocketException] for network errors.
  Future<HttpClientResponse> fetchWithHeaders(
    String url, {
    String? ifNoneMatch,
    DateTime? ifModifiedSince,
  }) async {
    HttpClientRequest? request;

    try {
      final uri = Uri.parse(url);
      request = await _client.getUrl(uri).timeout(_timeout);

      // Set standard headers
      request.headers.set(HttpHeaders.userAgentHeader, _userAgent);
      request.headers.set(
        HttpHeaders.acceptHeader,
        'application/rss+xml, application/xml, text/xml, */*',
      );

      // Set conditional headers for caching
      if (ifNoneMatch != null) {
        request.headers.set(HttpHeaders.ifNoneMatchHeader, ifNoneMatch);
      }
      if (ifModifiedSince != null) {
        request.headers.set(
          HttpHeaders.ifModifiedSinceHeader,
          HttpDate.format(ifModifiedSince),
        );
      }

      final response = await request.close().timeout(_timeout);

      // Don't throw for 304 Not Modified - caller should handle it
      if (response.statusCode == 200 || response.statusCode == 304) {
        return response;
      } else {
        throw HttpException(
          'HTTP ${response.statusCode}: ${response.reasonPhrase}',
          uri: uri,
        );
      }
    } on TimeoutException {
      throw HttpException('Request timeout after ${_timeout.inSeconds}s');
    } on SocketException catch (e) {
      throw HttpException('Network error: ${e.message}');
    } catch (e) {
      if (e is HttpException) rethrow;
      throw HttpException('Unexpected error: $e');
    }
  }

  /// Extracts caching information from HTTP response headers.
  ///
  /// Returns a [CacheInfo] object containing ETag, Last-Modified, and Cache-Control information.
  /// This information can be used for subsequent conditional requests.
  CacheInfo extractCacheInfo(HttpClientResponse response) {
    final etag = response.headers.value(HttpHeaders.etagHeader);
    final lastModifiedStr = response.headers.value(
      HttpHeaders.lastModifiedHeader,
    );
    final cacheControlStr = response.headers.value(
      HttpHeaders.cacheControlHeader,
    );

    DateTime? lastModified;
    if (lastModifiedStr != null) {
      try {
        lastModified = HttpDate.parse(lastModifiedStr);
      } catch (e) {
        // Ignore invalid date format
      }
    }

    Duration? maxAge;
    bool noCache = false;
    bool noStore = false;

    if (cacheControlStr != null) {
      final directives =
          cacheControlStr.split(',').map((s) => s.trim().toLowerCase());

      for (final directive in directives) {
        if (directive == 'no-cache') {
          noCache = true;
        } else if (directive == 'no-store') {
          noStore = true;
        } else if (directive.startsWith('max-age=')) {
          final maxAgeStr = directive.substring('max-age='.length);
          final maxAgeSeconds = int.tryParse(maxAgeStr);
          if (maxAgeSeconds != null && 0 <= maxAgeSeconds) {
            maxAge = Duration(seconds: maxAgeSeconds);
          }
        }
      }
    }

    return CacheInfo(
      etag: etag,
      lastModified: lastModified,
      maxAge: maxAge,
      noCache: noCache,
      noStore: noStore,
    );
  }

  /// Disposes of the HTTP client and cleans up resources.
  void dispose() {
    _client.close();
  }
}
