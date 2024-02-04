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
import 'package:seasoning/entities/season.dart';
import 'package:seasoning/entities/transcript.dart';
import 'package:seasoning/repository/repository.dart';
import 'package:seasoning/repository/sembast/sembast_database_service.dart';
import 'package:seasoning/state/episode_state.dart';
import 'package:seasoning/state/season_state.dart';
import 'package:sembast/sembast.dart';

/// An implementation of [Repository] that is backed by
/// [Sembast](https://github.com/tekartik/sembast.dart/tree/master/sembast)
class SembastRepository extends Repository {
  SembastRepository({
    bool cleanup = true,
    String databaseName = 'seasoning.db',
  }) {
    _databaseService =
        DatabaseService(databaseName, version: 2, upgraderCallback: dbUpgrader);

    if (cleanup) {
      _cleanupEpisodes().then((value) {
        log.fine('Orphan episodes cleanup complete');
      });
      _cleanupSeasons().then((value) {
        log.fine('Orphan seasons cleanup complete');
      });
    }
  }

  final log = Logger('SembastRepository');

  final _podcastSubject = BehaviorSubject<Podcast>();
  final _seasonSubject = BehaviorSubject<SeasonState>();
  final _episodeSubject = BehaviorSubject<EpisodeState>();

  final _podcastStore = intMapStoreFactory.store('podcast');
  final _seasonStore = intMapStoreFactory.store('season');
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
      newPodcast = podcast.copyWith(subscribedDate: DateTime.now());
      final id = await _podcastStore.add(await _db, newPodcast.toJson());
      newPodcast = newPodcast.copyWith(id: id);
    } else {
      await _podcastStore.update(
        await _db,
        newPodcast.toJson(),
        finder: finder,
      );
    }

    await _saveEpisodes(newPodcast.episodes);
    await _saveSeasons(newPodcast.seasons);
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
    return subscriptionSnapshot
        .map((snapshot) => Podcast.fromJson(snapshot.value))
        .toList();
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

    final p = Podcast.fromJson(snapshot.value);
    return p.copyWith(
      id: snapshot.key,
      episodes: await findEpisodesByPodcastGuid(p.guid),
      seasons: await findSeasonsByPodcastGuid(p.guid),
    );
  }

  @override
  Future<Podcast?> findPodcastByGuid(String guid) async {
    final finder = Finder(filter: Filter.equals('guid', guid));
    final snapshot = await _podcastStore.findFirst(await _db, finder: finder);
    if (snapshot == null) {
      return null;
    }

    final p = Podcast.fromJson(snapshot.value);
    return p.copyWith(
      id: snapshot.key,
      episodes: await findEpisodesByPodcastGuid(p.guid),
    );
  }

  @override
  Future<List<Season>> findAllSeasons() async {
    final finder = Finder(sortOrders: [SortOrder('title')]);
    final recordSnapshots = await _seasonStore.find(await _db, finder: finder);
    return recordSnapshots
        .map((snapshot) => _loadSeasonSnapshot(snapshot.key, snapshot.value))
        .toList();
  }

  @override
  Future<Season?> findSeasonById(int id) async {
    final finder = Finder(filter: Filter.byKey(id));
    final snapshot = (await _seasonStore.findFirst(await _db, finder: finder))!;
    return _loadSeasonSnapshot(snapshot.key, snapshot.value);
  }

  @override
  Future<List<Season>> findSeasonsByPodcastGuid(String? pguid) async {
    final finder = Finder(
      filter: Filter.equals('pguid', pguid),
      sortOrders: [SortOrder('seasonNum', false)],
    );

    final recordSnapshots = await _seasonStore.find(await _db, finder: finder);
    final results = recordSnapshots.map(
      (snapshot) async => _loadSeasonSnapshot(snapshot.key, snapshot.value),
    );
    return Future.wait(results);
  }

  @override
  Future<void> deleteSeasons(List<Season> seasons) async {
    final d = await _db;
    for (final chunk in seasons.chunk(100)) {
      await d.transaction((txn) async {
        final futures = <Future<int>>[];
        for (final season in chunk) {
          final finder = Finder(filter: Filter.byKey(season.id));
          futures.add(_seasonStore.delete(txn, finder: finder));
          _seasonSubject.add(SeasonDeleteState(season));
        }
        await Future.wait(futures);
      });
    }
  }

  @override
  Future<List<Episode>> findAllEpisodes() async {
    final finder = Finder(
      sortOrders: [SortOrder('publicationDate', false)],
    );
    final recordSnapshots = await _episodeStore.find(await _db, finder: finder);
    return recordSnapshots.map((snapshot) {
      final episode = Episode.fromJson(snapshot.value);
      return episode.copyWith(id: snapshot.key);
    }).toList();
  }

  @override
  Future<Episode?> findEpisodeById(int? id) async {
    final finder = Finder(filter: Filter.byKey(id));
    final snapshot =
        (await _episodeStore.findFirst(await _db, finder: finder))!;
    return _loadEpisodeSnapshot(snapshot.key, snapshot.value);
  }

  @override
  Future<Episode?> findEpisodeByGuid(String guid) async {
    final finder = Finder(filter: Filter.equals('guid', guid));
    final snapshot = await _episodeStore.findFirst(await _db, finder: finder);
    return snapshot == null
        ? null
        : _loadEpisodeSnapshot(snapshot.key, snapshot.value);
  }

  @override
  Future<List<Episode>> findEpisodesByPodcastGuid(String? pguid) async {
    final finder = Finder(
      filter: Filter.equals('pguid', pguid),
      sortOrders: [SortOrder('publicationDate', false)],
    );
    final recordSnapshots = await _episodeStore.find(await _db, finder: finder);
    final results = recordSnapshots
        .map(
          (snapshot) async =>
              _loadEpisodeSnapshot(snapshot.key, snapshot.value),
        )
        .toList();
    return Future.wait(results);
  }

  @override
  Future<List<Episode>> findDownloadsByPodcastGuid(String pguid) async {
    final finder = Finder(
      filter: Filter.and([
        Filter.equals('pguid', pguid),
        Filter.equals('downloadPercentage', '100'),
      ]),
      sortOrders: [SortOrder('publicationDate', false)],
    );
    final recordSnapshots = await _episodeStore.find(await _db, finder: finder);
    final futures = recordSnapshots
        .map((snapshot) => _loadEpisodeSnapshot(snapshot.key, snapshot.value))
        .toList();
    return Future.wait(futures);
  }

  @override
  Future<List<Episode>> findDownloads() async {
    final finder = Finder(
      filter: Filter.equals('downloadPercentage', '100'),
      sortOrders: [SortOrder('publicationDate', false)],
    );
    final recordSnapshots = await _episodeStore.find(await _db, finder: finder);
    final futures = recordSnapshots
        .map((snapshot) => _loadEpisodeSnapshot(snapshot.key, snapshot.value))
        .toList();
    return Future.wait(futures);
  }

  @override
  Future<void> deleteEpisode(Episode episode) async {
    final finder = Finder(filter: Filter.byKey(episode.id));
    final snapshot = await _episodeStore.findFirst(await _db, finder: finder);
    if (snapshot != null) {
      await _episodeStore.delete(await _db, finder: finder);
      _episodeSubject.add(EpisodeDeleteState(episode));
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
    _episodeSubject.add(EpisodeUpdateState(e));

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

    final futures = recordSnapshots
        .map((snapshot) => _loadEpisodeSnapshot(snapshot.key, snapshot.value));
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
    return snapshot == null ? null : Transcript.fromJson(snapshot.value);
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

  Future<void> _cleanupSeasons() async {
    final threshold = DateTime.now()
        .subtract(const Duration(days: 60))
        .millisecondsSinceEpoch;

    /// Find all streamed seasons over the threshold.
    final filter = Filter.and([
      Filter.equals('downloadState', 0),
      Filter.lessThan('lastUpdated', threshold),
    ]);

    final orphaned = <Season>[];
    final pguids = <String?>[];
    final seasons =
        await _seasonStore.find(await _db, finder: Finder(filter: filter));

    // First, find all podcasts
    for (final podcast in await _podcastStore.find(await _db)) {
      pguids.add(podcast.value['guid'] as String?);
    }

    for (final season in seasons) {
      final pguid = season.value['pguid'] as String?;
      final podcast = pguids.contains(pguid);

      if (!podcast) {
        orphaned.add(Season.fromJson(season.value));
      }
    }

    await deleteSeasons(orphaned);
  }

  /// Saves a list of seasons to the repository. To improve performance we
  /// split the seasons into chunks of 100 and save any that have been updated
  /// in that chunk in a single transaction.
  Future<void> _saveSeasons(List<Season> seasons) async {
    final d = await _db;

    if (seasons.isEmpty) {
      return;
    }

    for (final chunk in seasons.chunk(100)) {
      await d.transaction((txn) async {
        final futures = <Future<int>>[];
        final newSeasons = <Season>[];
        for (final season in chunk) {
          if (season.id == null) {
            futures.add(_seasonStore.add(txn, season.toJson()));
            newSeasons.add(season);
          } else {
            final finder = Finder(filter: Filter.byKey(season.id));
            final existingSeason = await findSeasonById(season.id!);
            if (existingSeason == null || existingSeason != season) {
              futures.add(
                _seasonStore.update(txn, season.toJson(), finder: finder),
              );
              newSeasons.add(season);
            }
          }
        }

        if (futures.isNotEmpty) {
          final ids = await Future.wait(futures);
          for (var i = 0; i < ids.length; i++) {
            newSeasons[i] = newSeasons[i].copyWith(id: ids[i]);
            _seasonSubject.add(SeasonUpdateState(newSeasons[i]));
          }
        }
      });
    }
  }

  Season _loadSeasonSnapshot(
    int key,
    Map<String, Object?> snapshot,
  ) {
    final season = Season.fromJson(snapshot);
    return season.copyWith(id: key);
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
  Future<void> _saveEpisodes(List<Episode> episodes) async {
    final d = await _db;
    if (episodes.isEmpty) {
      return;
    }

    final dateStamp = DateTime.now();
    for (final chunk in episodes.chunk(100)) {
      await d.transaction((txn) async {
        final futures = <Future<int>>[];

        for (final episode in chunk) {
          final newEpisode = episode.copyWith(lastUpdated: dateStamp);
          if (newEpisode.id == null) {
            futures.add(_episodeStore.add(txn, newEpisode.toJson()));
          } else {
            final finder = Finder(filter: Filter.byKey(newEpisode.id));
            final existingEpisode = await findEpisodeById(newEpisode.id);
            if (existingEpisode == null || existingEpisode != episode) {
              futures.add(
                _episodeStore.update(txn, newEpisode.toJson(), finder: finder),
              );
            }
          }
        }

        if (futures.isNotEmpty) {
          await Future.wait(futures);
        }
      });
    }
  }

  Future<Episode> _saveEpisode(Episode episode, bool updateIfSame) async {
    final finder = Finder(filter: Filter.byKey(episode.id));

    final snapshot = await _episodeStore.findFirst(await _db, finder: finder);

    var newEpisode = episode.copyWith(lastUpdated: DateTime.now());
    if (snapshot == null) {
      final id = await _episodeStore.add(await _db, newEpisode.toJson());
      newEpisode = newEpisode.copyWith(id: id);
    } else {
      final e = Episode.fromJson(snapshot.value);
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

    return snapshot == null
        ? null
        : _loadEpisodeSnapshot(snapshot.key, snapshot.value);
  }

  Future<Episode> _loadEpisodeSnapshot(
      int key, Map<String, Object?> snapshot) async {
    final episode = Episode.fromJson(snapshot);
    return episode.copyWith(
      id: key,
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

  Future<void> dbUpgrader(Database db, int oldVersion, int newVersion) async {
    if (oldVersion == 1) {
      await _upgradeV2(db);
    }
  }

  /// In v1 we allowed http requests, where as now we force to https.
  /// As we currently use the URL as the GUID we need to upgrade any followed
  /// podcasts that have a http base to https.
  /// We use the passed [Database] rather than _db to prevent deadlocking,
  /// hence the direct update to data within this routine rather than using the
  /// existing find/update methods.
  Future<void> _upgradeV2(Database db) async {
    final data = await _podcastStore.find(db);
    final podcasts = data.map((e) => Podcast.fromJson(e.value)).toList();

    log.info('Upgrading Sembast store to V2');

    for (final podcast in podcasts) {
      if (podcast.guid.startsWith('http:')) {
        final idFinder = Finder(filter: Filter.byKey(podcast.id));
        final guid = podcast.guid.replaceFirst('http:', 'https:');
        final episodeFinder = Finder(
          filter: Filter.equals('pguid', podcast.guid),
        );

        log.fine('Upgrading GUID ${podcast.guid} - to $guid');

        var upgradedPodcast = Podcast(
          id: podcast.id,
          guid: guid,
          url: podcast.url,
          link: podcast.link,
          title: podcast.title,
          description: podcast.description,
          imageUrl: podcast.imageUrl,
          thumbImageUrl: podcast.thumbImageUrl,
          copyright: podcast.copyright,
          funding: podcast.funding,
          persons: podcast.persons,
          lastUpdated: DateTime.now(),
        );

        final episodeData = await _episodeStore.find(db, finder: episodeFinder);
        final episodes =
            episodeData.map((e) => Episode.fromJson(e.value)).toList();

        // Now upgrade episodes
        for (final e in episodes) {
          log.fine(
            'Updating episode guid for ${e.title} from ${e.pguid} to $guid',
          );
          final episode = e.copyWith(pguid: guid);

          final epf = Finder(filter: Filter.byKey(episode.id));
          await _episodeStore.update(db, e.toJson(), finder: epf);
        }

        upgradedPodcast = upgradedPodcast.copyWith(episodes: episodes);
        await _podcastStore.update(
          db,
          upgradedPodcast.toJson(),
          finder: idFinder,
        );
      }
    }
  }

  @override
  Stream<EpisodeState> get episodeListener => _episodeSubject.stream;

  @override
  Stream<SeasonState> get seasonListener => _seasonSubject.stream;

  @override
  Stream<Podcast> get podcastListener => _podcastSubject.stream;
}
