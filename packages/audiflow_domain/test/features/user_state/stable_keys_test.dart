import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:audiflow_podcast/audiflow_podcast.dart' show duplicateGuidKey;
import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('podcastKeyFor', () {
    test('is stable and 22 base64url characters', () {
      final key = podcastKeyFor(feedUrl: 'https://example.com/feed.xml');

      check(key).equals(podcastKeyFor(feedUrl: 'https://example.com/feed.xml'));
      check(key).matchesPattern(RegExp(r'^[A-Za-z0-9_-]{22}$'));
    });

    test('prefers the podcast guid over the feed URL', () {
      final byGuid = podcastKeyFor(
        podcastGuid: 'abc',
        feedUrl: 'https://example.com/feed.xml',
      );

      check(byGuid).equals(
        podcastKeyFor(podcastGuid: 'abc', feedUrl: 'https://other.example/x'),
      );
      check(byGuid).not(
        (it) =>
            it.equals(podcastKeyFor(feedUrl: 'https://example.com/feed.xml')),
      );
    });

    test('treats a blank guid as absent', () {
      check(
        podcastKeyFor(podcastGuid: '  ', feedUrl: 'https://example.com/f'),
      ).equals(podcastKeyFor(feedUrl: 'https://example.com/f'));
    });

    test('ignores guid case and surrounding whitespace', () {
      check(
        podcastKeyFor(podcastGuid: ' ABC-1 ', feedUrl: 'https://a.example/f'),
      ).equals(
        podcastKeyFor(podcastGuid: 'abc-1', feedUrl: 'https://a.example/f'),
      );
    });

    test('never lets a guid collide with a URL of the same text', () {
      check(
        podcastKeyFor(
          podcastGuid: 'example.com/f',
          feedUrl: 'https://x.example/',
        ),
      ).not((it) => it.equals(podcastKeyFor(feedUrl: 'https://example.com/f')));
    });

    final sameFeed = [
      'http://example.com/feed.xml',
      'https://EXAMPLE.com/feed.xml',
      'https://example.com:443/feed.xml',
      'http://example.com:80/feed.xml',
      'https://example.com/feed.xml/',
      'https://example.com/feed.xml#top',
      ' https://example.com/feed.xml ',
    ];
    for (final url in sameFeed) {
      test('gives $url the same key as the canonical URL', () {
        check(
          podcastKeyFor(feedUrl: url),
        ).equals(podcastKeyFor(feedUrl: 'https://example.com/feed.xml'));
      });
    }

    final otherFeeds = [
      'https://example.com/Feed.xml',
      'https://example.com/feed.xml?id=2',
      'https://example.com:8443/feed.xml',
      'https://www.example.com/feed.xml',
    ];
    for (final url in otherFeeds) {
      test('keeps $url apart from the canonical URL', () {
        check(podcastKeyFor(feedUrl: url)).not(
          (it) =>
              it.equals(podcastKeyFor(feedUrl: 'https://example.com/feed.xml')),
        );
      });
    }
  });

  group('episodeKeyFor', () {
    final podcast = podcastKeyFor(feedUrl: 'https://example.com/feed.xml');
    final other = podcastKeyFor(feedUrl: 'https://example.com/other.xml');

    test('is stable and 22 base64url characters', () {
      final key = episodeKeyFor(podcast, 'guid-1');

      check(key).equals(episodeKeyFor(podcast, 'guid-1'));
      check(key).matchesPattern(RegExp(r'^[A-Za-z0-9_-]{22}$'));
    });

    test('differs between podcasts for the same guid', () {
      check(
        episodeKeyFor(podcast, 'guid-1'),
      ).not((it) => it.equals(episodeKeyFor(other, 'guid-1')));
    });

    test('gives items sharing one guid distinct keys', () {
      final raw = episodeKeyFor(podcast, 'guid-1');
      final duplicate = episodeKeyFor(
        podcast,
        duplicateGuidKey('guid-1', 'https://example.com/b.mp3'),
      );

      check(raw).not((it) => it.equals(duplicate));
    });

    test('never equals a podcast key', () {
      check(episodeKeyFor(podcast, '')).not((it) => it.equals(podcast));
    });
  });
}
