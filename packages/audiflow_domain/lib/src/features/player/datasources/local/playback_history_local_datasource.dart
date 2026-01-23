import 'package:drift/drift.dart';

import '../../../../common/database/app_database.dart';

/// Local datasource for playback history operations using Drift.
///
/// Provides CRUD operations for tracking episode playback progress.
class PlaybackHistoryLocalDatasource {
  PlaybackHistoryLocalDatasource(this._db);

  final AppDatabase _db;

  /// Returns playback history for an episode, or null if not found.
  Future<PlaybackHistory?> getByEpisodeId(int episodeId) {
    return (_db.select(
      _db.playbackHistories,
    )..where((h) => h.episodeId.equals(episodeId))).getSingleOrNull();
  }

  /// Upserts playback history (insert or update on conflict).
  Future<void> upsert(PlaybackHistoriesCompanion companion) async {
    await _db.into(_db.playbackHistories).insertOnConflictUpdate(companion);
  }

  /// Updates playback position and lastPlayedAt timestamp.
  Future<void> updateProgress({
    required int episodeId,
    required int positionMs,
    int? durationMs,
  }) async {
    final now = DateTime.now();
    final existing = await getByEpisodeId(episodeId);

    if (existing == null) {
      // First time playing - create new record
      await upsert(
        PlaybackHistoriesCompanion.insert(
          episodeId: Value(episodeId),
          positionMs: Value(positionMs),
          durationMs: Value(durationMs),
          firstPlayedAt: Value(now),
          lastPlayedAt: Value(now),
          playCount: const Value(1),
        ),
      );
    } else {
      // Update existing record
      await (_db.update(
        _db.playbackHistories,
      )..where((h) => h.episodeId.equals(episodeId))).write(
        PlaybackHistoriesCompanion(
          positionMs: Value(positionMs),
          durationMs: durationMs != null
              ? Value(durationMs)
              : const Value.absent(),
          lastPlayedAt: Value(now),
        ),
      );
    }
  }

  /// Marks an episode as completed.
  Future<void> markCompleted(int episodeId) async {
    final now = DateTime.now();
    final existing = await getByEpisodeId(episodeId);

    if (existing == null) {
      await upsert(
        PlaybackHistoriesCompanion.insert(
          episodeId: Value(episodeId),
          completedAt: Value(now),
          lastPlayedAt: Value(now),
        ),
      );
    } else {
      await (_db.update(
        _db.playbackHistories,
      )..where((h) => h.episodeId.equals(episodeId))).write(
        PlaybackHistoriesCompanion(
          completedAt: Value(now),
          lastPlayedAt: Value(now),
        ),
      );
    }
  }

  /// Marks an episode as incomplete (removes completedAt).
  Future<void> markIncomplete(int episodeId) async {
    await (_db.update(_db.playbackHistories)
          ..where((h) => h.episodeId.equals(episodeId)))
        .write(const PlaybackHistoriesCompanion(completedAt: Value(null)));
  }

  /// Increments play count (called when starting from beginning).
  Future<void> incrementPlayCount(int episodeId) async {
    final existing = await getByEpisodeId(episodeId);
    if (existing != null) {
      await (_db.update(
        _db.playbackHistories,
      )..where((h) => h.episodeId.equals(episodeId))).write(
        PlaybackHistoriesCompanion(playCount: Value(existing.playCount + 1)),
      );
    }
  }

  /// Returns episodes that are in progress (started but not completed).
  ///
  /// Ordered by lastPlayedAt descending, limited to [limit] items.
  Future<List<PlaybackHistory>> getInProgress({int limit = 10}) {
    return (_db.select(_db.playbackHistories)
          ..where(
            (h) => h.positionMs.isBiggerThanValue(0) & h.completedAt.isNull(),
          )
          ..orderBy([
            (h) => OrderingTerm(
              expression: h.lastPlayedAt,
              mode: OrderingMode.desc,
            ),
          ])
          ..limit(limit))
        .get();
  }

  /// Watches episodes that are in progress.
  Stream<List<PlaybackHistory>> watchInProgress({int limit = 10}) {
    return (_db.select(_db.playbackHistories)
          ..where(
            (h) => h.positionMs.isBiggerThanValue(0) & h.completedAt.isNull(),
          )
          ..orderBy([
            (h) => OrderingTerm(
              expression: h.lastPlayedAt,
              mode: OrderingMode.desc,
            ),
          ])
          ..limit(limit))
        .watch();
  }

  /// Returns true if the episode is completed.
  Future<bool> isCompleted(int episodeId) async {
    final history = await getByEpisodeId(episodeId);
    return history?.completedAt != null;
  }
}
