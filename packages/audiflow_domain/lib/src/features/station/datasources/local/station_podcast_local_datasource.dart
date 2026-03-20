import 'package:isar_community/isar.dart';

import '../../models/station_podcast.dart';

/// Local datasource for [StationPodcast] Isar operations.
class StationPodcastLocalDatasource {
  StationPodcastLocalDatasource(this._isar);

  final Isar _isar;

  /// Inserts a station–podcast link.
  ///
  /// Uses [putByStationIdPodcastId] to upsert on the unique composite index,
  /// so duplicate inserts are silently ignored rather than throwing.
  Future<void> insert(StationPodcast sp) async {
    await _isar.writeTxn(
      () => _isar.stationPodcasts.putByStationIdPodcastId(sp),
    );
  }

  /// Returns all links for [stationId].
  Future<List<StationPodcast>> getByStation(int stationId) =>
      _isar.stationPodcasts.filter().stationIdEqualTo(stationId).findAll();

  /// Watches all links for [stationId].
  Stream<List<StationPodcast>> watchByStation(int stationId) => _isar
      .stationPodcasts
      .filter()
      .stationIdEqualTo(stationId)
      .watch(fireImmediately: true);

  /// Deletes the link for a specific [stationId] + [podcastId] pair.
  Future<void> delete(int stationId, int podcastId) async {
    await _isar.writeTxn(
      () => _isar.stationPodcasts
          .filter()
          .stationIdEqualTo(stationId)
          .and()
          .podcastIdEqualTo(podcastId)
          .deleteAll(),
    );
  }

  /// Deletes all links for [stationId].
  Future<void> deleteAllForStation(int stationId) async {
    await _isar.writeTxn(
      () => _isar.stationPodcasts
          .filter()
          .stationIdEqualTo(stationId)
          .deleteAll(),
    );
  }

  /// Returns the station IDs that include [podcastId].
  Future<List<int>> getStationIdsForPodcast(int podcastId) async {
    final links = await _isar.stationPodcasts
        .filter()
        .podcastIdEqualTo(podcastId)
        .findAll();
    return links.map((sp) => sp.stationId).toList();
  }
}
