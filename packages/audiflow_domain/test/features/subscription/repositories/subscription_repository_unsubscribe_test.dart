import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';

import '../../../helpers/isar_test_helper.dart';

/// Unsubscribe keeps the podcast's identity (FR 03) while removing it from
/// everything that only holds subscribed podcasts (FR 07).
void main() {
  late Isar isar;
  late SubscriptionRepositoryImpl repository;

  setUpAll(() async {
    await Isar.initializeIsarCore(download: true);
  });

  setUp(() async {
    isar = await openTestIsar([
      SubscriptionSchema,
      StationSchema,
      StationPodcastSchema,
      StationEpisodeSchema,
      EpisodeSchema,
      PlaybackHistorySchema,
      DownloadTaskSchema,
    ]);
    repository = SubscriptionRepositoryImpl(
      datasource: SubscriptionLocalDatasource(isar),
      reconcilerService: StationReconcilerService(isar: isar),
    );
  });

  tearDown(() async {
    await isar.close(deleteFromDisk: true);
  });

  Future<Subscription> subscribe() {
    return repository.subscribe(
      itunesId: 'itunes-1',
      feedUrl: 'https://example.com/feed.xml',
      title: 'Test Podcast',
      artistName: 'Test Artist',
    );
  }

  Future<int> putStationWith(int podcastId) async {
    final station = Station()
      ..name = 'Test Station'
      ..createdAt = DateTime(2026, 1, 1)
      ..updatedAt = DateTime(2026, 1, 1);
    await isar.writeTxn(() async {
      await isar.stations.put(station);
      await isar.stationPodcasts.put(
        StationPodcast()
          ..stationId = station.id
          ..podcastId = podcastId
          ..addedAt = DateTime(2026, 1, 1),
      );
    });
    return station.id;
  }

  Future<Episode> putEpisode(int podcastId, String guid) async {
    final episode = Episode()
      ..podcastId = podcastId
      ..guid = guid
      ..title = 'Episode $guid'
      ..audioUrl = 'https://example.com/$guid.mp3';
    await isar.writeTxn(() => isar.episodes.put(episode));
    return episode;
  }

  test('removes the podcast from its stations', () async {
    final subscription = await subscribe();
    final stationId = await putStationWith(subscription.id);
    await putEpisode(subscription.id, 'ep1');
    await StationReconcilerService(
      isar: isar,
    ).onStationConfigChanged(stationId);

    await repository.unsubscribe('itunes-1');

    final links = await isar.stationPodcasts
        .filter()
        .stationIdEqualTo(stationId)
        .findAll();
    final entries = await isar.stationEpisodes
        .filter()
        .stationIdEqualTo(stationId)
        .findAll();
    check(links).isEmpty();
    check(entries).isEmpty();
  });

  test('keeps episodes and playback history for a resubscribe', () async {
    final subscription = await subscribe();
    final episode = await putEpisode(subscription.id, 'ep1');
    await isar.writeTxn(
      () => isar.playbackHistorys.put(
        PlaybackHistory()
          ..episodeId = episode.id
          ..positionMs = 1000
          ..durationMs = 60000
          ..lastPlayedAt = DateTime.now(),
      ),
    );

    await repository.unsubscribe('itunes-1');
    final resubscribed = await subscribe();

    final episodes = await isar.episodes
        .filter()
        .podcastIdEqualTo(resubscribed.id)
        .findAll();
    check(episodes.map((e) => e.id)).deepEquals([episode.id]);
    check(await isar.playbackHistorys.getByEpisodeId(episode.id)).isNotNull();
  });
}
