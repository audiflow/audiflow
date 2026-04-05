import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../common/providers/database_provider.dart';
import '../datasources/local/station_local_datasource.dart';
import '../models/station.dart';
import 'station_repository.dart';

part 'station_repository_impl.g.dart';

/// Provides a singleton [StationRepository] instance.
@Riverpod(keepAlive: true)
StationRepository stationRepository(Ref ref) {
  final isar = ref.watch(isarProvider);
  final datasource = StationLocalDatasource(isar);
  return StationRepositoryImpl(datasource: datasource);
}

/// Implementation of [StationRepository] using Isar database.
class StationRepositoryImpl implements StationRepository {
  StationRepositoryImpl({required StationLocalDatasource datasource})
    : _datasource = datasource;

  final StationLocalDatasource _datasource;

  @override
  Stream<List<Station>> watchAll() => _datasource.watchAll();

  @override
  Future<Station?> findById(int id) => _datasource.getById(id);

  @override
  Stream<Station?> watchById(int id) => _datasource.watchById(id);

  @override
  Future<Station> create(Station station) async {
    final count = await _datasource.count();
    // Reject if the limit has already been reached.
    if (StationLimitExceededException.maxStations <= count) {
      throw const StationLimitExceededException();
    }
    return _datasource.insert(station);
  }

  @override
  Future<void> update(Station station) => _datasource.update(station);

  @override
  Future<void> delete(int id) async {
    await _datasource.delete(id);
  }

  @override
  Future<void> reorder(List<int> stationIds) => _datasource.reorder(stationIds);

  @override
  Future<int> count() => _datasource.count();
}
