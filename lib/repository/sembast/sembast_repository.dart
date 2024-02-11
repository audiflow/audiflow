// Copyright 2024 HANAI Tohru, Reedom, INC.
// Copyright 2020 Ben Hills and the project contributors.
// All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';
import 'package:rxdart/rxdart.dart';
import 'package:seasoning/core/extensions.dart';
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

    final finder = podcast.id == null
        ? Finder(filter: Filter.equals('guid', podcast.guid))
        : Finder(filter: Filter.byKey(podcast.id));
    final snapshot = await _podcastStore.findFirst(await _db, finder: finder);

    var newPodcast = podcast.copyWith(lastUpdated: DateTime.now());

    if (snapshot == null) {
      newPodcast = newPodcast.copyWith(subscribedDate: DateTime.now());
      final id = await _podcastStore.add(await _db, newPodcast.toJson());
      newPodcast = newPodcast.copyWith(id: id);
    } else {
      await _podcastStore.update(
        await _db,
        newPodcast.toJson(),
        finder: finder,
      );
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
    final futures = recordSnapshots.map(_loadEpisodeSnapshot);
    return Future.wait(futures);
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
    final results = recordSnapshots.map(_loadEpisodeSnapshot);
    return Future.wait(results);
  }

  @override
  Future<List<Episode>> findDownloadsByPodcastGuid(String pguid) async {
    final finder = Finder(
      filter: Filter.and([
        Filter.equals('pguid', pguid),
        Filter.equals('downloadPercentage', 100),
      ]),
      sortOrders: [SortOrder('publicationDate', false)],
    );
    final recordSnapshots = await _episodeStore.find(await _db, finder: finder);
    final futures = recordSnapshots.map(_loadEpisodeSnapshot);
    return Future.wait(futures);
  }

  @override
  Future<List<Episode>> findDownloads() async {
    final finder = Finder(
      filter: Filter.equals('downloadPercentage', 100),
      sortOrders: [SortOrder('publicationDate', false)],
    );
    final recordSnapshots = await _episodeStore.find(await _db, finder: finder);
    final futures = recordSnapshots.map(_loadEpisodeSnapshot);
    return Future.wait(futures);
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
  Future<Episode> saveEpisode(
    Episode episode, {
    bool updateIfSame = false,
  }) async {
    final e = await _saveEpisode(episode, updateIfSame);
    _episodeSubject.add(EpisodeUpdateEvent(episode: e));

    return e;
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

    final futures = recordSnapshots.map(_loadEpisodeSnapshot);
    return Future.wait(futures);
  }

  @override
  Future<void> saveQueue(List<Episode> episodes) async {
    /// Check to see if we have any ad-hoc episodes and save them first
    final futures = <Future<Episode>>[];
    for (final e in episodes) {
      futures.add(
        e.pguid.isEmpty ? _saveEpisode(e, false) : Future.value(e),
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
    final dateStamp = DateTime.now();
    for (final chunk in episodes.chunk(100)) {
      await d.transaction((txn) async {
        final futures = <Future<int>>[];
        final newIdMap = <String, int>{};

        for (final episode in chunk) {
          final newEpisode = episode.copyWith(lastUpdated: dateStamp);
          if (newEpisode.id == null) {
            newIdMap[newEpisode.guid] = futures.length;
            newEpisodes.add(newEpisode);
            futures.add(_episodeStore.add(txn, newEpisode.toJson()));
          } else {
            final finder = Finder(filter: Filter.byKey(newEpisode.id));
            final existingEpisode = await findEpisodeById(newEpisode.id);
            if (existingEpisode == null || existingEpisode != episode) {
              futures.add(
                _episodeStore.update(txn, newEpisode.toJson(), finder: finder),
              );
              newEpisodes.add(newEpisode);
            } else {
              newEpisodes.add(episode);
            }
          }
        }

        if (futures.isEmpty) {
          return;
        }

        final ids = await Future.wait(futures);
        for (var iEpisode = 0; iEpisode < newEpisodes.length; ++iEpisode) {
          final idx = newIdMap[newEpisodes[iEpisode].guid];
          if (idx != null) {
            newEpisodes[iEpisode] =
                newEpisodes[iEpisode].copyWith(id: ids[idx]);
          }
        }
      });
    }

    return newEpisodes;
  }

  Future<Episode> _saveEpisode(Episode episode, bool updateIfSame) async {
    final finder = Finder(filter: Filter.byKey(episode.id));

    final snapshot = await _episodeStore.findFirst(await _db, finder: finder);

    var newEpisode = episode.copyWith(lastUpdated: DateTime.now());
    if (snapshot == null) {
      final id = await _episodeStore.add(await _db, newEpisode.toJson());
      newEpisode = newEpisode.copyWith(id: id);
    } else {
      final e = await _loadEpisodeSnapshot(snapshot);
      if (updateIfSame || episode != e) {
        await _episodeStore.update(
          await _db,
          newEpisode.toJson(),
          finder: finder,
        );
      }
    }

    return episode;
  }

  @override
  Future<Episode?> findEpisodeByTaskId(String taskId) async {
    final finder = Finder(filter: Filter.equals('downloadTaskId', taskId));
    final snapshot = await _episodeStore.findFirst(await _db, finder: finder);

    return snapshot == null ? null : _loadEpisodeSnapshot(snapshot);
  }

  Future<Episode> _loadEpisodeSnapshot(
    RecordSnapshot<int, Map<String, Object?>> snapshot,
  ) async {
    final episode = Episode.fromJson(snapshot.value);
    return episode.copyWith(
      id: snapshot.key,
      transcript: 0 < (episode.transcriptId ?? 0)
          ? await findTranscriptById(episode.transcriptId)
          : null,
    );
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
