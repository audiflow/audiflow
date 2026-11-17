import 'package:isar_community/isar.dart';

import '../feed/models/episode.dart';
import '../queue/models/queue_item.dart';
import '../station/models/station.dart';
import '../station/models/station_duration_filter.dart';
import '../station/models/station_episode.dart';
import '../station/models/station_podcast.dart';
import '../subscription/models/subscriptions.dart';
import '../subscription/services/feed_placeholder_id.dart';
import '../user_state/models/podcast_user_state.dart';
import '../user_state/models/queue_entry.dart';
import '../user_state/models/station_state.dart';
import '../user_state/models/sync_meta.dart';
import '../user_state/services/queue_entry_access.dart' show positionForRank;
import 'snapshot_merger.dart';

/// What [RestoreProjector.projectLibrary] leaves for the caller to finish.
class RestoreProjection {
  const RestoreProjection({required this.feedUrls, required this.stationIds});

  /// Feed URLs of the subscribed podcasts, to fetch again: a restore brings
  /// no catalog, so episodes appear only once their feeds are read.
  final List<String> feedUrls;

  /// Isar ids of the live stations, whose episode lists need reconciling.
  final List<int> stationIds;
}

/// Projects merged user state back onto the rows the app reads:
/// `Subscription`, `Station`, `StationPodcast`, and `QueueItem`.
///
/// After [SnapshotMerger.merge] only the keyed state holds the backup. The
/// rows are written directly instead of through the datasources, because
/// those record every write on the keyed state with a new clock, which
/// would make this device's copy beat the merged values everywhere.
///
/// Every step writes a row only when it changes, so running it again
/// changes nothing.
class RestoreProjector {
  RestoreProjector(this._isar);

  final Isar _isar;

  /// Projects subscriptions and stations in one write transaction.
  ///
  /// [podcastInfo] names podcasts this device has never fetched; [now]
  /// dates rows that the state gives no date for.
  Future<RestoreProjection> projectLibrary({
    required Map<String, SnapshotPodcastInfo> podcastInfo,
    DateTime? now,
  }) {
    final at = now ?? DateTime.now();
    return _isar.writeTxn(() async {
      final feedUrls = await _projectSubscriptions(podcastInfo, at);
      final stationIds = await _projectStations(at);
      return RestoreProjection(feedUrls: feedUrls, stationIds: stationIds);
    });
  }

  /// Projects the queue in its own write transaction, and returns how many
  /// entries it left out.
  ///
  /// Run after the feeds are fetched: an entry names its episode by key,
  /// which an episode gets only from a feed parse. Entries whose episode
  /// is not here yet are left out, and [SyncMeta.queueProjectionPending]
  /// asks the next feed sync to run [projectQueueIfPending].
  Future<int> projectQueue() => _isar.writeTxn(() async {
    var skipped = 0;
    final entries = await _isar.queueEntrys.where().findAll();
    final removed = {
      for (final e in entries)
        if (e.deleted) e.entryId,
    };
    final live = entries.where((e) => !e.deleted).toList()..sort(_byRank);
    final items = await _isar.queueItems.where().sortByPosition().findAll();
    final byEntry = {
      for (final item in items)
        if (item.entryId != null) item.entryId!: item,
    };
    final before = {for (final item in items) item.id: _describeItem(item)};

    final projected = <QueueItem>[];
    final ranks = <String>[];
    for (final entry in live) {
      final episode = await _isar.episodes
          .where()
          .episodeKeyEqualTo(entry.episodeKey)
          .findFirst();
      if (episode == null) {
        skipped++;
        continue;
      }
      final existing = byEntry[entry.entryId];
      final item = existing ?? (QueueItem()..entryId = entry.entryId);
      item
        ..episodeId = episode.id
        ..isAdhoc = entry.isAdhoc
        ..sourceContext = entry.sourceContext
        ..addedAt = entry.addedAt ?? existing?.addedAt ?? DateTime.now();
      projected.add(item);
      ranks.add(entry.rank);
    }
    final kept = projected.toSet();
    final leftovers = [
      for (final item in items)
        if (!kept.contains(item) && !removed.contains(item.entryId)) item,
    ];
    // Positions come from the ranks, not a fresh count: a later queue edit
    // saves the edited item's rank from its position, so the two must stay
    // in one number space or the next projection would undo the edit. Ties
    // (equal ranks from two devices) and ranks of another form take the
    // next free position.
    var last = -1;
    for (var i = 0; i < projected.length; i++) {
      var position = positionForRank(ranks[i]) ?? last + 1;
      if (position <= last) position = last + 1;
      projected[i].position = position;
      last = position;
    }
    for (final item in leftovers) {
      item.position = ++last;
    }
    final ordered = [...projected, ...leftovers];

    await _isar.queueItems.deleteAll([
      for (final item in items)
        if (removed.contains(item.entryId)) item.id,
    ]);
    await _isar.queueItems.putAll([
      for (final item in ordered)
        if (before[item.id] != _describeItem(item)) item,
    ]);
    final meta = await _isar.syncMetas.get(SyncMeta.singletonId);
    final pending = 0 < skipped;
    if (meta != null && meta.queueProjectionPending != pending) {
      await _isar.syncMetas.put(meta..queueProjectionPending = pending);
    }
    return skipped;
  });

  /// Runs [projectQueue] again when a restore left entries out, so they
  /// appear once a later feed sync brings their episodes.
  Future<void> projectQueueIfPending() async {
    final meta = await _isar.syncMetas.get(SyncMeta.singletonId);
    if (meta == null || !meta.queueProjectionPending) return;
    await projectQueue();
  }

  Future<List<String>> _projectSubscriptions(
    Map<String, SnapshotPodcastInfo> podcastInfo,
    DateTime now,
  ) async {
    final feedUrls = <String>{};
    final states = await _isar.podcastUserStates.where().findAll();
    for (final state in states) {
      if (!state.subscribed) {
        await _unsubscribe(state);
        continue;
      }
      final feedUrl = state.feedUrl;
      // Without a feed there is nothing to fetch or show.
      if (feedUrl == null) continue;
      final itunesId = state.itunesId ?? feedPlaceholderId(feedUrl);
      final existing = await _findSubscription(state, feedUrl, itunesId);
      final sub =
          existing ??
          _newSubscription(
            state,
            feedUrl,
            itunesId,
            podcastInfo[state.podcastKey],
            now,
          );
      final before = existing == null ? null : _describeSubscription(existing);
      final oldUrl = existing?.feedUrl;
      // The state's key verbatim: a key derived here again (say from a
      // guid) need not match the one the episodes and stations use.
      sub
        ..podcastKey ??= state.podcastKey
        // The merged URL wins over the row's: after a feed moves, the old
        // URL may no longer serve, and a later write would stamp it back.
        ..feedUrl = feedUrl
        ..isCached = false
        ..autoDownload = state.autoDownload
        ..autoDownloadKeepCount = state.autoDownloadKeepCount;
      final subscribedAt = state.subscribedAt;
      if (subscribedAt != null) sub.subscribedAt = subscribedAt;
      if (oldUrl != null && oldUrl != feedUrl) {
        // Validators of the old URL; sent to the new one, a 304 would skip
        // the parse, as promoteCached also avoids.
        sub
          ..httpEtag = null
          ..httpLastModified = null;
      }
      if (before != _describeSubscription(sub)) {
        await _isar.subscriptions.put(sub);
      }
      feedUrls.add(sub.feedUrl);
    }
    return feedUrls.toList();
  }

  /// Marks the podcast's subscribed rows as cached: the merge brought an
  /// unsubscribe newer than this device's subscribe. The rows stay, so the
  /// podcast's episodes and history keep their ids.
  Future<void> _unsubscribe(PodcastUserState state) async {
    // A zero clock means no subscription choice ever arrived, only other
    // sections, so it says nothing about the local rows.
    if (state.subscribedHlc == 0) return;
    final subs = await _isar.subscriptions
        .filter()
        .podcastKeyEqualTo(state.podcastKey)
        .isCachedEqualTo(false)
        .findAll();
    if (subs.isEmpty) return;
    for (final sub in subs) {
      sub.isCached = true;
    }
    await _isar.subscriptions.putAll(subs);
  }

  Future<Subscription?> _findSubscription(
    PodcastUserState state,
    String feedUrl,
    String itunesId,
  ) async =>
      await _subscriptionByKey(state.podcastKey) ??
      await _isar.subscriptions.filter().feedUrlEqualTo(feedUrl).findFirst() ??
      await _isar.subscriptions.getByItunesId(itunesId);

  /// The row for [podcastKey]; a subscribed one wins over cached rows that
  /// share the key.
  Future<Subscription?> _subscriptionByKey(String podcastKey) async {
    final subs = await _isar.subscriptions
        .filter()
        .podcastKeyEqualTo(podcastKey)
        .findAll();
    if (subs.isEmpty) return null;
    return subs.firstWhere((s) => !s.isCached, orElse: () => subs.first);
  }

  Subscription _newSubscription(
    PodcastUserState state,
    String feedUrl,
    String itunesId,
    SnapshotPodcastInfo? info,
    DateTime now,
  ) {
    return Subscription()
      ..itunesId = itunesId
      ..feedUrl = feedUrl
      ..title = info?.title ?? feedUrl
      ..artistName = info?.artistName ?? ''
      ..artworkUrl = info?.artworkUrl
      ..subscribedAt = now;
  }

  Future<List<int>> _projectStations(DateTime now) async {
    final ids = <int>[];
    final states = await _isar.stationStates.where().findAll();
    for (final state in states) {
      final existing = await _isar.stations
          .where()
          .stationIdEqualTo(state.stationId)
          .findAll();
      if (state.deleted) {
        for (final station in existing) {
          await _removeStation(station);
        }
        continue;
      }
      final station = existing.isEmpty
          ? (Station()
              ..stationId = state.stationId
              ..createdAt = state.createdAt ?? now
              ..updatedAt = now)
          : existing.first;
      final before = existing.isEmpty ? null : _describeStation(station);
      _applyStation(station, state);
      if (before != _describeStation(station)) {
        await _isar.stations.put(station);
      }
      await _projectMembers(station, now);
      ids.add(station.id);
    }
    return ids;
  }

  Future<void> _removeStation(Station station) async {
    await _isar.stationPodcasts
        .filter()
        .stationIdEqualTo(station.id)
        .deleteAll();
    await _isar.stationEpisodes
        .filter()
        .stationIdEqualTo(station.id)
        .deleteAll();
    await _isar.stations.delete(station.id);
  }

  /// Links [station] to the podcast of each live member and unlinks the
  /// podcasts that are no longer members.
  Future<void> _projectMembers(Station station, DateTime now) async {
    final members = await _isar.stationMembers
        .filter()
        .stationIdEqualTo(station.stationId!)
        .deletedEqualTo(false)
        .findAll();
    final memberKeys = {for (final m in members) m.podcastKey};
    final linked = <int>{};
    for (final member in members) {
      final sub = await _subscriptionByKey(member.podcastKey);
      // Its podcast is not on this device; a later run links it.
      if (sub == null) continue;
      final existing = await _isar.stationPodcasts.getByStationIdPodcastId(
        station.id,
        sub.id,
      );
      final link =
          existing ??
          (StationPodcast()
            ..stationId = station.id
            ..podcastId = sub.id
            ..addedAt = member.addedAt ?? now);
      final before = existing == null ? null : _describeLink(link);
      link
        ..episodeLimit = member.episodeLimit
        ..sortOrder = member.sortOrder;
      if (before != _describeLink(link)) {
        await _isar.stationPodcasts.put(link);
      }
      linked.add(link.id);
    }

    final links = await _isar.stationPodcasts
        .filter()
        .stationIdEqualTo(station.id)
        .findAll();
    final others = [
      for (final l in links)
        if (!linked.contains(l.id)) l,
    ];
    if (others.isEmpty) return;
    final subs = await _isar.subscriptions.getAll([
      for (final l in others) l.podcastId,
    ]);
    final stale = <int>[];
    for (var i = 0; i < others.length; i++) {
      final sub = subs[i];
      if (sub == null) {
        stale.add(others[i].id);
        continue;
      }
      final key = sub.podcastKey;
      // An unkeyed podcast never had a member to compare against, and a
      // second row sharing a member's key is still that member.
      if (key == null || memberKeys.contains(key)) continue;
      stale.add(others[i].id);
    }
    await _isar.stationPodcasts.deleteAll(stale);
  }

  static void _applyStation(Station station, StationState state) {
    final operator = state.durationOperator;
    station
      ..name = state.name
      ..sortOrder = state.sortOrder
      ..episodeSortType = state.episodeSortType
      ..hideCompleted = state.hideCompleted
      ..filterDownloaded = state.filterDownloaded
      ..filterFavorited = state.filterFavorited
      ..durationFilter = operator == null
          ? null
          : (StationDurationFilter()
              ..durationOperator = operator
              ..durationMinutes = state.durationMinutes)
      ..publishedWithinDays = state.publishedWithinDays
      ..defaultEpisodeLimit = state.defaultEpisodeLimit
      ..groupByPodcast = state.groupByPodcast
      ..podcastSortType = state.podcastSortType
      ..lastPlayedAt = state.lastPlayedAt;
  }

  static int _byRank(QueueEntry a, QueueEntry b) {
    final byRank = a.rank.compareTo(b.rank);
    return byRank != 0 ? byRank : a.entryId.compareTo(b.entryId);
  }

  // Each describes the fields this class writes, so a row is put only when
  // one of them changed. Times compare as instants: Isar reads them back
  // in local time.
  static String _describeSubscription(Subscription s) =>
      '${s.podcastKey}|${s.feedUrl}|${s.isCached}|${s.autoDownload}|'
      '${s.autoDownloadKeepCount}|${_micros(s.subscribedAt)}';

  static String _describeStation(Station s) =>
      '${s.name}|${s.sortOrder}|${s.episodeSortType}|${s.hideCompleted}|'
      '${s.filterDownloaded}|${s.filterFavorited}|'
      '${s.durationFilter?.durationOperator}|'
      '${s.durationFilter?.durationMinutes}|${s.publishedWithinDays}|'
      '${s.defaultEpisodeLimit}|${s.groupByPodcast}|${s.podcastSortType}|'
      '${_micros(s.lastPlayedAt)}';

  static String _describeLink(StationPodcast l) =>
      '${l.episodeLimit}|${l.sortOrder}';

  static String _describeItem(QueueItem q) =>
      '${q.episodeId}|${q.position}|${q.entryId}|${q.isAdhoc}|'
      '${q.sourceContext}|${_micros(q.addedAt)}';

  static int? _micros(DateTime? t) => t?.microsecondsSinceEpoch;
}
