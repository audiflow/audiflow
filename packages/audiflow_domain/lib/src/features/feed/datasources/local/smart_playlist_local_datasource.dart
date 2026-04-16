import 'package:isar_community/isar.dart';

import '../../models/smart_playlist_groups.dart';
import '../../models/smart_playlists.dart';

/// Local datasource for smart playlist operations using Isar.
///
/// Provides CRUD operations for the SmartPlaylist and SmartPlaylistGroup
/// collections. Smart playlists use composite unique index
/// (podcastId, playlistNumber).
class SmartPlaylistLocalDatasource {
  SmartPlaylistLocalDatasource(this._isar);

  final Isar _isar;

  /// Upserts a smart playlist (insert or update on conflict).
  ///
  /// Matches on composite key (podcastId, playlistNumber).
  Future<void> upsert(SmartPlaylistEntity entity) async {
    await _isar.writeTxn(() async {
      final existing = await _isar.smartPlaylistEntitys
          .getByPodcastIdPlaylistNumber(
            entity.podcastId,
            entity.playlistNumber,
          );
      if (existing != null) {
        entity.id = existing.id;
      }
      await _isar.smartPlaylistEntitys.put(entity);
    });
  }

  /// Replaces all smart playlists for a podcast atomically.
  Future<void> upsertAllForPodcast(
    int podcastId,
    List<SmartPlaylistEntity> entities,
  ) async {
    await _isar.writeTxn(() async {
      await _isar.smartPlaylistEntitys
          .filter()
          .podcastIdEqualTo(podcastId)
          .deleteAll();

      if (entities.isNotEmpty) {
        await _isar.smartPlaylistEntitys.putAll(entities);
      }
    });
  }

  /// Returns all smart playlists for a podcast, ordered by sortKey.
  Future<List<SmartPlaylistEntity>> getByPodcastId(int podcastId) {
    return _isar.smartPlaylistEntitys
        .filter()
        .podcastIdEqualTo(podcastId)
        .sortBySortKey()
        .findAll();
  }

  /// Watches smart playlists for a podcast, emitting updates when
  /// data changes.
  Stream<List<SmartPlaylistEntity>> watchByPodcastId(int podcastId) {
    return _isar.smartPlaylistEntitys
        .filter()
        .podcastIdEqualTo(podcastId)
        .sortBySortKey()
        .watch(fireImmediately: true);
  }

  /// Returns a smart playlist by podcast ID and playlist number.
  Future<SmartPlaylistEntity?> getByPodcastIdAndPlaylistNumber(
    int podcastId,
    int playlistNumber,
  ) {
    return _isar.smartPlaylistEntitys.getByPodcastIdPlaylistNumber(
      podcastId,
      playlistNumber,
    );
  }

  /// Deletes all smart playlists for a podcast.
  Future<int> deleteByPodcastId(int podcastId) {
    return _isar.writeTxn(
      () => _isar.smartPlaylistEntitys
          .filter()
          .podcastIdEqualTo(podcastId)
          .deleteAll(),
    );
  }

  /// Returns groups for a playlist.
  Future<List<SmartPlaylistGroupEntity>> getGroupsByPlaylist(
    int podcastId,
    String playlistId,
  ) {
    return _isar.smartPlaylistGroupEntitys
        .filter()
        .podcastIdEqualTo(podcastId)
        .and()
        .playlistIdEqualTo(playlistId)
        .sortBySortKey()
        .findAll();
  }

  /// Replaces all groups for a playlist atomically.
  Future<void> upsertGroupsForPlaylist(
    int podcastId,
    String playlistId,
    List<SmartPlaylistGroupEntity> groups,
  ) async {
    await _isar.writeTxn(() async {
      await _isar.smartPlaylistGroupEntitys
          .filter()
          .podcastIdEqualTo(podcastId)
          .and()
          .playlistIdEqualTo(playlistId)
          .deleteAll();

      if (groups.isNotEmpty) {
        await _isar.smartPlaylistGroupEntitys.putAll(groups);
      }
    });
  }

  /// Deletes all smart playlists and groups across all podcasts.
  Future<void> clearAll() async {
    await _isar.writeTxn(() async {
      await _isar.smartPlaylistEntitys.clear();
      await _isar.smartPlaylistGroupEntitys.clear();
    });
  }

  /// Returns count of smart playlists for a podcast.
  Future<int> countByPodcastId(int podcastId) {
    return _isar.smartPlaylistEntitys
        .filter()
        .podcastIdEqualTo(podcastId)
        .count();
  }
}
