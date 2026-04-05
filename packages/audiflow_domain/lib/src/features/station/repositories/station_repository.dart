import '../models/station.dart';

abstract class StationRepository {
  Stream<List<Station>> watchAll();
  Future<Station?> findById(int id);
  Stream<Station?> watchById(int id);
  Future<Station> create(Station station);
  Future<void> update(Station station);
  Future<void> delete(int id);
  Future<void> reorder(List<int> stationIds);
  Future<int> count();
}

class StationLimitExceededException implements Exception {
  const StationLimitExceededException();
  static const int maxStations = 15;

  @override
  String toString() => 'Station limit of $maxStations reached';
}
