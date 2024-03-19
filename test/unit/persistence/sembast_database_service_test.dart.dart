// Copyright (c) 2024 by HANAI, Tohru.
// Copyright (c) 2024 Reedom, Inc.
// Additional contributions from project contributors.
// All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:io';

import 'package:audiflow/entities/entities.dart';
import 'package:audiflow/repository/repository.dart';
import 'package:audiflow/repository/sembast/sembast_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';

import '../../test_common/riverpod.dart';
import '../mocks/mock_path_provider.dart';

void main() {
  late Repository repository;

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

  final sembastRepositoryProvider =
      Provider((ref) => SembastRepository(ref, databaseName: 'test.db'));

  void createRepository() {
    final container = createContainer();
    final mockPath = MockPathProvider();
    PathProviderPlatform.instance = mockPath;
    repository = container.read(sembastRepositoryProvider);
  }

  Future<void> cleanUpRepository() async {
    await repository.close();

    final f = File('${Directory.systemTemp.path}/test.db');
    if (f.existsSync()) {
      f.deleteSync();
    }
  }

  group('PodcastMetadata', () {
    setUpAll(createRepository);
    tearDownAll(cleanUpRepository);

    test('findPodcastMetadata', () async {
      final podcast = podcast1.copyWith(feedUrl: null);
      final metadata = podcast.metadata;
      await repository.savePodcast(metadata.toPartialPodcast());
    });

    test('findPodcastMetadata', () async {
      final actual = await repository.findPodcastMetadata(podcast1.guid);
      expect(actual, isNotNull);
      expect(actual!.title, podcast1.title);
      expect(actual.feedUrl, isNull);
    });

    test('findPodcast', () async {
      final actual = await repository.findPodcast(podcast1.guid);
      expect(actual, isNotNull);
      expect(actual!.title, podcast1.title);
      expect(actual.feedUrl, isNull);
      expect(actual.metadataOnly, isTrue);
    });

    test('findFeedUrl is null', () async {
      final actual = await repository.findFeedUrl(podcast1.guid);
      expect(actual, isNull);
    });

    test('populate feedUrl', () async {
      await repository.savePodcast(podcast1);

      final value = podcast1.toJson()..remove('feedUrl');
      final itemPartial = Podcast.fromJson(value);

      final actual = await repository.populatePodcastFeedUrl([
        PodcastMetadata.fromPodcast(podcast1),
        PodcastMetadata.fromPodcast(podcast2),
        PodcastMetadata.fromPodcast(itemPartial),
      ]);
      expect(actual, hasLength(3));
      expect(actual[0].feedUrl, podcast1.feedUrl);
      expect(actual[1].feedUrl, podcast2.feedUrl);
      expect(actual[2].feedUrl, podcast1.feedUrl);
    });

    test('metadata cannot overwrite full podcast', () async {
      final itemPartial =
          PodcastMetadata.fromPodcast(podcast1).toPartialPodcast();
      await repository.savePodcast(itemPartial);

      final actual = await repository.findPodcast(podcast1.guid);
      expect(actual!.metadataOnly, isFalse);
      await repository.savePodcast(actual);
    });
  });

  group('Podcast', () {
    setUpAll(createRepository);
    tearDownAll(cleanUpRepository);

    test('Fetch podcast with non-existent GUID', () async {
      final actual = await repository.findPodcast('abc');
      expect(actual, null);
    });

    late PodcastStats stats;

    test('subscribePodcast', () async {
      await repository.subscribePodcast(podcast1);
      stats = (await repository.findPodcastStats(podcast1.guid))!;
      expect(stats.subscribedDate, isNotNull);
    });

    test('findPodcastMetadata', () async {
      final loaded = await repository.findPodcastMetadata(stats.guid);
      expect(loaded, PodcastMetadata.fromPodcast(podcast1));
    });

    test('subscriptions', () async {
      final loaded = await repository.subscriptions();
      expect(loaded, hasLength(1));
      expect(loaded[0].$1.guid, stats.guid);
      expect(loaded[0].$2, stats);
    });

    test('savePodcast', () async {
      final updated = podcast1.copyWith(title: '${podcast1.title} updated');
      await repository.savePodcast(updated);
      final loaded = await repository.findPodcastMetadata(stats.guid);
      expect(loaded, PodcastMetadata.fromPodcast(updated));
    });

    test('unsubscribePodcast', () async {
      // Podcast remains.
      await repository.unsubscribePodcast(podcast1);
      final podcast = await repository.findPodcast(podcast1.guid);
      expect(podcast, isNotNull);

      // PodcastStats remains.
      final loaded = await repository.findPodcastStats(stats.guid);
      expect(loaded?.guid, stats.guid);
      expect(loaded?.subscribed, isFalse);

      // deletePodcast twice should do nothing.
      await repository.unsubscribePodcast(podcast1);
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
      final loaded = await repository.findEpisode('abc');
      expect(loaded, null);
    });

    test('findEpisodeStats with non-existence id', () async {
      final loaded = await repository.findEpisodeStats('abc');
      expect(loaded, null);
    });

    test('findEpisodesByPodcastGuid with non-existence id', () async {
      final loaded = await repository.findEpisodesByPodcastGuid('abc');
      expect(loaded, isEmpty);
    });

    test('subscribePodcast', () async {
      await repository.subscribePodcast(podcast);
      podcastStats = (await repository.findPodcastStats(podcast.guid))!;
    });

    test('findEpisodesByPodcastGuid', () async {
      final loaded = await repository.findEpisodesByPodcastGuid(podcast.guid);
      expect(loaded, hasLength(3));
    });

    test('findEpisode should return non-null but not stats', () async {
      final episode = await repository.findEpisode(podcast.episodes[2].guid);
      expect(episode, podcast.episodes[2]);

      final stats = await repository.findEpisodeStats(podcast.episodes[2].guid);
      expect(stats, isNull);
    });

    test('updateEpisodeStats', () async {
      final param = EpisodeStatsUpdateParam(
        pguid: podcast.episodes[2].pguid,
        guid: podcast.episodes[2].guid,
        played: true,
      );
      episodeStats = await repository.updateEpisodeStats(param);
      expect(episodeStats, isNotNull);
      expect(episodeStats.played, true);
    });

    test('findEpisodeStats', () async {
      final loaded = await repository.findEpisodeStats(episodeStats.guid);
      expect(loaded, episodeStats);
    });

    test('updateEpisodeStats should update', () async {
      final param = EpisodeStatsUpdateParam(
        pguid: podcast.episodes[2].pguid,
        guid: podcast.episodes[2].guid,
        playTotalDelta: const Duration(minutes: 33),
        completeCountDelta: 2,
      );
      await repository.updateEpisodeStats(param);

      final loaded = await repository.findEpisodeStats(episodeStats.guid);
      expect(loaded == episodeStats, isFalse);
      expect(loaded?.playTotal, param.playTotalDelta);
      expect(loaded?.completeCount, param.completeCountDelta);
    });

    test('check updated field', () async {
      final loaded = await repository.findEpisodeStats(episodeStats.guid);
      expect(loaded?.playTotal, const Duration(minutes: 33));
      episodeStats = loaded!;
    });

    test('updateEpisodeStatsList', () async {
      final params = [
        EpisodeStatsUpdateParam(
          pguid: podcast.episodes[0].pguid,
          guid: podcast.episodes[0].guid,
        ),
        EpisodeStatsUpdateParam(
          pguid: podcast.episodes[1].pguid,
          guid: podcast.episodes[1].guid,
          played: true,
        ),
      ];
      final result = await repository.updateEpisodeStatsList(params);
      expect(result, hasLength(2));
      expect(result[0].guid, podcast.episodes[0].guid);
      expect(result[1].played, isTrue);
    });

    test('check updated field(2)', () async {
      final loaded =
          await repository.findEpisodeStats(podcast.episodes[1].guid);
      expect(loaded?.played, isTrue);
    });

    test('unsubscribePodcast', () async {
      await repository.unsubscribePodcast(podcast1);
      final episodes =
          await repository.findEpisodesByPodcastGuid(podcastStats.guid);
      expect(episodes, isNotEmpty);

      // EpisodeStats should still exist.
      final loaded = await repository.findEpisodeStats(episodeStats.guid);
      expect(loaded, episodeStats);
    });
  });

  group('RecentlyPlayed', () {
    setUpAll(createRepository);
    tearDownAll(cleanUpRepository);

    var tm = DateTime.parse('2020-01-01');
    DateTime generateTime() {
      return tm = tm.add(const Duration(minutes: 1));
    }

    Future<void> addEntry(int n) async {
      final param = EpisodeStatsUpdateParam(
        pguid: 'p$n',
        guid: 'g$n',
        played: true,
      );
      await repository.updateEpisodeStats(param);
      await repository.saveRecentlyPlayedEpisode(
        EpisodeMetadata(
          guid: 'g$n',
          pguid: 'p$n',
          title: '',
          imageUrl: '',
          thumbImageUrl: '',
          duration: Duration.zero,
          publicationDate: tm,
          contentUrl: '',
        ).toPartialEpisode(),
        playedAt: generateTime(),
      );
    }

    test('empty', () async {
      final (statsList, cursor) =
          await repository.findRecentlyPlayedEpisodeList();
      expect(statsList, isEmpty);
      expect(cursor, isNull);
    });

    test('create on entry', () async {
      await addEntry(1);
      final (statsList, cursor) =
          await repository.findRecentlyPlayedEpisodeList();
      expect(statsList, hasLength(1));
      expect(cursor, isNull);
    });

    test('cursor', () async {
      // Add g2...g6 entries.
      await Future.wait(List.generate(5, (index) => addEntry(index + 2)));
      // Add g2, this should removed the previous g2 entry.
      await addEntry(2);

      var (statsList, cursor) =
          await repository.findRecentlyPlayedEpisodeList(limit: 3);
      expect(statsList.map((s) => s.guid), ['g2', 'g6', 'g5']);
      expect(cursor, isNotNull);

      (statsList, cursor) = await repository.findRecentlyPlayedEpisodeList(
        limit: 3,
        cursor: cursor,
      );
      expect(statsList.map((s) => s.guid), ['g4', 'g3']);
      expect(cursor, isNotNull);

      (statsList, cursor) = await repository.findRecentlyPlayedEpisodeList(
        limit: 3,
        cursor: cursor,
      );
      expect(statsList.map((s) => s.guid), ['g1']);
      expect(cursor, isNull);
    });
  });

  group('Player', () {
    setUpAll(createRepository);
    tearDownAll(cleanUpRepository);

    test('playingEpisodeGuid initial value', () async {
      final guid = await repository.playingEpisodeGuid();
      expect(guid, isNull);
    });

    test('savePlayingEpisodeGuid', () async {
      await repository.savePlayingEpisodeGuid('abc');
      final guid = await repository.playingEpisodeGuid();
      expect(guid, 'abc');
    });
  });

  group('Queue', () {
    setUpAll(createRepository);
    tearDownAll(cleanUpRepository);

    test('empty', () async {
      final loaded = await repository.loadQueue();
      expect(loaded.queue, isEmpty);

      await repository.saveQueue(const Queue());
    });

    test('Create and save', () async {
      final episodes1 = createEpisodeMocks(podcast1, 3);
      final episodes2 = createEpisodeMocks(podcast2, 3);
      final queue = Queue(
        queue: [
          QueueItem.primary(pguid: episodes1[0].pguid, guid: episodes1[0].guid),
          QueueItem.adhoc(pguid: episodes2[0].pguid, guid: episodes2[0].guid),
        ],
      );
      await repository.saveQueue(queue);

      final loaded = await repository.loadQueue();
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
