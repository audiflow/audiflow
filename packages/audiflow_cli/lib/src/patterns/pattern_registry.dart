import 'package:audiflow_domain/patterns.dart';

/// Registry of all available smart playlist patterns.
///
/// Patterns are loaded from JSON configuration via
/// [SmartPlaylistPatternLoader].
class PatternRegistry {
  /// All registered pattern configs (empty by default).
  ///
  /// Call [loadFromJson] to populate from JSON config.
  List<SmartPlaylistPatternConfig> get patterns => [];

  /// Finds a pattern config by its ID.
  SmartPlaylistPatternConfig? findById(String id) {
    for (final pattern in patterns) {
      if (pattern.id == id) {
        return pattern;
      }
    }
    return null;
  }

  /// Detects a pattern config from a feed URL.
  SmartPlaylistPatternConfig? detectFromUrl(String feedUrl) {
    for (final pattern in patterns) {
      if (pattern.matchesPodcast(null, feedUrl)) {
        return pattern;
      }
    }
    return null;
  }

  /// Lists all pattern configs with their metadata.
  List<SmartPlaylistPatternConfig> listPatterns() => patterns;
}
