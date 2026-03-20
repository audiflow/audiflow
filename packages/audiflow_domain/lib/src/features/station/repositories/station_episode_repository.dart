import '../models/station_episode.dart';

abstract class StationEpisodeRepository {
  Stream<List<StationEpisode>> watchByStation(
    int stationId, {
    int? limit,
    int? offset,
    bool ascending = false,
  });
  Future<int> countByStation(int stationId);
  Future<void> removeAllForStation(int stationId);

  /// Removes all [StationEpisode] entries that belong to [podcastId] across
  /// every station that includes that podcast.
  Future<void> removeByPodcast(int podcastId);
}
