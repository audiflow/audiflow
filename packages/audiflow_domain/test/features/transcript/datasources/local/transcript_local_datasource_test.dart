import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';

import '../../../../helpers/isar_test_helper.dart';

void main() {
  late Isar isar;
  late TranscriptLocalDatasource datasource;
  late int episodeId;

  setUpAll(() async {
    await Isar.initializeIsarCore(download: true);
  });

  setUp(() async {
    isar = await openTestIsar([
      SubscriptionSchema,
      EpisodeSchema,
      EpisodeTranscriptSchema,
      TranscriptSegmentSchema,
    ]);
    datasource = TranscriptLocalDatasource(isar);

    // Insert FK dependencies
    await isar.writeTxn(() async {
      final sub = Subscription()
        ..itunesId = 'test-1'
        ..feedUrl = 'https://example.com/feed.xml'
        ..title = 'Test'
        ..artistName = 'Test'
        ..subscribedAt = DateTime.now();
      await isar.subscriptions.put(sub);

      final ep = Episode()
        ..podcastId = sub.id
        ..guid = 'ep-1'
        ..title = 'Episode 1'
        ..audioUrl = 'https://example.com/ep1.mp3';
      await isar.episodes.put(ep);
      episodeId = ep.id;
    });
  });

  tearDown(() async {
    await isar.close(deleteFromDisk: true);
  });

  group('upsertMetas', () {
    test('should insert transcript metadata', () async {
      final metas = [
        EpisodeTranscript()
          ..episodeId = episodeId
          ..url = 'https://example.com/ep1.vtt'
          ..type = 'text/vtt'
          ..language = 'en'
          ..rel = 'captions',
      ];

      await datasource.upsertMetas(metas);

      final results = await datasource.getMetasByEpisodeId(episodeId);
      expect(results.length, equals(1));
      expect(results.first.url, equals('https://example.com/ep1.vtt'));
      expect(results.first.type, equals('text/vtt'));
    });

    test('should update on conflict (same episodeId + url)', () async {
      final meta = EpisodeTranscript()
        ..episodeId = episodeId
        ..url = 'https://example.com/ep1.vtt'
        ..type = 'text/vtt';

      await datasource.upsertMetas([meta]);
      await datasource.upsertMetas([
        EpisodeTranscript()
          ..episodeId = episodeId
          ..url = 'https://example.com/ep1.vtt'
          ..type = 'text/vtt',
      ]);

      final results = await datasource.getMetasByEpisodeId(episodeId);
      expect(results.length, equals(1));
    });
  });

  group('insertSegments / getSegments', () {
    late int transcriptId;

    setUp(() async {
      final transcript = EpisodeTranscript()
        ..episodeId = episodeId
        ..url = 'https://example.com/ep1.vtt'
        ..type = 'text/vtt';
      await datasource.upsertMetas([transcript]);
      final metas = await datasource.getMetasByEpisodeId(episodeId);
      transcriptId = metas.first.id;
    });

    test('should insert and query segments by time range', () async {
      final segments = [
        TranscriptSegment()
          ..transcriptId = transcriptId
          ..startMs = 0
          ..endMs = 5000
          ..body = 'First segment',
        TranscriptSegment()
          ..transcriptId = transcriptId
          ..startMs = 5000
          ..endMs = 10000
          ..body = 'Second segment',
        TranscriptSegment()
          ..transcriptId = transcriptId
          ..startMs = 10000
          ..endMs = 15000
          ..body = 'Third segment',
      ];

      await datasource.insertSegments(segments);

      final results = await datasource.getSegments(
        transcriptId,
        startMs: 4000,
        endMs: 10000,
      );

      expect(results.length, equals(2));
    });

    test('should return all segments ordered by startMs', () async {
      final segments = [
        TranscriptSegment()
          ..transcriptId = transcriptId
          ..startMs = 10000
          ..endMs = 15000
          ..body = 'Second',
        TranscriptSegment()
          ..transcriptId = transcriptId
          ..startMs = 0
          ..endMs = 5000
          ..body = 'First',
      ];

      await datasource.insertSegments(segments);

      final results = await datasource.getAllSegments(transcriptId);
      expect(results.length, equals(2));
      expect(results[0].body, equals('First'));
      expect(results[1].body, equals('Second'));
    });
  });

  group('markAsFetched', () {
    late int transcriptId;

    setUp(() async {
      final transcript = EpisodeTranscript()
        ..episodeId = episodeId
        ..url = 'https://example.com/ep1.vtt'
        ..type = 'text/vtt';
      await datasource.upsertMetas([transcript]);
      final metas = await datasource.getMetasByEpisodeId(episodeId);
      transcriptId = metas.first.id;
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
    late int transcriptId;

    setUp(() async {
      final transcript = EpisodeTranscript()
        ..episodeId = episodeId
        ..url = 'https://example.com/ep1.vtt'
        ..type = 'text/vtt';
      await datasource.upsertMetas([transcript]);
      final metas = await datasource.getMetasByEpisodeId(episodeId);
      transcriptId = metas.first.id;
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
    late int transcriptId;

    setUp(() async {
      final transcript = EpisodeTranscript()
        ..episodeId = episodeId
        ..url = 'https://example.com/ep1.vtt'
        ..type = 'text/vtt';
      await datasource.upsertMetas([transcript]);
      final metas = await datasource.getMetasByEpisodeId(episodeId);
      transcriptId = metas.first.id;
    });

    test('should delete all segments for a transcript', () async {
      await datasource.insertSegments([
        TranscriptSegment()
          ..transcriptId = transcriptId
          ..startMs = 0
          ..endMs = 5000
          ..body = 'Segment',
      ]);

      final deleted = await datasource.deleteSegments(transcriptId);
      expect(deleted, equals(1));

      final remaining = await datasource.getAllSegments(transcriptId);
      expect(remaining, isEmpty);
    });
  });
}
