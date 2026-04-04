/// Sort order for the podcast subscriptions list.
enum PodcastSortOrder {
  /// Sort by newest episode publishedAt (descending).
  latestEpisode,

  /// Sort by subscription date (descending).
  subscribedAt,

  /// Sort alphabetically by podcast title (ascending, case-insensitive).
  alphabetical;

  /// Parses a [name] string into a [PodcastSortOrder].
  ///
  /// Returns [defaultValue] when [name] does not match any value.
  static PodcastSortOrder fromName(
    String name, {
    PodcastSortOrder defaultValue = PodcastSortOrder.latestEpisode,
  }) {
    for (final value in values) {
      if (value.name == name) return value;
    }
    return defaultValue;
  }
}
