/// Represents a season grouping of episodes within a podcast.
final class Season {
  const Season({
    required this.id,
    required this.displayName,
    required this.sortKey,
    required this.episodeIds,
    this.thumbnailUrl,
  });

  /// Unique identifier within podcast (e.g., "season_2", "arc_mystery").
  final String id;

  /// Display name (e.g., "Season 2", "The Vanishing").
  final String displayName;

  /// Sort key for ordering seasons.
  final int sortKey;

  /// Episode IDs belonging to this season.
  final List<int> episodeIds;

  /// Thumbnail URL from the latest episode in this season.
  final String? thumbnailUrl;

  /// Number of episodes in this season.
  int get episodeCount => episodeIds.length;

  /// Creates a copy with optional field overrides.
  Season copyWith({
    String? id,
    String? displayName,
    int? sortKey,
    List<int>? episodeIds,
    String? thumbnailUrl,
  }) {
    return Season(
      id: id ?? this.id,
      displayName: displayName ?? this.displayName,
      sortKey: sortKey ?? this.sortKey,
      episodeIds: episodeIds ?? this.episodeIds,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
    );
  }
}

/// Result from a season resolver containing grouped seasons.
final class SeasonGrouping {
  const SeasonGrouping({
    required this.seasons,
    required this.ungroupedEpisodeIds,
    required this.resolverType,
  });

  /// Seasons detected by the resolver.
  final List<Season> seasons;

  /// Episode IDs that could not be grouped.
  final List<int> ungroupedEpisodeIds;

  /// Resolver type that produced this grouping (e.g., "rss", "title_pattern").
  final String resolverType;

  /// True if there are ungrouped episodes.
  bool get hasUngrouped => ungroupedEpisodeIds.isNotEmpty;
}
