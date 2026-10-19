import '../models/feed_link.dart';

/// Classifies [input] as a [FeedLink], or returns null when it is not a
/// web link (so it can be treated as a search term).
///
/// Accepts `http`/`https` URLs and the feed schemes podcast apps register
/// (`feed:`, `podcast:`, `pcast:`, `itpc:`). Links from Apple Podcasts,
/// Overcast, and Castro resolve through their Apple Podcasts ID; links
/// from services that never expose RSS are reported as unsupported.
FeedLink? parseFeedLink(String input) {
  final text = input.trim();
  if (text.isEmpty || _whitespace.hasMatch(text)) return null;

  final uri = Uri.tryParse(_stripFeedScheme(text));
  if (uri == null || !_isWebLink(uri)) return null;

  final host = uri.host.toLowerCase().replaceFirst(_wwwPrefix, '');
  final platformLink = _parsePlatformLink(host, uri.pathSegments);
  if (platformLink != null) return platformLink;

  // iOS and Android both block cleartext HTTP, so fetch over HTTPS.
  final secure = uri.removeFragment().replace(scheme: 'https');
  return FeedLink.direct(url: secure.toString());
}

final _whitespace = RegExp(r'\s');
final _wwwPrefix = RegExp('^www\\.');
final _feedScheme = RegExp('^(feed|podcast|pcast|itpc):', caseSensitive: false);
final _httpScheme = RegExp('^https?://', caseSensitive: false);
final _appleId = RegExp(r'^id(\d+)$');
final _overcastId = RegExp(r'^itunes(\d+)$');
final _digits = RegExp(r'^\d+$');

/// Turns `feed://host/x` into `https://host/x` and `feed:https://host/x`
/// into `https://host/x`; other text is returned unchanged.
String _stripFeedScheme(String text) {
  final match = _feedScheme.firstMatch(text);
  if (match == null) return text;
  final rest = text.substring(match.end);
  if (_httpScheme.hasMatch(rest)) return rest;
  return 'https:$rest';
}

bool _isWebLink(Uri uri) {
  final scheme = uri.scheme.toLowerCase();
  if (scheme != 'http' && scheme != 'https') return false;
  return uri.host.contains('.');
}

const _unsupportedHosts = {
  'open.spotify.com': 'Spotify',
  'spotify.com': 'Spotify',
  'spotify.link': 'Spotify',
  'youtube.com': 'YouTube',
  'm.youtube.com': 'YouTube',
  'music.youtube.com': 'YouTube',
  'youtu.be': 'YouTube',
  'pca.st': 'Pocket Casts',
  'pocketcasts.com': 'Pocket Casts',
  'play.pocketcasts.com': 'Pocket Casts',
};

FeedLink? _parsePlatformLink(String host, List<String> segments) {
  final unsupported = _unsupportedHosts[host];
  if (unsupported != null) {
    return FeedLink.unsupported(platformName: unsupported);
  }
  return switch (host) {
    'podcasts.apple.com' || 'itunes.apple.com' => _appleLink(segments),
    'overcast.fm' => _overcastLink(segments),
    'castro.fm' => _castroLink(segments),
    _ => null,
  };
}

/// `podcasts.apple.com/<country>/podcast/<slug>/id<digits>`
FeedLink _appleLink(List<String> segments) {
  for (final segment in segments) {
    final match = _appleId.firstMatch(segment);
    if (match != null) return FeedLink.itunes(itunesId: match.group(1)!);
  }
  return const FeedLink.unsupported(platformName: 'Apple Podcasts');
}

/// `overcast.fm/itunes<digits>/<slug>`; `overcast.fm/+<code>` episode
/// links carry no podcast ID.
FeedLink _overcastLink(List<String> segments) {
  final match = segments.isEmpty ? null : _overcastId.firstMatch(segments[0]);
  if (match == null) {
    return const FeedLink.unsupported(platformName: 'Overcast');
  }
  return FeedLink.itunes(itunesId: match.group(1)!);
}

/// `castro.fm/itunes/<digits>`; `castro.fm/podcast/<uuid>` links carry
/// no Apple Podcasts ID.
FeedLink _castroLink(List<String> segments) {
  final isItunesLink =
      segments.length == 2 &&
      segments[0] == 'itunes' &&
      _digits.hasMatch(segments[1]);
  if (!isItunesLink) return const FeedLink.unsupported(platformName: 'Castro');
  return FeedLink.itunes(itunesId: segments[1]);
}
