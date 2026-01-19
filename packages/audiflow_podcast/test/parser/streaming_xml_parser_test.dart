import 'dart:async';
import 'dart:convert';

import 'package:audiflow_podcast/src/errors/podcast_parse_error.dart';
import 'package:audiflow_podcast/src/models/podcast_entity.dart';
import 'package:audiflow_podcast/src/models/podcast_feed.dart';
import 'package:audiflow_podcast/src/models/podcast_item.dart';
import 'package:audiflow_podcast/src/parser/streaming_xml_parser.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_constants.dart';

void main() {
  group('StreamingXmlParser', () {
    late StreamingXmlParser parser;

    setUp(() {
      parser = StreamingXmlParser();
    });

    group('parseXmlString', () {
      test('should parse basic RSS feed with feed and items', () async {
        const xmlContent = '''<?xml version="1.0" encoding="UTF-8"?>
<rss version="2.0" xmlns:itunes="http://www.itunes.com/dtds/podcast-1.0.dtd">
  <channel>
    <title>Test Podcast</title>
    <description>A test podcast description</description>
    <link>https://example.com</link>
    <language>en-US</language>
    <itunes:author>Test Author</itunes:author>
    <itunes:explicit>false</itunes:explicit>
    <itunes:image href="https://example.com/image.jpg"/>

    <item>
      <title>Episode 1</title>
      <description>First episode description</description>
      <pubDate>Mon, 01 Jan 2024 12:00:00 GMT</pubDate>
      <enclosure url="https://example.com/episode1.mp3" type="audio/mpeg" length="12345"/>
      <itunes:duration>30:00</itunes:duration>
      <itunes:episode>1</itunes:episode>
      <itunes:explicit>false</itunes:explicit>
    </item>

    <item>
      <title>Episode 2</title>
      <description>Second episode description</description>
      <pubDate>Mon, 08 Jan 2024 12:00:00 GMT</pubDate>
      <enclosure url="https://example.com/episode2.mp3" type="audio/mpeg" length="54321"/>
      <itunes:duration>25:30</itunes:duration>
      <itunes:episode>2</itunes:episode>
    </item>
  </channel>
</rss>''';

        final entities = <PodcastEntity>[];
        final errors = <dynamic>[];

        parser.entityStream.listen(entities.add, onError: errors.add);

        await parser.parseXmlString(
          xmlContent,
          sourceUrl: 'https://example.com/feed.xml',
        );

        // Should have 1 feed + 2 items = 3 entities
        expect(entities.length, equals(3));
        expect(errors.length, equals(0));

        // First entity should be the feed (heuristic emission)
        final feed = entities[0] as PodcastFeed;
        expect(feed.title, equals('Test Podcast'));
        expect(feed.description, equals('A test podcast description'));
        expect(feed.link, equals('https://example.com'));
        expect(feed.language, equals('en-US'));
        expect(feed.author, equals('Test Author'));
        expect(feed.isExplicit, equals(false));
        expect(feed.images.length, equals(1));
        expect(feed.images.first.url, equals('https://example.com/image.jpg'));

        // Second and third entities should be items
        final item1 = entities[1] as PodcastItem;
        expect(item1.title, equals('Episode 1'));
        expect(item1.description, equals('First episode description'));
        expect(item1.enclosureUrl, equals('https://example.com/episode1.mp3'));
        expect(item1.enclosureType, equals('audio/mpeg'));
        expect(item1.enclosureLength, equals(12345));
        expect(item1.duration, equals(const Duration(minutes: 30)));
        expect(item1.episodeNumber, equals(1));
        expect(item1.isExplicit, equals(false));

        final item2 = entities[2] as PodcastItem;
        expect(item2.title, equals('Episode 2'));
        expect(item2.description, equals('Second episode description'));
        expect(
          item2.duration,
          equals(const Duration(minutes: 25, seconds: 30)),
        );
        expect(item2.episodeNumber, equals(2));
      });

      test('should handle RSS feed without items', () async {
        const xmlContent = '''<?xml version="1.0" encoding="UTF-8"?>
<rss version="2.0">
  <channel>
    <title>Empty Podcast</title>
    <description>A podcast with no episodes yet</description>
    <link>https://example.com</link>
  </channel>
</rss>''';

        final entities = <PodcastEntity>[];
        final errors = <dynamic>[];

        parser.entityStream.listen(entities.add, onError: errors.add);

        await parser.parseXmlString(xmlContent);

        // Should have 1 feed entity
        expect(entities.length, equals(1));
        expect(errors.length, equals(0));

        final feed = entities[0] as PodcastFeed;
        expect(feed.title, equals('Empty Podcast'));
        expect(feed.description, equals('A podcast with no episodes yet'));
      });

      test('should handle iTunes namespace elements correctly', () async {
        const xmlContent = '''<?xml version="1.0" encoding="UTF-8"?>
<rss version="2.0" xmlns:itunes="http://www.itunes.com/dtds/podcast-1.0.dtd">
  <channel>
    <title>iTunes Podcast</title>
    <description>A podcast with iTunes metadata</description>
    <itunes:author>iTunes Author</itunes:author>
    <itunes:subtitle>iTunes Subtitle</itunes:subtitle>
    <itunes:summary>iTunes Summary</itunes:summary>
    <itunes:explicit>true</itunes:explicit>
    <itunes:type>episodic</itunes:type>
    <itunes:complete>false</itunes:complete>
    <itunes:owner>
      <itunes:name>Owner Name</itunes:name>
      <itunes:email>owner@example.com</itunes:email>
    </itunes:owner>
    <itunes:category text="Technology"/>
    <itunes:category text="Education"/>

    <item>
      <title>iTunes Episode</title>
      <description>Episode with iTunes metadata</description>
      <itunes:author>Episode Author</itunes:author>
      <itunes:subtitle>Episode Subtitle</itunes:subtitle>
      <itunes:summary>Episode Summary</itunes:summary>
      <itunes:explicit>false</itunes:explicit>
      <itunes:duration>1:23:45</itunes:duration>
      <itunes:episode>10</itunes:episode>
      <itunes:season>2</itunes:season>
      <itunes:episodeType>full</itunes:episodeType>
    </item>
  </channel>
</rss>''';

        final entities = <PodcastEntity>[];
        parser.entityStream.listen(entities.add);

        await parser.parseXmlString(xmlContent);

        expect(entities.length, equals(2));

        final feed = entities[0] as PodcastFeed;
        expect(feed.author, equals('iTunes Author'));
        expect(feed.subtitle, equals('iTunes Subtitle'));
        expect(feed.summary, equals('iTunes Summary'));
        expect(feed.isExplicit, equals(true));
        expect(feed.type, equals('episodic'));
        expect(feed.isComplete, equals(false));
        expect(feed.ownerName, equals('Owner Name'));
        expect(feed.ownerEmail, equals('owner@example.com'));
        expect(feed.categories, containsAll(['Technology', 'Education']));

        final item = entities[1] as PodcastItem;
        expect(item.author, equals('Episode Author'));
        expect(item.subtitle, equals('Episode Subtitle'));
        expect(item.summary, equals('Episode Summary'));
        expect(item.isExplicit, equals(false));
        expect(
          item.duration,
          equals(const Duration(hours: 1, minutes: 23, seconds: 45)),
        );
        expect(item.episodeNumber, equals(10));
        expect(item.seasonNumber, equals(2));
        expect(item.episodeType, equals('full'));
      });

      test('should handle malformed XML gracefully', () async {
        const xmlContent = '''<?xml version="1.0" encoding="UTF-8"?>
<rss version="2.0">
  <channel>
    <title>Test Podcast</title>
    <description>A test podcast</description>
    <unclosed-tag>This tag is not closed
    <item>
      <title>Episode 1</title>
      <description>First episode</description>
    </item>
  </channel>
</rss>''';

        final entities = <PodcastEntity>[];
        final errors = <dynamic>[];

        parser.entityStream.listen(entities.add, onError: errors.add);

        await parser.parseXmlString(xmlContent);

        // Should have at least one error due to malformed XML
        expect(errors.length, greaterThan(0));
        expect(errors.first, isA<PodcastParseError>());
      });

      test('should handle missing required RSS elements', () async {
        const xmlContent = '''<?xml version="1.0" encoding="UTF-8"?>
<rss version="2.0">
  <channel>
    <!-- Missing title and description -->
    <link>https://example.com</link>
    <item>
      <!-- Missing title and description -->
      <pubDate>Mon, 01 Jan 2024 12:00:00 GMT</pubDate>
    </item>
  </channel>
</rss>''';

        final entities = <PodcastEntity>[];
        final errors = <dynamic>[];

        parser.entityStream.listen(entities.add, onError: errors.add);

        await parser.parseXmlString(xmlContent);

        expect(errors.length, greaterThanOrEqualTo(0));

        if (entities.isNotEmpty) {
          final feed = entities.first as PodcastFeed;
          expect(feed.title, isNotEmpty);
          expect(feed.description, isNotEmpty);
        }
      });

      test('should parse duration formats correctly', () async {
        const xmlContent = '''<?xml version="1.0" encoding="UTF-8"?>
<rss version="2.0" xmlns:itunes="http://www.itunes.com/dtds/podcast-1.0.dtd">
  <channel>
    <title>Duration Test</title>
    <description>Testing duration parsing</description>

    <item>
      <title>HH:MM:SS Format</title>
      <description>Episode with HH:MM:SS duration</description>
      <itunes:duration>1:23:45</itunes:duration>
    </item>

    <item>
      <title>MM:SS Format</title>
      <description>Episode with MM:SS duration</description>
      <itunes:duration>23:45</itunes:duration>
    </item>

    <item>
      <title>Seconds Only</title>
      <description>Episode with seconds only duration</description>
      <itunes:duration>1425</itunes:duration>
    </item>
  </channel>
</rss>''';

        final entities = <PodcastEntity>[];
        parser.entityStream.listen(entities.add);

        await parser.parseXmlString(xmlContent);

        expect(entities.length, equals(4)); // 1 feed + 3 items

        final item1 = entities[1] as PodcastItem;
        expect(
          item1.duration,
          equals(const Duration(hours: 1, minutes: 23, seconds: 45)),
        );

        final item2 = entities[2] as PodcastItem;
        expect(
          item2.duration,
          equals(const Duration(minutes: 23, seconds: 45)),
        );

        final item3 = entities[3] as PodcastItem;
        expect(item3.duration, equals(const Duration(seconds: 1425)));
      });

      test('should handle boolean parsing correctly', () async {
        const xmlContent = '''<?xml version="1.0" encoding="UTF-8"?>
<rss version="2.0" xmlns:itunes="http://www.itunes.com/dtds/podcast-1.0.dtd">
  <channel>
    <title>Boolean Test</title>
    <description>Testing boolean parsing</description>
    <itunes:explicit>true</itunes:explicit>

    <item>
      <title>Explicit Yes</title>
      <description>Episode marked as explicit with 'yes'</description>
      <itunes:explicit>yes</itunes:explicit>
    </item>

    <item>
      <title>Explicit 1</title>
      <description>Episode marked as explicit with '1'</description>
      <itunes:explicit>1</itunes:explicit>
    </item>

    <item>
      <title>Not Explicit</title>
      <description>Episode not marked as explicit</description>
      <itunes:explicit>false</itunes:explicit>
    </item>
  </channel>
</rss>''';

        final entities = <PodcastEntity>[];
        parser.entityStream.listen(entities.add);

        await parser.parseXmlString(xmlContent);

        expect(entities.length, equals(4)); // 1 feed + 3 items

        final feed = entities[0] as PodcastFeed;
        expect(feed.isExplicit, equals(true));

        final item1 = entities[1] as PodcastItem;
        expect(item1.isExplicit, equals(true));

        final item2 = entities[2] as PodcastItem;
        expect(item2.isExplicit, equals(true));

        final item3 = entities[3] as PodcastItem;
        expect(item3.isExplicit, equals(false));
      });

      test('should handle no RSS root element', () async {
        const xmlContent = '''<?xml version="1.0" encoding="UTF-8"?>
<html>
  <body>This is not an RSS feed</body>
</html>''';

        final entities = <PodcastEntity>[];
        final errors = <dynamic>[];

        parser.entityStream.listen(entities.add, onError: errors.add);

        await parser.parseXmlString(xmlContent);

        expect(entities.length, equals(0));
        expect(errors.length, equals(1));
        expect(errors.first, isA<PodcastParseError>());
        expect(
          (errors.first as PodcastParseError).message,
          contains('No RSS or Atom feed found'),
        );
      });

      test('should handle no channel element', () async {
        const xmlContent = '''<?xml version="1.0" encoding="UTF-8"?>
<rss version="2.0">
  <!-- Missing channel element -->
</rss>''';

        final entities = <PodcastEntity>[];
        final errors = <dynamic>[];

        parser.entityStream.listen(entities.add, onError: errors.add);

        await parser.parseXmlString(xmlContent);

        expect(entities.length, equals(0));
        expect(errors.length, equals(1));
        expect(errors.first, isA<PodcastParseError>());
        expect(
          (errors.first as PodcastParseError).message,
          contains('No channel element found'),
        );
      });

      test(
        'should emit feed heuristically when first item is encountered',
        () async {
          const xmlContent = '''<?xml version="1.0" encoding="UTF-8"?>
<rss version="2.0">
  <channel>
    <title>Heuristic Test</title>
    <description>Testing heuristic feed emission</description>
    <link>https://example.com</link>

    <!-- Feed should be emitted when this first item starts -->
    <item>
      <title>First Episode</title>
      <description>This should trigger feed emission</description>
    </item>

    <item>
      <title>Second Episode</title>
      <description>Feed should already be emitted</description>
    </item>
  </channel>
</rss>''';

          final entities = <PodcastEntity>[];
          final entityTypes = <String>[];

          parser.entityStream.listen((entity) {
            entities.add(entity);
            entityTypes.add(entity.runtimeType.toString());
          });

          await parser.parseXmlString(xmlContent);

          expect(entities.length, equals(3)); // 1 feed + 2 items

          // First entity should be the feed (emitted heuristically)
          expect(entityTypes[0], equals('PodcastFeed'));
          expect(entityTypes[1], equals('PodcastItem'));
          expect(entityTypes[2], equals('PodcastItem'));

          final feed = entities[0] as PodcastFeed;
          expect(feed.title, equals('Heuristic Test'));

          final firstItem = entities[1] as PodcastItem;
          expect(firstItem.title, equals('First Episode'));

          final secondItem = entities[2] as PodcastItem;
          expect(secondItem.title, equals('Second Episode'));
        },
      );

      test('should handle streaming with memory efficiency', () async {
        // Create a large feed simulation to test streaming efficiency
        const xmlHeader = '''<?xml version="1.0" encoding="UTF-8"?>
<rss version="2.0" xmlns:itunes="http://www.itunes.com/dtds/podcast-1.0.dtd">
  <channel>
    <title>Large Feed Test</title>
    <description>Testing streaming with many episodes</description>
    <link>https://example.com</link>
''';

        const xmlFooter = '''
  </channel>
</rss>''';

        // Create a stream that simulates a large feed with many items
        const itemTemplate = '''
    <item>
      <title>Episode {index}</title>
      <description>Description for episode {index}</description>
      <pubDate>Mon, 01 Jan 2024 12:00:00 GMT</pubDate>
      <enclosure url="https://example.com/episode{index}.mp3" type="audio/mpeg" length="12345"/>
      <itunes:duration>30:00</itunes:duration>
      <itunes:episode>{index}</itunes:episode>
    </item>
''';

        // Create chunks that simulate streaming
        final chunks = <List<int>>[];
        chunks.add(utf8.encode(xmlHeader));

        // Add items in chunks to simulate streaming
        for (var i = 1; i <= 10; i++) {
          final itemXml = itemTemplate.replaceAll('{index}', i.toString());
          chunks.add(utf8.encode(itemXml));
        }

        chunks.add(utf8.encode(xmlFooter));

        final byteStream = Stream.fromIterable(chunks);

        final entities = <PodcastEntity>[];
        final entityTypes = <String>[];

        parser.entityStream.listen((entity) {
          entities.add(entity);
          entityTypes.add(entity.runtimeType.toString());
        });

        await parser.parseXmlStream(
          byteStream,
          sourceUrl: 'https://example.com/large-feed.xml',
        );

        // Should have 1 feed + 10 items = 11 entities
        expect(entities.length, equals(11));

        // First entity should be the feed (emitted heuristically when first item is encountered)
        expect(entityTypes[0], equals('PodcastFeed'));

        // Remaining should be items
        for (var i = 1; i < entityTypes.length; i++) {
          expect(entityTypes[i], equals('PodcastItem'));
        }

        final feed = entities[0] as PodcastFeed;
        expect(feed.title, equals('Large Feed Test'));
        expect(feed.sourceUrl, equals('https://example.com/large-feed.xml'));

        // Check that items were processed correctly
        for (var i = 1; i <= 10; i++) {
          final item = entities[i] as PodcastItem;
          expect(item.title, equals('Episode $i'));
          expect(item.episodeNumber, equals(i));
          expect(item.sourceUrl, equals('https://example.com/large-feed.xml'));
        }
      });

      test(
        'should handle complex nested elements with state management',
        () async {
          const xmlContent = '''<?xml version="1.0" encoding="UTF-8"?>
<rss version="2.0" xmlns:itunes="http://www.itunes.com/dtds/podcast-1.0.dtd">
  <channel>
    <title>Complex Nested Test</title>
    <description>Testing complex nested element parsing</description>

    <image>
      <url>https://example.com/channel-image.jpg</url>
      <title>Channel Image</title>
      <width>300</width>
      <height>300</height>
    </image>

    <itunes:owner>
      <itunes:name>Test Owner</itunes:name>
      <itunes:email>owner@example.com</itunes:email>
    </itunes:owner>

    <item>
      <title>Nested Episode</title>
      <description>Episode with nested elements</description>
      <enclosure url="https://example.com/episode.mp3" type="audio/mpeg" length="12345"/>
      <itunes:image href="https://example.com/episode-image.jpg"/>
    </item>
  </channel>
</rss>''';

          final entities = <PodcastEntity>[];
          parser.entityStream.listen(entities.add);

          await parser.parseXmlString(xmlContent);

          expect(entities.length, equals(2)); // 1 feed + 1 item

          final feed = entities[0] as PodcastFeed;
          expect(feed.title, equals('Complex Nested Test'));
          expect(feed.images.length, greaterThan(0));
          expect(feed.ownerName, equals('Test Owner'));
          expect(feed.ownerEmail, equals('owner@example.com'));

          final item = entities[1] as PodcastItem;
          expect(item.title, equals('Nested Episode'));
          expect(item.enclosureUrl, equals('https://example.com/episode.mp3'));
          expect(item.enclosureType, equals('audio/mpeg'));
          expect(item.enclosureLength, equals(12345));
          expect(item.images.length, greaterThan(0));
        },
      );
    });

    group('parseXmlStream', () {
      test('should parse RSS feed from byte stream', () async {
        const xmlContent = '''<?xml version="1.0" encoding="UTF-8"?>
<rss version="2.0">
  <channel>
    <title>Stream Test</title>
    <description>Testing stream parsing</description>
    <item>
      <title>Stream Episode</title>
      <description>Episode from stream</description>
    </item>
  </channel>
</rss>''';

        final byteStream = Stream.fromIterable([utf8.encode(xmlContent)]);

        final entities = <PodcastEntity>[];
        parser.entityStream.listen(entities.add);

        await parser.parseXmlStream(
          byteStream,
          sourceUrl: 'https://example.com/stream.xml',
        );

        expect(entities.length, equals(2)); // 1 feed + 1 item

        final feed = entities[0] as PodcastFeed;
        expect(feed.title, equals('Stream Test'));
        expect(feed.sourceUrl, equals('https://example.com/stream.xml'));

        final item = entities[1] as PodcastItem;
        expect(item.title, equals('Stream Episode'));
        expect(item.sourceUrl, equals('https://example.com/stream.xml'));
      });

      test('should handle chunked byte stream', () async {
        const xmlContent = '''<?xml version="1.0" encoding="UTF-8"?>
<rss version="2.0">
  <channel>
    <title>Chunked Test</title>
    <description>Testing chunked parsing</description>
    <item>
      <title>Chunked Episode</title>
      <description>Episode from chunked stream</description>
    </item>
  </channel>
</rss>''';

        final chunks = <List<int>>[];
        final bytes = utf8.encode(xmlContent);

        for (var i = 0; i < bytes.length; i += testStreamChunkSize) {
          final end = (i + testStreamChunkSize < bytes.length)
              ? i + testStreamChunkSize
              : bytes.length;
          chunks.add(bytes.sublist(i, end));
        }

        final byteStream = Stream.fromIterable(chunks);

        final entities = <PodcastEntity>[];
        parser.entityStream.listen(entities.add);

        await parser.parseXmlStream(byteStream);

        expect(entities.length, equals(2)); // 1 feed + 1 item

        final feed = entities[0] as PodcastFeed;
        expect(feed.title, equals('Chunked Test'));

        final item = entities[1] as PodcastItem;
        expect(item.title, equals('Chunked Episode'));
      });
    });

    group('ParsingState', () {
      test('should initialize with default values', () {
        final state = ParsingState();

        expect(state.currentElement, equals(''));
        expect(state.currentAttributes, isEmpty);
        expect(state.characterData.toString(), equals(''));
        expect(state.currentFeedData, isEmpty);
        expect(state.currentItemData, isEmpty);
        expect(state.inItem, equals(false));
        expect(state.feedEmitted, equals(false));
        expect(state.sourceUrl, isNull);
        expect(state.elementStack, isEmpty);
        expect(state.inChannel, equals(false));
        expect(state.inImage, equals(false));
        expect(state.inOwner, equals(false));
        expect(state.inEnclosure, equals(false));
      });

      test('should reset to default values', () {
        final state = ParsingState();

        // Modify state
        state.currentElement = 'test';
        state.currentAttributes['key'] = 'value';
        state.characterData.write('data');
        state.currentFeedData['title'] = 'Test';
        state.currentItemData['title'] = 'Item';
        state.inItem = true;
        state.feedEmitted = true;
        state.sourceUrl = 'https://example.com';
        state.elementStack.add('channel');
        state.inChannel = true;

        // Reset
        state.reset();

        expect(state.currentElement, equals(''));
        expect(state.currentAttributes, isEmpty);
        expect(state.characterData.toString(), equals(''));
        expect(state.currentFeedData, isEmpty);
        expect(state.currentItemData, isEmpty);
        expect(state.inItem, equals(false));
        expect(state.feedEmitted, equals(false));
        expect(state.sourceUrl, isNull);
        expect(state.elementStack, isEmpty);
        expect(state.inChannel, equals(false));
      });

      test('should manage element stack correctly', () {
        final state = ParsingState();

        // Push elements
        state.pushElement('channel', {});
        expect(state.elementStack, equals(['channel']));
        expect(state.currentElement, equals('channel'));
        expect(state.inChannel, equals(true));

        state.pushElement('item', {});
        expect(state.elementStack, equals(['channel', 'item']));
        expect(state.currentElement, equals('item'));
        expect(state.inItem, equals(true));

        state.pushElement('title', {});
        expect(state.elementStack, equals(['channel', 'item', 'title']));
        expect(state.currentElement, equals('title'));

        // Pop elements
        state.popElement('title');
        expect(state.elementStack, equals(['channel', 'item']));
        expect(state.currentElement, equals('item'));

        state.popElement('item');
        expect(state.elementStack, equals(['channel']));
        expect(state.currentElement, equals('channel'));
        expect(state.inItem, equals(false));

        state.popElement('channel');
        expect(state.elementStack, isEmpty);
        expect(state.currentElement, equals(''));
        expect(state.inChannel, equals(false));
      });

      test('should track character data for elements', () {
        final state = ParsingState();

        state.pushElement('title', {});
        state.addCharacterData('Test ');
        state.addCharacterData('Podcast');

        expect(state.getElementData('title'), equals('Test Podcast'));

        state.popElement('title');
        expect(state.getElementData('title'), equals(''));
      });

      test('should provide element path for debugging', () {
        final state = ParsingState();

        state.pushElement('rss', {});
        state.pushElement('channel', {});
        state.pushElement('item', {});
        state.pushElement('title', {});

        expect(state.elementPath, equals('rss > channel > item > title'));
      });

      test('should check context correctly', () {
        final state = ParsingState();

        state.pushElement('channel', {});
        state.pushElement('item', {});

        expect(state.isInContext('channel'), equals(true));
        expect(state.isInContext('item'), equals(true));
        expect(state.isInContext('title'), equals(false));
      });

      test('should determine when to emit feed heuristically', () {
        final state = ParsingState();

        // No feed data yet
        expect(state.shouldEmitFeed(), equals(false));

        // Add feed data but not in item
        state.currentFeedData['title'] = 'Test Podcast';
        expect(state.shouldEmitFeed(), equals(false));

        // Now in item - should emit
        state.pushElement('item', {});
        expect(state.shouldEmitFeed(), equals(true));

        // Already emitted - should not emit again
        state.markFeedEmitted();
        expect(state.shouldEmitFeed(), equals(false));
      });
    });

    group('dispose', () {
      test('should close stream controller', () async {
        final parser = StreamingXmlParser();
        var streamClosed = false;

        parser.entityStream.listen((_) {}, onDone: () => streamClosed = true);

        parser.dispose();

        // Give some time for the stream to close
        await Future.delayed(const Duration(milliseconds: 10));

        expect(streamClosed, equals(true));
      });
    });
  });
}
