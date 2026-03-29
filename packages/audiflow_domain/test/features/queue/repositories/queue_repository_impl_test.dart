import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';

import '../../../helpers/isar_test_helper.dart';

void main() {
  late Isar isar;
  late QueueRepositoryImpl repository;

  setUpAll(() async {
    await Isar.initializeIsarCore(download: true);
  });

  setUp(() async {
    isar = await openTestIsar([
      SubscriptionSchema,
      EpisodeSchema,
      QueueItemSchema,
    ]);
    final queueDatasource = QueueLocalDatasource(isar);
    final episodeDatasource = EpisodeLocalDatasource(isar);
    final subscriptionDatasource = SubscriptionLocalDatasource(isar);
    repository = QueueRepositoryImpl(
      queueDatasource: queueDatasource,
      episodeDatasource: episodeDatasource,
      subscriptionDatasource: subscriptionDatasource,
    );

    // Create subscription and episodes
    await isar.writeTxn(() async {
      await isar.subscriptions.put(
        Subscription()
          ..itunesId = 'test-itunes-id'
          ..feedUrl = 'https://example.com/feed.xml'
          ..title = 'Test Podcast'
          ..artistName = 'Test Artist'
          ..subscribedAt = DateTime.now(),
      );

      for (var i = 1; i < 5; i++) {
        await isar.episodes.put(
          Episode()
            ..podcastId = 1
            ..guid = 'ep-$i'
            ..title = 'Episode $i'
            ..audioUrl = 'https://example.com/ep$i.mp3',
        );
      }
    });
  });

  tearDown(() async {
    await isar.close(deleteFromDisk: true);
  });

  group('addToEnd', () {
    test('adds item to empty queue', () async {
      final item = await repository.addToEnd(1);

      expect(item.episodeId, 1);
      expect(item.isAdhoc, false);
    });

    test('adds item after existing items', () async {
      await repository.addToEnd(1);
      await repository.addToEnd(2);

      final queue = await repository.getQueue();

      expect(queue.manualItems, hasLength(2));
      expect(queue.manualItems.first.episode.id, 1);
      expect(queue.manualItems.last.episode.id, 2);
    });
  });

  group('addToFront', () {
    test('adds item to front of empty queue', () async {
      final item = await repository.addToFront(1);

      expect(item.episodeId, 1);
      expect(item.isAdhoc, false);
    });

    test('adds item before existing items', () async {
      await repository.addToEnd(1);
      await repository.addToFront(2);

      final queue = await repository.getQueue();
      final episodes = queue.manualItems.map((i) => i.episode.id).toList();

      expect(episodes.first, 2);
      expect(episodes.last, 1);
    });
  });

  group('replaceWithAdhoc', () {
    test('replaces queue with adhoc items', () async {
      await repository.addToEnd(1);
      await repository.replaceWithAdhoc(
        episodeIds: [2, 3],
        sourceContext: 'Season 1',
      );

      final queue = await repository.getQueue();

      expect(queue.manualItems, isEmpty);
      expect(queue.adhocItems, hasLength(2));
      expect(queue.adhocSourceContext, 'Season 1');
    });

    test('maintains order of episode IDs', () async {
      await repository.replaceWithAdhoc(
        episodeIds: [3, 1, 2],
        sourceContext: 'Custom Order',
      );

      final queue = await repository.getQueue();
      final episodeIds = queue.adhocItems.map((i) => i.episode.id).toList();

      expect(episodeIds, [3, 1, 2]);
    });
  });

  group('remove', () {
    test('removes item from queue', () async {
      final item = await repository.addToEnd(1);
      await repository.addToEnd(2);

      await repository.remove(item.id);

      final queue = await repository.getQueue();
      expect(queue.manualItems, hasLength(1));
      expect(queue.manualItems.first.episode.id, 2);
    });
  });

  group('removeFirst', () {
    test('does nothing on empty queue', () async {
      await repository.removeFirst();

      final queue = await repository.getQueue();
      expect(queue.totalCount, 0);
    });

    test('removes first manual item when available', () async {
      await repository.addToEnd(1);
      await repository.addToEnd(2);

      await repository.removeFirst();

      final queue = await repository.getQueue();
      expect(queue.manualItems, hasLength(1));
      expect(queue.manualItems.first.episode.id, 2);
    });

    test('removes first adhoc item when no manual items', () async {
      await repository.replaceWithAdhoc(
        episodeIds: [1, 2],
        sourceContext: 'Test',
      );

      await repository.removeFirst();

      final queue = await repository.getQueue();
      expect(queue.adhocItems, hasLength(1));
      expect(queue.adhocItems.first.episode.id, 2);
    });
  });

  group('clearAll', () {
    test('removes all items from queue', () async {
      await repository.addToEnd(1);
      await repository.addToEnd(2);

      await repository.clearAll();

      final queue = await repository.getQueue();
      expect(queue.totalCount, 0);
    });
  });

  group('reorder', () {
    test('moves item to a different position', () async {
      await repository.addToEnd(1);
      await repository.addToEnd(2);
      await repository.addToEnd(3);

      final queue = await repository.getQueue();
      final firstItem = queue.manualItems.first;

      await repository.reorder(firstItem.queueItem.id, 2);

      final updated = await repository.getQueue();
      final episodeIds = updated.manualItems.map((i) => i.episode.id).toList();

      expect(episodeIds.last, 1);
    });

    test('does nothing when new index equals current', () async {
      await repository.addToEnd(1);
      await repository.addToEnd(2);

      final queue = await repository.getQueue();
      final firstItem = queue.manualItems.first;

      await repository.reorder(firstItem.queueItem.id, 0);

      final updated = await repository.getQueue();
      expect(
        updated.manualItems.first.episode.id,
        queue.manualItems.first.episode.id,
      );
    });

    test('does nothing with out-of-bounds index', () async {
      await repository.addToEnd(1);

      final queue = await repository.getQueue();
      final item = queue.manualItems.first;

      await repository.reorder(item.queueItem.id, 5);

      final updated = await repository.getQueue();
      expect(updated.manualItems, hasLength(1));
    });
  });

  group('getQueue', () {
    test('returns empty queue when no items', () async {
      final queue = await repository.getQueue();

      expect(queue.totalCount, 0);
      expect(queue.hasItems, false);
      expect(queue.manualItems, isEmpty);
      expect(queue.adhocItems, isEmpty);
    });

    test('separates manual and adhoc items', () async {
      await repository.addToEnd(1);
      await repository.addToEnd(2);

      final queue = await repository.getQueue();

      expect(queue.manualItems, hasLength(2));
      expect(queue.adhocItems, isEmpty);
    });
  });

  group('hasManualItems', () {
    test('returns false when queue is empty', () async {
      expect(await repository.hasManualItems(), false);
    });

    test('returns true when manual items exist', () async {
      await repository.addToEnd(1);
      expect(await repository.hasManualItems(), true);
    });

    test('returns false when only adhoc items exist', () async {
      await repository.replaceWithAdhoc(episodeIds: [1], sourceContext: 'Test');
      expect(await repository.hasManualItems(), false);
    });
  });

  group('getNextEpisode', () {
    test('returns null when queue is empty', () async {
      expect(await repository.getNextEpisode(), isNull);
    });

    test('returns first manual item episode', () async {
      await repository.addToEnd(1);
      await repository.addToEnd(2);

      final result = await repository.getNextEpisode();
      expect(result, isNotNull);
      expect(result!.id, 1);
    });

    test('returns first adhoc item when no manual items', () async {
      await repository.replaceWithAdhoc(
        episodeIds: [2, 3],
        sourceContext: 'Test',
      );

      final result = await repository.getNextEpisode();
      expect(result, isNotNull);
      expect(result!.id, 2);
    });
  });

  group('artwork resolution', () {
    test('uses episode imageUrl when available', () async {
      // Add an episode with its own artwork
      await isar.writeTxn(() async {
        await isar.episodes.put(
          Episode()
            ..id = 10
            ..podcastId = 1
            ..guid = 'ep-art'
            ..title = 'Episode With Art'
            ..audioUrl = 'https://example.com/ep-art.mp3'
            ..imageUrl = 'https://example.com/episode-art.jpg',
        );
      });

      await repository.addToEnd(10);
      final queue = await repository.getQueue();

      expect(
        queue.manualItems.first.artworkUrl,
        'https://example.com/episode-art.jpg',
      );
    });

    test(
      'falls back to subscription artworkUrl when episode has no image',
      () async {
        // Update the subscription to have artwork
        await isar.writeTxn(() async {
          final sub = await isar.subscriptions.get(1);
          sub!.artworkUrl = 'https://example.com/podcast-art.jpg';
          await isar.subscriptions.put(sub);
        });

        // Episode 1 has no imageUrl
        await repository.addToEnd(1);
        final queue = await repository.getQueue();

        expect(
          queue.manualItems.first.artworkUrl,
          'https://example.com/podcast-art.jpg',
        );
      },
    );

    test(
      'returns null artworkUrl when neither episode nor subscription has image',
      () async {
        await repository.addToEnd(1);
        final queue = await repository.getQueue();

        expect(queue.manualItems.first.artworkUrl, isNull);
      },
    );
  });

  group('itunesId mapping', () {
    test('populates itunesId from subscription', () async {
      await repository.addToEnd(1);

      final queue = await repository.getQueue();

      expect(queue.manualItems.first.itunesId, 'test-itunes-id');
    });

    test('populates itunesId even when episode has its own imageUrl', () async {
      // Episode with its own artwork should still get itunesId for sharing
      await isar.writeTxn(() async {
        await isar.episodes.put(
          Episode()
            ..id = 30
            ..podcastId = 1
            ..guid = 'ep-with-art'
            ..title = 'Episode With Art'
            ..audioUrl = 'https://example.com/ep-art.mp3'
            ..imageUrl = 'https://example.com/ep-art.jpg',
        );
      });

      await repository.addToEnd(30);

      final queue = await repository.getQueue();
      final item = queue.manualItems.where((i) => i.episode.id == 30).first;

      expect(item.itunesId, 'test-itunes-id');
    });

    test('returns null itunesId when no subscription exists', () async {
      // Create an episode whose podcastId has no matching subscription
      await isar.writeTxn(() async {
        await isar.episodes.put(
          Episode()
            ..id = 20
            ..podcastId = 999
            ..guid = 'ep-orphan'
            ..title = 'Orphan Episode'
            ..audioUrl = 'https://example.com/ep-orphan.mp3',
        );
      });

      await repository.addToEnd(20);

      final queue = await repository.getQueue();
      final item = queue.manualItems.where((i) => i.episode.id == 20).first;

      expect(item.itunesId, isNull);
    });
  });

  group('watchQueue', () {
    test('emits current queue state', () async {
      await repository.addToEnd(1);

      final queue = await repository.watchQueue().first;

      expect(queue.manualItems, hasLength(1));
      expect(queue.manualItems.first.episode.id, 1);
    });
  });
}
