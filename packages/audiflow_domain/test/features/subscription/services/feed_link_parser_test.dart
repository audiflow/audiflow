import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  void expectLink(String input, FeedLink? expected) {
    check(parseFeedLink(input)).equals(expected);
  }

  group('parseFeedLink', () {
    group('not a link', () {
      for (final input in [
        '',
        '   ',
        'rebuild fm',
        'example.com/feed',
        'ftp://example.com/feed.xml',
        'https://localhost/feed',
        'mailto:host@example.com',
      ]) {
        test('returns null for "$input"', () => expectLink(input, null));
      }
    });

    group('direct feed URLs', () {
      test('keeps an https URL, including its query', () {
        expectLink(
          'https://example.com/feed.xml?token=abc',
          const FeedLink.direct(url: 'https://example.com/feed.xml?token=abc'),
        );
      });

      test('trims surrounding whitespace', () {
        expectLink(
          '  https://example.com/feed.xml\n',
          const FeedLink.direct(url: 'https://example.com/feed.xml'),
        );
      });

      test('upgrades http to https', () {
        expectLink(
          'http://example.com/feed.xml',
          const FeedLink.direct(url: 'https://example.com/feed.xml'),
        );
      });

      test('drops the fragment', () {
        expectLink(
          'https://example.com/feed.xml#top',
          const FeedLink.direct(url: 'https://example.com/feed.xml'),
        );
      });

      for (final scheme in ['feed', 'podcast', 'pcast', 'itpc', 'FEED']) {
        test('maps $scheme:// to https', () {
          expectLink(
            '$scheme://example.com/feed.xml',
            const FeedLink.direct(url: 'https://example.com/feed.xml'),
          );
        });
      }

      test('unwraps feed:https:// URLs', () {
        expectLink(
          'feed:https://example.com/feed.xml',
          const FeedLink.direct(url: 'https://example.com/feed.xml'),
        );
      });
    });

    group('podcast app links', () {
      test('reads the ID from an Apple Podcasts link', () {
        expectLink(
          'https://podcasts.apple.com/jp/podcast/rebuild/id603013428?i=1000',
          const FeedLink.itunes(itunesId: '603013428'),
        );
      });

      test('reads the ID from a legacy iTunes link', () {
        expectLink(
          'https://itunes.apple.com/us/podcast/id603013428',
          const FeedLink.itunes(itunesId: '603013428'),
        );
      });

      test('reads the ID from an Overcast link', () {
        expectLink(
          'https://overcast.fm/itunes603013428/rebuild',
          const FeedLink.itunes(itunesId: '603013428'),
        );
      });

      test('reads the ID from a Castro link', () {
        expectLink(
          'https://castro.fm/itunes/603013428',
          const FeedLink.itunes(itunesId: '603013428'),
        );
      });

      test('ignores the www prefix', () {
        expectLink(
          'https://www.overcast.fm/itunes603013428',
          const FeedLink.itunes(itunesId: '603013428'),
        );
      });

      for (final (url, platform) in [
        ('https://podcasts.apple.com/us/browse', 'Apple Podcasts'),
        ('https://overcast.fm/+AbCdEf', 'Overcast'),
        ('https://castro.fm/podcast/0f1e2d3c', 'Castro'),
        ('https://open.spotify.com/show/abc', 'Spotify'),
        ('https://spotify.link/abc', 'Spotify'),
        ('https://www.youtube.com/@channel', 'YouTube'),
        ('https://pca.st/abcd', 'Pocket Casts'),
      ]) {
        test('reports $url as unsupported', () {
          expectLink(url, FeedLink.unsupported(platformName: platform));
        });
      }
    });
  });

  group('feedPlaceholderId', () {
    test('is stable and carries the placeholder prefix', () {
      const url = 'https://example.com/feed.xml';
      check(feedPlaceholderId(url))
        ..equals(feedPlaceholderId(url))
        ..startsWith(feedPlaceholderIdPrefix);
    });
  });
}
