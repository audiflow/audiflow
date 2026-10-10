/// Joins the guid and enclosure URL in a [duplicateGuidKey].
const duplicateGuidSeparator = '::audiflow-dup:';

/// Storage key for a feed item whose [guid] already belongs to another
/// episode.
///
/// Some feeds reuse one guid for distinct items. The item that owns the
/// stored row keeps the raw guid; any other item with that guid is stored
/// under this key, derived from its own enclosure URL so it stays the same
/// on every refresh.
String duplicateGuidKey(String guid, String enclosureUrl) =>
    '$guid$duplicateGuidSeparator$enclosureUrl';

/// The feed guid a storage key was built from: the guid itself for a raw
/// key, or the guid part of a [duplicateGuidKey].
String guidOfStorageKey(String key) {
  final separatorAt = key.indexOf(duplicateGuidSeparator);
  return separatorAt == -1 ? key : key.substring(0, separatorAt);
}
