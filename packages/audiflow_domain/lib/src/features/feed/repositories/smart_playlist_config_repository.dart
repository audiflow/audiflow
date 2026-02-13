import '../models/pattern_summary.dart';
import '../models/root_meta.dart';
import '../models/smart_playlist_pattern_config.dart';

/// Repository for fetching and caching split SmartPlaylist
/// configs.
abstract class SmartPlaylistConfigRepository {
  /// Fetches root meta from remote, falls back to cache on
  /// error.
  Future<RootMeta> fetchRootMeta();

  /// Returns assembled config for a pattern. Uses disk cache
  /// if version matches, otherwise fetches remotely.
  Future<SmartPlaylistPatternConfig> getConfig(PatternSummary summary);

  /// Finds matching pattern summary for a podcast.
  ///
  /// Uses `feedUrlHint` for quick pre-filtering.
  PatternSummary? findMatchingPattern(String? podcastGuid, String feedUrl);

  /// Evicts stale patterns based on version comparison.
  ///
  /// Removes cached patterns not in [latest] and patterns
  /// whose version has changed.
  Future<void> reconcileCache(List<PatternSummary> latest);

  /// Sets the current pattern summaries for matching.
  void setPatternSummaries(List<PatternSummary> summaries);
}
