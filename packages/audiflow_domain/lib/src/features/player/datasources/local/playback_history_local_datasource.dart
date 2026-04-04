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
        existing.lastPlayedAt = now;
        existing.totalListenedMs = existing.totalListenedMs + listenedDeltaMs;
        existing.totalRealtimeMs = existing.totalRealtimeMs + realtimeDeltaMs;
        await _isar.playbackHistorys.put(existing);
      }
    });
  }

  /// Marks an episode as completed.
  ///
  /// Atomic read-then-write inside a single transaction.
  Future<void> markCompleted(int episodeId) async {
    final now = DateTime.now();
    await _isar.writeTxn(() async {
      final existing = await _isar.playbackHistorys.getByEpisodeId(episodeId);

      if (existing == null) {
        final history = PlaybackHistory()
          ..episodeId = episodeId
          ..completedAt = now
          ..lastPlayedAt = now
          ..completedCount = 1;
        await _isar.playbackHistorys.put(history);
      } else {
        existing.completedAt = now;
        existing.lastPlayedAt = now;
        existing.completedCount = existing.completedCount + 1;
        await _isar.playbackHistorys.put(existing);
      }
    });
  }

  /// Marks an episode as incomplete (removes completedAt).
  Future<void> markIncomplete(int episodeId) async {
    final existing = await getByEpisodeId(episodeId);
    if (existing == null) return;

    existing.completedAt = null;
    await _isar.writeTxn(() => _isar.playbackHistorys.put(existing));
  }

  /// Increments play count (called when starting from beginning).
  Future<void> incrementPlayCount(int episodeId) async {
    final existing = await getByEpisodeId(episodeId);
    if (existing == null) return;

    existing.playCount = existing.playCount + 1;
    await _isar.writeTxn(() => _isar.playbackHistorys.put(existing));
  }

  /// Returns the most recently played incomplete episode, or null.
  Future<PlaybackHistory?> getLastPlayed() async {
    final results = await getInProgress(limit: 1);
    return results.isEmpty ? null : results.first;
  }

  /// Returns episodes that are in progress (started but not completed).
  ///
  /// Ordered by lastPlayedAt descending, limited to [limit] items.
  Future<List<PlaybackHistory>> getInProgress({int limit = 10}) {
    // positionMs > 0 rewritten as: 0 < positionMs
    return _isar.playbackHistorys
        .filter()
        .positionMsGreaterThan(0)
        .and()
        .completedAtIsNull()
        .sortByLastPlayedAtDesc()
        .limit(limit)
        .findAll();
  }

  /// Watches episodes that are in progress.
  Stream<List<PlaybackHistory>> watchInProgress({int limit = 10}) {
    return _isar.playbackHistorys
        .filter()
        .positionMsGreaterThan(0)
        .and()
        .completedAtIsNull()
        .sortByLastPlayedAtDesc()
        .limit(limit)
        .watch(fireImmediately: true);
  }

  /// Returns true if the episode is completed.
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
