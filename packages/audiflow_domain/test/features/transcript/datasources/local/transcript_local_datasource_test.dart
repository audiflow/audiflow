import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:audiflow_domain/src/common/database/app_database.dart';
import 'package:audiflow_domain/src/features/transcript/datasources/local/transcript_local_datasource.dart';

void main() {
  late AppDatabase db;
  late TranscriptLocalDatasource datasource;
  late int episodeId;
  late int transcriptId;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    datasource = TranscriptLocalDatasource(db);

    // Insert FK dependencies
    final subId = await db
        .into(db.subscriptions)
        .insert(
          SubscriptionsCompanion.insert(
            itunesId: 'test-1',
            feedUrl: 'https://example.com/feed.xml',
            title: 'Test',
            artistName: 'Test',
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

  group('upsertMetas', () {
    test('should insert transcript metadata', () async {
      final companions = [
        EpisodeTranscriptsCompanion.insert(
          episodeId: episodeId,
          url: 'https://example.com/ep1.vtt',
          type: 'text/vtt',
          language: const Value('en'),
          rel: const Value('captions'),
        ),
      ];

      await datasource.upsertMetas(companions);

      final results = await datasource.getMetasByEpisodeId(episodeId);
      expect(results.length, equals(1));
      expect(results.first.url, equals('https://example.com/ep1.vtt'));
      expect(results.first.type, equals('text/vtt'));
    });

    test('should update on conflict (same episodeId + url)', () async {
      final companion = EpisodeTranscriptsCompanion.insert(
        episodeId: episodeId,
        url: 'https://example.com/ep1.vtt',
        type: 'text/vtt',
      );

      await datasource.upsertMetas([companion]);
      await datasource.upsertMetas([companion]);

      final results = await datasource.getMetasByEpisodeId(episodeId);
      expect(results.length, equals(1));
    });
  });

  group('insertSegments / getSegments', () {
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

    test('should insert and query segments by time range', () async {
      final segments = [
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
      ];

      await datasource.insertSegments(segments);

      // Query range that overlaps segments 1 and 2 only
      final results = await datasource.getSegments(
        transcriptId,
        startMs: 4000,
        endMs: 10000,
      );

      expect(results.length, equals(2));
    });

    test('should return all segments ordered by startMs', () async {
      final segments = [
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
      ];

      await datasource.insertSegments(segments);

      final results = await datasource.getAllSegments(transcriptId);
      expect(results.length, equals(2));
      expect(results[0].body, equals('First'));
      expect(results[1].body, equals('Second'));
    });
  });

  group('markAsFetched', () {
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

    test('should set fetchedAt timestamp', () async {
      expect(
        (await datasource.getMetasByEpisodeId(episodeId)).first.fetchedAt,
        isNull,
      );

      await datasource.markAsFetched(transcriptId);

      final result = (await datasource.getMetasByEpisodeId(episodeId)).first;
      expect(result.fetchedAt, isNotNull);
    });
  });

  group('isContentFetched', () {
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

    test('should return false when not fetched', () async {
      expect(await datasource.isContentFetched(transcriptId), isFalse);
    });

    test('should return true after marking as fetched', () async {
      await datasource.markAsFetched(transcriptId);
      expect(await datasource.isContentFetched(transcriptId), isTrue);
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

    test('should delete all segments for a transcript', () async {
      await datasource.insertSegments([
        TranscriptSegmentsCompanion.insert(
          transcriptId: transcriptId,
          startMs: 0,
          endMs: 5000,
          body: 'Segment',
        ),
      ]);

      final deleted = await datasource.deleteSegments(transcriptId);
      expect(deleted, equals(1));

      final remaining = await datasource.getAllSegments(transcriptId);
      expect(remaining, isEmpty);
    });
  });
}
