/// Whether [body] is an HTML page rather than a feed document.
bool looksLikeHtml(String body) {
  final head = body.length <= _sniffLength
      ? body
      : body.substring(0, _sniffLength);
  return _htmlTag.hasMatch(head);
}

/// The RSS feed URL a web page announces with
/// `<link rel="alternate" type="application/rss+xml" href="...">`, resolved
/// against [pageUrl] and upgraded to HTTPS; null when it announces none.
///
/// Podcast websites commonly carry this tag, so a pasted show homepage
/// still leads to its feed.
String? discoverFeedUrl(String html, Uri pageUrl) {
  for (final tag in _linkTag.allMatches(html)) {
    final attributes = _attributes(tag.group(0)!);
    final rel = attributes['rel']?.toLowerCase().split(_whitespace) ?? [];
    final type = attributes['type']?.toLowerCase();
    final href = attributes['href'];
    if (!rel.contains('alternate') || type != _rssType || href == null) {
      continue;
    }
    final resolved = pageUrl.resolve(href.trim());
    return resolved.replace(scheme: 'https').toString();
  }
  return null;
}

const _sniffLength = 1024;
const _rssType = 'application/rss+xml';
final _htmlTag = RegExp(r'<html[\s>]', caseSensitive: false);
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
