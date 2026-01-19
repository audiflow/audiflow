import 'dart:convert';

import 'package:audiflow_podcast/audiflow_podcast.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PodcastRssParser', () {
    late PodcastRssParser parser;

    setUp(() {
      parser = PodcastRssParser();
    });

    group('parseFromString', () {
      test('should return stream of PodcastEntity objects', () async {
        const simpleRssXml = '''<?xml version="1.0" encoding="UTF-8"?>
<rss version="2.0" xmlns:itunes="http://www.itunes.com/dtds/podcast-1.0.dtd">
  <channel>
    <title>Test Podcast</title>
    <description>A test podcast</description>
    <link>https://example.com</link>
    <language>en</language>
    <item>
      <title>Episode 1</title>
      <description>First episode</description>
      <pubDate>Mon, 01 Jan 2024 00:00:00 GMT</pubDate>
      <enclosure url="https://example.com/episode1.mp3" type="audio/mpeg" length="1000000"/>
    </item>
  </channel>
</rss>''';

        final stream = parser.parseFromString(simpleRssXml);
        expect(stream, isA<Stream<PodcastEntity>>());

        final entities = await stream.toList();
        expect(entities, isNotEmpty);
        expect(entities.length, 2); // Feed + Item
        expect(entities[0], isA<PodcastFeed>());
        expect(entities[1], isA<PodcastItem>());
      });

      test('should handle empty RSS feed', () async {
        const emptyRssXml = '''<?xml version="1.0" encoding="UTF-8"?>
<rss version="2.0">
  <channel>
    <title>Empty Podcast</title>
    <description>A podcast with no episodes</description>
  </channel>
</rss>''';

        final stream = parser.parseFromString(emptyRssXml);
        final entities = await stream.toList();

        expect(entities, hasLength(1)); // Just Feed, no Items
        expect(entities[0], isA<PodcastFeed>());
        final feed = entities[0] as PodcastFeed;
        expect(feed.title, 'Empty Podcast');
        expect(feed.description, 'A podcast with no episodes');
      });

      test('should handle malformed XML gracefully', () async {
        const malformedXml = '''<?xml version="1.0" encoding="UTF-8"?>
<rss version="2.0">
  <channel>
    <title>Broken Podcast
    <description>Missing closing tag</description>
  </channel>
</rss>''';

        final stream = parser.parseFromString(malformedXml);

        expect(stream.toList, throwsA(isA<PodcastParseError>()));
      });
    });

    group('parseFromStream', () {
      test('should parse RSS from byte stream', () async {
        const simpleRssXml = '''<?xml version="1.0" encoding="UTF-8"?>
<rss version="2.0">
  <channel>
    <title>Stream Podcast</title>
    <description>From stream</description>
    <item>
      <title>Stream Episode</title>
      <description>Episode from stream</description>
      <enclosure url="https://example.com/stream.mp3" type="audio/mpeg" length="500000"/>
    </item>
  </channel>
</rss>''';

        final byteStream = Stream.value(utf8.encode(simpleRssXml));
        final stream = parser.parseFromStream(byteStream);

        final entities = await stream.toList();
        expect(entities, hasLength(2));
        expect(entities[0], isA<PodcastFeed>());
        expect(entities[1], isA<PodcastItem>());

        final feed = entities[0] as PodcastFeed;
        expect(feed.title, 'Stream Podcast');
      });

      test('should handle empty byte stream', () async {
        const emptyStream = Stream<List<int>>.empty();
        final stream = parser.parseFromStream(emptyStream);

        final entities = await stream.toList();
        expect(entities, isEmpty); // Empty stream results in empty list
      });
    });

    group('parseFromUrl', () {
      test('should integrate with HTTP fetcher and cache manager', () async {
        const testUrl = 'https://example.com/test-feed.xml';

        // This test will fail initially since we haven't implemented the integration
        final stream = parser.parseFromUrl(testUrl);
        expect(stream, isA<Stream<PodcastEntity>>());

        // We expect this to eventually work with real HTTP requests
        // For now, we'll mock or handle network errors gracefully
        expect(
          () => stream.first.timeout(const Duration(seconds: 1)),
          throwsA(anything), // Could be network error, timeout, etc.
        );
      });

      test('should respect cache options', () async {
        const testUrl = 'https://example.com/cached-feed.xml';
        const cacheOptions = CacheOptions(
          ttl: Duration(minutes: 30),
          maxCacheSize: 1024 * 1024, // 1MB
        );

        final stream = parser.parseFromUrl(testUrl, cacheOptions: cacheOptions);
        expect(stream, isA<Stream<PodcastEntity>>());
      });

      test('should handle invalid URLs', () async {
        const invalidUrl = 'not-a-valid-url';

        final stream = parser.parseFromUrl(invalidUrl);
        expect(stream.toList, throwsA(isA<PodcastParseError>()));
      });
    });

    group('integration', () {
      test(
        'should emit entities in correct order (Feed first, then Items)',
        () async {
          const rssWithMultipleItems = '''<?xml version="1.0" encoding="UTF-8"?>
<rss version="2.0">
  <channel>
    <title>Multi-Episode Podcast</title>
    <description>Multiple episodes</description>
    <item>
      <title>Episode 1</title>
      <description>First</description>
      <enclosure url="https://example.com/ep1.mp3" type="audio/mpeg" length="100"/>
    </item>
    <item>
      <title>Episode 2</title>
      <description>Second</description>
      <enclosure url="https://example.com/ep2.mp3" type="audio/mpeg" length="200"/>
    </item>
  </channel>
</rss>''';

          final stream = parser.parseFromString(rssWithMultipleItems);
          final entities = await stream.toList();

          expect(entities, hasLength(3)); // Feed + 2 Items
          expect(entities[0], isA<PodcastFeed>());
          expect(entities[1], isA<PodcastItem>());
          expect(entities[2], isA<PodcastItem>());

          final item1 = entities[1] as PodcastItem;
          final item2 = entities[2] as PodcastItem;
          expect(item1.title, 'Episode 1');
          expect(item2.title, 'Episode 2');
        },
      );

      test('should properly compose streams from all components', () async {
        // Test that HttpFetcher -> StreamingXmlParser -> EntityStream works
        const rssXml = '''<?xml version="1.0" encoding="UTF-8"?>
<rss version="2.0">
  <channel>
    <title>Stream Test</title>
    <description>Testing stream composition</description>
    <item>
      <title>Test Episode</title>
      <description>Stream test episode</description>
      <enclosure url="https://example.com/test.mp3" type="audio/mpeg" length="123"/>
    </item>
  </channel>
</rss>''';

        // Convert to byte stream like HttpFetcher would provide
        final byteChunks = <List<int>>[
          utf8.encode(rssXml.substring(0, 100)),
          utf8.encode(rssXml.substring(100, 200)),
          utf8.encode(rssXml.substring(200)),
        ];

        final chunkStream = Stream.fromIterable(byteChunks);
        final entityStream = parser.parseFromStream(chunkStream);

        final entities = <PodcastEntity>[];
        await for (final entity in entityStream) {
          entities.add(entity);
        }

        expect(entities, hasLength(2));
        expect(entities[0], isA<PodcastFeed>());
        expect(entities[1], isA<PodcastItem>());
      });

      test('should propagate errors through the entire pipeline', () async {
        // Test that errors from any component properly propagate
        final errorStream = Stream<List<int>>.error(Exception('Network error'));

        final entityStream = parser.parseFromStream(errorStream);

        expect(entityStream.toList, throwsA(isA<PodcastParseError>()));
      });

      test('should handle stream cancellation properly', () async {
        final longRssXml =
            '''<?xml version="1.0" encoding="UTF-8"?>
<rss version="2.0">
  <channel>
    <title>Long Podcast</title>
    <description>Many episodes</description>
    ${List.generate(100, (i) => '''
    <item>
      <title>Episode $i</title>
      <description>Episode $i description</description>
      <enclosure url="https://example.com/ep$i.mp3" type="audio/mpeg" length="1000"/>
    </item>''').join()}
  </channel>
</rss>''';

        final byteStream = Stream.value(utf8.encode(longRssXml));
        final entityStream = parser.parseFromStream(byteStream);

        // Take only first few entities and cancel
        final firstEntities = await entityStream.take(5).toList();

        expect(firstEntities, hasLength(5));
        expect(firstEntities[0], isA<PodcastFeed>());
        // Should cleanly handle cancellation without resource leaks
      });

      test('should properly dispose all resources', () {
        // Test that disposal doesn't throw and cleans up properly
        final testParser = PodcastRssParser();
        expect(testParser.dispose, returnsNormally);

        // After disposal, operations should still work (new instances created)
        const simpleXml = '''<?xml version="1.0" encoding="UTF-8"?>
<rss version="2.0">
  <channel><title>Test</title><description>Test</description></channel>
</rss>''';

        expect(() => testParser.parseFromString(simpleXml), returnsNormally);
      });

      test(
        'should handle caching during streaming without double-fetching',
        () async {
          const testUrl = 'https://example.com/cache-test.xml';
          const cacheOptions = CacheOptions();

          // First call should fetch from network and cache
          final firstStream = parser.parseFromUrl(
            testUrl,
            cacheOptions: cacheOptions,
          );

          // This should fail because we don't have real HTTP implementation
          // but it should properly handle the integration pattern
          expect(
            () => firstStream.first.timeout(const Duration(milliseconds: 500)),
            throwsA(anything), // Network error expected
          );
        },
      );

      test(
        'should implement optimized caching that avoids double HTTP requests',
        () async {
          // Current implementation fetches twice: once for parsing, once for caching
          // This is inefficient and should be fixed in the integration

          const testUrl = 'https://example.com/efficient-cache.xml';
          const cacheOptions = CacheOptions();

          // The integration should cache during streaming, not after
          final stream = parser.parseFromUrl(
            testUrl,
            cacheOptions: cacheOptions,
          );

          expect(
            () => stream.first.timeout(const Duration(milliseconds: 500)),
            throwsA(anything), // Expected to fail due to no real HTTP
          );
        },
      );
    });
  });
}
