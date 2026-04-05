import 'package:isar_community/isar.dart';

import '../../models/station.dart';

/// Local datasource for [Station] Isar operations.
class StationLocalDatasource {
  StationLocalDatasource(this._isar);

  final Isar _isar;

  /// Inserts a station and returns it with its auto-generated id.
  Future<Station> insert(Station station) async {
    await _isar.writeTxn(() => _isar.stations.put(station));
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
    await _isar.writeTxn(() => _isar.stations.put(station));
  }

  /// Deletes the station with [id]. Returns true if deleted.
  Future<bool> delete(int id) =>
      _isar.writeTxn(() => _isar.stations.delete(id));

  /// Returns the total number of stations.
  Future<int> count() => _isar.stations.count();

  /// Reassigns [sortOrder] for each station according to [stationIds] order.
  ///
  /// All updates run in a single transaction to avoid partial state.
  Future<void> reorder(List<int> stationIds) async {
    await _isar.writeTxn(() async {
      for (var i = 0; i < stationIds.length; i++) {
        final station = await _isar.stations.get(stationIds[i]);
        if (station == null) continue;
        station.sortOrder = i;
        await _isar.stations.put(station);
      }
    });
  }
}
