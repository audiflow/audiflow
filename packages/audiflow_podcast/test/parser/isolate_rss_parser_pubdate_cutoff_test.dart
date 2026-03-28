import 'package:audiflow_podcast/audiflow_podcast.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('IsolateRssParser pubDate-based early-stop', () {
    // Feed with pubDates in descending chronological order (newest first).
    const testXml = '''
<?xml version="1.0" encoding="UTF-8"?>
<rss version="2.0" xmlns:itunes="http://www.itunes.com/dtds/podcast-1.0.dtd">
  <channel>
    <title>Test Podcast</title>
    <description>A test podcast</description>
    <item>
      <guid>ep-3</guid>
      <title>Episode 3</title>
      <pubDate>Sat, 15 Mar 2026 10:00:00 GMT</pubDate>
      <enclosure url="https://example.com/ep3.mp3" type="audio/mpeg" length="1000"/>
    </item>
    <item>
      <guid>ep-2</guid>
      <title>Episode 2</title>
      <pubDate>Fri, 14 Mar 2026 10:00:00 GMT</pubDate>
      <enclosure url="https://example.com/ep2.mp3" type="audio/mpeg" length="1000"/>
    </item>
    <item>
      <guid>ep-1</guid>
      <title>Episode 1</title>
      <pubDate>Thu, 13 Mar 2026 10:00:00 GMT</pubDate>
      <enclosure url="https://example.com/ep1.mp3" type="audio/mpeg" length="1000"/>
    </item>
  </channel>
</rss>
''';

    test('stops at pubDate cutoff when no knownNewestGuid given', () async {
      // Cutoff is ep-2's pubDate -- should parse ep-3, then stop at ep-2.
      final cutoff = DateTime.utc(2026, 3, 14, 10);

      final result = await IsolateRssParser.parseFeed(
        feedXml: testXml,
        knownNewestPubDate: cutoff,
      );

      expect(result.episodes, hasLength(1));
      expect(result.episodes.first.guid, 'ep-3');
      expect(result.stoppedEarly, isTrue);
    });

    test('stops when pubDate matches cutoff exactly', () async {
      // Cutoff equals ep-2's pubDate exactly.
      final cutoff = DateTime.utc(2026, 3, 14, 10);

      final result = await IsolateRssParser.parseFeed(
        feedXml: testXml,
        knownNewestPubDate: cutoff,
      );

      expect(result.stoppedEarly, isTrue);
      expect(result.episodes, hasLength(1));
    });

    test('stops when pubDate+GUID both match', () async {
      final cutoff = DateTime.utc(2026, 3, 14, 10);

      final result = await IsolateRssParser.parseFeed(
        feedXml: testXml,
        knownNewestPubDate: cutoff,
        knownNewestGuid: 'ep-2',
      );

      expect(result.stoppedEarly, isTrue);
      expect(result.episodes, hasLength(1));
      expect(result.episodes.first.guid, 'ep-3');
    });

    test('continues past pubDate match when GUID does not match', () async {
      // Cutoff date matches ep-2 but GUID is wrong -- should NOT stop at ep-2.
      final cutoff = DateTime.utc(2026, 3, 14, 10);

      final result = await IsolateRssParser.parseFeed(
        feedXml: testXml,
        knownNewestPubDate: cutoff,
        knownNewestGuid: 'does-not-exist',
      );

      // ep-2 pubDate matches but GUID mismatch, so parsing continues.
      // ep-1 pubDate is before cutoff but GUID still mismatches, continues.
      // Reaches end of feed.
      expect(result.stoppedEarly, isFalse);
      expect(result.episodes, hasLength(3));
    });

    test('parses all episodes when cutoff is before all pubDates', () async {
      // Cutoff older than all episodes -- no early stop.
      final cutoff = DateTime.utc(2020);

      final result = await IsolateRssParser.parseFeed(
        feedXml: testXml,
        knownNewestPubDate: cutoff,
      );

      expect(result.stoppedEarly, isFalse);
      expect(result.episodes, hasLength(3));
    });

    test('stops at first episode when cutoff is after all pubDates', () async {
      // Cutoff newer than all episodes -- stops immediately at ep-3.
      final cutoff = DateTime.utc(2030);

      final result = await IsolateRssParser.parseFeed(
        feedXml: testXml,
        knownNewestPubDate: cutoff,
      );

      expect(result.stoppedEarly, isTrue);
      expect(result.episodes, isEmpty);
    });

    test('does not stop when no cutoff is provided', () async {
      final result = await IsolateRssParser.parseFeed(feedXml: testXml);

      expect(result.stoppedEarly, isFalse);
      expect(result.episodes, hasLength(3));
    });

    test('streams pubDate cutoff events correctly', () async {
      final cutoff = DateTime.utc(2026, 3, 14, 10);
      final progress = <ParseProgress>[];

      await for (final event in IsolateRssParser.parse(
        feedXml: testXml,
        knownGuids: {},
        knownNewestPubDate: cutoff,
      )) {
        progress.add(event);
      }

      expect(progress.whereType<ParsedPodcastMeta>(), hasLength(1));
      expect(progress.whereType<ParsedEpisode>(), hasLength(1));

      final complete = progress.whereType<ParseComplete>().first;
      expect(complete.totalParsed, 1);
      expect(complete.stoppedEarly, isTrue);
    });
  });
}
