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
  /// Saved manual podcast order, preserved when switching to automatic
  /// sort modes so it can be restored when switching back to manual.
  List<int>? _savedManualOrder;

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

  /// Updates the podcast sort mode and recomputes [podcastSortOrder] to
  /// reflect the new mode immediately, so the edit screen shows the correct
  /// ordering before save.
  ///
  /// When leaving manual mode, the current manual order is preserved so it
  /// can be restored if the user switches back to manual.
  Future<void> setPodcastSort(StationPodcastSort value) async {
    // Save manual order before switching away from it.
    if (state.podcastSort == StationPodcastSort.manual &&
        value != StationPodcastSort.manual) {
      _savedManualOrder = List<int>.from(state.podcastSortOrder);
    }
    state = state.copyWith(podcastSort: value);
    if (value == StationPodcastSort.manual) {
      if (_savedManualOrder != null) {
        state = state.copyWith(podcastSortOrder: _savedManualOrder!);
        _savedManualOrder = null;
      }
      return;
    }
    final resolved = await _resolvedPodcastOrder();
    state = state.copyWith(podcastSortOrder: resolved);
  }

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

    // Prepend newly selected podcasts sorted by id (subscription order)
    // to avoid arbitrary Set iteration order.
    final newlyAdded = added.toList()..sort();
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
    final entries = await Future.wait(
      selected.map((id) async => MapEntry(id, await subRepo.getById(id))),
    );
    final subMap = <int, Subscription>{
      for (final entry in entries)
        if (entry.value != null) entry.key: entry.value!,
    };

    final ids = selected.toList();
    ids.sort((a, b) {
      final subA = subMap[a];
      final subB = subMap[b];
      // Deterministic fallback: nulls sort last, tie-break by ID.
      if (subA == null && subB == null) return a.compareTo(b);
      if (subA == null) return 1;
      if (subB == null) return -1;
      final result = switch (state.podcastSort) {
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
      // Stable tie-break by ID when primary sort is equal.
      return result != 0 ? result : a.compareTo(b);
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

      // Diff-based sync: compare desired state with current DB state to
      // preserve addedAt and reduce unnecessary writes.
      final resolvedOrder = await _resolvedPodcastOrder();
      final currentLinks = await podcastRepo.getByStation(saved.id);
      final currentMap = {for (final sp in currentLinks) sp.podcastId: sp};
      final desiredPodcastIds = <int>{};

      for (var i = 0; i < resolvedOrder.length; i++) {
        final podcastId = resolvedOrder[i];
        if (!state.selectedPodcastIds.contains(podcastId)) continue;
        desiredPodcastIds.add(podcastId);
        final limitOverride = state.podcastEpisodeLimits[podcastId];

        final existing = currentMap[podcastId];
        if (existing != null) {
          // Update in place if sortOrder or episodeLimit changed.
          if (existing.sortOrder != i ||
              existing.episodeLimit != limitOverride) {
            existing
              ..sortOrder = i
              ..episodeLimit = limitOverride;
            await podcastRepo.update(existing);
          }
        } else {
          // Insert new link.
          await podcastRepo.add(
            saved.id,
            podcastId,
            sortOrder: i,
            episodeLimit: limitOverride,
          );
        }
      }

      // Remove links no longer in the selection.
      for (final existing in currentLinks) {
        if (!desiredPodcastIds.contains(existing.podcastId)) {
          await podcastRepo.remove(saved.id, existing.podcastId);
        }
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
