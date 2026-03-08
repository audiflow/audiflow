import 'smart_playlist_sort.dart';

/// Whether a smart playlist splits into separate playlists or
/// groups inside one playlist.
enum PlaylistStructure {
  /// Each resolver result becomes a separate top-level playlist.
  split,

  /// All resolver results are collected as groups inside a single
  /// parent playlist.
  grouped,
}

/// How groups relate to year headers in the group list view.
enum YearBinding {
  /// No year headers.
  none,

  /// Each group appears once, placed under the year of its
  /// earliest episode.
  pinToYear,

  /// A group appears under each year it has episodes in.
  splitByYear,
}

/// A group within a smart playlist containing episodes.
final class SmartPlaylistGroup {
  const SmartPlaylistGroup({
    required this.id,
    required this.displayName,
    required this.episodeIds,
    this.sortKey = 0,
    this.thumbnailUrl,
    this.yearOverride,
    this.showDateRange = false,
    this.earliestDate,
    this.latestDate,
    this.totalDurationMs,
  });

  /// Unique identifier within the parent playlist.
  final String id;

  /// Display name for the group.
  final String displayName;

  /// Sort key for ordering groups.
  final int sortKey;

  /// Episode IDs belonging to this group.
  final List<int> episodeIds;

  /// Thumbnail URL from the latest episode in this group.
  final String? thumbnailUrl;

  /// Per-group override of the parent playlist's yearBinding.
  final YearBinding? yearOverride;

  /// Whether this group shows date range and duration metadata.
  final bool showDateRange;

  /// Earliest episode publish date in this group.
  final DateTime? earliestDate;

  /// Latest episode publish date in this group.
  final DateTime? latestDate;

  /// Total duration of all episodes in milliseconds.
  final int? totalDurationMs;

  /// Number of episodes in this group.
  int get episodeCount => episodeIds.length;

  /// Returns display name with optional season number prefix.
  String formattedDisplayName({required bool prependSeasonNumber}) {
    if (prependSeasonNumber && 0 < sortKey) {
      return 'S$sortKey $displayName';
    }
    return displayName;
  }
}

/// Represents a smart playlist grouping of episodes within a podcast.
final class SmartPlaylist {
  const SmartPlaylist({
    required this.id,
    required this.displayName,
    required this.sortKey,
    required this.episodeIds,
    this.thumbnailUrl,
    this.playlistStructure = PlaylistStructure.split,
    this.yearBinding = YearBinding.none,
    this.showDateRange = false,
    this.userSortable = true,
    this.prependSeasonNumber = false,
    this.groupSort,
    this.groups,
  });

  /// Unique identifier within podcast.
  final String id;

  /// Display name.
  final String displayName;

  /// Sort key for ordering smart playlists.
  final int sortKey;

  /// Episode IDs belonging to this smart playlist.
  final List<int> episodeIds;

  /// Thumbnail URL from the latest episode in this smart playlist.
  final String? thumbnailUrl;

  /// Whether this playlist splits into separate playlists or groups.
  final PlaylistStructure playlistStructure;

  /// How groups relate to year headers in the group list view.
  final YearBinding yearBinding;

  /// Whether group cards should display a date range.
  final bool showDateRange;

  /// Whether the user can toggle the sort order.
  final bool userSortable;

  /// Whether to prepend a season number label (e.g. "S13") to group titles.
  final bool prependSeasonNumber;

  /// Sort rule for ordering groups within this playlist.
  final SmartPlaylistSortRule? groupSort;

  /// Groups within this playlist (when playlistStructure == grouped).
  final List<SmartPlaylistGroup>? groups;

  /// Number of episodes in this smart playlist.
  int get episodeCount => episodeIds.length;

  /// Returns display name with optional season number prefix.
  String get formattedDisplayName {
    if (prependSeasonNumber && 0 < sortKey) {
      return 'S$sortKey $displayName';
    }
    return displayName;
  }

  /// Creates a copy with optional field overrides.
  SmartPlaylist copyWith({
    String? id,
    String? displayName,
    int? sortKey,
    List<int>? episodeIds,
    String? thumbnailUrl,
    PlaylistStructure? playlistStructure,
    YearBinding? yearBinding,
    bool? showDateRange,
    bool? userSortable,
    bool? prependSeasonNumber,
    SmartPlaylistSortRule? groupSort,
    List<SmartPlaylistGroup>? groups,
  }) {
    return SmartPlaylist(
      id: id ?? this.id,
      displayName: displayName ?? this.displayName,
      sortKey: sortKey ?? this.sortKey,
      episodeIds: episodeIds ?? this.episodeIds,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      playlistStructure: playlistStructure ?? this.playlistStructure,
      yearBinding: yearBinding ?? this.yearBinding,
      showDateRange: showDateRange ?? this.showDateRange,
      userSortable: userSortable ?? this.userSortable,
      prependSeasonNumber: prependSeasonNumber ?? this.prependSeasonNumber,
      groupSort: groupSort ?? this.groupSort,
      groups: groups ?? this.groups,
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

  /// Resolver type that produced this grouping.
  final String resolverType;

  /// True if there are ungrouped episodes.
  bool get hasUngrouped => ungroupedEpisodeIds.isNotEmpty;
}
