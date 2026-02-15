import 'package:xml/xml.dart';

import '../models/opml_entry.dart';

/// Parses and generates OPML 2.0 files for podcast
/// subscription import/export.
class OpmlParserService {
  /// Parses OPML XML string into a list of [OpmlEntry].
  ///
  /// Recursively traverses `<outline>` elements and collects
  /// those with an `xmlUrl` attribute (RSS feed entries).
  /// Duplicate feed URLs are skipped.
  ///
  /// Throws [FormatException] if the XML is invalid or
  /// the root element is not `<opml>`.
  List<OpmlEntry> parse(String xml) {
    final XmlDocument document;
    try {
      document = XmlDocument.parse(xml);
    } on XmlParserException catch (e) {
      throw FormatException('Invalid XML: ${e.message}');
    }

    final root = document.rootElement;
    if (root.name.local != 'opml') {
      throw FormatException(
        'Expected <opml> root element, '
        'found <${root.name.local}>',
      );
    }

    final body = root.findElements('body').firstOrNull;
    if (body == null) {
      return [];
    }

    final entries = <OpmlEntry>[];
    final seenUrls = <String>{};
    _collectEntries(body, entries, seenUrls);
    return entries;
  }

  /// Generates an OPML 2.0 XML string from [entries].
  ///
  /// Produces a standard OPML document with head (title,
  /// dateCreated) and body containing flat outline elements.
  String generate(List<OpmlEntry> entries) {
    final builder = XmlBuilder();
    builder.processing('xml', 'version="1.0" encoding="UTF-8"');
    builder.element(
      'opml',
      nest: () {
        builder.attribute('version', '2.0');
        builder.element(
          'head',
          nest: () {
            builder.element('title', nest: 'Audiflow Podcast Subscriptions');
            builder.element(
              'dateCreated',
              nest: DateTime.now().toUtc().toIso8601String(),
            );
          },
        );
        if (entries.isEmpty) {
          builder.element('body');
        } else {
          builder.element(
            'body',
            nest: () {
              for (final entry in entries) {
                builder.element(
                  'outline',
                  nest: () {
                    builder.attribute('type', 'rss');
                    builder.attribute('text', entry.title);
                    builder.attribute('xmlUrl', entry.feedUrl);
                    if (entry.htmlUrl != null) {
                      builder.attribute('htmlUrl', entry.htmlUrl!);
                    }
                  },
                );
              }
            },
          );
        }
      },
    );
    return builder.buildDocument().toXmlString(pretty: true);
  }

  void _collectEntries(
    XmlElement element,
    List<OpmlEntry> entries,
    Set<String> seenUrls,
  ) {
    for (final child in element.childElements) {
      if (child.name.local != 'outline') continue;

      final xmlUrl = child.getAttribute('xmlUrl');
      if (xmlUrl != null && !seenUrls.contains(xmlUrl)) {
        seenUrls.add(xmlUrl);
        final text = child.getAttribute('text');
        final title = child.getAttribute('title');
        final htmlUrl = child.getAttribute('htmlUrl');
        entries.add(
          OpmlEntry(
            title: text ?? title ?? xmlUrl,
            feedUrl: xmlUrl,
            htmlUrl: htmlUrl,
          ),
        );
      }

      // Recurse into nested outlines (category wrappers)
      _collectEntries(child, entries, seenUrls);
    }
  }
}
