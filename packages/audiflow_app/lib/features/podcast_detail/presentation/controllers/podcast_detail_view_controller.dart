import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'podcast_detail_view_controller.g.dart';

/// Ephemeral view preferences for non-subscribed podcasts.
///
/// Subscribed podcasts persist preferences via
/// [podcastViewPreferenceControllerProvider]. This notifier
/// provides the same interface for non-subscribed podcasts
/// without persistence.
@riverpod
class LocalViewPreference extends _$LocalViewPreference {
  @override
  ({
    PodcastViewMode mode,
    EpisodeFilter filter,
    SortOrder sortOrder,
    SmartPlaylist? activePlaylist,
  })
  build() => (
    mode: PodcastViewMode.episodes,
    filter: EpisodeFilter.all,
    sortOrder: SortOrder.descending,
    activePlaylist: null,
  );

  /// Updates the view mode (episodes vs smart playlists).
  void setViewMode(PodcastViewMode mode) => state = (
    mode: mode,
    filter: state.filter,
    sortOrder: state.sortOrder,
    activePlaylist: state.activePlaylist,
  );

  /// Updates the episode filter.
  void setFilter(EpisodeFilter filter) => state = (
    mode: state.mode,
    filter: filter,
    sortOrder: state.sortOrder,
    activePlaylist: state.activePlaylist,
  );

  /// Updates the episode sort order.
  void setSortOrder(SortOrder order) => state = (
    mode: state.mode,
    filter: state.filter,
    sortOrder: order,
    activePlaylist: state.activePlaylist,
  );

  /// Sets or clears the active smart playlist.
  void setActivePlaylist(SmartPlaylist? playlist) => state = (
    mode: state.mode,
    filter: state.filter,
    sortOrder: state.sortOrder,
    activePlaylist: playlist,
  );
}
