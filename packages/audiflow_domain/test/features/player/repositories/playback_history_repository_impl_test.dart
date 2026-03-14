import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';

void main() {
  late Isar isar;
  late PlaybackHistoryRepositoryImpl repository;
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
    repository = PlaybackHistoryRepositoryImpl(datasource: datasource);

    await isar.writeTxn(() async {
      await isar.subscriptions.put(
        Subscription()
          ..itunesId = 'test-itunes-id'
          ..feedUrl = 'https://example.com/feed.xml'
          ..title = 'Test Podcast'
          ..artistName = 'Test Artist'
          ..subscribedAt = DateTime.now(),
      );
      await isar.episodes.put(
        Episode()
          ..podcastId = 1
          ..guid = 'ep-1'
          ..title = 'Episode 1'
          ..audioUrl = 'https://example.com/ep1.mp3',
      );
      await isar.episodes.put(
        Episode()
          ..podcastId = 1
          ..guid = 'ep-2'
          ..title = 'Episode 2'
          ..audioUrl = 'https://example.com/ep2.mp3',
      );
    });
  });

  tearDown(() async {
    await isar.close(deleteFromDisk: true);
  });

  group('saveProgress', () {
    test('creates new record for first play', () async {
      await repository.saveProgress(episodeId: 1, positionMs: 5000);

      final result = await repository.getByEpisodeId(1);
      expect(result, isNotNull);
      expect(result!.positionMs, 5000);
    });

    test('saves progress with duration', () async {
      await repository.saveProgress(
        episodeId: 1,
        positionMs: 5000,
        durationMs: 60000,
      );

      final result = await repository.getByEpisodeId(1);
      expect(result!.durationMs, 60000);
    });

    test('updates existing progress', () async {
      await repository.saveProgress(episodeId: 1, positionMs: 5000);
      await repository.saveProgress(episodeId: 1, positionMs: 20000);

      final result = await repository.getByEpisodeId(1);
      expect(result!.positionMs, 20000);
    });
  });

  group('markCompleted', () {
    test('marks episode as completed', () async {
      await repository.saveProgress(episodeId: 1, positionMs: 50000);
      await repository.markCompleted(1);

      expect(await repository.isCompleted(1), true);
    });
  });

  group('markIncomplete', () {
    test('marks completed episode as incomplete', () async {
      await repository.markCompleted(1);
      await repository.markIncomplete(1);

      expect(await repository.isCompleted(1), false);
    });
  });

  group('incrementPlayCount', () {
    test('increments play count', () async {
      await repository.saveProgress(episodeId: 1, positionMs: 0);
      await repository.incrementPlayCount(1);

      final result = await repository.getByEpisodeId(1);
      expect(result!.playCount, 2);
    });
  });

  group('isCompleted', () {
    test('returns false when no history', () async {
      expect(await repository.isCompleted(1), false);
    });

    test('returns false when in progress', () async {
      await repository.saveProgress(episodeId: 1, positionMs: 5000);
      expect(await repository.isCompleted(1), false);
    });

    test('returns true when completed', () async {
      await repository.markCompleted(1);
      expect(await repository.isCompleted(1), true);
    });
  });

  group('getProgressPercent', () {
    test('returns null when no history', () async {
      expect(await repository.getProgressPercent(1), isNull);
    });

    test('returns null when duration is null', () async {
      await repository.saveProgress(episodeId: 1, positionMs: 5000);
      expect(await repository.getProgressPercent(1), isNull);
    });

    test('returns null when duration is zero', () async {
      await repository.saveProgress(
        episodeId: 1,
        positionMs: 5000,
        durationMs: 0,
      );
      expect(await repository.getProgressPercent(1), isNull);
    });

    test('returns correct progress percentage', () async {
      await repository.saveProgress(
        episodeId: 1,
        positionMs: 30000,
        durationMs: 60000,
      );
      expect(await repository.getProgressPercent(1), 0.5);
    });

    test('returns 1.0 when position equals duration', () async {
      await repository.saveProgress(
        episodeId: 1,
        positionMs: 60000,
        durationMs: 60000,
      );
      expect(await repository.getProgressPercent(1), 1.0);
    });
  });

  group('getLastPlayed', () {
    test('returns null when no history', () async {
      expect(await repository.getLastPlayed(), isNull);
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

      final result = await repository.getLastPlayed();
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
      await repository.markCompleted(2);

      final result = await repository.getLastPlayed();
      expect(result!.episodeId, 1);
    });
  });

  group('watchInProgress', () {
    test('emits in-progress episodes', () async {
      await repository.saveProgress(episodeId: 1, positionMs: 5000);

      final result = await repository.watchInProgress().first;
      expect(result, hasLength(1));
      expect(result.first.episodeId, 1);
    });
  });

  group('getByPodcastId', () {
    test('returns history map for podcast episodes', () async {
      await repository.saveProgress(episodeId: 1, positionMs: 5000);
      await repository.saveProgress(episodeId: 2, positionMs: 10000);

      final result = await repository.getByPodcastId(1);
      expect(result, hasLength(2));
      expect(result[1]!.positionMs, 5000);
      expect(result[2]!.positionMs, 10000);
    });

    test('returns empty map for podcast with no history', () async {
      final result = await repository.getByPodcastId(999);
      expect(result, isEmpty);
    });
  });
}
