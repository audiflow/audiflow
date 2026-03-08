import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late PlaybackHistoryRepositoryImpl repository;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    final datasource = PlaybackHistoryLocalDatasource(db);
    repository = PlaybackHistoryRepositoryImpl(datasource: datasource);

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
    await db
        .into(db.episodes)
        .insert(
          EpisodesCompanion.insert(
            podcastId: 1,
            guid: 'ep-1',
            title: 'Episode 1',
            audioUrl: 'https://example.com/ep1.mp3',
          ),
        );
    await db
        .into(db.episodes)
        .insert(
          EpisodesCompanion.insert(
            podcastId: 1,
            guid: 'ep-2',
            title: 'Episode 2',
            audioUrl: 'https://example.com/ep2.mp3',
          ),
        );
  });

  tearDown(() async {
    await db.close();
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

      final completed = await repository.isCompleted(1);

      expect(completed, true);
    });
  });

  group('markIncomplete', () {
    test('marks completed episode as incomplete', () async {
      await repository.markCompleted(1);
      await repository.markIncomplete(1);

      final completed = await repository.isCompleted(1);

      expect(completed, false);
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
      final result = await repository.isCompleted(1);

      expect(result, false);
    });

    test('returns false when in progress', () async {
      await repository.saveProgress(episodeId: 1, positionMs: 5000);

      final result = await repository.isCompleted(1);

      expect(result, false);
    });

    test('returns true when completed', () async {
      await repository.markCompleted(1);

      final result = await repository.isCompleted(1);

      expect(result, true);
    });
  });

  group('getProgressPercent', () {
    test('returns null when no history', () async {
      final result = await repository.getProgressPercent(1);

      expect(result, isNull);
    });

    test('returns null when duration is null', () async {
      await repository.saveProgress(episodeId: 1, positionMs: 5000);

      final result = await repository.getProgressPercent(1);

      expect(result, isNull);
    });

    test('returns null when duration is zero', () async {
      await repository.saveProgress(
        episodeId: 1,
        positionMs: 5000,
        durationMs: 0,
      );

      final result = await repository.getProgressPercent(1);

      expect(result, isNull);
    });

    test('returns correct progress percentage', () async {
      await repository.saveProgress(
        episodeId: 1,
        positionMs: 30000,
        durationMs: 60000,
      );

      final result = await repository.getProgressPercent(1);

      expect(result, 0.5);
    });

    test('returns 1.0 when position equals duration', () async {
      await repository.saveProgress(
        episodeId: 1,
        positionMs: 60000,
        durationMs: 60000,
      );

      final result = await repository.getProgressPercent(1);

      expect(result, 1.0);
    });
  });

  group('getLastPlayed', () {
    test('returns null when no history', () async {
      final result = await repository.getLastPlayed();

      expect(result, isNull);
    });

    test('returns most recently played in-progress episode', () async {
      // Use direct upsert to control timestamps for deterministic ordering
      final datasource = PlaybackHistoryLocalDatasource(db);
      await datasource.upsert(
        PlaybackHistoriesCompanion.insert(
          episodeId: const Value(1),
          positionMs: const Value(5000),
          lastPlayedAt: Value(DateTime(2024, 1, 1)),
        ),
      );
      await datasource.upsert(
        PlaybackHistoriesCompanion.insert(
          episodeId: const Value(2),
          positionMs: const Value(10000),
          lastPlayedAt: Value(DateTime(2024, 6, 1)),
        ),
      );

      final result = await repository.getLastPlayed();

      expect(result, isNotNull);
      expect(result!.episodeId, 2);
    });

    test('excludes completed episodes', () async {
      final datasource = PlaybackHistoryLocalDatasource(db);
      await datasource.upsert(
        PlaybackHistoriesCompanion.insert(
          episodeId: const Value(1),
          positionMs: const Value(5000),
          lastPlayedAt: Value(DateTime(2024, 1, 1)),
        ),
      );
      await datasource.upsert(
        PlaybackHistoriesCompanion.insert(
          episodeId: const Value(2),
          positionMs: const Value(10000),
          lastPlayedAt: Value(DateTime(2024, 6, 1)),
        ),
      );
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
