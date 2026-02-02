/// Static group definition within a playlist.
///
/// Groups with a [pattern] match episodes by title regex.
/// Groups without a pattern act as fallback (catch-all).
final class SmartPlaylistGroupDef {
  const SmartPlaylistGroupDef({
    required this.id,
    required this.displayName,
    this.pattern,
  });

  /// Creates a group definition from JSON configuration.
  factory SmartPlaylistGroupDef.fromJson(Map<String, dynamic> json) {
    return SmartPlaylistGroupDef(
      id: json['id'] as String,
      displayName: json['displayName'] as String,
      pattern: json['pattern'] as String?,
    );
  }

  /// Unique identifier for this group within the playlist.
  final String id;

  /// Human-readable name for display.
  final String displayName;

  /// Regex pattern to match episode titles.
  ///
  /// When null, this group acts as a catch-all fallback.
  final String? pattern;

  /// Converts to JSON representation.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'displayName': displayName,
      if (pattern != null) 'pattern': pattern,
    };
  }
}
