import 'package:isar_community/isar.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../common/providers/database_provider.dart';
import '../../feed/models/episode.dart';
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
    isar: isar,
    episodeDatasource: episodeDatasource,
    podcastDatasource: podcastDatasource,
  );
}

/// Implementation of [StationEpisodeRepository] using Isar database.
class StationEpisodeRepositoryImpl implements StationEpisodeRepository {
  StationEpisodeRepositoryImpl({
    required Isar isar,
    required StationEpisodeLocalDatasource episodeDatasource,
    required StationPodcastLocalDatasource podcastDatasource,
  }) : _isar = isar,
       _episodeDatasource = episodeDatasource,
       _podcastDatasource = podcastDatasource;

  final Isar _isar;
  final StationEpisodeLocalDatasource _episodeDatasource;
  final StationPodcastLocalDatasource _podcastDatasource;

  @override
  Stream<List<StationEpisode>> watchByStation(
    int stationId, {
    int? limit,
    int? offset,
    bool ascending = false,
  }) => _episodeDatasource.watchByStation(
    stationId,
    limit: limit,
    offset: offset,
    ascending: ascending,
  );

  @override
  Future<int> countByStation(int stationId) =>
      _episodeDatasource.countByStation(stationId);

  @override
  Future<void> removeAllForStation(int stationId) =>
      _episodeDatasource.deleteAllForStation(stationId);

  @override
  Future<void> removeByPodcast(int podcastId) async {
    // Find every station that contains this podcast, then remove
    // StationEpisode rows whose episodeId belongs to that podcast.
    final stationIds = await _podcastDatasource.getStationIdsForPodcast(
      podcastId,
    );
    if (stationIds.isEmpty) return;

    // Look up episodeIds that belong to this podcast
    final podcastEpisodes = await _isar.episodes
        .filter()
        .podcastIdEqualTo(podcastId)
        .findAll();
    final podcastEpisodeIds = podcastEpisodes.map((e) => e.id).toSet();
    if (podcastEpisodeIds.isEmpty) return;

    for (final stationId in stationIds) {
      final stationEpisodes = await _episodeDatasource.getAllForStation(
        stationId,
      );
      final idsToDelete = stationEpisodes
          .where((se) => podcastEpisodeIds.contains(se.episodeId))
          .map((se) => se.id)
          .toList();
      if (idsToDelete.isNotEmpty) {
        await _episodeDatasource.deleteByIds(idsToDelete);
      }
    }
  }
}
