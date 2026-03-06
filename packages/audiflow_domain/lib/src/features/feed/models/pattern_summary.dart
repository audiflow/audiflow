/// Summary of a pattern from root meta.json.
///
/// Used for browse lists, feed URL pre-filtering, and
/// version-based cache invalidation.
final class PatternSummary {
  const PatternSummary({
    required this.id,
    required this.dataVersion,
    required this.displayName,
    required this.feedUrlHint,
    required this.playlistCount,
  });

  factory PatternSummary.fromJson(Map<String, dynamic> json) {
    return PatternSummary(
      id: json['id'] as String,
      dataVersion: (json['dataVersion'] as int?) ?? 1,
      displayName: json['displayName'] as String,
      feedUrlHint: json['feedUrlHint'] as String,
      playlistCount: json['playlistCount'] as int,
    );
  }

  /// Unique identifier for this pattern.
  final String id;

  /// Data version for cache invalidation.
  final int dataVersion;

  /// Human-readable name for display.
  final String displayName;

  /// Partial feed URL for pre-filtering.
  final String feedUrlHint;

  /// Number of playlists in this pattern.
  final int playlistCount;

  /// Converts to JSON representation.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'dataVersion': dataVersion,
      'displayName': displayName,
      'feedUrlHint': feedUrlHint,
      'playlistCount': playlistCount,
    };
  }
}
