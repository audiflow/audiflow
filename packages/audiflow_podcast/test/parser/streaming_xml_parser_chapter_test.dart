import 'dart:convert';

import 'package:audiflow_podcast/src/models/podcast_entity.dart';
import 'package:audiflow_podcast/src/models/podcast_item.dart';
import 'package:audiflow_podcast/src/parser/streaming_xml_parser.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('StreamingXmlParser - psc:chapter extraction', () {
    late StreamingXmlParser parser;

    setUp(() {
      parser = StreamingXmlParser();
    });

    group('parseXmlString (DOM path)', () {
      test('should extract chapters with all attributes', () async {
        const xmlContent = '''<?xml version="1.0" encoding="UTF-8"?>
<rss version="2.0"
  xmlns:itunes="http://www.itunes.com/dtds/podcast-1.0.dtd"
  xmlns:psc="http://podlove.org/simple-chapters">
  <channel>
    <title>Chapter Test</title>
    <description>Testing chapter extraction</description>
    <item>
      <title>Episode with Chapters</title>
      <description>Episode description</description>
      <psc:chapters version="1.2" xmlns:psc="http://podlove.org/simple-chapters">
        <psc:chapter start="00:00:00.000" title="Introduction" href="https://example.com" image="https://example.com/img.jpg" />
      </psc:chapters>
    </item>
  </channel>
</rss>''';

        final entities = <PodcastEntity>[];
        parser.entityStream.listen(entities.add);

        await parser.parseXmlString(xmlContent);

        expect(entities.length, equals(2));

        final item = entities[1] as PodcastItem;
        expect(item.chapters, isNotNull);
        expect(item.chapters!.length, equals(1));

        final chapter = item.chapters!.first;
        expect(chapter.title, equals('Introduction'));
        expect(chapter.startTime, equals(Duration.zero));
        expect(chapter.url, equals('https://example.com'));
        expect(chapter.imageUrl, equals('https://example.com/img.jpg'));
      });

      test('should extract multiple chapters per item', () async {
        const xmlContent = '''<?xml version="1.0" encoding="UTF-8"?>
<rss version="2.0"
  xmlns:itunes="http://www.itunes.com/dtds/podcast-1.0.dtd"
  xmlns:psc="http://podlove.org/simple-chapters">
  <channel>
    <title>Multi Chapter Test</title>
    <description>Testing multiple chapters</description>
    <item>
      <title>Episode with Multiple Chapters</title>
      <description>Episode description</description>
      <psc:chapters version="1.2" xmlns:psc="http://podlove.org/simple-chapters">
        <psc:chapter start="00:00:00.000" title="Introduction" />
        <psc:chapter start="00:05:30.000" title="Main Topic" href="https://example.com/topic" />
        <psc:chapter start="01:10:00.000" title="Wrap Up" image="https://example.com/wrap.jpg" />
      </psc:chapters>
    </item>
  </channel>
</rss>''';

        final entities = <PodcastEntity>[];
        parser.entityStream.listen(entities.add);

        await parser.parseXmlString(xmlContent);

        final item = entities[1] as PodcastItem;
        expect(item.chapters, isNotNull);
        expect(item.chapters!.length, equals(3));

        expect(item.chapters![0].title, equals('Introduction'));
        expect(item.chapters![0].startTime, equals(Duration.zero));
        expect(item.chapters![0].url, isNull);
        expect(item.chapters![0].imageUrl, isNull);

        expect(item.chapters![1].title, equals('Main Topic'));
        expect(
          item.chapters![1].startTime,
          equals(const Duration(minutes: 5, seconds: 30)),
        );
        expect(
          item.chapters![1].url,
          equals('https://example.com/topic'),
        );

        expect(item.chapters![2].title, equals('Wrap Up'));
        expect(
          item.chapters![2].startTime,
          equals(const Duration(hours: 1, minutes: 10)),
        );
        expect(
          item.chapters![2].imageUrl,
          equals('https://example.com/wrap.jpg'),
        );
      });

      test(
        'should return null chapters for items without chapters',
        () async {
          const xmlContent = '''<?xml version="1.0" encoding="UTF-8"?>
<rss version="2.0"
  xmlns:itunes="http://www.itunes.com/dtds/podcast-1.0.dtd"
  xmlns:psc="http://podlove.org/simple-chapters">
  <channel>
    <title>No Chapter Test</title>
    <description>Testing items without chapters</description>
    <item>
      <title>Episode without Chapters</title>
      <description>No chapters here</description>
    </item>
  </channel>
</rss>''';

          final entities = <PodcastEntity>[];
          parser.entityStream.listen(entities.add);

          await parser.parseXmlString(xmlContent);

          final item = entities[1] as PodcastItem;
          expect(item.chapters, isNull);
          expect(item.hasChapters, isFalse);
        },
      );

      test(
        'should skip chapters missing required start attribute',
        () async {
          const xmlContent = '''<?xml version="1.0" encoding="UTF-8"?>
<rss version="2.0"
  xmlns:itunes="http://www.itunes.com/dtds/podcast-1.0.dtd"
  xmlns:psc="http://podlove.org/simple-chapters">
  <channel>
    <title>Malformed Chapter Test</title>
    <description>Testing malformed chapters</description>
    <item>
      <title>Episode with Bad Chapters</title>
      <description>Some chapters missing required attributes</description>
      <psc:chapters version="1.2" xmlns:psc="http://podlove.org/simple-chapters">
        <psc:chapter title="No Start" />
        <psc:chapter start="00:05:00.000" title="Valid Chapter" />
      </psc:chapters>
    </item>
  </channel>
</rss>''';

          final entities = <PodcastEntity>[];
          parser.entityStream.listen(entities.add);

          await parser.parseXmlString(xmlContent);

          final item = entities[1] as PodcastItem;
          expect(item.chapters, isNotNull);
          expect(item.chapters!.length, equals(1));
          expect(item.chapters![0].title, equals('Valid Chapter'));
        },
      );

      test(
        'should skip chapters missing required title attribute',
        () async {
          const xmlContent = '''<?xml version="1.0" encoding="UTF-8"?>
<rss version="2.0"
  xmlns:itunes="http://www.itunes.com/dtds/podcast-1.0.dtd"
  xmlns:psc="http://podlove.org/simple-chapters">
  <channel>
    <title>Missing Title Test</title>
    <description>Testing chapter without title</description>
    <item>
      <title>Episode with Missing Title Chapter</title>
      <description>Chapter missing title attribute</description>
      <psc:chapters version="1.2" xmlns:psc="http://podlove.org/simple-chapters">
        <psc:chapter start="00:00:00.000" />
        <psc:chapter start="00:10:00.000" title="Has Title" />
      </psc:chapters>
    </item>
  </channel>
</rss>''';

          final entities = <PodcastEntity>[];
          parser.entityStream.listen(entities.add);

          await parser.parseXmlString(xmlContent);

          final item = entities[1] as PodcastItem;
          expect(item.chapters, isNotNull);
          expect(item.chapters!.length, equals(1));
          expect(item.chapters![0].title, equals('Has Title'));
        },
      );

      test('should parse HH:MM:SS timestamp format', () async {
        const xmlContent = '''<?xml version="1.0" encoding="UTF-8"?>
<rss version="2.0"
  xmlns:itunes="http://www.itunes.com/dtds/podcast-1.0.dtd"
  xmlns:psc="http://podlove.org/simple-chapters">
  <channel>
    <title>Timestamp Format Test</title>
    <description>Testing HH:MM:SS format</description>
    <item>
      <title>Episode with HH:MM:SS</title>
      <description>Episode description</description>
      <psc:chapters version="1.2" xmlns:psc="http://podlove.org/simple-chapters">
        <psc:chapter start="02:30:45" title="Without Milliseconds" />
      </psc:chapters>
    </item>
  </channel>
</rss>''';

        final entities = <PodcastEntity>[];
        parser.entityStream.listen(entities.add);

        await parser.parseXmlString(xmlContent);

        final item = entities[1] as PodcastItem;
        expect(item.chapters, isNotNull);
        expect(item.chapters!.length, equals(1));
        expect(
          item.chapters![0].startTime,
          equals(
            const Duration(hours: 2, minutes: 30, seconds: 45),
          ),
        );
      });

      test('should parse HH:MM:SS.mmm timestamp format', () async {
        const xmlContent = '''<?xml version="1.0" encoding="UTF-8"?>
<rss version="2.0"
  xmlns:itunes="http://www.itunes.com/dtds/podcast-1.0.dtd"
  xmlns:psc="http://podlove.org/simple-chapters">
  <channel>
    <title>Timestamp Millis Test</title>
    <description>Testing HH:MM:SS.mmm format</description>
    <item>
      <title>Episode with Milliseconds</title>
      <description>Episode description</description>
      <psc:chapters version="1.2" xmlns:psc="http://podlove.org/simple-chapters">
        <psc:chapter start="01:23:45.678" title="With Milliseconds" />
      </psc:chapters>
    </item>
  </channel>
</rss>''';

        final entities = <PodcastEntity>[];
        parser.entityStream.listen(entities.add);

        await parser.parseXmlString(xmlContent);

        final item = entities[1] as PodcastItem;
        expect(item.chapters, isNotNull);
        expect(item.chapters!.length, equals(1));
        expect(
          item.chapters![0].startTime,
          equals(
            const Duration(
              hours: 1,
              minutes: 23,
              seconds: 45,
              milliseconds: 678,
            ),
          ),
        );
      });
    });

    group('parseXmlStream (streaming path)', () {
      test('should extract chapters from streamed XML', () async {
        const xmlContent = '''<?xml version="1.0" encoding="UTF-8"?>
<rss version="2.0"
  xmlns:itunes="http://www.itunes.com/dtds/podcast-1.0.dtd"
  xmlns:psc="http://podlove.org/simple-chapters">
  <channel>
    <title>Stream Chapter Test</title>
    <description>Testing chapter extraction from stream</description>
    <item>
      <title>Streamed Episode</title>
      <description>Episode from stream</description>
      <psc:chapters version="1.2" xmlns:psc="http://podlove.org/simple-chapters">
        <psc:chapter start="00:00:00.000" title="Intro" href="https://example.com" />
        <psc:chapter start="00:15:00.000" title="Discussion" image="https://example.com/disc.jpg" />
      </psc:chapters>
    </item>
  </channel>
</rss>''';

        final byteStream = Stream.fromIterable([utf8.encode(xmlContent)]);

        final entities = <PodcastEntity>[];
        parser.entityStream.listen(entities.add);

        await parser.parseXmlStream(byteStream);

        expect(entities.length, equals(2));

        final item = entities[1] as PodcastItem;
        expect(item.chapters, isNotNull);
        expect(item.chapters!.length, equals(2));

        expect(item.chapters![0].title, equals('Intro'));
        expect(item.chapters![0].startTime, equals(Duration.zero));
        expect(item.chapters![0].url, equals('https://example.com'));

        expect(item.chapters![1].title, equals('Discussion'));
        expect(
          item.chapters![1].startTime,
          equals(const Duration(minutes: 15)),
        );
        expect(
          item.chapters![1].imageUrl,
          equals('https://example.com/disc.jpg'),
        );
      });

      test('should skip malformed chapters in streamed XML', () async {
        const xmlContent = '''<?xml version="1.0" encoding="UTF-8"?>
<rss version="2.0"
  xmlns:itunes="http://www.itunes.com/dtds/podcast-1.0.dtd"
  xmlns:psc="http://podlove.org/simple-chapters">
  <channel>
    <title>Stream Malformed Test</title>
    <description>Testing malformed chapters in stream</description>
    <item>
      <title>Streamed Episode</title>
      <description>Episode from stream</description>
      <psc:chapters version="1.2" xmlns:psc="http://podlove.org/simple-chapters">
        <psc:chapter title="No Start" />
        <psc:chapter start="00:05:00.000" title="Valid" />
        <psc:chapter start="00:10:00.000" />
      </psc:chapters>
    </item>
  </channel>
</rss>''';

        final byteStream = Stream.fromIterable([utf8.encode(xmlContent)]);

        final entities = <PodcastEntity>[];
        parser.entityStream.listen(entities.add);

        await parser.parseXmlStream(byteStream);

        final item = entities[1] as PodcastItem;
        expect(item.chapters, isNotNull);
        expect(item.chapters!.length, equals(1));
        expect(item.chapters![0].title, equals('Valid'));
      });
    });
  });
}
