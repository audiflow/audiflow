import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';

import '../../../../helpers/isar_test_helper.dart';

void main() {
  late Isar isar;
  late TranscriptLocalDatasource datasource;
  late int episodeId;
  late int transcriptId;

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

      final transcript = EpisodeTranscript()
        ..episodeId = episodeId
        ..url = 'https://example.com/ep1.vtt'
        ..type = 'text/vtt';
      await isar.episodeTranscripts.put(transcript);
      transcriptId = transcript.id;
    });
  });

  tearDown(() async {
    await isar.close(deleteFromDisk: true);
  });

  group('transcript search', () {
    setUp(() async {
      await datasource.insertSegments([
        TranscriptSegment()
          ..transcriptId = transcriptId
          ..startMs = 0
          ..endMs = 5000
          ..body = 'Welcome to our podcast about Flutter development',
        TranscriptSegment()
          ..transcriptId = transcriptId
          ..startMs = 5000
          ..endMs = 10000
          ..body = 'Today we discuss state management with Riverpod',
        TranscriptSegment()
          ..transcriptId = transcriptId
          ..startMs = 10000
          ..endMs = 15000
          ..body = 'Dart is a great language for mobile development'
          ..speaker = 'Alice',
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
