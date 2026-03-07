import 'package:audiflow_domain/src/features/feed/models/feed_parse_progress.dart';
import 'package:audiflow_podcast/audiflow_podcast.dart';
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:audiflow_domain/src/common/database/app_database.dart';
import 'package:audiflow_domain/src/features/feed/datasources/local/episode_local_datasource.dart';
import 'package:audiflow_domain/src/features/feed/repositories/episode_repository_impl.dart';
import 'package:audiflow_domain/src/features/transcript/datasources/local/chapter_local_datasource.dart';
import 'package:audiflow_domain/src/features/transcript/datasources/local/transcript_local_datasource.dart';

void main() {
  late AppDatabase db;
  late EpisodeLocalDatasource episodeDatasource;
  late TranscriptLocalDatasource transcriptDatasource;
  late ChapterLocalDatasource chapterDatasource;
  late EpisodeRepositoryImpl repository;
  late int podcastId;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    episodeDatasource = EpisodeLocalDatasource(db);
    transcriptDatasource = TranscriptLocalDatasource(db);
    chapterDatasource = ChapterLocalDatasource(db);
    repository = EpisodeRepositoryImpl(
      datasource: episodeDatasource,
      transcriptDatasource: transcriptDatasource,
      chapterDatasource: chapterDatasource,
    );

    // Insert FK dependency: a subscription to serve as podcast
    podcastId = await db
        .into(db.subscriptions)
        .insert(
          SubscriptionsCompanion.insert(
            itunesId: 'test-1',
            feedUrl: 'https://example.com/feed.xml',
            title: 'Test Podcast',
            artistName: 'Test Artist',
            subscribedAt: DateTime.now(),
          ),
        );
  });

  tearDown(() async {
    await db.close();
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

      // Verify episode was stored
      final episodes = await episodeDatasource.getByPodcastId(podcastId);
      expect(episodes.length, equals(1));

      // Verify transcripts were stored
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

      final srt = transcripts.firstWhere(
        (t) => t.url == 'https://example.com/ep1.srt',
      );
      expect(srt.type, equals('application/srt'));
      expect(srt.language, isNull);
      expect(srt.rel, isNull);
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

      // Chapters should be ordered by startMs
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

    test('handles mixed items with and without transcript data', () async {
      final items = [
        makeItem(
          guid: 'ep-with',
          title: 'With Transcripts',
          enclosureUrl: 'https://example.com/with.mp3',
          transcripts: [
            const PodcastTranscript(
              url: 'https://example.com/with.vtt',
              type: 'text/vtt',
            ),
          ],
        ),
        makeItem(
          guid: 'ep-without',
          title: 'Without Transcripts',
          enclosureUrl: 'https://example.com/without.mp3',
        ),
      ];

      await repository.upsertFromFeedItems(podcastId, items);

      final episodes = await episodeDatasource.getByPodcastId(podcastId);
      expect(episodes.length, equals(2));

      // Find episode with transcript
      final withTranscript = episodes.firstWhere((e) => e.guid == 'ep-with');
      final transcripts = await transcriptDatasource.getMetasByEpisodeId(
        withTranscript.id,
      );
      expect(transcripts.length, equals(1));

      // Episode without transcript should have none
      final withoutTranscript = episodes.firstWhere(
        (e) => e.guid == 'ep-without',
      );
      final noTranscripts = await transcriptDatasource.getMetasByEpisodeId(
        withoutTranscript.id,
      );
      expect(noTranscripts, isEmpty);
    });

    test('works without transcript/chapter datasources', () async {
      // Create repository without optional datasources
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

      // Should not throw even with transcript data present
      await basicRepo.upsertFromFeedItems(podcastId, items);

      final episodes = await episodeDatasource.getByPodcastId(podcastId);
      expect(episodes.length, equals(1));
    });

    test('skips items without guid', () async {
      final items = [
        makeItem(
          guid: 'valid-guid',
          title: 'Valid',
          enclosureUrl: 'https://example.com/valid.mp3',
          transcripts: [
            const PodcastTranscript(
              url: 'https://example.com/valid.vtt',
              type: 'text/vtt',
            ),
          ],
        ),
      ];

      await repository.upsertFromFeedItems(podcastId, items);

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

      // First sync
      await repository.upsertFromFeedItems(podcastId, items);

      // Second sync (same data)
      await repository.upsertFromFeedItems(podcastId, items);

      final episodes = await episodeDatasource.getByPodcastId(podcastId);
      expect(episodes.length, equals(1));

      // Should still have exactly 1 transcript (upserted, not duplicated)
      final transcripts = await transcriptDatasource.getMetasByEpisodeId(
        episodes.first.id,
      );
      expect(transcripts.length, equals(1));
    });
  });

  group('getByPodcastId', () {
    test('returns episodes ordered by publish date descending', () async {
      final items = [
        makeItem(
          guid: 'ep-old',
          title: 'Old Episode',
          enclosureUrl: 'https://example.com/old.mp3',
        ),
        makeItem(
          guid: 'ep-new',
          title: 'New Episode',
          enclosureUrl: 'https://example.com/new.mp3',
        ),
      ];

      await repository.upsertFromFeedItems(podcastId, items);

      // Set distinct publish dates
      final episodes = await episodeDatasource.getByPodcastId(podcastId);
      for (final ep in episodes) {
        final date = ep.guid == 'ep-old'
            ? DateTime(2023, 1, 1)
            : DateTime(2024, 1, 1);
        await db
            .into(db.episodes)
            .insertOnConflictUpdate(
              EpisodesCompanion(
                id: Value(ep.id),
                podcastId: Value(podcastId),
                guid: Value(ep.guid),
                title: Value(ep.title),
                audioUrl: Value(ep.audioUrl),
                publishedAt: Value(date),
              ),
            );
      }

      final result = await repository.getByPodcastId(podcastId);
      expect(result.length, equals(2));
      // Newest first
      expect(result.first.guid, equals('ep-new'));
      expect(result.last.guid, equals('ep-old'));
    });

    test('returns empty list for unknown podcast', () async {
      final result = await repository.getByPodcastId(9999);
      expect(result, isEmpty);
    });
  });

  group('getById', () {
    test('returns episode by id', () async {
      await episodeDatasource.upsert(
        EpisodesCompanion.insert(
          podcastId: podcastId,
          guid: 'find-me',
          title: 'Find Me',
          audioUrl: 'https://example.com/find.mp3',
        ),
      );

      final episodes = await episodeDatasource.getByPodcastId(podcastId);
      final id = episodes.first.id;

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
        EpisodesCompanion.insert(
          podcastId: podcastId,
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
    test('inserts new episodes via companion list', () async {
      final companions = [
        EpisodesCompanion.insert(
          podcastId: podcastId,
          guid: 'upsert-1',
          title: 'Upsert 1',
          audioUrl: 'https://example.com/u1.mp3',
        ),
        EpisodesCompanion.insert(
          podcastId: podcastId,
          guid: 'upsert-2',
          title: 'Upsert 2',
          audioUrl: 'https://example.com/u2.mp3',
        ),
      ];

      await repository.upsertEpisodes(companions);

      final episodes = await repository.getByPodcastId(podcastId);
      expect(episodes.length, equals(2));
    });

    test('updates existing episodes on conflict', () async {
      await episodeDatasource.upsert(
        EpisodesCompanion.insert(
          podcastId: podcastId,
          guid: 'conflict-ep',
          title: 'Original',
          audioUrl: 'https://example.com/original.mp3',
        ),
      );

      final companions = [
        EpisodesCompanion.insert(
          podcastId: podcastId,
          guid: 'conflict-ep',
          title: 'Updated',
          audioUrl: 'https://example.com/updated.mp3',
        ),
      ];

      await repository.upsertEpisodes(companions);

      final episodes = await repository.getByPodcastId(podcastId);
      expect(episodes.length, equals(1));
      expect(episodes.first.title, equals('Updated'));
    });
  });

  group('getGuidsByPodcastId', () {
    test('returns set of guids for podcast', () async {
      final companions = [
        EpisodesCompanion.insert(
          podcastId: podcastId,
          guid: 'guid-a',
          title: 'A',
          audioUrl: 'https://example.com/a.mp3',
        ),
        EpisodesCompanion.insert(
          podcastId: podcastId,
          guid: 'guid-b',
          title: 'B',
          audioUrl: 'https://example.com/b.mp3',
        ),
      ];

      await repository.upsertEpisodes(companions);

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
        EpisodesCompanion.insert(
          podcastId: podcastId,
          guid: 'ids-1',
          title: 'Ids 1',
          audioUrl: 'https://example.com/ids1.mp3',
        ),
      );
      await episodeDatasource.upsert(
        EpisodesCompanion.insert(
          podcastId: podcastId,
          guid: 'ids-2',
          title: 'Ids 2',
          audioUrl: 'https://example.com/ids2.mp3',
        ),
      );
      await episodeDatasource.upsert(
        EpisodesCompanion.insert(
          podcastId: podcastId,
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
          EpisodesCompanion.insert(
            podcastId: podcastId,
            guid: 'seq-$i',
            title: 'Episode $i',
            audioUrl: 'https://example.com/seq$i.mp3',
            episodeNumber: Value(i),
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
          EpisodesCompanion.insert(
            podcastId: podcastId,
            guid: 'start-$i',
            title: 'Episode $i',
            audioUrl: 'https://example.com/start$i.mp3',
            episodeNumber: Value(i),
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
          EpisodesCompanion.insert(
            podcastId: podcastId,
            guid: 'limit-$i',
            title: 'Episode $i',
            audioUrl: 'https://example.com/limit$i.mp3',
            episodeNumber: Value(i),
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

  group('watchByPodcastId', () {
    test('emits initial list and updates', () async {
      await episodeDatasource.upsert(
        EpisodesCompanion.insert(
          podcastId: podcastId,
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
        EpisodesCompanion.insert(
          podcastId: podcastId,
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

      // Should not throw
      await repository.storeTranscriptAndChapterDataFromParsed(
        podcastId,
        mediaMetas,
      );
    });

    test('handles empty media metas list', () async {
      // Should not throw
      await repository.storeTranscriptAndChapterDataFromParsed(podcastId, []);
    });

    test('handles items with no transcript or chapter data', () async {
      await insertEpisode('ep-empty');

      final mediaMetas = [const ParsedEpisodeMediaMeta(guid: 'ep-empty')];

      // Should not throw
      await repository.storeTranscriptAndChapterDataFromParsed(
        podcastId,
        mediaMetas,
      );
    });
  });
}
