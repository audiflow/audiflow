import 'package:audiflow_podcast/audiflow_podcast.dart';
import 'package:flutter_test/flutter_test.dart';

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

    group('with knownEnclosureUrls', () {
      const reusedXml = '''
<?xml version="1.0" encoding="UTF-8"?>
<rss version="2.0">
  <channel>
    <title>Test Podcast</title>
    <item>
      <guid>reused</guid>
      <title>New episode reusing an old guid</title>
      <enclosure url="https://example.com/new.mp3" type="audio/mpeg"/>
    </item>
    <item>
      <guid>reused</guid>
      <title>Old episode</title>
      <enclosure url="https://example.com/old.mp3" type="audio/mpeg"/>
    </item>
    <item>
      <guid>older</guid>
      <title>Older episode</title>
      <enclosure url="https://example.com/older.mp3" type="audio/mpeg"/>
    </item>
  </channel>
</rss>
''';

      Future<List<ParseProgress>> parse(Map<String, String> known) {
        return IsolateRssParser.parse(
          feedXml: reusedXml,
          knownGuids: known.keys.toSet(),
          knownEnclosureUrls: known,
        ).toList();
      }

      test('parses a new item that reuses a known guid', () async {
        final progress = await parse({
          'reused': 'https://example.com/old.mp3',
          'older': 'https://example.com/older.mp3',
        });

        final episodes = progress.whereType<ParsedEpisode>().toList();
        expect(episodes.map((e) => e.title), [
          'New episode reusing an old guid',
        ]);
        final complete = progress.whereType<ParseComplete>().single;
        expect(complete.stoppedEarly, isTrue);
        expect(complete.tailGuids, {'reused', 'older'});
      });

      test('reports only the matching row of a shared guid', () async {
        final duplicateKey = duplicateGuidKey(
          'reused',
          'https://example.com/new.mp3',
        );
        final progress = await IsolateRssParser.parse(
          feedXml: reusedXml.replaceFirst(
            RegExp(
              r'<item>\s*<guid>reused</guid>\s*<title>Old.*?</item>',
              dotAll: true,
            ),
            '',
          ),
          knownGuids: {duplicateKey, 'reused', 'older'},
          knownEnclosureUrls: {
            duplicateKey: 'https://example.com/new.mp3',
            'reused': 'https://example.com/old.mp3',
            'older': 'https://example.com/older.mp3',
          },
        ).toList();

        final complete = progress.whereType<ParseComplete>().single;
        // The raw-guid row left the feed, so it must not be reported.
        expect(complete.tailGuids, {duplicateKey, 'older'});
      });

      test('reports the guid of an item whose URL was rewritten', () async {
        final progress = await parse({
          'reused': 'https://example.com/old.mp3',
          'older': 'https://old-host.example.com/older.mp3',
        });

        final complete = progress.whereType<ParseComplete>().single;
        expect(complete.tailGuids, contains('older'));
      });

      test('keeps every row of a guid whose tail item is unmatched', () async {
        final duplicateKey = duplicateGuidKey(
          'older',
          'https://example.com/older-repost.mp3',
        );
        final progress = await parse({
          'reused': 'https://example.com/old.mp3',
          'older': 'https://old-host.example.com/older.mp3',
          duplicateKey: 'https://old-host.example.com/older-repost.mp3',
        });

        final complete = progress.whereType<ParseComplete>().single;
        expect(complete.tailGuids, containsAll(['older', duplicateKey]));
      });

      test('stops at a duplicate row stored under an older URL', () async {
        final staleKey = duplicateGuidKey(
          'reused',
          'https://example.com/stale.mp3',
        );
        final progress = await parse({
          staleKey: 'https://example.com/new.mp3',
          'reused': 'https://example.com/old.mp3',
        });

        expect(progress.whereType<ParsedEpisode>(), isEmpty);
        final complete = progress.whereType<ParseComplete>().single;
        expect(complete.tailGuids, contains(staleKey));
      });

      test('stops at an item stored under its duplicate-guid key', () async {
        final duplicateKey = duplicateGuidKey(
          'reused',
          'https://example.com/new.mp3',
        );
        final progress = await parse({
          duplicateKey: 'https://example.com/new.mp3',
          'reused': 'https://example.com/old.mp3',
        });

        expect(progress.whereType<ParsedEpisode>(), isEmpty);
        final complete = progress.whereType<ParseComplete>().single;
        expect(complete.tailGuids, contains(duplicateKey));
      });
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

    test('reads the episode explicit flag', () async {
      const xml = '''
<?xml version="1.0" encoding="UTF-8"?>
<rss version="2.0" xmlns:itunes="http://www.itunes.com/dtds/podcast-1.0.dtd">
  <channel>
    <title>Show</title>
    <item><guid>a</guid><title>A</title><itunes:explicit>yes</itunes:explicit></item>
    <item><guid>b</guid><title>B</title><itunes:explicit> Explicit </itunes:explicit></item>
    <item><guid>c</guid><title>C</title><itunes:explicit>clean</itunes:explicit></item>
    <item><guid>d</guid><title>D</title></item>
  </channel>
</rss>
''';
      final episodes = await IsolateRssParser.parse(
        feedXml: xml,
        knownGuids: {},
      ).where((e) => e is ParsedEpisode).cast<ParsedEpisode>().toList();

      expect(
        {for (final e in episodes) e.guid: e.isExplicit},
        {'a': true, 'b': true, 'c': false, 'd': null},
      );
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
      expect(meta.link, isNull);
    });

    test('reads the channel website, not atom:link', () async {
      const xml = '''
<?xml version="1.0" encoding="UTF-8"?>
<rss version="2.0" xmlns:atom="http://www.w3.org/2005/Atom">
  <channel>
    <title>Show</title>
    <atom:link href="https://example.com/feed.xml" rel="self"/>
    <link>https://example.com/show</link>
    <description>About</description>
    <item>
      <guid>e1</guid>
      <title>E1</title>
      <link>https://example.com/show/e1</link>
    </item>
  </channel>
</rss>
''';
      final meta = await IsolateRssParser.parse(
        feedXml: xml,
        knownGuids: {},
      ).firstWhere((event) => event is ParsedPodcastMeta);

      expect((meta as ParsedPodcastMeta).link, 'https://example.com/show');
    });

    Future<String?> channelLink(String link) async {
      final xml =
          '<?xml version="1.0" encoding="UTF-8"?>'
          '<rss version="2.0"><channel><title>Show</title>'
          '<link>$link</link>'
          '<item><guid>e1</guid><title>E1</title></item>'
          '</channel></rss>';
      final meta = await IsolateRssParser.parse(
        feedXml: xml,
        knownGuids: {},
      ).firstWhere((event) => event is ParsedPodcastMeta);
      return (meta as ParsedPodcastMeta).link;
    }

    test('decodes character references in the channel link', () async {
      expect(
        await channelLink('https://example.com/show?a=1&amp;b=2&#38;c=3'),
        'https://example.com/show?a=1&b=2&c=3',
      );
    });

    test('keeps a CDATA channel link verbatim', () async {
      expect(
        await channelLink('<![CDATA[https://example.com/show?a=1&amp;b]]>'),
        'https://example.com/show?a=1&amp;b',
      );
    });

    test('reads a channel link placed after the items', () async {
      const xml =
          '<?xml version="1.0" encoding="UTF-8"?>'
          '<rss version="2.0"><channel><title>Show</title>'
          '<item><guid>e1</guid><title>E1</title>'
          '<link>https://example.com/show/e1</link></item>'
          '<link>https://example.com/show</link>'
          '</channel></rss>';
      final meta = await IsolateRssParser.parse(
        feedXml: xml,
        knownGuids: {},
      ).firstWhere((event) => event is ParsedPodcastMeta);
      // The channel's own link, not the item's.
      expect((meta as ParsedPodcastMeta).link, 'https://example.com/show');
    });

    Future<String?> linkOf(String channelBody) async {
      final xml =
          '<?xml version="1.0" encoding="UTF-8"?>'
          '<rss version="2.0"><channel><title>Show</title>'
          '$channelBody'
          '</channel></rss>';
      final meta = await IsolateRssParser.parse(
        feedXml: xml,
        knownGuids: {},
      ).firstWhere((event) => event is ParsedPodcastMeta);
      return (meta as ParsedPodcastMeta).link;
    }

    test('ignores textInput and image links after the items', () async {
      expect(
        await linkOf(
          '<item><guid>e1</guid></item>'
          '<textInput><title>Search</title>'
          '<link>https://example.com/search</link></textInput>'
          '<link>https://example.com/show</link>',
        ),
        'https://example.com/show',
      );
    });

    test('ignores a link inside a comment', () async {
      expect(
        await linkOf(
          '<!-- <link>https://example.com/old</link> -->'
          '<link>https://example.com/show</link>'
          '<item><guid>e1</guid></item>',
        ),
        'https://example.com/show',
      );
    });

    test('a malformed reference in the link does not fail the feed', () async {
      final events = await IsolateRssParser.parse(
        feedXml:
            '<?xml version="1.0" encoding="UTF-8"?>'
            '<rss version="2.0"><channel><title>Show</title>'
            '<link>https://example.com/&#x110000;</link>'
            '<item><guid>e1</guid><title>E1</title></item>'
            '</channel></rss>',
        knownGuids: {},
      ).toList();
      expect(events.whereType<ParsedEpisode>(), hasLength(1));
    });

    test('drops a channel link that is not an http(s) address', () async {
      // Such a link only hides "Open website"; it must not fail the feed.
      expect(await channelLink('example.com/show'), isNull);
      expect(await channelLink('mailto:host@example.com'), isNull);
    });
  });
}
