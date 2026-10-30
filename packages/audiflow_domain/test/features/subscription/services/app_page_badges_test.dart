import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:audiflow_domain/src/features/subscription/services/app_page_badges.dart';
import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  String pageWith(String badges) =>
      '<!DOCTYPE html><html><body><div>$badges</div></body></html>';

  // Badge rows as served by overcast.fm/+<code> pages.
  const overcastApple =
      '<a href="https://podcasts.apple.com/podcast/id1237931798"\n'
      '    ><img src="/img/badge-apple.svg"/></a>';
  const overcastRss =
      '<a href="https://feeds.megaphone.fm/ep-wswb"\n'
      '    ><img src="/img/badge-rss.svg"/></a>';

  // Badge rows as served by castro.fm/podcast and /episode pages.
  const castroApple =
      '<a href="https://geo.itunes.apple.com/ca/podcast/feed/id1200361736'
      '?at=11lLuB"><img alt="Listen On Apple Podcasts" '
      'src="/railsassets/apple-ba625a7d.png" /></a>';
  const castroOvercast =
      '<a href="https://overcast.fm/itunes1200361736"><img alt="Listen In '
      'Overcast" src="/railsassets/overcast-4dd0db35.png" /></a>';
  const castroRss =
      '<a href="https://feeds.simplecast.com/54nAGcIl"><img alt="Subscribe '
      'to RSS" src="/railsassets/rss-d2f1bc8a.png" /></a>';

  group('Overcast', () {
    test('prefers the Apple Podcasts badge', () {
      check(
        showLinkFromBadges(pageWith('$overcastRss$overcastApple')),
      ).equals(const FeedLink.itunes(itunesId: '1237931798'));
    });

    test('falls back to the RSS badge', () {
      check(showLinkFromBadges(pageWith(overcastRss))).equals(
        const FeedLink.direct(url: 'https://feeds.megaphone.fm/ep-wswb'),
      );
    });
  });

  group('Castro', () {
    test('prefers the Apple Podcasts badge', () {
      check(
        showLinkFromBadges(pageWith('$castroApple$castroOvercast$castroRss')),
      ).equals(const FeedLink.itunes(itunesId: '1200361736'));
    });

    test('falls back to the RSS badge', () {
      check(showLinkFromBadges(pageWith('$castroOvercast$castroRss'))).equals(
        const FeedLink.direct(url: 'https://feeds.simplecast.com/54nAGcIl'),
      );
    });
  });

  test('upgrades an http RSS badge to https and unescapes it', () {
    const badge =
        '<a href="http://example.com/feed?a=1&amp;b=2">'
        '<img src="/img/badge-rss.svg"></a>';
    check(
      showLinkFromBadges(pageWith(badge)),
    ).equals(const FeedLink.direct(url: 'https://example.com/feed?a=1&b=2'));
  });

  test('ignores links that are not badges', () {
    const unrelated =
        '<a href="https://podcasts.apple.com/podcast/id999">Other show</a>'
        '<a href="https://example.com/x"><img src="/img/pineapple.png"></a>';
    check(showLinkFromBadges(pageWith(unrelated))).isNull();
  });

  test('returns null for a page without badges', () {
    check(showLinkFromBadges(pageWith(''))).isNull();
  });
}
