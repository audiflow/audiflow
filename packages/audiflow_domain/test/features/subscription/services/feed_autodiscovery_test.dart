import 'package:audiflow_domain/src/features/subscription/services/feed_autodiscovery.dart';
import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final page = Uri.parse('https://example.com/show/');

  String htmlWith(String head) =>
      '<!DOCTYPE html><html><head>$head</head><body></body></html>';

  group('looksLikeHtml', () {
    test('detects an HTML page', () {
      check(looksLikeHtml(htmlWith(''))).isTrue();
    });

    test('detects a page without an <html> tag', () {
      check(looksLikeHtml('<!doctype html><title>x</title>')).isTrue();
      check(looksLikeHtml('<head><title>x</title></head>')).isTrue();
    });

    test('looks past a prolog and comments', () {
      check(
        looksLikeHtml('\uFEFF<?xml version="1.0"?>\n<!-- page -->\n<html>'),
      ).isTrue();
    });

    test('ignores HTML inside the show notes of a feed', () {
      check(
        looksLikeHtml(
          '<?xml version="1.0"?><rss><channel><description><![CDATA['
          '<!DOCTYPE html><html><head></head></html>]]></description>',
        ),
      ).isFalse();
    });

    test('rejects an RSS document', () {
      check(
        looksLikeHtml('<?xml version="1.0"?><rss><channel/></rss>'),
      ).isFalse();
    });
  });

  group('discoverFeedUrl', () {
    test('returns the announced RSS feed', () {
      final html = htmlWith(
        '<link rel="alternate" type="application/rss+xml" '
        'href="https://feeds.example.com/show.xml">',
      );
      check(
        discoverFeedUrl(html, page),
      ).equals('https://feeds.example.com/show.xml');
    });

    test('resolves a relative href and upgrades it to https', () {
      final html = htmlWith(
        "<LINK type='application/rss+xml' href='feed.xml' rel='alternate'>",
      );
      check(
        discoverFeedUrl(html, Uri.parse('http://example.com/show/')),
      ).equals('https://example.com/show/feed.xml');
    });

    test('unescapes &amp; in the href', () {
      final html = htmlWith(
        '<link rel="alternate" type="application/rss+xml" '
        'href="/feed?a=1&amp;b=2">',
      );
      check(
        discoverFeedUrl(html, page),
      ).equals('https://example.com/feed?a=1&b=2');
    });

    test('prefers the feed that mentions podcast', () {
      final html = htmlWith(
        '<link rel="alternate" type="application/rss+xml" href="/feed/">'
        '<link rel="alternate" type="application/rss+xml" '
        'href="/comments/feed/">'
        '<link rel="alternate" type="application/rss+xml" '
        'title="Show Podcast" href="/feed/audio/">',
      );
      check(
        discoverFeedUrl(html, page),
      ).equals('https://example.com/feed/audio/');
    });

    test('skips links that are not RSS alternates', () {
      final html = htmlWith(
        '<link rel="stylesheet" href="/style.css">'
        '<link rel="alternate" type="application/atom+xml" href="/atom">',
      );
      check(discoverFeedUrl(html, page)).isNull();
    });
  });
}
