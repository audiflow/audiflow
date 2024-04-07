// Copyright (c) 2024 by HANAI, Tohru.
// Copyright (c) 2024 Reedom, Inc.
// Additional contributions from project contributors.
// All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:io';

import 'package:audiflow/entities/entities.dart';
import 'package:audiflow/repository/isar_repository.dart';
import 'package:audiflow/repository/repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';

import '../../test_common/riverpod.dart';
import '../mocks/mock_path_provider.dart';

void main() {
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
    final mockPath = MockPathProvider();
    PathProviderPlatform.instance = mockPath;
    repository = container.read(repositoryProvider);
    await (repository as IsarRepository).ensureInitialized();
  }

  Future<void> cleanUpRepository() async {
    await repository.close();
    final dir = await getApplicationDocumentsDirectory();
    final isar = await Isar.open(
      [
        BlockSchema,
        EpisodeSchema,
        EpisodeStatsSchema,
        FundingSchema,
        LockedSchema,
        PersonSchema,
        PodcastSchema,
        PodcastStatsSchema,
        PodcastViewStatsSchema,
        TranscriptUrlSchema,
        ValueSchema,
        ValueRecipientSchema,
      ],
      directory: dir.path,
    );
    await isar.close(deleteFromDisk: true);
  }

  group('Podcast', () {
    setUpAll(createRepository);
    tearDownAll(cleanUpRepository);

    test('findPodcast', () async {
      final actual = await repository.findPodcast(pid: podcast1.id);
      expect(actual, isNull);
    });

    late PodcastStats stats;

    test('subscribePodcast', () async {
      await repository.subscribePodcast(podcast1);
      // Also it records the podcast.
      final podcast = await repository.findPodcast(pid: podcast1.id);
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
      final podcast = await repository.findPodcast(pid: podcast1.id);
      expect(podcast, isNotNull);

      // PodcastStats remains.
      stats = (await repository.findPodcastStats(podcast1.id))!;
      expect(stats.subscribedDate, isNull);
    });
  });
}
