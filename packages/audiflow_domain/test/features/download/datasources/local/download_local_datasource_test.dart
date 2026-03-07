import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late DownloadLocalDatasource datasource;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    datasource = DownloadLocalDatasource(db);

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
    for (var i = 1; 5 <= i == false; i++) {
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

  DownloadTasksCompanion _makeTask({
    required int episodeId,
    bool wifiOnly = true,
  }) {
    return DownloadTasksCompanion.insert(
      episodeId: episodeId,
      audioUrl: 'https://example.com/ep$episodeId.mp3',
      wifiOnly: Value(wifiOnly),
      createdAt: DateTime.now(),
    );
  }

  group('create', () {
    test('inserts download task and returns id', () async {
      final id = await datasource.create(_makeTask(episodeId: 1));

      expect(0 < id, true);
    });
  });

  group('getById', () {
    test('returns task by id', () async {
      final id = await datasource.create(_makeTask(episodeId: 1));

      final task = await datasource.getById(id);

      expect(task, isNotNull);
      expect(task!.episodeId, 1);
      expect(task.downloadStatus, isA<DownloadStatusPending>());
    });

    test('returns null when not found', () async {
      final task = await datasource.getById(999);

      expect(task, isNull);
    });
  });

  group('getByEpisodeId', () {
    test('returns task by episode id', () async {
      await datasource.create(_makeTask(episodeId: 1));

      final task = await datasource.getByEpisodeId(1);

      expect(task, isNotNull);
      expect(task!.episodeId, 1);
    });

    test('returns null when not found', () async {
      final task = await datasource.getByEpisodeId(999);

      expect(task, isNull);
    });
  });

  group('getAll', () {
    test('returns empty list when no tasks', () async {
      final tasks = await datasource.getAll();

      expect(tasks, isEmpty);
    });

    test('returns all tasks ordered by creation date', () async {
      await datasource.create(_makeTask(episodeId: 1));
      await datasource.create(_makeTask(episodeId: 2));

      final tasks = await datasource.getAll();

      expect(tasks, hasLength(2));
      expect(tasks.first.episodeId, 1);
      expect(tasks.last.episodeId, 2);
    });
  });

  group('getByStatus', () {
    test('returns tasks with matching status', () async {
      final id1 = await datasource.create(_makeTask(episodeId: 1));
      await datasource.create(_makeTask(episodeId: 2));

      // Mark first as downloading
      await datasource.updateById(
        id1,
        const DownloadTasksCompanion(
          status: Value(1), // downloading
        ),
      );

      final pending = await datasource.getByStatus(
        const DownloadStatus.pending(),
      );
      final downloading = await datasource.getByStatus(
        const DownloadStatus.downloading(),
      );

      expect(pending, hasLength(1));
      expect(pending.first.episodeId, 2);
      expect(downloading, hasLength(1));
      expect(downloading.first.episodeId, 1);
    });
  });

  group('updateProgress', () {
    test('updates downloaded bytes and total bytes', () async {
      final id = await datasource.create(_makeTask(episodeId: 1));

      await datasource.updateById(
        id,
        const DownloadTasksCompanion(
          downloadedBytes: Value(5000),
          totalBytes: Value(10000),
        ),
      );

      final task = await datasource.getById(id);
      expect(task!.downloadedBytes, 5000);
      expect(task.totalBytes, 10000);
      expect(task.progress, 0.5);
    });
  });

  group('updateById', () {
    test('updates status', () async {
      final id = await datasource.create(_makeTask(episodeId: 1));

      await datasource.updateById(
        id,
        DownloadTasksCompanion(
          status: Value(const DownloadStatus.completed().toDbValue()),
          localPath: const Value('/path/ep1.mp3'),
        ),
      );

      final task = await datasource.getById(id);
      expect(task!.downloadStatus, isA<DownloadStatusCompleted>());
      expect(task.localPath, '/path/ep1.mp3');
    });

    test('updates error message', () async {
      final id = await datasource.create(_makeTask(episodeId: 1));

      await datasource.updateById(
        id,
        DownloadTasksCompanion(
          status: Value(const DownloadStatus.failed().toDbValue()),
          lastError: const Value('Network error'),
        ),
      );

      final task = await datasource.getById(id);
      expect(task!.downloadStatus, isA<DownloadStatusFailed>());
      expect(task.lastError, 'Network error');
    });
  });

  group('delete', () {
    test('removes task by id', () async {
      final id = await datasource.create(_makeTask(episodeId: 1));

      final deleted = await datasource.delete(id);

      expect(deleted, 1);
      final task = await datasource.getById(id);
      expect(task, isNull);
    });

    test('returns 0 when task does not exist', () async {
      final deleted = await datasource.delete(999);

      expect(deleted, 0);
    });
  });

  group('getActiveCount', () {
    test('returns 0 when no tasks', () async {
      final count = await datasource.getActiveCount();

      expect(count, 0);
    });

    test('counts pending, downloading, and paused tasks', () async {
      final id1 = await datasource.create(_makeTask(episodeId: 1));
      final id2 = await datasource.create(_makeTask(episodeId: 2));
      await datasource.create(_makeTask(episodeId: 3)); // pending

      await datasource.updateById(
        id1,
        DownloadTasksCompanion(
          status: Value(const DownloadStatus.downloading().toDbValue()),
        ),
      );
      await datasource.updateById(
        id2,
        DownloadTasksCompanion(
          status: Value(const DownloadStatus.paused().toDbValue()),
        ),
      );

      final count = await datasource.getActiveCount();

      expect(count, 3);
    });

    test('excludes completed and failed tasks', () async {
      final id1 = await datasource.create(_makeTask(episodeId: 1));
      final id2 = await datasource.create(_makeTask(episodeId: 2));

      await datasource.updateById(
        id1,
        DownloadTasksCompanion(
          status: Value(const DownloadStatus.completed().toDbValue()),
        ),
      );
      await datasource.updateById(
        id2,
        DownloadTasksCompanion(
          status: Value(const DownloadStatus.failed().toDbValue()),
        ),
      );

      final count = await datasource.getActiveCount();

      expect(count, 0);
    });
  });

  group('getNextPending', () {
    test('returns null when no pending tasks', () async {
      final task = await datasource.getNextPending(isOnWifi: true);

      expect(task, isNull);
    });

    test('returns oldest pending task', () async {
      await datasource.create(_makeTask(episodeId: 1));
      await datasource.create(_makeTask(episodeId: 2));

      final task = await datasource.getNextPending(isOnWifi: true);

      expect(task, isNotNull);
      expect(task!.episodeId, 1);
    });

    test('skips wifiOnly tasks when not on wifi', () async {
      await datasource.create(_makeTask(episodeId: 1, wifiOnly: true));
      await datasource.create(_makeTask(episodeId: 2, wifiOnly: false));

      final task = await datasource.getNextPending(isOnWifi: false);

      expect(task, isNotNull);
      expect(task!.episodeId, 2);
    });

    test('includes wifiOnly tasks when on wifi', () async {
      await datasource.create(_makeTask(episodeId: 1, wifiOnly: true));

      final task = await datasource.getNextPending(isOnWifi: true);

      expect(task, isNotNull);
      expect(task!.episodeId, 1);
    });
  });

  group('getCompletedByEpisodeId', () {
    test('returns completed download for episode', () async {
      final id = await datasource.create(_makeTask(episodeId: 1));
      await datasource.updateById(
        id,
        DownloadTasksCompanion(
          status: Value(const DownloadStatus.completed().toDbValue()),
          localPath: const Value('/path/ep1.mp3'),
        ),
      );

      final task = await datasource.getCompletedByEpisodeId(1);

      expect(task, isNotNull);
      expect(task!.localPath, '/path/ep1.mp3');
    });

    test('returns null when no completed download', () async {
      await datasource.create(_makeTask(episodeId: 1));

      final task = await datasource.getCompletedByEpisodeId(1);

      expect(task, isNull);
    });
  });

  group('deleteAllCompleted', () {
    test('removes all completed downloads', () async {
      final id1 = await datasource.create(_makeTask(episodeId: 1));
      await datasource.create(_makeTask(episodeId: 2)); // pending

      await datasource.updateById(
        id1,
        DownloadTasksCompanion(
          status: Value(const DownloadStatus.completed().toDbValue()),
        ),
      );

      final deleted = await datasource.deleteAllCompleted();

      expect(deleted, 1);
      final remaining = await datasource.getAll();
      expect(remaining, hasLength(1));
      expect(remaining.first.episodeId, 2);
    });
  });

  group('getTotalStorageUsed', () {
    test('returns 0 when no completed downloads', () async {
      final total = await datasource.getTotalStorageUsed();

      expect(total, 0);
    });

    test('sums total bytes of completed downloads', () async {
      final id1 = await datasource.create(_makeTask(episodeId: 1));
      final id2 = await datasource.create(_makeTask(episodeId: 2));

      await datasource.updateById(
        id1,
        DownloadTasksCompanion(
          status: Value(const DownloadStatus.completed().toDbValue()),
          totalBytes: const Value(10000),
        ),
      );
      await datasource.updateById(
        id2,
        DownloadTasksCompanion(
          status: Value(const DownloadStatus.completed().toDbValue()),
          totalBytes: const Value(20000),
        ),
      );

      final total = await datasource.getTotalStorageUsed();

      expect(total, 30000);
    });
  });
}
