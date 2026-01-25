import 'package:audiflow_domain/audiflow_domain.dart';
// ignore: implementation_imports
import 'package:audiflow_domain/src/features/feed/patterns/coten_radio_pattern.dart';

/// Registry of all available season patterns.
class PatternRegistry {
  /// All registered patterns.
  List<SeasonPattern> get patterns => [cotenRadioPattern];

  /// Finds a pattern by its ID.
  SeasonPattern? findById(String id) {
    for (final pattern in patterns) {
      if (pattern.id == id) {
        return pattern;
      }
    }
    return null;
  }

  /// Detects a pattern from a feed URL.
  SeasonPattern? detectFromUrl(String feedUrl) {
    for (final pattern in patterns) {
      if (pattern.matchesPodcast(null, feedUrl)) {
        return pattern;
      }
    }
    return null;
  }

  /// Lists all patterns with their metadata.
  List<SeasonPattern> listPatterns() => patterns;
}
