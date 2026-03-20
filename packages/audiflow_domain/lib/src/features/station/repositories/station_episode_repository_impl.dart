import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../common/providers/database_provider.dart';
import '../datasources/local/station_episode_local_datasource.dart';
import '../datasources/local/station_podcast_local_datasource.dart';
import '../models/station_episode.dart';
import 'station_episode_repository.dart';

part 'station_episode_repository_impl.g.dart';

/// Provides a singleton [StationEpisodeRepository] instance.
@Riverpod(keepAlive: true)
StationEpisodeRepository stationEpisodeRepository(Ref ref) {
  final isar = ref.watch(isarProvider);
  final episodeDatasource = StationEpisodeLocalDatasource(isar);
  final podcastDatasource = StationPodcastLocalDatasource(isar);
  return StationEpisodeRepositoryImpl(
    episodeDatasource: episodeDatasource,
    podcastDatasource: podcastDatasource,
  );
}

/// Implementation of [StationEpisodeRepository] using Isar database.
class StationEpisodeRepositoryImpl implements StationEpisodeRepository {
  StationEpisodeRepositoryImpl({
    required StationEpisodeLocalDatasource episodeDatasource,
    required StationPodcastLocalDatasource podcastDatasource,
  }) : _episodeDatasource = episodeDatasource,
       _podcastDatasource = podcastDatasource;

  final StationEpisodeLocalDatasource _episodeDatasource;
  final StationPodcastLocalDatasource _podcastDatasource;

  @override
  Stream<List<StationEpisode>> watchByStation(
    int stationId, {
    int? limit,
    int? offset,
  }) => _episodeDatasource.watchByStation(
    stationId,
    limit: limit,
    offset: offset,
  );

  @override
  Future<int> countByStation(int stationId) =>
      _episodeDatasource.countByStation(stationId);

  @override
  Future<void> removeAllForStation(int stationId) =>
      _episodeDatasource.deleteAllForStation(stationId);

  @override
  Future<void> removeByPodcast(int podcastId) async {
    // Find every station that contains this podcast, then remove all
    // StationEpisode rows that belong to that (station, podcast) pair.
    final stationIds = await _podcastDatasource.getStationIdsForPodcast(
      podcastId,
    );
    for (final stationId in stationIds) {
      final episodes = await _episodeDatasource.getAllForStation(stationId);
      final idsToDelete = episodes
          .where((e) => e.stationId == stationId)
          .map((e) => e.id)
          .toList();
      if (idsToDelete.isNotEmpty) {
        await _episodeDatasource.deleteByIds(idsToDelete);
      }
    }
  }
}
