import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/podcast_detail_state.dart';
import 'podcast_detail_controller.dart';

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

/// Consolidated view controller for the podcast detail screen.
///
/// Merges feed data, subscription state, view preferences,
/// filtered episodes, progress, and smart playlists into a
/// single [PodcastDetailViewState].
@riverpod
Future<PodcastDetailViewState> podcastDetailView(
  Ref ref,
  String feedUrl,
  String podcastId,
) async {
  final feed = await ref.watch(podcastDetailProvider(feedUrl).future);
  final subscription = await ref.watch(
    subscriptionByFeedUrlProvider(feedUrl).future,
  );

  final prefs = await _resolvePreferences(ref, subscription);

  final filteredEpisodes = await ref.watch(
    filteredSortedEpisodesProvider(
      feedUrl,
      prefs.filter,
      prefs.sortOrder,
    ).future,
  );

  final progressMap = await ref.watch(
    podcastEpisodeProgressProvider(feedUrl).future,
  );

  final smartPlaylistData = await _resolveSmartPlaylists(
    ref,
    feedUrl,
    podcastId,
  );

  final feedImageUrl = feed.podcast.primaryImage?.url;

  return PodcastDetailViewState(
    feed: feed,
    viewMode: prefs.mode,
    episodeFilter: prefs.filter,
    episodeSortOrder: prefs.sortOrder,
    filteredEpisodes: filteredEpisodes,
    progressMap: progressMap,
    smartPlaylists: smartPlaylistData.playlists,
    isSubscribed: subscription != null,
    hasSmartPlaylistView: smartPlaylistData.hasView,
    activePlaylist: prefs.activePlaylist,
    feedImageUrl: feedImageUrl,
    subscriptionId: subscription?.id,
    pattern: smartPlaylistData.pattern,
  );
}

/// Resolves view preferences from persisted or local state.
Future<
  ({
    PodcastViewMode mode,
    EpisodeFilter filter,
    SortOrder sortOrder,
    SmartPlaylist? activePlaylist,
  })
>
_resolvePreferences(Ref ref, Subscription? subscription) async {
  if (subscription == null) {
    final local = ref.watch(localViewPreferenceProvider);
    return local;
  }

  final prefs = await ref.watch(
    podcastViewPreferenceControllerProvider(subscription.id).future,
  );
  return (
    mode: prefs.viewMode,
    filter: prefs.episodeFilter,
    sortOrder: prefs.episodeSortOrder,
    activePlaylist: null,
  );
}

/// Smart playlist resolution result.
typedef _SmartPlaylistData = ({
  List<SmartPlaylist> playlists,
  bool hasView,
  SmartPlaylistPatternConfig? pattern,
});

/// Resolves smart playlists and pattern for the feed.
Future<_SmartPlaylistData> _resolveSmartPlaylists(
  Ref ref,
  String feedUrl,
  String podcastId,
) async {
  final pattern = await ref.watch(
    smartPlaylistPatternByFeedUrlProvider(feedUrl).future,
  );

  final grouping = await ref.watch(
    sortedPodcastSmartPlaylistsProvider(feedUrl, podcastId).future,
  );

  final hasView = await ref.watch(
    hasSmartPlaylistViewAfterLoadProvider(feedUrl).future,
  );

  return (
    playlists: grouping?.playlists ?? [],
    hasView: hasView,
    pattern: pattern,
  );
}
