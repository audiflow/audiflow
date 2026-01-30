import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/episode_filter.dart';
import '../models/podcast_view_mode.dart';
import '../models/smart_playlist_sort.dart';
import '../repositories/podcast_view_preference_repository.dart';

part 'podcast_view_preference_providers.g.dart';

/// Watches podcast view preference for a given podcast ID.
///
/// Returns defaults if no preference is stored.
@riverpod
Stream<PodcastViewPreferenceData> podcastViewPreference(
  Ref ref,
  int podcastId,
) {
  final repo = ref.watch(podcastViewPreferenceRepositoryProvider);
  return repo.watchPreference(podcastId);
}

/// Controller for updating podcast view preferences.
///
/// Persists changes to Drift database immediately.
@riverpod
class PodcastViewPreferenceController
    extends _$PodcastViewPreferenceController {
  @override
  Future<PodcastViewPreferenceData> build(int podcastId) async {
    final repo = ref.watch(podcastViewPreferenceRepositoryProvider);
    return repo.getPreference(podcastId);
  }

  /// Sets the view mode and persists to database.
  Future<void> setViewMode(PodcastViewMode mode) async {
    final repo = ref.read(podcastViewPreferenceRepositoryProvider);
    await repo.updateViewMode(podcastId, mode);
    ref.invalidateSelf();
  }

  /// Toggles between episodes and smart playlists view modes.
  Future<void> toggleViewMode() async {
    final current = state.value;
    if (current == null) return;

    final newMode = current.viewMode == PodcastViewMode.episodes
        ? PodcastViewMode.smartPlaylists
        : PodcastViewMode.episodes;
    await setViewMode(newMode);
  }

  /// Sets the episode filter and persists to database.
  Future<void> setEpisodeFilter(EpisodeFilter filter) async {
    final repo = ref.read(podcastViewPreferenceRepositoryProvider);
    await repo.updateEpisodeFilter(podcastId, filter);
    ref.invalidateSelf();
  }

  /// Sets the episode sort order and persists to database.
  Future<void> setEpisodeSortOrder(SortOrder order) async {
    final repo = ref.read(podcastViewPreferenceRepositoryProvider);
    await repo.updateEpisodeSortOrder(podcastId, order);
    ref.invalidateSelf();
  }

  /// Toggles episode sort order between ascending and descending.
  Future<void> toggleEpisodeSortOrder() async {
    final current = state.value;
    if (current == null) return;

    final newOrder = current.episodeSortOrder == SortOrder.ascending
        ? SortOrder.descending
        : SortOrder.ascending;
    await setEpisodeSortOrder(newOrder);
  }

  /// Selects a smart playlist for inline display.
  ///
  /// Sets view mode to smartPlaylists and persists the
  /// selected playlist ID.
  Future<void> selectPlaylist(String playlistId) async {
    final repo = ref.read(podcastViewPreferenceRepositoryProvider);
    await repo.updateSelectedPlaylistId(podcastId, playlistId);
    ref.invalidateSelf();
  }

  /// Sets the smart playlist sort field and order, persists to
  /// database.
  Future<void> setSmartPlaylistSort(
    SmartPlaylistSortField field,
    SortOrder order,
  ) async {
    final repo = ref.read(podcastViewPreferenceRepositoryProvider);
    await repo.updateSmartPlaylistSort(podcastId, field, order);
    ref.invalidateSelf();
  }
}
