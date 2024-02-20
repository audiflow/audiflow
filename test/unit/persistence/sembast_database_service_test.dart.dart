import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:seasoning/entities/entities.dart';
import 'package:seasoning/repository/repository.dart';
import 'package:seasoning/repository/sembast/sembast_repository.dart';

import '../mocks/mock_path_provider.dart';

void main() {
  MockPathProvder mockPath;
  Repository? persistenceService;

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
  );

  setUp(() async {
    mockPath = MockPathProvder();
    PathProviderPlatform.instance = mockPath;
  });

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

  void createRepository() {
    persistenceService = SembastRepository(cleanup: false);
  }

  Future<void> cleanUpRepository() async {
    await persistenceService!.close();
    persistenceService = null;

    final f = File('${Directory.systemTemp.path}/seasoning.db');
    if (f.existsSync()) {
      f.deleteSync();
    }
  }

  /// Test the creation and retrieval of podcasts both with and without
  /// episodes. Ensure that data fetched is equal to the data originally
  /// stored.
  group('Podcast', () {
    setUpAll(createRepository);
    tearDownAll(cleanUpRepository);

    test('Fetch podcast with non-existent ID', () async {
      final actual = await persistenceService!.findPodcastById(123);
      expect(actual, null);
    });

    late PodcastStats stats;

    test('subscribePodcast', () async {
      stats = await persistenceService!.subscribePodcast(podcast1);
      expect(stats.id, greaterThan(0));
      expect(stats.guid, podcast1.guid);
      expect(stats.subscribedDate, isNotNull);
    });

    test('findPodcastById', () async {
      final loaded = await persistenceService!.findPodcastById(stats.id);
      expect(loaded, podcast1);
    });

    test('findPodcastByGuid', () async {
      final loaded = await persistenceService!.findPodcastByGuid(stats.guid);
      expect(loaded.$1, stats.id);
      expect(loaded.$2, podcast1);
    });

    test('findPodcastStatsById', () async {
      final loaded = await persistenceService!.findPodcastStatsById(stats.id);
      expect(loaded, stats);
    });

    test('findPodcastStatsByGuid', () async {
      final loaded =
          await persistenceService!.findPodcastStatsByGuid(stats.guid);
      expect(loaded, stats);
    });

    test('subscriptions', () async {
      final loaded = await persistenceService!.subscriptions();
      expect(loaded, hasLength(1));
      expect(loaded[0].$1, stats);
      expect(loaded[0].$2.guid, stats.guid);
    });

    test('savePodcastStats', () async {
      final updated = stats.copyWith(playTotal: const Duration(minutes: 30));
      await persistenceService!.savePodcastStats(updated);
      final loaded = await persistenceService!.findPodcastStatsById(stats.id);
      expect(loaded, updated);
      expect(loaded == stats, isFalse);
      stats = updated;
    });

    test('savePodcast', () async {
      final updated = podcast1.copyWith(title: '${podcast1.title} updated');
      await persistenceService!.savePodcast(stats.id, updated);
      final loaded = await persistenceService!.findPodcastById(stats.id);
      expect(loaded, updated);
    });

    test('unsubscribePodcast', () async {
      await persistenceService!.unsubscribePodcast(podcast1);
      final podcast = await persistenceService!.findPodcastById(stats.id);
      expect(podcast, isNull);

      // PodcastStats should still exist.
      final loaded = await persistenceService!.findPodcastStatsById(stats.id);
      expect(loaded?.guid, stats.guid);
      expect(loaded?.subscribed, isFalse);

      // deletePodcast twice should do nothing.
      await persistenceService!.unsubscribePodcast(podcast1);
    });
  });

  group('Episode', () {
    setUpAll(createRepository);
    tearDownAll(cleanUpRepository);

    final podcast =
        podcast1.copyWith(episodes: createEpisodeMocks(podcast1, 3));
    late PodcastStats podcastStats;
    late EpisodeStats episodeStats;

    test('findEpisodeById with non-existence id', () async {
      final loaded = await persistenceService!.findEpisodeById(1);
      expect(loaded, isNull);
    });

    test('findEpisodeStatsByGuid with non-existence id', () async {
      final loaded = await persistenceService!.findEpisodeByGuid('abc');
      expect(loaded, (null, null));
    });

    test('findEpisodesByPodcastGuid with non-existence id', () async {
      final loaded = await persistenceService!.findEpisodeStatsById(1);
      expect(loaded, isNull);
    });

    test('findEpisodesByPodcastGuid with non-existence id', () async {
      final loaded =
          await persistenceService!.findEpisodeStatsByGuid(podcast.guid);
      expect(loaded, isNull);
    });

    test('findEpisodesByPodcastGuid with non-existence id', () async {
      final loaded = await persistenceService!.findEpisodesByPodcastGuid('abc');
      expect(loaded, isEmpty);
    });

    test('subscribePodcast', () async {
      podcastStats = await persistenceService!.subscribePodcast(podcast);
      expect(podcastStats.id, greaterThan(0));
    });

    test('findPodcastById', () async {
      final loaded = await persistenceService!.findPodcastById(podcastStats.id);
      expect(loaded?.episodes, hasLength(3));
    });

    test('findEpisodesByPodcastGuid', () async {
      final loaded =
          await persistenceService!.findEpisodesByPodcastGuid(podcast.guid);
      expect(loaded, hasLength(3));
    });

    test('findEpisodeStatsById should be non-null but not stats', () async {
      final episode = await persistenceService!.findEpisodeById(3);
      expect(episode, podcast.episodes[2]);

      final stats = await persistenceService!.findEpisodeStatsById(3);
      expect(stats, isNull);
    });

    test('createEpisodeStats should assign id of the companion episode',
        () async {
      episodeStats =
          await persistenceService!.createEpisodeStats(podcast.episodes[2]);
      expect(episodeStats.id, 3);
    });

    test('findEpisodeStatsById', () async {
      final loaded =
          await persistenceService!.findEpisodeStatsById(episodeStats.id);
      expect(loaded, episodeStats);
    });

    test('findEpisodeStatsById', () async {
      final loaded =
          await persistenceService!.findEpisodeStatsByGuid(episodeStats.guid);
      expect(loaded, episodeStats);
    });

    test('createEpisodeStats should assign id of the companion episode',
        () async {
      final newStats =
          episodeStats.copyWith(playTotal: const Duration(minutes: 30));
      await persistenceService!.saveEpisodeStats(newStats);

      final loaded =
          await persistenceService!.findEpisodeStatsById(newStats.id);
      expect(loaded, newStats);
    });

    test('check updated field', () async {
      final loaded =
          await persistenceService!.findEpisodeStatsByGuid(episodeStats.guid);
      expect(loaded?.playTotal, const Duration(minutes: 30));
      episodeStats = loaded!;
    });

    test('unsubscribePodcast', () async {
      await persistenceService!.unsubscribePodcast(podcast1);
      final episodes = await persistenceService!
          .findEpisodesByPodcastGuid(podcastStats.guid);
      expect(episodes, isEmpty);

      // EpisodeStats should still exist.
      final loaded =
          await persistenceService!.findEpisodeStatsById(episodeStats.id);
      expect(loaded, episodeStats);
    });
  });

  group('Player', () {
    setUpAll(createRepository);
    tearDownAll(cleanUpRepository);

    test('playingEpisodeGuid initial value', () async {
      final guid = await persistenceService!.playingEpisodeGuid();
      expect(guid, isNull);
    });

    test('savePlayingEpisodeGuid', () async {
      await persistenceService!.savePlayingEpisodeGuid('abc');
      final guid = await persistenceService!.playingEpisodeGuid();
      expect(guid, 'abc');
    });
  });

  // group('Queue', () {
  //   setUpAll(createRepository);
  //   tearDownAll(cleanUpRepository);
  //
  //   late List<Episode> saved1;
  //   late List<Episode> saved2;
  //
  //   test('empty', () async {
  //     final loaded = await persistenceService!.loadQueue();
  //     expect(loaded, isEmpty);
  //   });
  //
  //   test('Create and save', () async {
  //     final episodes1 = createEpisodeMocks(podcast1, 3);
  //     final episodes2 = createEpisodeMocks(podcast2, 3);
  //     saved1 = await persistenceService!.saveEpisodes(episodes1);
  //     saved2 = await persistenceService!.saveEpisodes(episodes2);
  //
  //     final queue = [...saved1, ...saved2];
  //     await persistenceService!.saveQueue(queue);
  //
  //     final loaded = await persistenceService!.loadQueue();
  //     expect(listEquals(queue, loaded), isTrue);
  //   });
  //
  // group('Downloads', () {
  //   setUpAll(createRepository);
  //   tearDownAll(cleanUpRepository);
  //
  //   late List<Downloadable> saved;
  //
  //   test('findDownloads but empty', () async {
  //     final loaded = await persistenceService!.findDownloads();
  //     expect(loaded, isEmpty);
  //   });
  //
  //   test('findDownloadsByPodcastGuid but empty', () async {
  //     final loaded =
  //         await persistenceService!.findDownloadsByPodcastGuid(podcast1.guid);
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
  //       list.map((d) => persistenceService!.saveDownload(d)),
  //     );
  //   });
  //
  //   test('findDownloads', () async {
  //     final loaded = await persistenceService!.findDownloads();
  //     expect(loaded, hasLength(3));
  //   });
  //
  //   test('findDownloads', () async {
  //     var loaded =
  //         await persistenceService!.findDownloadsByPodcastGuid(podcast1.guid);
  //     expect(loaded, hasLength(3));
  //
  //     loaded =
  //         await persistenceService!.findDownloadsByPodcastGuid(podcast2.guid);
  //     expect(loaded, isEmpty);
  //   });
  //
  //   test('findDownloadByGuid', () async {
  //     final loaded =
  //         await persistenceService!.findDownloadByGuid(saved[1].guid);
  //     expect(loaded, saved[1]);
  //   });
  //
  //   test('findDownloadByTaskId', () async {
  //     final loaded =
  //         await persistenceService!.findDownloadByTaskId(saved[1].taskId);
  //     expect(loaded, saved[1]);
  //   });
  //
  //   test('deleteDownload', () async {
  //     await persistenceService!.deleteDownload(saved[1]);
  //     final loaded =
  //         await persistenceService!.findDownloadByGuid(saved[1].guid);
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
  //     podcast = await persistenceService!.savePodcast(podcast1);
  //     episodes = await persistenceService!.saveEpisodes(
  //       createEpisodeMocks(podcast1, 110),
  //     );
  //     downloads = await Future.wait(
  //       episodes.map(
  //         (e) => persistenceService!.saveDownload(
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
  //         (e) => persistenceService!.saveTranscript(
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
  //     await persistenceService!.deleteEpisode(episodes[1]);
  //   });
  //
  //   test('Check existence of episode related objects', () async {
  //     final loaded = await persistenceService!.findPodcastById(podcast.id!);
  //     expect(loaded, podcast);
  //
  //     final episode =
  //         await persistenceService!.findEpisodeById(episodes[1].id!);
  //     expect(episode, isNull);
  //
  //     final download =
  //         await persistenceService!.findDownloadByTaskId(downloads[1].taskId);
  //     expect(download, isNull);
  //
  //     final transcript =
  //         await persistenceService!.findTranscriptById(transcripts[1].id!);
  //     expect(transcript, isNull);
  //   });
  //
  //   test('Delete podcast', () async {
  //     await persistenceService!.deletePodcast(podcast);
  //   });
  //
  //   test('Check existence of related objects', () async {
  //     final loaded = await persistenceService!.findPodcastById(podcast.id!);
  //     expect(loaded, isNull);
  //
  //     final episode =
  //         await persistenceService!.findEpisodeById(episodes[0].id!);
  //     expect(episode, isNull);
  //
  //     final download =
  //         await persistenceService!.findDownloadByGuid(downloads[0].guid);
  //     expect(download, isNull);
  //
  //     final transcript =
  //         await persistenceService!.findTranscriptById(transcripts[0].id!);
  //     expect(transcript, isNull);
  //   });
  // });
}
