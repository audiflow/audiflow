// Copyright 2024 HANAI Tohru, Reedom, INC.
// Copyright 2020 Ben Hills and the project contributors.
// All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:seasoning/core/extensions.dart';
import 'package:seasoning/entities/downloadable.dart';
import 'package:seasoning/entities/episode.dart';
import 'package:seasoning/entities/podcast.dart';
import 'package:seasoning/entities/queue.dart';
import 'package:seasoning/entities/transcript.dart';
import 'package:seasoning/repository/download_event.dart';
import 'package:seasoning/repository/episode_event.dart';
import 'package:seasoning/repository/podcast_event.dart';
import 'package:seasoning/repository/repository.dart';
import 'package:seasoning/repository/sembast/sembast_database_service.dart';
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

  final _podcastStore = intMapStoreFactory.store('podcast');
  final _podcastStatsStore = intMapStoreFactory.store('podcastStats');
  final _episodeStore = intMapStoreFactory.store('episode');
  final _episodeStatsStore = intMapStoreFactory.store('episodeStats');
  final _downloadableStore = intMapStoreFactory.store('downloadable');
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

  // --- Podcast

  @override
  Future<void> savePodcast(int id, Podcast podcast) async {
    log.fine('Update Podcast: ${podcast.feedUrl}');
    await _podcastStore.record(id).put(await _db, podcast.toJson());
    _podcastEventStream.add(PodcastUpdatedEvent(id, podcast));
  }

  @override
  Future<Podcast?> findPodcastById(int id) async {
    final value = await _podcastStore.record(id).get(await _db);
    if (value == null) {
      return null;
    }

    final podcast = Podcast.fromJson(value);
    final episodes = await findEpisodesByPodcastGuid(podcast.guid);
    return podcast.copyWith(episodes: episodes);
  }

  @override
  Future<Podcast?> findPodcastByGuid(String guid) async {
    final finder = Finder(filter: Filter.equals('guid', guid));
    final snapshot = await _podcastStore.findFirst(await _db, finder: finder);
    if (snapshot == null) {
      return null;
    }

    final podcast = Podcast.fromJson(snapshot.value);
    final episodes = await findEpisodesByPodcastGuid(podcast.guid);
    return podcast.copyWith(episodes: episodes);
  }

  @override
  Future<List<(PodcastStats, PodcastSummary)>> subscriptions() async {
    final statsFinder = Finder(filter: Filter.notNull('subscribedDate'));
    final snapshots = await _podcastStatsStore.find(
      await _db,
      finder: statsFinder,
    );

    final podcastFinder = Finder(
      filter: Filter.or(snapshots.map((ss) => Filter.byKey(ss.key)).toList()),
      sortOrders: [SortOrder('title')],
    );

    final podcastSnapshots = await _podcastStore.find(
      await _db,
      finder: podcastFinder,
    );

    return podcastSnapshots.map(
      (snapshot) {
        final stats = PodcastStats.fromJson(
          snapshots
              .firstWhere(
                (ss) => ss.key == snapshot.key,
              )
              .value,
        ).copyWith(id: snapshot.key);
        final summary = PodcastSearchResultItem.fromJson(snapshot.value);
        return (stats, summary);
      },
    ).toList();
  }

  // -- PodcastStats

  @override
  Future<PodcastStats> subscribePodcast(Podcast podcast) async {
    final saved = await findPodcastStatsByGuid(podcast.guid);
    if (saved != null) {
      if (saved.subscribed) {
        log.warning('subscribePodcast: already subscribed: ${podcast.guid}');
        return saved;
      }
    }

    log.fine('subscribePodcast: ${podcast.guid}');

    final db = await _db;
    final stats = await db.transaction((txn) async {
      PodcastStats stats;

      if (saved != null) {
        stats = saved.copyWith(subscribedDate: DateTime.now());
        await _podcastStatsStore.record(saved.id).put(txn, stats.toJson());
      } else {
        stats = PodcastStats(
          guid: podcast.guid,
          subscribedDate: DateTime.now(),
        );
        final id = await _podcastStatsStore.add(txn, stats.toJson());
        stats = stats.copyWith(id: id);
      }

      await Future.wait([
        _podcastStore.record(stats.id).put(txn, podcast.toJson()),
        _saveEpisodes(podcast.episodes, db: txn),
      ]);
      return stats;
    });

    _podcastEventStream
      ..add(PodcastStatsUpdatedEvent(stats))
      ..add(PodcastSubscribedEvent(podcast, stats));
    return stats;
  }

  @override
  Future<void> unsubscribePodcast(Podcast podcast) async {
    final db = await _db;

    final results = await Future.wait([
      findPodcastStatsByGuid(podcast.guid),
      findDownloadsByPodcastGuid(podcast.guid),
    ]);

    final stats = results[0] as PodcastStats?;
    final downloads = results[1]! as List<Downloadable>;
    if (stats?.subscribed != true) {
      log.warning('unsubscribePodcast: already unsubscribed: ${podcast.guid}');
      return;
    }

    // TODO(reedom): Let sweeper manages these entities.

    final newStats = stats!.copyWith(subscribedDate: null);
    if (downloads.isEmpty) {
      await db.transaction((txn) async {
        final finder = Finder(filter: Filter.equals('pguid', stats.guid));
        await _podcastStatsStore.record(stats.id).put(txn, newStats.toJson());
        await _podcastStore.record(stats.id).delete(txn);
        await _episodeStore.delete(txn, finder: finder);
        await _downloadableStore.delete(txn, finder: finder);
        await _transcriptStore.delete(txn, finder: finder);
      });
    } else {
      final episodes = podcast.episodes
          .where((e) => downloads.any((d) => d.guid == e.guid))
          .toList();
      await _deleteEpisodes(episodes);
      await _podcastStatsStore.record(stats.id).put(db, newStats.toJson());
    }

    log.warning('unsubscribed: ${stats.guid}');
    _podcastEventStream.add(PodcastUnsubscribedEvent(podcast, newStats));
  }

  @override
  Future<void> savePodcastStats(PodcastStats stats) async {
    log.fine('Update PodcastStats: ${stats.guid}');

    if (stats.id == 0) {
      throw ArgumentError('PodcastStats.id must not be 0');
    }

    await _podcastStatsStore.record(stats.id).put(await _db, stats.toJson());
    _podcastEventStream.add(PodcastStatsUpdatedEvent(stats));
  }

  @override
  Future<PodcastStats?> findPodcastStatsById(int id) async {
    final value = await _podcastStatsStore.record(id).get(await _db);
    return value == null ? null : PodcastStats.fromJson(value).copyWith(id: id);
  }

  @override
  Future<PodcastStats?> findPodcastStatsByGuid(String guid) async {
    final finder = Finder(filter: Filter.equals('guid', guid));
    final snapshot =
        await _podcastStatsStore.findFirst(await _db, finder: finder);
    return snapshot == null
        ? null
        : PodcastStats.fromJson(snapshot.value).copyWith(id: snapshot.key);
  }

  // --- Episodes

  @override
  Future<void> saveEpisodes(List<Episode> episodes) async {
    final db = await _db;
    await db.transaction((txn) async => _saveEpisodes(episodes, db: txn));
  }

  @override
  Future<void> saveEpisode(Episode episode) async {
    await _saveEpisode(episode);
  }

  @override
  Future<void> deleteEpisodes(List<Episode> episodes) async {
    return _deleteEpisodes(episodes);
  }

  @override
  Future<void> deleteEpisode(Episode episode) async {
    return _deleteEpisode(episode);
  }

  Future<void> _saveEpisodes(
    List<Episode> episodes, {
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
    final finder = Finder(filter: Filter.equals('guid', episode.guid));

    final client = db ?? await _db;
    final snapshots = await Future.wait([
      _episodeStore.findFirst(client, finder: finder),
      _episodeStatsStore.findFirst(client, finder: finder),
    ]);
    final snapshot = snapshots[0];
    final statsSnapshot = snapshots[1];

    if (snapshot != null) {
      final e = _loadEpisodeSnapshot(snapshot);
      if (episode != e) {
        await _episodeStore.update(client, episode.toJson(), finder: finder);
        _episodeEventStream.add(EpisodeUpdatedEvent(episode));
      }
    } else if (statsSnapshot != null) {
      final id = statsSnapshot.key;
      await _episodeStore.record(id).put(client, episode.toJson());
    } else {
      await _episodeStore.add(client, episode.toJson());
      _episodeEventStream.add(EpisodeInsertedEvent(episode));
    }
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
  Future<Episode?> findEpisodeById(int id) async {
    final value = await _episodeStore.record(id).get(await _db);
    return value == null ? null : Episode.fromJson(value);
  }

  @override
  Future<Episode?> findEpisodeByGuid(String guid) async {
    final finder = Finder(filter: Filter.equals('guid', guid));
    final snapshot = await _episodeStore.findFirst(await _db, finder: finder);
    if (snapshot == null) {
      return null;
    }
    return _loadEpisodeSnapshot(snapshot);
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
    RecordSnapshot<int, Map<String, Object?>> snapshot,
  ) {
    return Episode.fromJson(snapshot.value);
  }

  // --- EpisodeStats

  @override
  Future<EpisodeStats> updateEpisodeStats(EpisodeStatsUpdateParam param) async {
    log.fine('Update EpisodeStats: ${param.guid} $param');

    final db = await _db;
    final stats = await db.transaction((txn) async {
      final EpisodeStats? loaded;
      var creating = true;

      if (param.id != null && 0 < param.id!) {
        final value = await _episodeStatsStore.record(param.id!).get(txn);
        loaded = value == null
            ? null
            : EpisodeStats.fromJson(value).copyWith(id: param.id!);
        creating = false;
      } else {
        final finder = Finder(filter: Filter.equals('guid', param.guid));
        final snapshot =
            await _episodeStatsStore.findFirst(await _db, finder: finder);
        if (snapshot != null) {
          loaded =
              EpisodeStats.fromJson(snapshot.value).copyWith(id: snapshot.key);
        } else {
          final snapshot = await _episodeStore.findFirst(txn, finder: finder);
          loaded = snapshot == null
              ? null
              : EpisodeStats.fromEpisode(Episode.fromJson(snapshot.value))
                  .copyWith(id: snapshot.key);
        }
      }

      if (loaded == null) {
        final stats = EpisodeStats(
          guid: param.guid,
          position: param.position ?? Duration.zero,
          duration: param.duration ?? Duration.zero,
          played: param.completed ?? false,
          playCount: param.playCount ?? 0,
          playTotal: param.playTotal ?? Duration.zero,
          inQueue: param.inQueue ?? false,
          downloaded: param.downloaded ?? false,
        );
        final id = await _episodeStatsStore.add(txn, stats.toJson());
        return stats.copyWith(id: id);
      } else {
        final stats = loaded.copyWith(
          position: param.position ?? loaded.position,
          duration: param.duration ?? loaded.duration,
          played: param.completed ?? loaded.played,
          playCount: param.playCount ?? loaded.playCount,
          playTotal: param.playTotal ?? loaded.playTotal,
          inQueue: param.inQueue ?? loaded.inQueue,
          downloaded: param.downloaded ?? loaded.downloaded,
        );
        if (creating || stats != loaded) {
          await _episodeStatsStore.record(stats.id).put(txn, stats.toJson());
        }
        return stats;
      }
    });

    _episodeEventStream.add(EpisodeStatsUpdatedEvent(stats));
    return stats;
  }

  @override
  Future<EpisodeStats?> findEpisodeStatsById(int id) async {
    final value = await _episodeStatsStore.record(id).get(await _db);
    return value == null ? null : EpisodeStats.fromJson(value).copyWith(id: id);
  }

  @override
  Future<EpisodeStats?> findEpisodeStatsByGuid(String guid) async {
    final finder = Finder(filter: Filter.equals('guid', guid));
    final snapshot =
        await _episodeStatsStore.findFirst(await _db, finder: finder);
    return snapshot == null
        ? null
        : EpisodeStats.fromJson(snapshot.value).copyWith(id: snapshot.key);
  }

  // --- Downloads

  @override
  Future<Downloadable> saveDownload(Downloadable download) async {
    final finder = Finder(filter: Filter.equals('guid', download.guid));

    final client = await _db;
    final snapshot = await _downloadableStore.findFirst(client, finder: finder);
    if (snapshot == null) {
      final id = await _downloadableStore.add(client, download.toJson());
      final newDownload = download.copyWith(id: id);
      _downloadEventStream.add(DownloadUpdatedEvent(newDownload));
      return newDownload;
    } else {
      await _downloadableStore.update(
        client,
        download.toJson(),
        finder: finder,
      );
      _downloadEventStream.add(DownloadUpdatedEvent(download));
      return download;
    }
  }

  @override
  Future<void> deleteDownload(Downloadable download) async {
    final finder = Finder(filter: Filter.byKey(download.id));
    await _downloadableStore.delete(await _db, finder: finder);
    _downloadEventStream.add(DownloadDeletedEvent(download));
  }

  @override
  Future<List<Downloadable>> findDownloadsByPodcastGuid(String pguid) async {
    final finder = Finder(
      filter: Filter.and([
        Filter.equals('pguid', pguid),
      ]),
      sortOrders: [SortOrder('publicationDate', false)],
    );
    final recordSnapshots =
        await _downloadableStore.find(await _db, finder: finder);
    return recordSnapshots.map(
      (snapshot) {
        return Downloadable.fromJson(snapshot.value).copyWith(id: snapshot.key);
      },
    ).toList();
  }

  @override
  Future<List<Downloadable>> findDownloads() async {
    final finder = Finder(
      sortOrders: [SortOrder('publicationDate', false)],
    );
    final recordSnapshots =
        await _downloadableStore.find(await _db, finder: finder);
    return recordSnapshots.map(
      (snapshot) {
        return Downloadable.fromJson(snapshot.value).copyWith(id: snapshot.key);
      },
    ).toList();
  }

  @override
  Future<Downloadable?> findDownloadByGuid(String guid) async {
    final finder = Finder(filter: Filter.equals('guid', guid));
    final snapshot =
        await _downloadableStore.findFirst(await _db, finder: finder);

    return snapshot == null
        ? null
        : Downloadable.fromJson(snapshot.value).copyWith(id: snapshot.key);
  }

  @override
  Future<Downloadable?> findDownloadByTaskId(String taskId) async {
    final finder = Finder(filter: Filter.equals('taskId', taskId));
    final snapshot =
        await _downloadableStore.findFirst(await _db, finder: finder);

    return snapshot == null
        ? null
        : Downloadable.fromJson(snapshot.value).copyWith(id: snapshot.key);
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
