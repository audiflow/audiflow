/// Summary of a pattern from root meta.json.
///
/// Used for browse lists, feed URL pre-filtering, and
/// version-based cache invalidation.
final class PatternSummary {
  const PatternSummary({
    required this.id,
    required this.version,
    required this.displayName,
    required this.feedUrlHint,
    required this.playlistCount,
  });

  factory PatternSummary.fromJson(Map<String, dynamic> json) {
    return PatternSummary(
      id: json['id'] as String,
      version: json['version'] as int,
      displayName: json['displayName'] as String,
      feedUrlHint: json['feedUrlHint'] as String,
      playlistCount: json['playlistCount'] as int,
    );
  }

  /// Unique identifier for this pattern.
  final String id;

  /// Schema version for cache invalidation.
  final int version;

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
      'version': version,
      'displayName': displayName,
      'feedUrlHint': feedUrlHint,
      'playlistCount': playlistCount,
    };
  }
}
