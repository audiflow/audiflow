import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:audiflow_podcast/audiflow_podcast.dart';
import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';

import '../../../helpers/isar_test_helper.dart';

void main() {
  late Isar isar;
  late EpisodeLocalDatasource episodeDatasource;
  late TranscriptLocalDatasource transcriptDatasource;
  late ChapterLocalDatasource chapterDatasource;
  late EpisodeRepositoryImpl repository;
  late int podcastId;

  setUpAll(() async {
    await Isar.initializeIsarCore(download: true);
  });

  setUp(() async {
    isar = await openTestIsar([
      SubscriptionSchema,
      EpisodeSchema,
      EpisodeTranscriptSchema,
      TranscriptSegmentSchema,
      EpisodeChapterSchema,
    ]);
    episodeDatasource = EpisodeLocalDatasource(isar);
    transcriptDatasource = TranscriptLocalDatasource(isar);
    chapterDatasource = ChapterLocalDatasource(isar);
    repository = EpisodeRepositoryImpl(
      datasource: episodeDatasource,
      transcriptDatasource: transcriptDatasource,
      chapterDatasource: chapterDatasource,
    );

    // Insert FK dependency: a subscription
    final sub = Subscription()
      ..itunesId = 'test-1'
      ..feedUrl = 'https://example.com/feed.xml'
      ..title = 'Test Podcast'
      ..artistName = 'Test Artist'
      ..subscribedAt = DateTime.now();
    await isar.writeTxn(() => isar.subscriptions.put(sub));
    podcastId = sub.id;
  });

  tearDown(() async {
    await isar.close(deleteFromDisk: true);
  });

  PodcastItem makeItem({
    required String guid,
    required String title,
    required String enclosureUrl,
    List<PodcastTranscript>? transcripts,
    List<PodcastChapter>? chapters,
  }) {
    return PodcastItem.fromData(
      parsedAt: DateTime.now(),
      sourceUrl: '',
      title: title,
      description: 'desc',
      guid: guid,
      enclosureUrl: enclosureUrl,
      transcripts: transcripts,
      chapters: chapters,
    );
  }

  Episode makeEpisode({
    required String guid,
    required String title,
    required String audioUrl,
    DateTime? publishedAt,
    int? episodeNumber,
  }) {
    return Episode()
      ..podcastId = podcastId
      ..guid = guid
      ..title = title
      ..audioUrl = audioUrl
      ..publishedAt = publishedAt
      ..episodeNumber = episodeNumber;
  }

  group('upsertFromFeedItems', () {
    test('stores transcript metadata during feed sync', () async {
      final items = [
        makeItem(
          guid: 'ep-1',
          title: 'Episode 1',
          enclosureUrl: 'https://example.com/ep1.mp3',
          transcripts: [
            const PodcastTranscript(
              url: 'https://example.com/ep1.vtt',
              type: 'text/vtt',
              language: 'en',
              rel: 'captions',
            ),
            const PodcastTranscript(
              url: 'https://example.com/ep1.srt',
              type: 'application/srt',
            ),
          ],
        ),
      ];

      await repository.upsertFromFeedItems(podcastId, items);

      final episodes = await episodeDatasource.getByPodcastId(podcastId);
      expect(episodes.length, equals(1));

      final transcripts = await transcriptDatasource.getMetasByEpisodeId(
        episodes.first.id,
      );
      expect(transcripts.length, equals(2));

      final urls = transcripts.map((t) => t.url).toSet();
      expect(urls, contains('https://example.com/ep1.vtt'));
      expect(urls, contains('https://example.com/ep1.srt'));

      final vtt = transcripts.firstWhere(
        (t) => t.url == 'https://example.com/ep1.vtt',
      );
      expect(vtt.type, equals('text/vtt'));
      expect(vtt.language, equals('en'));
      expect(vtt.rel, equals('captions'));
    });

    test('stores chapter data during feed sync', () async {
      final items = [
        makeItem(
          guid: 'ep-2',
          title: 'Episode 2',
          enclosureUrl: 'https://example.com/ep2.mp3',
          chapters: [
            const PodcastChapter(
              title: 'Intro',
              startTime: Duration.zero,
              endTime: Duration(minutes: 5),
              url: 'https://example.com/intro',
            ),
            const PodcastChapter(
              title: 'Main Topic',
              startTime: Duration(minutes: 5),
              endTime: Duration(minutes: 30),
              imageUrl: 'https://example.com/topic.jpg',
            ),
            const PodcastChapter(
              title: 'Outro',
              startTime: Duration(minutes: 30),
            ),
          ],
        ),
      ];

      await repository.upsertFromFeedItems(podcastId, items);

      final episodes = await episodeDatasource.getByPodcastId(podcastId);
      expect(episodes.length, equals(1));

      final chapters = await chapterDatasource.getByEpisodeId(
        episodes.first.id,
      );
      expect(chapters.length, equals(3));

      expect(chapters[0].title, equals('Intro'));
      expect(chapters[0].startMs, equals(0));
      expect(chapters[0].endMs, equals(300000));
      expect(chapters[0].url, equals('https://example.com/intro'));
      expect(chapters[0].sortOrder, equals(0));

      expect(chapters[1].title, equals('Main Topic'));
      expect(chapters[1].startMs, equals(300000));
      expect(chapters[1].endMs, equals(1800000));
      expect(chapters[1].imageUrl, equals('https://example.com/topic.jpg'));
      expect(chapters[1].sortOrder, equals(1));

      expect(chapters[2].title, equals('Outro'));
      expect(chapters[2].startMs, equals(1800000));
      expect(chapters[2].endMs, isNull);
      expect(chapters[2].sortOrder, equals(2));
    });

    test('handles episodes with both transcripts and chapters', () async {
      final items = [
        makeItem(
          guid: 'ep-3',
          title: 'Episode 3',
          enclosureUrl: 'https://example.com/ep3.mp3',
          transcripts: [
            const PodcastTranscript(
              url: 'https://example.com/ep3.vtt',
              type: 'text/vtt',
            ),
          ],
          chapters: [
            const PodcastChapter(title: 'Chapter 1', startTime: Duration.zero),
          ],
        ),
      ];

      await repository.upsertFromFeedItems(podcastId, items);

      final episodes = await episodeDatasource.getByPodcastId(podcastId);
      final episodeId = episodes.first.id;

      final transcripts = await transcriptDatasource.getMetasByEpisodeId(
        episodeId,
      );
      expect(transcripts.length, equals(1));

      final chapters = await chapterDatasource.getByEpisodeId(episodeId);
      expect(chapters.length, equals(1));
    });

    test('skips transcript/chapter storage for items without them', () async {
      final items = [
        makeItem(
          guid: 'ep-plain',
          title: 'Plain Episode',
          enclosureUrl: 'https://example.com/plain.mp3',
        ),
      ];

      await repository.upsertFromFeedItems(podcastId, items);

      final episodes = await episodeDatasource.getByPodcastId(podcastId);
      expect(episodes.length, equals(1));

      final transcripts = await transcriptDatasource.getMetasByEpisodeId(
        episodes.first.id,
      );
      expect(transcripts, isEmpty);

      final chapters = await chapterDatasource.getByEpisodeId(
        episodes.first.id,
      );
      expect(chapters, isEmpty);
    });

    test('works without transcript/chapter datasources', () async {
      final basicRepo = EpisodeRepositoryImpl(datasource: episodeDatasource);
      final items = [
        makeItem(
          guid: 'ep-basic',
          title: 'Basic Episode',
          enclosureUrl: 'https://example.com/basic.mp3',
          transcripts: [
            const PodcastTranscript(
              url: 'https://example.com/basic.vtt',
              type: 'text/vtt',
            ),
          ],
        ),
      ];

      await basicRepo.upsertFromFeedItems(podcastId, items);

      final episodes = await episodeDatasource.getByPodcastId(podcastId);
      expect(episodes.length, equals(1));
    });

    test('upserts transcripts on re-sync', () async {
      final items = [
        makeItem(
          guid: 'ep-resync',
          title: 'Resync Episode',
          enclosureUrl: 'https://example.com/resync.mp3',
          transcripts: [
            const PodcastTranscript(
              url: 'https://example.com/resync.vtt',
              type: 'text/vtt',
            ),
          ],
        ),
      ];

      await repository.upsertFromFeedItems(podcastId, items);
      await repository.upsertFromFeedItems(podcastId, items);

      final episodes = await episodeDatasource.getByPodcastId(podcastId);
      expect(episodes.length, equals(1));

      final transcripts = await transcriptDatasource.getMetasByEpisodeId(
        episodes.first.id,
      );
      expect(transcripts.length, equals(1));
    });
  });

  group('getByPodcastId', () {
    test('returns empty list for unknown podcast', () async {
      final result = await repository.getByPodcastId(9999);
      expect(result, isEmpty);
    });
  });

  group('getById', () {
    test('returns episode by id', () async {
      final id = await episodeDatasource.upsert(
        makeEpisode(
          guid: 'find-me',
          title: 'Find Me',
          audioUrl: 'https://example.com/find.mp3',
        ),
      );

      final result = await repository.getById(id);
      expect(result, isNotNull);
      expect(result!.guid, equals('find-me'));
    });

    test('returns null for non-existent id', () async {
      final result = await repository.getById(9999);
      expect(result, isNull);
    });
  });

  group('getByAudioUrl', () {
    test('returns episode by audio URL', () async {
      await episodeDatasource.upsert(
        makeEpisode(
          guid: 'audio-url-ep',
          title: 'Audio URL Episode',
          audioUrl: 'https://example.com/unique-audio.mp3',
        ),
      );

      final result = await repository.getByAudioUrl(
        'https://example.com/unique-audio.mp3',
      );
      expect(result, isNotNull);
      expect(result!.guid, equals('audio-url-ep'));
    });

    test('returns null for non-existent audio URL', () async {
      final result = await repository.getByAudioUrl(
        'https://example.com/nonexistent.mp3',
      );
      expect(result, isNull);
    });
  });

  group('upsertEpisodes', () {
    test('inserts new episodes', () async {
      final episodes = [
        makeEpisode(
          guid: 'upsert-1',
          title: 'Upsert 1',
          audioUrl: 'https://example.com/u1.mp3',
        ),
        makeEpisode(
          guid: 'upsert-2',
          title: 'Upsert 2',
          audioUrl: 'https://example.com/u2.mp3',
        ),
      ];

      await repository.upsertEpisodes(episodes);

      final result = await repository.getByPodcastId(podcastId);
      expect(result.length, equals(2));
    });

    test('updates existing episodes on conflict', () async {
      await episodeDatasource.upsert(
        makeEpisode(
          guid: 'conflict-ep',
          title: 'Original',
          audioUrl: 'https://example.com/original.mp3',
        ),
      );

      await repository.upsertEpisodes([
        makeEpisode(
          guid: 'conflict-ep',
          title: 'Updated',
          audioUrl: 'https://example.com/updated.mp3',
        ),
      ]);

      final episodes = await repository.getByPodcastId(podcastId);
      expect(episodes.length, equals(1));
      expect(episodes.first.title, equals('Updated'));
    });
  });

  group('getGuidsByPodcastId', () {
    test('returns set of guids for podcast', () async {
      await repository.upsertEpisodes([
        makeEpisode(
          guid: 'guid-a',
          title: 'A',
          audioUrl: 'https://example.com/a.mp3',
        ),
        makeEpisode(
          guid: 'guid-b',
          title: 'B',
          audioUrl: 'https://example.com/b.mp3',
        ),
      ]);

      final guids = await repository.getGuidsByPodcastId(podcastId);
      expect(guids, equals({'guid-a', 'guid-b'}));
    });

    test('returns empty set for unknown podcast', () async {
      final guids = await repository.getGuidsByPodcastId(9999);
      expect(guids, isEmpty);
    });
  });

  group('getByIds', () {
    test('returns episodes matching given ids', () async {
      await episodeDatasource.upsert(
        makeEpisode(
          guid: 'ids-1',
          title: 'Ids 1',
          audioUrl: 'https://example.com/ids1.mp3',
        ),
      );
      await episodeDatasource.upsert(
        makeEpisode(
          guid: 'ids-2',
          title: 'Ids 2',
          audioUrl: 'https://example.com/ids2.mp3',
        ),
      );
      await episodeDatasource.upsert(
        makeEpisode(
          guid: 'ids-3',
          title: 'Ids 3',
          audioUrl: 'https://example.com/ids3.mp3',
        ),
      );

      final allEpisodes = await episodeDatasource.getByPodcastId(podcastId);
      final targetIds = allEpisodes.take(2).map((e) => e.id).toList();

      final result = await repository.getByIds(targetIds);
      expect(result.length, equals(2));
    });

    test('returns empty list for empty ids', () async {
      final result = await repository.getByIds([]);
      expect(result, isEmpty);
    });
  });

  group('getSubsequentEpisodes', () {
    test('returns episodes after given episode number', () async {
      for (var i = 1; 6 < i ? false : true; i++) {
        await episodeDatasource.upsert(
          makeEpisode(
            guid: 'seq-$i',
            title: 'Episode $i',
            audioUrl: 'https://example.com/seq$i.mp3',
            episodeNumber: i,
          ),
        );
      }

      final result = await repository.getSubsequentEpisodes(
        podcastId: podcastId,
        afterEpisodeNumber: 3,
        limit: 10,
      );

      expect(result.length, equals(3));
      expect(result.first.episodeNumber, equals(4));
    });

    test('returns from beginning when afterEpisodeNumber is null', () async {
      for (var i = 1; 4 < i ? false : true; i++) {
        await episodeDatasource.upsert(
          makeEpisode(
            guid: 'start-$i',
            title: 'Episode $i',
            audioUrl: 'https://example.com/start$i.mp3',
            episodeNumber: i,
          ),
        );
      }

      final result = await repository.getSubsequentEpisodes(
        podcastId: podcastId,
        afterEpisodeNumber: null,
        limit: 2,
      );

      expect(result.length, equals(2));
      expect(result.first.episodeNumber, equals(1));
      expect(result.last.episodeNumber, equals(2));
    });

    test('respects limit parameter', () async {
      for (var i = 1; 10 < i ? false : true; i++) {
        await episodeDatasource.upsert(
          makeEpisode(
            guid: 'limit-$i',
            title: 'Episode $i',
            audioUrl: 'https://example.com/limit$i.mp3',
            episodeNumber: i,
          ),
        );
      }

      final result = await repository.getSubsequentEpisodes(
        podcastId: podcastId,
        afterEpisodeNumber: 0,
        limit: 3,
      );

      expect(result.length, equals(3));
    });
  });

  group('getByPodcastIdAndGuid', () {
    test('returns episode when found', () async {
      final episode = Episode()
        ..podcastId = podcastId
        ..guid = 'test-guid-123'
        ..title = 'Test Episode'
        ..audioUrl = 'https://example.com/audio.mp3';
      await isar.writeTxn(() => isar.episodes.put(episode));

      final result = await repository.getByPodcastIdAndGuid(
        podcastId,
        'test-guid-123',
      );

      check(result).isNotNull();
      check(result!.guid).equals('test-guid-123');
      check(result.podcastId).equals(podcastId);
    });

    test('returns null when not found', () async {
      final result = await repository.getByPodcastIdAndGuid(999, 'nonexistent');
      check(result).isNull();
    });
  });

  group('watchByPodcastId', () {
    test('emits initial list', () async {
      await episodeDatasource.upsert(
        makeEpisode(
          guid: 'watch-1',
          title: 'Watch 1',
          audioUrl: 'https://example.com/watch1.mp3',
        ),
      );

      final stream = repository.watchByPodcastId(podcastId);
      final first = await stream.first;
      expect(first.length, equals(1));
      expect(first.first.guid, equals('watch-1'));
    });
  });

  group('storeTranscriptAndChapterDataFromParsed', () {
    Future<void> insertEpisode(String guid) async {
      await episodeDatasource.upsert(
        makeEpisode(
          guid: guid,
          title: 'Episode $guid',
          audioUrl: 'https://example.com/$guid.mp3',
        ),
      );
    }

    test('stores transcript metas from parsed data', () async {
      await insertEpisode('ep-parsed-1');

      final mediaMetas = [
        const ParsedEpisodeMediaMeta(
          guid: 'ep-parsed-1',
          transcripts: [
            ParsedTranscript(
              url: 'https://example.com/ep1.vtt',
              type: 'text/vtt',
              language: 'en',
              rel: 'captions',
            ),
          ],
        ),
      ];

      await repository.storeTranscriptAndChapterDataFromParsed(
        podcastId,
        mediaMetas,
      );

      final episodes = await episodeDatasource.getByPodcastId(podcastId);
      final transcripts = await transcriptDatasource.getMetasByEpisodeId(
        episodes.first.id,
      );
      expect(transcripts.length, equals(1));
      expect(transcripts.first.url, 'https://example.com/ep1.vtt');
      expect(transcripts.first.type, 'text/vtt');
      expect(transcripts.first.language, 'en');
      expect(transcripts.first.rel, 'captions');
    });

    test('stores chapter data from parsed data', () async {
      await insertEpisode('ep-parsed-2');

      final mediaMetas = [
        const ParsedEpisodeMediaMeta(
          guid: 'ep-parsed-2',
          chapters: [
            ParsedChapter(
              title: 'Intro',
              startTime: Duration.zero,
              url: 'https://example.com/intro',
            ),
            ParsedChapter(
              title: 'Main',
              startTime: Duration(minutes: 5),
              imageUrl: 'https://example.com/main.jpg',
            ),
          ],
        ),
      ];

      await repository.storeTranscriptAndChapterDataFromParsed(
        podcastId,
        mediaMetas,
      );

      final episodes = await episodeDatasource.getByPodcastId(podcastId);
      final chapters = await chapterDatasource.getByEpisodeId(
        episodes.first.id,
      );
      expect(chapters.length, equals(2));
      expect(chapters[0].title, 'Intro');
      expect(chapters[0].startMs, 0);
      expect(chapters[0].url, 'https://example.com/intro');
      expect(chapters[1].title, 'Main');
      expect(chapters[1].startMs, 300000);
      expect(chapters[1].imageUrl, 'https://example.com/main.jpg');
    });

    test('skips items without matching episodes', () async {
      final mediaMetas = [
        const ParsedEpisodeMediaMeta(
          guid: 'nonexistent-guid',
          transcripts: [
            ParsedTranscript(
              url: 'https://example.com/ghost.vtt',
              type: 'text/vtt',
            ),
          ],
        ),
      ];

      await repository.storeTranscriptAndChapterDataFromParsed(
        podcastId,
        mediaMetas,
      );
    });

    test('handles empty media metas list', () async {
      await repository.storeTranscriptAndChapterDataFromParsed(podcastId, []);
    });

    test('handles items with no transcript or chapter data', () async {
      await insertEpisode('ep-empty');

      final mediaMetas = [const ParsedEpisodeMediaMeta(guid: 'ep-empty')];

      await repository.storeTranscriptAndChapterDataFromParsed(
        podcastId,
        mediaMetas,
      );
    });
  });
}
