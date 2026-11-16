import 'package:isar_community/isar.dart';

import '../../models/station.dart';
import '../../../user_state/services/station_state_access.dart';
import '../../../user_state/services/user_state_store.dart';

/// Local datasource for [Station] Isar operations.
///
/// Every write also records the station on its `StationState`, the copy
/// that syncs (see [StationStateAccess]).
class StationLocalDatasource {
  StationLocalDatasource(this._isar);

  final Isar _isar;

  /// User state writes go through the store; see [UserStateStore].
  late final _store = UserStateStore(_isar);
  late final _states = StationStateAccess(_isar);

  /// Inserts a station and returns it with its auto-generated id.
  Future<Station> insert(Station station) async {
    await _store.write((txn) => _states.saveStations([station], txn));
    return station;
  }

  /// Returns the station with [id], or null if not found.
  Future<Station?> getById(int id) => _isar.stations.get(id);

  /// Watches the station with [id] for changes.
  Stream<Station?> watchById(int id) =>
      _isar.stations.watchObject(id, fireImmediately: true);

  /// Returns all stations sorted by [sortOrder] ascending.
  Future<List<Station>> getAll() =>
      _isar.stations.where().sortBySortOrder().findAll();

  /// Watches all stations sorted by [sortOrder] ascending.
  Stream<List<Station>> watchAll() =>
      _isar.stations.where().sortBySortOrder().watch(fireImmediately: true);

  /// Updates an existing station.
  Future<void> update(Station station) async {
    await _store.write((txn) => _states.saveStations([station], txn));
  }

  /// Deletes the station with [id]. Returns true if deleted.
  Future<bool> delete(int id) {
    return _store.write((txn) async {
      final station = await _isar.stations.get(id);
      if (station == null) return false;
      await _states.removeStation(station, txn);
      return _isar.stations.delete(id);
    });
  }

  /// Returns the total number of stations.
  Future<int> count() => _isar.stations.count();

  /// Sets [Station.lastPlayedAt] without touching [Station.updatedAt]:
  /// playing is not an edit. Does nothing for an unknown [id].
  Future<void> markPlayed(int id, {required DateTime at}) async {
    await _store.write((txn) async {
      final station = await _isar.stations.get(id);
      if (station == null) return;
      station.lastPlayedAt = at;
      await _states.saveStations([station], txn);
    });
  }

  /// Reassigns [sortOrder] for each station according to [stationIds] order.
  ///
  /// All updates run in a single transaction to avoid partial state.
  Future<void> reorder(List<int> stationIds) async {
    await _store.write((txn) async {
      final stations = <Station>[];
      for (var i = 0; i < stationIds.length; i++) {
        final station = await _isar.stations.get(stationIds[i]);
        if (station == null) continue;
        stations.add(station..sortOrder = i);
      }
      await _states.saveStations(stations, txn);
    });
  }
}
