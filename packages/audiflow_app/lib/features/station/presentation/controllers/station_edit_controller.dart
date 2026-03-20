import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'station_edit_controller.g.dart';

/// Form state for station create/edit.
class StationEditState {
  const StationEditState({
    this.name = '',
    this.selectedPodcastIds = const {},
    this.playbackState = StationPlaybackState.all,
    this.filterDownloaded = false,
    this.filterFavorited = false,
    this.durationFilter,
    this.publishedWithinDays,
    this.episodeSort = StationEpisodeSort.newest,
    this.isSaving = false,
    this.error,
  });

  final String name;
  final Set<int> selectedPodcastIds;
  final StationPlaybackState playbackState;
  final bool filterDownloaded;
  final bool filterFavorited;
  final StationDurationFilter? durationFilter;
  final int? publishedWithinDays;
  final StationEpisodeSort episodeSort;
  final bool isSaving;
  final String? error;

  StationEditState copyWith({
    String? name,
    Set<int>? selectedPodcastIds,
    StationPlaybackState? playbackState,
    bool? filterDownloaded,
    bool? filterFavorited,
    Object? durationFilter = _sentinel,
    Object? publishedWithinDays = _sentinel,
    StationEpisodeSort? episodeSort,
    bool? isSaving,
    Object? error = _sentinel,
  }) {
    return StationEditState(
      name: name ?? this.name,
      selectedPodcastIds: selectedPodcastIds ?? this.selectedPodcastIds,
      playbackState: playbackState ?? this.playbackState,
      filterDownloaded: filterDownloaded ?? this.filterDownloaded,
      filterFavorited: filterFavorited ?? this.filterFavorited,
      durationFilter: durationFilter == _sentinel
          ? this.durationFilter
          : durationFilter as StationDurationFilter?,
      publishedWithinDays: publishedWithinDays == _sentinel
          ? this.publishedWithinDays
          : publishedWithinDays as int?,
      episodeSort: episodeSort ?? this.episodeSort,
      isSaving: isSaving ?? this.isSaving,
      error: error == _sentinel ? this.error : error as String?,
    );
  }

  static const Object _sentinel = Object();
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
      state = state.copyWith(error: 'Station name is required');
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
          state = state.copyWith(isSaving: false, error: 'Station not found');
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
        error:
            'Station limit of ${StationLimitExceededException.maxStations} reached',
      );
      return null;
    } catch (e) {
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
    } catch (e) {
      state = state.copyWith(isSaving: false, error: e.toString());
      return false;
    }
  }
}
