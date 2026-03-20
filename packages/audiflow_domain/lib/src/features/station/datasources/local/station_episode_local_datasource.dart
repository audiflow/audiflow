import 'package:isar_community/isar.dart';

import '../../models/station_episode.dart';

/// Local datasource for [StationEpisode] Isar operations.
class StationEpisodeLocalDatasource {
  StationEpisodeLocalDatasource(this._isar);

  final Isar _isar;

  /// Watches episodes for [stationId] sorted by [sortKey].
  ///
  /// When [ascending] is false (default), sorts newest first.
  /// Optional [limit] and [offset] support pagination.
  Stream<List<StationEpisode>> watchByStation(
    int stationId, {
    int? limit,
    int? offset,
    bool ascending = false,
  }) {
    // Isar's QueryBuilder type advances on each offset/limit call, so all
    // four combinations are built explicitly to keep the type system happy.
    final filtered = _isar.stationEpisodes.filter().stationIdEqualTo(stationId);
    final sorted = ascending
        ? filtered.sortBySortKey()
        : filtered.sortBySortKeyDesc();

    if (offset != null && limit != null) {
      return sorted.offset(offset).limit(limit).watch(fireImmediately: true);
    }
    if (offset != null) {
      return sorted.offset(offset).watch(fireImmediately: true);
    }
    if (limit != null) {
      return sorted.limit(limit).watch(fireImmediately: true);
    }
    return sorted.watch(fireImmediately: true);
  }

  /// Returns the number of episodes for [stationId].
  Future<int> countByStation(int stationId) =>
      _isar.stationEpisodes.filter().stationIdEqualTo(stationId).count();

  /// Inserts or updates all [entries] in a single transaction.
  Future<void> putAll(List<StationEpisode> entries) async {
    await _isar.writeTxn(() => _isar.stationEpisodes.putAll(entries));
  }

  /// Deletes episodes by their Isar [ids].
  Future<void> deleteByIds(List<int> ids) async {
    await _isar.writeTxn(() => _isar.stationEpisodes.deleteAll(ids));
  }

  /// Deletes all episodes for [stationId].
  Future<void> deleteAllForStation(int stationId) async {
    await _isar.writeTxn(
      () => _isar.stationEpisodes
          .filter()
          .stationIdEqualTo(stationId)
          .deleteAll(),
    );
  }

  /// Deletes episodes within [stationId] whose episode IDs are in [episodeIds].
  Future<void> deleteByEpisodeIdsForStation(
    int stationId,
    List<int> episodeIds,
  ) async {
    await _isar.writeTxn(
      () => _isar.stationEpisodes
          .filter()
          .stationIdEqualTo(stationId)
          .and()
          .anyOf(episodeIds, (q, id) => q.episodeIdEqualTo(id))
          .deleteAll(),
    );
  }

  /// Returns the [StationEpisode] matching [stationId] and [episodeId], or null.
  Future<StationEpisode?> getByStationAndEpisode(
    int stationId,
    int episodeId,
  ) => _isar.stationEpisodes
      .filter()
      .stationIdEqualTo(stationId)
      .and()
      .episodeIdEqualTo(episodeId)
      .findFirst();

  /// Returns all episodes for [stationId].
  Future<List<StationEpisode>> getAllForStation(int stationId) =>
      _isar.stationEpisodes.filter().stationIdEqualTo(stationId).findAll();
}
