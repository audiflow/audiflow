import '../models/station_podcast.dart';

abstract class StationPodcastRepository {
  /// Returns all podcast links for a station (one-shot query).
  Future<List<StationPodcast>> getByStation(int stationId);

  Stream<List<StationPodcast>> watchByStation(int stationId);

  /// Adds a station–podcast link with optional [sortOrder] and [episodeLimit].
  Future<void> add(
    int stationId,
    int podcastId, {
    int sortOrder = 0,
    int? episodeLimit,
  });

  /// Updates sortOrder and episodeLimit on an existing station-podcast link.
  Future<void> update(StationPodcast stationPodcast);

  Future<void> remove(int stationId, int podcastId);
  Future<void> removeAllForStation(int stationId);
}
