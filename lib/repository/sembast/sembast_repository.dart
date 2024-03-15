// Copyright (c) 2024 by HANAI, Tohru.
// Copyright (c) 2024 Reedom, Inc.
// Additional contributions from project contributors.
// Originally (c) 2020 Ben Hills and the project contributors.
// All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:audiflow/core/extensions.dart';
import 'package:audiflow/entities/entities.dart';
import 'package:audiflow/repository/download_event.dart';
import 'package:audiflow/repository/episode_event.dart';
import 'package:audiflow/repository/podcast_event.dart';
import 'package:audiflow/repository/repository.dart';
import 'package:audiflow/repository/sembast/sembast_database_service.dart';
import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:sembast/sembast.dart';

/// An implementation of [Repository] that is backed by
/// [Sembast](https://github.com/tekartik/sembast.dart/tree/master/sembast)
class SembastRepository extends Repository {
  SembastRepository(
    this._ref, {
    bool cleanup = true,
    String databaseName = 'seasoning.db',
  }) {
    _databaseService = DatabaseService(databaseName, version: 1);

    if (cleanup) {
      _cleanupEpisodes().then((value) {
        log.fine('Orphan episodes cleanup complete');
      });
    }
  }

  final Ref _ref;
  final log = Logger('SembastRepository');

  final _chartsStore = intMapStoreFactory.store('charts');
  final _podcastStore = stringMapStoreFactory.store('podcast');
  final _podcastMetadataStore = stringMapStoreFactory.store('podcastMetadata');
  final _podcastStatsStore = stringMapStoreFactory.store('podcastStats');
  final _episodeStore = stringMapStoreFactory.store('episode');
  final _episodeStatsStore = stringMapStoreFactory.store('episodeStats');
  final _downloadableStore = stringMapStoreFactory.store('downloadable');
  final _queueStore = intMapStoreFactory.store('queue');
  final _playerStore = intMapStoreFactory.store('player');
  final _transcriptStore = intMapStoreFactory.store('transcript');

  late DatabaseService _databaseService;

  Future<Database> get _db async => _databaseService.database;

  PodcastEventStream get _podcastEventStream =>
      _ref.read(podcastEventStreamProvider.notifier);

  EpisodeEventStream get _episodeEventStream =>
      _ref.read(episodeEventStreamProvider.notifier);

  DownloadEventStream get _downloadEventStream =>
      _ref.read(downloadEventStreamProvider.notifier);

  // --- charts

  @override
  Future<void> savePodcastChart(PodcastChartState chart) async {
    await _chartsStore.record(1).put(await _db, chart.toJson());
  }

  @override
  Future<PodcastChartState?> loadPodcastChart() async {
    final value = await _chartsStore.record(1).get(await _db);
    return value == null ? null : PodcastChartState.fromJson(value);
  }

  // --- PodcastMetadata

  @override
  Future<void> savePodcastMetadata(
    Iterable<PodcastMetadata> metadataList,
  ) async {
    final targets = metadataList.map(
      (metadata) {
        final value = metadata.toJson();
        if (metadata.feedUrl == null || metadata.feedUrl!.isEmpty) {
          value.remove('feedUrl');
        }
        return (metadata.guid, value);
      },
    );

    await _podcastMetadataStore
        .records(targets.map((target) => target.$1))
        .put(await _db, targets.map((target) => target.$2).toList());
  }

  @override
  Future<PodcastMetadata?> findPodcastMetadata(String guid) async {
    final value = await _podcastMetadataStore.record(guid).get(await _db);
    return value == null ? null : PodcastMetadata.fromJson(value);
  }

  @override
  Future<List<PodcastMetadata>> populatePodcastFeedUrl(
    Iterable<PodcastMetadata> items,
  ) async {
    final guids = items
        .where((item) => item.feedUrl == null || item.feedUrl!.isEmpty)
        .map((item) => item.guid);
    if (guids.isEmpty) {
      return items.toList();
    }

    final values = await _podcastMetadataStore.records(guids).get(await _db);
    var i = 0;
    return items.map((item) {
      if (item.feedUrl?.isNotEmpty == true) {
        return item;
      }
      final value = values[i++];
      if (value == null) {
        return item;
      }
      return item.copyWith(feedUrl: value['feedUrl'] as String?);
    }).toList();
  }

  @override
  Future<String?> findFeedUrl(String guid) async {
    final value = await _podcastMetadataStore.record(guid).get(await _db);
    return value?['feedUrl'] as String?;
  }

  // --- Podcast

  @override
  Future<void> savePodcast(
    Podcast podcast, {
    PodcastStatsUpdateParam? statsParam,
  }) async {
    log.fine('Save Podcast: ${podcast.feedUrl}');
    final db = await _db;
    final stats = await db.transaction((txn) async {
      await _podcastStore.record(podcast.guid).put(txn, podcast.toJson());
      return statsParam == null
          ? null
          : await _updatePodcastStats(txn, statsParam);
    });
    _podcastEventStream.add(PodcastUpdatedEvent(podcast, stats: stats));
  }

  @override
  Future<Podcast?> findPodcast(String guid) async {
    final value = await _podcastStore.record(guid).get(await _db);
    if (value == null) {
      return null;
    }

    final podcast = Podcast.fromJson(value);
    final episodes = await findEpisodesByPodcastGuid(podcast.guid);
    return podcast.copyWith(episodes: episodes);
  }

  @override
  Future<List<(PodcastMetadata, PodcastStats)>> subscriptions() async {
    final db = await _db;
    final statsFinder = Finder(filter: Filter.notNull('subscribedDate'));
    final snapshots = await _podcastStatsStore.find(db, finder: statsFinder);

    final podcastFinder = Finder(
      filter: Filter.or(snapshots.map((ss) => Filter.byKey(ss.key)).toList()),
      sortOrders: [SortOrder('title')],
    );

    final podcastSnapshots =
        await _podcastStore.find(db, finder: podcastFinder);

    return podcastSnapshots.map(
      (snapshot) {
        final stats = PodcastStats.fromJson(
          snapshots
              .firstWhere(
                (ss) => ss.key == snapshot.key,
              )
              .value,
        );
        final metadata = PodcastMetadata.fromJson(snapshot.value);
        return (metadata, stats);
      },
    ).toList();
  }

  // -- PodcastStats

  @override
  Future<void> subscribePodcast(Podcast podcast) async {
    final db = await _db;
    final newStats = await db.transaction((txn) async {
      final value = await _podcastStatsStore.record(podcast.guid).get(txn);
      final saved = value == null ? null : PodcastStats.fromJson(value);
      if (saved?.subscribed == true) {
        log.warning('subscribePodcast: already subscribed: ${podcast.guid}');
        return null;
      }

      log.fine('subscribePodcast: ${podcast.guid}');
      final newStats = saved != null
          ? saved.copyWith(subscribedDate: DateTime.now())
          : PodcastStats(
              guid: podcast.guid,
              subscribedDate: DateTime.now(),
            );

      await Future.wait([
        _podcastStatsStore.record(newStats.guid).put(txn, newStats.toJson()),
        _podcastStore.record(newStats.guid).put(txn, podcast.toJson()),
        _saveEpisodes(podcast.episodes, db: txn),
      ]);
      return newStats;
    });

    if (newStats != null) {
      _podcastEventStream
        ..add(PodcastStatsUpdatedEvent(newStats))
        ..add(PodcastSubscribedEvent(podcast, newStats));
    }
  }

  @override
  Future<void> unsubscribePodcast(Podcast podcast) async {
    final guid = podcast.guid;
    final stats = await findPodcastStats(guid);
    if (stats?.subscribed != true) {
      log.warning('unsubscribePodcast: already unsubscribed: $guid');
      return;
    }

    final newStats = stats!.copyWith(subscribedDate: null);
    await _podcastStatsStore.record(guid).put(await _db, newStats.toJson());
    log.warning('unsubscribed: $guid');
    _podcastEventStream.add(PodcastUnsubscribedEvent(podcast, newStats));
  }

  @override
  Future<void> savePodcastStats(PodcastStats stats) async {
    log.fine('Update PodcastStats: ${stats.guid}');
    await _podcastStatsStore.record(stats.guid).put(await _db, stats.toJson());
    _podcastEventStream.add(PodcastStatsUpdatedEvent(stats));
  }

  @override
  Future<PodcastStats?> findPodcastStats(String guid) async {
    final value = await _podcastStatsStore.record(guid).get(await _db);
    return value == null ? null : PodcastStats.fromJson(value);
  }

  @override
  Future<PodcastStats> updatePodcastStats(PodcastStatsUpdateParam param) async {
    final db = await _db;
    final stats =
        await db.transaction((txn) => _updatePodcastStats(txn, param));
    _podcastEventStream.add(PodcastStatsUpdatedEvent(stats));
    return stats;
  }

  Future<PodcastStats> _updatePodcastStats(
    DatabaseClient txn,
    PodcastStatsUpdateParam param,
  ) async {
    final value = await _podcastStatsStore.record(param.guid).get(txn);
    final loaded = value == null ? null : PodcastStats.fromJson(value);
    final newStats = loaded?.copyWith(
          viewMode: param.viewMode ?? loaded.viewMode,
          ascend: param.ascend ?? loaded.ascend,
          ascendSeasonEpisodes:
              param.ascendSeasonEpisodes ?? loaded.ascendSeasonEpisodes,
          lastCheckedAt: param.lastCheckedAt ?? loaded.lastCheckedAt,
        ) ??
        PodcastStats(
          guid: param.guid,
          viewMode: param.viewMode ?? PodcastDetailViewMode.episodes,
          ascend: param.ascend ?? false,
          ascendSeasonEpisodes: param.ascendSeasonEpisodes ?? true,
          lastCheckedAt: param.lastCheckedAt,
        );
    await _podcastStatsStore.record(param.guid).put(txn, newStats.toJson());
    return newStats;
  }

  // --- Episodes

  @override
  Future<void> saveEpisodes(Iterable<Episode> episodes) async {
    await _saveEpisodes(episodes);
  }

  @override
  Future<void> saveEpisode(Episode episode) async {
    await _saveEpisode(episode);
  }

  Future<void> _saveEpisodes(
    Iterable<Episode> episodes, {
    DatabaseClient? db,
  }) async {
    final client = db ?? await _db;
    for (final chunk in episodes.chunk(100)) {
      final futures = chunk.map((e) => _saveEpisode(e, db: client));
      await Future.wait(futures);
    }
  }

  Future<void> _saveEpisode(
    Episode episode, {
    DatabaseClient? db,
  }) async {
    final client = db ?? await _db;
    final guid = episode.guid;
    final [episodeValue, statsValue] = await Future.wait([
      _episodeStore.record(guid).get(client),
      _episodeStatsStore.record(guid).get(client),
    ]);

    if (statsValue != null) {
      final loaded = EpisodeStats.fromJson(statsValue);
      if (loaded.duration == null && episode.duration != null) {
        final newStats = loaded.copyWith(duration: episode.duration);
        await _episodeStatsStore.record(guid).put(client, newStats.toJson());
        _episodeEventStream.add(EpisodeStatsUpdatedEvent(newStats));
      }
    }

    if (episodeValue != null && Episode.fromJson(episodeValue) == episode) {
      return;
    }
    await _episodeStore.record(guid).put(client, episode.toJson());
    _episodeEventStream.add(EpisodeUpdatedEvent(episode));
  }

  Future<void> _deleteEpisodes(List<Episode> episodes) async {
    final d = await _db;
    for (final chunk in episodes.chunk(30)) {
      await d.transaction((txn) async {
        final futures = chunk.map((e) => _deleteEpisode(e, db: txn));
        await Future.wait(futures);
      });
    }
  }

  Future<void> _deleteEpisode(
    Episode episode, {
    DatabaseClient? db,
  }) async {
    final client = db ?? await _db;
    final guidFinder = Finder(filter: Filter.equals('guid', episode.guid));
    await _episodeStore.delete(client, finder: guidFinder);
    await _downloadableStore.delete(client, finder: guidFinder);
    await _transcriptStore.delete(client, finder: guidFinder);
    _episodeEventStream.add(EpisodeDeletedEvent(episode));
  }

  @override
  Future<Episode?> findEpisode(String guid) async {
    final value = await _episodeStore.record(guid).get(await _db);
    return value == null ? null : Episode.fromJson(value);
  }

  @override
  Future<List<Episode?>> findEpisodes(Iterable<String> guids) async {
    final values = await _episodeStore.records(guids).get(await _db);
    return values
        .map((value) => value == null ? null : Episode.fromJson(value))
        .toList();
  }

  @override
  Future<List<Episode>> findEpisodesByPodcastGuid(String? pguid) async {
    final finder = Finder(
      filter: Filter.equals('pguid', pguid),
      sortOrders: [SortOrder('publicationDate', false)],
    );
    final recordSnapshots = await _episodeStore.find(await _db, finder: finder);
    return recordSnapshots.map(_loadEpisodeSnapshot).toList();
  }

  Episode _loadEpisodeSnapshot(
    RecordSnapshot<String, Map<String, Object?>> snapshot,
  ) {
    return Episode.fromJson(snapshot.value);
  }

  // --- EpisodeStats

  @override
  Future<EpisodeStats> updateEpisodeStats(EpisodeStatsUpdateParam param) async {
    // log.fine('Update EpisodeStats: ${param.guid}');

    final db = await _db;
    final stats = await db.transaction((txn) async {
      final EpisodeStats? stats;

      final value = await _episodeStatsStore.record(param.guid).get(txn);
      if (value != null) {
        stats = EpisodeStats.fromJson(value);
      } else {
        final value = await _episodeStore.record(param.guid).get(txn);
        stats = value != null
            ? EpisodeStats.fromEpisode(Episode.fromJson(value))
            : EpisodeStats(guid: param.guid);
      }

      final newStats = stats.copyWith(
        position: param.position ?? stats.position,
        duration: param.duration ?? stats.duration,
        playCount: param.playCount ?? stats.playCount,
        playTotal: stats.playTotal + (param.playTotalDelta ?? Duration.zero),
        completeCount: stats.completeCount + (param.completeCountDelta ?? 0),
        inQueue: param.inQueue ?? stats.inQueue,
        downloaded: param.downloaded ?? stats.downloaded,
        lastPlayedAt: param.lastPlayedAt ?? stats.lastPlayedAt,
      );

      if (newStats != stats) {
        await _episodeStatsStore.record(stats.guid).put(txn, newStats.toJson());
      }
      return newStats;
    });

    _episodeEventStream.add(EpisodeStatsUpdatedEvent(stats));
    return stats;
  }

  @override
  Future<List<EpisodeStats>> updateEpisodeStatsList(
    Iterable<EpisodeStatsUpdateParam> params,
  ) async {
    if (params.isEmpty) {
      return [];
    }

    final db = await _db;
    final statsList = await db.transaction((txn) async {
      final values = await _episodeStatsStore
          .records(params.map((param) => param.guid))
          .get(txn);

      final paramList = params.toList();
      final futures = List.generate(params.length, (i) async {
        final param = paramList[i];
        final value = values[i];

        final EpisodeStats? stats;
        if (value != null) {
          stats = EpisodeStats.fromJson(value);
        } else {
          final value = await _episodeStore.record(param.guid).get(txn);
          stats = value != null
              ? EpisodeStats.fromEpisode(Episode.fromJson(value))
              : EpisodeStats(
                  guid: param.guid,
                  position: param.position ?? Duration.zero,
                  duration: param.duration ?? Duration.zero,
                  playCount: param.playCount ?? 0,
                  playTotal: param.playTotalDelta ?? Duration.zero,
                  completeCount: param.completeCountDelta ?? 0,
                  inQueue: param.inQueue ?? false,
                  downloaded: param.downloaded ?? false,
                );
        }

        final newStats = stats.copyWith(
          position: param.position ?? stats.position,
          duration: param.duration ?? stats.duration,
          playCount: param.playCount ?? stats.playCount,
          playTotal: param.playTotalDelta ?? stats.playTotal,
          completeCount: param.completeCountDelta ?? 0,
          inQueue: param.inQueue ?? stats.inQueue,
          downloaded: param.downloaded ?? stats.downloaded,
        );

        if (newStats != stats) {
          await _episodeStatsStore
              .record(stats.guid)
              .put(txn, newStats.toJson());
        }
        return newStats;
      });
      return Future.wait(futures);
    });

    for (final stats in statsList) {
      _episodeEventStream.add(EpisodeStatsUpdatedEvent(stats));
    }
    return statsList;
  }

  @override
  Future<EpisodeStats?> findEpisodeStats(String guid) async {
    final value = await _episodeStatsStore.record(guid).get(await _db);
    return value == null ? null : EpisodeStats.fromJson(value);
  }

  @override
  Future<List<EpisodeStats?>> findEpisodeStatsList(
    Iterable<String> guids,
  ) async {
    final values = await _episodeStatsStore.records(guids).get(await _db);
    return values
        .map((value) => value == null ? null : EpisodeStats.fromJson(value))
        .toList();
  }

  // --- Downloads

  @override
  Future<void> saveDownload(Downloadable download) async {
    final client = await _db;
    await _downloadableStore
        .record(download.guid)
        .put(client, download.toJson());
    _downloadEventStream.add(DownloadUpdatedEvent(download));
  }

  @override
  Future<void> deleteDownload(Downloadable download) async {
    final client = await _db;
    await _downloadableStore.record(download.guid).delete(client);
    _downloadEventStream.add(DownloadDeletedEvent(download));
  }

  @override
  Future<List<Downloadable>> findDownloadsByPodcastGuid(String pguid) async {
    final finder = Finder(
      filter: Filter.equals('pguid', pguid),
      sortOrders: [SortOrder('publicationDate', false)],
    );
    final snapshots = await _downloadableStore.find(await _db, finder: finder);
    return snapshots.map(
      (snapshot) {
        return Downloadable.fromJson(snapshot.value);
      },
    ).toList();
  }

  @override
  Future<List<Downloadable>> findAllDownloads() async {
    final finder = Finder(
      sortOrders: [SortOrder('publicationDate', false)],
    );
    final snapshots = await _downloadableStore.find(await _db, finder: finder);
    return snapshots.map(
      (snapshot) {
        return Downloadable.fromJson(snapshot.value);
      },
    ).toList();
  }

  @override
  Future<List<Downloadable>> findDownloads(Iterable<String> guids) async {
    final values = await _downloadableStore.records(guids).get(await _db);
    return values.whereNotNull().map(Downloadable.fromJson).toList();
  }

  @override
  Future<Downloadable?> findDownload(String guid) async {
    final value = await _downloadableStore.record(guid).get(await _db);
    return value == null ? null : Downloadable.fromJson(value);
  }

  @override
  Future<Downloadable?> findDownloadByTaskId(String taskId) async {
    final finder = Finder(filter: Filter.equals('taskId', taskId));
    final snapshot =
        await _downloadableStore.findFirst(await _db, finder: finder);

    return snapshot == null ? null : Downloadable.fromJson(snapshot.value);
  }

  // --- Transcript

  @override
  Future<Transcript> saveTranscript(Transcript transcript) async {
    final finder = Finder(filter: Filter.byKey(transcript.id));
    final snapshot =
        await _transcriptStore.findFirst(await _db, finder: finder);

    if (snapshot == null) {
      final id = await _transcriptStore.add(await _db, transcript.toJson());
      return transcript.copyWith(id: id);
    } else {
      await _transcriptStore.update(
        await _db,
        transcript.toJson(),
        finder: finder,
      );
      return transcript;
    }
  }

  @override
  Future<void> deleteTranscriptById(int id) async {
    final finder = Finder(filter: Filter.byKey(id));
    final snapshot =
        await _transcriptStore.findFirst(await _db, finder: finder);
    if (snapshot != null) {
      await _transcriptStore.delete(await _db, finder: finder);
    }
  }

  @override
  Future<void> deleteTranscriptsById(List<int> id) async {
    final d = await _db;

    for (final chunk in id.chunk(100)) {
      await d.transaction((txn) async {
        final finder = Finder(
          filter: Filter.or(chunk.map(Filter.byKey).toList()),
        );
        await _transcriptStore.delete(txn, finder: finder);
      });
    }
  }

  @override
  Future<Transcript?> findTranscriptById(int? id) async {
    final finder = Finder(filter: Filter.byKey(id));
    final snapshot =
        await _transcriptStore.findFirst(await _db, finder: finder);
    return snapshot == null
        ? null
        : Transcript.fromJson(snapshot.value).copyWith(id: snapshot.key);
  }

  @override
  Future<Queue> loadQueue() async {
    final value = await _queueStore.record(1).get(await _db);
    return value == null ? const Queue() : Queue.fromJson(value);
  }

  @override
  Future<void> saveQueue(Queue queue) async {
    await _queueStore.record(1).put(await _db, queue.toJson());
  }

  // --- Player

  @override
  Future<void> savePlayingEpisodeGuid(String guid) async {
    await _playerStore.record(1).put(await _db, {'guid': guid});
  }

  @override
  Future<void> clearPlayingEpisodeGuid() async {
    await _playerStore.record(1).delete(await _db);
  }

  @override
  Future<String?> playingEpisodeGuid() async {
    final value = await _playerStore.record(1).get(await _db);
    return value?['guid'] as String?;
  }

  Future<void> _cleanupEpisodes() async {
    final threshold = DateTime.now()
        .subtract(const Duration(days: 60))
        .millisecondsSinceEpoch;

    /// Find all streamed episodes over the threshold.
    final filter = Filter.and([
      Filter.equals('downloadState', 0),
      Filter.lessThan('lastUpdated', threshold),
    ]);

    final orphaned = <Episode>[];
    final pguids = <String?>[];
    final episodes =
        await _episodeStore.find(await _db, finder: Finder(filter: filter));

    // First, find all podcasts
    for (final podcast in await _podcastStore.find(await _db)) {
      pguids.add(podcast.value['guid'] as String?);
    }

    for (final episode in episodes) {
      final pguid = episode.value['pguid'] as String?;
      final podcast = pguids.contains(pguid);

      if (!podcast) {
        orphaned.add(Episode.fromJson(episode.value));
      }
    }

    await _deleteEpisodes(orphaned);
  }

  @override
  Future<void> close() async {
    final d = await _db;
    await d.close();
  }
}
