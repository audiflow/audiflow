import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../common/providers/database_provider.dart';
import '../datasources/local/station_podcast_local_datasource.dart';
import '../models/station_podcast.dart';
import 'station_podcast_repository.dart';

part 'station_podcast_repository_impl.g.dart';

/// Provides a singleton [StationPodcastRepository] instance.
@Riverpod(keepAlive: true)
StationPodcastRepository stationPodcastRepository(Ref ref) {
  final isar = ref.watch(isarProvider);
  final datasource = StationPodcastLocalDatasource(isar);
  return StationPodcastRepositoryImpl(datasource: datasource);
}

/// Implementation of [StationPodcastRepository] using Isar database.
class StationPodcastRepositoryImpl implements StationPodcastRepository {
  StationPodcastRepositoryImpl({
    required StationPodcastLocalDatasource datasource,
  }) : _datasource = datasource;

  final StationPodcastLocalDatasource _datasource;

  @override
  Stream<List<StationPodcast>> watchByStation(int stationId) =>
      _datasource.watchByStation(stationId);

  @override
  Future<void> add(int stationId, int podcastId) {
    final link = StationPodcast()
      ..stationId = stationId
      ..podcastId = podcastId
      ..addedAt = DateTime.now();
    return _datasource.insert(link);
  }

  @override
  Future<void> remove(int stationId, int podcastId) =>
      _datasource.delete(stationId, podcastId);

  @override
  Future<void> removeAllForStation(int stationId) =>
      _datasource.deleteAllForStation(stationId);
}
