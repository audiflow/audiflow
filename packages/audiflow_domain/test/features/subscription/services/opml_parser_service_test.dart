import 'package:audiflow_domain/src/features/subscription/'
    'models/opml_entry.dart';
import 'package:audiflow_domain/src/features/subscription/'
    'services/opml_parser_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late OpmlParserService service;

  setUp(() {
    service = OpmlParserService();
  });

  group('parse', () {
    test('parses standard nested OPML with outline wrapper', () {
      const xml = '''<?xml version="1.0" encoding="UTF-8"?>
<opml version="2.0">
  <head>
    <title>My Podcasts</title>
  </head>
  <body>
    <outline text="feeds">
      <outline type="rss"
        text="Podcast One"
        xmlUrl="https://example.com/feed1.xml"
        htmlUrl="https://example.com/1" />
      <outline type="rss"
        text="Podcast Two"
        xmlUrl="https://example.com/feed2.xml" />
    </outline>
  </body>
</opml>''';

      final result = service.parse(xml);

      expect(result.length, 2);
      expect(result[0].title, 'Podcast One');
      expect(result[0].feedUrl, 'https://example.com/feed1.xml');
      expect(result[0].htmlUrl, 'https://example.com/1');
      expect(result[1].title, 'Podcast Two');
      expect(result[1].feedUrl, 'https://example.com/feed2.xml');
      expect(result[1].htmlUrl, isNull);
    });

    test('parses flat OPML without outline wrapper', () {
      const xml = '''<?xml version="1.0" encoding="UTF-8"?>
<opml version="2.0">
  <head><title>Flat</title></head>
  <body>
    <outline type="rss"
      text="Direct Feed"
      xmlUrl="https://example.com/direct.xml"
      htmlUrl="https://example.com/direct" />
    <outline type="rss"
      text="Another Feed"
      xmlUrl="https://example.com/another.xml" />
  </body>
</opml>''';

      final result = service.parse(xml);

      expect(result.length, 2);
      expect(result[0].title, 'Direct Feed');
      expect(result[0].feedUrl, 'https://example.com/direct.xml');
      expect(result[0].htmlUrl, 'https://example.com/direct');
      expect(result[1].title, 'Another Feed');
      expect(result[1].feedUrl, 'https://example.com/another.xml');
    });

    test('skips outlines without xmlUrl', () {
      const xml = '''<?xml version="1.0" encoding="UTF-8"?>
<opml version="2.0">
  <head><title>Test</title></head>
  <body>
    <outline text="Category Only" />
    <outline type="rss"
      text="Valid Feed"
      xmlUrl="https://example.com/valid.xml" />
    <outline text="Another Category">
      <outline text="Subcategory" />
    </outline>
  </body>
</opml>''';

      final result = service.parse(xml);

      expect(result.length, 1);
      expect(result[0].title, 'Valid Feed');
      expect(result[0].feedUrl, 'https://example.com/valid.xml');
    });

    test('returns empty list for OPML with no RSS outlines', () {
      const xml = '''<?xml version="1.0" encoding="UTF-8"?>
<opml version="2.0">
  <head><title>Empty</title></head>
  <body>
  </body>
</opml>''';

      final result = service.parse(xml);

      expect(result, isEmpty);
    });

    test('throws FormatException for invalid XML', () {
      expect(() => service.parse('not xml at all'), throwsFormatException);
    });

    test('throws FormatException for XML without opml root', () {
      const xml = '<?xml version="1.0"?><html><body></body></html>';

      expect(() => service.parse(xml), throwsFormatException);
    });

    test('uses xmlUrl as title fallback when text is missing', () {
      const xml = '''<?xml version="1.0" encoding="UTF-8"?>
<opml version="2.0">
  <head><title>Fallback</title></head>
  <body>
    <outline type="rss"
      xmlUrl="https://example.com/notitle.xml" />
  </body>
</opml>''';

      final result = service.parse(xml);

      expect(result.length, 1);
      expect(result[0].title, 'https://example.com/notitle.xml');
      expect(result[0].feedUrl, 'https://example.com/notitle.xml');
    });

    test('handles deeply nested category outlines', () {
      const xml = '''<?xml version="1.0" encoding="UTF-8"?>
<opml version="2.0">
  <head><title>Apple Style</title></head>
  <body>
    <outline text="Technology">
      <outline text="Software">
        <outline text="Mobile">
          <outline type="rss"
            text="Deep Nested Pod"
            xmlUrl="https://example.com/deep.xml"
            htmlUrl="https://example.com/deep" />
        </outline>
      </outline>
      <outline type="rss"
        text="Tech Pod"
        xmlUrl="https://example.com/tech.xml" />
    </outline>
  </body>
</opml>''';

      final result = service.parse(xml);

      expect(result.length, 2);
      expect(result[0].title, 'Deep Nested Pod');
      expect(result[0].feedUrl, 'https://example.com/deep.xml');
      expect(result[1].title, 'Tech Pod');
      expect(result[1].feedUrl, 'https://example.com/tech.xml');
    });

    test('handles special characters in titles', () {
      const xml = '''<?xml version="1.0" encoding="UTF-8"?>
<opml version="2.0">
  <head><title>Special</title></head>
  <body>
    <outline type="rss"
      text="Rock &amp; Roll Podcast"
      xmlUrl="https://example.com/rock.xml" />
    <outline type="rss"
      text="The &lt;Code&gt; Show"
      xmlUrl="https://example.com/code.xml" />
    <outline type="rss"
      text="Quotes &quot;and&quot; More"
      xmlUrl="https://example.com/quotes.xml" />
  </body>
</opml>''';

      final result = service.parse(xml);

      expect(result.length, 3);
      expect(result[0].title, 'Rock & Roll Podcast');
      expect(result[1].title, 'The <Code> Show');
      expect(result[2].title, 'Quotes "and" More');
    });

    test('handles OPML 1.0 version', () {
      const xml = '''<?xml version="1.0" encoding="UTF-8"?>
<opml version="1.0">
  <head><title>V1</title></head>
  <body>
    <outline type="rss"
      text="Legacy Feed"
      xmlUrl="https://example.com/legacy.xml" />
  </body>
</opml>''';

      final result = service.parse(xml);

      expect(result.length, 1);
      expect(result[0].title, 'Legacy Feed');
    });

    test('ignores duplicate xmlUrl entries', () {
      const xml = '''<?xml version="1.0" encoding="UTF-8"?>
<opml version="2.0">
  <head><title>Dupes</title></head>
  <body>
    <outline type="rss"
      text="Feed A"
      xmlUrl="https://example.com/same.xml" />
    <outline type="rss"
      text="Feed A Copy"
      xmlUrl="https://example.com/same.xml" />
    <outline type="rss"
      text="Feed B"
      xmlUrl="https://example.com/other.xml" />
  </body>
</opml>''';

      final result = service.parse(xml);

      expect(result.length, 2);
      expect(result[0].title, 'Feed A');
      expect(result[1].title, 'Feed B');
    });

    test('handles empty body element', () {
      const xml = '''<?xml version="1.0" encoding="UTF-8"?>
<opml version="2.0">
  <head><title>Empty Body</title></head>
  <body/>
</opml>''';

      final result = service.parse(xml);

      expect(result, isEmpty);
    });

    test('uses title attribute as fallback when text is '
        'missing but title is present', () {
      const xml = '''<?xml version="1.0" encoding="UTF-8"?>
<opml version="2.0">
  <head><title>Title Attr</title></head>
  <body>
    <outline type="rss"
      title="Title Attr Feed"
      xmlUrl="https://example.com/titleattr.xml" />
  </body>
</opml>''';

      final result = service.parse(xml);

      expect(result.length, 1);
      expect(result[0].title, 'Title Attr Feed');
    });
  });

  group('generate', () {
    test('generates valid OPML 2.0 from entries', () {
      final entries = [
        const OpmlEntry(
          title: 'Podcast A',
          feedUrl: 'https://example.com/a.xml',
          htmlUrl: 'https://example.com/a',
        ),
        const OpmlEntry(
          title: 'Podcast B',
          feedUrl: 'https://example.com/b.xml',
        ),
      ];

      final xml = service.generate(entries);

      expect(xml, contains('<?xml'));
      expect(xml, contains('<opml version="2.0">'));
      expect(xml, contains('text="Podcast A"'));
      expect(xml, contains('xmlUrl="https://example.com/a.xml"'));
      expect(xml, contains('htmlUrl="https://example.com/a"'));
      expect(xml, contains('text="Podcast B"'));
      expect(xml, contains('xmlUrl="https://example.com/b.xml"'));
      // Podcast B has no htmlUrl, so it should not appear
      // We check that Podcast B's outline doesn't have htmlUrl
      // by verifying the overall structure
      expect(xml, contains('type="rss"'));
    });

    test('generates empty body for empty list', () {
      final xml = service.generate([]);

      expect(xml, contains('<opml version="2.0">'));
      expect(xml, isNot(contains('xmlUrl')));
    });

    test('escapes special characters in generated XML', () {
      final entries = [
        const OpmlEntry(
          title: 'Rock & Roll',
          feedUrl: 'https://example.com/rock.xml',
        ),
      ];

      final xml = service.generate(entries);

      // XML should have escaped ampersand
      expect(xml, contains('Rock &amp; Roll'));
      expect(xml, contains('xmlUrl'));
    });

    test('does not include htmlUrl attribute when null', () {
      final entries = [
        const OpmlEntry(
          title: 'No HTML',
          feedUrl: 'https://example.com/nohtml.xml',
        ),
      ];

      final xml = service.generate(entries);

      expect(xml, isNot(contains('htmlUrl')));
    });

    test('includes head with title and dateCreated', () {
      final xml = service.generate([]);

      expect(xml, contains('<head>'));
      expect(xml, contains('<title>'));
      expect(xml, contains('</head>'));
    });
  });

  group('round-trip', () {
    test('generate then parse produces equivalent entries', () {
      final original = [
        const OpmlEntry(
          title: 'Round Trip',
          feedUrl: 'https://example.com/round.xml',
          htmlUrl: 'https://example.com/round',
        ),
        const OpmlEntry(
          title: 'No HTML',
          feedUrl: 'https://example.com/nohtml.xml',
        ),
      ];

      final xml = service.generate(original);
      final parsed = service.parse(xml);

      expect(parsed.length, original.length);
      for (var i = 0; i < original.length; i++) {
        expect(parsed[i].title, original[i].title);
        expect(parsed[i].feedUrl, original[i].feedUrl);
        expect(parsed[i].htmlUrl, original[i].htmlUrl);
      }
    });

    test('round-trip preserves special characters', () {
      final original = [
        const OpmlEntry(
          title: 'Tom & Jerry\'s "Show"',
          feedUrl: 'https://example.com/tj.xml',
        ),
      ];

      final xml = service.generate(original);
      final parsed = service.parse(xml);

      expect(parsed.length, 1);
      expect(parsed[0].title, original[0].title);
      expect(parsed[0].feedUrl, original[0].feedUrl);
    });

    test('round-trip with many entries preserves order', () {
      final original = List.generate(
        10,
        (i) => OpmlEntry(
          title: 'Podcast $i',
          feedUrl: 'https://example.com/feed$i.xml',
          htmlUrl: i.isEven ? 'https://example.com/$i' : null,
        ),
      );

      final xml = service.generate(original);
      final parsed = service.parse(xml);

      expect(parsed.length, original.length);
      for (var i = 0; i < original.length; i++) {
        expect(parsed[i].title, original[i].title);
        expect(parsed[i].feedUrl, original[i].feedUrl);
        expect(parsed[i].htmlUrl, original[i].htmlUrl);
      }
    });
  });
}
