import 'package:isar_community/isar.dart';

import '../../models/station_podcast.dart';
import '../../../user_state/services/station_state_access.dart';
import '../../../user_state/services/user_state_store.dart';

/// Local datasource for [StationPodcast] Isar operations.
///
/// Every write also records the link on its `StationMember`, the copy that
/// syncs (see [StationStateAccess]).
class StationPodcastLocalDatasource {
  StationPodcastLocalDatasource(this._isar);

  final Isar _isar;

  /// User state writes go through the store; see [UserStateStore].
  late final _store = UserStateStore(_isar);
  late final _states = StationStateAccess(_isar);

  Future<void> _deleteLinks(
    QueryBuilder<StationPodcast, StationPodcast, QAfterFilterCondition> query,
  ) {
    return _store.write((txn) async {
      final links = await query.findAll();
      await _states.removeMembers(links, txn);
      await _isar.stationPodcasts.deleteAll([for (final l in links) l.id]);
    });
  }

  /// Inserts a station–podcast link.
  ///
  /// No-op if the (stationId, podcastId) pair already exists, preserving
  /// the original [addedAt] timestamp.
  Future<void> insert(StationPodcast sp) async {
    await _store.write((txn) async {
      final existing = await _isar.stationPodcasts
          .filter()
          .stationIdEqualTo(sp.stationId)
          .and()
          .podcastIdEqualTo(sp.podcastId)
          .findFirst();
      if (existing != null) return;
      await _states.saveMembers([sp], txn);
    });
  }

  /// Updates an existing station-podcast link (sortOrder, episodeLimit).
  Future<void> update(StationPodcast sp) async {
    await _store.write((txn) => _states.saveMembers([sp], txn));
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
    await _deleteLinks(
      _isar.stationPodcasts
          .filter()
          .stationIdEqualTo(stationId)
          .and()
          .podcastIdEqualTo(podcastId),
    );
  }

  /// Deletes all links for [stationId].
  Future<void> deleteAllForStation(int stationId) async {
    await _deleteLinks(
      _isar.stationPodcasts.filter().stationIdEqualTo(stationId),
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
