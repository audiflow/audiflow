import 'package:audiflow_domain/patterns.dart';

/// Registry of all available smart playlist patterns.
///
/// Patterns are now loaded from JSON configuration via
/// [SmartPlaylistPatternLoader] instead of hardcoded constants.
/// The CLI debug command still uses the legacy [SmartPlaylistPattern]
/// model for extraction diagnostics; a full migration is planned.
class PatternRegistry {
  /// All registered patterns (empty by default).
  ///
  /// Call [loadFromJson] to populate from JSON config.
  List<SmartPlaylistPattern> get patterns => [];

  /// Finds a pattern by its ID.
  SmartPlaylistPattern? findById(String id) {
    for (final pattern in patterns) {
      if (pattern.id == id) {
        return pattern;
      }
    }
    return null;
  }

  /// Detects a pattern from a feed URL.
  SmartPlaylistPattern? detectFromUrl(String feedUrl) {
    for (final pattern in patterns) {
      if (pattern.matchesPodcast(null, feedUrl)) {
        return pattern;
      }
    }
    return null;
  }

  /// Lists all patterns with their metadata.
  List<SmartPlaylistPattern> listPatterns() => patterns;
}
