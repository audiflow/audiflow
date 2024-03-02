import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:seasoning/entities/entities.dart';
import 'package:seasoning/repository/repository.dart';
import 'package:seasoning/repository/sembast/sembast_repository.dart';

import '../../test_common/riverpod.dart';
import '../mocks/mock_path_provider.dart';

void main() {
  late Repository persistenceService;

  final podcast1 = Podcast(
    guid: 'http://p1.com',
    collectionId: 123,
    feedUrl: 'http://p1.com',
    linkUrl: 'http://p1.com',
    title: 'Podcast 1',
    description: '1st podcast',
    copyright: '2021',
    thumbImageUrl: 'http://p1.com',
    imageUrl: 'http://p1.com',
    releaseDate: DateTime(2021),
    persons: [const Person(name: 'Person 1')],
  );

  final podcast2 = Podcast(
    guid: 'http://p2.com',
    collectionId: 456,
    feedUrl: 'http://p2.com',
    linkUrl: 'http://p2.com',
    title: 'Podcast 2',
    description: '2nd podcast',
    copyright: '2021',
    thumbImageUrl: 'http://p2.com',
    imageUrl: 'http://p2.com',
    releaseDate: DateTime(2021),
    persons: [const Person(name: 'Person 1')],
  );

  final numberFormat = NumberFormat('000');

  List<Episode> createEpisodeMocks(Podcast podcast, int count) {
    return Iterable<int>.generate(count)
        .map(
          (i) => Episode(
            guid: 'EP${numberFormat.format(i + 1)}',
            pguid: podcast.guid,
            title: 'Title ${i + 1}',
            description: 'desc ${i + 1}',
            contentUrl: 'http://example.com/episode${i + 1}.mp3',
            imageUrl: 'http://example.com/image.jpg',
            thumbImageUrl: 'http://example.com/thumb.jpg',
            publicationDate: DateTime.now().add(Duration(days: -i)),
            duration: const Duration(minutes: 30),
          ),
        )
        .toList();
  }

  final sembastRepositoryProvider = Provider(SembastRepository.new);

  void createRepository() {
    final container = createContainer();
    final mockPath = MockPathProvider();
    PathProviderPlatform.instance = mockPath;
    persistenceService = container.read(sembastRepositoryProvider);
  }

  Future<void> cleanUpRepository() async {
    await persistenceService.close();

    final f = File('${Directory.systemTemp.path}/seasoning.db');
    if (f.existsSync()) {
      f.deleteSync();
    }
  }

  group('PodcastPreview', () {
    setUpAll(createRepository);
    tearDownAll(cleanUpRepository);

    test('Fetch preview with non-existent GUID', () async {
      final actual = await persistenceService.findPodcastPreview('abc');
      expect(actual, null);
    });

    test('findPodcastPreview', () async {
      final value = podcast1.toJson()..remove('feedUrl');
      final podcast = Podcast.fromJson(value);

      await persistenceService.savePodcastPreview([podcast]);
    });

    test('findPodcastPreview', () async {
      final actual = await persistenceService.findPodcastPreview(podcast1.guid);
      expect(actual, isNotNull);
      expect(actual!.title, podcast1.title);
      expect(actual.feedUrl, isNull);
    });

    test('findPodcastPreview is null', () async {
      final actual = await persistenceService.findFeedUrl(podcast1.guid);
      expect(actual, isNull);
    });

    test('populate feedUrl', () async {
      await persistenceService.savePodcastPreview([podcast1]);
      final feedUrl = await persistenceService.findFeedUrl(podcast1.guid);
      expect(feedUrl, podcast1.feedUrl);

      final itemFull = PodcastSearchResultItem.fromPodcast(podcast2);
      expect(itemFull.feedUrl, isNotEmpty);

      final value = podcast1.toJson()..remove('feedUrl');
      final podcast = Podcast.fromJson(value);
      final itemPartial = PodcastSearchResultItem.fromPodcast(podcast);
      expect(itemPartial.feedUrl, isNull);

      final actual = await persistenceService.populatePodcastFeedUrl([
        itemPartial,
        itemFull,
        itemPartial,
      ]);
      expect(actual, hasLength(3));
      expect(actual[0].feedUrl, podcast1.feedUrl);
      expect(actual[1].feedUrl, podcast2.feedUrl);
      expect(actual[2].feedUrl, podcast1.feedUrl);
    });
  });

  group('Podcast', () {
    setUpAll(createRepository);
    tearDownAll(cleanUpRepository);

    test('Fetch podcast with non-existent GUID', () async {
      final actual = await persistenceService.findPodcast('abc');
      expect(actual, null);
    });

    late PodcastStats stats;

    test('subscribePodcast', () async {
      await persistenceService.subscribePodcast(podcast1);
      stats = (await persistenceService.findPodcastStats(podcast1.guid))!;
      expect(stats.subscribedDate, isNotNull);
    });

    test('findPodcast', () async {
      final loaded = await persistenceService.findPodcast(stats.guid);
      expect(loaded, podcast1);
    });

    test('subscriptions', () async {
      final loaded = await persistenceService.subscriptions();
      expect(loaded, hasLength(1));
      expect(loaded[0].$1.guid, stats.guid);
      expect(loaded[0].$2, stats);
    });

    test('savePodcastStats', () async {
      final updated = stats.copyWith(viewMode: PodcastDetailViewMode.seasons);
      await persistenceService.savePodcastStats(updated);
      final loaded = await persistenceService.findPodcastStats(stats.guid);
      expect(loaded, updated);
      expect(loaded == stats, isFalse);
      stats = updated;
    });

    test('savePodcast', () async {
      final updated = podcast1.copyWith(title: '${podcast1.title} updated');
      await persistenceService.savePodcast(updated);
      final loaded = await persistenceService.findPodcast(stats.guid);
      expect(loaded, updated);
    });

    test('unsubscribePodcast', () async {
      // Podcast remains.
      await persistenceService.unsubscribePodcast(podcast1);
      final podcast = await persistenceService.findPodcast(podcast1.guid);
      expect(podcast, isNotNull);

      // PodcastStats remains.
      final loaded = await persistenceService.findPodcastStats(stats.guid);
      expect(loaded?.guid, stats.guid);
      expect(loaded?.subscribed, isFalse);

      // deletePodcast twice should do nothing.
      await persistenceService.unsubscribePodcast(podcast1);
    });
  });

  group('Episode', () {
    setUpAll(createRepository);
    tearDownAll(cleanUpRepository);

    final podcast =
        podcast1.copyWith(episodes: createEpisodeMocks(podcast1, 3));
    late PodcastStats podcastStats;
    late EpisodeStats episodeStats;

    test('findEpisode with non-existence id', () async {
      final loaded = await persistenceService.findEpisode('abc');
      expect(loaded, null);
    });

    test('findEpisodeStats with non-existence id', () async {
      final loaded = await persistenceService.findEpisodeStats('abc');
      expect(loaded, null);
    });

    test('findEpisodesByPodcastGuid with non-existence id', () async {
      final loaded = await persistenceService.findEpisodesByPodcastGuid('abc');
      expect(loaded, isEmpty);
    });

    test('subscribePodcast', () async {
      await persistenceService.subscribePodcast(podcast);
      podcastStats = (await persistenceService.findPodcastStats(podcast.guid))!;
    });

    test('findEpisodesByPodcastGuid', () async {
      final loaded =
          await persistenceService.findEpisodesByPodcastGuid(podcast.guid);
      expect(loaded, hasLength(3));
    });

    test('findEpisode should return non-null but not stats', () async {
      final episode =
          await persistenceService.findEpisode(podcast.episodes[2].guid);
      expect(episode, podcast.episodes[2]);

      final stats =
          await persistenceService.findEpisodeStats(podcast.episodes[2].guid);
      expect(stats, isNull);
    });

    test('updateEpisodeStats', () async {
      final param = EpisodeStatsUpdateParam(
        guid: podcast.episodes[2].guid,
        playCount: 1,
      );
      episodeStats = await persistenceService.updateEpisodeStats(param);
      expect(episodeStats, isNotNull);
      expect(episodeStats.duration, podcast.episodes[2].duration);
      expect(episodeStats.playCount, 1);
    });

    test('findEpisodeStats', () async {
      final loaded =
          await persistenceService.findEpisodeStats(episodeStats.guid);
      expect(loaded, episodeStats);
    });

    test('updateEpisodeStats should update', () async {
      final param = EpisodeStatsUpdateParam(
        guid: podcast.episodes[2].guid,
        playTotal: const Duration(minutes: 33),
        completeCount: 2,
      );
      await persistenceService.updateEpisodeStats(param);

      final loaded =
          await persistenceService.findEpisodeStats(episodeStats.guid);
      expect(loaded == episodeStats, isFalse);
      expect(loaded?.playTotal, param.playTotal);
      expect(loaded?.completeCount, param.completeCount);
    });

    test('check updated field', () async {
      final loaded =
          await persistenceService.findEpisodeStats(episodeStats.guid);
      expect(loaded?.playTotal, const Duration(minutes: 33));
      episodeStats = loaded!;
    });

    test('updateEpisodeStatsList', () async {
      final params = [
        EpisodeStatsUpdateParam(
          guid: podcast.episodes[0].guid,
          playCount: 2,
        ),
        EpisodeStatsUpdateParam(
          guid: podcast.episodes[1].guid,
          playCount: 1,
        ),
      ];
      final result = await persistenceService.updateEpisodeStatsList(params);
      expect(result, hasLength(2));
      expect(result[0].guid, podcast.episodes[0].guid);
      expect(result[0].duration, podcast.episodes[0].duration);
      expect(result[1].playCount, 1);
    });

    test('check updated field(2)', () async {
      final loaded =
          await persistenceService.findEpisodeStats(podcast.episodes[1].guid);
      expect(loaded?.playCount, 1);
    });

    test('unsubscribePodcast', () async {
      await persistenceService.unsubscribePodcast(podcast1);
      final episodes =
          await persistenceService.findEpisodesByPodcastGuid(podcastStats.guid);
      expect(episodes, isEmpty);

      // EpisodeStats should still exist.
      final loaded =
          await persistenceService.findEpisodeStats(episodeStats.guid);
      expect(loaded, episodeStats);
    });
  });

  group('Player', () {
    setUpAll(createRepository);
    tearDownAll(cleanUpRepository);

    test('playingEpisodeGuid initial value', () async {
      final guid = await persistenceService.playingEpisodeGuid();
      expect(guid, isNull);
    });

    test('savePlayingEpisodeGuid', () async {
      await persistenceService.savePlayingEpisodeGuid('abc');
      final guid = await persistenceService.playingEpisodeGuid();
      expect(guid, 'abc');
    });
  });

  group('Queue', () {
    setUpAll(createRepository);
    tearDownAll(cleanUpRepository);

    test('empty', () async {
      final loaded = await persistenceService.loadQueue();
      expect(loaded.queue, isEmpty);

      await persistenceService.saveQueue(const Queue());
    });

    test('Create and save', () async {
      final episodes1 = createEpisodeMocks(podcast1, 3);
      final episodes2 = createEpisodeMocks(podcast2, 3);
      final queue = Queue(
        queue: [
          QueueItem.primary(episodes1[0].guid),
          QueueItem.adhoc(episodes2[0].guid),
        ],
      );
      await persistenceService.saveQueue(queue);

      final loaded = await persistenceService.loadQueue();
      expect(queue == loaded, isTrue);
    });
  });

  // group('Downloads', () {
  //   setUpAll(createRepository);
  //   tearDownAll(cleanUpRepository);
  //
  //   late List<Downloadable> saved;
  //
  //   test('findDownloads but empty', () async {
  //     final loaded = await persistenceService.findDownloads();
  //     expect(loaded, isEmpty);
  //   });
  //
  //   test('findDownloadsByPodcastGuid but empty', () async {
  //     final loaded =
  //         await persistenceService.findDownloadsByPodcastGuid(podcast1.guid);
  //     expect(loaded, isEmpty);
  //   });
  //
  //   test('Create and save', () async {
  //     final episodes = createEpisodeMocks(podcast1, 3);
  //     final list = episodes.map(
  //       (e) => Downloadable(
  //         pguid: e.pguid,
  //         guid: e.guid,
  //         url: e.contentUrl!,
  //         directory: 'dir',
  //         filename: '${e.guid}.mp3',
  //         taskId: 'TASK${e.guid}',
  //         state: e == episodes[0]
  //             ? DownloadState.none
  //             : e == episodes[1]
  //                 ? DownloadState.downloading
  //                 : DownloadState.downloaded,
  //         percentage: e == episodes[0]
  //             ? 0
  //             : e == episodes[1]
  //                 ? 99
  //                 : 100,
  //       ),
  //     );
  //     saved = await Future.wait(
  //       list.map((d) => persistenceService.saveDownload(d)),
  //     );
  //   });
  //
  //   test('findDownloads', () async {
  //     final loaded = await persistenceService.findDownloads();
  //     expect(loaded, hasLength(3));
  //   });
  //
  //   test('findDownloads', () async {
  //     var loaded =
  //         await persistenceService.findDownloadsByPodcastGuid(podcast1.guid);
  //     expect(loaded, hasLength(3));
  //
  //     loaded =
  //         await persistenceService.findDownloadsByPodcastGuid(podcast2.guid);
  //     expect(loaded, isEmpty);
  //   });
  //
  //   test('findDownloadByGuid', () async {
  //     final loaded =
  //         await persistenceService.findDownloadByGuid(saved[1].guid);
  //     expect(loaded, saved[1]);
  //   });
  //
  //   test('findDownloadByTaskId', () async {
  //     final loaded =
  //         await persistenceService.findDownloadByTaskId(saved[1].taskId);
  //     expect(loaded, saved[1]);
  //   });
  //
  //   test('deleteDownload', () async {
  //     await persistenceService.deleteDownload(saved[1]);
  //     final loaded =
  //         await persistenceService.findDownloadByGuid(saved[1].guid);
  //     expect(loaded, isNull);
  //   });
  // });
  //
  // group('Deletion', () {
  //   setUpAll(createRepository);
  //   tearDownAll(cleanUpRepository);
  //
  //   late Podcast podcast;
  //   late List<Episode> episodes;
  //   late List<Downloadable> downloads;
  //   late List<Transcript> transcripts;
  //
  //   test('Create 110 episodes, their downloads and transcripts', () async {
  //     podcast = await persistenceService.savePodcast(podcast1);
  //     episodes = await persistenceService.saveEpisodes(
  //       createEpisodeMocks(podcast1, 110),
  //     );
  //     downloads = await Future.wait(
  //       episodes.map(
  //         (e) => persistenceService.saveDownload(
  //           Downloadable(
  //             pguid: e.pguid,
  //             guid: e.guid,
  //             url: e.contentUrl!,
  //             directory: 'dir',
  //             filename: '${e.guid}.mp3',
  //             taskId: 'TASK${e.guid}',
  //             state: DownloadState.downloaded,
  //             percentage: 100,
  //           ),
  //         ),
  //       ),
  //     );
  //     transcripts = await Future.wait(
  //       episodes.map(
  //         (e) => persistenceService.saveTranscript(
  //           Transcript(
  //             pguid: e.pguid,
  //             guid: e.guid,
  //           ),
  //         ),
  //       ),
  //     );
  //   });
  //
  //   test('Delete episode', () async {
  //     await persistenceService.deleteEpisode(episodes[1]);
  //   });
  //
  //   test('Check existence of episode related objects', () async {
  //     final loaded = await persistenceService.findPodcastById(podcast.id!);
  //     expect(loaded, podcast);
  //
  //     final episode =
  //         await persistenceService.findEpisodeById(episodes[1].id!);
  //     expect(episode, isNull);
  //
  //     final download =
  //         await persistenceService.findDownloadByTaskId(downloads[1].taskId);
  //     expect(download, isNull);
  //
  //     final transcript =
  //         await persistenceService.findTranscriptById(transcripts[1].id!);
  //     expect(transcript, isNull);
  //   });
  //
  //   test('Delete podcast', () async {
  //     await persistenceService.deletePodcast(podcast);
  //   });
  //
  //   test('Check existence of related objects', () async {
  //     final loaded = await persistenceService.findPodcastById(podcast.id!);
  //     expect(loaded, isNull);
  //
  //     final episode =
  //         await persistenceService.findEpisodeById(episodes[0].id!);
  //     expect(episode, isNull);
  //
  //     final download =
  //         await persistenceService.findDownloadByGuid(downloads[0].guid);
  //     expect(download, isNull);
  //
  //     final transcript =
  //         await persistenceService.findTranscriptById(transcripts[0].id!);
  //     expect(transcript, isNull);
  //   });
  // });
}
