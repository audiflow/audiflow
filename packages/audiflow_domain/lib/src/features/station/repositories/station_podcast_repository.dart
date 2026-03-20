import '../models/station_podcast.dart';

abstract class StationPodcastRepository {
  Stream<List<StationPodcast>> watchByStation(int stationId);
  Future<void> add(int stationId, int podcastId);
  Future<void> remove(int stationId, int podcastId);
  Future<void> removeAllForStation(int stationId);
}
