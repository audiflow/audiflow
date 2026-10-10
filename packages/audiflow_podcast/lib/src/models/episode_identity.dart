const _duplicateGuidSeparator = '::audiflow-dup:';

/// Storage key for a feed item whose [guid] already belongs to another
/// episode.
///
/// Some feeds reuse one guid for distinct items. The item that owns the
/// stored row keeps the raw guid; any other item with that guid is stored
/// under this key, derived from its own enclosure URL so it stays the same
/// on every refresh.
String duplicateGuidKey(String guid, String enclosureUrl) =>
    '$guid$_duplicateGuidSeparator$enclosureUrl';
