import 'episode_number_extractor.dart';
import 'season_episode_extractor.dart';
import 'season_sort.dart';
import 'season_title_extractor.dart';

/// Configuration for how to group episodes into seasons for a specific podcast.
final class SeasonPattern {
  const SeasonPattern({
    required this.id,
    this.podcastGuid,
    this.feedUrlPatterns,
    required this.resolverType,
    required this.config,
    this.priority = 0,
    this.customSort,
    this.titleExtractor,
    this.episodeNumberExtractor,
    this.seasonEpisodeExtractor,
  });

  /// Unique identifier for this pattern.
  final String id;

  /// Match by podcast GUID (checked first).
  final String? podcastGuid;

  /// Match by feed URL regex patterns (anchored matching with ^$).
  final List<String>? feedUrlPatterns;

  /// Which resolver type to use (e.g., "rss", "title_appearance").
  final String resolverType;

  /// Resolver-specific configuration.
  final Map<String, dynamic> config;

  /// Priority for pattern ordering (higher = checked first).
  final int priority;

  /// Custom default sort for seasons from this pattern.
  final SeasonSortSpec? customSort;

  /// Custom title extractor for generating season display names.
  ///
  /// When provided, overrides the default title generation logic.
  final SeasonTitleExtractor? titleExtractor;

  /// Custom episode number extractor for on-demand extraction.
  ///
  /// When provided, extracts episode-in-season numbers from episode titles.
  final EpisodeNumberExtractor? episodeNumberExtractor;

  /// Extracts both season and episode numbers from episode title prefix.
  ///
  /// When provided, extracts values can override RSS metadata.
  /// Useful for podcasts with unreliable RSS metadata but reliable title
  /// encoding.
  final SeasonEpisodeExtractor? seasonEpisodeExtractor;

  /// Returns true if this pattern matches the given podcast.
  bool matchesPodcast(String? guid, String feedUrl) {
    // Match by GUID first
    if (podcastGuid != null && guid == podcastGuid) {
      return true;
    }

    // Try feedUrlPatterns (anchored matching)
    if (feedUrlPatterns != null) {
      for (final pattern in feedUrlPatterns!) {
        final regex = RegExp('^$pattern\$');
        if (regex.hasMatch(feedUrl)) {
          return true;
        }
      }
    }

    return false;
  }
}
