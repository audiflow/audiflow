import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';
import 'package:logger/logger.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import '../../../helpers/isar_test_helper.dart';
@GenerateMocks([Dio])
import 'chapter_service_test.mocks.dart';

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
  late MockDio mockDio;
  late DateTime now;
  late ChapterService service;

  setUpAll(() async {
    await Isar.initializeIsarCore(download: true);
  });

  setUp(() async {
    isar = await openTestIsar([EpisodeSchema, EpisodeChapterSchema]);
    chapterDatasource = ChapterLocalDatasource(isar);
    episodeDatasource = EpisodeLocalDatasource(isar);
    mockDio = MockDio();
    now = DateTime(2026, 1, 1);
    service = ChapterService(
      chapterRepository: ChapterRepositoryImpl(datasource: chapterDatasource),
      episodeRepository: EpisodeRepositoryImpl(datasource: episodeDatasource),
      dio: mockDio,
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
    when(mockDio.get<String>(any, options: anyNamed('options'))).thenAnswer(
      (_) async => Response(
        data: body,
        statusCode: 200,
        requestOptions: RequestOptions(path: _chaptersUrl),
      ),
    );
  }

  void failWith(DioExceptionType type) {
    when(mockDio.get<String>(any, options: anyNamed('options'))).thenThrow(
      DioException(
        type: type,
        requestOptions: RequestOptions(path: ''),
      ),
    );
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

      expect(changed, isTrue);
      final chapters = await chapterDatasource.getByEpisodeId(episodeId);
      expect(chapters.map((c) => c.title), ['Intro', 'Topic']);
      expect(chapters[1].startMs, 60000);
      expect(chapters[1].imageUrl, 'https://example.com/t.jpg');
      expect(
        chapters.map((c) => c.source),
        everyElement(ChapterSource.podcastChaptersJson),
      );
    });

    test('replaces stored psc chapters', () async {
      final episodeId = await insertEpisode();
      await chapterDatasource.replaceChapters({
        episodeId: [pscChapter(episodeId, 'From psc')],
      }, source: ChapterSource.podlove);
      respondWith(_validJson);

      await service.ensureChapters(episodeId);

      expect(await storedTitles(episodeId), ['Intro', 'Topic']);
    });

    test('does not fetch again once JSON chapters are stored', () async {
      final episodeId = await insertEpisode();
      respondWith(_validJson);
      await service.ensureChapters(episodeId);

      final changed = await service.ensureChapters(episodeId);

      expect(changed, isFalse);
      verify(mockDio.get<String>(any, options: anyNamed('options'))).called(1);
    });

    test('fetches again when the chapters URL changes', () async {
      final episodeId = await insertEpisode();
      respondWith(_validJson);
      await service.ensureChapters(episodeId);

      await insertEpisode(chaptersUrl: 'https://example.com/ep1/v2.json');
      respondWith('{"chapters": [{"startTime": 0, "title": "Revised"}]}');

      expect(await service.ensureChapters(episodeId), isTrue);
      expect(await storedTitles(episodeId), ['Revised']);
      final stored = await chapterDatasource.getByEpisodeId(episodeId);
      expect(stored.single.sourceUrl, 'https://example.com/ep1/v2.json');
    });

    test('drops JSON chapters once the feed removes the link', () async {
      final episodeId = await insertEpisode();
      respondWith(_validJson);
      await service.ensureChapters(episodeId);

      await insertEpisode(chaptersUrl: null);

      expect(await service.ensureChapters(episodeId), isTrue);
      expect(await storedTitles(episodeId), isEmpty);
    });

    test('keeps psc chapters when there is no link', () async {
      final episodeId = await insertEpisode(chaptersUrl: null);
      await chapterDatasource.replaceChapters({
        episodeId: [pscChapter(episodeId, 'From psc')],
      }, source: ChapterSource.podlove);

      expect(await service.ensureChapters(episodeId), isFalse);
      expect(await storedTitles(episodeId), ['From psc']);
    });

    test('does nothing without a chapters link', () async {
      final episodeId = await insertEpisode(chaptersUrl: null);

      expect(await service.ensureChapters(episodeId), isFalse);
      verifyNever(mockDio.get<String>(any, options: anyNamed('options')));
    });

    test('ignores non-JSON chapters types', () async {
      final episodeId = await insertEpisode(chaptersType: 'text/plain');

      expect(await service.ensureChapters(episodeId), isFalse);
      verifyNever(mockDio.get<String>(any, options: anyNamed('options')));
    });

    test('returns false for an unknown episode', () async {
      expect(await service.ensureChapters(999), isFalse);
    });

    test('network failure keeps stored chapters and does not throw', () async {
      final episodeId = await insertEpisode();
      await chapterDatasource.replaceChapters({
        episodeId: [pscChapter(episodeId, 'From psc')],
      }, source: ChapterSource.podlove);
      failWith(DioExceptionType.connectionError);

      expect(await service.ensureChapters(episodeId), isFalse);
      expect(await storedTitles(episodeId), ['From psc']);
    });

    test('malformed JSON leaves the episode without chapters', () async {
      final episodeId = await insertEpisode();
      respondWith('{"chapters": [');

      expect(await service.ensureChapters(episodeId), isFalse);
      expect(await storedTitles(episodeId), isEmpty);
    });

    test('JSON without usable chapters stores nothing', () async {
      final episodeId = await insertEpisode();
      respondWith('{"version": "1.2.0", "chapters": [{"startTime": 0}]}');

      expect(await service.ensureChapters(episodeId), isFalse);
      expect(await storedTitles(episodeId), isEmpty);
    });

    test('retries a failed URL only after the cooldown', () async {
      final episodeId = await insertEpisode();
      failWith(DioExceptionType.connectionTimeout);
      await service.ensureChapters(episodeId);

      now = now.add(const Duration(minutes: 1));
      await service.ensureChapters(episodeId);
      verify(mockDio.get<String>(any, options: anyNamed('options'))).called(1);

      now = now.add(ChapterService.retryCooldown);
      respondWith(_validJson);
      expect(await service.ensureChapters(episodeId), isTrue);
    });

    test('concurrent calls share one fetch', () async {
      final episodeId = await insertEpisode();
      respondWith(_validJson);

      final results = await Future.wait([
        service.ensureChapters(episodeId),
        service.ensureChapters(episodeId),
      ]);

      expect(results, [isTrue, isTrue]);
      verify(mockDio.get<String>(any, options: anyNamed('options'))).called(1);
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

      expect(await service.ensureChapters(episodeId), isTrue);
      final chapters = await chapterDatasource.getByEpisodeId(episodeId);
      expect(chapters.map((c) => c.title), ['オープニング', '人生の選択', 'イベント']);
      expect(
        chapters.map((c) => c.source),
        everyElement(ChapterSource.description),
      );
      expect(await service.ensureChapters(episodeId), isFalse);
    });

    test('leaves feed chapters alone', () async {
      final episodeId = await insertEpisode(
        chaptersUrl: null,
        description: notes,
      );
      await chapterDatasource.replaceChapters({
        episodeId: [pscChapter(episodeId, 'From psc')],
      }, source: ChapterSource.podlove);

      expect(await service.ensureChapters(episodeId), isFalse);
      expect(await storedTitles(episodeId), ['From psc']);
    });

    test('falls back to notes when JSON fails, JSON wins later', () async {
      final episodeId = await insertEpisode(description: notes);
      failWith(DioExceptionType.connectionError);

      await service.ensureChapters(episodeId);
      expect(await storedTitles(episodeId), ['オープニング', '人生の選択', 'イベント']);

      now = now.add(ChapterService.retryCooldown);
      respondWith(_validJson);
      await service.ensureChapters(episodeId);
      expect(await storedTitles(episodeId), ['Intro', 'Topic']);
    });

    test('derives nothing from notes without a timestamp list', () async {
      final episodeId = await insertEpisode(
        chaptersUrl: null,
        description: 'Just talking at 12:30 today.',
      );

      expect(await service.ensureChapters(episodeId), isFalse);
      expect(await storedTitles(episodeId), isEmpty);
    });
  });
}
