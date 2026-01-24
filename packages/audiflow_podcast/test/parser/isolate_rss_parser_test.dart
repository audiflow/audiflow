import 'package:audiflow_podcast/audiflow_podcast.dart';
import 'package:test/test.dart';

void main() {
  group('IsolateRssParser', () {
    const testXml = '''
<?xml version="1.0" encoding="UTF-8"?>
<rss version="2.0" xmlns:itunes="http://www.itunes.com/dtds/podcast-1.0.dtd">
  <channel>
    <title>Test Podcast</title>
    <description>A test podcast description</description>
    <itunes:author>Test Author</itunes:author>
    <item>
      <guid>episode-3</guid>
      <title>Episode 3</title>
      <enclosure url="https://example.com/ep3.mp3" type="audio/mpeg" length="1000"/>
    </item>
    <item>
      <guid>episode-2</guid>
      <title>Episode 2</title>
      <enclosure url="https://example.com/ep2.mp3" type="audio/mpeg" length="1000"/>
    </item>
    <item>
      <guid>episode-1</guid>
      <title>Episode 1</title>
      <enclosure url="https://example.com/ep1.mp3" type="audio/mpeg" length="1000"/>
    </item>
  </channel>
</rss>
''';

    test('parses all episodes when no known GUIDs', () async {
      final progress = <ParseProgress>[];

      await for (final event in IsolateRssParser.parse(
        feedXml: testXml,
        knownGuids: {},
      )) {
        progress.add(event);
      }

      expect(progress.whereType<ParsedPodcastMeta>(), hasLength(1));
      expect(progress.whereType<ParsedEpisode>(), hasLength(3));
      expect(progress.whereType<ParseComplete>(), hasLength(1));

      final complete = progress.whereType<ParseComplete>().first;
      expect(complete.totalParsed, 3);
      expect(complete.stoppedEarly, isFalse);
    });

    test('stops early when known GUID encountered', () async {
      final progress = <ParseProgress>[];

      await for (final event in IsolateRssParser.parse(
        feedXml: testXml,
        knownGuids: {'episode-2'},
      )) {
        progress.add(event);
      }

      // Should have parsed episode-3, then stopped at episode-2
      final episodes = progress.whereType<ParsedEpisode>().toList();
      expect(episodes, hasLength(1));
      expect(episodes.first.guid, 'episode-3');

      final complete = progress.whereType<ParseComplete>().first;
      expect(complete.totalParsed, 1);
      expect(complete.stoppedEarly, isTrue);
    });

    test('stops at maxNewEpisodes limit', () async {
      final progress = <ParseProgress>[];

      await for (final event in IsolateRssParser.parse(
        feedXml: testXml,
        knownGuids: {},
        maxNewEpisodes: 2,
      )) {
        progress.add(event);
      }

      final episodes = progress.whereType<ParsedEpisode>().toList();
      expect(episodes, hasLength(2));

      final complete = progress.whereType<ParseComplete>().first;
      expect(complete.totalParsed, 2);
      expect(complete.stoppedEarly, isFalse);
    });

    test('emits metadata first', () async {
      final progress = <ParseProgress>[];

      await for (final event in IsolateRssParser.parse(
        feedXml: testXml,
        knownGuids: {},
      )) {
        progress.add(event);
      }

      expect(progress.first, isA<ParsedPodcastMeta>());
      final meta = progress.first as ParsedPodcastMeta;
      expect(meta.title, 'Test Podcast');
      expect(meta.author, 'Test Author');
    });
  });
}
