import 'package:drift/drift.dart';

import '../../../../common/database/app_database.dart';

/// Local datasource for smart playlist operations using Drift.
///
/// Provides CRUD operations for the SmartPlaylists table.
/// Smart playlists use composite primary key
/// (podcastId, playlistNumber).
class SmartPlaylistLocalDatasource {
  SmartPlaylistLocalDatasource(this._db);

  final AppDatabase _db;

  /// Upserts a smart playlist (insert or update on conflict).
  ///
  /// Matches on composite key (podcastId, playlistNumber).
  Future<void> upsert(SmartPlaylistsCompanion companion) async {
    await _db.into(_db.smartPlaylists).insertOnConflictUpdate(companion);
  }

  /// Upserts multiple smart playlists in a batch.
  ///
  /// Replaces all smart playlists for a podcast atomically.
  Future<void> upsertAllForPodcast(
    int podcastId,
    List<SmartPlaylistsCompanion> companions,
  ) async {
    await _db.transaction(() async {
      // Delete existing smart playlists for this podcast
      await (_db.delete(
        _db.smartPlaylists,
      )..where((s) => s.podcastId.equals(podcastId))).go();

      // Insert new smart playlists
      if (companions.isNotEmpty) {
        await _db.batch((batch) {
          for (final companion in companions) {
            batch.insert(_db.smartPlaylists, companion);
          }
        });
      }
    });
  }

  /// Returns all smart playlists for a podcast, ordered by sortKey.
  Future<List<SmartPlaylistEntity>> getByPodcastId(int podcastId) {
    return (_db.select(_db.smartPlaylists)
          ..where((s) => s.podcastId.equals(podcastId))
          ..orderBy([(s) => OrderingTerm.asc(s.sortKey)]))
        .get();
  }

  /// Watches smart playlists for a podcast, emitting updates when
  /// data changes.
  Stream<List<SmartPlaylistEntity>> watchByPodcastId(int podcastId) {
    return (_db.select(_db.smartPlaylists)
          ..where((s) => s.podcastId.equals(podcastId))
          ..orderBy([(s) => OrderingTerm.asc(s.sortKey)]))
        .watch();
  }

  /// Returns a smart playlist by podcast ID and playlist number.
  Future<SmartPlaylistEntity?> getByPodcastIdAndPlaylistNumber(
    int podcastId,
    int playlistNumber,
  ) {
    return (_db.select(_db.smartPlaylists)..where(
          (s) =>
              s.podcastId.equals(podcastId) &
              s.playlistNumber.equals(playlistNumber),
        ))
        .getSingleOrNull();
  }

  /// Deletes all smart playlists for a podcast.
  Future<int> deleteByPodcastId(int podcastId) {
    return (_db.delete(
      _db.smartPlaylists,
    )..where((s) => s.podcastId.equals(podcastId))).go();
  }

  /// Returns groups for a playlist.
  Future<List<SmartPlaylistGroupEntity>> getGroupsByPlaylist(
    int podcastId,
    String playlistId,
  ) {
    return (_db.select(_db.smartPlaylistGroups)
          ..where(
            (g) =>
                g.podcastId.equals(podcastId) & g.playlistId.equals(playlistId),
          )
          ..orderBy([(g) => OrderingTerm.asc(g.sortKey)]))
        .get();
  }

  /// Replaces all groups for a playlist atomically.
  Future<void> upsertGroupsForPlaylist(
    int podcastId,
    String playlistId,
    List<SmartPlaylistGroupsCompanion> companions,
  ) async {
    await _db.transaction(() async {
      await (_db.delete(_db.smartPlaylistGroups)..where(
            (g) =>
                g.podcastId.equals(podcastId) & g.playlistId.equals(playlistId),
          ))
          .go();

      if (companions.isNotEmpty) {
        await _db.batch((batch) {
          for (final c in companions) {
            batch.insert(_db.smartPlaylistGroups, c);
          }
        });
      }
    });
  }

  /// Returns count of smart playlists for a podcast.
  Future<int> countByPodcastId(int podcastId) async {
    final count = _db.smartPlaylists.podcastId.count();
    final query = _db.selectOnly(_db.smartPlaylists)
      ..addColumns([count])
      ..where(_db.smartPlaylists.podcastId.equals(podcastId));
    final result = await query.getSingle();
    return result.read(count) ?? 0;
  }
}
