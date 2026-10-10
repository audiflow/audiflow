import 'package:audiflow_podcast/audiflow_podcast.dart' show duplicateGuidKey;
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
  ///
  /// Feeds sometimes reuse one guid for several items. Each item is stored
  /// under the key from [_resolveKey], and its `guid` is rewritten to that
  /// key so callers see where it was stored. An item that repeats an
  /// episode already in the batch is skipped, since writing it would
  /// violate the unique index and abort the whole batch.
  Future<void> upsertAll(List<Episode> episodes) async {
    await _isar.writeTxn(() async {
      final pending = <(int, String), Episode>{};
      for (final episode in episodes) {
        final key = await _resolveKey(episode, pending);
        if (key == null) continue;
        episode.guid = key;
        pending[(episode.podcastId, key)] = episode;
      }
      await _isar.episodes.putAll(pending.values.toList());
    });
  }

  /// Picks the storage key for [episode]: its guid when that is free or
  /// already holds the same episode, otherwise its duplicate-guid key.
  /// Sets the stored row's id on a match. Returns null when the batch
  /// already holds the same episode.
  Future<String?> _resolveKey(
    Episode episode,
    Map<(int, String), Episode> pending,
  ) async {
    final candidates = [
      episode.guid,
      duplicateGuidKey(episode.guid, episode.audioUrl),
    ];
    for (final key in candidates) {
      final queued = pending[(episode.podcastId, key)];
      if (queued != null) {
        if (_isSameEpisode(queued, episode)) return null;
        continue;
      }
      final stored = await _isar.episodes.getByPodcastIdGuid(
        episode.podcastId,
        key,
      );
      if (stored == null) return key;
      if (_isSameEpisode(stored, episode)) {
        episode.id = stored.id;
        return key;
      }
    }
    return null;
  }

  /// Two items with one guid are the same episode when the enclosure URL
  /// or the publish date matches: hosts rewrite enclosure URLs (tracking
  /// prefixes, signed URLs) but keep the date, and a reposted item keeps
  /// the date too. A guid reused for a new episode changes both.
  static bool _isSameEpisode(Episode a, Episode b) {
    if (a.audioUrl == b.audioUrl) return true;
    final (aDate, bDate) = (a.publishedAt, b.publishedAt);
    // Isar returns local time; compare instants, not representations.
    return aDate != null && bDate != null && aDate.isAtSameMomentAs(bDate);
  }

  /// Returns the stored episode for a feed item, checking its
  /// duplicate-guid key before its raw guid.
  Future<Episode?> getByFeedItem(
    int podcastId,
    String guid,
    String audioUrl,
  ) async {
    final duplicate = await _isar.episodes.getByPodcastIdGuid(
      podcastId,
      duplicateGuidKey(guid, audioUrl),
    );
    return duplicate ?? _isar.episodes.getByPodcastIdGuid(podcastId, guid);
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

  /// Returns each stored episode key of a podcast with its audio URL.
  ///
  /// Used for early-stop during RSS parsing, so a known guid only stops the
  /// parse when the item's enclosure URL matches the stored one.
  Future<Map<String, String>> getAudioUrlsByGuid(int podcastId) async {
    final episodes = await _isar.episodes
        .filter()
        .podcastIdEqualTo(podcastId)
        .findAll();
    return {for (final e in episodes) e.guid: e.audioUrl};
  }

  /// Returns the newest episode for a podcast by publishedAt descending.
  ///
  /// Used for pubDate-based early-stop optimization during RSS parsing.
  /// Returns null if no episodes exist for the podcast.
  Future<Episode?> getNewestByPodcastId(int podcastId) {
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

  /// Deletes episodes for [podcastId] whose guid is in [guids].
  ///
  /// No protection is applied: favorited, downloaded, or played episodes are
  /// deleted just like any other. This matches the "RSS is the source of
  /// truth" policy — if the feed drops an episode, the app drops it too.
  ///
  /// Returns the number of deleted rows. Returns 0 immediately when [guids]
  /// is empty, avoiding an unnecessary write transaction.
  Future<int> deleteByPodcastIdAndGuids(
    int podcastId,
    Set<String> guids,
  ) async {
    if (guids.isEmpty) return 0;
    return _isar.writeTxn(() async {
      final targetIds = await _isar.episodes
          .filter()
          .podcastIdEqualTo(podcastId)
          .anyOf(guids.toList(), (q, guid) => q.guidEqualTo(guid))
          .idProperty()
          .findAll();
      if (targetIds.isEmpty) return 0;
      return _isar.episodes.deleteAll(targetIds);
    });
  }

  /// Returns episodes by their IDs.
  ///
  /// Order is not guaranteed; caller should sort as needed.
  Future<List<Episode>> getByIds(List<int> ids) async {
    if (ids.isEmpty) return [];
    final results = await _isar.episodes.getAll(ids);
    return results.whereType<Episode>().toList();
  }

  /// Returns episodes for [podcastId] not yet processed by the
  /// auto-download pipeline, ordered by publish date (newest first).
  ///
  /// Used to enqueue auto-downloads for new episodes regardless of which
  /// sync path (foreground or background) first ingested them.
  Future<List<Episode>> getPendingAutoDownloadByPodcastId(int podcastId) {
    return _isar.episodes
        .filter()
        .podcastIdEqualTo(podcastId)
        .autoDownloadEnqueuedEqualTo(false)
        .sortByPublishedAtDesc()
        .findAll();
  }

  /// Marks the given episode IDs as processed by the auto-download
  /// pipeline. Idempotent — episodes already marked stay marked.
  Future<void> markAutoDownloadEnqueued(Iterable<int> ids) async {
    if (ids.isEmpty) return;
    await _isar.writeTxn(() async {
      final episodes = await _isar.episodes.getAll(ids.toList());
      final updated = <Episode>[];
      for (final episode in episodes) {
        if (episode == null) continue;
        if (episode.autoDownloadEnqueued) continue;
        episode.autoDownloadEnqueued = true;
        updated.add(episode);
      }
      if (updated.isNotEmpty) {
        await _isar.episodes.putAll(updated);
      }
    });
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
