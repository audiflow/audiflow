import '../models/station.dart';

abstract class StationRepository {
  Stream<List<Station>> watchAll();
  Future<Station?> findById(int id);
  Stream<Station?> watchById(int id);
  Future<Station> create(Station station);
  Future<void> update(Station station);
  Future<void> delete(int id);
  Future<void> reorder(List<int> stationIds);

  /// Records that an episode was played from station [id] at [at].
  Future<void> markPlayed(int id, {required DateTime at});
  Future<int> count();
}

class StationLimitExceededException implements Exception {
  const StationLimitExceededException();
  static const int maxStations = 15;

  @override
  String toString() => 'Station limit of $maxStations reached';
}
