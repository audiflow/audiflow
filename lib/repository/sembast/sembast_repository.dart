// Copyright (c) 2024 by HANAI, Tohru.
// Copyright (c) 2024 Reedom, Inc.
// Additional contributions from project contributors.
// Originally (c) 2020 Ben Hills and the project contributors.
// All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:math' as math;

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

class SembastRepository extends Repository {
  SembastRepository(
    this._ref, {
    bool cleanup = true,
    String databaseName = 'audiflow.db',
  }) {
    _databaseService = DatabaseService(databaseName, version: 1);

    if (cleanup) {
      _cleanupEpisodes();
    }
  }

  final Ref _ref;
  final log = Logger('SembastRepository');

  final _chartsStore = intMapStoreFactory.store('charts');
  final _podcastStore = stringMapStoreFactory.store('podcast');
  final _podcastStatsStore = stringMapStoreFactory.store('podcastStats');
  final _podcastViewStatsStore =
      stringMapStoreFactory.store('podcastViewStats');
  final _episodeStore = stringMapStoreFactory.store('episode');
  final _episodeStatsStore = stringMapStoreFactory.store('episodeStats');
  final _recentlyPlayedStore = intMapStoreFactory.store('recentlyPlayed');
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
  Future<void> savePodcastMetadataList(Iterable<PodcastMetadata> list) =>
      savePodcasts(list.map(Podcast.fromMetadata));

  @override
  Future<void> savePodcastMetadata(PodcastMetadata metadata) =>
      savePodcast(metadata.toPartialPodcast());

  @override
  Future<PodcastMetadata?> findPodcastMetadata(String guid) async {
    final value = await _podcastStore.record(guid).get(await _db);
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

    final values = await _podcastStore.records(guids).get(await _db);
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
    final value = await _podcastStore.record(guid).get(await _db);
    return value?['feedUrl'] as String?;
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

  // --- Podcast

  @override
  Future<void> savePodcasts(Iterable<Podcast> podcasts) async {
    final db = await _db;
    final updates = await db.transaction((txn) async {
      return Future.wait(
        podcasts.map((podcast) => _savePodcast(podcast, txn)),
      );
    });
    for (final (i, updated) in updates.indexed) {
      if (updated) {
        _podcastEventStream.add(PodcastUpdatedEvent(podcasts.elementAt(i)));
      }
    }
  }

  @override
  Future<void> savePodcast(
    Podcast podcast, {
    PodcastStatsUpdateParam? statsParam,
  }) async {
    log.fine('Save Podcast: ${podcast.feedUrl}');
    final db = await _db;
    final (updated, stats) = await db.transaction((txn) async {
      final updated = await _savePodcast(podcast, txn);
      final stats = statsParam == null
          ? null
          : await _updatePodcastStats(statsParam, txn);
      return (updated, stats);
    });
    if (updated || stats != null) {
      _podcastEventStream.add(PodcastUpdatedEvent(podcast, stats: stats));
    }
  }

  Future<bool> _savePodcast(Podcast podcast, DatabaseClient txn) async {
    final record = _podcastStore.record(podcast.guid);
    final value = await record.get(txn);
    if (value == null ||
        (!podcast.metadataOnly && value['metadataOnly'] == true) ||
        (podcast.metadataOnly == value['metadataOnly'] &&
            value['hash'] != podcast.hashCode)) {
      final newValue = podcast.toJson();
      newValue['hash'] = podcast.hashCode;
      await record.put(txn, newValue);
      return true;
    }
    return false;
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

  // -- PodcastStats

  @override
  Future<void> subscribePodcast(Podcast podcast) async {
    final db = await _db;
    final newStats = await db.transaction((txn) async {
      final value = await _podcastStatsStore.record(podcast.guid).get(txn);
      final subscribed = value != null && value['subscribedDate'] != null;
      if (subscribed) {
        log.warning('subscribePodcast: '
            'already subscribed: ${podcast.guid} ${podcast.title}');
        return null;
      }

      log.fine('subscribe podcast: ${podcast.guid} ${podcast.title}');
      final updateParam = PodcastStatsUpdateParam(
        guid: podcast.guid,
        subscribed: true,
      );

      final ret = await Future.wait<dynamic>([
        _savePodcast(podcast, txn),
        _updatePodcastStats(updateParam, txn),
        _saveEpisodes(podcast.episodes, txn),
      ]);
      return ret[1] as PodcastStats;
    });

    if (newStats != null) {
      _podcastEventStream
        ..add(PodcastStatsUpdatedEvent(newStats))
        ..add(PodcastSubscribedEvent(podcast, newStats));
    }
  }

  @override
  Future<void> unsubscribePodcast(Podcast podcast) async {
    final db = await _db;
    final newStats = await db.transaction((txn) async {
      final value = await _podcastStatsStore.record(podcast.guid).get(txn);
      final subscribed = value != null && value['subscribedDate'] != null;
      if (!subscribed) {
        log.warning('unsubscribePodcast: '
            'already unsubscribed: ${podcast.guid} ${podcast.title}');
        return null;
      }

      log.fine('unsubscribe podcast: ${podcast.guid} ${podcast.title}');
      final updateParam = PodcastStatsUpdateParam(
        guid: podcast.guid,
        subscribed: false,
      );

      return _updatePodcastStats(updateParam, txn);
    });

    if (newStats != null) {
      _podcastEventStream
        ..add(PodcastStatsUpdatedEvent(newStats))
        ..add(PodcastUnsubscribedEvent(podcast, newStats));
    }
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
        await db.transaction((txn) => _updatePodcastStats(param, txn));
    _podcastEventStream.add(PodcastStatsUpdatedEvent(stats));
    return stats;
  }

  Future<PodcastStats> _updatePodcastStats(
    PodcastStatsUpdateParam param,
    DatabaseClient txn,
  ) async {
    final value = await _podcastStatsStore.record(param.guid).get(txn);
    final loaded = value == null ? null : PodcastStats.fromJson(value);
    final newStats = loaded?.copyWith(
          subscribedDate: param.subscribed == null
              ? loaded.subscribedDate
              : param.subscribed!
                  ? DateTime.now()
                  : null,
          lastCheckedAt: param.lastCheckedAt ?? loaded.lastCheckedAt,
        ) ??
        PodcastStats(
          guid: param.guid,
          subscribedDate: param.subscribed == null
              ? null
              : param.subscribed!
                  ? DateTime.now()
                  : null,
          lastCheckedAt: param.lastCheckedAt,
        );
    await _podcastStatsStore.record(param.guid).put(txn, newStats.toJson());
    return newStats;
  }

  // -- PodcastViewStats

  @override
  Future<PodcastViewStats?> findPodcastViewStats(String guid) async {
    final value = await _podcastViewStatsStore.record(guid).get(await _db);
    return value == null ? null : PodcastViewStats.fromJson(value);
  }

  @override
  Future<PodcastViewStats> updatePodcastViewStats(
    PodcastViewStatsUpdateParam param,
  ) async {
    final db = await _db;
    final newViewStats = await db.transaction((txn) async {
      final value = await _podcastViewStatsStore.record(param.guid).get(txn);
      final loaded = value == null ? null : PodcastViewStats.fromJson(value);
      final newViewStats = loaded?.copyWith(
            viewMode: param.viewMode ?? loaded.viewMode,
            ascend: param.ascend ?? loaded.ascend,
            ascendSeasonEpisodes:
                param.ascendSeasonEpisodes ?? loaded.ascendSeasonEpisodes,
            listenedEpisodes: param.listenedEpisodes ?? loaded.listenedEpisodes,
          ) ??
          PodcastViewStats(
            guid: param.guid,
            viewMode: param.viewMode ?? PodcastDetailViewMode.episodes,
            ascend: param.ascend ?? false,
            ascendSeasonEpisodes: param.ascendSeasonEpisodes ?? true,
            listenedEpisodes: param.listenedEpisodes ?? const {},
          );
      await _podcastViewStatsStore
          .record(param.guid)
          .put(txn, newViewStats.toJson());
      return newViewStats;
    });
    _podcastEventStream.add(PodcastViewStatsUpdatedEvent(newViewStats));
    return newViewStats;
  }

  // --- Episodes

  @override
  Future<void> saveEpisodes(Iterable<Episode> episodes) async {
    await _saveEpisodes(episodes, await _db);
  }

  @override
  Future<void> saveEpisode(Episode episode) async {
    await _saveEpisode(episode, await _db);
  }

  Future<void> _saveEpisodes(
    Iterable<Episode> episodes,
    DatabaseClient txn,
  ) async {
    for (final chunk in episodes.chunk(100)) {
      final futures = chunk.map((e) => _saveEpisode(e, txn));
      await Future.wait(futures);
    }
  }

  Future<void> _saveEpisode(Episode episode, DatabaseClient txn) async {
    final guid = episode.guid;
    final value = await _episodeStore.record(guid).get(txn);
    if (value == null ||
        (!episode.metadataOnly && value['metadataOnly'] == true) ||
        (episode.metadataOnly == value['metadataOnly'] &&
            value['hash'] != episode.hashCode)) {
      final value = episode.toJson();
      value['hash'] = episode.hashCode;
      await _episodeStore.record(guid).put(txn, value);
      _episodeEventStream.add(EpisodeUpdatedEvent(episode));
    }
  }

  Future<void> _deleteEpisodes(List<Episode> episodes) async {
    final db = await _db;
    for (final chunk in episodes.chunk(30)) {
      await db.transaction((txn) async {
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
    final db = await _db;
    final stats =
        await db.transaction((txn) => _updateEpisodeStats(param, txn));
    _episodeEventStream.add(EpisodeStatsUpdatedEvent(stats));
    return stats;
  }

  Future<EpisodeStats> _updateEpisodeStats(
    EpisodeStatsUpdateParam param,
    DatabaseClient txn,
  ) async {
    final value = await _episodeStatsStore.record(param.guid).get(txn);
    final stats = value != null
        ? EpisodeStats.fromJson(value)
        : EpisodeStats(pguid: param.pguid, guid: param.guid);

    final newStats = _composeNewEpisodeStats(stats, param);
    if (newStats != stats) {
      await _episodeStatsStore.record(stats.guid).put(txn, newStats.toJson());
    }
    return newStats;
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
        final stats = value != null
            ? EpisodeStats.fromJson(value)
            : EpisodeStats(pguid: param.pguid, guid: param.guid);

        final newStats = _composeNewEpisodeStats(stats, param);
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

  EpisodeStats _composeNewEpisodeStats(
    EpisodeStats stats,
    EpisodeStatsUpdateParam param,
  ) {
    return stats.copyWith(
      position: param.position ?? stats.position,
      playCount: stats.playCount + (param.lastPlayedAt != null ? 1 : 0),
      playTotal: stats.playTotal + (param.playTotalDelta ?? Duration.zero),
      played: param.played ?? stats.played,
      completeCount: stats.completeCount + (param.completeCountDelta ?? 0),
      inQueue: param.inQueue ?? stats.inQueue,
      downloadedTime: param.downloaded == null
          ? stats.downloadedTime
          : param.downloaded!
              ? DateTime.now()
              : null,
      lastPlayedAt: param.lastPlayedAt ?? stats.lastPlayedAt,
    );
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

  @override
  Future<List<EpisodeStats>> findDownloadedEpisodeStatsList(
    String pguid,
  ) async {
    final finder = Finder(
      filter: Filter.and([
        Filter.equals('pguid', pguid),
        Filter.notNull('downloadedTime'),
      ]),
      sortOrders: [SortOrder('downloadedTime', false)],
    );
    final snapshots = await _episodeStatsStore.find(await _db, finder: finder);
    return snapshots
        .map((snapshot) => EpisodeStats.fromJson(snapshot.value))
        .toList();
  }

  @override
  Future<List<EpisodeStats>> findPlayedEpisodeStatsList(String pguid) async {
    final finder = Finder(
      filter: Filter.and([
        Filter.equals('pguid', pguid),
        Filter.equals('played', true),
      ]),
      sortOrders: [SortOrder('lastPlayedAt', false, true)],
    );
    final snapshots = await _episodeStatsStore.find(await _db, finder: finder);
    return snapshots
        .map((snapshot) => EpisodeStats.fromJson(snapshot.value))
        .toList();
  }

  @override
  Future<List<EpisodeStats>> findUnplayedEpisodeStatsList(String pguid) async {
    final finder = Finder(
      filter: Filter.and([
        Filter.equals('pguid', pguid),
        Filter.equals('played', false),
      ]),
    );
    final snapshots = await _episodeStatsStore.find(await _db, finder: finder);
    return snapshots
        .map((snapshot) => EpisodeStats.fromJson(snapshot.value))
        .toList();
  }

  // --- Recently played episodes

  @override
  Future<void> saveRecentlyPlayedEpisode(
    Episode episode, {
    DateTime? playedAt,
  }) async {
    final db = await _db;
    await db.transaction((txn) async {
      final finder = Finder(
        filter: Filter.equals('guid', episode.guid),
      );
      await _recentlyPlayedStore.delete(txn, finder: finder);

      final metadata = EpisodeMetadata.fromEpisode(episode);
      final value = Map<String, Object?>.from(metadata.toJson());
      value['playedAt'] = (playedAt ?? DateTime.now()).millisecondsSinceEpoch;
      await _recentlyPlayedStore.add(txn, value);
    });
  }

  @override
  Future<(List<Episode>, int?)> findRecentlyPlayedEpisodeList({
    int? cursor,
    int limit = 100,
  }) async {
    assert(cursor == null || 0 <= cursor);
    assert(0 < limit);

    final db = await _db;
    var key = cursor;
    if (key == null) {
      final finder = Finder(sortOrders: [SortOrder(Field.key, false)]);
      key = await _recentlyPlayedStore.findKey(db, finder: finder);
      if (key == null) {
        return (<Episode>[], null);
      }
      key++;
    }

    List<RecordSnapshot<int, Map<String, Object?>>> snapshots;
    do {
      final finder = Finder(
        sortOrders: [SortOrder(Field.key, false)],
        start: Boundary(values: [key]),
        end: Boundary(values: [math.max(0, key! - limit - 1)]),
      );

      snapshots = await _recentlyPlayedStore.find(db, finder: finder);
      key -= limit;
    } while (snapshots.isEmpty && 1 < key);

    if (snapshots.isEmpty) {
      return (<Episode>[], null);
    }

    final list = snapshots
        .map((snapshot) => EpisodeMetadata.fromJson(snapshot.value))
        .map((metadata) => metadata.toPartialEpisode())
        .toList();
    final nextCursor = snapshots.last.key;
    return (list, 1 < nextCursor ? nextCursor : null);
  }

  // --- Downloads

  @override
  Future<void> saveDownload(Downloadable download) async {
    final client = await _db;
    final newStats = await client.transaction((txn) async {
      await _downloadableStore
          .record(download.guid)
          .put(txn, download.toJson());
      if (download.state != DownloadState.downloaded) {
        return null;
      }

      // If the episode is downloaded, update the episode stats.
      // (This is a bit of a hack, but it's the easiest way to keep the
      // episode stats in sync with the download state.
      final updateParam = EpisodeStatsUpdateParam(
        pguid: download.pguid,
        guid: download.guid,
        downloaded: true,
      );
      return _updateEpisodeStats(updateParam, txn);
    });

    _downloadEventStream.add(DownloadUpdatedEvent(download));
    if (newStats != null) {
      _episodeEventStream.add(EpisodeStatsUpdatedEvent(newStats));
    }
  }

  @override
  Future<void> deleteDownload(Downloadable download) async {
    final client = await _db;
    final newStats = await client.transaction((txn) async {
      await _downloadableStore.record(download.guid).delete(txn);
      final updateParam = EpisodeStatsUpdateParam(
        pguid: download.pguid,
        guid: download.guid,
        downloaded: false,
      );
      return _updateEpisodeStats(updateParam, txn);
    });
    _downloadEventStream.add(DownloadDeletedEvent(download));
    _episodeEventStream.add(EpisodeStatsUpdatedEvent(newStats));
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
    final db = await _db;

    for (final chunk in id.chunk(100)) {
      await db.transaction((txn) async {
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
    log.fine('Start cleanup repository');
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
    log.fine('Completed cleanup repository');
  }

  @override
  Future<void> close() async {
    final db = await _db;
    await db.close();
  }
}
