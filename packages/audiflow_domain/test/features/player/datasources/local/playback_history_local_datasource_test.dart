import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';

void main() {
  late Isar isar;
  late PlaybackHistoryLocalDatasource datasource;

  setUpAll(() async {
    await Isar.initializeIsarCore(download: true);
  });

  setUp(() async {
    isar = await Isar.open(
      [SubscriptionSchema, EpisodeSchema, PlaybackHistorySchema],
      directory: '',
      name: 'test_${DateTime.now().microsecondsSinceEpoch}',
    );
    datasource = PlaybackHistoryLocalDatasource(isar);

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

      for (var i = 1; i < 4; i++) {
        final ep = Episode()
          ..podcastId = 1
          ..guid = 'ep-$i'
          ..title = 'Episode $i'
          ..audioUrl = 'https://example.com/ep$i.mp3';
        await isar.episodes.put(ep);
      }
    });
  });

  tearDown(() async {
    await isar.close(deleteFromDisk: true);
  });

  group('updateProgress', () {
    test('creates new record on first play', () async {
      await datasource.updateProgress(episodeId: 1, positionMs: 5000);

      final result = await datasource.getByEpisodeId(1);

      expect(result, isNotNull);
      expect(result!.episodeId, 1);
      expect(result.positionMs, 5000);
      expect(result.playCount, 1);
      expect(result.firstPlayedAt, isNotNull);
      expect(result.lastPlayedAt, isNotNull);
    });

    test('creates record with duration when provided', () async {
      await datasource.updateProgress(
        episodeId: 1,
        positionMs: 5000,
        durationMs: 60000,
      );

      final result = await datasource.getByEpisodeId(1);

      expect(result!.durationMs, 60000);
    });

    test('updates existing record position', () async {
      await datasource.updateProgress(episodeId: 1, positionMs: 5000);
      await datasource.updateProgress(episodeId: 1, positionMs: 15000);

      final result = await datasource.getByEpisodeId(1);

      expect(result!.positionMs, 15000);
    });

    test('does not increment playCount on subsequent updates', () async {
      await datasource.updateProgress(episodeId: 1, positionMs: 5000);
      await datasource.updateProgress(episodeId: 1, positionMs: 15000);

      final result = await datasource.getByEpisodeId(1);

      expect(result!.playCount, 1);
    });

    test('updates duration on existing record when provided', () async {
      await datasource.updateProgress(
        episodeId: 1,
        positionMs: 5000,
        durationMs: 60000,
      );
      await datasource.updateProgress(
        episodeId: 1,
        positionMs: 10000,
        durationMs: 65000,
      );

      final result = await datasource.getByEpisodeId(1);

      expect(result!.durationMs, 65000);
    });

    test('preserves duration when not provided on update', () async {
      await datasource.updateProgress(
        episodeId: 1,
        positionMs: 5000,
        durationMs: 60000,
      );
      await datasource.updateProgress(episodeId: 1, positionMs: 10000);

      final result = await datasource.getByEpisodeId(1);

      expect(result!.durationMs, 60000);
    });
  });

  group('getByEpisodeId', () {
    test('returns null when no history exists', () async {
      final result = await datasource.getByEpisodeId(1);

      expect(result, isNull);
    });

    test('returns history for correct episode', () async {
      await datasource.updateProgress(episodeId: 1, positionMs: 5000);
      await datasource.updateProgress(episodeId: 2, positionMs: 10000);

      final result = await datasource.getByEpisodeId(1);

      expect(result, isNotNull);
      expect(result!.positionMs, 5000);
    });
  });

  group('markCompleted', () {
    test('marks episode as completed with new record', () async {
      await datasource.markCompleted(1);

      final result = await datasource.getByEpisodeId(1);

      expect(result, isNotNull);
      expect(result!.completedAt, isNotNull);
    });

    test('marks existing in-progress episode as completed', () async {
      await datasource.updateProgress(episodeId: 1, positionMs: 50000);
      await datasource.markCompleted(1);

      final result = await datasource.getByEpisodeId(1);

      expect(result!.completedAt, isNotNull);
      expect(result.positionMs, 50000);
    });
  });

  group('markIncomplete', () {
    test('clears completedAt timestamp', () async {
      await datasource.markCompleted(1);
      await datasource.markIncomplete(1);

      final result = await datasource.getByEpisodeId(1);

      expect(result!.completedAt, isNull);
    });
  });

  group('incrementPlayCount', () {
    test('increments play count on existing record', () async {
      await datasource.updateProgress(episodeId: 1, positionMs: 0);

      await datasource.incrementPlayCount(1);

      final result = await datasource.getByEpisodeId(1);
      expect(result!.playCount, 2);
    });

    test('increments multiple times', () async {
      await datasource.updateProgress(episodeId: 1, positionMs: 0);

      await datasource.incrementPlayCount(1);
      await datasource.incrementPlayCount(1);

      final result = await datasource.getByEpisodeId(1);
      expect(result!.playCount, 3);
    });

    test('does nothing when no existing record', () async {
      await datasource.incrementPlayCount(999);

      final result = await datasource.getByEpisodeId(999);
      expect(result, isNull);
    });
  });

  group('isCompleted', () {
    test('returns false when no history exists', () async {
      final result = await datasource.isCompleted(1);

      expect(result, false);
    });

    test('returns false when not completed', () async {
      await datasource.updateProgress(episodeId: 1, positionMs: 5000);

      final result = await datasource.isCompleted(1);

      expect(result, false);
    });

    test('returns true when completed', () async {
      await datasource.markCompleted(1);

      final result = await datasource.isCompleted(1);

      expect(result, true);
    });

    test('returns false after marking incomplete', () async {
      await datasource.markCompleted(1);
      await datasource.markIncomplete(1);

      final result = await datasource.isCompleted(1);

      expect(result, false);
    });
  });

  group('getLastPlayed', () {
    test('returns null when no history exists', () async {
      final result = await datasource.getLastPlayed();

      expect(result, isNull);
    });

    test('returns most recently played in-progress episode', () async {
      final h1 = PlaybackHistory()
        ..episodeId = 1
        ..positionMs = 5000
        ..lastPlayedAt = DateTime(2024, 1, 1);
      final h2 = PlaybackHistory()
        ..episodeId = 2
        ..positionMs = 10000
        ..lastPlayedAt = DateTime(2024, 6, 1);
      await datasource.upsert(h1);
      await datasource.upsert(h2);

      final result = await datasource.getLastPlayed();

      expect(result, isNotNull);
      expect(result!.episodeId, 2);
    });

    test('excludes completed episodes', () async {
      final h1 = PlaybackHistory()
        ..episodeId = 1
        ..positionMs = 5000
        ..lastPlayedAt = DateTime(2024, 1, 1);
      final h2 = PlaybackHistory()
        ..episodeId = 2
        ..positionMs = 10000
        ..lastPlayedAt = DateTime(2024, 6, 1);
      await datasource.upsert(h1);
      await datasource.upsert(h2);
      await datasource.markCompleted(2);

      final result = await datasource.getLastPlayed();

      expect(result, isNotNull);
      expect(result!.episodeId, 1);
    });

    test('excludes episodes with position 0', () async {
      final h = PlaybackHistory()
        ..episodeId = 1
        ..positionMs = 0
        ..lastPlayedAt = DateTime.now();
      await datasource.upsert(h);

      final result = await datasource.getLastPlayed();

      expect(result, isNull);
    });
  });

  group('getInProgress', () {
    test('returns episodes with position and no completion', () async {
      await datasource.updateProgress(episodeId: 1, positionMs: 5000);
      await datasource.updateProgress(episodeId: 2, positionMs: 10000);
      await datasource.markCompleted(3);

      final result = await datasource.getInProgress();

      expect(result, hasLength(2));
    });

    test('respects limit parameter', () async {
      final h1 = PlaybackHistory()
        ..episodeId = 1
        ..positionMs = 5000
        ..lastPlayedAt = DateTime(2024, 1, 1);
      final h2 = PlaybackHistory()
        ..episodeId = 2
        ..positionMs = 10000
        ..lastPlayedAt = DateTime(2024, 6, 1);
      await datasource.upsert(h1);
      await datasource.upsert(h2);

      final result = await datasource.getInProgress(limit: 1);

      expect(result, hasLength(1));
      expect(result.first.episodeId, 2);
    });
  });

  group('getByPodcastId', () {
    test('returns map of episodeId to PlaybackHistory', () async {
      await datasource.updateProgress(episodeId: 1, positionMs: 5000);
      await datasource.updateProgress(episodeId: 2, positionMs: 10000);

      final result = await datasource.getByPodcastId(1);

      expect(result, hasLength(2));
      expect(result[1]!.positionMs, 5000);
      expect(result[2]!.positionMs, 10000);
    });

    test('returns empty map for podcast with no history', () async {
      final result = await datasource.getByPodcastId(999);

      expect(result, isEmpty);
    });

    test('only returns history for specified podcast', () async {
      await isar.writeTxn(() async {
        await isar.subscriptions.put(
          Subscription()
            ..itunesId = 'itunes-2'
            ..feedUrl = 'https://example.com/feed2.xml'
            ..title = 'Podcast 2'
            ..artistName = 'Artist 2'
            ..subscribedAt = DateTime.now(),
        );
        await isar.episodes.put(
          Episode()
            ..podcastId = 2
            ..guid = 'ep-other'
            ..title = 'Other Episode'
            ..audioUrl = 'https://example.com/other.mp3',
        );
      });

      await datasource.updateProgress(episodeId: 1, positionMs: 5000);
      await datasource.updateProgress(episodeId: 4, positionMs: 8000);

      final result = await datasource.getByPodcastId(1);

      expect(result, hasLength(1));
      expect(result.containsKey(1), true);
      expect(result.containsKey(4), false);
    });
  });
}
