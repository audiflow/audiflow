import 'package:drift/drift.dart';

import '../../../../common/database/app_database.dart';

/// Local datasource for episode operations using Drift.
///
/// Provides CRUD operations and upsert support for the Episodes table.
class EpisodeLocalDatasource {
  EpisodeLocalDatasource(this._db);

  final AppDatabase _db;

  /// Upserts an episode (insert or update on conflict).
  ///
  /// Matches on composite key (podcastId, guid). Returns the episode ID.
  Future<int> upsert(EpisodesCompanion companion) async {
    return _db.into(_db.episodes).insertOnConflictUpdate(companion);
  }

  /// Upserts multiple episodes in a batch.
  Future<void> upsertAll(List<EpisodesCompanion> companions) async {
    await _db.batch((batch) {
      for (final companion in companions) {
        batch.insert(
          _db.episodes,
          companion,
          onConflict: DoUpdate(
            (old) => companion,
            target: [_db.episodes.podcastId, _db.episodes.guid],
          ),
        );
      }
    });
  }

  /// Returns all episodes for a podcast, ordered by publish date (newest first).
  Future<List<Episode>> getByPodcastId(int podcastId) {
    return (_db.select(_db.episodes)
          ..where((e) => e.podcastId.equals(podcastId))
          ..orderBy([
            (e) => OrderingTerm(
              expression: e.publishedAt,
              mode: OrderingMode.desc,
            ),
          ]))
        .get();
  }

  /// Watches episodes for a podcast, emitting updates when data changes.
  Stream<List<Episode>> watchByPodcastId(int podcastId) {
    return (_db.select(_db.episodes)
          ..where((e) => e.podcastId.equals(podcastId))
          ..orderBy([
            (e) => OrderingTerm(
              expression: e.publishedAt,
              mode: OrderingMode.desc,
            ),
          ]))
        .watch();
  }

  /// Returns an episode by its ID.
  Future<Episode?> getById(int id) {
    return (_db.select(
      _db.episodes,
    )..where((e) => e.id.equals(id))).getSingleOrNull();
  }

  /// Returns an episode by podcast ID and guid.
  Future<Episode?> getByPodcastIdAndGuid(int podcastId, String guid) {
    return (_db.select(_db.episodes)
          ..where((e) => e.podcastId.equals(podcastId) & e.guid.equals(guid)))
        .getSingleOrNull();
  }

  /// Returns an episode by its audio URL.
  Future<Episode?> getByAudioUrl(String audioUrl) {
    return (_db.select(
      _db.episodes,
    )..where((e) => e.audioUrl.equals(audioUrl))).getSingleOrNull();
  }

  /// Returns all episode GUIDs for a podcast.
  ///
  /// Used for early-stop optimization during RSS parsing.
  Future<Set<String>> getGuidsByPodcastId(int podcastId) async {
    final results = await (_db.select(
      _db.episodes,
    )..where((e) => e.podcastId.equals(podcastId))).map((e) => e.guid).get();
    return results.toSet();
  }

  /// Deletes all episodes for a podcast.
  Future<int> deleteByPodcastId(int podcastId) {
    return (_db.delete(
      _db.episodes,
    )..where((e) => e.podcastId.equals(podcastId))).go();
  }
}
