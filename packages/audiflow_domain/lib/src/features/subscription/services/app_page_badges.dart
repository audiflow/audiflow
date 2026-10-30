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
  final apple = _badgeHref(html, 'apple');
  if (apple != null) {
    final link = parseFeedLink(apple);
    if (link is ItunesFeedLink) return link;
  }
  final rss = _badgeHref(html, 'rss');
  if (rss == null) return null;
  final link = parseFeedLink(rss);
  return link is DirectFeedLink ? link : null;
}

/// The href of the first link wrapping a [name] badge image.
String? _badgeHref(String html, String name) {
  for (final match in _badge.allMatches(html)) {
    if (match.group(2)!.toLowerCase() != name) continue;
    return match.group(1)!.replaceAll('&amp;', '&');
  }
  return null;
}

// An <a href> whose first child is an <img> named after its directory:
// Overcast serves `/img/badge-apple.svg`, Castro `/railsassets/apple-<hash>.png`.
final _badge = RegExp(
  r'''<a\b[^>]*\bhref\s*=\s*["']([^"']+)["'][^>]*>\s*'''
  r'''<img\b[^>]*\bsrc\s*=\s*["'][^"']*/(?:badge-)?(apple|rss)[-.][^"']*["']''',
  caseSensitive: false,
);
