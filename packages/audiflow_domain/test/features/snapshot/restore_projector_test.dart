import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart' hide expect;
import 'package:isar_community/isar.dart';

import '../../helpers/isar_test_helper.dart';

void main() {
  late Isar isar;
  final now = DateTime.utc(2026, 11, 17, 12);
  final subscribedAt = DateTime.utc(2026, 3, 4);

  setUpAll(() async {
    await Isar.initializeIsarCore(download: true);
  });

  setUp(() async {
    isar = await openTestIsar(isarSchemas);
  });

  tearDown(() async {
    await isar.close(deleteFromDisk: true);
  });

  RestoreProjector projector([Isar? target]) =>
      RestoreProjector(target ?? isar);

  Future<void> put(Future<void> Function() body) => isar.writeTxn(body);

  PodcastUserState subscribedState(
    String key,
    String feedUrl, {
    String? itunesId,
  }) => PodcastUserState()
    ..podcastKey = key
    ..subscribed = true
    ..subscribedAt = subscribedAt
    ..feedUrl = feedUrl
    ..itunesId = itunesId
    ..autoDownload = true
    ..autoDownloadKeepCount = 4;

  Subscription subscription(
    String itunesId,
    String feedUrl, {
    String? podcastKey,
    bool isCached = false,
    String title = 'Local title',
  }) => Subscription()
    ..itunesId = itunesId
    ..feedUrl = feedUrl
    ..podcastKey = podcastKey
    ..title = title
    ..artistName = 'Local artist'
    ..subscribedAt = DateTime.utc(2025)
    ..isCached = isCached;

  Episode episode(int podcastId, String guid, String? key) => Episode()
    ..podcastId = podcastId
    ..guid = guid
    ..episodeKey = key
    ..title = guid
    ..audioUrl = 'https://example.com/$guid.mp3';

  // Every field the projection writes, so two runs can be compared.
  Future<List<String>> describeAll([Isar? target]) async {
    final db = target ?? isar;
    final subs = await db.subscriptions.where().findAll();
    final stations = await db.stations.where().findAll();
    final links = await db.stationPodcasts.where().findAll();
    final items = await db.queueItems.where().findAll();
    return [
      for (final s in subs)
        'sub ${s.id} ${s.itunesId} ${s.feedUrl} ${s.podcastKey} ${s.title} '
            '${s.artistName} ${s.artworkUrl} ${s.subscribedAt} ${s.isCached} '
            '${s.autoDownload} ${s.autoDownloadKeepCount}',
      for (final s in stations)
        'station ${s.id} ${s.stationId} ${s.name} ${s.sortOrder} '
            '${s.episodeSortType} ${s.hideCompleted} ${s.filterDownloaded} '
            '${s.filterFavorited} ${s.durationFilter?.durationOperator} '
            '${s.durationFilter?.durationMinutes} ${s.publishedWithinDays} '
            '${s.defaultEpisodeLimit} ${s.groupByPodcast} ${s.podcastSortType} '
            '${s.createdAt} ${s.updatedAt} ${s.lastPlayedAt}',
      for (final l in links)
        'link ${l.id} ${l.stationId} ${l.podcastId} ${l.addedAt} '
            '${l.episodeLimit} ${l.sortOrder}',
      for (final q in items)
        'queue ${q.id} ${q.episodeId} ${q.position} ${q.entryId} '
            '${q.isAdhoc} ${q.sourceContext} ${q.addedAt}',
    ];
  }

  group('projectLibrary subscriptions', () {
    test(
      'inserts a missing subscription with info and the key verbatim',
      () async {
        await put(
          () => isar.podcastUserStates.putAll([
            subscribedState(
              'guid:abc',
              'https://a.example/feed',
              itunesId: '42',
            ),
            subscribedState('url:b', 'https://b.example/feed'),
          ]),
        );

        final result = await projector().projectLibrary(
          podcastInfo: {
            'guid:abc': const SnapshotPodcastInfo(
              title: 'Show A',
              artistName: 'Artist A',
              artworkUrl: 'https://a.example/art.jpg',
            ),
          },
          now: now,
        );

        final a = (await isar.subscriptions.getByItunesId('42'))!;
        check(a.podcastKey).equals('guid:abc');
        check(a.feedUrl).equals('https://a.example/feed');
        check(a.title).equals('Show A');
        check(a.artistName).equals('Artist A');
        check(a.artworkUrl).equals('https://a.example/art.jpg');
        check(a.subscribedAt.isAtSameMomentAs(subscribedAt)).isTrue();
        check(a.isCached).isFalse();
        check(a.autoDownload).isTrue();
        check(a.autoDownloadKeepCount).equals(4);

        final b = (await isar.subscriptions.getByItunesId(
          feedPlaceholderId('https://b.example/feed'),
        ))!;
        check(b.podcastKey).equals('url:b');
        check(b.title).equals('https://b.example/feed');
        check(b.artistName).equals('');
        check(b.artworkUrl).isNull();

        check(
          result.feedUrls,
        ).unorderedEquals(['https://a.example/feed', 'https://b.example/feed']);
      },
    );

    test('uses now when the state has no subscribedAt', () async {
      await put(
        () => isar.podcastUserStates.put(
          subscribedState('k', 'https://a.example/feed')..subscribedAt = null,
        ),
      );

      await projector().projectLibrary(podcastInfo: const {}, now: now);

      final sub = (await isar.subscriptions.where().findFirst())!;
      check(sub.subscribedAt.isAtSameMomentAs(now)).isTrue();
    });

    test('moves a keyed row to the merged feed url', () async {
      await put(() async {
        await isar.subscriptions.put(
          subscription('7', 'https://old.example/feed')
            ..podcastKey = 'k'
            ..httpEtag = 'old-etag'
            ..httpLastModified = 'yesterday',
        );
        await isar.podcastUserStates.put(
          subscribedState('k', 'https://new.example/feed'),
        );
      });

      final result = await projector().projectLibrary(
        podcastInfo: const {},
        now: now,
      );

      final sub = (await isar.subscriptions.where().findFirst())!;
      check(sub.feedUrl).equals('https://new.example/feed');
      check(sub.httpEtag).isNull();
      check(sub.httpLastModified).isNull();
      check(result.feedUrls).deepEquals(['https://new.example/feed']);
    });

    test('promotes a cached row found by feed url and keys it', () async {
      await put(() async {
        await isar.subscriptions.put(
          subscription('7', 'https://a.example/feed', isCached: true),
        );
        await isar.podcastUserStates.put(
          subscribedState('guid:abc', 'https://a.example/feed'),
        );
      });

      await projector().projectLibrary(
        podcastInfo: {'guid:abc': const SnapshotPodcastInfo(title: 'Backup')},
        now: now,
      );

      final subs = await isar.subscriptions.where().findAll();
      check(subs).length.equals(1);
      final sub = subs.single;
      check(sub.isCached).isFalse();
      check(sub.podcastKey).equals('guid:abc');
      check(sub.title).equals('Local title');
      check(sub.autoDownload).isTrue();
      check(sub.autoDownloadKeepCount).equals(4);
    });

    test('finds an unkeyed row by itunes id', () async {
      await put(() async {
        await isar.subscriptions.put(
          subscription('42', 'https://old.example/feed', isCached: true),
        );
        await isar.podcastUserStates.put(
          subscribedState('k', 'https://new.example/feed', itunesId: '42'),
        );
      });

      await projector().projectLibrary(podcastInfo: const {}, now: now);

      final subs = await isar.subscriptions.where().findAll();
      check(subs).length.equals(1);
      check(subs.single.podcastKey).equals('k');
      check(subs.single.isCached).isFalse();
    });

    test('demotes a subscribed row the merge unsubscribed', () async {
      await put(() async {
        await isar.subscriptions.put(
          subscription('1', 'https://a.example/feed', podcastKey: 'k'),
        );
        await isar.podcastUserStates.put(
          subscribedState('k', 'https://a.example/feed')
            ..subscribed = false
            ..subscribedHlc = Hlc(1700000000000, 0).packed,
        );
      });

      final result = await projector().projectLibrary(
        podcastInfo: const {},
        now: now,
      );

      final sub = (await isar.subscriptions.getByItunesId('1'))!;
      check(sub.isCached).isTrue();
      check(result.feedUrls).isEmpty();
    });

    test('keeps a subscribed row when no unsubscribe arrived', () async {
      await put(() async {
        await isar.subscriptions.put(
          subscription('1', 'https://a.example/feed', podcastKey: 'k'),
        );
        // Only another section of this podcast came with the backup.
        await isar.podcastUserStates.put(PodcastUserState()..podcastKey = 'k');
      });

      await projector().projectLibrary(podcastInfo: const {}, now: now);

      check((await isar.subscriptions.getByItunesId('1'))!.isCached).isFalse();
    });

    test('a second run changes nothing', () async {
      await put(() async {
        await isar.subscriptions.put(
          subscription('7', 'https://a.example/feed', isCached: true),
        );
        await isar.podcastUserStates.putAll([
          subscribedState('guid:abc', 'https://a.example/feed'),
          subscribedState('url:b', 'https://b.example/feed'),
        ]);
      });

      await projector().projectLibrary(podcastInfo: const {}, now: now);
      final first = await describeAll();
      await projector().projectLibrary(
        podcastInfo: const {},
        now: now.add(const Duration(days: 1)),
      );

      check(await describeAll()).deepEquals(first);
    });
  });

  group('projectLibrary stations', () {
    Future<void> seedStations() => put(() async {
      await isar.podcastUserStates.putAll([
        subscribedState('k1', 'https://one.example/feed'),
        subscribedState('k2', 'https://two.example/feed'),
      ]);
      await isar.stationStates.putAll([
        StationState()
          ..stationId = 's1'
          ..name = 'Morning'
          ..sortOrder = 2
          ..episodeSortType = 'oldest'
          ..hideCompleted = true
          ..filterDownloaded = true
          ..filterFavorited = true
          ..durationOperator = 'longerThan'
          ..durationMinutes = 45
          ..publishedWithinDays = 7
          ..defaultEpisodeLimit = 5
          ..groupByPodcast = true
          ..podcastSortType = 'alphabetical'
          ..lastPlayedAt = DateTime.utc(2026, 5)
          ..createdAt = DateTime.utc(2026, 1),
        StationState()
          ..stationId = 'gone'
          ..name = 'Gone'
          ..deleted = true,
      ]);
      await isar.stationMembers.putAll([
        StationMember()
          ..stationId = 's1'
          ..podcastKey = 'k1'
          ..episodeLimit = 2
          ..sortOrder = 1
          ..addedAt = DateTime.utc(2026, 2),
        StationMember()
          ..stationId = 's1'
          ..podcastKey = 'k2'
          ..deleted = true,
        // No subscription carries this key: skipped.
        StationMember()
          ..stationId = 's1'
          ..podcastKey = 'unknown',
      ]);
    });

    test('upserts stations with every shared field', () async {
      await seedStations();

      final result = await projector().projectLibrary(
        podcastInfo: const {},
        now: now,
      );

      final station = (await isar.stations
          .filter()
          .stationIdEqualTo('s1')
          .findFirst())!;
      check(result.stationIds).deepEquals([station.id]);
      check(station.name).equals('Morning');
      check(station.sortOrder).equals(2);
      check(station.episodeSortType).equals('oldest');
      check(station.hideCompleted).isTrue();
      check(station.filterDownloaded).isTrue();
      check(station.filterFavorited).isTrue();
      check(station.durationFilter).isNotNull()
        ..has((d) => d.durationOperator, 'operator').equals('longerThan')
        ..has((d) => d.durationMinutes, 'minutes').equals(45);
      check(station.publishedWithinDays).equals(7);
      check(station.defaultEpisodeLimit).equals(5);
      check(station.groupByPodcast).isTrue();
      check(station.podcastSortType).equals('alphabetical');
      check(
        station.lastPlayedAt!.isAtSameMomentAs(DateTime.utc(2026, 5)),
      ).isTrue();
      check(station.createdAt.isAtSameMomentAs(DateTime.utc(2026, 1))).isTrue();
      check(station.updatedAt.isAtSameMomentAs(now)).isTrue();
      check(
        await isar.stations.filter().stationIdEqualTo('gone').count(),
      ).equals(0);
    });

    test('clears the duration filter when the state has none', () async {
      await put(() async {
        await isar.stations.put(
          Station()
            ..stationId = 's1'
            ..name = 'Old'
            ..durationFilter = (StationDurationFilter()..durationMinutes = 10)
            ..createdAt = DateTime.utc(2025)
            ..updatedAt = DateTime.utc(2025),
        );
        await isar.stationStates.put(
          StationState()
            ..stationId = 's1'
            ..name = 'New',
        );
      });

      await projector().projectLibrary(podcastInfo: const {}, now: now);

      final station = (await isar.stations.where().findFirst())!;
      check(station.name).equals('New');
      check(station.durationFilter).isNull();
      check(station.createdAt.isAtSameMomentAs(DateTime.utc(2025))).isTrue();
    });

    test('links live members and removes the rest', () async {
      await seedStations();
      // Links the restore must remove: k2's member is a tombstone.
      await put(() async {
        final station = Station()
          ..stationId = 's1'
          ..name = 'Local'
          ..createdAt = DateTime.utc(2025)
          ..updatedAt = DateTime.utc(2025);
        await isar.stations.put(station);
        final two = subscription(
          '2',
          'https://two.example/feed',
          podcastKey: 'k2',
        );
        await isar.subscriptions.put(two);
        await isar.stationPodcasts.put(
          StationPodcast()
            ..stationId = station.id
            ..podcastId = two.id
            ..addedAt = DateTime.utc(2025),
        );
      });

      await projector().projectLibrary(podcastInfo: const {}, now: now);

      final station = (await isar.stations
          .filter()
          .stationIdEqualTo('s1')
          .findFirst())!;
      final one = (await isar.subscriptions
          .filter()
          .podcastKeyEqualTo('k1')
          .findFirst())!;
      final links = await isar.stationPodcasts.where().findAll();
      check(links).length.equals(1);
      final link = links.single;
      check(link.stationId).equals(station.id);
      check(link.podcastId).equals(one.id);
      check(link.episodeLimit).equals(2);
      check(link.sortOrder).equals(1);
      check(link.addedAt.isAtSameMomentAs(DateTime.utc(2026, 2))).isTrue();
    });

    test('removes a deleted station and its links and episodes', () async {
      await put(() async {
        final station = Station()
          ..stationId = 'gone'
          ..name = 'Gone'
          ..createdAt = DateTime.utc(2025)
          ..updatedAt = DateTime.utc(2025);
        await isar.stations.put(station);
        await isar.stationPodcasts.put(
          StationPodcast()
            ..stationId = station.id
            ..podcastId = 99
            ..addedAt = DateTime.utc(2025),
        );
        await isar.stationEpisodes.put(
          StationEpisode()
            ..stationId = station.id
            ..episodeId = 5,
        );
        await isar.stationStates.put(
          StationState()
            ..stationId = 'gone'
            ..deleted = true,
        );
      });

      final result = await projector().projectLibrary(
        podcastInfo: const {},
        now: now,
      );

      check(await isar.stations.count()).equals(0);
      check(await isar.stationPodcasts.count()).equals(0);
      check(await isar.stationEpisodes.count()).equals(0);
      check(result.stationIds).isEmpty();
    });

    test('keeps links of podcasts without a key', () async {
      await put(() async {
        final station = Station()
          ..stationId = 's1'
          ..name = 'Local'
          ..createdAt = DateTime.utc(2025)
          ..updatedAt = DateTime.utc(2025);
        await isar.stations.put(station);
        final unkeyed = subscription('3', 'https://three.example/feed');
        await isar.subscriptions.put(unkeyed);
        await isar.stationPodcasts.put(
          StationPodcast()
            ..stationId = station.id
            ..podcastId = unkeyed.id
            ..addedAt = DateTime.utc(2025),
        );
        await isar.stationStates.put(StationState()..stationId = 's1');
      });

      await projector().projectLibrary(podcastInfo: const {}, now: now);

      check(await isar.stationPodcasts.count()).equals(1);
    });

    test('a second run changes nothing', () async {
      await seedStations();

      await projector().projectLibrary(podcastInfo: const {}, now: now);
      final first = await describeAll();
      await projector().projectLibrary(
        podcastInfo: const {},
        now: now.add(const Duration(days: 1)),
      );

      check(await describeAll()).deepEquals(first);
    });
  });

  group('projectQueue', () {
    late int podcastId;

    Future<void> seedQueue() => put(() async {
      final sub = subscription('1', 'https://a.example/feed', podcastKey: 'pk');
      await isar.subscriptions.put(sub);
      podcastId = sub.id;
      await isar.episodes.putAll([
        episode(podcastId, 'e1', 'ek1'),
        episode(podcastId, 'e2', 'ek2'),
        episode(podcastId, 'e3', 'ek3'),
      ]);
      await isar.queueEntrys.putAll([
        QueueEntry()
          ..entryId = 'q-b'
          ..episodeKey = 'ek2'
          ..rank = rankForPosition(1)
          ..isAdhoc = true
          ..sourceContext = 'playlist:x'
          ..addedAt = DateTime.utc(2026, 2),
        QueueEntry()
          ..entryId = 'q-a'
          ..episodeKey = 'ek1'
          ..rank = rankForPosition(0)
          ..addedAt = DateTime.utc(2026),
        QueueEntry()
          ..entryId = 'q-late'
          ..episodeKey = 'ek-not-fetched'
          ..rank = rankForPosition(2)
          ..addedAt = DateTime.utc(2026, 3),
        QueueEntry()
          ..entryId = 'q-gone'
          ..episodeKey = 'ek3'
          ..rank = rankForPosition(3)
          ..deleted = true,
      ]);
    });

    Future<int> episodeId(String key) async =>
        (await isar.episodes.filter().episodeKeyEqualTo(key).findFirst())!.id;

    test('orders by rank, drops tombstones, keeps local leftovers', () async {
      await seedQueue();
      final e3 = await episodeId('ek3');
      await put(
        () => isar.queueItems.putAll([
          QueueItem()
            ..episodeId = e3
            ..position = 0
            ..entryId = 'q-gone'
            ..addedAt = DateTime.utc(2025),
          // Not tied to an entry; stays after the projected ones.
          QueueItem()
            ..episodeId = e3
            ..position = 1
            ..addedAt = DateTime.utc(2025),
        ]),
      );

      await projector().projectQueue();

      final items = await isar.queueItems.where().sortByPosition().findAll();
      check(items.map((i) => i.entryId)).deepEquals(['q-a', 'q-b', null]);
      check(items.map((i) => i.position)).deepEquals([0, 1, 2]);
      check(items[0].episodeId).equals(await episodeId('ek1'));
      check(items[1])
        ..has((i) => i.episodeId, 'episodeId').equals(await episodeId('ek2'))
        ..has((i) => i.isAdhoc, 'isAdhoc').isTrue()
        ..has((i) => i.sourceContext, 'sourceContext').equals('playlist:x')
        ..has(
          (i) => i.addedAt.isAtSameMomentAs(DateTime.utc(2026, 2)),
          'addedAt',
        ).isTrue();
      check(items[2].episodeId).equals(e3);
    });

    test('picks up an entry once its episode arrives', () async {
      await seedQueue();
      await projector().projectQueue();
      check(await isar.queueItems.count()).equals(2);

      await put(
        () => isar.episodes.put(episode(podcastId, 'late', 'ek-not-fetched')),
      );
      await projector().projectQueue();

      final items = await isar.queueItems.where().sortByPosition().findAll();
      check(items.map((i) => i.entryId)).deepEquals(['q-a', 'q-b', 'q-late']);
      check(items.map((i) => i.position)).deepEquals([0, 1, 2]);
    });

    test('leaves a retry for entries it skipped', () async {
      await seedQueue();
      await put(() => isar.syncMetas.put(SyncMeta()..historyId = 'h'));

      check(await projector().projectQueue()).equals(1);
      check(
        (await isar.syncMetas.get(
          SyncMeta.singletonId,
        ))!.queueProjectionPending,
      ).isTrue();

      await put(
        () => isar.episodes.put(episode(podcastId, 'late', 'ek-not-fetched')),
      );
      await projector().projectQueueIfPending();

      check(await isar.queueItems.count()).equals(3);
      check(
        (await isar.syncMetas.get(
          SyncMeta.singletonId,
        ))!.queueProjectionPending,
      ).isFalse();
    });

    test('a library projection leaves the queue step pending', () async {
      // A queue step that throws or never runs (app killed during the
      // feed refetch) is then retried by the next feed sync.
      await seedQueue();
      await put(() => isar.syncMetas.put(SyncMeta()..historyId = 'h'));

      await projector().projectLibrary(podcastInfo: const {});
      check(
        (await isar.syncMetas.get(
          SyncMeta.singletonId,
        ))!.queueProjectionPending,
      ).isTrue();

      await projector().projectQueueIfPending();
      check(await isar.queueItems.count()).equals(2);
    });

    test('does nothing more when no retry is pending', () async {
      await seedQueue();
      await put(() => isar.syncMetas.put(SyncMeta()..historyId = 'h'));

      await projector().projectQueueIfPending();

      check(await isar.queueItems.count()).equals(0);
    });

    test('keeps positions in the ranks\' number space', () async {
      await put(() async {
        // The projection resolves episodes by key alone.
        await isar.episodes.putAll([
          episode(1, 'x', 'ekx'),
          episode(1, 'y', 'eky'),
        ]);
        await isar.queueEntrys.putAll([
          QueueEntry()
            ..entryId = 'q-x'
            ..episodeKey = 'ekx'
            ..rank = rankForPosition(10)
            ..addedAt = DateTime.utc(2026),
          QueueEntry()
            ..entryId = 'q-y'
            ..episodeKey = 'eky'
            ..rank = rankForPosition(20)
            ..addedAt = DateTime.utc(2026),
        ]);
      });

      await projector().projectQueue();

      final items = await isar.queueItems.where().sortByPosition().findAll();
      check(items.map((i) => i.position)).deepEquals([10, 20]);
    });

    test('breaks equal ranks by entry id', () async {
      await seedQueue();
      await put(
        () => isar.queueEntrys.put(
          (QueueEntry()
            ..entryId = 'q-0'
            ..episodeKey = 'ek3'
            ..rank = rankForPosition(1)
            ..addedAt = DateTime.utc(2026)),
        ),
      );

      await projector().projectQueue();

      final items = await isar.queueItems.where().sortByPosition().findAll();
      check(items.map((i) => i.entryId)).deepEquals(['q-a', 'q-0', 'q-b']);
    });

    test('a second run changes nothing', () async {
      await seedQueue();

      await projector().projectQueue();
      final first = await describeAll();
      await projector().projectQueue();

      check(await describeAll()).deepEquals(first);
    });
  });

  test('restores a backup end to end', () async {
    final source = await openTestIsar(isarSchemas);
    addTearDown(() => source.close(deleteFromDisk: true));
    await source.writeTxn(() async {
      final hlc = Hlc(1700000000000, 0).packed;
      await source.subscriptions.put(
        subscription(
          '42',
          'https://a.example/feed',
          podcastKey: 'guid:abc',
          title: 'Show A',
        )..artworkUrl = 'https://a.example/art.jpg',
      );
      await source.podcastUserStates.put(
        subscribedState('guid:abc', 'https://a.example/feed', itunesId: '42')
          ..subscribedHlc = hlc
          ..feedUrlHlc = hlc
          ..itunesIdHlc = hlc
          ..autoDownloadHlc = hlc
          ..autoDownloadKeepCountHlc = hlc,
      );
      await source.stationStates.put(
        StationState()
          ..stationId = 's1'
          ..name = 'Morning'
          ..nameHlc = hlc
          ..durationOperator = 'shorterThan'
          ..durationMinutes = 20
          ..durationFilterHlc = hlc
          ..createdAt = DateTime.utc(2026),
      );
      await source.stationMembers.put(
        StationMember()
          ..stationId = 's1'
          ..podcastKey = 'guid:abc'
          ..episodeLimit = 3
          ..episodeLimitHlc = hlc
          ..addedAt = DateTime.utc(2026, 2),
      );
      await source.queueEntrys.putAll([
        QueueEntry()
          ..entryId = 'q2'
          ..episodeKey = 'ek2'
          ..rank = rankForPosition(1)
          ..rankHlc = hlc
          ..addedAt = DateTime.utc(2026, 4),
        QueueEntry()
          ..entryId = 'q1'
          ..episodeKey = 'ek1'
          ..rank = rankForPosition(0)
          ..rankHlc = hlc
          ..isAdhoc = true
          ..isAdhocHlc = hlc
          ..addedAt = DateTime.utc(2026, 3),
      ]);
    });

    final backup = await buildBackupFile(
      source,
      now: now,
      appVersion: '2.3.0',
      platform: 'ios',
    );
    final merge = await SnapshotMerger(
      isar,
      nowMillis: () => now.millisecondsSinceEpoch,
    ).merge(readSnapshotFile(backup.bytes));

    final library = await projector().projectLibrary(
      podcastInfo: merge.podcastInfo,
      now: now,
    );
    check(library.feedUrls).deepEquals(['https://a.example/feed']);

    // The feed fetch keys the episodes.
    final sub = (await isar.subscriptions.getByItunesId('42'))!;
    await put(
      () => isar.episodes.putAll([
        episode(sub.id, 'g1', 'ek1'),
        episode(sub.id, 'g2', 'ek2'),
      ]),
    );
    await projector().projectQueue();

    check(sub)
      ..has((s) => s.podcastKey, 'podcastKey').equals('guid:abc')
      ..has((s) => s.title, 'title').equals('Show A')
      ..has(
        (s) => s.artworkUrl,
        'artworkUrl',
      ).equals('https://a.example/art.jpg')
      ..has((s) => s.isCached, 'isCached').isFalse()
      ..has((s) => s.autoDownloadKeepCount, 'keep').equals(4);
    final station = (await isar.stations.where().findFirst())!;
    check(library.stationIds).deepEquals([station.id]);
    check(station.stationId).equals('s1');
    check(station.name).equals('Morning');
    check(station.durationFilter?.durationMinutes).equals(20);
    final link = (await isar.stationPodcasts.where().findFirst())!;
    check(link.stationId).equals(station.id);
    check(link.podcastId).equals(sub.id);
    check(link.episodeLimit).equals(3);
    final items = await isar.queueItems.where().sortByPosition().findAll();
    check(items.map((i) => i.entryId)).deepEquals(['q1', 'q2']);
    check(items.first.isAdhoc).isTrue();

    // Restoring the same backup again changes nothing.
    final before = await describeAll();
    await SnapshotMerger(
      isar,
      nowMillis: () => now.millisecondsSinceEpoch,
    ).merge(readSnapshotFile(backup.bytes));
    await projector().projectLibrary(podcastInfo: merge.podcastInfo, now: now);
    await projector().projectQueue();
    check(await describeAll()).deepEquals(before);
  });
}
