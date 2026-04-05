import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'station_edit_controller.freezed.dart';
part 'station_edit_controller.g.dart';

/// Sentinel value stored in [StationEditState.podcastEpisodeLimits] to
/// represent an explicit "all episodes" override, distinct from the absence
/// of an override (which falls back to the station default).
const int allEpisodesSentinel = 0;

/// Error keys for localization in the UI layer.
abstract final class StationEditError {
  static const nameRequired = 'name_required';
  static const podcastRequired = 'podcast_required';
  static const notFound = 'not_found';
  static const _limitReachedPrefix = 'limit_reached:';
  static String limitReached(int max) => '$_limitReachedPrefix$max';

  static bool isLimitReached(String key) => key.startsWith(_limitReachedPrefix);
  static int parseLimitMax(String key) {
    if (!key.startsWith(_limitReachedPrefix)) return 0;
    return int.tryParse(key.substring(_limitReachedPrefix.length)) ?? 0;
  }
}

/// Form state for station create/edit.
@freezed
sealed class StationEditState with _$StationEditState {
  const factory StationEditState({
    @Default('') String name,
    @Default({}) Set<int> selectedPodcastIds,
    @Default(false) bool hideCompleted,
    @Default(false) bool filterDownloaded,
    @Default(false) bool filterFavorited,
    StationDurationFilter? durationFilter,
    @Default(3) int? defaultEpisodeLimit,
    @Default(StationEpisodeSort.newest) StationEpisodeSort episodeSort,
    @Default(false) bool groupByPodcast,
    @Default(StationPodcastSort.manual) StationPodcastSort podcastSort,

    /// Per-podcast episode limit overrides. Key = podcastId, value = limit
    /// (null removed from map = use default).
    @Default({}) Map<int, int?> podcastEpisodeLimits,

    /// Ordered list of selected podcast IDs for manual sort.
    @Default([]) List<int> podcastSortOrder,

    /// Original sort orders from DB, used to preserve order during edits.
    @Default({}) Map<int, int> originalSortOrders,
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
        .getByStation(id);

    final podcastIds = podcasts.map((p) => p.podcastId).toSet();
    final limits = <int, int?>{};
    final sortOrders = <int, int>{};
    final orderedIds = <int>[];

    // Sort by sortOrder to reconstruct the correct display order.
    final sorted = List<StationPodcast>.from(podcasts)
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    for (final p in sorted) {
      orderedIds.add(p.podcastId);
      sortOrders[p.podcastId] = p.sortOrder;
      if (p.episodeLimit != null) {
        // episodeLimit == 0 in the DB means "explicitly all episodes"
        // (distinct from null which means "use station default").
        limits[p.podcastId] = p.episodeLimit;
      }
    }

    state = state.copyWith(
      name: station.name,
      selectedPodcastIds: podcastIds,
      hideCompleted: station.hideCompleted,
      filterDownloaded: station.filterDownloaded,
      filterFavorited: station.filterFavorited,
      durationFilter: station.durationFilter,
      defaultEpisodeLimit: station.defaultEpisodeLimit,
      episodeSort: station.episodeSort,
      groupByPodcast: station.groupByPodcast,
      podcastSort: station.podcastSort,
      podcastEpisodeLimits: limits,
      podcastSortOrder: orderedIds,
      originalSortOrders: sortOrders,
    );
  }

  void setName(String name) => state = state.copyWith(name: name);

  void setFilterDownloaded(bool value) =>
      state = state.copyWith(filterDownloaded: value);

  void setFilterFavorited(bool value) =>
      state = state.copyWith(filterFavorited: value);

  void setHideCompleted(bool value) =>
      state = state.copyWith(hideCompleted: value);

  void setDurationFilter(StationDurationFilter? value) =>
      state = state.copyWith(durationFilter: value);

  void setEpisodeSort(StationEpisodeSort value) =>
      state = state.copyWith(episodeSort: value);

  void setDefaultEpisodeLimit(int? value) =>
      state = state.copyWith(defaultEpisodeLimit: value);

  void setGroupByPodcast(bool value) =>
      state = state.copyWith(groupByPodcast: value);

  void setPodcastSort(StationPodcastSort value) =>
      state = state.copyWith(podcastSort: value);

  /// Sets a per-podcast episode limit override.
  ///
  /// Pass `null` to remove the override (use station default).
  /// Pass [allEpisodesSentinel] to explicitly override as "all episodes".
  void setPodcastEpisodeLimit(int podcastId, int? limit) {
    final limits = Map<int, int?>.from(state.podcastEpisodeLimits);
    if (limit == null) {
      limits.remove(podcastId);
    } else {
      limits[podcastId] = limit;
    }
    state = state.copyWith(podcastEpisodeLimits: limits);
  }

  void reorderPodcasts(List<int> newOrder) =>
      state = state.copyWith(podcastSortOrder: newOrder);

  /// Replaces [selectedPodcastIds] from a multi-selection picker.
  ///
  /// Newly added podcasts are prepended to [podcastSortOrder] so they appear
  /// at the top of the list. Removed podcasts are dropped from the order.
  void updateSelectedPodcasts(Set<int> newSelection) {
    final currentOrder = List<int>.from(state.podcastSortOrder);
    final originalOrders = Map<int, int>.from(state.originalSortOrders);

    final added = newSelection.difference(state.selectedPodcastIds);
    final removed = state.selectedPodcastIds.difference(newSelection);

    // Remove de-selected podcasts from sort order.
    currentOrder.removeWhere(removed.contains);

    // Prepend newly selected podcasts (top of list).
    final newlyAdded = added.toList();
    currentOrder.insertAll(0, newlyAdded);

    // Safety: ensure every selected podcast appears in the order list.
    for (final id in newSelection) {
      if (!currentOrder.contains(id)) {
        currentOrder.add(id);
      }
    }

    state = state.copyWith(
      selectedPodcastIds: newSelection,
      podcastSortOrder: currentOrder,
      originalSortOrders: originalOrders,
    );
  }

  /// Computes the podcast order based on [state.podcastSort].
  ///
  /// For [StationPodcastSort.manual], returns the existing
  /// [state.podcastSortOrder]. For automatic modes, fetches subscription
  /// metadata and sorts accordingly.
  Future<List<int>> _resolvedPodcastOrder() async {
    final selected = state.selectedPodcastIds;
    final manualOrder = state.podcastSortOrder
        .where(selected.contains)
        .toList();

    if (state.podcastSort == StationPodcastSort.manual) return manualOrder;

    final subRepo = ref.read(subscriptionRepositoryProvider);
    final subMap = <int, Subscription>{};
    for (final id in selected) {
      final sub = await subRepo.getById(id);
      if (sub != null) subMap[id] = sub;
    }

    final ids = selected.toList();
    ids.sort((a, b) {
      final subA = subMap[a];
      final subB = subMap[b];
      if (subA == null || subB == null) return 0;
      return switch (state.podcastSort) {
        StationPodcastSort.nameAsc => subA.title.toLowerCase().compareTo(
          subB.title.toLowerCase(),
        ),
        StationPodcastSort.nameDesc => subB.title.toLowerCase().compareTo(
          subA.title.toLowerCase(),
        ),
        StationPodcastSort.subscribeAsc => subA.subscribedAt.compareTo(
          subB.subscribedAt,
        ),
        StationPodcastSort.subscribeDesc => subB.subscribedAt.compareTo(
          subA.subscribedAt,
        ),
        StationPodcastSort.manual => 0,
      };
    });
    return ids;
  }

  /// Persists the station and reconciles podcast membership.
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
          ..hideCompleted = state.hideCompleted
          ..filterDownloaded = state.filterDownloaded
          ..filterFavorited = state.filterFavorited
          ..durationFilter = state.durationFilter
          ..defaultEpisodeLimit = state.defaultEpisodeLimit
          ..episodeSort = state.episodeSort
          ..groupByPodcast = state.groupByPodcast
          ..podcastSort = state.podcastSort
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
          ..hideCompleted = state.hideCompleted
          ..filterDownloaded = state.filterDownloaded
          ..filterFavorited = state.filterFavorited
          ..durationFilter = state.durationFilter
          ..defaultEpisodeLimit = state.defaultEpisodeLimit
          ..episodeSort = state.episodeSort
          ..groupByPodcast = state.groupByPodcast
          ..podcastSort = state.podcastSort
          ..updatedAt = now;
        await stationRepo.update(existing);
        saved = existing;
      }

      // Sync podcast membership with sort order and per-podcast limits.
      await podcastRepo.removeAllForStation(saved.id);
      final resolvedOrder = await _resolvedPodcastOrder();
      for (var i = 0; i < resolvedOrder.length; i++) {
        final podcastId = resolvedOrder[i];
        if (!state.selectedPodcastIds.contains(podcastId)) continue;
        final limitOverride = state.podcastEpisodeLimits[podcastId];
        // allEpisodesSentinel (0) persists as 0; null means no override.
        await podcastRepo.add(
          saved.id,
          podcastId,
          sortOrder: i,
          episodeLimit: limitOverride,
        );
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
