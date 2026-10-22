/// Synthetic iTunes ID for a podcast added by feed URL rather than from the
/// podcast directory (OPML import, pasted feed link).
///
/// The `opml:` prefix predates feed links; it is kept so existing
/// subscriptions keep their IDs and analytics keeps filtering them out.
/// The same feed URL always yields the same ID.
String feedPlaceholderId(String feedUrl) {
  final hash = feedUrl.hashCode.toRadixString(16);
  return '$feedPlaceholderIdPrefix$hash';
}

/// Prefix of every [feedPlaceholderId].
const feedPlaceholderIdPrefix = 'opml:';
