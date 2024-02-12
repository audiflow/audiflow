// Copyright 2024 HANAI Tohru, Reedom, INC.
// Copyright 2020 Ben Hills and the project contributors.
// All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';
import 'package:rxdart/rxdart.dart';
import 'package:seasoning/core/extensions.dart';
import 'package:seasoning/entities/downloadable.dart';
import 'package:seasoning/entities/episode.dart';
import 'package:seasoning/entities/podcast.dart';
import 'package:seasoning/entities/queue.dart';
import 'package:seasoning/entities/transcript.dart';
import 'package:seasoning/events/episode_event.dart';
import 'package:seasoning/repository/repository.dart';
import 'package:seasoning/repository/sembast/sembast_database_service.dart';
import 'package:sembast/sembast.dart';

/// An implementation of [Repository] that is backed by
/// [Sembast](https://github.com/tekartik/sembast.dart/tree/master/sembast)
class SembastRepository extends Repository {
  SembastRepository({
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

  final log = Logger('SembastRepository');

  final _podcastSubject = BehaviorSubject<Podcast>();
  final _episodeSubject = BehaviorSubject<EpisodeEvent>();

  final _podcastStore = intMapStoreFactory.store('podcast');
  final _episodeStore = intMapStoreFactory.store('episode');
  final _downloadableStore = intMapStoreFactory.store('downloadable');
  final _queueStore = intMapStoreFactory.store('queue');
  final _transcriptStore = intMapStoreFactory.store('transcript');

  final _queueGuids = <String>[];

  late DatabaseService _databaseService;

  Future<Database> get _db async => _databaseService.database;

  /// Saves the [Podcast] instance and associated [Episode]s. Podcasts are
  /// only stored when we subscribe to them, so at the point we store a
  /// new podcast we store the current [DateTime] to mark the
  /// subscription date.
  @override
  Future<Podcast> savePodcast(Podcast podcast) async {
    log.fine('Saving podcast (${podcast.id ?? -1}) ${podcast.url}');

    final saved = podcast.id != null
        ? await findPodcastById(podcast.id!)
        : await findPodcastByGuid(podcast.guid);
    if (saved == podcast) {
      return podcast;
    }

    late Podcast newPodcast;
    if (saved != null) {
      newPodcast = podcast;
      await _podcastStore.update(
        await _db,
        podcast.toJson(),
        finder: Finder(filter: Filter.byKey(podcast.id)),
      );
    } else {
      newPodcast = podcast.copyWith(subscribedDate: DateTime.now());
      final id = await _podcastStore.add(await _db, newPodcast.toJson());
      newPodcast = newPodcast.copyWith(id: id);
    }

    _podcastSubject.add(newPodcast);
    return newPodcast;
  }

  @override
  Future<List<Podcast>> subscriptions() async {
    final finder = Finder(sortOrders: [SortOrder('title')]);
    final subscriptionSnapshot = await _podcastStore.find(
      await _db,
      finder: finder,
    );
    return subscriptionSnapshot.map(
      (snapshot) {
        return Podcast.fromJson(snapshot.value).copyWith(id: snapshot.key);
      },
    ).toList();
  }

  @override
  Future<void> deletePodcast(Podcast podcast) async {
    final db = await _db;

    await db.transaction((txn) async {
      final podcastFinder = Finder(filter: Filter.byKey(podcast.id));
      final episodeFinder =
          Finder(filter: Filter.equals('pguid', podcast.guid));
      await _podcastStore.delete(txn, finder: podcastFinder);
      await _episodeStore.delete(txn, finder: episodeFinder);
    });
  }

  @override
  Future<Podcast?> findPodcastById(num id) async {
    final finder = Finder(filter: Filter.byKey(id));
    final snapshot = await _podcastStore.findFirst(await _db, finder: finder);
    if (snapshot == null) {
      return null;
    }

    return Podcast.fromJson(snapshot.value).copyWith(id: snapshot.key);
  }

  @override
  Future<Podcast?> findPodcastByGuid(String guid) async {
    final finder = Finder(filter: Filter.equals('guid', guid));
    final snapshot = await _podcastStore.findFirst(await _db, finder: finder);
    if (snapshot == null) {
      return null;
    }

    return Podcast.fromJson(snapshot.value).copyWith(id: snapshot.key);
  }

  @override
  Future<List<Episode>> findAllEpisodes() async {
    final finder = Finder(
      sortOrders: [SortOrder('publicationDate', false)],
    );
    final recordSnapshots = await _episodeStore.find(await _db, finder: finder);
    return recordSnapshots.map(_loadEpisodeSnapshot).toList();
  }

  @override
  Future<Episode?> findEpisodeById(int? id) async {
    final finder = Finder(filter: Filter.byKey(id));
    final snapshot =
        (await _episodeStore.findFirst(await _db, finder: finder))!;
    return _loadEpisodeSnapshot(snapshot);
  }

  @override
  Future<Episode?> findEpisodeByGuid(String guid) async {
    final finder = Finder(filter: Filter.equals('guid', guid));
    final snapshot = await _episodeStore.findFirst(await _db, finder: finder);
    return snapshot == null ? null : _loadEpisodeSnapshot(snapshot);
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

  @override
  Future<void> deleteEpisode(Episode episode) async {
    final finder = Finder(filter: Filter.byKey(episode.id));
    final snapshot = await _episodeStore.findFirst(await _db, finder: finder);
    if (snapshot != null) {
      await _episodeStore.delete(await _db, finder: finder);
      _episodeSubject.add(EpisodeDeleteEvent(episode: episode));
    }
  }

  @override
  Future<void> deleteEpisodes(List<Episode> episodes) async {
    final d = await _db;
    for (final chunk in episodes.chunk(100)) {
      await d.transaction((txn) async {
        final futures = <Future<int>>[];
        for (final episode in chunk) {
          final finder = Finder(filter: Filter.byKey(episode.id));
          futures.add(_episodeStore.delete(txn, finder: finder));
        }
        await Future.wait(futures);
      });
    }
  }

  @override
  Future<Episode> saveEpisode(Episode episode) async {
    final e = await _saveEpisode(episode);
    _episodeSubject.add(EpisodeUpdateEvent(episode: e));

    return e;
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
  Future<Downloadable?> findDownloadByTaskId(String taskId) async {
    final finder = Finder(filter: Filter.equals('taskId', taskId));
    final snapshot =
        await _downloadableStore.findFirst(await _db, finder: finder);

    return snapshot == null
        ? null
        : Downloadable.fromJson(snapshot.value).copyWith(id: snapshot.key);
  }

  Episode _loadEpisodeSnapshot(
    RecordSnapshot<int, Map<String, Object?>> snapshot,
  ) {
    return Episode.fromJson(snapshot.value).copyWith(id: snapshot.key);
  }

  @override
  Future<Downloadable> saveDownload(Downloadable downloadable) async {
    final finder = Finder(
      filter: Filter.and([
        Filter.equals('guid', downloadable.guid),
      ]),
    );

    final client = await _db;
    final snapshot = await _downloadableStore.findFirst(client, finder: finder);
    if (snapshot == null) {
      final id = await _downloadableStore.add(client, downloadable.toJson());
      return downloadable.copyWith(id: id);
    } else {
      await _downloadableStore.update(
        client,
        downloadable.toJson(),
        finder: finder,
      );
      return downloadable;
    }
  }

  @override
  Future<List<Episode>> loadQueue() async {
    final snapshot = await _queueStore.record(1).getSnapshot(await _db);
    if (snapshot == null) {
      return [];
    }

    final queue = Queue.fromJson(snapshot.value);
    final episodeFinder = Finder(filter: Filter.inList('guid', queue.guids));

    final recordSnapshots =
        await _episodeStore.find(await _db, finder: episodeFinder);

    return recordSnapshots.map(_loadEpisodeSnapshot).toList();
  }

  @override
  Future<void> saveQueue(List<Episode> episodes) async {
    /// Check to see if we have any ad-hoc episodes and save them first
    final futures = <Future<Episode>>[];
    for (final e in episodes) {
      futures.add(
        e.pguid.isEmpty ? _saveEpisode(e) : Future.value(e),
      );
    }
    final updatedEpisodes = await Future.wait(futures);

    final guids = updatedEpisodes.map((e) => e.guid).toList();

    /// Only bother saving if the queue has changed
    if (!listEquals(guids, _queueGuids)) {
      final queue = Queue(guids: guids);

      await _queueStore.record(1).put(await _db, queue.toJson());

      _queueGuids
        ..clear()
        ..addAll(guids);
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
        final futures = <Future<int>>[];
        for (final id in chunk) {
          final finder = Finder(filter: Filter.byKey(id));
          futures.add(_transcriptStore.delete(txn, finder: finder));
        }
        await Future.wait(futures);
      });
    }
  }

  @override
  Future<Transcript> saveTranscript(Transcript transcript) async {
    final finder = Finder(filter: Filter.byKey(transcript.id));
    final snapshot =
        await _transcriptStore.findFirst(await _db, finder: finder);

    var newTranscript = transcript.copyWith(lastUpdated: DateTime.now());

    if (snapshot == null) {
      final id = await _transcriptStore.add(await _db, transcript.toJson());
      newTranscript = newTranscript.copyWith(id: id);
    } else {
      await _transcriptStore.update(
        await _db,
        transcript.toJson(),
        finder: finder,
      );
    }

    return newTranscript;
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

    await deleteEpisodes(orphaned);
  }

  /// Saves a list of episodes to the repository. To improve performance we
  /// split the episodes into chunks of 100 and save any that have been updated
  /// in that chunk in a single transaction.
  @override
  Future<List<Episode>> saveEpisodes(List<Episode> episodes) async {
    final d = await _db;
    if (episodes.isEmpty) {
      return [];
    }

    final newEpisodes = <Episode>[];
    for (final chunk in episodes.chunk(100)) {
      await d.transaction((txn) async {
        final futures = <Future<Episode>>[];
        for (final episode in chunk) {
          futures.add(_saveEpisode(episode, db: txn));
        }
        newEpisodes.addAll(await Future.wait(futures));
      });
    }

    return newEpisodes;
  }

  Future<Episode> _saveEpisode(
    Episode episode, {
    DatabaseClient? db,
  }) async {
    final finder = Finder(filter: Filter.byKey(episode.id));

    final client = db ?? await _db;
    final snapshot = await _episodeStore.findFirst(client, finder: finder);

    if (snapshot == null) {
      final id = await _episodeStore.add(client, episode.toJson());
      return episode.copyWith(id: id);
    } else {
      final e = _loadEpisodeSnapshot(snapshot);
      if (episode != e) {
        await _episodeStore.update(client, episode.toJson(), finder: finder);
      }
    }

    return episode;
  }

  @override
  Future<void> close() async {
    final d = await _db;

    await d.close();
  }

  @override
  Stream<EpisodeEvent> get episodeListener => _episodeSubject.stream;

  @override
  Stream<Podcast> get podcastListener => _podcastSubject.stream;
}
