// Copyright (c) 2024 by HANAI, Tohru.
// Copyright (c) 2024 Reedom, Inc.
// Additional contributions from project contributors.
// All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:audiflow/entities/entities.dart';
import 'package:audiflow/repository/isar_repository.dart';
import 'package:audiflow/repository/repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';

import '../../test_common/riverpod.dart';
import '../mocks/mock_path_provider.dart';

void main() {
  final mockPath = MockPathProvider();
  PathProviderPlatform.instance = mockPath;

  late Repository repository;

  final podcast1 = Podcast(
    feedUrl: 'https://p1.com',
    collectionId: 123,
    title: 'Podcast 1',
    description: '1st podcast',
    language: 'en',
    category: 'Technology',
    subcategory: 'Software How-To',
    explicit: false,
    image: 'https://p1.com',
    guid: 'https://p1.com',
    link: 'https://p1.com',
    copyright: '2021',
  );

  final podcast2 = Podcast(
    feedUrl: 'https://p2.com',
    collectionId: 234,
    title: 'Podcast 2',
    description: '2nd podcast',
    language: 'en',
    category: 'Technology',
    subcategory: 'Software How-To',
    explicit: false,
    image: 'https://p2.com',
    guid: 'https://p2.com',
    link: 'https://p2.com',
    copyright: '2021',
  );

  final numberFormat = NumberFormat('000');
  List<Episode> createEpisodeMocks(Podcast podcast, int count) {
    return Iterable<int>.generate(count)
        .map(
          (i) => Episode(
            pid: podcast.id,
            guid: 'EP${numberFormat.format(i + 1)}',
            title: 'Title ${i + 1}',
            description: 'desc ${i + 1}',
            imageUrl: 'https://example.com/image.jpg',
            publicationDate: DateTime.now().add(Duration(days: -i)),
            durationMS: const Duration(minutes: 30).inMilliseconds,
          ),
        )
        .toList();
  }

  final repositoryProvider = Provider((ref) => IsarRepository());

  Future<void> createRepository() async {
    final container = createContainer();
    repository = container.read(repositoryProvider);
    await (repository as IsarRepository).ensureInitialized();
    final isar = (repository as IsarRepository).isar;
  }

  Future<void> cleanUpRepository() async {
    await (repository as IsarRepository).isar.close(deleteFromDisk: true);
  }

  group('Podcast', () {
    setUpAll(createRepository);
    tearDownAll(cleanUpRepository);

    test('findPodcast', () async {
      final actual = await repository.findPodcast(id: podcast1.id);
      expect(actual, isNull);
    });

    late PodcastStats stats;

    test('subscribePodcast', () async {
      await repository.subscribePodcast(podcast1);
      // Also it records the podcast.
      final podcast = await repository.findPodcast(id: podcast1.id);
      expect(podcast, isNotNull);

      stats = (await repository.findPodcastStats(podcast1.id))!;
      expect(stats.subscribedDate, isNotNull);
    });

    test('subscriptions', () async {
      final podcasts = await repository.subscriptions();
      expect(podcasts, hasLength(1));
    });

    test('unsubscribePodcast', () async {
      // Podcast remains.
      await repository.unsubscribePodcast(podcast1);
      final podcast = await repository.findPodcast(id: podcast1.id);
      expect(podcast, isNotNull);

      // PodcastStats remains.
      stats = (await repository.findPodcastStats(podcast1.id))!;
      expect(stats.subscribedDate, isNull);
    });
  });

  group('Episode', () {
    setUpAll(createRepository);
    tearDownAll(cleanUpRepository);

    final episodes = createEpisodeMocks(podcast2, 3);
    late PodcastStats podcastStats;
    late EpisodeStats episodeStats;

    test('findEpisode with non-existence id', () async {
      final loaded = await repository.findEpisode(podcast2.id);
      expect(loaded, isNull);
    });

    test('findEpisodeStats with non-existence id', () async {
      final loaded = await repository.findEpisodeStats(episodes[0].id);
      expect(loaded, null);
    });

    test('findEpisodesByPodcastGuid with non-existence id', () async {
      final loaded = await repository.findEpisodesByPodcastId(podcast2.id);
      expect(loaded, isEmpty);
    });

    test('subscribePodcast', () async {
      await repository.subscribePodcast(podcast2);
      await repository.saveEpisodes(episodes);
      podcastStats = (await repository.findPodcastStats(podcast2.id))!;
    });

    test('findEpisodesByPodcastId', () async {
      final loaded = await repository.findEpisodesByPodcastId(podcast2.id);
      expect(loaded, hasLength(3));
    });

    test('findEpisode should return non-null but not stats', () async {
      final episode = await repository.findEpisode(episodes[2].id);
      expect(episode?.title, episodes[2].title);

      final stats = await repository.findEpisodeStats(episodes[2].id);
      expect(stats, isNull);
    });

    test('updateEpisodeStats', () async {
      final param = EpisodeStatsUpdateParam(
        id: episodes[2].id,
        pid: podcast2.id,
        played: true,
      );
      episodeStats = await repository.updateEpisodeStats(param);
      expect(episodeStats, isNotNull);
      expect(episodeStats.played, true);
    });

    test('findEpisodeStats', () async {
      final loaded = await repository.findEpisodeStats(episodeStats.id);
      expect(loaded?.played, isTrue);
    });

    test('updateEpisodeStats should update', () async {
      final param = EpisodeStatsUpdateParam(
        pid: episodes[2].pid,
        id: episodes[2].id,
        playTotalDelta: const Duration(minutes: 33),
        completed: true,
      );
      await repository.updateEpisodeStats(param);

      final loaded = await repository.findEpisodeStats(episodes[2].id);
      expect(loaded == episodeStats, isFalse);
      expect(loaded?.playTotal, param.playTotalDelta);
      expect(loaded?.completeCount, 1);
    });

    test('check updated field', () async {
      final loaded = await repository.findEpisodeStats(episodeStats.id);
      expect(loaded?.playTotal, const Duration(minutes: 33));
      episodeStats = loaded!;
    });

    test('updateEpisodeStatsList', () async {
      final params = [
        EpisodeStatsUpdateParam(
          id: episodes[0].id,
          pid: episodes[0].pid,
        ),
        EpisodeStatsUpdateParam(
          id: episodes[1].id,
          pid: episodes[1].pid,
          played: true,
        ),
      ];
      final result = await repository.updateEpisodeStatsList(params);
      expect(result, hasLength(2));
      expect(result[0].id, episodes[0].id);
      expect(result[1].played, isTrue);
    });

    test('check updated field(2)', () async {
      final loaded = await repository.findEpisodeStats(episodes[1].id);
      expect(loaded?.played, isTrue);
    });

    test('unsubscribePodcast', () async {
      await repository.unsubscribePodcast(podcast2);
      final episodes =
          await repository.findEpisodesByPodcastId(podcastStats.id);
      expect(episodes, isNotEmpty);

      // EpisodeStats should still exist.
      final loaded = await repository.findEpisodeStats(episodeStats.id);
      expect(loaded?.played, isTrue);
    });
  });
}
