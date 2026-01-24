import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late FeedParserService service;

  const testXml = '''
<?xml version="1.0" encoding="UTF-8"?>
<rss version="2.0" xmlns:itunes="http://www.itunes.com/dtds/podcast-1.0.dtd">
  <channel>
    <title>Test Podcast</title>
    <description>Test description</description>
    <item>
      <guid>new-episode</guid>
      <title>New Episode</title>
      <enclosure url="https://example.com/new.mp3" type="audio/mpeg"/>
    </item>
    <item>
      <guid>known-episode</guid>
      <title>Known Episode</title>
      <enclosure url="https://example.com/known.mp3" type="audio/mpeg"/>
    </item>
  </channel>
</rss>
''';

  setUp(() {
    service = FeedParserService();
  });

  tearDown(() {
    service.dispose();
  });

  group('parseWithProgress', () {
    test('emits progress events in correct order', () async {
      final events = <FeedParseProgress>[];
      final storedCompanions = <EpisodesCompanion>[];

      await for (final event in service.parseWithProgress(
        xmlContent: testXml,
        podcastId: 1,
        knownGuids: {},
        onBatchReady: (companions) async {
          storedCompanions.addAll(companions);
        },
      )) {
        events.add(event);
      }

      expect(events.first, isA<FeedMetaReady>());
      expect(events.last, isA<FeedParseComplete>());

      final complete = events.last as FeedParseComplete;
      expect(complete.total, 2);
      expect(storedCompanions, hasLength(2));
    });

    test('stops early when known GUID found', () async {
      final events = <FeedParseProgress>[];
      final storedCompanions = <EpisodesCompanion>[];

      await for (final event in service.parseWithProgress(
        xmlContent: testXml,
        podcastId: 1,
        knownGuids: {'known-episode'},
        onBatchReady: (companions) async {
          storedCompanions.addAll(companions);
        },
      )) {
        events.add(event);
      }

      final complete = events.last as FeedParseComplete;
      expect(complete.total, 1);
      expect(complete.stoppedEarly, isTrue);
      expect(storedCompanions, hasLength(1));
    });

    test('emits FeedMetaReady with podcast metadata', () async {
      final events = <FeedParseProgress>[];

      await for (final event in service.parseWithProgress(
        xmlContent: testXml,
        podcastId: 1,
        knownGuids: {},
        onBatchReady: (_) async {},
      )) {
        events.add(event);
      }

      final meta = events.whereType<FeedMetaReady>().first;
      expect(meta.title, 'Test Podcast');
      expect(meta.description, 'Test description');
    });
  });
}
