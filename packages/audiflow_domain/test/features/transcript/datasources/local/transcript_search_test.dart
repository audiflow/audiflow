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

  tearDown(() async {
    await db.close();
  });

  group('FTS5 transcript search', () {
    setUp(() async {
      await datasource.insertSegments([
        TranscriptSegmentsCompanion.insert(
          transcriptId: transcriptId,
          startMs: 0,
          endMs: 5000,
          body: 'Welcome to our podcast about Flutter development',
        ),
        TranscriptSegmentsCompanion.insert(
          transcriptId: transcriptId,
          startMs: 5000,
          endMs: 10000,
          body: 'Today we discuss state management with Riverpod',
        ),
        TranscriptSegmentsCompanion.insert(
          transcriptId: transcriptId,
          startMs: 10000,
          endMs: 15000,
          body: 'Dart is a great language for mobile development',
          speaker: const Value('Alice'),
        ),
      ]);
    });

    test('should find segments matching query', () async {
      final results = await datasource.search('Flutter');
      expect(results.length, equals(1));
      expect(results[0].body, contains('Flutter'));
      expect(results[0].episodeId, equals(episodeId));
    });

    test('should return empty for no match', () async {
      final results = await datasource.search('Python');
      expect(results, isEmpty);
    });

    test('should return empty for empty query', () async {
      final results = await datasource.search('');
      expect(results, isEmpty);
    });

    test('should include speaker info', () async {
      final results = await datasource.search('Dart');
      expect(results.length, equals(1));
      expect(results[0].speaker, equals('Alice'));
    });

    test('should match multiple segments', () async {
      final results = await datasource.search('development');
      expect(results.length, equals(2));
    });
  });
}
