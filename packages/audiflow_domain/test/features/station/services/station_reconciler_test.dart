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
    String playbackState = 'all',
    bool filterDownloaded = false,
    bool filterFavorited = false,
    StationDurationFilter? durationFilter,
    int? publishedWithinDays,
  }) async {
    final station = Station()
      ..name = 'Test Station'
      ..playbackState = playbackState
      ..filterDownloaded = filterDownloaded
      ..filterFavorited = filterFavorited
      ..durationFilter = durationFilter
      ..publishedWithinDays = publishedWithinDays
      ..createdAt = DateTime(2026, 1, 1)
      ..updatedAt = DateTime(2026, 1, 1);
    await isar.writeTxn(() => isar.stations.put(station));
    return station.id;
  }

  Future<void> linkPodcast(int stationId, int podcastId) async {
    await isar.writeTxn(
      () => isar.stationPodcasts.put(
        StationPodcast()
          ..stationId = stationId
          ..podcastId = podcastId
          ..addedAt = DateTime(2026, 1, 1),
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
    test('unplayed filter keeps only episodes without playback', () async {
      final stationId = await putStation(playbackState: 'unplayed');
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
      check(ids).deepEquals([epNoHistory]);
    });

    test('inProgress filter keeps only partially played episodes', () async {
      final stationId = await putStation(playbackState: 'inProgress');
      await linkPodcast(stationId, 1);

      await putEpisode(podcastId: 1, guid: 'no-history');
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
      check(ids).deepEquals([epInProgress]);
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

    test('publishedWithin filter keeps only recent episodes', () async {
      final stationId = await putStation(publishedWithinDays: 7);
      await linkPodcast(stationId, 1);

      final epRecent = await putEpisode(
        podcastId: 1,
        guid: 'recent',
        publishedAt: DateTime.now().subtract(const Duration(days: 3)),
      );
      await putEpisode(
        podcastId: 1,
        guid: 'old',
        publishedAt: DateTime.now().subtract(const Duration(days: 30)),
      );
      await putEpisode(podcastId: 1, guid: 'null-date');

      await reconciler.reconcileFull(stationId);

      final ids = await stationEpisodeIds(stationId);
      check(ids).deepEquals([epRecent]);
    });

    test('combined filters require ALL conditions to match', () async {
      final stationId = await putStation(
        playbackState: 'unplayed',
        filterDownloaded: true,
        publishedWithinDays: 30,
      );
      await linkPodcast(stationId, 1);

      // Matches all: unplayed, downloaded, recent
      final epMatch = await putEpisode(
        podcastId: 1,
        guid: 'match',
        publishedAt: DateTime.now().subtract(const Duration(days: 5)),
      );
      await putDownloadTask(episodeId: epMatch);

      // Downloaded + recent, but played
      final epPlayed = await putEpisode(
        podcastId: 1,
        guid: 'played',
        publishedAt: DateTime.now().subtract(const Duration(days: 2)),
      );
      await putDownloadTask(episodeId: epPlayed);
      await putPlaybackHistory(
        episodeId: epPlayed,
        positionMs: 1000,
        completedAt: DateTime(2026, 3, 1),
      );

      // Unplayed + recent, but not downloaded
      await putEpisode(
        podcastId: 1,
        guid: 'not-downloaded',
        publishedAt: DateTime.now().subtract(const Duration(days: 1)),
      );

      // Unplayed + downloaded, but too old
      final epOld = await putEpisode(
        podcastId: 1,
        guid: 'old',
        publishedAt: DateTime.now().subtract(const Duration(days: 60)),
      );
      await putDownloadTask(episodeId: epOld);

      await reconciler.reconcileFull(stationId);

      final ids = await stationEpisodeIds(stationId);
      check(ids).deepEquals([epMatch]);
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
      final stationId = await putStation(playbackState: 'unplayed');
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
      final stationId = await putStation(playbackState: 'unplayed');
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
}
