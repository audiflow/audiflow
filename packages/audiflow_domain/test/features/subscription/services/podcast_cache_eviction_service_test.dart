import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';
import 'package:logger/logger.dart';

void main() {
  late Isar isar;
  late SubscriptionRepositoryImpl subscriptionRepo;
  late PodcastCacheEvictionService service;
  late Logger logger;

  setUpAll(() async {
    await Isar.initializeIsarCore(download: true);
  });

  setUp(() async {
    isar = await Isar.open(
      [
        SubscriptionSchema,
        EpisodeSchema,
        PlaybackHistorySchema,
        SmartPlaylistEntitySchema,
        SmartPlaylistGroupEntitySchema,
        PodcastViewPreferenceSchema,
      ],
      directory: '',
      name: 'test_${DateTime.now().microsecondsSinceEpoch}',
    );
    final datasource = SubscriptionLocalDatasource(isar);
    subscriptionRepo = SubscriptionRepositoryImpl(datasource: datasource);
    logger = Logger(level: Level.off);
  });

  tearDown(() async {
    await isar.close(deleteFromDisk: true);
  });

  Future<Subscription> createCached(
    String itunesId, {
    DateTime? lastAccessedAt,
  }) async {
    final sub = await subscriptionRepo.getOrCreateCached(
      itunesId: itunesId,
      feedUrl: 'https://example.com/$itunesId/feed.xml',
      title: 'Podcast $itunesId',
      artistName: 'Artist',
    );
    if (lastAccessedAt != null) {
      await isar.writeTxn(() async {
        sub.lastAccessedAt = lastAccessedAt;
        await isar.subscriptions.put(sub);
      });
    }
    return sub;
  }

  Future<Episode> createEpisode(int podcastId, String guid) async {
    final episode = Episode()
      ..podcastId = podcastId
      ..guid = guid
      ..title = 'Episode $guid'
      ..audioUrl = 'https://example.com/$guid.mp3';
    await isar.writeTxn(() async {
      await isar.episodes.put(episode);
    });
    return episode;
  }

  Future<void> createHistory(int episodeId) async {
    final history = PlaybackHistory()
      ..episodeId = episodeId
      ..positionMs = 1000
      ..durationMs = 60000
      ..lastPlayedAt = DateTime.now();
    await isar.writeTxn(() async {
      await isar.playbackHistorys.put(history);
    });
  }

  Future<void> createSmartPlaylist(int podcastId) async {
    final entity = SmartPlaylistEntity()
      ..podcastId = podcastId
      ..playlistNumber = 1
      ..playlistId = 'pl-$podcastId'
      ..displayName = 'Playlist'
      ..sortKey = 1
      ..resolverType = 'rss';
    await isar.writeTxn(() async {
      await isar.smartPlaylistEntitys.put(entity);
    });
  }

  Future<void> createSmartPlaylistGroup(int podcastId) async {
    final entity = SmartPlaylistGroupEntity()
      ..podcastId = podcastId
      ..playlistId = 'pl-$podcastId'
      ..groupId = 'g1'
      ..displayName = 'Group 1'
      ..sortKey = 1
      ..episodeIds = '1,2,3';
    await isar.writeTxn(() async {
      await isar.smartPlaylistGroupEntitys.put(entity);
    });
  }

  Future<void> createViewPreference(int podcastId) async {
    final pref = PodcastViewPreference()..podcastId = podcastId;
    await isar.writeTxn(() async {
      await isar.podcastViewPreferences.put(pref);
    });
  }

  group('evict', () {
    test('returns 0 when no cached subscriptions exist', () async {
      service = PodcastCacheEvictionService(
        subscriptionRepository: subscriptionRepo,
        isar: isar,
        logger: logger,
      );

      final result = await service.evict();

      expect(result, 0);
    });

    test('does not evict fresh cached subscriptions', () async {
      await createCached('p1', lastAccessedAt: DateTime.now());

      service = PodcastCacheEvictionService(
        subscriptionRepository: subscriptionRepo,
        isar: isar,
        logger: logger,
      );

      final result = await service.evict();

      expect(result, 0);
      final remaining = await subscriptionRepo.getCachedSubscriptions();
      expect(remaining, hasLength(1));
    });

    test('evicts stale cached subscriptions past maxAge', () async {
      final staleDate = DateTime.now().subtract(const Duration(days: 10));
      await createCached('stale', lastAccessedAt: staleDate);
      await createCached('fresh', lastAccessedAt: DateTime.now());

      service = PodcastCacheEvictionService(
        subscriptionRepository: subscriptionRepo,
        isar: isar,
        logger: logger,
        maxAge: const Duration(days: 7),
      );

      final result = await service.evict();

      expect(result, 1);
      final remaining = await subscriptionRepo.getCachedSubscriptions();
      expect(remaining, hasLength(1));
      expect(remaining.first.itunesId, 'fresh');
    });

    test('enforces cap on remaining cached entries', () async {
      for (var i = 0; i < 5; i++) {
        await createCached(
          'p$i',
          lastAccessedAt: DateTime.now().subtract(Duration(hours: 5 - i)),
        );
      }

      service = PodcastCacheEvictionService(
        subscriptionRepository: subscriptionRepo,
        isar: isar,
        logger: logger,
        maxCachedPodcasts: 2,
      );

      final result = await service.evict();

      expect(result, 3);
      final remaining = await subscriptionRepo.getCachedSubscriptions();
      expect(remaining, hasLength(2));
    });

    test('cascades deletes to episodes', () async {
      final staleDate = DateTime.now().subtract(const Duration(days: 10));
      final sub = await createCached('stale', lastAccessedAt: staleDate);
      await createEpisode(sub.id, 'ep1');
      await createEpisode(sub.id, 'ep2');

      service = PodcastCacheEvictionService(
        subscriptionRepository: subscriptionRepo,
        isar: isar,
        logger: logger,
      );

      await service.evict();

      final episodes = await isar.episodes
          .filter()
          .podcastIdEqualTo(sub.id)
          .findAll();
      expect(episodes, isEmpty);
    });

    test('cascades deletes to playback history', () async {
      final staleDate = DateTime.now().subtract(const Duration(days: 10));
      final sub = await createCached('stale', lastAccessedAt: staleDate);
      final ep = await createEpisode(sub.id, 'ep1');
      await createHistory(ep.id);

      service = PodcastCacheEvictionService(
        subscriptionRepository: subscriptionRepo,
        isar: isar,
        logger: logger,
      );

      await service.evict();

      final histories = await isar.playbackHistorys.where().findAll();
      expect(histories, isEmpty);
    });

    test('cascades deletes to smart playlists and groups', () async {
      final staleDate = DateTime.now().subtract(const Duration(days: 10));
      final sub = await createCached('stale', lastAccessedAt: staleDate);
      await createSmartPlaylist(sub.id);
      await createSmartPlaylistGroup(sub.id);

      service = PodcastCacheEvictionService(
        subscriptionRepository: subscriptionRepo,
        isar: isar,
        logger: logger,
      );

      await service.evict();

      final playlists = await isar.smartPlaylistEntitys
          .filter()
          .podcastIdEqualTo(sub.id)
          .findAll();
      final groups = await isar.smartPlaylistGroupEntitys
          .filter()
          .podcastIdEqualTo(sub.id)
          .findAll();
      expect(playlists, isEmpty);
      expect(groups, isEmpty);
    });

    test('cascades deletes to view preferences', () async {
      final staleDate = DateTime.now().subtract(const Duration(days: 10));
      final sub = await createCached('stale', lastAccessedAt: staleDate);
      await createViewPreference(sub.id);

      service = PodcastCacheEvictionService(
        subscriptionRepository: subscriptionRepo,
        isar: isar,
        logger: logger,
      );

      await service.evict();

      final prefs = await isar.podcastViewPreferences
          .filter()
          .podcastIdEqualTo(sub.id)
          .findAll();
      expect(prefs, isEmpty);
    });

    test('does not evict real subscriptions', () async {
      await subscriptionRepo.subscribe(
        itunesId: 'real',
        feedUrl: 'https://example.com/real/feed.xml',
        title: 'Real Podcast',
        artistName: 'Artist',
      );
      final staleDate = DateTime.now().subtract(const Duration(days: 10));
      await createCached('stale', lastAccessedAt: staleDate);

      service = PodcastCacheEvictionService(
        subscriptionRepository: subscriptionRepo,
        isar: isar,
        logger: logger,
      );

      final result = await service.evict();

      expect(result, 1);
      final real = await subscriptionRepo.getSubscription('real');
      expect(real, isNotNull);
    });

    test('preserves data for non-evicted cached subscriptions', () async {
      final staleDate = DateTime.now().subtract(const Duration(days: 10));
      final staleSub = await createCached('stale', lastAccessedAt: staleDate);
      final freshSub = await createCached(
        'fresh',
        lastAccessedAt: DateTime.now(),
      );

      await createEpisode(staleSub.id, 'stale-ep1');
      final freshEp = await createEpisode(freshSub.id, 'fresh-ep1');
      await createHistory(freshEp.id);

      service = PodcastCacheEvictionService(
        subscriptionRepository: subscriptionRepo,
        isar: isar,
        logger: logger,
      );

      await service.evict();

      final episodes = await isar.episodes
          .filter()
          .podcastIdEqualTo(freshSub.id)
          .findAll();
      expect(episodes, hasLength(1));
      final histories = await isar.playbackHistorys.where().findAll();
      expect(histories, hasLength(1));
    });

    test('uses subscribedAt when lastAccessedAt is null', () async {
      final sub = await subscriptionRepo.getOrCreateCached(
        itunesId: 'no-access',
        feedUrl: 'https://example.com/no-access/feed.xml',
        title: 'No Access Podcast',
        artistName: 'Artist',
      );
      await isar.writeTxn(() async {
        sub.subscribedAt = DateTime.now().subtract(const Duration(days: 10));
        sub.lastAccessedAt = null;
        await isar.subscriptions.put(sub);
      });

      service = PodcastCacheEvictionService(
        subscriptionRepository: subscriptionRepo,
        isar: isar,
        logger: logger,
      );

      final result = await service.evict();

      expect(result, 1);
    });
  });
}
