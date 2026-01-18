import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:audiflow_podcast/src/network/http_fetcher.dart';

const testUrl = 'https://example.com/feed.xml';
const testRssContent = '<rss>test content</rss>';
const testContent = 'test';

class MockHttpClient implements HttpClient {
  final List<MockHttpClientRequest> _requests = [];
  late MockHttpClientResponse _mockResponse;
  Exception? _exception;

  void setMockResponse(MockHttpClientResponse response) {
    _mockResponse = response;
  }

  void setException(Exception exception) {
    _exception = exception;
  }

  List<MockHttpClientRequest> get requests => _requests;

  @override
  Future<HttpClientRequest> getUrl(Uri url) async {
    if (_exception != null) {
      throw _exception!;
    }

    final request = MockHttpClientRequest(url, _mockResponse);
    _requests.add(request);
    return request;
  }

  @override
  void close({bool force = false}) {}

  @override
  bool get autoUncompress => throw UnimplementedError();

  @override
  set autoUncompress(bool value) => throw UnimplementedError();

  @override
  Duration? connectionTimeout;

  @override
  Duration get idleTimeout => throw UnimplementedError();

  @override
  set idleTimeout(Duration value) => throw UnimplementedError();

  @override
  int? get maxConnectionsPerHost => throw UnimplementedError();

  @override
  set maxConnectionsPerHost(int? value) => throw UnimplementedError();

  @override
  String? get userAgent => throw UnimplementedError();

  @override
  set userAgent(String? value) => throw UnimplementedError();

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class MockHttpClientRequest implements HttpClientRequest {
  final Uri _uri;
  final MockHttpClientResponse _response;
  final HttpHeaders _headers = MockHttpHeaders();

  MockHttpClientRequest(this._uri, this._response);

  @override
  Future<HttpClientResponse> close() async {
    return _response;
  }

  @override
  HttpHeaders get headers => _headers;

  @override
  Uri get uri => _uri;

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class MockHttpClientResponse extends Stream<List<int>>
    implements HttpClientResponse {
  final int _statusCode;
  final String _reasonPhrase;
  final Stream<List<int>> _dataStream;
  final MockHttpHeaders _headers = MockHttpHeaders();

  MockHttpClientResponse(
    this._statusCode,
    this._reasonPhrase,
    this._dataStream,
  );

  @override
  int get statusCode => _statusCode;

  @override
  String get reasonPhrase => _reasonPhrase;

  @override
  MockHttpHeaders get headers => _headers;

  @override
  StreamSubscription<List<int>> listen(
    void Function(List<int> event)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    return _dataStream.listen(
      onData,
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) {
    // Handle specific Stream methods that return Futures or Streams
    if (invocation.memberName == #any) {
      return _dataStream.any(invocation.positionalArguments[0]);
    }
    return super.noSuchMethod(invocation);
  }
}

class MockHttpHeaders implements HttpHeaders {
  final Map<String, List<String>> _headers = {};

  @override
  void add(String name, Object value, {bool preserveHeaderCase = false}) {
    final key = preserveHeaderCase ? name : name.toLowerCase();
    _headers.putIfAbsent(key, () => []).add(value.toString());
  }

  @override
  void set(String name, Object value, {bool preserveHeaderCase = false}) {
    final key = preserveHeaderCase ? name : name.toLowerCase();
    _headers[key] = [value.toString()];
  }

  @override
  String? value(String name) {
    final values = _headers[name.toLowerCase()];
    return values?.isNotEmpty == true ? values!.first : null;
  }

  @override
  List<String>? operator [](String name) {
    return _headers[name.toLowerCase()];
  }

  @override
  void forEach(void Function(String name, List<String> values) action) {
    _headers.forEach(action);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

void main() {
  group('HttpFetcher', () {
    late MockHttpClient mockClient;
    late HttpFetcher fetcher;

    setUp(() {
      mockClient = MockHttpClient();
      fetcher = HttpFetcher(client: mockClient);
    });

    tearDown(() {
      fetcher.dispose();
    });

    group('fetchStream', () {
      test('should fetch content successfully', () async {
        final dataStream = Stream.fromIterable([utf8.encode(testRssContent)]);
        mockClient.setMockResponse(
          MockHttpClientResponse(200, 'OK', dataStream),
        );

        final stream = fetcher.fetchStream(testUrl);
        final chunks = await stream.toList();

        expect(chunks.length, 1);
        expect(utf8.decode(chunks.first), testRssContent);
        expect(mockClient.requests.length, 1);
        expect(mockClient.requests.first.uri.toString(), testUrl);
      });

      test('should set correct headers', () async {
        final dataStream = Stream.fromIterable([utf8.encode(testContent)]);
        mockClient.setMockResponse(
          MockHttpClientResponse(200, 'OK', dataStream),
        );

        await fetcher.fetchStream(testUrl).toList();

        final request = mockClient.requests.first;
        expect(
          request.headers.value('user-agent'),
          contains('PodcastRssParser'),
        );
        expect(
          request.headers.value('accept'),
          contains('application/rss+xml'),
        );
      });

      test('should use custom user agent', () async {
        const customUserAgent = 'MyApp/1.0';
        final customFetcher = HttpFetcher(
          userAgent: customUserAgent,
          client: mockClient,
        );
        final dataStream = Stream.fromIterable([utf8.encode(testContent)]);
        mockClient.setMockResponse(
          MockHttpClientResponse(200, 'OK', dataStream),
        );

        await customFetcher.fetchStream(testUrl).toList();

        expect(
          mockClient.requests.first.headers.value('user-agent'),
          customUserAgent,
        );
        customFetcher.dispose();
      });

      test('should throw HttpException for 404 status', () async {
        final dataStream = Stream.fromIterable([utf8.encode('Not Found')]);
        mockClient.setMockResponse(
          MockHttpClientResponse(404, 'Not Found', dataStream),
        );

        expect(
          () => fetcher.fetchStream(testUrl).toList(),
          throwsA(
            isA<HttpException>().having(
              (e) => e.message,
              'message',
              contains('HTTP 404'),
            ),
          ),
        );
      });

      test('should throw HttpException for 500 status', () async {
        final dataStream = Stream.fromIterable([utf8.encode('Server Error')]);
        mockClient.setMockResponse(
          MockHttpClientResponse(500, 'Internal Server Error', dataStream),
        );

        expect(
          () => fetcher.fetchStream(testUrl).toList(),
          throwsA(
            isA<HttpException>().having(
              (e) => e.message,
              'message',
              contains('HTTP 500'),
            ),
          ),
        );
      });

      test('should handle SocketException', () async {
        mockClient.setException(const SocketException('Network unreachable'));

        expect(
          () => fetcher.fetchStream(testUrl).toList(),
          throwsA(
            isA<HttpException>().having(
              (e) => e.message,
              'message',
              contains('Network error'),
            ),
          ),
        );
      });

      test('should handle TimeoutException', () async {
        mockClient.setException(
          TimeoutException('Request timeout', const Duration(seconds: 30)),
        );

        expect(
          () => fetcher.fetchStream(testUrl).toList(),
          throwsA(
            isA<HttpException>().having(
              (e) => e.message,
              'message',
              contains('Request timeout'),
            ),
          ),
        );
      });

      test('should handle generic exceptions', () async {
        mockClient.setException(Exception('Generic error'));

        expect(
          () => fetcher.fetchStream(testUrl).toList(),
          throwsA(
            isA<HttpException>().having(
              (e) => e.message,
              'message',
              contains('Unexpected error'),
            ),
          ),
        );
      });
    });

    group('fetchWithHeaders', () {
      test('should return response with headers', () async {
        final dataStream = Stream.fromIterable([utf8.encode(testContent)]);
        mockClient.setMockResponse(
          MockHttpClientResponse(200, 'OK', dataStream),
        );

        final response = await fetcher.fetchWithHeaders(testUrl);

        expect(response.statusCode, 200);
        expect(response.reasonPhrase, 'OK');
      });

      test('should set conditional headers', () async {
        const etag = '"abc123"';
        final modifiedSince = DateTime(2023, 1, 1);
        final dataStream = Stream.fromIterable([utf8.encode(testContent)]);
        mockClient.setMockResponse(
          MockHttpClientResponse(304, 'Not Modified', dataStream),
        );

        await fetcher.fetchWithHeaders(
          testUrl,
          ifNoneMatch: etag,
          ifModifiedSince: modifiedSince,
        );

        final request = mockClient.requests.first;
        expect(request.headers.value('if-none-match'), etag);
        expect(request.headers.value('if-modified-since'), isNotNull);
      });

      test('should handle 304 Not Modified response', () async {
        final dataStream = Stream.fromIterable([utf8.encode('')]);
        mockClient.setMockResponse(
          MockHttpClientResponse(304, 'Not Modified', dataStream),
        );

        final response = await fetcher.fetchWithHeaders(testUrl);

        expect(response.statusCode, 304);
        expect(response.reasonPhrase, 'Not Modified');
      });

      test('should throw HttpException for other error codes', () async {
        final dataStream = Stream.fromIterable([utf8.encode('Forbidden')]);
        mockClient.setMockResponse(
          MockHttpClientResponse(403, 'Forbidden', dataStream),
        );

        expect(
          () => fetcher.fetchWithHeaders(testUrl),
          throwsA(
            isA<HttpException>().having(
              (e) => e.message,
              'message',
              contains('HTTP 403'),
            ),
          ),
        );
      });
    });

    group('extractCacheInfo', () {
      test('should extract ETag from response headers', () async {
        // Arrange
        const testUrl = 'https://example.com/feed.xml';
        const etag = '"abc123"';
        final dataStream = Stream.fromIterable([utf8.encode('test')]);

        final mockResponse = MockHttpClientResponse(200, 'OK', dataStream);
        mockResponse.headers.set('etag', etag);
        mockClient.setMockResponse(mockResponse);

        // Act
        final response = await fetcher.fetchWithHeaders(testUrl);
        final cacheInfo = fetcher.extractCacheInfo(response);

        // Assert
        expect(cacheInfo.etag, equals(etag));
        expect(cacheInfo.lastModified, isNull);
        expect(cacheInfo.maxAge, isNull);
        expect(cacheInfo.noCache, isFalse);
        expect(cacheInfo.noStore, isFalse);
      });

      test('should extract Last-Modified from response headers', () async {
        // Arrange
        const testUrl = 'https://example.com/feed.xml';
        final lastModified = DateTime.utc(2023, 1, 1, 12, 0, 0);
        final lastModifiedStr = HttpDate.format(lastModified);
        final dataStream = Stream.fromIterable([utf8.encode('test')]);

        final mockResponse = MockHttpClientResponse(200, 'OK', dataStream);
        mockResponse.headers.set('last-modified', lastModifiedStr);
        mockClient.setMockResponse(mockResponse);

        // Act
        final response = await fetcher.fetchWithHeaders(testUrl);
        final cacheInfo = fetcher.extractCacheInfo(response);

        // Assert
        expect(cacheInfo.etag, isNull);
        expect(cacheInfo.lastModified, equals(lastModified));
        expect(cacheInfo.maxAge, isNull);
        expect(cacheInfo.noCache, isFalse);
        expect(cacheInfo.noStore, isFalse);
      });

      test('should extract Cache-Control max-age', () async {
        // Arrange
        const testUrl = 'https://example.com/feed.xml';
        const maxAgeSeconds = 3600;
        final dataStream = Stream.fromIterable([utf8.encode('test')]);

        final mockResponse = MockHttpClientResponse(200, 'OK', dataStream);
        mockResponse.headers.set('cache-control', 'max-age=$maxAgeSeconds');
        mockClient.setMockResponse(mockResponse);

        // Act
        final response = await fetcher.fetchWithHeaders(testUrl);
        final cacheInfo = fetcher.extractCacheInfo(response);

        // Assert
        expect(cacheInfo.etag, isNull);
        expect(cacheInfo.lastModified, isNull);
        expect(cacheInfo.maxAge, equals(const Duration(seconds: maxAgeSeconds)));
        expect(cacheInfo.noCache, isFalse);
        expect(cacheInfo.noStore, isFalse);
      });

      test('should extract Cache-Control no-cache directive', () async {
        // Arrange
        const testUrl = 'https://example.com/feed.xml';
        final dataStream = Stream.fromIterable([utf8.encode('test')]);

        final mockResponse = MockHttpClientResponse(200, 'OK', dataStream);
        mockResponse.headers.set('cache-control', 'no-cache');
        mockClient.setMockResponse(mockResponse);

        // Act
        final response = await fetcher.fetchWithHeaders(testUrl);
        final cacheInfo = fetcher.extractCacheInfo(response);

        // Assert
        expect(cacheInfo.etag, isNull);
        expect(cacheInfo.lastModified, isNull);
        expect(cacheInfo.maxAge, isNull);
        expect(cacheInfo.noCache, isTrue);
        expect(cacheInfo.noStore, isFalse);
      });

      test('should extract Cache-Control no-store directive', () async {
        // Arrange
        const testUrl = 'https://example.com/feed.xml';
        final dataStream = Stream.fromIterable([utf8.encode('test')]);

        final mockResponse = MockHttpClientResponse(200, 'OK', dataStream);
        mockResponse.headers.set('cache-control', 'no-store');
        mockClient.setMockResponse(mockResponse);

        // Act
        final response = await fetcher.fetchWithHeaders(testUrl);
        final cacheInfo = fetcher.extractCacheInfo(response);

        // Assert
        expect(cacheInfo.etag, isNull);
        expect(cacheInfo.lastModified, isNull);
        expect(cacheInfo.maxAge, isNull);
        expect(cacheInfo.noCache, isFalse);
        expect(cacheInfo.noStore, isTrue);
      });

      test('should extract multiple Cache-Control directives', () async {
        // Arrange
        const testUrl = 'https://example.com/feed.xml';
        final dataStream = Stream.fromIterable([utf8.encode('test')]);

        final mockResponse = MockHttpClientResponse(200, 'OK', dataStream);
        mockResponse.headers.set(
          'cache-control',
          'max-age=1800, no-cache, public',
        );
        mockClient.setMockResponse(mockResponse);

        // Act
        final response = await fetcher.fetchWithHeaders(testUrl);
        final cacheInfo = fetcher.extractCacheInfo(response);

        // Assert
        expect(cacheInfo.etag, isNull);
        expect(cacheInfo.lastModified, isNull);
        expect(cacheInfo.maxAge, equals(const Duration(seconds: 1800)));
        expect(cacheInfo.noCache, isTrue);
        expect(cacheInfo.noStore, isFalse);
      });

      test('should extract all caching headers together', () async {
        // Arrange
        const testUrl = 'https://example.com/feed.xml';
        const etag = '"xyz789"';
        final lastModified = DateTime.utc(2023, 6, 15, 10, 30, 0);
        final lastModifiedStr = HttpDate.format(lastModified);
        final dataStream = Stream.fromIterable([utf8.encode('test')]);

        final mockResponse = MockHttpClientResponse(200, 'OK', dataStream);
        mockResponse.headers.set('etag', etag);
        mockResponse.headers.set('last-modified', lastModifiedStr);
        mockResponse.headers.set('cache-control', 'max-age=7200');
        mockClient.setMockResponse(mockResponse);

        // Act
        final response = await fetcher.fetchWithHeaders(testUrl);
        final cacheInfo = fetcher.extractCacheInfo(response);

        // Assert
        expect(cacheInfo.etag, equals(etag));
        expect(cacheInfo.lastModified, equals(lastModified));
        expect(cacheInfo.maxAge, equals(const Duration(seconds: 7200)));
        expect(cacheInfo.noCache, isFalse);
        expect(cacheInfo.noStore, isFalse);
      });

      test('should handle invalid Last-Modified date gracefully', () async {
        // Arrange
        const testUrl = 'https://example.com/feed.xml';
        final dataStream = Stream.fromIterable([utf8.encode('test')]);

        final mockResponse = MockHttpClientResponse(200, 'OK', dataStream);
        mockResponse.headers.set('last-modified', 'invalid-date-format');
        mockClient.setMockResponse(mockResponse);

        // Act
        final response = await fetcher.fetchWithHeaders(testUrl);
        final cacheInfo = fetcher.extractCacheInfo(response);

        // Assert
        expect(cacheInfo.lastModified, isNull);
      });

      test('should handle invalid max-age value gracefully', () async {
        // Arrange
        const testUrl = 'https://example.com/feed.xml';
        final dataStream = Stream.fromIterable([utf8.encode('test')]);

        final mockResponse = MockHttpClientResponse(200, 'OK', dataStream);
        mockResponse.headers.set('cache-control', 'max-age=invalid');
        mockClient.setMockResponse(mockResponse);

        // Act
        final response = await fetcher.fetchWithHeaders(testUrl);
        final cacheInfo = fetcher.extractCacheInfo(response);

        // Assert
        expect(cacheInfo.maxAge, isNull);
      });

      test('should handle negative max-age value gracefully', () async {
        // Arrange
        const testUrl = 'https://example.com/feed.xml';
        final dataStream = Stream.fromIterable([utf8.encode('test')]);

        final mockResponse = MockHttpClientResponse(200, 'OK', dataStream);
        mockResponse.headers.set('cache-control', 'max-age=-100');
        mockClient.setMockResponse(mockResponse);

        // Act
        final response = await fetcher.fetchWithHeaders(testUrl);
        final cacheInfo = fetcher.extractCacheInfo(response);

        // Assert
        expect(cacheInfo.maxAge, isNull);
      });
    });

    group('CacheInfo', () {
      test('should have correct convenience properties', () {
        // Test shouldNotCache
        const noStoreInfo = CacheInfo(noStore: true);
        expect(noStoreInfo.shouldNotCache, isTrue);

        const normalInfo = CacheInfo();
        expect(normalInfo.shouldNotCache, isFalse);

        // Test requiresRevalidation
        const noCacheInfo = CacheInfo(noCache: true);
        expect(noCacheInfo.requiresRevalidation, isTrue);

        expect(normalInfo.requiresRevalidation, isFalse);

        // Test hasValidationHeaders
        const etagInfo = CacheInfo(etag: '"abc123"');
        expect(etagInfo.hasValidationHeaders, isTrue);

        final lastModifiedInfo = CacheInfo(lastModified: DateTime.now());
        expect(lastModifiedInfo.hasValidationHeaders, isTrue);

        expect(normalInfo.hasValidationHeaders, isFalse);
      });

      test('should have correct equality and hashCode', () {
        const duration = Duration(seconds: 3600);

        const info1 = CacheInfo(
          etag: '"abc123"',
          maxAge: duration,
          noCache: true,
        );

        const info2 = CacheInfo(
          etag: '"abc123"',
          maxAge: duration,
          noCache: true,
        );

        const info3 = CacheInfo(
          etag: '"xyz789"',
          maxAge: duration,
          noCache: true,
        );

        expect(info1, equals(info2));
        expect(info1.hashCode, equals(info2.hashCode));
        expect(info1, isNot(equals(info3)));
      });

      test('should have meaningful toString', () {
        const info = CacheInfo(
          etag: '"abc123"',
          maxAge: Duration(seconds: 3600),
          noCache: true,
        );

        final str = info.toString();
        expect(str, contains('CacheInfo'));
        expect(str, contains('"abc123"'));
        expect(str, contains('1:00:00')); // Duration toString format
        expect(str, contains('true'));
      });
    });

    group('dispose', () {
      test('should close HTTP client', () {
        expect(() => fetcher.dispose(), returnsNormally);
      });
    });
  });
}
