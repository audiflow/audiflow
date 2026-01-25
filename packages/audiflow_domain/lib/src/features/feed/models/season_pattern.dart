import 'season_sort.dart';

/// Configuration for how to group episodes into seasons for a specific podcast.
final class SeasonPattern {
  const SeasonPattern({
    required this.id,
    this.podcastGuid,
    this.feedUrlPattern,
    required this.resolverType,
    required this.config,
    this.priority = 0,
    this.customSort,
  });

  /// Unique identifier for this pattern.
  final String id;

  /// Match by podcast GUID (checked first).
  final String? podcastGuid;

  /// Match by feed URL regex pattern (fallback).
  final String? feedUrlPattern;

  /// Which resolver type to use (e.g., "rss", "title_appearance").
  final String resolverType;

  /// Resolver-specific configuration.
  final Map<String, dynamic> config;

  /// Priority for pattern ordering (higher = checked first).
  final int priority;

  /// Custom default sort for seasons from this pattern.
  final SeasonSortSpec? customSort;

  /// Returns true if this pattern matches the given podcast.
  bool matchesPodcast(String? guid, String feedUrl) {
    // Match by GUID first
    if (podcastGuid != null && guid == podcastGuid) {
      return true;
    }

    // Fall back to feed URL pattern
    if (feedUrlPattern != null) {
      final regex = RegExp(feedUrlPattern!);
      if (regex.hasMatch(feedUrl)) {
        return true;
      }
    }

    return false;
  }
}
