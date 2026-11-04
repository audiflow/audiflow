/// Whether a feed can be fetched from [feedUrl]: an `http` or `https` address
/// with a host.
///
/// Anything else, such as an empty or relative URL, can only fail in the HTTP
/// client, so it must neither be stored nor be sent there.
bool isFetchableFeedUrl(String feedUrl) {
  final uri = Uri.tryParse(feedUrl);
  if (uri == null || uri.host.isEmpty) return false;
  return uri.isScheme('http') || uri.isScheme('https');
}

/// [feedUrl] followed by the same URL under the other of `http` and
/// `https`.
///
/// Feed links are upgraded to `https` while OPML imports keep the URL as
/// written, so one show can be stored under either scheme; duplicate
/// checks try both.
List<String> feedUrlVariants(String feedUrl) {
  final uri = Uri.tryParse(feedUrl);
  final otherScheme = switch (uri?.scheme) {
    'https' => 'http',
    'http' => 'https',
    _ => null,
  };
  if (uri == null || otherScheme == null) return [feedUrl];
  return [feedUrl, uri.replace(scheme: otherScheme).toString()];
}
