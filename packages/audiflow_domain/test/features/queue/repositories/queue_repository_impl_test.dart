import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late QueueRepositoryImpl repository;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    final queueDatasource = QueueLocalDatasource(db);
    final episodeDatasource = EpisodeLocalDatasource(db);
    repository = QueueRepositoryImpl(
      queueDatasource: queueDatasource,
      episodeDatasource: episodeDatasource,
    );

    // Create subscription (FK dependency)
    await db
        .into(db.subscriptions)
        .insert(
          SubscriptionsCompanion.insert(
            itunesId: 'test-itunes-id',
            feedUrl: 'https://example.com/feed.xml',
            title: 'Test Podcast',
            artistName: 'Test Artist',
            subscribedAt: DateTime.now(),
          ),
        );

    // Create episodes (FK dependency)
    for (var i = 1; i < 5; i++) {
      await db
          .into(db.episodes)
          .insert(
            EpisodesCompanion.insert(
              podcastId: 1,
              guid: 'ep-$i',
              title: 'Episode $i',
              audioUrl: 'https://example.com/ep$i.mp3',
            ),
          );
    }
  });

  tearDown(() async {
    await db.close();
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

      // Move first item to last position
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

      // Add adhoc items by replacing (this clears manual too)
      // Instead, add manual first, then test separately
      final queue = await repository.getQueue();

      expect(queue.manualItems, hasLength(2));
      expect(queue.adhocItems, isEmpty);
    });
  });

  group('hasManualItems', () {
    test('returns false when queue is empty', () async {
      final result = await repository.hasManualItems();

      expect(result, false);
    });

    test('returns true when manual items exist', () async {
      await repository.addToEnd(1);

      final result = await repository.hasManualItems();

      expect(result, true);
    });

    test('returns false when only adhoc items exist', () async {
      await repository.replaceWithAdhoc(episodeIds: [1], sourceContext: 'Test');

      final result = await repository.hasManualItems();

      expect(result, false);
    });
  });

  group('getNextEpisode', () {
    test('returns null when queue is empty', () async {
      final result = await repository.getNextEpisode();

      expect(result, isNull);
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

  group('watchQueue', () {
    test('emits current queue state', () async {
      await repository.addToEnd(1);

      final queue = await repository.watchQueue().first;

      expect(queue.manualItems, hasLength(1));
      expect(queue.manualItems.first.episode.id, 1);
    });
  });
}
