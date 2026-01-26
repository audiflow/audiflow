import 'package:drift/drift.dart';

import '../../../../common/database/app_database.dart';

/// Local datasource for season operations using Drift.
///
/// Provides CRUD operations for the Seasons table.
/// Seasons use composite primary key (podcastId, seasonNumber).
class SeasonLocalDatasource {
  SeasonLocalDatasource(this._db);

  final AppDatabase _db;

  /// Upserts a season (insert or update on conflict).
  ///
  /// Matches on composite key (podcastId, seasonNumber).
  Future<void> upsert(SeasonsCompanion companion) async {
    await _db.into(_db.seasons).insertOnConflictUpdate(companion);
  }

  /// Upserts multiple seasons in a batch.
  ///
  /// Replaces all seasons for a podcast atomically.
  Future<void> upsertAllForPodcast(
    int podcastId,
    List<SeasonsCompanion> companions,
  ) async {
    await _db.transaction(() async {
      // Delete existing seasons for this podcast
      await (_db.delete(
        _db.seasons,
      )..where((s) => s.podcastId.equals(podcastId))).go();

      // Insert new seasons
      if (companions.isNotEmpty) {
        await _db.batch((batch) {
          for (final companion in companions) {
            batch.insert(_db.seasons, companion);
          }
        });
      }
    });
  }

  /// Returns all seasons for a podcast, ordered by sortKey.
  Future<List<SeasonEntity>> getByPodcastId(int podcastId) {
    return (_db.select(_db.seasons)
          ..where((s) => s.podcastId.equals(podcastId))
          ..orderBy([(s) => OrderingTerm.asc(s.sortKey)]))
        .get();
  }

  /// Watches seasons for a podcast, emitting updates when data changes.
  Stream<List<SeasonEntity>> watchByPodcastId(int podcastId) {
    return (_db.select(_db.seasons)
          ..where((s) => s.podcastId.equals(podcastId))
          ..orderBy([(s) => OrderingTerm.asc(s.sortKey)]))
        .watch();
  }

  /// Returns a season by podcast ID and season number.
  Future<SeasonEntity?> getByPodcastIdAndSeasonNumber(
    int podcastId,
    int seasonNumber,
  ) {
    return (_db.select(_db.seasons)..where(
          (s) =>
              s.podcastId.equals(podcastId) &
              s.seasonNumber.equals(seasonNumber),
        ))
        .getSingleOrNull();
  }

  /// Deletes all seasons for a podcast.
  Future<int> deleteByPodcastId(int podcastId) {
    return (_db.delete(
      _db.seasons,
    )..where((s) => s.podcastId.equals(podcastId))).go();
  }

  /// Returns count of seasons for a podcast.
  Future<int> countByPodcastId(int podcastId) async {
    final count = _db.seasons.podcastId.count();
    final query = _db.selectOnly(_db.seasons)
      ..addColumns([count])
      ..where(_db.seasons.podcastId.equals(podcastId));
    final result = await query.getSingle();
    return result.read(count) ?? 0;
  }
}
