import 'dart:io';
import 'dart:typed_data';

import 'package:audiflow_app/features/player/services/now_playing_artwork_fetcher.dart';
import 'package:checks/checks.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

const _url = 'https://example.com/art.jpg';

/// Serves a canned streamed response so tests can drive the bounded
/// download path without a network.
class _StubAdapter implements HttpClientAdapter {
  _StubAdapter({
    this.chunks = const [],
    this.statusCode = 200,
    this.declaredLength,
  });

  final List<List<int>> chunks;
  final int statusCode;
  final int? declaredLength;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async => ResponseBody(
    _emit(),
    statusCode,
    headers: {
      if (declaredLength != null)
        Headers.contentLengthHeader: ['$declaredLength'],
    },
  );

  Stream<Uint8List> _emit() async* {
    for (final chunk in chunks) {
      yield Uint8List.fromList(chunk);
    }
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  late Dio dio;
  late Directory tempDirectory;

  setUp(() async {
    dio = Dio();
    tempDirectory = await Directory.systemTemp.createTemp('artwork_fetcher_');
  });

  tearDown(() => tempDirectory.delete(recursive: true));

  NowPlayingArtworkFetcher buildFetcher({
    required CachedImageFileLookup cachedImageFile,
    int maxEncodedBytes = nowPlayingArtworkMaxEncodedBytes,
  }) => NowPlayingArtworkFetcher(
    dio: dio,
    cachedImageFile: cachedImageFile,
    maxEncodedBytes: maxEncodedBytes,
  );

  group('NowPlayingArtworkFetcher', () {
    test('reads the bytes from the UI image cache when present', () async {
      final cached = File('${tempDirectory.path}/cached.jpg')
        ..writeAsBytesSync([7, 7, 7]);
      final fetcher = buildFetcher(cachedImageFile: (_) async => cached);

      check(await fetcher.fetch(_url)).isNotNull().deepEquals([7, 7, 7]);
    });

    test('treats an oversized cache entry as a miss', () async {
      final cached = File('${tempDirectory.path}/cached.jpg')
        ..writeAsBytesSync([1, 2, 3, 4, 5]);
      dio.httpClientAdapter = _StubAdapter(
        chunks: [
          [9, 9],
        ],
      );
      final fetcher = buildFetcher(
        cachedImageFile: (_) async => cached,
        maxEncodedBytes: 4,
      );

      check(await fetcher.fetch(_url)).isNotNull().deepEquals([9, 9]);
    });

    test('downloads the bytes when the UI cache misses', () async {
      dio.httpClientAdapter = _StubAdapter(
        chunks: [
          [1, 2],
          [3],
        ],
      );
      final fetcher = buildFetcher(cachedImageFile: (_) async => null);

      check(await fetcher.fetch(_url)).isNotNull().deepEquals([1, 2, 3]);
    });

    test('downloads when the cache lookup itself fails', () async {
      dio.httpClientAdapter = _StubAdapter(
        chunks: [
          [4, 5],
        ],
      );
      final fetcher = buildFetcher(
        cachedImageFile: (_) async => throw const FileSystemException(),
      );

      check(await fetcher.fetch(_url)).isNotNull().deepEquals([4, 5]);
    });

    test('refuses a body that declares an oversized length', () async {
      dio.httpClientAdapter = _StubAdapter(
        chunks: [
          [1, 2],
        ],
        declaredLength: 99,
      );
      final fetcher = buildFetcher(
        cachedImageFile: (_) async => null,
        maxEncodedBytes: 4,
      );

      check(await fetcher.fetch(_url)).isNull();
    });

    test('refuses a body that grows past the limit mid-stream', () async {
      dio.httpClientAdapter = _StubAdapter(
        chunks: [
          [1, 2],
          [3, 4],
          [5, 6],
        ],
      );
      final fetcher = buildFetcher(
        cachedImageFile: (_) async => null,
        maxEncodedBytes: 3,
      );

      check(await fetcher.fetch(_url)).isNull();
    });

    test('returns null for an empty body', () async {
      dio.httpClientAdapter = _StubAdapter();
      final fetcher = buildFetcher(cachedImageFile: (_) async => null);

      check(await fetcher.fetch(_url)).isNull();
    });

    test('propagates download failures to the caller', () async {
      dio.httpClientAdapter = _StubAdapter(statusCode: 404);
      final fetcher = buildFetcher(cachedImageFile: (_) async => null);

      await check(fetcher.fetch(_url)).throws<DioException>();
    });
  });
}
