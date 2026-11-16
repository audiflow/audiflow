import 'dart:async';

import 'package:isar_community/isar.dart';

import '../../../feed/models/episode.dart';
import '../../../user_state/models/episode_user_state.dart';
import '../../../user_state/services/episode_user_state_access.dart';
import '../../models/playback_history.dart';
import '../../../user_state/services/user_state_store.dart';

/// Local datasource for playback history operations using Isar.
///
/// Playback state lives in [EpisodeUserState], keyed by the episode's
/// stable key; the old [PlaybackHistory] rows keep being written for one
/// release so a rollback still finds them. This class keeps speaking
/// [PlaybackHistory] by local episode id, so callers did not change; see
/// [EpisodeUserStateAccess] for how the two are kept in step.
class PlaybackHistoryLocalDatasource {
  PlaybackHistoryLocalDatasource(this._isar);

  final Isar _isar;

  /// User state writes go through the store; see [UserStateStore].
  late final _store = UserStateStore(_isar);
  late final _access = EpisodeUserStateAccess(_isar);

  /// Returns playback history for an episode, or null if not found.
  Future<PlaybackHistory?> getByEpisodeId(int episodeId) {
    return _access.history(episodeId);
  }

  /// Watches playback history for an episode, emitting null until the
  /// first play. Emits the current value immediately, then after writes
  /// that change it.
  Stream<PlaybackHistory?> watchByEpisodeId(int episodeId) {
    return _watch<PlaybackHistory?>(
      triggers: [
        _isar.playbackHistorys.where().episodeIdEqualTo(episodeId).watchLazy(),
        // The episode's key is not known synchronously, so any state write
        // re-reads; [_watch] drops the unchanged results.
        _isar.episodeUserStates.watchLazy(),
        // Keying the episode can switch it to keyed state already stored.
        _isar.episodes.where().idEqualTo(episodeId).watchLazy(),
      ],
      load: () => getByEpisodeId(episodeId),
      same: (a, b) => a == null || b == null ? a == b : sameHistory(a, b),
    );
  }

  /// Upserts playback history (insert or update on conflict).
  Future<void> upsert(PlaybackHistory history) async {
    await _store.write((txn) async {
      final slot = await _access.loadSlot(history.episodeId);
      await _access.saveHistory(slot, history, txn);
    });
  }

  /// Updates playback position, lastPlayedAt, and accumulated listen time.
  ///
  /// [listenedDeltaMs] and [realtimeDeltaMs] are incremental durations to
  /// add to the running totals. Pass 0 when no accumulation is needed
  /// (e.g. first save of a session).
  ///
  /// Atomic read-then-write inside a single transaction to
  /// prevent unique index violations from concurrent calls.
  Future<void> updateProgress({
    required int episodeId,
    required int positionMs,
    int? durationMs,
    int listenedDeltaMs = 0,
    int realtimeDeltaMs = 0,
  }) async {
    final now = DateTime.now();
    await _store.write((txn) async {
      final slot = await _access.loadSlot(episodeId);
      final existing = slot.history;

      if (existing == null) {
        final history = PlaybackHistory()
          ..episodeId = episodeId
          ..positionMs = positionMs
          ..durationMs = durationMs
          ..firstPlayedAt = now
          ..lastPlayedAt = now
          ..playCount = 1
          ..totalListenedMs = listenedDeltaMs
          ..totalRealtimeMs = realtimeDeltaMs;
        await _access.saveHistory(slot, history, txn);
      } else {
        existing.positionMs = positionMs;
        if (durationMs != null) {
          existing.durationMs = durationMs;
        }
        existing.firstPlayedAt ??= now;
        existing.lastPlayedAt = now;
        existing.totalListenedMs = existing.totalListenedMs + listenedDeltaMs;
        existing.totalRealtimeMs = existing.totalRealtimeMs + realtimeDeltaMs;
        await _access.saveHistory(slot, existing, txn);
      }
    });
  }

  /// Marks an episode as played by the listener.
  ///
  /// Counts a completion only when the episode was not played: marking a
  /// played episode, also one being replayed, ends the replay without
  /// counting one.
  Future<void> markCompleted(int episodeId) =>
      _markCompleted(episodeId, skipPlayed: false);

  /// Marks an episode as played unless it already is, for bulk marking:
  /// a played episode, also one being replayed, is left as it is. Returns
  /// whether the episode changed.
  Future<bool> markCompletedUnlessPlayed(int episodeId) =>
      _markCompleted(episodeId, skipPlayed: true);

  /// Atomic read-then-write inside a single transaction.
  Future<bool> _markCompleted(int episodeId, {required bool skipPlayed}) async {
    final now = DateTime.now();
    return _store.write((txn) async {
      final slot = await _access.loadSlot(episodeId);
      final existing = slot.history;
      if (existing == null) {
        await _access.saveHistory(slot, _firstCompletion(episodeId, now), txn);
        return true;
      }
      if (existing.isPlayed && skipPlayed) return false;
      if (!existing.isPlayed) {
        existing.completedCount = existing.completedCount + 1;
      }
      _closeListen(existing, now);
      await _access.saveHistory(slot, existing, txn);
      return true;
    });
  }

  /// Finishes the current listen at the completion threshold. Returns
  /// false, changing nothing, when the listen is already finished.
  ///
  /// A first listen and a replay started from the beginning count a
  /// completion; a replay reopened by a rewind does not.
  ///
  /// Atomic read-then-write inside a single transaction.
  Future<bool> finishListen(int episodeId) async {
    final now = DateTime.now();
    return _store.write((txn) async {
      final slot = await _access.loadSlot(episodeId);
      final existing = slot.history;
      if (existing == null) {
        await _access.saveHistory(slot, _firstCompletion(episodeId, now), txn);
        return true;
      }
      if (existing.isListenFinished) return false;
      if (!existing.isPlayed || existing.isReplayFromStart) {
        existing.completedCount = existing.completedCount + 1;
      }
      _closeListen(existing, now);
      await _access.saveHistory(slot, existing, txn);
      return true;
    });
  }

  PlaybackHistory _firstCompletion(int episodeId, DateTime now) =>
      PlaybackHistory()
        ..episodeId = episodeId
        ..firstPlayedAt = now
        ..completedAt = now
        ..lastPlayedAt = now
        ..completedCount = 1;

  void _closeListen(PlaybackHistory history, DateTime now) {
    history
      ..firstPlayedAt ??= now
      ..lastPlayedAt = now
      ..completedAt = now
      ..isReplaying = false
      ..isReplayFromStart = false;
  }

  /// Marks an episode as unplayed (removes completedAt and ends any replay).
  Future<void> markIncomplete(int episodeId) async {
    await _store.write((txn) async {
      final slot = await _access.loadSlot(episodeId);
      final existing = slot.history;
      if (existing == null) return;

      existing
        ..completedAt = null
        ..isReplaying = false
        ..isReplayFromStart = false;
      await _access.saveHistory(slot, existing, txn);
    });
  }

  /// Opens a replay of a played episode at [positionMs]. [fromStart]
  /// tells whether the replay starts from the beginning, which makes it
  /// count a completion when it finishes.
  ///
  /// Keeps the played status and makes the new listen resumable. Taking
  /// an open replay back to the beginning makes it count; otherwise does
  /// nothing unless the episode's last listen is finished.
  ///
  /// Atomic read-then-write inside a single transaction.
  Future<void> startReplay(
    int episodeId, {
    required int positionMs,
    required bool fromStart,
  }) async {
    await _store.write((txn) async {
      final slot = await _access.loadSlot(episodeId);
      final existing = slot.history;
      if (existing == null || !existing.isPlayed) return;

      if (existing.isReplaying) {
        if (!fromStart || existing.isReplayFromStart) return;
        existing.isReplayFromStart = true;
      } else {
        existing
          ..isReplaying = true
          ..isReplayFromStart = fromStart
          // The previous listen's position (usually the end) is not where
          // the replay resumes.
          ..positionMs = positionMs
          ..lastPlayedAt = DateTime.now();
      }
      await _access.saveHistory(slot, existing, txn);
    });
  }

  /// Increments play count (called when starting from beginning).
  Future<void> incrementPlayCount(int episodeId) async {
    await _store.write((txn) async {
      final slot = await _access.loadSlot(episodeId);
      final existing = slot.history;
      if (existing == null) return;

      existing.playCount = existing.playCount + 1;
      await _access.saveHistory(slot, existing, txn);
    });
  }

  /// Returns the most recently played in-progress episode, or null.
  Future<PlaybackHistory?> getLastPlayed() async {
    final results = await getInProgress(limit: 1);
    return results.isEmpty ? null : results.first;
  }

  /// Returns episodes whose listen finished at or before [time], replays
  /// excluded.
  Future<List<PlaybackHistory>> getFinishedBefore(DateTime time) =>
      _isar.txn(() => _finishedBefore(time));

  Future<List<PlaybackHistory>> _finishedBefore(DateTime time) async {
    final states = await _isar.episodeUserStates
        .filter()
        .hasPlaybackEqualTo(true)
        .and()
        // Isar sorts null below every date, so LessThan alone would match
        // episodes that were never finished.
        .completedAtIsNotNull()
        .and()
        .completedAtLessThan(time, include: true)
        .and()
        .isReplayingEqualTo(false)
        .findAll();
    final legacy = await _isar.playbackHistorys
        .filter()
        .completedAtIsNotNull()
        .and()
        .completedAtLessThan(time, include: true)
        .and()
        .isReplayingEqualTo(false)
        .findAll();
    return _access.resolve(states: states, legacy: legacy);
  }

  /// Returns episodes that are in progress: started, and their current
  /// listen not finished. Replays of played episodes are included.
  ///
  /// Ordered by lastPlayedAt descending, limited to [limit] items.
  ///
  /// Reads in one read transaction, so every page and the resolution see
  /// the same snapshot and a write in between cannot shift rows across
  /// pages.
  Future<List<PlaybackHistory>> getInProgress({int limit = 10}) =>
      _isar.txn(() => _inProgress(limit));

  Future<List<PlaybackHistory>> _inProgress(int limit) async {
    // Mirrors [PlaybackHistoryStatus.isInProgress]. Both collections are
    // read newest first in pages, since rows whose episode is missing are
    // dropped only after resolving; reading stops once the newest [limit]
    // visible rows are known.
    final pageSize = limit < 10 ? 20 : limit * 2;
    final states = _Pager<EpisodeUserState>(
      pageSize,
      (offset) => _isar.episodeUserStates
          .filter()
          .hasPlaybackEqualTo(true)
          .and()
          .positionMsGreaterThan(0)
          .and()
          .group((q) => q.completedAtIsNull().or().isReplayingEqualTo(true))
          .sortByLastPlayedAtDesc()
          .offset(offset)
          .limit(pageSize)
          .findAll(),
      (state) => state.lastPlayedAt,
    );
    final legacy = _Pager<PlaybackHistory>(
      pageSize,
      (offset) => _isar.playbackHistorys
          .filter()
          .positionMsGreaterThan(0)
          .and()
          .group((q) => q.completedAtIsNull().or().isReplayingEqualTo(true))
          .sortByLastPlayedAtDesc()
          .offset(offset)
          .limit(pageSize)
          .findAll(),
      (history) => history.lastPlayedAt,
    );
    while (true) {
      await states.next();
      await legacy.next();
      final resolved = await _access.resolve(
        states: states.rows,
        legacy: legacy.rows,
      );
      resolved.sort(_byLastPlayedDesc);
      final done = states.isDone && legacy.isDone;
      if (done || limit <= _settledCount(resolved, [states, legacy])) {
        return resolved.take(limit).toList();
      }
    }
  }

  /// How many of [sorted] are known to be among the newest: rows strictly
  /// newer than anything an unfinished pager could still return.
  static int _settledCount(
    List<PlaybackHistory> sorted,
    List<_Pager<Object>> pagers,
  ) {
    DateTime? frontier;
    var frontierIsNull = false;
    for (final pager in pagers) {
      if (pager.isDone) continue;
      final last = pager.lastSortValue;
      if (last == null) {
        frontierIsNull = true;
        continue;
      }
      final current = frontier;
      if (current == null || current.isBefore(last)) frontier = last;
    }
    final newest = frontier;
    if (newest == null) {
      // Unread rows can only have no lastPlayedAt, which sorts last.
      return frontierIsNull
          ? sorted.where((h) => h.lastPlayedAt != null).length
          : sorted.length;
    }
    return sorted.where((h) {
      final at = h.lastPlayedAt;
      return at != null && newest.isBefore(at);
    }).length;
  }

  /// Watches episodes that are in progress.
  Stream<List<PlaybackHistory>> watchInProgress({int limit = 10}) {
    return _watch<List<PlaybackHistory>>(
      triggers: [
        _isar.playbackHistorys.watchLazy(),
        _isar.episodeUserStates.watchLazy(),
        // Keyed state shows only once its episode is in the catalog, so a
        // feed bringing the episode back changes the result too.
        _isar.episodes.watchLazy(),
      ],
      load: () => getInProgress(limit: limit),
      same: (a, b) =>
          a.length == b.length &&
          [
            for (var i = 0; i < a.length; i++) sameHistory(a[i], b[i]),
          ].every((same) => same),
    );
  }

  /// Returns true if the episode is played (see [PlaybackHistoryStatus]).
  Future<bool> isCompleted(int episodeId) async {
    final history = await getByEpisodeId(episodeId);
    return history?.completedAt != null;
  }

  /// Returns all playback histories for episodes in a podcast.
  ///
  /// Queries episodes by podcastId first, then fetches their histories.
  Future<Map<int, PlaybackHistory>> getByPodcastId(int podcastId) =>
      _isar.txn(() => _byPodcastId(podcastId));

  Future<Map<int, PlaybackHistory>> _byPodcastId(int podcastId) async {
    final episodes = await _isar.episodes
        .filter()
        .podcastIdEqualTo(podcastId)
        .findAll();
    if (episodes.isEmpty) return {};

    final keys = [for (final e in episodes) ?e.episodeKey];
    final states = [
      for (final s in await _isar.episodeUserStates.getAllByEpisodeKey(keys))
        if (s != null && s.hasPlayback) s,
    ];
    final legacy = [
      for (final h in await _isar.playbackHistorys.getAllByEpisodeId(
        episodes.map((e) => e.id).toList(),
      ))
        ?h,
    ];
    final resolved = await _access.resolve(states: states, legacy: legacy);
    return {for (final h in resolved) h.episodeId: h};
  }

  static int _byLastPlayedDesc(PlaybackHistory a, PlaybackHistory b) {
    final at = a.lastPlayedAt;
    final bt = b.lastPlayedAt;
    if (at == null) return bt == null ? 0 : 1;
    if (bt == null) return -1;
    return bt.compareTo(at);
  }

  /// Emits [load]'s result on listen and again after each event of
  /// [triggers], skipping a result [same] as the one before.
  ///
  /// The triggers are subscribed before the first load, so a write that
  /// lands while it runs is not missed. Loads run one at a time, in order.
  static Stream<T> _watch<T>({
    required List<Stream<void>> triggers,
    required Future<T> Function() load,
    required bool Function(T a, T b) same,
  }) {
    late final StreamController<T> controller;
    final subscriptions = <StreamSubscription<void>>[];
    var pending = Future<void>.value();
    var active = false;
    var hasLast = false;
    late T last;

    void refresh() {
      pending = pending.then((_) async {
        if (!active) return;
        try {
          final value = await load();
          // Cancelled while loading: nobody listens any more.
          if (!active) return;
          if (hasLast && same(last, value)) return;
          hasLast = true;
          last = value;
          controller.add(value);
        } on Object catch (error, stack) {
          if (active) controller.addError(error, stack);
        }
      });
    }

    controller = StreamController<T>(
      onListen: () {
        active = true;
        for (final trigger in triggers) {
          subscriptions.add(
            trigger.listen((_) => refresh(), onError: controller.addError),
          );
        }
        refresh();
      },
      onCancel: () async {
        // Before awaiting, so refreshes queued behind a running load skip.
        active = false;
        for (final sub in subscriptions) {
          await sub.cancel();
        }
        subscriptions.clear();
      },
    );
    return controller.stream;
  }
}

/// Reads one query page by page, keeping every row read so far.
class _Pager<T> {
  _Pager(this._pageSize, this._fetch, this._sortValue);

  final int _pageSize;
  final Future<List<T>> Function(int offset) _fetch;
  final DateTime? Function(T row) _sortValue;
  final rows = <T>[];
  var isDone = false;

  /// The sort value of the last row read, the newest any unread row can be.
  DateTime? get lastSortValue => rows.isEmpty ? null : _sortValue(rows.last);

  Future<void> next() async {
    if (isDone) return;
    final page = await _fetch(rows.length);
    rows.addAll(page);
    if (page.length < _pageSize) isDone = true;
  }
}
