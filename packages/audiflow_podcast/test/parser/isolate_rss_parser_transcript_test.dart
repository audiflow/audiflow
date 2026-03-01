import 'package:audiflow_podcast/audiflow_podcast.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('IsolateRssParser - transcript extraction', () {
    const xmlWithTranscripts = '''
<?xml version="1.0" encoding="UTF-8"?>
<rss version="2.0"
  xmlns:itunes="http://www.itunes.com/dtds/podcast-1.0.dtd"
  xmlns:podcast="https://podcastindex.org/namespace/1.0"
  xmlns:psc="http://podlove.org/simple-chapters">
  <channel>
    <title>Transcript Test Podcast</title>
    <description>Testing transcript extraction</description>
    <item>
      <guid>ep-with-vtt</guid>
      <title>Episode with VTT</title>
      <description>Has VTT transcript</description>
      <enclosure url="https://example.com/ep1.mp3" type="audio/mpeg" length="1000"/>
      <podcast:transcript url="https://example.com/ep1.vtt" type="text/vtt" language="en" rel="captions"/>
    </item>
    <item>
      <guid>ep-with-multiple</guid>
      <title>Episode with Multiple Transcripts</title>
      <description>Has multiple transcript formats</description>
      <enclosure url="https://example.com/ep2.mp3" type="audio/mpeg" length="2000"/>
      <podcast:transcript url="https://example.com/ep2.srt" type="application/srt" rel="captions"/>
      <podcast:transcript url="https://example.com/ep2.vtt" type="text/vtt" language="en" rel="captions"/>
    </item>
    <item>
      <guid>ep-no-transcript</guid>
      <title>Episode without Transcript</title>
      <description>No transcript</description>
      <enclosure url="https://example.com/ep3.mp3" type="audio/mpeg" length="3000"/>
    </item>
  </channel>
</rss>
''';

    test('parses single transcript from episode', () async {
      final result = await IsolateRssParser.parseFeed(
        feedXml: xmlWithTranscripts,
      );

      final episode = result.episodes.firstWhere(
        (e) => e.guid == 'ep-with-vtt',
      );
      expect(episode.transcripts, isNotNull);
      expect(episode.transcripts, hasLength(1));
      expect(episode.transcripts!.first.url, 'https://example.com/ep1.vtt');
      expect(episode.transcripts!.first.type, 'text/vtt');
      expect(episode.transcripts!.first.language, 'en');
      expect(episode.transcripts!.first.rel, 'captions');
    });

    test('parses multiple transcripts from episode', () async {
      final result = await IsolateRssParser.parseFeed(
        feedXml: xmlWithTranscripts,
      );

      final episode = result.episodes.firstWhere(
        (e) => e.guid == 'ep-with-multiple',
      );
      expect(episode.transcripts, hasLength(2));
      expect(episode.transcripts![0].type, 'application/srt');
      expect(episode.transcripts![1].type, 'text/vtt');
    });

    test('returns null transcripts when episode has none', () async {
      final result = await IsolateRssParser.parseFeed(
        feedXml: xmlWithTranscripts,
      );

      final episode = result.episodes.firstWhere(
        (e) => e.guid == 'ep-no-transcript',
      );
      expect(episode.transcripts, isNull);
    });

    test('streams transcript data via parse()', () async {
      final episodes = <ParsedEpisode>[];

      await for (final event in IsolateRssParser.parse(
        feedXml: xmlWithTranscripts,
        knownGuids: {},
      )) {
        if (event is ParsedEpisode) episodes.add(event);
      }

      final withVtt = episodes.firstWhere((e) => e.guid == 'ep-with-vtt');
      expect(withVtt.transcripts, isNotNull);
      expect(withVtt.transcripts, hasLength(1));
    });
  });

  group('IsolateRssParser - chapter extraction', () {
    const xmlWithChapters = '''
<?xml version="1.0" encoding="UTF-8"?>
<rss version="2.0"
  xmlns:itunes="http://www.itunes.com/dtds/podcast-1.0.dtd"
  xmlns:podcast="https://podcastindex.org/namespace/1.0"
  xmlns:psc="http://podlove.org/simple-chapters">
  <channel>
    <title>Chapter Test Podcast</title>
    <description>Testing chapter extraction</description>
    <item>
      <guid>ep-with-chapters</guid>
      <title>Episode with Chapters</title>
      <description>Has PSC chapters</description>
      <enclosure url="https://example.com/ep1.mp3" type="audio/mpeg" length="1000"/>
      <psc:chapters>
        <psc:chapter start="00:00:00.000" title="Introduction"/>
        <psc:chapter start="00:05:30.000" title="Main Topic" href="https://example.com"/>
      </psc:chapters>
    </item>
    <item>
      <guid>ep-no-chapters</guid>
      <title>Episode without Chapters</title>
      <description>No chapters</description>
      <enclosure url="https://example.com/ep2.mp3" type="audio/mpeg" length="2000"/>
    </item>
  </channel>
</rss>
''';

    test('parses chapters from episode', () async {
      final result = await IsolateRssParser.parseFeed(
        feedXml: xmlWithChapters,
      );

      final episode = result.episodes.firstWhere(
        (e) => e.guid == 'ep-with-chapters',
      );
      expect(episode.chapters, isNotNull);
      expect(episode.chapters, hasLength(2));
      expect(episode.chapters![0].title, 'Introduction');
      expect(episode.chapters![0].startTime, Duration.zero);
      expect(episode.chapters![1].title, 'Main Topic');
      expect(
        episode.chapters![1].startTime,
        const Duration(minutes: 5, seconds: 30),
      );
      expect(episode.chapters![1].url, 'https://example.com');
    });

    test('returns null chapters when episode has none', () async {
      final result = await IsolateRssParser.parseFeed(
        feedXml: xmlWithChapters,
      );

      final episode = result.episodes.firstWhere(
        (e) => e.guid == 'ep-no-chapters',
      );
      expect(episode.chapters, isNull);
    });
  });
}
