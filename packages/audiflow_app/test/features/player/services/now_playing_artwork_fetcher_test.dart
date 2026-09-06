import 'dart:io';
import 'dart:typed_data';

import 'package:audiflow_app/features/player/services/now_playing_artwork_fetcher.dart';
import 'package:checks/checks.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';

const _url = 'https://example.com/art.jpg';

void main() {
  late Dio dio;
  late DioAdapter adapter;
  late Directory dir;

  setUp(() async {
    dio = Dio();
    adapter = DioAdapter(dio: dio);
    dir = await Directory.systemTemp.createTemp('artwork_fetcher_');
  });

  tearDown(() => dir.delete(recursive: true));

  group('NowPlayingArtworkFetcher', () {
    test('reads the bytes from the UI image cache when present', () async {
      final cached = File('${dir.path}/cached.jpg')
        ..writeAsBytesSync([7, 7, 7]);
      final fetcher = NowPlayingArtworkFetcher(
        dio: dio,
        cachedImageFile: (_) async => cached,
      );

      check(await fetcher.fetch(_url)).isNotNull().deepEquals([7, 7, 7]);
    });

    test('downloads the bytes when the UI cache misses', () async {
      adapter.onGet(
        _url,
        (server) => server.reply(200, Uint8List.fromList([1, 2, 3])),
      );
      final fetcher = NowPlayingArtworkFetcher(
        dio: dio,
        cachedImageFile: (_) async => null,
      );

      final bytes = await fetcher.fetch(_url);

      check(bytes).isNotNull().deepEquals([1, 2, 3]);
    });

    test('downloads when the cache lookup itself fails', () async {
      adapter.onGet(
        _url,
        (server) => server.reply(200, Uint8List.fromList([4, 5])),
      );
      final fetcher = NowPlayingArtworkFetcher(
        dio: dio,
        cachedImageFile: (_) async => throw const FileSystemException(),
      );

      check(await fetcher.fetch(_url)).isNotNull().deepEquals([4, 5]);
    });

    test('propagates download failures to the caller', () async {
      adapter.onGet(_url, (server) => server.reply(404, ''));
      final fetcher = NowPlayingArtworkFetcher(
        dio: dio,
        cachedImageFile: (_) async => null,
      );

      await check(fetcher.fetch(_url)).throws<DioException>();
    });
  });
}
