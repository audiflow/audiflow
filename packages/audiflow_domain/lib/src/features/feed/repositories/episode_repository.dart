import 'package:audiflow_podcast/audiflow_podcast.dart';

import '../models/episode.dart';
import '../models/feed_parse_progress.dart';
import '../models/smart_playlist_episode_extractor.dart';
import '../models/smart_playlist_pattern_config.dart';

/// Repository interface for episode operations.
///
/// Abstracts the data layer for fetching and persisting podcast episodes.
abstract class EpisodeRepository {
  /// Returns all episodes for a podcast, ordered by publish date
  /// (newest first).
  Future<List<Episode>> getByPodcastId(int podcastId);

  /// Watches episodes for a podcast, emitting updates when data changes.
  Stream<List<Episode>> watchByPodcastId(int podcastId);

  /// Returns an episode by its ID, or null if not found.
  Future<Episode?> getById(int id);

  /// Returns an episode by its audio URL, or null if not found.
  Future<Episode?> getByAudioUrl(String audioUrl);

  /// Upserts episodes for a podcast.
  ///
  /// Uses the composite unique key (podcastId, guid) for conflict resolution.
  Future<void> upsertEpisodes(List<Episode> episodes);

  /// Upserts episodes from parsed RSS feed items.
  ///
  /// Converts [PodcastItem] list to [Episode] objects and persists them.
  /// Items without guid or enclosureUrl are skipped.
  ///
  /// When [extractor] is provided, season and episode numbers are extracted
  /// from episode titles using the pattern, overriding RSS metadata values.
  Future<void> upsertFromFeedItems(
    int podcastId,
    List<PodcastItem> items, {
    SmartPlaylistEpisodeExtractor? extractor,
  });

  /// Upserts episodes with per-group extractor resolution.
  ///
  /// For each episode, resolves the most specific extractor by matching
  /// against group patterns in the [config]. Falls back to definition-level
  /// extractors when no group match is found.
  Future<void> upsertFromFeedItemsWithConfig(
    int podcastId,
    List<PodcastItem> items, {
    required SmartPlaylistPatternConfig config,
  });

  /// Returns episodes by their IDs.
  ///
  /// Order is not guaranteed; caller should sort as needed.
  Future<List<Episode>> getByIds(List<int> ids);

  /// Returns all episode GUIDs for a podcast.
  ///
  /// Used for early-stop optimization during RSS parsing.
  Future<Set<String>> getGuidsByPodcastId(int podcastId);

  /// Stores transcript and chapter metadata from parsed RSS data.
  ///
  /// Resolves episode database IDs by [podcastId] + guid lookup,
  /// then persists transcript and chapter metadata. Items whose
  /// guid cannot be resolved are silently skipped.
  Future<void> storeTranscriptAndChapterDataFromParsed(
    int podcastId,
    List<ParsedEpisodeMediaMeta> mediaMetas,
  );

  /// Gets episodes after a given episode number, ordered ascending.
  ///
  /// Returns episodes from [podcastId] with episode numbers greater than
  /// [afterEpisodeNumber], ordered by episode number ascending.
  /// If [afterEpisodeNumber] is null, returns from the beginning.
  Future<List<Episode>> getSubsequentEpisodes({
    required int podcastId,
    required int? afterEpisodeNumber,
    required int limit,
  });
}
