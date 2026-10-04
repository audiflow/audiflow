import 'dart:convert';

import 'package:audiflow_podcast/audiflow_podcast.dart';
import 'package:audiflow_podcast/src/parser/streaming_xml_parser.dart';
import 'package:flutter_test/flutter_test.dart';

const _feedWithBothChapterKinds = '''<?xml version="1.0" encoding="UTF-8"?>
<rss version="2.0"
  xmlns:podcast="https://podcastindex.org/namespace/1.0"
  xmlns:psc="http://podlove.org/simple-chapters">
  <channel>
    <title>Chapters Link Test</title>
    <description>Testing podcast:chapters</description>
    <item>
      <guid>ep-json-first</guid>
      <title>JSON link before psc</title>
      <description>Both kinds</description>
      <enclosure url="https://example.com/ep1.mp3" type="audio/mpeg" length="1"/>
      <podcast:chapters url="https://example.com/ep1/chapters.json" type="application/json+chapters"/>
      <psc:chapters version="1.2">
        <psc:chapter start="00:00:00" title="Intro"/>
      </psc:chapters>
    </item>
    <item>
      <guid>ep-json-only</guid>
      <title>JSON link only</title>
      <description>JSON only</description>
      <enclosure url="https://example.com/ep2.mp3" type="audio/mpeg" length="1"/>
      <podcast:chapters url="https://example.com/ep2/chapters.json" type="application/json+chapters"/>
    </item>
    <item>
      <guid>ep-missing-url</guid>
      <title>Link without url</title>
      <description>Invalid link</description>
      <enclosure url="https://example.com/ep3.mp3" type="audio/mpeg" length="1"/>
      <podcast:chapters type="application/json+chapters"/>
    </item>
  </channel>
</rss>''';

void main() {
  group('IsolateRssParser - podcast:chapters', () {
    late List<ParsedEpisode> episodes;

    setUpAll(() async {
      final result = await IsolateRssParser.parseFeed(
        feedXml: _feedWithBothChapterKinds,
      );
      episodes = result.episodes;
    });

    ParsedEpisode byGuid(String guid) =>
        episodes.firstWhere((e) => e.guid == guid);

    test('captures url and type', () {
      final link = byGuid('ep-json-only').chaptersLink;
      expect(
        link,
        const PodcastChaptersLink(
          url: 'https://example.com/ep2/chapters.json',
          type: 'application/json+chapters',
        ),
      );
      expect(byGuid('ep-json-only').chapters, isNull);
    });

    test('keeps psc chapters when podcast:chapters comes first', () {
      final episode = byGuid('ep-json-first');
      expect(
        episode.chaptersLink?.url,
        'https://example.com/ep1/chapters.json',
      );
      expect(episode.chapters, hasLength(1));
      expect(episode.chapters!.single.title, 'Intro');
    });

    test('ignores a link without url', () {
      expect(byGuid('ep-missing-url').chaptersLink, isNull);
    });
  });

  group('StreamingXmlParser - podcast:chapters', () {
    Future<List<PodcastItem>> parse(
      Future<void> Function(StreamingXmlParser parser) run,
    ) async {
      final parser = StreamingXmlParser();
      final items = <PodcastItem>[];
      parser.entityStream.listen((e) {
        if (e is PodcastItem) items.add(e);
      });
      await run(parser);
      return items;
    }

    void expectLinks(List<PodcastItem> items) {
      final byGuid = {for (final i in items) i.guid: i};
      expect(
        byGuid['ep-json-first']!.chaptersLink?.url,
        'https://example.com/ep1/chapters.json',
      );
      expect(byGuid['ep-json-first']!.chapters, hasLength(1));
      expect(
        byGuid['ep-json-only']!.chaptersLink,
        const PodcastChaptersLink(
          url: 'https://example.com/ep2/chapters.json',
          type: 'application/json+chapters',
        ),
      );
      expect(byGuid['ep-missing-url']!.chaptersLink, isNull);
    }

    test('DOM path captures the link', () async {
      final items = await parse(
        (p) => p.parseXmlString(_feedWithBothChapterKinds),
      );
      expectLinks(items);
    });

    test('streaming path captures the link', () async {
      final items = await parse(
        (p) => p.parseXmlStream(
          Stream.fromIterable([utf8.encode(_feedWithBothChapterKinds)]),
        ),
      );
      expectLinks(items);
    });
  });
}
