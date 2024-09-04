/// Season distinction algorithm.
enum SeasonDistinction {
  /// Distinguish seasons by their number.
  /// Use this option for podcasts that properly manage their season numbers.
  seasonNum,

  /// Distinguish seasons by their title.
  /// Use this option for podcasts that do not properly manage their season
  /// numbers.
  /// Seasons are distinguished by comparing extracted season titles.
  title,
}

abstract class PodcastSeasonTitleExtractor {
  /// Podcast feed URL.
  String get feedUrl;

  /// Label of this extractor in listing.
  String get label;

  SeasonDistinction get distinction => SeasonDistinction.seasonNum;

  /// Extract season title from episode title.
  String? extractSeasonTitle({
    required String podcastTitle,
    required String title,
    required int? episodeNum,
    required int? seasonNum,
  }) =>
      title;

  /// Create the episode's display title under the season view.
  String stripEpisodeTitle({
    required String podcastTitle,
    required String title,
    required int? episodeNum,
    required int? seasonNum,
  }) =>
      title;
}
