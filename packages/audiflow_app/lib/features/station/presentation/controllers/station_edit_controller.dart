import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'station_edit_controller.freezed.dart';
part 'station_edit_controller.g.dart';

/// Error keys for localization in the UI layer.
abstract final class StationEditError {
  static const nameRequired = 'name_required';
  static const podcastRequired = 'podcast_required';
  static const notFound = 'not_found';
  static String limitReached(int max) => 'limit_reached:$max';
}

/// Form state for station create/edit.
@freezed
sealed class StationEditState with _$StationEditState {
  const factory StationEditState({
    @Default('') String name,
    @Default({}) Set<int> selectedPodcastIds,
    @Default(StationPlaybackState.all) StationPlaybackState playbackState,
    @Default(false) bool filterDownloaded,
    @Default(false) bool filterFavorited,
    StationDurationFilter? durationFilter,
    int? publishedWithinDays,
    @Default(StationEpisodeSort.newest) StationEpisodeSort episodeSort,
    @Default(false) bool isSaving,
    String? error,
  }) = _StationEditState;
}

@riverpod
class StationEditController extends _$StationEditController {
  @override
  StationEditState build(int? stationId) {
    if (stationId != null) {
      _loadExistingStation(stationId);
    }
    return const StationEditState();
  }

  Future<void> _loadExistingStation(int id) async {
    final station = await ref.read(stationRepositoryProvider).findById(id);
    if (station == null) return;

    final podcasts = await ref
        .read(stationPodcastRepositoryProvider)
        .watchByStation(id)
        .first;

    state = state.copyWith(
      name: station.name,
      selectedPodcastIds: podcasts.map((p) => p.podcastId).toSet(),
      playbackState: station.playbackStateFilter,
      filterDownloaded: station.filterDownloaded,
      filterFavorited: station.filterFavorited,
      durationFilter: station.durationFilter,
      publishedWithinDays: station.publishedWithinDays,
      episodeSort: station.episodeSort,
    );
  }

  void setName(String name) => state = state.copyWith(name: name);

  void setPlaybackState(StationPlaybackState value) =>
      state = state.copyWith(playbackState: value);

  void setFilterDownloaded(bool value) =>
      state = state.copyWith(filterDownloaded: value);

  void setFilterFavorited(bool value) =>
      state = state.copyWith(filterFavorited: value);

  void setDurationFilter(StationDurationFilter? value) =>
      state = state.copyWith(durationFilter: value);

  void setPublishedWithinDays(int? value) =>
      state = state.copyWith(publishedWithinDays: value);

  void setEpisodeSort(StationEpisodeSort value) =>
      state = state.copyWith(episodeSort: value);

  void togglePodcast(int podcastId) {
    final ids = Set<int>.from(state.selectedPodcastIds);
    if (ids.contains(podcastId)) {
      ids.remove(podcastId);
    } else {
      ids.add(podcastId);
    }
    state = state.copyWith(selectedPodcastIds: ids);
  }

  /// Persists the station and reconciles episode membership.
  ///
  /// Returns the saved [Station] on success, null on failure.
  Future<Station?> save() async {
    final trimmedName = state.name.trim();
    if (trimmedName.isEmpty) {
      state = state.copyWith(error: StationEditError.nameRequired);
      return null;
    }

    if (state.selectedPodcastIds.isEmpty) {
      state = state.copyWith(error: StationEditError.podcastRequired);
      return null;
    }

    state = state.copyWith(isSaving: true, error: null);

    try {
      final stationRepo = ref.read(stationRepositoryProvider);
      final podcastRepo = ref.read(stationPodcastRepositoryProvider);
      final reconciler = ref.read(stationReconcilerServiceProvider);

      final now = DateTime.now();
      Station saved;

      if (stationId == null) {
        final station = Station()
          ..name = trimmedName
          ..playbackStateFilter = state.playbackState
          ..filterDownloaded = state.filterDownloaded
          ..filterFavorited = state.filterFavorited
          ..durationFilter = state.durationFilter
          ..publishedWithinDays = state.publishedWithinDays
          ..episodeSort = state.episodeSort
          ..createdAt = now
          ..updatedAt = now;
        saved = await stationRepo.create(station);
      } else {
        final existing = await stationRepo.findById(stationId!);
        if (existing == null) {
          state = state.copyWith(
            isSaving: false,
            error: StationEditError.notFound,
          );
          return null;
        }
        existing
          ..name = trimmedName
          ..playbackStateFilter = state.playbackState
          ..filterDownloaded = state.filterDownloaded
          ..filterFavorited = state.filterFavorited
          ..durationFilter = state.durationFilter
          ..publishedWithinDays = state.publishedWithinDays
          ..episodeSort = state.episodeSort
          ..updatedAt = now;
        await stationRepo.update(existing);
        saved = existing;
      }

      // Sync podcast membership.
      await podcastRepo.removeAllForStation(saved.id);
      for (final podcastId in state.selectedPodcastIds) {
        await podcastRepo.add(saved.id, podcastId);
      }

      await reconciler.onStationConfigChanged(saved.id);

      state = state.copyWith(isSaving: false);
      return saved;
    } on StationLimitExceededException {
      state = state.copyWith(
        isSaving: false,
        error: StationEditError.limitReached(
          StationLimitExceededException.maxStations,
        ),
      );
      return null;
    } on Exception catch (e) {
      state = state.copyWith(isSaving: false, error: e.toString());
      return null;
    }
  }

  /// Deletes the station and all associated data.
  Future<bool> delete() async {
    if (stationId == null) return false;

    state = state.copyWith(isSaving: true, error: null);

    try {
      final stationRepo = ref.read(stationRepositoryProvider);
      final podcastRepo = ref.read(stationPodcastRepositoryProvider);
      final episodeRepo = ref.read(stationEpisodeRepositoryProvider);

      await episodeRepo.removeAllForStation(stationId!);
      await podcastRepo.removeAllForStation(stationId!);
      await stationRepo.delete(stationId!);

      state = state.copyWith(isSaving: false);
      return true;
    } on Exception catch (e) {
      state = state.copyWith(isSaving: false, error: e.toString());
      return false;
    }
  }
}
