import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';

void main() {
  late Isar isar;
  late DownloadLocalDatasource datasource;

  setUpAll(() async {
    await Isar.initializeIsarCore(download: true);
  });

  setUp(() async {
    isar = await Isar.open(
      [DownloadTaskSchema],
      directory: '',
      name: 'test_${DateTime.now().microsecondsSinceEpoch}',
    );
    datasource = DownloadLocalDatasource(isar);
  });

  tearDown(() async {
    await isar.close(deleteFromDisk: true);
  });

  DownloadTask makeTask({required int episodeId, bool wifiOnly = true}) {
    return DownloadTask()
      ..episodeId = episodeId
      ..audioUrl = 'https://example.com/ep$episodeId.mp3'
      ..wifiOnly = wifiOnly
      ..createdAt = DateTime.now();
  }

  group('create', () {
    test('inserts download task and returns id', () async {
      final id = await datasource.create(makeTask(episodeId: 1));

      expect(0 < id, true);
    });
  });

  group('getById', () {
    test('returns task by id', () async {
      final id = await datasource.create(makeTask(episodeId: 1));

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
      await datasource.create(makeTask(episodeId: 1));

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
      await datasource.create(makeTask(episodeId: 1));
      await datasource.create(makeTask(episodeId: 2));

      final tasks = await datasource.getAll();

      expect(tasks, hasLength(2));
      expect(tasks.first.episodeId, 1);
      expect(tasks.last.episodeId, 2);
    });
  });

  group('getByStatus', () {
    test('returns tasks with matching status', () async {
      final id1 = await datasource.create(makeTask(episodeId: 1));
      await datasource.create(makeTask(episodeId: 2));

      // Mark first as downloading
      final task1 = await datasource.getById(id1);
      task1!.status = const DownloadStatus.downloading().toDbValue();
      await datasource.updateById(id1, task1);

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
      final id = await datasource.create(makeTask(episodeId: 1));

      final task = await datasource.getById(id);
      task!.downloadedBytes = 5000;
      task.totalBytes = 10000;
      await datasource.updateById(id, task);

      final updated = await datasource.getById(id);
      expect(updated!.downloadedBytes, 5000);
      expect(updated.totalBytes, 10000);
      expect(updated.progress, 0.5);
    });
  });

  group('updateById', () {
    test('updates status', () async {
      final id = await datasource.create(makeTask(episodeId: 1));

      final task = await datasource.getById(id);
      task!.status = const DownloadStatus.completed().toDbValue();
      task.localPath = '/path/ep1.mp3';
      await datasource.updateById(id, task);

      final updated = await datasource.getById(id);
      expect(updated!.downloadStatus, isA<DownloadStatusCompleted>());
      expect(updated.localPath, '/path/ep1.mp3');
    });

    test('updates error message', () async {
      final id = await datasource.create(makeTask(episodeId: 1));

      final task = await datasource.getById(id);
      task!.status = const DownloadStatus.failed().toDbValue();
      task.lastError = 'Network error';
      await datasource.updateById(id, task);

      final updated = await datasource.getById(id);
      expect(updated!.downloadStatus, isA<DownloadStatusFailed>());
      expect(updated.lastError, 'Network error');
    });
  });

  group('delete', () {
    test('removes task by id', () async {
      final id = await datasource.create(makeTask(episodeId: 1));

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
      final id1 = await datasource.create(makeTask(episodeId: 1));
      final id2 = await datasource.create(makeTask(episodeId: 2));
      await datasource.create(makeTask(episodeId: 3)); // pending

      final task1 = await datasource.getById(id1);
      task1!.status = const DownloadStatus.downloading().toDbValue();
      await datasource.updateById(id1, task1);

      final task2 = await datasource.getById(id2);
      task2!.status = const DownloadStatus.paused().toDbValue();
      await datasource.updateById(id2, task2);

      final count = await datasource.getActiveCount();

      expect(count, 3);
    });

    test('excludes completed and failed tasks', () async {
      final id1 = await datasource.create(makeTask(episodeId: 1));
      final id2 = await datasource.create(makeTask(episodeId: 2));

      final task1 = await datasource.getById(id1);
      task1!.status = const DownloadStatus.completed().toDbValue();
      await datasource.updateById(id1, task1);

      final task2 = await datasource.getById(id2);
      task2!.status = const DownloadStatus.failed().toDbValue();
      await datasource.updateById(id2, task2);

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
      await datasource.create(makeTask(episodeId: 1));
      await datasource.create(makeTask(episodeId: 2));

      final task = await datasource.getNextPending(isOnWifi: true);

      expect(task, isNotNull);
      expect(task!.episodeId, 1);
    });

    test('skips wifiOnly tasks when not on wifi', () async {
      await datasource.create(makeTask(episodeId: 1, wifiOnly: true));
      await datasource.create(makeTask(episodeId: 2, wifiOnly: false));

      final task = await datasource.getNextPending(isOnWifi: false);

      expect(task, isNotNull);
      expect(task!.episodeId, 2);
    });

    test('includes wifiOnly tasks when on wifi', () async {
      await datasource.create(makeTask(episodeId: 1, wifiOnly: true));

      final task = await datasource.getNextPending(isOnWifi: true);

      expect(task, isNotNull);
      expect(task!.episodeId, 1);
    });
  });

  group('getCompletedByEpisodeId', () {
    test('returns completed download for episode', () async {
      final id = await datasource.create(makeTask(episodeId: 1));
      final task = await datasource.getById(id);
      task!.status = const DownloadStatus.completed().toDbValue();
      task.localPath = '/path/ep1.mp3';
      await datasource.updateById(id, task);

      final result = await datasource.getCompletedByEpisodeId(1);

      expect(result, isNotNull);
      expect(result!.localPath, '/path/ep1.mp3');
    });

    test('returns null when no completed download', () async {
      await datasource.create(makeTask(episodeId: 1));

      final result = await datasource.getCompletedByEpisodeId(1);

      expect(result, isNull);
    });
  });

  group('deleteAllCompleted', () {
    test('removes all completed downloads', () async {
      final id1 = await datasource.create(makeTask(episodeId: 1));
      await datasource.create(makeTask(episodeId: 2)); // pending

      final task1 = await datasource.getById(id1);
      task1!.status = const DownloadStatus.completed().toDbValue();
      await datasource.updateById(id1, task1);

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
      final id1 = await datasource.create(makeTask(episodeId: 1));
      final id2 = await datasource.create(makeTask(episodeId: 2));

      final task1 = await datasource.getById(id1);
      task1!.status = const DownloadStatus.completed().toDbValue();
      task1.totalBytes = 10000;
      await datasource.updateById(id1, task1);

      final task2 = await datasource.getById(id2);
      task2!.status = const DownloadStatus.completed().toDbValue();
      task2.totalBytes = 20000;
      await datasource.updateById(id2, task2);

      final total = await datasource.getTotalStorageUsed();

      expect(total, 30000);
    });
  });
}
