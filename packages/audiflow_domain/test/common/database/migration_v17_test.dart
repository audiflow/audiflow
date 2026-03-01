import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Migration v16 to v17', () {
    late AppDatabase db;

    setUp(() {
      db = AppDatabase.forTesting(NativeDatabase.memory());
    });

    tearDown(() async {
      await db.close();
    });

    test('should create transcript and chapter tables', () async {
      // Insert FK dependencies (subscription, then episode)
      final subId = await db
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

      final episodeId = await db
          .into(db.episodes)
          .insert(
            EpisodesCompanion.insert(
              podcastId: subId,
              guid: 'ep-1',
              title: 'Episode 1',
              audioUrl: 'https://example.com/ep1.mp3',
            ),
          );

      // Insert transcript metadata
      final transcriptId = await db
          .into(db.episodeTranscripts)
          .insert(
            EpisodeTranscriptsCompanion.insert(
              episodeId: episodeId,
              url: 'https://example.com/ep1.vtt',
              type: 'text/vtt',
            ),
          );
      expect(0 < transcriptId, isTrue);

      // Insert segment
      final segmentId = await db
          .into(db.transcriptSegments)
          .insert(
            TranscriptSegmentsCompanion.insert(
              transcriptId: transcriptId,
              startMs: 0,
              endMs: 5000,
              body: 'Hello world',
            ),
          );
      expect(0 < segmentId, isTrue);

      // Insert chapter
      final chapterId = await db
          .into(db.episodeChapters)
          .insert(
            EpisodeChaptersCompanion.insert(
              episodeId: episodeId,
              sortOrder: 0,
              title: 'Introduction',
              startMs: 0,
            ),
          );
      expect(0 < chapterId, isTrue);
    });

    test('should enforce unique key on transcript (episodeId, url)', () async {
      final subId = await db
          .into(db.subscriptions)
          .insert(
            SubscriptionsCompanion.insert(
              itunesId: 'test-2',
              feedUrl: 'https://example.com/feed2.xml',
              title: 'Test Podcast 2',
              artistName: 'Test Artist',
              subscribedAt: DateTime.now(),
            ),
          );

      final episodeId = await db
          .into(db.episodes)
          .insert(
            EpisodesCompanion.insert(
              podcastId: subId,
              guid: 'ep-2',
              title: 'Episode 2',
              audioUrl: 'https://example.com/ep2.mp3',
            ),
          );

      await db
          .into(db.episodeTranscripts)
          .insert(
            EpisodeTranscriptsCompanion.insert(
              episodeId: episodeId,
              url: 'https://example.com/ep2.vtt',
              type: 'text/vtt',
            ),
          );

      // Duplicate should fail
      expect(
        () => db
            .into(db.episodeTranscripts)
            .insert(
              EpisodeTranscriptsCompanion.insert(
                episodeId: episodeId,
                url: 'https://example.com/ep2.vtt',
                type: 'text/vtt',
              ),
            ),
        throwsA(isA<Exception>()),
      );
    });

    test(
      'should enforce unique key on chapter (episodeId, sortOrder)',
      () async {
        final subId = await db
            .into(db.subscriptions)
            .insert(
              SubscriptionsCompanion.insert(
                itunesId: 'test-3',
                feedUrl: 'https://example.com/feed3.xml',
                title: 'Test Podcast 3',
                artistName: 'Test Artist',
                subscribedAt: DateTime.now(),
              ),
            );

        final episodeId = await db
            .into(db.episodes)
            .insert(
              EpisodesCompanion.insert(
                podcastId: subId,
                guid: 'ep-3',
                title: 'Episode 3',
                audioUrl: 'https://example.com/ep3.mp3',
              ),
            );

        await db
            .into(db.episodeChapters)
            .insert(
              EpisodeChaptersCompanion.insert(
                episodeId: episodeId,
                sortOrder: 0,
                title: 'Chapter 1',
                startMs: 0,
              ),
            );

        // Duplicate should fail
        expect(
          () => db
              .into(db.episodeChapters)
              .insert(
                EpisodeChaptersCompanion.insert(
                  episodeId: episodeId,
                  sortOrder: 0,
                  title: 'Duplicate Chapter',
                  startMs: 0,
                ),
              ),
          throwsA(isA<Exception>()),
        );
      },
    );

    test('should store nullable fields on transcript', () async {
      final subId = await db
          .into(db.subscriptions)
          .insert(
            SubscriptionsCompanion.insert(
              itunesId: 'test-4',
              feedUrl: 'https://example.com/feed4.xml',
              title: 'Test Podcast 4',
              artistName: 'Test Artist',
              subscribedAt: DateTime.now(),
            ),
          );

      final episodeId = await db
          .into(db.episodes)
          .insert(
            EpisodesCompanion.insert(
              podcastId: subId,
              guid: 'ep-4',
              title: 'Episode 4',
              audioUrl: 'https://example.com/ep4.mp3',
            ),
          );

      final transcriptId = await db
          .into(db.episodeTranscripts)
          .insert(
            EpisodeTranscriptsCompanion.insert(
              episodeId: episodeId,
              url: 'https://example.com/ep4.srt',
              type: 'application/x-subrip',
              language: const Value('en'),
              rel: const Value('captions'),
            ),
          );

      final transcript = await (db.select(
        db.episodeTranscripts,
      )..where((t) => t.id.equals(transcriptId))).getSingle();

      expect(transcript.language, equals('en'));
      expect(transcript.rel, equals('captions'));
      expect(transcript.fetchedAt, isNull);
    });

    test('should store nullable fields on chapter', () async {
      final subId = await db
          .into(db.subscriptions)
          .insert(
            SubscriptionsCompanion.insert(
              itunesId: 'test-5',
              feedUrl: 'https://example.com/feed5.xml',
              title: 'Test Podcast 5',
              artistName: 'Test Artist',
              subscribedAt: DateTime.now(),
            ),
          );

      final episodeId = await db
          .into(db.episodes)
          .insert(
            EpisodesCompanion.insert(
              podcastId: subId,
              guid: 'ep-5',
              title: 'Episode 5',
              audioUrl: 'https://example.com/ep5.mp3',
            ),
          );

      final chapterId = await db
          .into(db.episodeChapters)
          .insert(
            EpisodeChaptersCompanion.insert(
              episodeId: episodeId,
              sortOrder: 0,
              title: 'Introduction',
              startMs: 0,
              endMs: const Value(30000),
              url: const Value('https://example.com/chapter-link'),
              imageUrl: const Value('https://example.com/chapter.jpg'),
            ),
          );

      final chapter = await (db.select(
        db.episodeChapters,
      )..where((c) => c.id.equals(chapterId))).getSingle();

      expect(chapter.endMs, equals(30000));
      expect(chapter.url, equals('https://example.com/chapter-link'));
      expect(chapter.imageUrl, equals('https://example.com/chapter.jpg'));
    });
  });
}
