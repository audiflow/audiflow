/// Summary of a preset from root meta.json.
///
/// Used for browse lists, feed URL pre-filtering, and
/// version-based cache invalidation.
final class PresetSummary {
  const PresetSummary({
    required this.id,
    required this.dataVersion,
    required this.displayName,
    required this.feedUrlHints,
    required this.playlistCount,
  });

  factory PresetSummary.fromJson(Map<String, dynamic> json) {
    return PresetSummary(
      id: json['id'] as String,
      dataVersion: (json['dataVersion'] as int?) ?? 1,
      displayName: json['displayName'] as String,
      feedUrlHints: _parseFeedUrlHints(json['feedUrlHints']),
      playlistCount: json['playlistCount'] as int,
    );
  }

  /// Unique identifier for this preset.
  final String id;

  /// Data version for cache invalidation.
  final int dataVersion;

  /// Human-readable name for display.
  final String displayName;

  /// Feed URL substrings for pre-filtering, one per feed URL of the
  /// preset. A podcast that moved feeds matches on any of them.
  final List<String> feedUrlHints;

  /// Whether any hint is a substring of [feedUrl].
  bool matchesFeedUrl(String feedUrl) => feedUrlHints.any(feedUrl.contains);

  /// Number of playlists in this preset.
  final int playlistCount;

  /// Converts to JSON representation.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'dataVersion': dataVersion,
      'displayName': displayName,
      'feedUrlHints': feedUrlHints,
      'playlistCount': playlistCount,
    };
  }

  /// Throws [FormatException] for anything but a list of strings, which
  /// includes a v7 root index that carries the scalar `feedUrlHint`.
  static List<String> _parseFeedUrlHints(Object? raw) {
    if (raw is! List<dynamic> || raw.any((h) => h is! String)) {
      throw const FormatException(
        'Expected "feedUrlHints" to be a list of strings',
      );
    }
    return List.unmodifiable(raw.cast<String>());
  }
}
