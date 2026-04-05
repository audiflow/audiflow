import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';

import '../../../helpers/isar_test_helper.dart';

void main() {
  late Isar isar;

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
  });

  tearDown(() async {
    await isar.close(deleteFromDisk: true);
  });

  test('full station lifecycle: create, filter, reconcile, delete', () async {
    // 1. Create a Station with hideCompleted and a count limit of 1 per podcast
    final station = Station()
      ..name = 'Test Station'
      ..hideCompleted = true
      ..defaultEpisodeLimit = 1
      ..createdAt = DateTime.now()
      ..updatedAt = DateTime.now();
    await isar.writeTxn(() => isar.stations.put(station));

    // 2. Add 2 podcasts to the station
    for (final podcastId in [1, 2]) {
      await isar.writeTxn(
        () => isar.stationPodcasts.put(
          StationPodcast()
            ..stationId = station.id
            ..podcastId = podcastId
            ..addedAt = DateTime.now(),
        ),
      );
    }

    // 3. Insert episodes: 2 per podcast (newest + older)
    final now = DateTime.now();
    final episodes = [
      Episode()
        ..podcastId = 1
        ..guid = 'new-unplayed'
        ..title = 'New Unplayed'
        ..audioUrl = 'u1'
        ..publishedAt = now.subtract(const Duration(days: 3)),
      Episode()
        ..podcastId = 1
        ..guid = 'older-played'
        ..title = 'Older Played'
        ..audioUrl = 'u2'
        ..publishedAt = now.subtract(const Duration(days: 5)),
      Episode()
        ..podcastId = 2
        ..guid = 'old-unplayed'
        ..title = 'Old Unplayed'
        ..audioUrl = 'u3'
        ..publishedAt = now.subtract(const Duration(days: 60)),
      Episode()
        ..podcastId = 2
        ..guid = 'new-unplayed-2'
        ..title = 'New Unplayed 2'
        ..audioUrl = 'u4'
        ..publishedAt = now.subtract(const Duration(days: 1)),
    ];
    await isar.writeTxn(() => isar.episodes.putAll(episodes));

    // Mark 'older-played' as completed (it won't be in the limit anyway)
    await isar.writeTxn(
      () => isar.playbackHistorys.put(
        PlaybackHistory()
          ..episodeId = episodes[1].id
          ..completedAt = now
          ..positionMs = 10000,
      ),
    );

    // 4. Run reconcileFull
    final reconciler = StationReconciler(isar: isar);
    await reconciler.reconcileFull(station.id);

    // 5. Verify: only the newest unplayed episode per podcast is included.
    // defaultEpisodeLimit=1 picks: 'new-unplayed' (podcast1) and
    // 'new-unplayed-2' (podcast2), excluding the older episodes.
    var stationEpisodes = await isar.stationEpisodes
        .filter()
        .stationIdEqualTo(station.id)
        .findAll();
    check(stationEpisodes.length).equals(2);
    final episodeIds = stationEpisodes.map((se) => se.episodeId).toSet();
    check(episodeIds).contains(episodes[0].id); // new-unplayed
    check(episodeIds).contains(episodes[3].id); // new-unplayed-2

    // 6. Simulate: mark one episode as completed
    await isar.writeTxn(
      () => isar.playbackHistorys.put(
        PlaybackHistory()
          ..episodeId = episodes[0].id
          ..completedAt = now
          ..positionMs = 5000,
      ),
    );

    // 7. Run reconcileEpisode
    await reconciler.reconcileEpisode(episodes[0].id);

    // 8. Verify: completed episode removed
    stationEpisodes = await isar.stationEpisodes
        .filter()
        .stationIdEqualTo(station.id)
        .findAll();
    check(stationEpisodes.length).equals(1);
    check(stationEpisodes.first.episodeId).equals(episodes[3].id);

    // 9. Delete the station
    await isar.writeTxn(() => isar.stations.delete(station.id));
    // Clean up StationPodcast and StationEpisode
    await isar.writeTxn(() async {
      await isar.stationPodcasts
          .filter()
          .stationIdEqualTo(station.id)
          .deleteAll();
      await isar.stationEpisodes
          .filter()
          .stationIdEqualTo(station.id)
          .deleteAll();
    });

    // 10. Verify cleanup
    final remainingPodcasts = await isar.stationPodcasts
        .filter()
        .stationIdEqualTo(station.id)
        .count();
    final remainingEpisodes = await isar.stationEpisodes
        .filter()
        .stationIdEqualTo(station.id)
        .count();
    check(remainingPodcasts).equals(0);
    check(remainingEpisodes).equals(0);
  });
}
