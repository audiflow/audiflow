/// Sub-category within a smart playlist for further episode grouping.
final class SmartPlaylistSubCategory {
  const SmartPlaylistSubCategory({
    required this.id,
    required this.displayName,
    required this.episodeIds,
    this.yearGrouped = false,
  });

  /// Unique identifier within the parent playlist.
  final String id;

  /// Display name for the sub-category section header.
  final String displayName;

  /// Episode IDs belonging to this sub-category.
  final List<int> episodeIds;

  /// Whether episodes in this sub-category are grouped by year.
  final bool yearGrouped;
}

/// Represents a smart playlist grouping of episodes within a podcast.
final class SmartPlaylist {
  const SmartPlaylist({
    required this.id,
    required this.displayName,
    required this.sortKey,
    required this.episodeIds,
    this.thumbnailUrl,
    this.yearGrouped = false,
    this.subCategories,
  });

  /// Unique identifier within podcast (e.g., "season_2", "arc_mystery").
  final String id;

  /// Display name (e.g., "Season 2", "The Vanishing").
  final String displayName;

  /// Sort key for ordering smart playlists.
  final int sortKey;

  /// Episode IDs belonging to this smart playlist.
  final List<int> episodeIds;

  /// Thumbnail URL from the latest episode in this smart playlist.
  final String? thumbnailUrl;

  /// Whether episodes in this playlist are grouped by year.
  final bool yearGrouped;

  /// Optional sub-categories for further grouping within this playlist.
  final List<SmartPlaylistSubCategory>? subCategories;

  /// Number of episodes in this smart playlist.
  int get episodeCount => episodeIds.length;

  /// Creates a copy with optional field overrides.
  SmartPlaylist copyWith({
    String? id,
    String? displayName,
    int? sortKey,
    List<int>? episodeIds,
    String? thumbnailUrl,
    bool? yearGrouped,
    List<SmartPlaylistSubCategory>? subCategories,
  }) {
    return SmartPlaylist(
      id: id ?? this.id,
      displayName: displayName ?? this.displayName,
      sortKey: sortKey ?? this.sortKey,
      episodeIds: episodeIds ?? this.episodeIds,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      yearGrouped: yearGrouped ?? this.yearGrouped,
      subCategories: subCategories ?? this.subCategories,
    );
  }
}

/// Result from a smart playlist resolver containing grouped playlists.
final class SmartPlaylistGrouping {
  const SmartPlaylistGrouping({
    required this.playlists,
    required this.ungroupedEpisodeIds,
    required this.resolverType,
  });

  /// Smart playlists detected by the resolver.
  final List<SmartPlaylist> playlists;

  /// Episode IDs that could not be grouped.
  final List<int> ungroupedEpisodeIds;

  /// Resolver type that produced this grouping (e.g., "rss", "title_pattern").
  final String resolverType;

  /// True if there are ungrouped episodes.
  bool get hasUngrouped => ungroupedEpisodeIds.isNotEmpty;
}
