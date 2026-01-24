import 'package:audiflow_podcast/audiflow_podcast.dart';

import '../../../common/database/app_database.dart';

/// Repository interface for episode operations.
///
/// Abstracts the data layer for fetching and persisting podcast episodes.
abstract class EpisodeRepository {
  /// Returns all episodes for a podcast, ordered by publish date (newest first).
  Future<List<Episode>> getByPodcastId(int podcastId);

  /// Watches episodes for a podcast, emitting updates when data changes.
  Stream<List<Episode>> watchByPodcastId(int podcastId);

  /// Returns an episode by its ID, or null if not found.
  Future<Episode?> getById(int id);

  /// Returns an episode by its audio URL, or null if not found.
  Future<Episode?> getByAudioUrl(String audioUrl);

  /// Upserts episodes for a podcast from RSS feed data.
  ///
  /// Uses the composite unique key (podcastId, guid) for conflict resolution.
  Future<void> upsertEpisodes(List<EpisodesCompanion> episodes);

  /// Upserts episodes from parsed RSS feed items.
  ///
  /// Converts [PodcastItem] list to [EpisodesCompanion] and persists them.
  /// Items without guid or enclosureUrl are skipped.
  Future<void> upsertFromFeedItems(int podcastId, List<PodcastItem> items);

  /// Returns episodes by their IDs.
  ///
  /// Order is not guaranteed; caller should sort as needed.
  Future<List<Episode>> getByIds(List<int> ids);
}
