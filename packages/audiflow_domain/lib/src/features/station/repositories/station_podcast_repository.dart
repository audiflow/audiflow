import '../models/station_podcast.dart';

abstract class StationPodcastRepository {
  /// Returns all podcast links for a station (one-shot query).
  Future<List<StationPodcast>> getByStation(int stationId);

  Stream<List<StationPodcast>> watchByStation(int stationId);
  Future<void> add(int stationId, int podcastId);
  Future<void> remove(int stationId, int podcastId);
  Future<void> removeAllForStation(int stationId);
}
