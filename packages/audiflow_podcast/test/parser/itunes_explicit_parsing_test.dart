// Tests for the full Apple-spec <itunes:explicit> value matrix at both the
// StreamingXmlParser and EntityFactory boundaries.
//
// Apple Podcasts Connect specifies three canonical values: true, false, and
// explicit. Many feeds also use yes/no/1/0/clean. The parser must treat
// true/yes/1/explicit as truthy and everything else (including absent) as false.

import 'package:audiflow_podcast/src/models/podcast_feed.dart';
import 'package:audiflow_podcast/src/models/podcast_item.dart';
import 'package:audiflow_podcast/src/parser/entity_factory.dart';
import 'package:audiflow_podcast/src/parser/streaming_xml_parser.dart';
import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart';

// ---------------------------------------------------------------------------
// EntityFactory boundary — _parseBoolean via createItem
// ---------------------------------------------------------------------------

/// Builds a minimal item data map with the given [explicitValue] string, or
/// omits the key entirely when [explicitValue] is null.
Map<String, dynamic> _itemData({String? explicitValue}) => {
  'title': 'Test Episode',
  'enclosureUrl': 'https://example.com/ep.mp3',
  'enclosureType': 'audio/mpeg',
  'itunesExplicit': ?explicitValue,
};

void main() {
  group('EntityFactory._parseBoolean via createItem (itunes:explicit)', () {
    late EntityFactory factory;

    setUp(() => factory = EntityFactory());

    // --- truthy values ---
    // PodcastItem.isExplicit is bool? so use equals(true/false) not isTrue/isFalse.

    for (final truthy in [
      'true',
      'TRUE',
      'True',
      ' true ',
      'yes',
      'YES',
      '  yes ',
      '1',
      'explicit',
      'EXPLICIT',
      ' Explicit ',
    ]) {
      test('isExplicit=true for "$truthy"', () {
        final item = factory.createItem(_itemData(explicitValue: truthy), null);
        check(item).isNotNull();
        check(item!.isExplicit).equals(true);
      });
    }

    // --- falsy values ---

    for (final falsy in [
      'false',
      'FALSE',
      'no',
      'NO',
      'clean',
      'CLEAN',
      '0',
      '',
      'oui',
    ]) {
      test('isExplicit=false for "$falsy"', () {
        final item = factory.createItem(_itemData(explicitValue: falsy), null);
        check(item).isNotNull();
        check(item!.isExplicit).equals(false);
      });
    }

    // --- absent tag ---

    test('isExplicit=null when tag is absent', () {
      final item = factory.createItem(_itemData(), null);
      check(item).isNotNull();
      // Absent itunes:explicit maps to null on PodcastItem (no default).
      check(item!.isExplicit).isNull();
    });
  });

  // -------------------------------------------------------------------------
  // StreamingXmlParser boundary — full XML round-trip for the 'explicit' value
  // -------------------------------------------------------------------------

  group('StreamingXmlParser itunes:explicit="explicit" round-trip', () {
    late StreamingXmlParser parser;

    setUp(() => parser = StreamingXmlParser());

    test('feed-level explicit="explicit" is parsed as true', () async {
      const xml = '''<?xml version="1.0" encoding="UTF-8"?>
<rss version="2.0" xmlns:itunes="http://www.itunes.com/dtds/podcast-1.0.dtd">
  <channel>
    <title>Explicit Feed</title>
    <description>Feed marked explicit via Apple-spec literal</description>
    <itunes:explicit>explicit</itunes:explicit>
  </channel>
</rss>''';

      final entities = <Object>[];
      parser.entityStream.listen(entities.add);
      await parser.parseXmlString(xml);

      check(entities).isNotEmpty();
      // PodcastFeed.isExplicit is bool (non-nullable).
      final feed = entities.first as PodcastFeed;
      check(feed.isExplicit).isTrue();
    });

    test(
      'item-level explicit="EXPLICIT" (uppercase) is parsed as true',
      () async {
        const xml = '''<?xml version="1.0" encoding="UTF-8"?>
<rss version="2.0" xmlns:itunes="http://www.itunes.com/dtds/podcast-1.0.dtd">
  <channel>
    <title>Mixed Case Feed</title>
    <description>Tests case-insensitive explicit parsing</description>
    <itunes:explicit>false</itunes:explicit>

    <item>
      <title>Explicit Episode</title>
      <description>Marked explicit with uppercase EXPLICIT</description>
      <enclosure url="https://example.com/ep.mp3" type="audio/mpeg" length="1"/>
      <itunes:explicit>EXPLICIT</itunes:explicit>
    </item>

    <item>
      <title>Clean Episode</title>
      <description>Marked clean</description>
      <enclosure url="https://example.com/ep2.mp3" type="audio/mpeg" length="1"/>
      <itunes:explicit>clean</itunes:explicit>
    </item>
  </channel>
</rss>''';

        final entities = <Object>[];
        parser.entityStream.listen(entities.add);
        await parser.parseXmlString(xml);

        check(entities.length).equals(3); // 1 feed + 2 items

        // PodcastItem.isExplicit is bool? — use equals().
        final item1 = entities[1] as PodcastItem;
        check(item1.isExplicit).equals(true);

        final item2 = entities[2] as PodcastItem;
        check(item2.isExplicit).equals(false);
      },
    );

    test('item with absent itunes:explicit tag has null isExplicit', () async {
      const xml = '''<?xml version="1.0" encoding="UTF-8"?>
<rss version="2.0" xmlns:itunes="http://www.itunes.com/dtds/podcast-1.0.dtd">
  <channel>
    <title>No Explicit Tag</title>
    <description>No itunes:explicit on item</description>

    <item>
      <title>Untagged Episode</title>
      <description>No explicit element present</description>
      <enclosure url="https://example.com/ep.mp3" type="audio/mpeg" length="1"/>
    </item>
  </channel>
</rss>''';

      final entities = <Object>[];
      parser.entityStream.listen(entities.add);
      await parser.parseXmlString(xml);

      check(entities.length).equals(2); // 1 feed + 1 item
      final item = entities[1] as PodcastItem;
      // Absent tag → null on PodcastItem; Episode.itunesExplicit defaults false.
      check(item.isExplicit).isNull();
    });
  });
}
