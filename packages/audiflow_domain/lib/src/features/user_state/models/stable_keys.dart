import 'dart:convert';

import 'package:crypto/crypto.dart';

/// Keys that name a podcast or an episode identically on every device.
///
/// Local Isar ids differ per device, and an episode's storage guid depends
/// on what that device fetched first, so user state that travels between
/// devices is addressed by these instead. See
/// docs/architecture/user-data-sync.md (stable keys).
///
/// Each key is fixed when first assigned and never recomputed: a feed that
/// moves or starts declaring `podcast:guid` later keeps its key. The inputs
/// are typed and versioned, so a guid can never produce the key of a URL,
/// and a future derivation can coexist with this one.
///
/// Keys are the first 128 bits of SHA-256, base64url without padding (22
/// characters): collision-free in practice at the scale of one library.

/// The key for a podcast: from its `podcast:guid` when the feed declares
/// one, otherwise from [feedUrl] (see [normalizeFeedUrlForKey]).
String podcastKeyFor({String? podcastGuid, required String feedUrl}) {
  final guid = podcastGuid?.trim().toLowerCase();
  if (guid != null && guid.isNotEmpty) {
    return _key('podcast:guid:v1:$guid');
  }
  return _key('podcast:url:v1:${normalizeFeedUrlForKey(feedUrl)}');
}

/// The key for an episode of the podcast keyed [podcastKey].
///
/// [storageGuid] is the episode's stored guid: the feed item guid, the
/// enclosure URL for an item without one, or a duplicate-guid key for an
/// item that reuses another item's guid, so two items sharing a guid get
/// distinct keys.
String episodeKeyFor(String podcastKey, String storageGuid) =>
    // The podcast key has a fixed length, so the separator cannot be
    // forged by either part.
    _key('episode:v1:$podcastKey:$storageGuid');

/// [feedUrl] reduced to what identifies the feed: hosts move between
/// `http` and `https` and add or drop default ports and trailing slashes
/// without the feed changing. The path, query, and any credentials stay as
/// they are: servers may treat path case as significant, and private feeds
/// tell subscribers apart by the credentials alone.
String normalizeFeedUrlForKey(String feedUrl) {
  final trimmed = feedUrl.trim();
  final uri = Uri.tryParse(trimmed);
  if (uri == null || uri.host.isEmpty) return trimmed;
  final hasDefaultPort =
      !uri.hasPort ||
      (uri.port == 80 && uri.scheme == 'http') ||
      (uri.port == 443 && uri.scheme == 'https');
  final port = hasDefaultPort ? '' : ':${uri.port}';
  var path = uri.path;
  while (path.endsWith('/')) {
    path = path.substring(0, path.length - 1);
  }
  final query = uri.hasQuery ? '?${uri.query}' : '';
  final userInfo = uri.userInfo.isEmpty ? '' : '${uri.userInfo}@';
  return '$userInfo${uri.host.toLowerCase()}$port$path$query';
}

String _key(String input) {
  final digest = sha256.convert(utf8.encode(input)).bytes.sublist(0, 16);
  return base64Url.encode(digest).replaceAll('=', '');
}
