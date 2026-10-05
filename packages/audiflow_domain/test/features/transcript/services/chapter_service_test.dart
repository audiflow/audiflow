import 'dart:typed_data';

import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:checks/checks.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';
import 'package:logger/logger.dart';

import '../../../helpers/isar_test_helper.dart';

/// Answers every request with [handler] and counts the requests.
class _FakeHttpAdapter implements HttpClientAdapter {
  Future<ResponseBody> Function(RequestOptions options)? handler;
  int requests = 0;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) {
    requests++;
    return handler!(options);
  }

  @override
  void close({bool force = false}) {}
}

/// Runs [onRead] right after the [readsBeforeHook]-th chapter read, to
/// interleave a concurrent write between a read and the write that follows.
class _InterleavingChapterRepository extends ChapterRepositoryImpl {
  _InterleavingChapterRepository({required super.datasource});

  int readsBeforeHook = 0;
  Future<void> Function()? onRead;

  @override
  Future<List<EpisodeChapter>> getByEpisodeId(int episodeId) async {
    final rows = await super.getByEpisodeId(episodeId);
    readsBeforeHook--;
    final hook = onRead;
    if (hook != null && readsBeforeHook == 0) {
      onRead = null;
      await hook();
    }
    return rows;
  }
}

const _chaptersUrl = 'https://example.com/ep1/chapters.json';

const _validJson = '''
{"version": "1.2.0", "chapters": [
  {"startTime": 0, "title": "Intro"},
  {"startTime": 30, "title": "Sponsor", "toc": false},
  {"startTime": 60, "title": "Topic", "img": "https://example.com/t.jpg"}
]}''';

void main() {
  late Isar isar;
  late ChapterLocalDatasource chapterDatasource;
  late EpisodeLocalDatasource episodeDatasource;
  late _FakeHttpAdapter http;
  late DateTime now;
  late ChapterService service;

  setUpAll(() async {
    await Isar.initializeIsarCore(download: true);
  });

  setUp(() async {
    isar = await openTestIsar([EpisodeSchema, EpisodeChapterSchema]);
    chapterDatasource = ChapterLocalDatasource(isar);
    episodeDatasource = EpisodeLocalDatasource(isar);
    http = _FakeHttpAdapter();
    now = DateTime(2026, 1, 1);
    service = ChapterService(
      chapterRepository: ChapterRepositoryImpl(datasource: chapterDatasource),
      episodeRepository: EpisodeRepositoryImpl(datasource: episodeDatasource),
      dio: Dio()..httpClientAdapter = http,
      logger: Logger(level: Level.off),
      now: () => now,
    );
  });

  tearDown(() async {
    await isar.close(deleteFromDisk: true);
  });

  Future<int> insertEpisode({
    String? chaptersUrl = _chaptersUrl,
    String? chaptersType = 'application/json+chapters',
    String? description,
    int? durationMs,
  }) async {
    await episodeDatasource.upsert(
      Episode()
        ..podcastId = 1
        ..guid = 'ep1'
        ..title = 'Episode 1'
        ..audioUrl = 'https://example.com/ep1.mp3'
        ..chaptersUrl = chaptersUrl
        ..chaptersType = chaptersType
        ..description = description
        ..durationMs = durationMs,
    );
    return (await episodeDatasource.getByPodcastIdAndGuid(1, 'ep1'))!.id;
  }

  void respondWith(String body) {
    http.handler = (_) async => ResponseBody.fromString(body, 200);
  }

  void failWith(DioExceptionType type) {
    http.handler = (options) async =>
        throw DioException(type: type, requestOptions: options);
  }

  Future<List<String>> storedTitles(int episodeId) async =>
      (await chapterDatasource.getByEpisodeId(
        episodeId,
      )).map((c) => c.title).toList();

  EpisodeChapter pscChapter(int episodeId, String title) => EpisodeChapter()
    ..episodeId = episodeId
    ..sortOrder = 0
    ..title = title
    ..startMs = 0;

  group('ensureChapters', () {
    test('fetches and stores JSON chapters', () async {
      final episodeId = await insertEpisode();
      respondWith(_validJson);

      final changed = await service.ensureChapters(episodeId);

      check(changed).isTrue();
      final chapters = await chapterDatasource.getByEpisodeId(episodeId);
      check(chapters.map((c) => c.title)).deepEquals(['Intro', 'Topic']);
      check(chapters[1].startMs).equals(60000);
      check(chapters[1].imageUrl).equals('https://example.com/t.jpg');
      check(
        chapters.map((c) => c.source),
      ).every((it) => it.equals(ChapterSource.podcastChaptersJson));
    });

    test('replaces stored psc chapters', () async {
      final episodeId = await insertEpisode();
      await chapterDatasource.replaceChapters({
        episodeId: [pscChapter(episodeId, 'From psc')],
      }, source: ChapterSource.podlove);
      respondWith(_validJson);

      await service.ensureChapters(episodeId);

      check(await storedTitles(episodeId)).deepEquals(['Intro', 'Topic']);
    });

    test('does not fetch again once JSON chapters are stored', () async {
      final episodeId = await insertEpisode();
      respondWith(_validJson);
      await service.ensureChapters(episodeId);

      final changed = await service.ensureChapters(episodeId);

      check(changed).isFalse();
      check(http.requests).equals(1);
    });

    test('fetches again when the chapters URL changes', () async {
      final episodeId = await insertEpisode();
      respondWith(_validJson);
      await service.ensureChapters(episodeId);

      await insertEpisode(chaptersUrl: 'https://example.com/ep1/v2.json');
      respondWith('{"chapters": [{"startTime": 0, "title": "Revised"}]}');

      check(await service.ensureChapters(episodeId)).isTrue();
      check(await storedTitles(episodeId)).deepEquals(['Revised']);
      final stored = await chapterDatasource.getByEpisodeId(episodeId);
      check(stored.single.sourceUrl).equals('https://example.com/ep1/v2.json');
    });

    test('a link changed during the download fetches the new file', () async {
      const v2 = 'https://example.com/ep1/v2.json';
      final episodeId = await insertEpisode();
      http.handler = (options) async {
        if (options.uri.toString() == v2) {
          return ResponseBody.fromString(
            '{"chapters": [{"startTime": 0, "title": "Revised"}]}',
            200,
          );
        }
        // Feed sync relinks the episode while the old file downloads.
        await insertEpisode(chaptersUrl: v2);
        return ResponseBody.fromString(_validJson, 200);
      };

      check(await service.ensureChapters(episodeId)).isTrue();
      check(await storedTitles(episodeId)).deepEquals(['Revised']);
      final stored = await chapterDatasource.getByEpisodeId(episodeId);
      check(stored.single.sourceUrl).equals(v2);
      check(http.requests).equals(2);
    });

    test('drops JSON chapters once the feed removes the link', () async {
      final episodeId = await insertEpisode();
      respondWith(_validJson);
      await service.ensureChapters(episodeId);

      await insertEpisode(chaptersUrl: null);

      check(await service.ensureChapters(episodeId)).isTrue();
      check(await storedTitles(episodeId)).isEmpty();
    });

    test('keeps psc chapters when there is no link', () async {
      final episodeId = await insertEpisode(chaptersUrl: null);
      await chapterDatasource.replaceChapters({
        episodeId: [pscChapter(episodeId, 'From psc')],
      }, source: ChapterSource.podlove);

      check(await service.ensureChapters(episodeId)).isFalse();
      check(await storedTitles(episodeId)).deepEquals(['From psc']);
    });

    test('does nothing without a chapters link', () async {
      final episodeId = await insertEpisode(chaptersUrl: null);

      check(await service.ensureChapters(episodeId)).isFalse();
      check(http.requests).equals(0);
    });

    test('ignores non-JSON chapters types', () async {
      final episodeId = await insertEpisode(chaptersType: 'text/plain');

      check(await service.ensureChapters(episodeId)).isFalse();
      check(http.requests).equals(0);
    });

    test('returns false for an unknown episode', () async {
      check(await service.ensureChapters(999)).isFalse();
    });

    test('network failure keeps stored chapters and does not throw', () async {
      final episodeId = await insertEpisode();
      await chapterDatasource.replaceChapters({
        episodeId: [pscChapter(episodeId, 'From psc')],
      }, source: ChapterSource.podlove);
      failWith(DioExceptionType.connectionError);

      check(await service.ensureChapters(episodeId)).isFalse();
      check(await storedTitles(episodeId)).deepEquals(['From psc']);
    });

    test('malformed JSON leaves the episode without chapters', () async {
      final episodeId = await insertEpisode();
      respondWith('{"chapters": [');

      check(await service.ensureChapters(episodeId)).isFalse();
      check(await storedTitles(episodeId)).isEmpty();
    });

    test('JSON without usable chapters stores nothing', () async {
      final episodeId = await insertEpisode();
      respondWith('{"version": "1.2.0", "chapters": [{"startTime": 0}]}');

      check(await service.ensureChapters(episodeId)).isFalse();
      check(await storedTitles(episodeId)).isEmpty();
    });

    test('retries a failed URL only after the cooldown', () async {
      final episodeId = await insertEpisode();
      failWith(DioExceptionType.connectionTimeout);
      await service.ensureChapters(episodeId);

      now = now.add(const Duration(minutes: 1));
      await service.ensureChapters(episodeId);
      check(http.requests).equals(1);

      now = now.add(ChapterService.retryCooldown);
      respondWith(_validJson);
      check(await service.ensureChapters(episodeId)).isTrue();
    });

    test('concurrent calls share one fetch', () async {
      final episodeId = await insertEpisode();
      respondWith(_validJson);

      final results = await Future.wait([
        service.ensureChapters(episodeId),
        service.ensureChapters(episodeId),
      ]);

      check(results).deepEquals([true, true]);
      check(http.requests).equals(1);
    });
  });

  group('description chapters', () {
    const notes = '<p>00:00 オープニング<br />02:57 人生の選択<br />17:22 イベント</p>';

    test('derives chapters for an episode without any', () async {
      final episodeId = await insertEpisode(
        chaptersUrl: null,
        description: notes,
        durationMs: const Duration(minutes: 30).inMilliseconds,
      );

      check(await service.ensureChapters(episodeId)).isTrue();
      final chapters = await chapterDatasource.getByEpisodeId(episodeId);
      check(
        chapters.map((c) => c.title),
      ).deepEquals(['オープニング', '人生の選択', 'イベント']);
      check(
        chapters.map((c) => c.source),
      ).every((it) => it.equals(ChapterSource.description));
      check(await service.ensureChapters(episodeId)).isFalse();
    });

    test('leaves feed chapters alone', () async {
      final episodeId = await insertEpisode(
        chaptersUrl: null,
        description: notes,
      );
      await chapterDatasource.replaceChapters({
        episodeId: [pscChapter(episodeId, 'From psc')],
      }, source: ChapterSource.podlove);

      check(await service.ensureChapters(episodeId)).isFalse();
      check(await storedTitles(episodeId)).deepEquals(['From psc']);
    });

    test('falls back to notes when JSON fails, JSON wins later', () async {
      final episodeId = await insertEpisode(description: notes);
      failWith(DioExceptionType.connectionError);

      await service.ensureChapters(episodeId);
      check(
        await storedTitles(episodeId),
      ).deepEquals(['オープニング', '人生の選択', 'イベント']);

      now = now.add(ChapterService.retryCooldown);
      respondWith(_validJson);
      await service.ensureChapters(episodeId);
      check(await storedTitles(episodeId)).deepEquals(['Intro', 'Topic']);
    });

    test('refreshes and drops chapters as the notes change', () async {
      final episodeId = await insertEpisode(
        chaptersUrl: null,
        description: notes,
      );
      await service.ensureChapters(episodeId);

      await insertEpisode(
        chaptersUrl: null,
        description: '0:00 New A<br>1:00 New B<br>2:00 New C',
      );
      check(await service.ensureChapters(episodeId)).isTrue();
      check(
        await storedTitles(episodeId),
      ).deepEquals(['New A', 'New B', 'New C']);

      await insertEpisode(chaptersUrl: null, description: 'No list now');
      check(await service.ensureChapters(episodeId)).isTrue();
      check(await storedTitles(episodeId)).isEmpty();
    });

    test(
      'dropping derived chapters keeps feed chapters stored meanwhile',
      () async {
        final repository = _InterleavingChapterRepository(
          datasource: chapterDatasource,
        );
        service = ChapterService(
          chapterRepository: repository,
          episodeRepository: EpisodeRepositoryImpl(
            datasource: episodeDatasource,
          ),
          dio: Dio()..httpClientAdapter = http,
          logger: Logger(level: Level.off),
          now: () => now,
        );
        final episodeId = await insertEpisode(
          chaptersUrl: null,
          description: notes,
        );
        await service.ensureChapters(episodeId);
        await insertEpisode(chaptersUrl: null, description: 'No list now');
        // Sync stores feed chapters after the description step has read the
        // derived ones (the second read; the JSON step reads first).
        repository
          ..readsBeforeHook = 2
          ..onRead = () => chapterDatasource.replaceChapters({
            episodeId: [pscChapter(episodeId, 'From psc')],
          }, source: ChapterSource.podlove);

        await service.ensureChapters(episodeId);

        check(await storedTitles(episodeId)).deepEquals(['From psc']);
      },
    );

    test('derives nothing from notes without a timestamp list', () async {
      final episodeId = await insertEpisode(
        chaptersUrl: null,
        description: 'Just talking at 12:30 today.',
      );

      check(await service.ensureChapters(episodeId)).isFalse();
      check(await storedTitles(episodeId)).isEmpty();
    });
  });
}
