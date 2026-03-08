import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late DownloadRepositoryImpl repository;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    final datasource = DownloadLocalDatasource(db);
    repository = DownloadRepositoryImpl(datasource: datasource);

    // Create test subscription and episode
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
  });

  tearDown(() async {
    await db.close();
  });

  group('createDownload', () {
    test('creates new download task', () async {
      final task = await repository.createDownload(
        episodeId: 1,
        audioUrl: 'https://example.com/ep1.mp3',
        wifiOnly: true,
      );

      expect(task, isNotNull);
      expect(task!.episodeId, 1);
      expect(task.wifiOnly, true);
      expect(task.downloadStatus, isA<DownloadStatusPending>());
    });

    test('returns null if episode already has active download', () async {
      await repository.createDownload(
        episodeId: 1,
        audioUrl: 'https://example.com/ep1.mp3',
        wifiOnly: true,
      );

      final duplicate = await repository.createDownload(
        episodeId: 1,
        audioUrl: 'https://example.com/ep1.mp3',
        wifiOnly: true,
      );

      expect(duplicate, isNull);
    });

    test('allows re-download after cancellation', () async {
      final first = await repository.createDownload(
        episodeId: 1,
        audioUrl: 'https://example.com/ep1.mp3',
        wifiOnly: true,
      );

      await repository.updateStatus(
        id: first!.id,
        status: const DownloadStatus.cancelled(),
      );

      final second = await repository.createDownload(
        episodeId: 1,
        audioUrl: 'https://example.com/ep1.mp3',
        wifiOnly: false,
      );

      expect(second, isNotNull);
      expect(second!.wifiOnly, false);
    });

    test('allows re-download after failure', () async {
      final first = await repository.createDownload(
        episodeId: 1,
        audioUrl: 'https://example.com/ep1.mp3',
        wifiOnly: true,
      );

      await repository.updateStatus(
        id: first!.id,
        status: const DownloadStatus.failed(),
        lastError: 'Test error',
      );

      final second = await repository.createDownload(
        episodeId: 1,
        audioUrl: 'https://example.com/ep1.mp3',
        wifiOnly: false,
      );

      expect(second, isNotNull);
    });
  });

  group('updateProgress', () {
    test('updates download progress', () async {
      final task = await repository.createDownload(
        episodeId: 1,
        audioUrl: 'https://example.com/ep1.mp3',
        wifiOnly: true,
      );

      await repository.updateProgress(
        id: task!.id,
        downloadedBytes: 5000,
        totalBytes: 10000,
      );

      final updated = await repository.getById(task.id);
      expect(updated!.downloadedBytes, 5000);
      expect(updated.totalBytes, 10000);
      expect(updated.progress, 0.5);
    });

    test('updates only downloaded bytes when total is null', () async {
      final task = await repository.createDownload(
        episodeId: 1,
        audioUrl: 'https://example.com/ep1.mp3',
        wifiOnly: true,
      );

      await repository.updateProgress(id: task!.id, downloadedBytes: 5000);

      final updated = await repository.getById(task.id);
      expect(updated!.downloadedBytes, 5000);
      expect(updated.totalBytes, isNull);
    });
  });

  group('updateStatus', () {
    test('updates status to completed with local path', () async {
      final task = await repository.createDownload(
        episodeId: 1,
        audioUrl: 'https://example.com/ep1.mp3',
        wifiOnly: true,
      );

      await repository.updateStatus(
        id: task!.id,
        status: const DownloadStatus.completed(),
        localPath: '/path/to/file.mp3',
      );

      final updated = await repository.getById(task.id);
      expect(updated!.downloadStatus, isA<DownloadStatusCompleted>());
      expect(updated.localPath, '/path/to/file.mp3');
      expect(updated.completedAt, isNotNull);
    });

    test('updates status to failed with error message', () async {
      final task = await repository.createDownload(
        episodeId: 1,
        audioUrl: 'https://example.com/ep1.mp3',
        wifiOnly: true,
      );

      await repository.updateStatus(
        id: task!.id,
        status: const DownloadStatus.failed(),
        lastError: 'Network error',
      );

      final updated = await repository.getById(task.id);
      expect(updated!.downloadStatus, isA<DownloadStatusFailed>());
      expect(updated.lastError, 'Network error');
    });
  });

  group('incrementRetryCount', () {
    test('increments retry count by one', () async {
      final task = await repository.createDownload(
        episodeId: 1,
        audioUrl: 'https://example.com/ep1.mp3',
        wifiOnly: true,
      );

      expect(task!.retryCount, 0);

      await repository.incrementRetryCount(task.id);
      final updated = await repository.getById(task.id);
      expect(updated!.retryCount, 1);

      await repository.incrementRetryCount(task.id);
      final updated2 = await repository.getById(task.id);
      expect(updated2!.retryCount, 2);
    });
  });

  group('getByStatus', () {
    test('returns tasks with matching status', () async {
      // Create multiple downloads
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
      await db
          .into(db.episodes)
          .insert(
            EpisodesCompanion.insert(
              podcastId: 1,
              guid: 'ep-3',
              title: 'Episode 3',
              audioUrl: 'https://example.com/ep3.mp3',
            ),
          );

      final task1 = await repository.createDownload(
        episodeId: 1,
        audioUrl: 'https://example.com/ep1.mp3',
        wifiOnly: true,
      );
      final task2 = await repository.createDownload(
        episodeId: 2,
        audioUrl: 'https://example.com/ep2.mp3',
        wifiOnly: true,
      );
      await repository.createDownload(
        episodeId: 3,
        audioUrl: 'https://example.com/ep3.mp3',
        wifiOnly: true,
      );

      // Mark some as completed
      await repository.updateStatus(
        id: task1!.id,
        status: const DownloadStatus.completed(),
        localPath: '/path/ep1.mp3',
      );
      await repository.updateStatus(
        id: task2!.id,
        status: const DownloadStatus.completed(),
        localPath: '/path/ep2.mp3',
      );

      final pending = await repository.getByStatus(
        const DownloadStatus.pending(),
      );
      final completed = await repository.getByStatus(
        const DownloadStatus.completed(),
      );

      expect(pending, hasLength(1));
      expect(completed, hasLength(2));
    });
  });

  group('getNextPending', () {
    test('returns oldest pending task', () async {
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

      await repository.createDownload(
        episodeId: 1,
        audioUrl: 'https://example.com/ep1.mp3',
        wifiOnly: false,
      );
      await repository.createDownload(
        episodeId: 2,
        audioUrl: 'https://example.com/ep2.mp3',
        wifiOnly: false,
      );

      final next = await repository.getNextPending(isOnWifi: false);
      expect(next, isNotNull);
      expect(next!.episodeId, 1);
    });

    test('respects wifiOnly flag when not on wifi', () async {
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

      await repository.createDownload(
        episodeId: 1,
        audioUrl: 'https://example.com/ep1.mp3',
        wifiOnly: true,
      );
      await repository.createDownload(
        episodeId: 2,
        audioUrl: 'https://example.com/ep2.mp3',
        wifiOnly: false,
      );

      final next = await repository.getNextPending(isOnWifi: false);
      expect(next, isNotNull);
      expect(next!.episodeId, 2);
    });

    test('includes wifiOnly tasks when on wifi', () async {
      await repository.createDownload(
        episodeId: 1,
        audioUrl: 'https://example.com/ep1.mp3',
        wifiOnly: true,
      );

      final next = await repository.getNextPending(isOnWifi: true);
      expect(next, isNotNull);
      expect(next!.episodeId, 1);
    });
  });

  group('delete', () {
    test('removes download task', () async {
      final task = await repository.createDownload(
        episodeId: 1,
        audioUrl: 'https://example.com/ep1.mp3',
        wifiOnly: true,
      );

      await repository.delete(task!.id);

      final deleted = await repository.getById(task.id);
      expect(deleted, isNull);
    });
  });

  group('getActiveCount', () {
    test('counts pending, downloading, and paused tasks', () async {
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
      await db
          .into(db.episodes)
          .insert(
            EpisodesCompanion.insert(
              podcastId: 1,
              guid: 'ep-3',
              title: 'Episode 3',
              audioUrl: 'https://example.com/ep3.mp3',
            ),
          );

      final task1 = await repository.createDownload(
        episodeId: 1,
        audioUrl: 'https://example.com/ep1.mp3',
        wifiOnly: false,
      );
      final task2 = await repository.createDownload(
        episodeId: 2,
        audioUrl: 'https://example.com/ep2.mp3',
        wifiOnly: false,
      );
      await repository.createDownload(
        episodeId: 3,
        audioUrl: 'https://example.com/ep3.mp3',
        wifiOnly: false,
      );

      await repository.updateStatus(
        id: task1!.id,
        status: const DownloadStatus.downloading(),
      );
      await repository.updateStatus(
        id: task2!.id,
        status: const DownloadStatus.paused(),
      );

      final activeCount = await repository.getActiveCount();
      expect(activeCount, 3);
    });

    test('excludes completed and failed tasks', () async {
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

      final task1 = await repository.createDownload(
        episodeId: 1,
        audioUrl: 'https://example.com/ep1.mp3',
        wifiOnly: false,
      );
      final task2 = await repository.createDownload(
        episodeId: 2,
        audioUrl: 'https://example.com/ep2.mp3',
        wifiOnly: false,
      );

      await repository.updateStatus(
        id: task1!.id,
        status: const DownloadStatus.completed(),
        localPath: '/path/ep1.mp3',
      );
      await repository.updateStatus(
        id: task2!.id,
        status: const DownloadStatus.failed(),
        lastError: 'Error',
      );

      final activeCount = await repository.getActiveCount();
      expect(activeCount, 0);
    });
  });

  group('deleteAllCompleted', () {
    test('removes all completed downloads', () async {
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

      final task1 = await repository.createDownload(
        episodeId: 1,
        audioUrl: 'https://example.com/ep1.mp3',
        wifiOnly: false,
      );
      await repository.createDownload(
        episodeId: 2,
        audioUrl: 'https://example.com/ep2.mp3',
        wifiOnly: false,
      );

      await repository.updateStatus(
        id: task1!.id,
        status: const DownloadStatus.completed(),
        localPath: '/path/ep1.mp3',
      );

      final deletedCount = await repository.deleteAllCompleted();
      expect(deletedCount, 1);

      final remaining = await repository.getAll();
      expect(remaining, hasLength(1));
      expect(remaining.first.episodeId, 2);
    });
  });

  group('getAll', () {
    test('returns all tasks ordered by creation date', () async {
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

      await repository.createDownload(
        episodeId: 1,
        audioUrl: 'https://example.com/ep1.mp3',
        wifiOnly: true,
      );
      await repository.createDownload(
        episodeId: 2,
        audioUrl: 'https://example.com/ep2.mp3',
        wifiOnly: false,
      );

      final all = await repository.getAll();
      expect(all, hasLength(2));
      expect(all.first.episodeId, 1);
      expect(all.last.episodeId, 2);
    });

    test('returns empty list when no tasks exist', () async {
      final all = await repository.getAll();
      expect(all, isEmpty);
    });
  });

  group('watchAll', () {
    test('emits initial task list', () async {
      await repository.createDownload(
        episodeId: 1,
        audioUrl: 'https://example.com/ep1.mp3',
        wifiOnly: true,
      );

      final first = await repository.watchAll().first;
      expect(first, hasLength(1));
      expect(first.first.episodeId, 1);
    });

    test('emits empty list when no tasks exist', () async {
      final first = await repository.watchAll().first;
      expect(first, isEmpty);
    });
  });

  group('watchByStatus', () {
    test('emits tasks matching status', () async {
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

      final task1 = await repository.createDownload(
        episodeId: 1,
        audioUrl: 'https://example.com/ep1.mp3',
        wifiOnly: false,
      );
      await repository.createDownload(
        episodeId: 2,
        audioUrl: 'https://example.com/ep2.mp3',
        wifiOnly: false,
      );

      await repository.updateStatus(
        id: task1!.id,
        status: const DownloadStatus.completed(),
        localPath: '/path/ep1.mp3',
      );

      final pendingStream = repository.watchByStatus(
        const DownloadStatus.pending(),
      );
      final pending = await pendingStream.first;
      expect(pending, hasLength(1));
      expect(pending.first.episodeId, 2);

      final completedStream = repository.watchByStatus(
        const DownloadStatus.completed(),
      );
      final completed = await completedStream.first;
      expect(completed, hasLength(1));
      expect(completed.first.episodeId, 1);
    });
  });

  group('watchByEpisodeId', () {
    test('emits task for episode', () async {
      await repository.createDownload(
        episodeId: 1,
        audioUrl: 'https://example.com/ep1.mp3',
        wifiOnly: true,
      );

      final first = await repository.watchByEpisodeId(1).first;
      expect(first, isNotNull);
      expect(first!.episodeId, 1);
    });

    test('emits null for non-existent episode', () async {
      final first = await repository.watchByEpisodeId(9999).first;
      expect(first, isNull);
    });
  });

  group('getCompletedForEpisode', () {
    test('returns completed download for episode', () async {
      final task = await repository.createDownload(
        episodeId: 1,
        audioUrl: 'https://example.com/ep1.mp3',
        wifiOnly: true,
      );

      await repository.updateStatus(
        id: task!.id,
        status: const DownloadStatus.completed(),
        localPath: '/path/ep1.mp3',
      );

      final completed = await repository.getCompletedForEpisode(1);
      expect(completed, isNotNull);
      expect(completed!.localPath, '/path/ep1.mp3');
    });

    test('returns null when no completed download exists', () async {
      await repository.createDownload(
        episodeId: 1,
        audioUrl: 'https://example.com/ep1.mp3',
        wifiOnly: true,
      );

      final completed = await repository.getCompletedForEpisode(1);
      expect(completed, isNull);
    });

    test('returns null for non-existent episode', () async {
      final completed = await repository.getCompletedForEpisode(9999);
      expect(completed, isNull);
    });
  });

  group('getTotalStorageUsed', () {
    test('returns sum of totalBytes for completed downloads', () async {
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

      final task1 = await repository.createDownload(
        episodeId: 1,
        audioUrl: 'https://example.com/ep1.mp3',
        wifiOnly: false,
      );
      final task2 = await repository.createDownload(
        episodeId: 2,
        audioUrl: 'https://example.com/ep2.mp3',
        wifiOnly: false,
      );

      await repository.updateProgress(
        id: task1!.id,
        downloadedBytes: 5000,
        totalBytes: 5000,
      );
      await repository.updateStatus(
        id: task1.id,
        status: const DownloadStatus.completed(),
        localPath: '/path/ep1.mp3',
      );

      await repository.updateProgress(
        id: task2!.id,
        downloadedBytes: 3000,
        totalBytes: 3000,
      );
      await repository.updateStatus(
        id: task2.id,
        status: const DownloadStatus.completed(),
        localPath: '/path/ep2.mp3',
      );

      final totalStorage = await repository.getTotalStorageUsed();
      expect(totalStorage, equals(8000));
    });

    test('returns zero when no completed downloads exist', () async {
      await repository.createDownload(
        episodeId: 1,
        audioUrl: 'https://example.com/ep1.mp3',
        wifiOnly: false,
      );

      final totalStorage = await repository.getTotalStorageUsed();
      expect(totalStorage, equals(0));
    });

    test('excludes non-completed downloads from total', () async {
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

      final task1 = await repository.createDownload(
        episodeId: 1,
        audioUrl: 'https://example.com/ep1.mp3',
        wifiOnly: false,
      );
      await repository.createDownload(
        episodeId: 2,
        audioUrl: 'https://example.com/ep2.mp3',
        wifiOnly: false,
      );

      await repository.updateProgress(
        id: task1!.id,
        downloadedBytes: 5000,
        totalBytes: 5000,
      );
      await repository.updateStatus(
        id: task1.id,
        status: const DownloadStatus.completed(),
        localPath: '/path/ep1.mp3',
      );

      final totalStorage = await repository.getTotalStorageUsed();
      expect(totalStorage, equals(5000));
    });
  });

  group('incrementRetryCount edge cases', () {
    test('does nothing for non-existent task', () async {
      // Should not throw
      await repository.incrementRetryCount(9999);
    });
  });
}
