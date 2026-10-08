import 'dart:async';
import 'dart:typed_data';

import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:checks/checks.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart' hide expect;
import 'package:isar_community/isar.dart';
import 'package:logger/logger.dart';

import '../../../helpers/isar_test_helper.dart';

const _vttUrl = 'https://example.com/ep1.vtt';
const _srtUrl = 'https://example.com/ep1.srt';

const _vttContent =
    'WEBVTT\n'
    '\n'
    '00:00:01.000 --> 00:00:05.000\n'
    'Hello world\n'
    '\n'
    '00:00:05.000 --> 00:00:10.000\n'
    'Second line\n';

const _srtContent =
    '1\n'
    '00:00:01,000 --> 00:00:05,000\n'
    'Hello from SRT\n';

void main() {
  late Isar isar;
  late TranscriptRepository repository;
  late _FakeHttpAdapter http;
  late TranscriptService service;
  const episodeId = 1;

  setUpAll(() async {
    await Isar.initializeIsarCore(download: true);
  });

  setUp(() async {
    isar = await openTestIsar([
      EpisodeTranscriptSchema,
      TranscriptSegmentSchema,
    ]);
    repository = TranscriptRepositoryImpl(
      datasource: TranscriptLocalDatasource(isar),
    );
    http = _FakeHttpAdapter();
    service = TranscriptService(
      repository: repository,
      dio: Dio()..httpClientAdapter = http,
      logger: Logger(level: Level.off),
    );
  });

  tearDown(() async {
    await isar.close(deleteFromDisk: true);
  });

  Future<int> declare(String url, String type) async {
    await repository.upsertMetas([
      EpisodeTranscript()
        ..episodeId = episodeId
        ..url = url
        ..type = type,
    ]);
    final metas = await repository.getMetasByEpisodeId(episodeId);
    return metas.firstWhere((m) => m.url == url).id;
  }

  Future<EpisodeTranscript> stored(int transcriptId) async {
    final metas = await repository.getMetasByEpisodeId(episodeId);
    return metas.firstWhere((m) => m.id == transcriptId);
  }

  group('ensureContent', () {
    test('returns null when no transcript metadata exists', () async {
      check(await service.ensureContent(episodeId)).isNull();
    });

    test('returns null when no supported types exist', () async {
      await declare('https://example.com/ep1.json', 'application/json');

      check(await service.ensureContent(episodeId)).isNull();
      check(http.requested).isEmpty();
    });

    test('returns transcriptId when content already fetched', () async {
      final transcriptId = await declare(_vttUrl, 'text/vtt');
      await repository.markAsFetched(transcriptId);

      check(await service.ensureContent(episodeId)).equals(transcriptId);
      check(http.requested).isEmpty();
    });

    test('fetches, parses, stores segments, and marks as fetched', () async {
      final transcriptId = await declare(_vttUrl, 'text/vtt');
      http.respond(_vttUrl, _vttContent);

      check(await service.ensureContent(episodeId)).equals(transcriptId);

      final segments = await repository.getAllSegments(transcriptId);
      check(
        segments.map((s) => s.body),
      ).deepEquals(['Hello world', 'Second line']);
      check(segments.first.startMs).equals(1000);
      check(segments.first.endMs).equals(5000);
      check(await repository.isContentFetched(transcriptId)).isTrue();
    });

    test('prefers VTT over SRT', () async {
      await declare(_srtUrl, 'application/srt');
      final vttId = await declare(_vttUrl, 'text/vtt');
      http
        ..respond(_vttUrl, _vttContent)
        ..respond(_srtUrl, _srtContent);

      check(await service.ensureContent(episodeId)).equals(vttId);
      check(http.requested).deepEquals([_vttUrl]);
    });

    test('stores speaker information from VTT', () async {
      final transcriptId = await declare(_vttUrl, 'text/vtt');
      http.respond(
        _vttUrl,
        'WEBVTT\n\n00:00:01.000 --> 00:00:05.000\n<v Alice>Hello from Alice\n',
      );

      await service.ensureContent(episodeId);

      final segments = await repository.getAllSegments(transcriptId);
      check(segments).length.equals(1);
      check(segments.single.speaker).equals('Alice');
      check(segments.single.body).equals('Hello from Alice');
    });

    test('falls back to SRT when VTT not available', () async {
      final srtId = await declare(_srtUrl, 'application/srt');
      http.respond(_srtUrl, _srtContent);

      check(await service.ensureContent(episodeId)).equals(srtId);
      final segments = await repository.getAllSegments(srtId);
      check(segments.single.body).equals('Hello from SRT');
    });
  });

  group('ensureContent with an unusable file', () {
    test('a network failure returns null without marking the file', () async {
      final transcriptId = await declare(_vttUrl, 'text/vtt');
      http.failWithConnectionError(_vttUrl);

      check(await service.ensureContent(episodeId)).isNull();
      check((await stored(transcriptId)).unusableAt).isNull();
    });

    test('an HTTP error returns null without marking the file', () async {
      final transcriptId = await declare(_vttUrl, 'text/vtt');
      http.respond(_vttUrl, 'Not Found', statusCode: 404);

      check(await service.ensureContent(episodeId)).isNull();
      check((await stored(transcriptId)).unusableAt).isNull();
    });

    test('empty content returns null and marks the file unusable', () async {
      final transcriptId = await declare(_vttUrl, 'text/vtt');
      http.respond(_vttUrl, '');

      check(await service.ensureContent(episodeId)).isNull();
      check((await stored(transcriptId)).unusableAt).isNotNull();
    });

    test('content without cues returns null and marks the file', () async {
      final transcriptId = await declare(_vttUrl, 'text/vtt');
      http.respond(_vttUrl, '<html><body>Moved</body></html>');

      check(await service.ensureContent(episodeId)).isNull();
      check((await stored(transcriptId)).unusableAt).isNotNull();
      check(await repository.getAllSegments(transcriptId)).isEmpty();
    });

    test('a file marked unusable is not fetched again', () async {
      final transcriptId = await declare(_vttUrl, 'text/vtt');
      await repository.markAsUnusable(transcriptId);

      check(await service.ensureContent(episodeId)).isNull();
      check(http.requested).isEmpty();
    });

    test(
      'falls through to the next file when the preferred one is unusable',
      () async {
        final srtId = await declare(_srtUrl, 'application/srt');
        await declare(_vttUrl, 'text/vtt');
        http
          ..respond(_vttUrl, '')
          ..respond(_srtUrl, _srtContent);

        check(await service.ensureContent(episodeId)).equals(srtId);
        check(http.requested).deepEquals([_vttUrl, _srtUrl]);
      },
    );
  });

  group('ensureContent when cancelled', () {
    test('mid-download returns null without marking the file', () async {
      await declare(_srtUrl, 'application/srt');
      final vttId = await declare(_vttUrl, 'text/vtt');
      http.hang(_vttUrl);
      final cancelToken = CancelToken();

      final result = service.ensureContent(episodeId, cancelToken: cancelToken);
      await http.firstRequest;
      cancelToken.cancel();

      check(await result).isNull();
      check((await stored(vttId)).unusableAt).isNull();
      check(http.requested).deepEquals([_vttUrl]);
    });

    test('before it starts fetches nothing', () async {
      await declare(_vttUrl, 'text/vtt');
      final cancelToken = CancelToken()..cancel();

      final result = await service.ensureContent(
        episodeId,
        cancelToken: cancelToken,
      );

      check(result).isNull();
      check(http.requested).isEmpty();
    });
  });
}

/// Serves canned bodies per URL and records each request, standing in for
/// the network.
class _FakeHttpAdapter implements HttpClientAdapter {
  final _responses = <String, ({String body, int statusCode})>{};
  final _connectionErrors = <String>{};
  final _hanging = <String>{};
  final _firstRequest = Completer<void>();
  final requested = <String>[];

  /// Completes once any request reaches the adapter.
  Future<void> get firstRequest => _firstRequest.future;

  void respond(String url, String body, {int statusCode = 200}) =>
      _responses[url] = (body: body, statusCode: statusCode);

  void failWithConnectionError(String url) => _connectionErrors.add(url);

  /// Never answers [url], like a stalled download, so a test can cancel it.
  void hang(String url) => _hanging.add(url);

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    final url = options.uri.toString();
    requested.add(url);
    if (!_firstRequest.isCompleted) _firstRequest.complete();
    if (_hanging.contains(url)) return Completer<ResponseBody>().future;
    if (_connectionErrors.contains(url)) {
      throw DioException.connectionError(
        requestOptions: options,
        reason: 'offline',
      );
    }
    final response = _responses[url] ?? (body: 'Not Found', statusCode: 404);
    return ResponseBody.fromString(
      response.body,
      response.statusCode,
      headers: {
        Headers.contentTypeHeader: ['text/plain'],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}
