import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';

import '../../../helpers/isar_test_helper.dart';

void main() {
  late Isar isar;
  late StationReconcilerService service;

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
    service = StationReconcilerService(isar: isar);
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
  }) async {
    final station = Station()
      ..name = 'Test Station'
      ..playbackState = playbackState
      ..filterDownloaded = filterDownloaded
      ..filterFavorited = filterFavorited
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
    bool isFavorited = false,
  }) async {
    final episode = Episode()
      ..podcastId = podcastId
      ..guid = guid
      ..title = 'Episode $guid'
      ..audioUrl = 'https://example.com/$guid.mp3'
      ..isFavorited = isFavorited;
    await isar.writeTxn(() => isar.episodes.put(episode));
    return episode.id;
  }

  Future<List<int>> stationEpisodeIds(int stationId) async {
    final entries = await isar.stationEpisodes
        .filter()
        .stationIdEqualTo(stationId)
        .findAll();
    return entries.map((e) => e.episodeId).toList()..sort();
  }

  Future<List<int>> stationPodcastIdsForStation(int stationId) async {
    final entries = await isar.stationPodcasts
        .filter()
        .stationIdEqualTo(stationId)
        .findAll();
    return entries.map((e) => e.podcastId).toList()..sort();
  }

  // ---------------------------------------------------------------------------
  // Tests
  // ---------------------------------------------------------------------------

  group('onEpisodeChanged triggers differential reconciliation', () {
    test(
      'unfavorited episode not added when station filters by favorited',
      () async {
        final stationId = await putStation(filterFavorited: true);
        await linkPodcast(stationId, 1);

        final epId = await putEpisode(podcastId: 1, guid: 'ep1');

        await service.onEpisodeChanged(epId);

        check(await stationEpisodeIds(stationId)).isEmpty();
      },
    );

    test('episode appears in StationEpisode after being favorited', () async {
      final stationId = await putStation(filterFavorited: true);
      await linkPodcast(stationId, 1);

      final epId = await putEpisode(podcastId: 1, guid: 'ep1');

      // Not favorited yet — should not appear.
      await service.onEpisodeChanged(epId);
      check(await stationEpisodeIds(stationId)).isEmpty();

      // Favorite the episode and re-evaluate.
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

      await service.onEpisodeChanged(epId);

      check(await stationEpisodeIds(stationId)).deepEquals([epId]);
    });
  });

  group('onStationConfigChanged triggers full reconciliation', () {
    test(
      'all-filter station includes all episodes after config change',
      () async {
        final stationId = await putStation();
        await linkPodcast(stationId, 1);

        final ep1 = await putEpisode(podcastId: 1, guid: 'ep1');
        final ep2 = await putEpisode(podcastId: 1, guid: 'ep2');
        final ep3 = await putEpisode(podcastId: 1, guid: 'ep3');

        await service.onStationConfigChanged(stationId);

        check(await stationEpisodeIds(stationId)).deepEquals([ep1, ep2, ep3]);
      },
    );

    test('filter change to favorited removes non-favorited episodes', () async {
      final stationId = await putStation();
      await linkPodcast(stationId, 1);

      final epFav = await putEpisode(
        podcastId: 1,
        guid: 'fav',
        isFavorited: true,
      );
      final epNotFav = await putEpisode(podcastId: 1, guid: 'not-fav');

      // Initial reconciliation with all-filter includes both.
      await service.onStationConfigChanged(stationId);
      check(
        await stationEpisodeIds(stationId),
      ).deepEquals([epFav, epNotFav]..sort());

      // Update station to filterFavorited = true.
      final station = (await isar.stations.get(stationId))!;
      await isar.writeTxn(() {
        final updated = Station()
          ..id = station.id
          ..name = station.name
          ..playbackState = station.playbackState
          ..filterDownloaded = station.filterDownloaded
          ..filterFavorited = true
          ..createdAt = station.createdAt
          ..updatedAt = DateTime.now();
        return isar.stations.put(updated);
      });

      await service.onStationConfigChanged(stationId);

      check(await stationEpisodeIds(stationId)).deepEquals([epFav]);
    });
  });

  group('onSubscriptionDeleted cleans up', () {
    test('removes StationPodcast entries and reconciles station', () async {
      final stationId = await putStation();
      await linkPodcast(stationId, 1);

      final ep1 = await putEpisode(podcastId: 1, guid: 'ep1');
      final ep2 = await putEpisode(podcastId: 1, guid: 'ep2');

      // Prime the materialized view.
      await service.onStationConfigChanged(stationId);
      check(await stationEpisodeIds(stationId)).deepEquals([ep1, ep2]..sort());

      // Delete the subscription.
      await service.onSubscriptionDeleted(1);

      // StationPodcast link should be gone.
      check(await stationPodcastIdsForStation(stationId)).isEmpty();

      // StationEpisode entries for this podcast should be removed.
      check(await stationEpisodeIds(stationId)).isEmpty();
    });

    test('does not affect stations linked to other podcasts', () async {
      final stationId = await putStation();
      await linkPodcast(stationId, 1);
      await linkPodcast(stationId, 2);

      final ep1 = await putEpisode(podcastId: 1, guid: 'ep1');
      final ep2 = await putEpisode(podcastId: 2, guid: 'ep2');

      await service.onStationConfigChanged(stationId);
      check(await stationEpisodeIds(stationId)).deepEquals([ep1, ep2]..sort());

      // Delete only podcast 1's subscription.
      await service.onSubscriptionDeleted(1);

      // Only podcast 2's episode should remain.
      check(await stationEpisodeIds(stationId)).deepEquals([ep2]);
    });

    test('no-op when podcast is not linked to any station', () async {
      // Should complete without error even if podcast is not in any station.
      await service.onSubscriptionDeleted(999);
    });
  });
}
