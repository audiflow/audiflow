import 'package:audiflow_domain/patterns.dart';

/// Registry of all available smart playlist patterns.
///
/// Patterns are loaded from JSON configuration via
/// [SmartPlaylistPatternLoader].
class PatternRegistry {
  /// Creates a registry with optional pre-loaded patterns.
  PatternRegistry([List<SmartPlaylistPatternConfig>? patterns])
    : _patterns = patterns ?? [];

  /// Creates a registry from a JSON string.
  factory PatternRegistry.fromJson(String jsonString) {
    final patterns = SmartPlaylistPatternLoader.parse(jsonString);
    return PatternRegistry(patterns);
  }

  final List<SmartPlaylistPatternConfig> _patterns;

  /// All registered pattern configs.
  List<SmartPlaylistPatternConfig> get patterns => _patterns;

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
