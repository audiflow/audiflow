import 'package:audiflow_domain/src/common/database/app_database.dart';
import 'package:audiflow_domain/src/features/transcript/datasources/local/transcript_local_datasource.dart';
import 'package:audiflow_domain/src/features/transcript/repositories/transcript_repository.dart';
import 'package:audiflow_domain/src/features/transcript/repositories/transcript_repository_impl.dart';
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late TranscriptLocalDatasource datasource;
  late TranscriptRepository repository;
  late int episodeId;
  late int transcriptId;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    datasource = TranscriptLocalDatasource(db);
    repository = TranscriptRepositoryImpl(datasource: datasource);

    // Insert FK dependencies
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
    episodeId = await db
        .into(db.episodes)
        .insert(
          EpisodesCompanion.insert(
            podcastId: subId,
            guid: 'ep-1',
            title: 'Episode 1',
            audioUrl: 'https://example.com/ep1.mp3',
          ),
        );
  });

  tearDown(() async {
    await db.close();
  });

  group('getMetasByEpisodeId', () {
    test('returns empty list when no transcripts exist', () async {
      final results = await repository.getMetasByEpisodeId(episodeId);
      expect(results, isEmpty);
    });

    test('returns transcript metadata for an episode', () async {
      await repository.upsertMetas([
        EpisodeTranscriptsCompanion.insert(
          episodeId: episodeId,
          url: 'https://example.com/ep1.vtt',
          type: 'text/vtt',
          language: const Value('en'),
          rel: const Value('captions'),
        ),
      ]);

      final results = await repository.getMetasByEpisodeId(episodeId);
      expect(results.length, equals(1));
      expect(results.first.url, equals('https://example.com/ep1.vtt'));
      expect(results.first.type, equals('text/vtt'));
      expect(results.first.language, equals('en'));
    });
  });

  group('upsertMetas', () {
    test('inserts new transcript metadata', () async {
      await repository.upsertMetas([
        EpisodeTranscriptsCompanion.insert(
          episodeId: episodeId,
          url: 'https://example.com/ep1.srt',
          type: 'application/x-subrip',
        ),
      ]);

      final results = await repository.getMetasByEpisodeId(episodeId);
      expect(results.length, equals(1));
      expect(results.first.type, equals('application/x-subrip'));
    });

    test('updates on conflict (same episodeId + url)', () async {
      final companion = EpisodeTranscriptsCompanion.insert(
        episodeId: episodeId,
        url: 'https://example.com/ep1.vtt',
        type: 'text/vtt',
      );

      await repository.upsertMetas([companion]);
      await repository.upsertMetas([companion]);

      final results = await repository.getMetasByEpisodeId(episodeId);
      expect(results.length, equals(1));
    });
  });

  group('insertSegments / getAllSegments', () {
    setUp(() async {
      transcriptId = await db
          .into(db.episodeTranscripts)
          .insert(
            EpisodeTranscriptsCompanion.insert(
              episodeId: episodeId,
              url: 'https://example.com/ep1.vtt',
              type: 'text/vtt',
            ),
          );
    });

    test('inserts and retrieves all segments ordered by startMs', () async {
      await repository.insertSegments([
        TranscriptSegmentsCompanion.insert(
          transcriptId: transcriptId,
          startMs: 10000,
          endMs: 15000,
          body: 'Second',
        ),
        TranscriptSegmentsCompanion.insert(
          transcriptId: transcriptId,
          startMs: 0,
          endMs: 5000,
          body: 'First',
        ),
      ]);

      final results = await repository.getAllSegments(transcriptId);
      expect(results.length, equals(2));
      expect(results[0].body, equals('First'));
      expect(results[1].body, equals('Second'));
    });

    test('returns empty list when no segments exist', () async {
      final results = await repository.getAllSegments(transcriptId);
      expect(results, isEmpty);
    });
  });

  group('getSegments', () {
    setUp(() async {
      transcriptId = await db
          .into(db.episodeTranscripts)
          .insert(
            EpisodeTranscriptsCompanion.insert(
              episodeId: episodeId,
              url: 'https://example.com/ep1.vtt',
              type: 'text/vtt',
            ),
          );

      await repository.insertSegments([
        TranscriptSegmentsCompanion.insert(
          transcriptId: transcriptId,
          startMs: 0,
          endMs: 5000,
          body: 'First segment',
        ),
        TranscriptSegmentsCompanion.insert(
          transcriptId: transcriptId,
          startMs: 5000,
          endMs: 10000,
          body: 'Second segment',
        ),
        TranscriptSegmentsCompanion.insert(
          transcriptId: transcriptId,
          startMs: 10000,
          endMs: 15000,
          body: 'Third segment',
        ),
      ]);
    });

    test('returns segments overlapping time range', () async {
      final results = await repository.getSegments(
        transcriptId,
        startMs: 4000,
        endMs: 10000,
      );

      expect(results.length, equals(2));
      expect(results[0].body, equals('First segment'));
      expect(results[1].body, equals('Second segment'));
    });

    test('returns empty when range has no overlap', () async {
      final results = await repository.getSegments(
        transcriptId,
        startMs: 20000,
        endMs: 25000,
      );

      expect(results, isEmpty);
    });
  });

  group('markAsFetched / isContentFetched', () {
    setUp(() async {
      transcriptId = await db
          .into(db.episodeTranscripts)
          .insert(
            EpisodeTranscriptsCompanion.insert(
              episodeId: episodeId,
              url: 'https://example.com/ep1.vtt',
              type: 'text/vtt',
            ),
          );
    });

    test('returns false when not yet fetched', () async {
      expect(await repository.isContentFetched(transcriptId), isFalse);
    });

    test('returns true after marking as fetched', () async {
      await repository.markAsFetched(transcriptId);
      expect(await repository.isContentFetched(transcriptId), isTrue);
    });
  });

  group('deleteSegments', () {
    setUp(() async {
      transcriptId = await db
          .into(db.episodeTranscripts)
          .insert(
            EpisodeTranscriptsCompanion.insert(
              episodeId: episodeId,
              url: 'https://example.com/ep1.vtt',
              type: 'text/vtt',
            ),
          );
    });

    test('deletes all segments and returns count', () async {
      await repository.insertSegments([
        TranscriptSegmentsCompanion.insert(
          transcriptId: transcriptId,
          startMs: 0,
          endMs: 5000,
          body: 'Segment 1',
        ),
        TranscriptSegmentsCompanion.insert(
          transcriptId: transcriptId,
          startMs: 5000,
          endMs: 10000,
          body: 'Segment 2',
        ),
      ]);

      final deleted = await repository.deleteSegments(transcriptId);
      expect(deleted, equals(2));

      final remaining = await repository.getAllSegments(transcriptId);
      expect(remaining, isEmpty);
    });

    test('returns zero when no segments to delete', () async {
      final deleted = await repository.deleteSegments(transcriptId);
      expect(deleted, equals(0));
    });
  });
}
