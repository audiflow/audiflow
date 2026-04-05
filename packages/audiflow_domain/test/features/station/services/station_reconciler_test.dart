import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';

import '../../../helpers/isar_test_helper.dart';

void main() {
  late Isar isar;
  late StationReconciler reconciler;

  final schemas = [
    StationSchema,
    StationPodcastSchema,
    StationEpisodeSchema,
    EpisodeSchema,
    PlaybackHistorySchema,
    DownloadTaskSchema,
  ];

  setUpAll(() async {
    await Isar.initializeIsarCore(download: true);
  });

  setUp(() async {
    isar = await openTestIsar(schemas);
    reconciler = StationReconciler(isar: isar);
  });

  tearDown(() async {
    await isar.close(deleteFromDisk: true);
  });

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  Future<int> putStation({
    bool hideCompleted = false,
    bool filterDownloaded = false,
    bool filterFavorited = false,
    StationDurationFilter? durationFilter,
    int? defaultEpisodeLimit,
    int? publishedWithinDays,
  }) async {
    final station = Station()
      ..name = 'Test Station'
      ..hideCompleted = hideCompleted
      ..filterDownloaded = filterDownloaded
      ..filterFavorited = filterFavorited
      ..durationFilter = durationFilter
      ..defaultEpisodeLimit = defaultEpisodeLimit
      ..publishedWithinDays = publishedWithinDays
      ..createdAt = DateTime(2026, 1, 1)
      ..updatedAt = DateTime(2026, 1, 1);
    await isar.writeTxn(() => isar.stations.put(station));
    return station.id;
  }

  Future<void> linkPodcast(
    int stationId,
    int podcastId, {
    int? episodeLimit,
    int sortOrder = 0,
  }) async {
    await isar.writeTxn(
      () => isar.stationPodcasts.put(
        StationPodcast()
          ..stationId = stationId
          ..podcastId = podcastId
          ..addedAt = DateTime(2026, 1, 1)
          ..episodeLimit = episodeLimit
          ..sortOrder = sortOrder,
      ),
    );
  }

  Future<int> putEpisode({
    required int podcastId,
    required String guid,
    int? durationMs,
    DateTime? publishedAt,
    bool isFavorited = false,
  }) async {
    final episode = Episode()
      ..podcastId = podcastId
      ..guid = guid
      ..title = 'Episode $guid'
      ..audioUrl = 'https://example.com/$guid.mp3'
      ..durationMs = durationMs
      ..publishedAt = publishedAt
      ..isFavorited = isFavorited;
    await isar.writeTxn(() => isar.episodes.put(episode));
    return episode.id;
  }

  Future<void> putPlaybackHistory({
    required int episodeId,
    int positionMs = 0,
    DateTime? completedAt,
  }) async {
    await isar.writeTxn(
      () => isar.playbackHistorys.put(
        PlaybackHistory()
          ..episodeId = episodeId
          ..positionMs = positionMs
          ..completedAt = completedAt,
      ),
    );
  }

  Future<void> markCompleted(int episodeId) async {
    await putPlaybackHistory(
      episodeId: episodeId,
      positionMs: 5000,
      completedAt: DateTime(2026, 3, 1),
    );
  }

  Future<void> putDownloadTask({
    required int episodeId,
    DownloadStatus downloadStatus = const DownloadStatus.completed(),
  }) async {
    await isar.writeTxn(
      () => isar.downloadTasks.put(
        DownloadTask()
          ..episodeId = episodeId
          ..audioUrl = 'https://example.com/$episodeId.mp3'
          ..status = downloadStatus.toDbValue()
          ..createdAt = DateTime(2026, 1, 1),
      ),
    );
  }

  Future<List<int>> stationEpisodeIds(int stationId) async {
    final entries = await isar.stationEpisodes
        .filter()
        .stationIdEqualTo(stationId)
        .findAll();
    return entries.map((e) => e.episodeId).toList()..sort();
  }

  // ---------------------------------------------------------------------------
  // Tests
  // ---------------------------------------------------------------------------

  group('reconcileFull', () {
    test('hideCompleted excludes completed episodes', () async {
      final stationId = await putStation(hideCompleted: true);
      await linkPodcast(stationId, 1);

      final epNoHistory = await putEpisode(podcastId: 1, guid: 'no-history');
      final epCompleted = await putEpisode(podcastId: 1, guid: 'completed');
      final epInProgress = await putEpisode(podcastId: 1, guid: 'in-progress');

      await putPlaybackHistory(
        episodeId: epCompleted,
        positionMs: 5000,
        completedAt: DateTime(2026, 3, 1),
      );
      await putPlaybackHistory(episodeId: epInProgress, positionMs: 5000);

      await reconciler.reconcileFull(stationId);

      final ids = await stationEpisodeIds(stationId);
      check(ids).unorderedEquals([epNoHistory, epInProgress]);
    });

    test('downloaded filter keeps only completed downloads', () async {
      final stationId = await putStation(filterDownloaded: true);
      await linkPodcast(stationId, 1);

      final epDownloaded = await putEpisode(podcastId: 1, guid: 'downloaded');
      await putEpisode(podcastId: 1, guid: 'not-downloaded');

      await putDownloadTask(episodeId: epDownloaded);

      await reconciler.reconcileFull(stationId);

      final ids = await stationEpisodeIds(stationId);
      check(ids).deepEquals([epDownloaded]);
    });

    test('favorited filter keeps only favorited episodes', () async {
      final stationId = await putStation(filterFavorited: true);
      await linkPodcast(stationId, 1);

      final epFavorited = await putEpisode(
        podcastId: 1,
        guid: 'fav',
        isFavorited: true,
      );
      await putEpisode(podcastId: 1, guid: 'not-fav');

      await reconciler.reconcileFull(stationId);

      final ids = await stationEpisodeIds(stationId);
      check(ids).deepEquals([epFavorited]);
    });

    test('duration shorterThan filter keeps only short episodes', () async {
      final durationFilter = StationDurationFilter()
        ..durationOperator = 'shorterThan'
        ..durationMinutes = 30;
      final stationId = await putStation(durationFilter: durationFilter);
      await linkPodcast(stationId, 1);

      final epShort = await putEpisode(
        podcastId: 1,
        guid: 'short',
        durationMs: 15 * 60 * 1000, // 15 min
      );
      await putEpisode(
        podcastId: 1,
        guid: 'long',
        durationMs: 45 * 60 * 1000, // 45 min
      );
      await putEpisode(podcastId: 1, guid: 'null-duration');

      await reconciler.reconcileFull(stationId);

      final ids = await stationEpisodeIds(stationId);
      check(ids).deepEquals([epShort]);
    });

    test('empty station with no podcasts produces no entries', () async {
      final stationId = await putStation();

      await reconciler.reconcileFull(stationId);

      final ids = await stationEpisodeIds(stationId);
      check(ids).isEmpty();
    });
  });

  group('reconcileEpisode', () {
    test('adds episode when it becomes favorited', () async {
      final stationId = await putStation(filterFavorited: true);
      await linkPodcast(stationId, 1);

      final epId = await putEpisode(podcastId: 1, guid: 'ep1');

      // Initially not favorited, so should not be in station
      await reconciler.reconcileFull(stationId);
      check(await stationEpisodeIds(stationId)).isEmpty();

      // Toggle favorited
      final episode = (await isar.episodes.get(epId))!;
      await isar.writeTxn(() {
        final updated = Episode()
          ..id = episode.id
          ..podcastId = episode.podcastId
          ..guid = episode.guid
          ..title = episode.title
          ..audioUrl = episode.audioUrl
          ..isFavorited = true;
        return isar.episodes.put(updated);
      });

      await reconciler.reconcileEpisode(epId);

      check(await stationEpisodeIds(stationId)).deepEquals([epId]);
    });

    test('removes episode when it becomes completed', () async {
      final stationId = await putStation(hideCompleted: true);
      await linkPodcast(stationId, 1);

      final epId = await putEpisode(podcastId: 1, guid: 'ep1');

      // Initially unplayed, should be in station
      await reconciler.reconcileFull(stationId);
      check(await stationEpisodeIds(stationId)).deepEquals([epId]);

      // Mark as completed
      await putPlaybackHistory(
        episodeId: epId,
        positionMs: 5000,
        completedAt: DateTime(2026, 3, 1),
      );

      await reconciler.reconcileEpisode(epId);

      check(await stationEpisodeIds(stationId)).isEmpty();
    });
  });

  group('diff correctness', () {
    test('second reconcileFull is a no-op with unchanged data', () async {
      final stationId = await putStation(hideCompleted: true);
      await linkPodcast(stationId, 1);

      final epId = await putEpisode(podcastId: 1, guid: 'ep1');

      await reconciler.reconcileFull(stationId);
      final firstRun = await stationEpisodeIds(stationId);
      check(firstRun).deepEquals([epId]);

      // Capture the station episode row id from first run
      final firstEntries = await isar.stationEpisodes
          .filter()
          .stationIdEqualTo(stationId)
          .findAll();
      final firstRowId = firstEntries.first.id;

      await reconciler.reconcileFull(stationId);

      final secondEntries = await isar.stationEpisodes
          .filter()
          .stationIdEqualTo(stationId)
          .findAll();

      // Same row id means no delete+reinsert happened
      check(secondEntries).length.equals(1);
      check(secondEntries.first.id).equals(firstRowId);
      check(secondEntries.first.episodeId).equals(epId);
    });
  });

  group('DB-level pre-filtering', () {
    test('filterFavorited skips non-favorited at query level', () async {
      final stationId = await putStation(filterFavorited: true);
      await linkPodcast(stationId, 1);

      await putEpisode(podcastId: 1, guid: 'not-fav-1');
      await putEpisode(podcastId: 1, guid: 'not-fav-2');
      final epFav = await putEpisode(
        podcastId: 1,
        guid: 'fav',
        isFavorited: true,
      );

      await reconciler.reconcileFull(stationId);

      check(await stationEpisodeIds(stationId)).deepEquals([epFav]);
    });

    test('durationFilter longerThan skips short at query level', () async {
      final durationFilter = StationDurationFilter()
        ..durationOperator = 'longerThan'
        ..durationMinutes = 30;
      final stationId = await putStation(durationFilter: durationFilter);
      await linkPodcast(stationId, 1);

      await putEpisode(podcastId: 1, guid: 'short', durationMs: 10 * 60 * 1000);
      final epLong = await putEpisode(
        podcastId: 1,
        guid: 'long',
        durationMs: 60 * 60 * 1000,
      );
      await putEpisode(podcastId: 1, guid: 'null-dur');

      await reconciler.reconcileFull(stationId);

      check(await stationEpisodeIds(stationId)).deepEquals([epLong]);
    });
  });

  group('count-based episode limiting', () {
    test('limits episodes per podcast using station default', () async {
      final stationId = await putStation(defaultEpisodeLimit: 2);
      await linkPodcast(stationId, 1);
      for (var i = 0; i < 4; i++) {
        await putEpisode(
          podcastId: 1,
          guid: 'ep-$i',
          publishedAt: DateTime(2026, 4, 1).add(Duration(days: i)),
        );
      }
      await reconciler.reconcileFull(stationId);
      final results = await isar.stationEpisodes
          .filter()
          .stationIdEqualTo(stationId)
          .findAll();
      check(results.length).equals(2);
    });

    test('per-podcast episodeLimit overrides station default', () async {
      final stationId = await putStation(defaultEpisodeLimit: 1);
      await linkPodcast(stationId, 1, episodeLimit: 3);
      for (var i = 0; i < 5; i++) {
        await putEpisode(
          podcastId: 1,
          guid: 'ep-$i',
          publishedAt: DateTime(2026, 4, 1).add(Duration(days: i)),
        );
      }
      await reconciler.reconcileFull(stationId);
      final results = await isar.stationEpisodes
          .filter()
          .stationIdEqualTo(stationId)
          .findAll();
      check(results.length).equals(3);
    });

    test('null limit includes all episodes', () async {
      final stationId = await putStation(defaultEpisodeLimit: null);
      await linkPodcast(stationId, 1);
      for (var i = 0; i < 10; i++) {
        await putEpisode(
          podcastId: 1,
          guid: 'ep-$i',
          publishedAt: DateTime(2026, 4, 1).add(Duration(days: i)),
        );
      }
      await reconciler.reconcileFull(stationId);
      final results = await isar.stationEpisodes
          .filter()
          .stationIdEqualTo(stationId)
          .findAll();
      check(results.length).equals(10);
    });

    test('count limit applied before attribute filters', () async {
      final stationId = await putStation(
        defaultEpisodeLimit: 3,
        hideCompleted: true,
      );
      await linkPodcast(stationId, 1);
      await putEpisode(
        podcastId: 1,
        guid: 'old',
        publishedAt: DateTime(2026, 4, 1),
      );
      await putEpisode(
        podcastId: 1,
        guid: 'mid',
        publishedAt: DateTime(2026, 4, 2),
      );
      final epCompleted = await putEpisode(
        podcastId: 1,
        guid: 'new-completed',
        publishedAt: DateTime(2026, 4, 3),
      );
      await putEpisode(
        podcastId: 1,
        guid: 'newest',
        publishedAt: DateTime(2026, 4, 4),
      );
      await markCompleted(epCompleted);

      await reconciler.reconcileFull(stationId);
      final results = await isar.stationEpisodes
          .filter()
          .stationIdEqualTo(stationId)
          .findAll();
      // Latest 3 = newest, new-completed, mid. new-completed filtered by
      // hideCompleted. 2 remain.
      check(results.length).equals(2);
    });

    test('multiple podcasts with different limits', () async {
      final stationId = await putStation(defaultEpisodeLimit: 2);
      await linkPodcast(stationId, 1);
      await linkPodcast(stationId, 2, episodeLimit: 1);
      for (var i = 0; i < 3; i++) {
        await putEpisode(
          podcastId: 1,
          guid: 'p1-$i',
          publishedAt: DateTime(2026, 4, 1).add(Duration(days: i)),
        );
        await putEpisode(
          podcastId: 2,
          guid: 'p2-$i',
          publishedAt: DateTime(2026, 4, 1).add(Duration(days: i)),
        );
      }
      await reconciler.reconcileFull(stationId);
      final results = await isar.stationEpisodes
          .filter()
          .stationIdEqualTo(stationId)
          .findAll();
      check(results.length).equals(3); // 2 from p1, 1 from p2
    });

    test('podcastSortKey populated from StationPodcast.sortOrder', () async {
      final stationId = await putStation(defaultEpisodeLimit: 1);
      await linkPodcast(stationId, 1, sortOrder: 0);
      await linkPodcast(stationId, 2, sortOrder: 1);
      await putEpisode(
        podcastId: 1,
        guid: 'p1',
        publishedAt: DateTime(2026, 4, 5),
      );
      await putEpisode(
        podcastId: 2,
        guid: 'p2',
        publishedAt: DateTime(2026, 4, 5),
      );

      await reconciler.reconcileFull(stationId);
      final results = await isar.stationEpisodes
          .filter()
          .stationIdEqualTo(stationId)
          .sortByPodcastSortKey()
          .findAll();
      check(results.length).equals(2);
      check(results[0].podcastSortKey).equals(0);
      check(results[1].podcastSortKey).equals(1);
    });
  });

  // ---------------------------------------------------------------------------
  // Backward compatibility
  // ---------------------------------------------------------------------------

  group('legacy publishedWithinDays', () {
    test('filters out episodes older than the cutoff', () async {
      final now = DateTime.now();
      final stationId = await putStation(publishedWithinDays: 7);
      await linkPodcast(stationId, 1);

      // Recent episode (within 7 days of now).
      await putEpisode(
        podcastId: 1,
        guid: 'recent',
        publishedAt: now.subtract(const Duration(days: 2)),
      );
      // Old episode (outside 7 days of now).
      await putEpisode(
        podcastId: 1,
        guid: 'old',
        publishedAt: now.subtract(const Duration(days: 30)),
      );

      await reconciler.reconcileFull(stationId);
      final ids = await stationEpisodeIds(stationId);
      check(ids.length).equals(1);
    });
  });
}
