import 'package:isar_community/isar.dart';

import '../../../feed/models/episode.dart';
import '../../models/playback_history.dart';

/// Local datasource for playback history operations using Isar.
///
/// Provides CRUD operations for tracking episode playback progress.
class PlaybackHistoryLocalDatasource {
  PlaybackHistoryLocalDatasource(this._isar);

  final Isar _isar;

  /// Returns playback history for an episode, or null if not found.
  Future<PlaybackHistory?> getByEpisodeId(int episodeId) {
    return _isar.playbackHistorys.getByEpisodeId(episodeId);
  }

  /// Upserts playback history (insert or update on conflict).
  Future<void> upsert(PlaybackHistory history) async {
    await _isar.writeTxn(() async {
      final existing = await _isar.playbackHistorys.getByEpisodeId(
        history.episodeId,
      );
      if (existing != null) {
        history.id = existing.id;
      }
      await _isar.playbackHistorys.put(history);
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
    await _isar.writeTxn(() async {
      final existing = await _isar.playbackHistorys.getByEpisodeId(episodeId);

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
        await _isar.playbackHistorys.put(history);
      } else {
        existing.positionMs = positionMs;
        if (durationMs != null) {
          existing.durationMs = durationMs;
        }
        existing.firstPlayedAt ??= now;
        existing.lastPlayedAt = now;
        existing.totalListenedMs = existing.totalListenedMs + listenedDeltaMs;
        existing.totalRealtimeMs = existing.totalRealtimeMs + realtimeDeltaMs;
        await _isar.playbackHistorys.put(existing);
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
    return _isar.writeTxn(() async {
      final existing = await _isar.playbackHistorys.getByEpisodeId(episodeId);
      if (existing == null) {
        await _isar.playbackHistorys.put(_firstCompletion(episodeId, now));
        return true;
      }
      if (existing.isPlayed && skipPlayed) return false;
      if (!existing.isPlayed) {
        existing.completedCount = existing.completedCount + 1;
      }
      _closeListen(existing, now);
      await _isar.playbackHistorys.put(existing);
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
    return _isar.writeTxn(() async {
      final existing = await _isar.playbackHistorys.getByEpisodeId(episodeId);
      if (existing == null) {
        await _isar.playbackHistorys.put(_firstCompletion(episodeId, now));
        return true;
      }
      if (existing.isListenFinished) return false;
      if (!existing.isPlayed || existing.isReplayFromStart) {
        existing.completedCount = existing.completedCount + 1;
      }
      _closeListen(existing, now);
      await _isar.playbackHistorys.put(existing);
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
    final existing = await getByEpisodeId(episodeId);
    if (existing == null) return;

    existing
      ..completedAt = null
      ..isReplaying = false
      ..isReplayFromStart = false;
    await _isar.writeTxn(() => _isar.playbackHistorys.put(existing));
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
    await _isar.writeTxn(() async {
      final existing = await _isar.playbackHistorys.getByEpisodeId(episodeId);
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
      await _isar.playbackHistorys.put(existing);
    });
  }

  /// Increments play count (called when starting from beginning).
  Future<void> incrementPlayCount(int episodeId) async {
    final existing = await getByEpisodeId(episodeId);
    if (existing == null) return;

    existing.playCount = existing.playCount + 1;
    await _isar.writeTxn(() => _isar.playbackHistorys.put(existing));
  }

  /// Returns the most recently played in-progress episode, or null.
  Future<PlaybackHistory?> getLastPlayed() async {
    final results = await getInProgress(limit: 1);
    return results.isEmpty ? null : results.first;
  }

  /// Returns episodes that are in progress: started, and their current
  /// listen not finished. Replays of played episodes are included.
  ///
  /// Ordered by lastPlayedAt descending, limited to [limit] items.
  Future<List<PlaybackHistory>> getInProgress({int limit = 10}) {
    return _inProgressQuery(limit).findAll();
  }

  /// Watches episodes that are in progress.
  Stream<List<PlaybackHistory>> watchInProgress({int limit = 10}) {
    return _inProgressQuery(limit).watch(fireImmediately: true);
  }

  /// Mirrors [PlaybackHistoryStatus.isInProgress] as an Isar query.
  Query<PlaybackHistory> _inProgressQuery(int limit) {
    return _isar.playbackHistorys
        .filter()
        .positionMsGreaterThan(0)
        .and()
        .group((q) => q.completedAtIsNull().or().isReplayingEqualTo(true))
        .sortByLastPlayedAtDesc()
        .limit(limit)
        .build();
  }

  /// Returns true if the episode is played (see [PlaybackHistoryStatus]).
  Future<bool> isCompleted(int episodeId) async {
    final history = await getByEpisodeId(episodeId);
    return history?.completedAt != null;
  }

  /// Returns all playback histories for episodes in a podcast.
  ///
  /// Queries episodes by podcastId first, then fetches their histories.
  Future<Map<int, PlaybackHistory>> getByPodcastId(int podcastId) async {
    final episodes = await _isar.episodes
        .filter()
        .podcastIdEqualTo(podcastId)
        .findAll();

    final episodeIds = episodes.map((e) => e.id).toList();
    if (episodeIds.isEmpty) return {};

    final result = <int, PlaybackHistory>{};
    for (final episodeId in episodeIds) {
      final history = await _isar.playbackHistorys.getByEpisodeId(episodeId);
      if (history != null) {
        result[episodeId] = history;
      }
    }
    return result;
  }
}
