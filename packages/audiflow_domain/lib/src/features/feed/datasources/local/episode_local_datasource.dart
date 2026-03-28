import 'package:isar_community/isar.dart';

import '../../models/episode.dart';

/// Local datasource for episode operations using Isar.
///
/// Provides CRUD operations and upsert support for the Episode collection.
class EpisodeLocalDatasource {
  EpisodeLocalDatasource(this._isar);

  final Isar _isar;

  /// Upserts an episode (insert or update on conflict).
  ///
  /// Matches on composite key (podcastId, guid). Returns the episode ID.
  Future<int> upsert(Episode episode) async {
    await _isar.writeTxn(() async {
      final existing = await _isar.episodes.getByPodcastIdGuid(
        episode.podcastId,
        episode.guid,
      );
      if (existing != null) {
        episode.id = existing.id;
      }
      await _isar.episodes.put(episode);
    });
    return episode.id;
  }

  /// Upserts multiple episodes in a batch.
  Future<void> upsertAll(List<Episode> episodes) async {
    await _isar.writeTxn(() async {
      for (final episode in episodes) {
        final existing = await _isar.episodes.getByPodcastIdGuid(
          episode.podcastId,
          episode.guid,
        );
        if (existing != null) {
          episode.id = existing.id;
        }
      }
      await _isar.episodes.putAll(episodes);
    });
  }

  /// Returns all episodes for a podcast, ordered by publish date
  /// (newest first).
  Future<List<Episode>> getByPodcastId(int podcastId) {
    return _isar.episodes
        .filter()
        .podcastIdEqualTo(podcastId)
        .sortByPublishedAtDesc()
        .findAll();
  }

  /// Watches episodes for a podcast, emitting updates when data changes.
  Stream<List<Episode>> watchByPodcastId(int podcastId) {
    return _isar.episodes
        .filter()
        .podcastIdEqualTo(podcastId)
        .sortByPublishedAtDesc()
        .watch(fireImmediately: true);
  }

  /// Returns an episode by its ID.
  Future<Episode?> getById(int id) {
    return _isar.episodes.get(id);
  }

  /// Returns an episode by podcast ID and guid.
  Future<Episode?> getByPodcastIdAndGuid(int podcastId, String guid) {
    return _isar.episodes.getByPodcastIdGuid(podcastId, guid);
  }

  /// Returns an episode by its audio URL.
  ///
  /// Multiple episodes may share the same audio URL across podcasts,
  /// so this returns the first match.
  Future<Episode?> getByAudioUrl(String audioUrl) {
    return _isar.episodes.filter().audioUrlEqualTo(audioUrl).findFirst();
  }

  /// Returns all episode GUIDs for a podcast.
  ///
  /// Used for early-stop optimization during RSS parsing.
  Future<Set<String>> getGuidsByPodcastId(int podcastId) async {
    final episodes = await _isar.episodes
        .filter()
        .podcastIdEqualTo(podcastId)
        .findAll();
    return episodes.map((e) => e.guid).toSet();
  }

  /// Returns the newest episode for a podcast by publishedAt descending.
  ///
  /// Used for pubDate-based early-stop optimization during RSS parsing.
  /// Returns null if no episodes exist for the podcast.
  Future<Episode?> getNewestByPodcastId(int podcastId) async {
    return _isar.episodes
        .filter()
        .podcastIdEqualTo(podcastId)
        .sortByPublishedAtDesc()
        .findFirst();
  }

  /// Deletes all episodes for a podcast.
  Future<int> deleteByPodcastId(int podcastId) {
    return _isar.writeTxn(
      () => _isar.episodes.filter().podcastIdEqualTo(podcastId).deleteAll(),
    );
  }

  /// Returns episodes by their IDs.
  ///
  /// Order is not guaranteed; caller should sort as needed.
  Future<List<Episode>> getByIds(List<int> ids) async {
    if (ids.isEmpty) return [];
    final results = await _isar.episodes.getAll(ids);
    return results.whereType<Episode>().toList();
  }

  /// Gets episodes after a given episode number, ordered by episode
  /// number ascending.
  ///
  /// Returns episodes from [podcastId] with episode numbers greater than
  /// [afterEpisodeNumber]. If [afterEpisodeNumber] is null, returns from
  /// the beginning.
  Future<List<Episode>> getSubsequentEpisodes({
    required int podcastId,
    required int? afterEpisodeNumber,
    required int limit,
  }) async {
    var query = _isar.episodes.filter().podcastIdEqualTo(podcastId);

    if (afterEpisodeNumber != null) {
      // episodeNumber > afterEpisodeNumber rewritten as
      // afterEpisodeNumber < episodeNumber
      query = query.episodeNumberIsNotNull().and().episodeNumberGreaterThan(
        afterEpisodeNumber,
      );
    }

    return query.sortByEpisodeNumber().limit(limit).findAll();
  }
}
