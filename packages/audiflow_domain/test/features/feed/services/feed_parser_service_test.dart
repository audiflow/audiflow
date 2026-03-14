import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:audiflow_podcast/audiflow_podcast.dart'
    show TranscriptFileParser;
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

  const testXmlWithTranscripts = '''
<?xml version="1.0" encoding="UTF-8"?>
<rss version="2.0"
  xmlns:itunes="http://www.itunes.com/dtds/podcast-1.0.dtd"
  xmlns:podcast="https://podcastindex.org/namespace/1.0">
  <channel>
    <title>Podnews Daily</title>
    <description>Podcast news</description>
    <item>
      <guid>ep-with-vtt</guid>
      <title>Episode with VTT</title>
      <enclosure url="https://example.com/ep1.mp3" type="audio/mpeg"/>
      <podcast:transcript url="https://example.com/ep1.vtt" type="text/vtt" rel="captions"/>
    </item>
    <item>
      <guid>ep-no-transcript</guid>
      <title>Episode without Transcript</title>
      <enclosure url="https://example.com/ep2.mp3" type="audio/mpeg"/>
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
      final storedEpisodes = <Episode>[];

      await for (final event in service.parseWithProgress(
        xmlContent: testXml,
        podcastId: 1,
        knownGuids: {},
        onBatchReady: (episodes, _) async {
          storedEpisodes.addAll(episodes);
        },
      )) {
        events.add(event);
      }

      expect(events.first, isA<FeedMetaReady>());
      expect(events.last, isA<FeedParseComplete>());

      final complete = events.last as FeedParseComplete;
      expect(complete.total, 2);
      expect(storedEpisodes, hasLength(2));
    });

    test('stops early when known GUID found', () async {
      final events = <FeedParseProgress>[];
      final storedEpisodes = <Episode>[];

      await for (final event in service.parseWithProgress(
        xmlContent: testXml,
        podcastId: 1,
        knownGuids: {'known-episode'},
        onBatchReady: (episodes, _) async {
          storedEpisodes.addAll(episodes);
        },
      )) {
        events.add(event);
      }

      final complete = events.last as FeedParseComplete;
      expect(complete.total, 1);
      expect(complete.stoppedEarly, isTrue);
      expect(storedEpisodes, hasLength(1));
    });

    test('emits FeedMetaReady with podcast metadata', () async {
      final events = <FeedParseProgress>[];

      await for (final event in service.parseWithProgress(
        xmlContent: testXml,
        podcastId: 1,
        knownGuids: {},
        onBatchReady: (_, mediaMetas) async {},
      )) {
        events.add(event);
      }

      final meta = events.whereType<FeedMetaReady>().first;
      expect(meta.title, 'Test Podcast');
      expect(meta.description, 'Test description');
    });

    test('passes transcript media metas through onBatchReady', () async {
      final allMediaMetas = <ParsedEpisodeMediaMeta>[];

      await for (final _ in service.parseWithProgress(
        xmlContent: testXmlWithTranscripts,
        podcastId: 1,
        knownGuids: {},
        onBatchReady: (companions, mediaMetas) async {
          allMediaMetas.addAll(mediaMetas);
        },
      )) {}

      // Only ep-with-vtt has transcript data
      expect(allMediaMetas, hasLength(1));
      expect(allMediaMetas.first.guid, 'ep-with-vtt');
      expect(allMediaMetas.first.hasTranscripts, isTrue);
      expect(allMediaMetas.first.transcripts, hasLength(1));
      expect(allMediaMetas.first.transcripts!.first.type, 'text/vtt');
    });
  });

  group('parseFromString', () {
    test('maps transcript data to PodcastItem', () async {
      final result = await service.parseFromString(testXmlWithTranscripts);

      expect(result.episodes, hasLength(2));

      final withTranscript = result.episodes.firstWhere(
        (e) => e.guid == 'ep-with-vtt',
      );
      expect(withTranscript.hasTranscripts, isTrue);
      expect(withTranscript.transcripts, hasLength(1));
      expect(
        withTranscript.transcripts!.first.url,
        'https://example.com/ep1.vtt',
      );
      expect(withTranscript.transcripts!.first.type, 'text/vtt');
      expect(withTranscript.transcripts!.first.rel, 'captions');

      // Verify the type is supported by TranscriptFileParser
      expect(
        TranscriptFileParser.isSupported(
          withTranscript.transcripts!.first.type,
        ),
        isTrue,
      );

      final withoutTranscript = result.episodes.firstWhere(
        (e) => e.guid == 'ep-no-transcript',
      );
      expect(withoutTranscript.hasTranscripts, isFalse);
    });
  });
}
