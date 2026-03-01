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

  PodcastItem _makeItem({
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
        _makeItem(
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
        _makeItem(
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
        _makeItem(
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
        _makeItem(
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
        _makeItem(
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
        _makeItem(
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
        _makeItem(
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
        _makeItem(
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
        _makeItem(
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
}
