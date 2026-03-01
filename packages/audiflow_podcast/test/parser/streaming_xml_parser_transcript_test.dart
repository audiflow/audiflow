import 'dart:convert';

import 'package:audiflow_podcast/src/models/podcast_entity.dart';
import 'package:audiflow_podcast/src/models/podcast_item.dart';
import 'package:audiflow_podcast/src/parser/streaming_xml_parser.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('StreamingXmlParser - podcast:transcript extraction', () {
    late StreamingXmlParser parser;

    setUp(() {
      parser = StreamingXmlParser();
    });

    group('parseXmlString (DOM path)', () {
      test('should extract transcript with all attributes', () async {
        const xmlContent = '''<?xml version="1.0" encoding="UTF-8"?>
<rss version="2.0"
  xmlns:itunes="http://www.itunes.com/dtds/podcast-1.0.dtd"
  xmlns:podcast="https://podcastindex.org/namespace/1.0">
  <channel>
    <title>Transcript Test</title>
    <description>Testing transcript extraction</description>
    <item>
      <title>Episode with Transcript</title>
      <description>Episode description</description>
      <podcast:transcript url="https://example.com/ep1.vtt" type="text/vtt" language="en" rel="captions" />
    </item>
  </channel>
</rss>''';

        final entities = <PodcastEntity>[];
        parser.entityStream.listen(entities.add);

        await parser.parseXmlString(xmlContent);

        expect(entities.length, equals(2));

        final item = entities[1] as PodcastItem;
        expect(item.transcripts, isNotNull);
        expect(item.transcripts!.length, equals(1));

        final transcript = item.transcripts!.first;
        expect(transcript.url, equals('https://example.com/ep1.vtt'));
        expect(transcript.type, equals('text/vtt'));
        expect(transcript.language, equals('en'));
        expect(transcript.rel, equals('captions'));
      });

      test('should extract multiple transcripts per item', () async {
        const xmlContent = '''<?xml version="1.0" encoding="UTF-8"?>
<rss version="2.0"
  xmlns:itunes="http://www.itunes.com/dtds/podcast-1.0.dtd"
  xmlns:podcast="https://podcastindex.org/namespace/1.0">
  <channel>
    <title>Multi Transcript Test</title>
    <description>Testing multiple transcripts</description>
    <item>
      <title>Episode with Multiple Transcripts</title>
      <description>Episode description</description>
      <podcast:transcript url="https://example.com/ep1.vtt" type="text/vtt" language="en" rel="captions" />
      <podcast:transcript url="https://example.com/ep1.srt" type="application/srt" language="ja" rel="transcript" />
      <podcast:transcript url="https://example.com/ep1.txt" type="text/plain" />
    </item>
  </channel>
</rss>''';

        final entities = <PodcastEntity>[];
        parser.entityStream.listen(entities.add);

        await parser.parseXmlString(xmlContent);

        final item = entities[1] as PodcastItem;
        expect(item.transcripts, isNotNull);
        expect(item.transcripts!.length, equals(3));

        expect(item.transcripts![0].url, equals('https://example.com/ep1.vtt'));
        expect(item.transcripts![0].type, equals('text/vtt'));
        expect(item.transcripts![0].language, equals('en'));
        expect(item.transcripts![0].rel, equals('captions'));

        expect(item.transcripts![1].url, equals('https://example.com/ep1.srt'));
        expect(item.transcripts![1].type, equals('application/srt'));
        expect(item.transcripts![1].language, equals('ja'));
        expect(item.transcripts![1].rel, equals('transcript'));

        expect(item.transcripts![2].url, equals('https://example.com/ep1.txt'));
        expect(item.transcripts![2].type, equals('text/plain'));
        expect(item.transcripts![2].language, isNull);
        expect(item.transcripts![2].rel, isNull);
      });

      test(
        'should return null transcripts for items without transcripts',
        () async {
          const xmlContent = '''<?xml version="1.0" encoding="UTF-8"?>
<rss version="2.0"
  xmlns:itunes="http://www.itunes.com/dtds/podcast-1.0.dtd"
  xmlns:podcast="https://podcastindex.org/namespace/1.0">
  <channel>
    <title>No Transcript Test</title>
    <description>Testing items without transcripts</description>
    <item>
      <title>Episode without Transcript</title>
      <description>No transcript here</description>
    </item>
  </channel>
</rss>''';

          final entities = <PodcastEntity>[];
          parser.entityStream.listen(entities.add);

          await parser.parseXmlString(xmlContent);

          final item = entities[1] as PodcastItem;
          expect(item.transcripts, isNull);
          expect(item.hasTranscripts, isFalse);
        },
      );

      test('should skip malformed transcript elements missing url', () async {
        const xmlContent = '''<?xml version="1.0" encoding="UTF-8"?>
<rss version="2.0"
  xmlns:itunes="http://www.itunes.com/dtds/podcast-1.0.dtd"
  xmlns:podcast="https://podcastindex.org/namespace/1.0">
  <channel>
    <title>Malformed Transcript Test</title>
    <description>Testing malformed transcripts</description>
    <item>
      <title>Episode with Bad Transcripts</title>
      <description>Some transcripts are missing required attributes</description>
      <podcast:transcript type="text/vtt" language="en" />
      <podcast:transcript url="https://example.com/ep1.vtt" type="text/vtt" />
    </item>
  </channel>
</rss>''';

        final entities = <PodcastEntity>[];
        parser.entityStream.listen(entities.add);

        await parser.parseXmlString(xmlContent);

        final item = entities[1] as PodcastItem;
        // Only the valid transcript (with both url and type) should be kept
        expect(item.transcripts, isNotNull);
        expect(item.transcripts!.length, equals(1));
        expect(item.transcripts![0].url, equals('https://example.com/ep1.vtt'));
        expect(item.transcripts![0].type, equals('text/vtt'));
      });

      test('should skip malformed transcript elements missing type', () async {
        const xmlContent = '''<?xml version="1.0" encoding="UTF-8"?>
<rss version="2.0"
  xmlns:itunes="http://www.itunes.com/dtds/podcast-1.0.dtd"
  xmlns:podcast="https://podcastindex.org/namespace/1.0">
  <channel>
    <title>Missing Type Test</title>
    <description>Testing transcript without type</description>
    <item>
      <title>Episode with Missing Type</title>
      <description>Transcript missing type attribute</description>
      <podcast:transcript url="https://example.com/ep1.vtt" />
    </item>
  </channel>
</rss>''';

        final entities = <PodcastEntity>[];
        parser.entityStream.listen(entities.add);

        await parser.parseXmlString(xmlContent);

        final item = entities[1] as PodcastItem;
        // Transcript without type should be skipped
        expect(item.transcripts, isNull);
      });
    });

    group('parseXmlStream (streaming path)', () {
      test('should extract transcripts from streamed XML', () async {
        const xmlContent = '''<?xml version="1.0" encoding="UTF-8"?>
<rss version="2.0"
  xmlns:itunes="http://www.itunes.com/dtds/podcast-1.0.dtd"
  xmlns:podcast="https://podcastindex.org/namespace/1.0">
  <channel>
    <title>Stream Transcript Test</title>
    <description>Testing transcript extraction from stream</description>
    <item>
      <title>Streamed Episode</title>
      <description>Episode from stream</description>
      <podcast:transcript url="https://example.com/ep1.vtt" type="text/vtt" language="en" rel="captions" />
      <podcast:transcript url="https://example.com/ep1.srt" type="application/srt" language="ja" />
    </item>
  </channel>
</rss>''';

        final byteStream = Stream.fromIterable([utf8.encode(xmlContent)]);

        final entities = <PodcastEntity>[];
        parser.entityStream.listen(entities.add);

        await parser.parseXmlStream(byteStream);

        expect(entities.length, equals(2));

        final item = entities[1] as PodcastItem;
        expect(item.transcripts, isNotNull);
        expect(item.transcripts!.length, equals(2));

        expect(item.transcripts![0].url, equals('https://example.com/ep1.vtt'));
        expect(item.transcripts![0].type, equals('text/vtt'));
        expect(item.transcripts![0].language, equals('en'));
        expect(item.transcripts![0].rel, equals('captions'));

        expect(item.transcripts![1].url, equals('https://example.com/ep1.srt'));
        expect(item.transcripts![1].type, equals('application/srt'));
        expect(item.transcripts![1].language, equals('ja'));
        expect(item.transcripts![1].rel, isNull);
      });

      test('should skip malformed transcripts in streamed XML', () async {
        const xmlContent = '''<?xml version="1.0" encoding="UTF-8"?>
<rss version="2.0"
  xmlns:itunes="http://www.itunes.com/dtds/podcast-1.0.dtd"
  xmlns:podcast="https://podcastindex.org/namespace/1.0">
  <channel>
    <title>Stream Malformed Test</title>
    <description>Testing malformed transcript in stream</description>
    <item>
      <title>Streamed Episode</title>
      <description>Episode from stream</description>
      <podcast:transcript type="text/vtt" />
      <podcast:transcript url="https://example.com/good.vtt" type="text/vtt" />
      <podcast:transcript url="https://example.com/no-type.vtt" />
    </item>
  </channel>
</rss>''';

        final byteStream = Stream.fromIterable([utf8.encode(xmlContent)]);

        final entities = <PodcastEntity>[];
        parser.entityStream.listen(entities.add);

        await parser.parseXmlStream(byteStream);

        final item = entities[1] as PodcastItem;
        expect(item.transcripts, isNotNull);
        expect(item.transcripts!.length, equals(1));
        expect(
          item.transcripts![0].url,
          equals('https://example.com/good.vtt'),
        );
      });
    });
  });
}
