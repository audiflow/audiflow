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
