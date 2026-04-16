import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';

import '../../../../helpers/isar_test_helper.dart';

void main() {
  late Isar isar;
  late EpisodeLocalDatasource datasource;

  setUpAll(() async {
    await Isar.initializeIsarCore(download: true);
  });

  setUp(() async {
    isar = await openTestIsar([
      SubscriptionSchema,
      EpisodeSchema,
      DownloadTaskSchema,
    ]);
    datasource = EpisodeLocalDatasource(isar);

    // Insert a test subscription (no FK in Isar, but keeps data coherent)
    await isar.writeTxn(() async {
      await isar.subscriptions.put(
        Subscription()
          ..itunesId = 'itunes-1'
          ..feedUrl = 'https://example.com/feed.xml'
          ..title = 'Test Podcast'
          ..artistName = 'Test Artist'
          ..subscribedAt = DateTime.now(),
      );
    });
  });

  tearDown(() async {
    await isar.close(deleteFromDisk: true);
  });

  Episode makeEpisode({
    int podcastId = 1,
    required String guid,
    required String title,
    required String audioUrl,
    DateTime? publishedAt,
    int? episodeNumber,
  }) {
    return Episode()
      ..podcastId = podcastId
      ..guid = guid
      ..title = title
      ..audioUrl = audioUrl
      ..publishedAt = publishedAt
      ..episodeNumber = episodeNumber;
  }

  group('getGuidsByPodcastId', () {
    test('returns empty set for podcast with no episodes', () async {
      final guids = await datasource.getGuidsByPodcastId(999);
      expect(guids, isEmpty);
    });

    test('returns all GUIDs for podcast', () async {
      await datasource.upsert(
        makeEpisode(
          guid: 'guid-1',
          title: 'Episode 1',
          audioUrl: 'https://example.com/ep1.mp3',
        ),
      );
      await datasource.upsert(
        makeEpisode(
          guid: 'guid-2',
          title: 'Episode 2',
          audioUrl: 'https://example.com/ep2.mp3',
        ),
      );

      // Insert another subscription for isolation test
      await isar.writeTxn(() async {
        await isar.subscriptions.put(
          Subscription()
            ..itunesId = 'itunes-2'
            ..feedUrl = 'https://example.com/feed2.xml'
            ..title = 'Test Podcast 2'
            ..artistName = 'Test Artist 2'
            ..subscribedAt = DateTime.now(),
        );
      });
      await datasource.upsert(
        makeEpisode(
          podcastId: 2,
          guid: 'guid-3',
          title: 'Episode 3',
          audioUrl: 'https://example.com/ep3.mp3',
        ),
      );

      final guids = await datasource.getGuidsByPodcastId(1);

      expect(guids, hasLength(2));
      expect(guids, containsAll(['guid-1', 'guid-2']));
      expect(guids, isNot(contains('guid-3')));
    });
  });

  group('upsertAll', () {
    test('inserts multiple episodes in batch', () async {
      final episodes = [
        makeEpisode(
          guid: 'batch-1',
          title: 'Batch Episode 1',
          audioUrl: 'https://example.com/batch1.mp3',
        ),
        makeEpisode(
          guid: 'batch-2',
          title: 'Batch Episode 2',
          audioUrl: 'https://example.com/batch2.mp3',
        ),
      ];

      await datasource.upsertAll(episodes);

      final result = await datasource.getByPodcastId(1);
      expect(result, hasLength(2));
    });

    test('updates existing episodes on conflict', () async {
      await datasource.upsert(
        makeEpisode(
          guid: 'update-test',
          title: 'Original Title',
          audioUrl: 'https://example.com/update.mp3',
        ),
      );

      await datasource.upsertAll([
        makeEpisode(
          guid: 'update-test',
          title: 'Updated Title',
          audioUrl: 'https://example.com/update.mp3',
        ),
      ]);

      final episodes = await datasource.getByPodcastId(1);
      expect(episodes, hasLength(1));
      expect(episodes.first.title, 'Updated Title');
    });
  });

  group('upsert', () {
    test('returns inserted episode id', () async {
      final id = await datasource.upsert(
        makeEpisode(
          guid: 'guid-upsert',
          title: 'Upsert Episode',
          audioUrl: 'https://example.com/upsert.mp3',
        ),
      );

      expect(0 < id, isTrue);
    });

    test('inserts multiple distinct episodes', () async {
      await datasource.upsert(
        makeEpisode(
          guid: 'guid-a',
          title: 'Episode A',
          audioUrl: 'https://example.com/a.mp3',
        ),
      );
      await datasource.upsert(
        makeEpisode(
          guid: 'guid-b',
          title: 'Episode B',
          audioUrl: 'https://example.com/b.mp3',
        ),
      );

      final episodes = await datasource.getByPodcastId(1);
      expect(episodes, hasLength(2));
    });
  });

  group('getById', () {
    test('returns episode when exists', () async {
      final id = await datasource.upsert(
        makeEpisode(
          guid: 'guid-by-id',
          title: 'By ID Episode',
          audioUrl: 'https://example.com/byid.mp3',
        ),
      );

      final episode = await datasource.getById(id);

      expect(episode, isNotNull);
      expect(episode!.id, id);
      expect(episode.title, 'By ID Episode');
    });

    test('returns null when not found', () async {
      final episode = await datasource.getById(99999);
      expect(episode, isNull);
    });
  });

  group('getByPodcastIdAndGuid', () {
    test('returns matching episode', () async {
      await datasource.upsert(
        makeEpisode(
          guid: 'target-guid',
          title: 'Target Episode',
          audioUrl: 'https://example.com/target.mp3',
        ),
      );

      final episode = await datasource.getByPodcastIdAndGuid(1, 'target-guid');

      expect(episode, isNotNull);
      expect(episode!.guid, 'target-guid');
      expect(episode.title, 'Target Episode');
    });

    test('returns null for wrong podcast', () async {
      await datasource.upsert(
        makeEpisode(
          guid: 'some-guid',
          title: 'Episode',
          audioUrl: 'https://example.com/ep.mp3',
        ),
      );

      final episode = await datasource.getByPodcastIdAndGuid(999, 'some-guid');
      expect(episode, isNull);
    });

    test('returns null for wrong guid', () async {
      await datasource.upsert(
        makeEpisode(
          guid: 'real-guid',
          title: 'Episode',
          audioUrl: 'https://example.com/ep.mp3',
        ),
      );

      final episode = await datasource.getByPodcastIdAndGuid(1, 'wrong-guid');
      expect(episode, isNull);
    });
  });

  group('getByAudioUrl', () {
    test('returns episode matching audio URL', () async {
      await datasource.upsert(
        makeEpisode(
          guid: 'audio-url-guid',
          title: 'Audio URL Episode',
          audioUrl: 'https://example.com/specific.mp3',
        ),
      );

      final episode = await datasource.getByAudioUrl(
        'https://example.com/specific.mp3',
      );

      expect(episode, isNotNull);
      expect(episode!.audioUrl, 'https://example.com/specific.mp3');
    });

    test('returns null when no match', () async {
      final episode = await datasource.getByAudioUrl(
        'https://example.com/nonexistent.mp3',
      );
      expect(episode, isNull);
    });
  });

  group('getByPodcastId', () {
    test('returns episodes ordered by publishedAt descending', () async {
      await datasource.upsert(
        makeEpisode(
          guid: 'old',
          title: 'Oldest',
          audioUrl: 'https://example.com/old.mp3',
          publishedAt: DateTime(2024, 1, 1),
        ),
      );
      await datasource.upsert(
        makeEpisode(
          guid: 'new',
          title: 'Newest',
          audioUrl: 'https://example.com/new.mp3',
          publishedAt: DateTime(2024, 6, 1),
        ),
      );
      await datasource.upsert(
        makeEpisode(
          guid: 'mid',
          title: 'Middle',
          audioUrl: 'https://example.com/mid.mp3',
          publishedAt: DateTime(2024, 3, 1),
        ),
      );

      final episodes = await datasource.getByPodcastId(1);

      expect(episodes, hasLength(3));
      expect(episodes[0].title, 'Newest');
      expect(episodes[1].title, 'Middle');
      expect(episodes[2].title, 'Oldest');
    });
  });

  group('watchByPodcastId', () {
    test('emits initial data', () async {
      await datasource.upsert(
        makeEpisode(
          guid: 'watch-guid',
          title: 'Watch Episode',
          audioUrl: 'https://example.com/watch.mp3',
        ),
      );

      final result = await datasource.watchByPodcastId(1).first;
      expect(result, hasLength(1));
      expect(result.first.title, 'Watch Episode');
    });
  });

  group('deleteByPodcastId', () {
    test('deletes all episodes for a podcast', () async {
      await datasource.upsert(
        makeEpisode(
          guid: 'del-1',
          title: 'Delete Episode 1',
          audioUrl: 'https://example.com/del1.mp3',
        ),
      );
      await datasource.upsert(
        makeEpisode(
          guid: 'del-2',
          title: 'Delete Episode 2',
          audioUrl: 'https://example.com/del2.mp3',
        ),
      );

      final deleted = await datasource.deleteByPodcastId(1);
      expect(deleted, 2);

      final remaining = await datasource.getByPodcastId(1);
      expect(remaining, isEmpty);
    });

    test('returns 0 when no episodes exist', () async {
      final deleted = await datasource.deleteByPodcastId(999);
      expect(deleted, 0);
    });
  });

  group('deleteByPodcastIdAndGuids', () {
    test('deletes only matching guids for the podcast', () async {
      await datasource.upsert(
        makeEpisode(
          guid: 'keep',
          title: 'Keep',
          audioUrl: 'https://example.com/keep.mp3',
        ),
      );
      await datasource.upsert(
        makeEpisode(
          guid: 'drop-1',
          title: 'Drop 1',
          audioUrl: 'https://example.com/drop1.mp3',
        ),
      );
      await datasource.upsert(
        makeEpisode(
          guid: 'drop-2',
          title: 'Drop 2',
          audioUrl: 'https://example.com/drop2.mp3',
        ),
      );

      final deleted = await datasource.deleteByPodcastIdAndGuids(1, {
        'drop-1',
        'drop-2',
      });

      expect(deleted, 2);
      final remaining = await datasource.getByPodcastId(1);
      expect(remaining.map((e) => e.guid), ['keep']);
    });

    test('returns 0 without opening a txn when guids is empty', () async {
      await datasource.upsert(
        makeEpisode(
          guid: 'survivor',
          title: 'Survivor',
          audioUrl: 'https://example.com/survivor.mp3',
        ),
      );

      final deleted = await datasource.deleteByPodcastIdAndGuids(1, const {});

      expect(deleted, 0);
      final remaining = await datasource.getByPodcastId(1);
      expect(remaining, hasLength(1));
    });

    test(
      'does not delete episodes from a different podcast with the same guid',
      () async {
        await isar.writeTxn(() async {
          await isar.subscriptions.put(
            Subscription()
              ..itunesId = 'itunes-other'
              ..feedUrl = 'https://example.com/other.xml'
              ..title = 'Other'
              ..artistName = 'Other Artist'
              ..subscribedAt = DateTime.now(),
          );
        });

        await datasource.upsert(
          makeEpisode(
            podcastId: 1,
            guid: 'shared-guid',
            title: 'Pod 1',
            audioUrl: 'https://example.com/a.mp3',
          ),
        );
        await datasource.upsert(
          makeEpisode(
            podcastId: 2,
            guid: 'shared-guid',
            title: 'Pod 2',
            audioUrl: 'https://example.com/b.mp3',
          ),
        );

        final deleted = await datasource.deleteByPodcastIdAndGuids(1, {
          'shared-guid',
        });

        expect(deleted, 1);
        expect(await datasource.getByPodcastId(1), isEmpty);
        expect(await datasource.getByPodcastId(2), hasLength(1));
      },
    );
  });

  group('getByIds', () {
    test('returns empty list for empty ids', () async {
      final episodes = await datasource.getByIds([]);
      expect(episodes, isEmpty);
    });

    test('returns matching episodes', () async {
      final id1 = await datasource.upsert(
        makeEpisode(
          guid: 'ids-1',
          title: 'IDs Episode 1',
          audioUrl: 'https://example.com/ids1.mp3',
        ),
      );
      final id2 = await datasource.upsert(
        makeEpisode(
          guid: 'ids-2',
          title: 'IDs Episode 2',
          audioUrl: 'https://example.com/ids2.mp3',
        ),
      );
      // Insert a third that we will NOT query
      await datasource.upsert(
        makeEpisode(
          guid: 'ids-3',
          title: 'IDs Episode 3',
          audioUrl: 'https://example.com/ids3.mp3',
        ),
      );

      final episodes = await datasource.getByIds([id1, id2]);
      expect(episodes, hasLength(2));

      final ids = episodes.map((e) => e.id).toSet();
      expect(ids, containsAll([id1, id2]));
    });
  });

  group('getSubsequentEpisodes', () {
    test('returns episodes after given episode number', () async {
      for (var i = 1; i < 6; i++) {
        await datasource.upsert(
          makeEpisode(
            guid: 'sub-$i',
            title: 'Episode $i',
            audioUrl: 'https://example.com/sub$i.mp3',
            episodeNumber: i,
          ),
        );
      }

      final episodes = await datasource.getSubsequentEpisodes(
        podcastId: 1,
        afterEpisodeNumber: 2,
        limit: 10,
      );

      expect(episodes, hasLength(3));
      expect(episodes[0].episodeNumber, 3);
      expect(episodes[1].episodeNumber, 4);
      expect(episodes[2].episodeNumber, 5);
    });

    test('returns from beginning when afterEpisodeNumber is null', () async {
      for (var i = 1; i < 4; i++) {
        await datasource.upsert(
          makeEpisode(
            guid: 'from-start-$i',
            title: 'Episode $i',
            audioUrl: 'https://example.com/fs$i.mp3',
            episodeNumber: i,
          ),
        );
      }

      final episodes = await datasource.getSubsequentEpisodes(
        podcastId: 1,
        afterEpisodeNumber: null,
        limit: 10,
      );

      expect(episodes, hasLength(3));
      expect(episodes[0].episodeNumber, 1);
    });

    test('respects limit parameter', () async {
      for (var i = 1; i < 6; i++) {
        await datasource.upsert(
          makeEpisode(
            guid: 'limit-$i',
            title: 'Episode $i',
            audioUrl: 'https://example.com/limit$i.mp3',
            episodeNumber: i,
          ),
        );
      }

      final episodes = await datasource.getSubsequentEpisodes(
        podcastId: 1,
        afterEpisodeNumber: null,
        limit: 2,
      );

      expect(episodes, hasLength(2));
    });

    test('returns empty when no episodes match', () async {
      await datasource.upsert(
        makeEpisode(
          guid: 'no-match',
          title: 'Episode 1',
          audioUrl: 'https://example.com/nomatch.mp3',
          episodeNumber: 1,
        ),
      );

      final episodes = await datasource.getSubsequentEpisodes(
        podcastId: 1,
        afterEpisodeNumber: 100,
        limit: 10,
      );

      expect(episodes, isEmpty);
    });
  });
}
