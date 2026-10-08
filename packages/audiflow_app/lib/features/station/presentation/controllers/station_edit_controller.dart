import 'dart:async';

import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:flutter/foundation.dart';
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

    /// True until an existing station has loaded; the editor accepts no
    /// changes meanwhile, since the load would replace them.
    @Default(false) bool isLoading,
    String? error,
  }) = _StationEditState;
}

/// Saves and feed rebuilds still running per station, shared by every
/// editor instance: an editor keeps saving after it closes, so one opened
/// again for the same station must wait for them before loading.
class StationEditActivity {
  final _pending = <int, Future<void>>{};

  /// Adds [work] to what [settled] waits for on [stationId].
  void track(int stationId, Future<void> work) {
    final all = Future.wait([
      _pending[stationId] ?? Future<void>.value(),
      work.catchError((Object _) {}),
    ]).then((_) {});
    _pending[stationId] = all;
    unawaited(
      all.whenComplete(() {
        if (identical(_pending[stationId], all)) _pending.remove(stationId);
      }),
    );
  }

  /// Completes once all tracked work for [stationId] has finished.
  Future<void> settled(int stationId) =>
      _pending[stationId] ?? Future<void>.value();
}

@Riverpod(keepAlive: true)
StationEditActivity stationEditActivity(Ref ref) => StationEditActivity();

/// Edits a station and saves every change as it happens; there is no save
/// button to forget.
///
/// A new station is created once its first podcast is selected (leaving
/// before that discards it) and is saved in place from then on. An existing
/// station may be left with no podcasts; only an explicit delete removes
/// it. A blank name never reaches the database: a new station falls back to
/// its default name and an existing one keeps its saved name.
///
/// Settings are written immediately, one write at a time. The episode
/// reconcile is costlier, so it waits for the edits to settle and runs at
/// the latest when the editor closes.
@riverpod
class StationEditController extends _$StationEditController {
  /// Saved manual podcast order, preserved when switching to automatic
  /// sort modes so it can be restored when switching back to manual.
  List<int>? _savedManualOrder;

  /// How long edits must settle before the feed is rebuilt.
  @visibleForTesting
  static Duration reconcileDelay = const Duration(milliseconds: 800);

  // Captured in build: writes and the final reconcile outlive the provider.
  late StationRepository _stations;
  late StationPodcastRepository _links;
  late StationEpisodeRepository _episodes;
  late StationReconcilerService _reconciler;
  late SubscriptionRepository _subscriptions;
  late StationEditActivity _activity;

  /// The persisted station; null until a new station is created.
  int? _savedId;
  String _defaultName = '';
  bool _loaded = false;
  bool _deleted = false;
  Future<void> _writes = Future.value();
  final _loadCompleter = Completer<void>();
  Timer? _reconcileTimer;

  /// Feed rebuilds run one at a time, so an older one can never finish
  /// after a newer one (or after a delete) and restore stale rows.
  Future<void> _rebuilds = Future.value();

  /// Set when the editor closes: later writes leave the reconcile to the
  /// final flush instead of a timer.
  bool _closing = false;
  int? _pendingReconcileId;

  /// Completes once every change made so far has been written.
  @visibleForTesting
  Future<void> get pendingWrites => _writes;

  /// Completes once an existing station has loaded (immediately for new).
  @visibleForTesting
  Future<void> get loaded => _loadCompleter.future;

  @override
  StationEditState build(int? stationId) {
    _stations = ref.read(stationRepositoryProvider);
    _links = ref.read(stationPodcastRepositoryProvider);
    _episodes = ref.read(stationEpisodeRepositoryProvider);
    _reconciler = ref.read(stationReconcilerServiceProvider);
    _subscriptions = ref.read(subscriptionRepositoryProvider);
    _activity = ref.read(stationEditActivityProvider);
    _savedId = stationId;
    ref.onDispose(_flushReconcile);
    if (stationId == null) {
      _markLoaded();
    } else {
      unawaited(_loadExistingStation(stationId).whenComplete(_finishLoading));
    }
    return StationEditState(isLoading: stationId != null);
  }

  void _markLoaded() {
    _loaded = true;
    if (!_loadCompleter.isCompleted) _loadCompleter.complete();
  }

  void _finishLoading() {
    _markLoaded();
    if (ref.mounted) state = state.copyWith(isLoading: false);
  }

  /// Sets a new station's default [name], used whenever the field is left
  /// blank, and prefills it unless a name was already typed. Not a change,
  /// so nothing is written.
  void useDefaultName(String name) {
    _defaultName = name;
    if (state.name.trim().isEmpty) state = state.copyWith(name: name);
  }

  Future<void> _loadExistingStation(int id) async {
    // A previous editor for this station may still be saving.
    await _activity.settled(id);
    final station = await _stations.findById(id);
    if (station == null) return;

    final podcasts = await _links.getByStation(id);

    final podcastIds = podcasts.map((p) => p.podcastId).toSet();
    final limits = <int, int?>{};
    final orderedIds = <int>[];

    // Sort by sortOrder to reconstruct the correct display order.
    final sorted = List<StationPodcast>.from(podcasts)
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    for (final p in sorted) {
      orderedIds.add(p.podcastId);
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
    );
  }

  void setName(String name) => _edit(state.copyWith(name: name));

  void setFilterDownloaded(bool value) =>
      _edit(state.copyWith(filterDownloaded: value));

  void setFilterFavorited(bool value) =>
      _edit(state.copyWith(filterFavorited: value));

  void setHideCompleted(bool value) =>
      _edit(state.copyWith(hideCompleted: value));

  void setDurationFilter(StationDurationFilter? value) =>
      _edit(state.copyWith(durationFilter: value));

  void setEpisodeSort(StationEpisodeSort value) =>
      _edit(state.copyWith(episodeSort: value));

  void setDefaultEpisodeLimit(int? value) =>
      _edit(state.copyWith(defaultEpisodeLimit: value));

  void setGroupByPodcast(bool value) =>
      _edit(state.copyWith(groupByPodcast: value));

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
        // Merge any podcasts added while in automatic mode that are
        // missing from the saved snapshot.
        final restored = List<int>.from(_savedManualOrder!);
        for (final id in state.selectedPodcastIds) {
          if (!restored.contains(id)) {
            restored.add(id);
          }
        }
        state = state.copyWith(podcastSortOrder: restored);
        _savedManualOrder = null;
      }
      _scheduleSave();
      return;
    }
    // Queued before the await: a write resolves the order from its own
    // snapshot, and closing the editor during the await must not drop it.
    _scheduleSave();
    final resolved = await _resolvedPodcastOrder();
    // The resolved order is only for display; the write derives it too.
    if (ref.mounted) state = state.copyWith(podcastSortOrder: resolved);
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
    _edit(state.copyWith(podcastEpisodeLimits: limits));
  }

  void reorderPodcasts(List<int> newOrder) =>
      _edit(state.copyWith(podcastSortOrder: newOrder));

  /// Replaces [selectedPodcastIds] from a multi-selection picker.
  ///
  /// Newly added podcasts are prepended to [podcastSortOrder] so they appear
  /// at the top of the list. Removed podcasts are dropped from the order.
  ///
  /// When an automatic sort mode is active, the order is recomputed so the
  /// editor list immediately reflects the selected sort.
  Future<void> updateSelectedPodcasts(Set<int> newSelection) async {
    final currentOrder = List<int>.from(state.podcastSortOrder);

    final added = newSelection.difference(state.selectedPodcastIds);
    final removed = state.selectedPodcastIds.difference(newSelection);

    // Remove de-selected podcasts from sort order.
    currentOrder.removeWhere(removed.contains);

    // Prepend newly selected podcasts in ascending id order to keep the
    // result deterministic and avoid arbitrary Set iteration order.
    final newlyAdded = added.toList()..sort();
    currentOrder.insertAll(0, newlyAdded);

    // Safety: ensure every selected podcast appears in the order list.
    for (final id in newSelection) {
      if (!currentOrder.contains(id)) {
        currentOrder.add(id);
      }
    }

    // Queued before any await, so closing the editor cannot drop it.
    _edit(
      state.copyWith(
        selectedPodcastIds: newSelection,
        podcastSortOrder: currentOrder,
      ),
    );

    // Recompute order for automatic sort modes so the editor list matches
    // the selected sort immediately.
    if (state.podcastSort != StationPodcastSort.manual) {
      final resolved = await _resolvedPodcastOrder();
      if (ref.mounted) state = state.copyWith(podcastSortOrder: resolved);
    }
  }

  /// Computes the podcast order based on [state.podcastSort].
  ///
  /// For [StationPodcastSort.manual], returns the existing
  /// [state.podcastSortOrder]. For automatic modes, fetches subscription
  /// metadata and sorts accordingly.
  Future<List<int>> _resolvedPodcastOrder([StationEditState? from]) async {
    final edit = from ?? state;
    final selected = edit.selectedPodcastIds;
    final manualOrder = edit.podcastSortOrder.where(selected.contains).toList();

    if (edit.podcastSort == StationPodcastSort.manual) return manualOrder;

    final subRepo = _subscriptions;
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
      final result = switch (edit.podcastSort) {
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

  void _edit(StationEditState next) {
    state = next;
    _scheduleSave();
  }

  /// Queues a write of the current state behind the ones already queued,
  /// so a new station is never created twice.
  ///
  /// Each write uses the state as it was when queued: the editor may have
  /// closed (and the notifier been disposed) by the time it runs.
  void _scheduleSave() {
    final snapshot = state;
    _writes = _writes.then((_) => _persist(snapshot));
    if (_savedId case final id?) _activity.track(id, _writes);
  }

  Future<void> _persist(StationEditState edit) async {
    if (_deleted || !_loaded) return;
    final id = _savedId;
    // A new station exists only once it has a podcast.
    if (id == null && edit.selectedPodcastIds.isEmpty) return;
    try {
      final saved = id == null ? await _create(edit) : await _update(id, edit);
      if (saved == null) return;
      await _syncPodcastLinks(saved.id, edit);
      _scheduleReconcile(saved.id);
      _setError(null);
    } on StationLimitExceededException {
      _setError(
        StationEditError.limitReached(
          StationLimitExceededException.maxStations,
        ),
      );
    } on Object catch (e) {
      // Any failure, not only an Exception: the write chain must go on.
      _setError(e.toString());
    }
  }

  void _setError(String? error) {
    if (!ref.mounted || state.error == error) return;
    state = state.copyWith(error: error);
  }

  Future<Station> _create(StationEditState edit) async {
    final now = DateTime.now();
    final station = Station()
      ..name = _nameOr(edit, _defaultName)
      ..createdAt = now
      ..updatedAt = now;
    _applySettings(station, edit);
    final created = await _stations.create(station);
    _savedId = created.id;
    _activity.track(created.id, _writes);
    return created;
  }

  Future<Station?> _update(int id, StationEditState edit) async {
    final existing = await _stations.findById(id);
    if (existing == null) {
      _setError(StationEditError.notFound);
      return null;
    }
    _applySettings(existing, edit);
    existing
      ..name = _nameOr(edit, existing.name)
      ..publishedWithinDays = null
      ..updatedAt = DateTime.now();
    await _stations.update(existing);
    return existing;
  }

  /// The trimmed name, or [fallback] while the field is blank.
  String _nameOr(StationEditState edit, String fallback) {
    final trimmed = edit.name.trim();
    return trimmed.isEmpty ? fallback : trimmed;
  }

  static void _applySettings(Station station, StationEditState edit) {
    station
      ..hideCompleted = edit.hideCompleted
      ..filterDownloaded = edit.filterDownloaded
      ..filterFavorited = edit.filterFavorited
      ..durationFilter = edit.durationFilter
      ..defaultEpisodeLimit = edit.defaultEpisodeLimit
      ..episodeSort = edit.episodeSort
      ..groupByPodcast = edit.groupByPodcast
      ..podcastSort = edit.podcastSort;
  }

  /// Diff-based sync: compares the selection with the stored links to
  /// preserve addedAt and skip unchanged rows.
  Future<void> _syncPodcastLinks(int stationId, StationEditState edit) async {
    final resolvedOrder = await _resolvedPodcastOrder(edit);
    final currentLinks = await _links.getByStation(stationId);
    final currentMap = {for (final sp in currentLinks) sp.podcastId: sp};
    final selected = edit.selectedPodcastIds;
    for (var i = 0; i < resolvedOrder.length; i++) {
      final podcastId = resolvedOrder[i];
      if (!selected.contains(podcastId)) continue;
      final limit = edit.podcastEpisodeLimits[podcastId];
      await _writeLink(stationId, podcastId, i, limit, currentMap[podcastId]);
    }
    for (final link in currentLinks) {
      if (selected.contains(link.podcastId)) continue;
      await _links.remove(stationId, link.podcastId);
    }
  }

  Future<void> _writeLink(
    int stationId,
    int podcastId,
    int sortOrder,
    int? limit,
    StationPodcast? existing,
  ) async {
    if (existing == null) {
      await _links.add(
        stationId,
        podcastId,
        sortOrder: sortOrder,
        episodeLimit: limit,
      );
      return;
    }
    if (existing.sortOrder == sortOrder && existing.episodeLimit == limit) {
      return;
    }
    existing
      ..sortOrder = sortOrder
      ..episodeLimit = limit;
    await _links.update(existing);
  }

  void _scheduleReconcile(int stationId) {
    _reconcileTimer?.cancel();
    _pendingReconcileId = stationId;
    if (_closing) return;
    _reconcileTimer = Timer(reconcileDelay, () {
      _pendingReconcileId = null;
      _enqueueRebuild(stationId);
    });
  }

  /// Runs a pending reconcile once the queued writes finish, so the
  /// station feed is current when the editor closes.
  void _flushReconcile() {
    _closing = true;
    _reconcileTimer?.cancel();
    final flush = _writes.then((_) {
      final id = _pendingReconcileId;
      if (id == null) return null;
      _enqueueRebuild(id);
      return _rebuilds;
    });
    // Tracked as a whole: the final rebuild is only queued once the writes
    // finish, and a reopened editor must not load in between.
    if (_savedId case final id?) _activity.track(id, flush);
    unawaited(flush);
  }

  void _enqueueRebuild(int stationId) {
    _rebuilds = _rebuilds.then((_) {
      if (!_deleted) return _reconcile(stationId);
    });
    _activity.track(stationId, _rebuilds);
  }

  Future<void> _reconcile(int stationId) async {
    try {
      await _reconciler.onStationConfigChanged(stationId);
    } on Object catch (e) {
      // Any failure: the rebuild chain must go on.
      _setError(e.toString());
    }
  }

  /// Deletes the station and all associated data.
  Future<bool> delete() async {
    final id = _savedId;
    if (id == null) return false;
    _deleted = true;
    _reconcileTimer?.cancel();
    try {
      // Let a write or rebuild already in flight finish, so neither can
      // recreate links or feed rows after the delete.
      await _writes;
      await _rebuilds;
      await _episodes.removeAllForStation(id);
      await _links.removeAllForStation(id);
      await _stations.delete(id);
      return true;
    } on Exception catch (e) {
      _deleted = false;
      _setError(e.toString());
      return false;
    }
  }
}
