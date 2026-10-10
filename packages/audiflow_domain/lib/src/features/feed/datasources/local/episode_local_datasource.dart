import 'package:audiflow_podcast/audiflow_podcast.dart'
    show duplicateGuidKey, duplicateGuidSeparator, guidOfStorageKey;
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
  /// App-owned state on an existing row is kept (see [_keepAppState]).
  Future<int> upsert(Episode episode) async {
    await _isar.writeTxn(() async {
      final existing = await _isar.episodes.getByPodcastIdGuid(
        episode.podcastId,
        episode.guid,
      );
      if (existing != null) {
        _keepAppState(episode, existing);
      }
      await _isar.episodes.put(episode);
    });
    return episode.id;
  }

  /// Upserts multiple episodes in a batch.
  ///
  /// Feeds sometimes reuse one guid for several items. Each item is stored
  /// under the key [_FeedItemBatch.claim] picks, and its `guid` is
  /// rewritten to that key so callers see where it was stored. An item
  /// that repeats an episode already in the batch is skipped, since
  /// writing it would violate the unique index and abort the whole batch;
  /// its `guid` becomes the key of the episode it repeats.
  /// App-owned state on existing rows is kept (see [_keepAppState]).
  Future<void> upsertAll(List<Episode> episodes) async {
    await _isar.writeTxn(() async {
      final batch = _FeedItemBatch();
      for (final episode in episodes) {
        batch.claim(episode, await _storedSiblings(episode, batch));
      }
      await _isar.episodes.putAll(batch.episodes);
    });
  }

  /// Stored rows created from feed items with [episode]'s guid: the row
  /// under the raw guid and every duplicate-guid row.
  Future<List<Episode>> _storedSiblings(
    Episode episode,
    _FeedItemBatch batch,
  ) async {
    final raw = await _isar.episodes.getByPodcastIdGuid(
      episode.podcastId,
      episode.guid,
    );
    final duplicates = await batch.storedDuplicates(
      episode.podcastId,
      () => _storedDuplicates(episode.podcastId),
    );
    return [?raw, ...?duplicates[episode.guid]];
  }

  /// A podcast's duplicate-guid rows grouped by their feed guid. Loaded
  /// once per batch: such rows are rare, and a raw guid alone cannot
  /// find a row whose key was built from an enclosure URL since changed.
  Future<Map<String, List<Episode>>> _storedDuplicates(int podcastId) async {
    final rows = await _isar.episodes
        .where()
        .podcastIdEqualToAnyGuid(podcastId)
        .filter()
        .guidContains(duplicateGuidSeparator)
        .findAll();
    final byGuid = <String, List<Episode>>{};
    for (final row in rows) {
      (byGuid[guidOfStorageKey(row.guid)] ??= []).add(row);
    }
    return byGuid;
  }

  /// Returns the stored episode for a feed item: the row stored with its
  /// guid and current audio URL.
  ///
  /// Every upserted item's row holds its current audio URL, so no match
  /// means the item was not stored (a repost skipped in favor of another
  /// item); falling back to the raw guid would hand its media to another
  /// episode.
  Future<Episode?> getByFeedItem(
    int podcastId,
    String guid,
    String audioUrl,
  ) async {
    final raw = await _isar.episodes.getByPodcastIdGuid(podcastId, guid);
    // An item without an enclosure URL can only be matched by guid.
    if (audioUrl.isEmpty || raw?.audioUrl == audioUrl) return raw;
    final duplicate = await _isar.episodes
        .where()
        .podcastIdEqualToAnyGuid(podcastId)
        .filter()
        .guidStartsWith(duplicateGuidKey(guid, ''))
        .audioUrlEqualTo(audioUrl)
        .findFirst();
    return duplicate;
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

/// Storage keys claimed by one [EpisodeLocalDatasource.upsertAll] batch.
class _FeedItemBatch {
  final _byKey = <(int, String), Episode>{};
  final _byGuid = <(int, String), List<Episode>>{};
  final _duplicatesByPodcast = <int, Map<String, List<Episode>>>{};

  List<Episode> get episodes => _byKey.values.toList();

  Future<Map<String, List<Episode>>> storedDuplicates(
    int podcastId,
    Future<Map<String, List<Episode>>> Function() load,
  ) async => _duplicatesByPodcast[podcastId] ??= await load();

  /// Rewrites [episode]'s guid to its storage key, given the [stored]
  /// rows sharing its guid, and queues it for writing unless the batch
  /// already holds the same episode.
  ///
  /// A matching stored row keeps its key, id and app state, whichever key
  /// it is under; only an unmatched item gets a new key: the raw guid
  /// when free, otherwise its duplicate-guid key. A skipped repeat takes
  /// the key of the episode it repeats, so callers recording observed
  /// keys never mark another stored episode as still in the feed.
  void claim(Episode episode, List<Episode> stored) {
    final guidKey = (episode.podcastId, episode.guid);
    final queued = _byGuid[guidKey] ?? const <Episode>[];
    final repeated = queued.where((other) => _isSameEpisode(other, episode));
    if (repeated.isNotEmpty) {
      episode.guid = repeated.first.guid;
      return;
    }
    final unclaimed = stored.where(
      (row) => !_byKey.containsKey((row.podcastId, row.guid)),
    );
    final match = _bestMatch(unclaimed, episode);
    final key = match?.guid ?? _newKey(episode, [...stored, ...queued]);
    episode.guid = key;
    // Never queue two items under one key: the write would abort.
    if (_byKey.containsKey((episode.podcastId, key))) return;
    if (match != null) _keepAppState(episode, match);
    _byKey[(episode.podcastId, key)] = episode;
    (_byGuid[guidKey] ??= []).add(episode);
  }

  /// A row with the same audio URL first, so a date match never takes a
  /// row that another item in the feed matches exactly; then the same
  /// date; then, when a date is missing, the raw-guid row before any
  /// duplicate, as the guid alone decided before reused guids were told
  /// apart.
  static Episode? _bestMatch(Iterable<Episode> rows, Episode episode) =>
      rows.where((row) => row.audioUrl == episode.audioUrl).firstOrNull ??
      rows.where((row) => _isSameEpisode(row, episode)).firstOrNull ??
      _undatedMatch(rows, episode);

  static Episode? _undatedMatch(Iterable<Episode> rows, Episode episode) {
    final candidates = rows.where(
      (row) => row.publishedAt == null || episode.publishedAt == null,
    );
    return candidates.where((row) => row.guid == episode.guid).firstOrNull ??
        candidates.firstOrNull;
  }

  static String _newKey(Episode episode, Iterable<Episode> taken) {
    final takenKeys = {for (final row in taken) row.guid};
    if (!takenKeys.contains(episode.guid)) return episode.guid;
    return duplicateGuidKey(episode.guid, episode.audioUrl);
  }
}

/// Carries the existing row's identity and app-owned state onto
/// [incoming].
///
/// Callers build [incoming] from feed data, so fields the feed does not
/// carry arrive at their defaults; without this, every feed refresh would
/// clear favorites and re-arm auto-download.
void _keepAppState(Episode incoming, Episode existing) {
  incoming
    ..id = existing.id
    ..isFavorited = existing.isFavorited
    ..favoritedAt = existing.favoritedAt
    ..autoDownloadEnqueued = existing.autoDownloadEnqueued;
}

/// Two items with one guid are the same episode when the enclosure URL or
/// the publish date matches: hosts rewrite enclosure URLs (tracking
/// prefixes, signed URLs) but keep the date, and a reposted item keeps the
/// date too. A guid reused for a new episode changes both.
///
/// A missing date proves nothing either way; stored rows fall back to the
/// guid for it (see [_FeedItemBatch._undatedMatch]), but two items in one
/// batch are only collapsed on positive evidence, so an undated item never
/// swallows a dated one that identifies another stored row.
bool _isSameEpisode(Episode a, Episode b) {
  if (a.audioUrl == b.audioUrl) return true;
  final (aDate, bDate) = (a.publishedAt, b.publishedAt);
  // Isar returns local time; compare instants, not representations.
  return aDate != null && bDate != null && aDate.isAtSameMomentAs(bDate);
}
