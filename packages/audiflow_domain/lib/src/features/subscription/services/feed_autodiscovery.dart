/// Whether [body] is an HTML page rather than a feed document.
///
/// Only the root element counts: feeds often embed whole HTML documents in
/// their show notes, so a tag anywhere else proves nothing.
bool looksLikeHtml(String body) => _htmlRoot.hasMatch(body);

/// The RSS feed URL a web page announces with
/// `<link rel="alternate" type="application/rss+xml" href="...">`, resolved
/// against [pageUrl] and upgraded to HTTPS; null when it announces none.
///
/// Podcast websites commonly carry this tag, so a pasted show homepage
/// still leads to its feed. Sites often announce their article and
/// comment feeds too, so a feed whose title or URL mentions "podcast" wins
/// over the first one listed.
String? discoverFeedUrl(String html, Uri pageUrl) {
  final feeds = [
    for (final tag in _linkTag.allMatches(html))
      ?_rssAlternate(_attributes(tag.group(0)!)),
  ];
  if (feeds.isEmpty) return null;
  final chosen = feeds.firstWhere(_mentionsPodcast, orElse: () => feeds.first);
  final resolved = pageUrl.resolve(chosen['href']!.trim());
  return resolved.replace(scheme: 'https').toString();
}

/// [attributes] when they describe an RSS alternate link with an href.
Map<String, String>? _rssAlternate(Map<String, String> attributes) {
  final rel = attributes['rel']?.toLowerCase().split(_whitespace) ?? [];
  final type = attributes['type']?.toLowerCase();
  final isFeed = rel.contains('alternate') && type == _rssType;
  return isFeed && attributes['href'] != null ? attributes : null;
}

bool _mentionsPodcast(Map<String, String> attributes) {
  final text = '${attributes['title'] ?? ''} ${attributes['href']}';
  return text.toLowerCase().contains('podcast');
}

const _rssType = 'application/rss+xml';
// Skips a byte order mark, XML declarations, processing instructions and
// comments before the root. The <html> tag is optional, so a doctype or
// <head> also marks a page.
final _htmlRoot = RegExp(
  r'^\uFEFF?\s*(?:(?:<\?[\s\S]*?\?>|<!--[\s\S]*?-->)\s*)*'
  r'<(?:!doctype\s+html|html|head)[\s>]',
  caseSensitive: false,
);
final _linkTag = RegExp(r'<link\b[^>]*>', caseSensitive: false);
final _attribute = RegExp(
  r'''([a-zA-Z-]+)\s*=\s*("([^"]*)"|'([^']*)'|([^\s>]+))''',
);
final _whitespace = RegExp(r'\s+');

Map<String, String> _attributes(String tag) {
  return {
    for (final match in _attribute.allMatches(tag))
      match.group(1)!.toLowerCase(): _unescape(
        match.group(3) ?? match.group(4) ?? match.group(5) ?? '',
      ),
  };
}

String _unescape(String value) => value.replaceAll('&amp;', '&');
