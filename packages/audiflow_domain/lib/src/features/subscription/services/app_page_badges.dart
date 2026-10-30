import '../models/feed_link.dart';
import 'feed_link_parser.dart';

/// The show behind a podcast app's share page, read from its "listen on"
/// badges (an image link per directory); null when the page has none.
///
/// Overcast and Castro pages both carry an Apple Podcasts badge and an RSS
/// badge. The Apple badge wins, so the show matches a subscription made
/// from search; shows missing from the Apple directory carry only the RSS
/// badge, which links to the feed itself.
///
/// This reads the apps' markup, which they may change; a page whose badges
/// no longer match yields null rather than a wrong show.
FeedLink? showLinkFromBadges(String html) {
  // A commented-out badge is not shown, so it must not pick the show.
  final live = html.replaceAll(_comment, '');
  final links = [
    for (final name in const ['apple', 'rss'])
      for (final href in _badgeHrefs(live, name)) parseFeedLink(href),
  ];
  return links.whereType<ItunesFeedLink>().firstOrNull ??
      links.whereType<DirectFeedLink>().firstOrNull;
}

/// The hrefs of the links wrapping a [name] badge image, in page order.
Iterable<String> _badgeHrefs(String html, String name) sync* {
  for (final match in _badge.allMatches(html)) {
    if (match.group(2)!.toLowerCase() != name) continue;
    yield match.group(1)!.replaceAll('&amp;', '&');
  }
}

final _comment = RegExp(r'<!--[\s\S]*?-->');

// An <a href> whose first child is an <img> named after its directory:
// Overcast serves `/img/badge-apple.svg`, Castro `/railsassets/apple-<hash>.png`.
final _badge = RegExp(
  r'''<a\b[^>]*\bhref\s*=\s*["']([^"']+)["'][^>]*>\s*'''
  r'''<img\b[^>]*\bsrc\s*=\s*["'][^"']*/(?:badge-)?(apple|rss)[-.][^"']*["']''',
  caseSensitive: false,
);
