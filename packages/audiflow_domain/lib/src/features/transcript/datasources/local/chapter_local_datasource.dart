import 'package:drift/drift.dart';

import '../../../../common/database/app_database.dart';

/// Local datasource for chapter CRUD operations using Drift.
///
/// Provides read, upsert, delete, and watch operations for the
/// EpisodeChapters table.
class ChapterLocalDatasource {
  ChapterLocalDatasource(this._db);

  final AppDatabase _db;

  /// Returns chapters for an episode, ordered by startMs.
  Future<List<EpisodeChapter>> getByEpisodeId(int episodeId) {
    return (_db.select(_db.episodeChapters)
          ..where((c) => c.episodeId.equals(episodeId))
          ..orderBy([(c) => OrderingTerm.asc(c.startMs)]))
        .get();
  }

  /// Watches chapters for an episode, ordered by startMs.
  Stream<List<EpisodeChapter>> watchByEpisodeId(int episodeId) {
    return (_db.select(_db.episodeChapters)
          ..where((c) => c.episodeId.equals(episodeId))
          ..orderBy([(c) => OrderingTerm.asc(c.startMs)]))
        .watch();
  }

  /// Upserts chapter records in a batch.
  ///
  /// Inserts new chapters or updates existing ones on conflict
  /// (matching episodeId + sortOrder unique key).
  Future<void> upsertChapters(List<EpisodeChaptersCompanion> companions) async {
    await _db.batch((batch) {
      for (final companion in companions) {
        batch.insert(
          _db.episodeChapters,
          companion,
          onConflict: DoUpdate(
            (old) => companion,
            target: [
              _db.episodeChapters.episodeId,
              _db.episodeChapters.sortOrder,
            ],
          ),
        );
      }
    });
  }

  /// Deletes all chapters for an episode.
  ///
  /// Returns the number of deleted rows.
  Future<int> deleteByEpisodeId(int episodeId) {
    return (_db.delete(
      _db.episodeChapters,
    )..where((c) => c.episodeId.equals(episodeId))).go();
  }
}
