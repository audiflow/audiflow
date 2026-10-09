import 'dart:async';

import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';

import '../../../helpers/isar_test_helper.dart';

void main() {
  late Isar isar;
  late DownloadRepositoryImpl repository;

  setUpAll(() async {
    await Isar.initializeIsarCore(download: true);
  });

  setUp(() async {
    isar = await openTestIsar([DownloadTaskSchema, DownloadFileRemovalSchema]);
    final datasource = DownloadLocalDatasource(isar);
    repository = DownloadRepositoryImpl(datasource: datasource);
  });

  tearDown(() async {
    await isar.close(deleteFromDisk: true);
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

    test('records manual origin by default', () async {
      final task = await repository.createDownload(
        episodeId: 1,
        audioUrl: 'https://example.com/ep1.mp3',
        wifiOnly: true,
      );

      check(task!.downloadOrigin).equals(DownloadOrigin.manual);
    });

    test('records auto origin when requested', () async {
      final task = await repository.createDownload(
        episodeId: 1,
        audioUrl: 'https://example.com/ep1.mp3',
        wifiOnly: true,
        origin: DownloadOrigin.auto,
      );

      check(task!.downloadOrigin).equals(DownloadOrigin.auto);
    });

    test('promotes an existing auto download to manual', () async {
      final auto = await repository.createDownload(
        episodeId: 1,
        audioUrl: 'https://example.com/ep1.mp3',
        wifiOnly: true,
        origin: DownloadOrigin.auto,
      );

      final duplicate = await repository.createDownload(
        episodeId: 1,
        audioUrl: 'https://example.com/ep1.mp3',
        wifiOnly: true,
      );

      check(duplicate).isNull();
      final stored = await repository.getById(auto!.id);
      check(stored!.downloadOrigin).equals(DownloadOrigin.manual);
    });

    test('does not demote an existing manual download to auto', () async {
      final manual = await repository.createDownload(
        episodeId: 1,
        audioUrl: 'https://example.com/ep1.mp3',
        wifiOnly: true,
      );

      await repository.createDownload(
        episodeId: 1,
        audioUrl: 'https://example.com/ep1.mp3',
        wifiOnly: true,
        origin: DownloadOrigin.auto,
      );

      final stored = await repository.getById(manual!.id);
      check(stored!.downloadOrigin).equals(DownloadOrigin.manual);
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

  group('resetRetryCount', () {
    test('sets retry count back to zero', () async {
      final task = await repository.createDownload(
        episodeId: 1,
        audioUrl: 'https://example.com/ep1.mp3',
        wifiOnly: true,
      );
      await repository.incrementRetryCount(task!.id);
      await repository.incrementRetryCount(task.id);

      await repository.resetRetryCount(task.id);

      final updated = await repository.getById(task.id);
      check(
        updated,
      ).isNotNull().has((t) => t.retryCount, 'retryCount').equals(0);
    });
  });

  group('getByStatus', () {
    test('returns tasks with matching status', () async {
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

  Future<DownloadTask> createAuto({
    DownloadStatus status = const DownloadStatus.downloading(),
  }) async {
    final task = await repository.createDownload(
      episodeId: 1,
      audioUrl: 'https://example.com/ep1.mp3',
      wifiOnly: true,
      origin: DownloadOrigin.auto,
    );
    await repository.updateStatus(id: task!.id, status: status);
    return task;
  }

  group('markManual', () {
    test('promotes an auto download to manual', () async {
      final task = await createAuto();

      check(await repository.markManual(task.id)).isTrue();

      final stored = await repository.getById(task.id);
      check(stored!.downloadOrigin).equals(DownloadOrigin.manual);
    });

    test('reports no promotion for a manual download', () async {
      final task = await repository.createDownload(
        episodeId: 1,
        audioUrl: 'https://example.com/ep1.mp3',
        wifiOnly: true,
      );

      check(await repository.markManual(task!.id)).isFalse();
    });

    test('reports no promotion for an unknown task', () async {
      check(await repository.markManual(999)).isFalse();

      check(await repository.getAll()).isEmpty();
    });
  });

  // Each writer is started first and markManual right after, without
  // awaiting in between. A writer that read the task before its write
  // transaction would save that stale copy after the promotion and put
  // the auto origin back.
  group('writers racing markManual keep the promotion', () {
    final writers = <String, Future<void> Function(int id)>{
      'updateProgress': (id) =>
          repository.updateProgress(id: id, downloadedBytes: 10),
      'updateStatus': (id) => repository.updateStatus(
        id: id,
        status: const DownloadStatus.completed(),
        localPath: '/downloads/1.mp3',
      ),
      'incrementRetryCount': (id) => repository.incrementRetryCount(id),
      'resetRetryCount': (id) => repository.resetRetryCount(id),
    };

    for (final MapEntry(key: name, value: write) in writers.entries) {
      test(name, () async {
        final task = await createAuto();

        await Future.wait([write(task.id), repository.markManual(task.id)]);

        final stored = await repository.getById(task.id);
        check(stored!.downloadOrigin).equals(DownloadOrigin.manual);
      });
    }

    test('writers still apply their own fields', () async {
      final task = await createAuto();

      await Future.wait([
        repository.updateProgress(
          id: task.id,
          downloadedBytes: 10,
          totalBytes: 20,
        ),
        repository.markManual(task.id),
        repository.incrementRetryCount(task.id),
      ]);

      final stored = await repository.getById(task.id);
      check(stored!.downloadedBytes).equals(10);
      check(stored.totalBytes).equals(20);
      check(stored.retryCount).equals(1);
    });

    test('writers do not recreate a deleted task', () async {
      final task = await createAuto();
      await repository.delete(task.id);

      await repository.updateStatus(
        id: task.id,
        status: const DownloadStatus.cancelled(),
      );

      check(await repository.getById(task.id)).isNull();
    });
  });

  group('deleteIfAuto', () {
    test('deletes an auto download and records its files for '
        'removal', () async {
      final task = await createAuto(status: const DownloadStatus.completed());
      await repository.updateStatus(
        id: task.id,
        status: const DownloadStatus.completed(),
        localPath: '/downloads/1_episode.mp3',
      );

      final deleted = await repository.deleteIfAuto(task.id);

      check(deleted).isNotNull()
        ..has((d) => d.task.id, 'task.id').equals(task.id)
        ..has((d) => d.fileRemoval.episodeId, 'episodeId').equals(1);
      check(await repository.getById(task.id)).isNull();
      final pending = await repository.getPendingFileRemovals();
      check(pending).length.equals(1);
      check(pending.single.storedPath).equals('/downloads/1_episode.mp3');
    });

    test('records no file removal for a kept task', () async {
      final task = await createAuto(status: const DownloadStatus.completed());
      await repository.markManual(task.id);

      await repository.deleteIfAuto(task.id);

      check(await repository.getPendingFileRemovals()).isEmpty();
    });

    test('leaves a task kept before the delete in place', () async {
      final task = await createAuto(status: const DownloadStatus.completed());
      await repository.markManual(task.id);

      check(await repository.deleteIfAuto(task.id)).isNull();
      check(await repository.getById(task.id)).isNotNull();
    });

    test('a keep after the delete reports no promotion', () async {
      final task = await createAuto(status: const DownloadStatus.completed());
      await repository.deleteIfAuto(task.id);

      check(await repository.markManual(task.id)).isFalse();
    });

    test('returns null for an unknown task', () async {
      check(await repository.deleteIfAuto(999)).isNull();
    });
  });

  group('removeEpisodeFiles', () {
    Future<DownloadTask?> requestDownload() => repository.createDownload(
      episodeId: 1,
      audioUrl: 'https://example.com/ep1.mp3',
      wifiOnly: true,
    );

    test('removes the files and drops the record', () async {
      final task = await createAuto(status: const DownloadStatus.completed());
      final deleted = await repository.deleteIfAuto(task.id);
      var removed = false;

      final ran = await repository.removeEpisodeFiles(
        episodeId: 1,
        fileRemovalId: deleted!.fileRemoval.id,
        removeFiles: () async => removed = true,
      );

      check(ran).isTrue();
      check(removed).isTrue();
      check(await repository.getPendingFileRemovals()).isEmpty();
    });

    test('deletes the given task with its files', () async {
      final task = await createAuto(status: const DownloadStatus.cancelled());

      final ran = await repository.removeEpisodeFiles(
        episodeId: 1,
        taskId: task.id,
        removeFiles: () async {},
      );

      check(ran).isTrue();
      check(await repository.getById(task.id)).isNull();
    });

    test('leaves the files of a download in progress, dropping the '
        'record', () async {
      final old = await createAuto(status: const DownloadStatus.completed());
      final deleted = await repository.deleteIfAuto(old.id);
      final current = await requestDownload();
      await repository.updateStatus(
        id: current!.id,
        status: const DownloadStatus.downloading(),
      );
      var removed = false;

      final ran = await repository.removeEpisodeFiles(
        episodeId: 1,
        fileRemovalId: deleted!.fileRemoval.id,
        removeFiles: () async => removed = true,
      );

      check(ran).isFalse();
      check(removed).isFalse();
      check(await repository.getPendingFileRemovals()).isEmpty();
    });

    test('a failed removal keeps the task and the record', () async {
      final task = await createAuto(status: const DownloadStatus.cancelled());
      final other = await repository.createDownload(
        episodeId: 2,
        audioUrl: 'https://example.com/ep2.mp3',
        wifiOnly: true,
        origin: DownloadOrigin.auto,
      );
      final deleted = await repository.deleteIfAuto(other!.id);

      await check(
        repository.removeEpisodeFiles(
          episodeId: 1,
          taskId: task.id,
          removeFiles: () async => throw const FormatException('disk'),
        ),
      ).throws<FormatException>();
      await check(
        repository.removeEpisodeFiles(
          episodeId: 2,
          fileRemovalId: deleted!.fileRemoval.id,
          removeFiles: () async => throw const FormatException('disk'),
        ),
      ).throws<FormatException>();

      check(await repository.getById(task.id)).isNotNull();
      check(await repository.getPendingFileRemovals()).length.equals(1);
    });

    test('a download requested after the check waits until the files are '
        'gone', () async {
      final old = await createAuto(status: const DownloadStatus.completed());
      final deleted = await repository.deleteIfAuto(old.id);
      final events = <String>[];
      final checked = Completer<void>();
      final release = Completer<void>();

      final removal = repository.removeEpisodeFiles(
        episodeId: 1,
        fileRemovalId: deleted!.fileRemoval.id,
        removeFiles: () async {
          // The task check has run by now; hold the removal open while the
          // listener requests the episode again.
          checked.complete();
          await release.future;
          events.add('removed');
        },
      );
      await checked.future;
      final request = requestDownload().then((task) {
        events.add('created');
        return task;
      });
      // Gives the request every chance to land inside the removal.
      await Future<void>.delayed(const Duration(milliseconds: 50));
      release.complete();

      check(await removal).isTrue();
      check(await request).isNotNull();
      check(events).deepEquals(['removed', 'created']);
    });
  });

  group('removeTasksWithFiles', () {
    Future<DownloadTask> request(int episodeId) async =>
        (await repository.createDownload(
          episodeId: episodeId,
          audioUrl: 'https://example.com/ep$episodeId.mp3',
          wifiOnly: true,
        ))!;

    Future<List<DownloadTask>> removeAll(
      List<int> taskIds, {
      bool Function(DownloadTask task)? isRemovable,
      List<List<int>>? removedEpisodes,
      Set<int> failed = const {},
    }) => repository.removeTasksWithFiles(
      taskIds: taskIds,
      isRemovable: isRemovable ?? (_) => true,
      removeFiles: (tasks) async {
        removedEpisodes?.add([for (final task in tasks) task.episodeId]);
        return failed;
      },
    );

    test('deletes the tasks and removes their episodes\' files', () async {
      final first = await request(1);
      final second = await request(2);
      final removed = <List<int>>[];

      final deleted = await removeAll([
        first.id,
        second.id,
      ], removedEpisodes: removed);

      check(deleted.map((task) => task.id)).deepEquals([first.id, second.id]);
      check(removed).deepEquals([
        [1, 2],
      ]);
      check(await repository.getAll()).isEmpty();
      check(await repository.getPendingFileRemovals()).isEmpty();
    });

    test('keeps a task the re-read finds not removable', () async {
      final task = await request(1);
      await repository.updateStatus(
        id: task.id,
        status: const DownloadStatus.completed(),
      );
      final removed = <List<int>>[];

      final deleted = await removeAll(
        [task.id],
        isRemovable: (task) => task.downloadStatus.isActive,
        removedEpisodes: removed,
      );

      check(deleted).isEmpty();
      check(removed).isEmpty();
      check(await repository.getById(task.id)).isNotNull();
    });

    test('leaves the files of an episode that still has a task', () async {
      final first = await request(1);
      final second = await request(2);
      final removed = <List<int>>[];

      await removeAll(
        [first.id, second.id],
        // Episode 2 was downloaded again under a task this call keeps.
        isRemovable: (task) => task.id == first.id,
        removedEpisodes: removed,
      );

      check(removed).deepEquals([
        [1],
      ]);
      check(await repository.getById(second.id)).isNotNull();
    });

    test('records files it could not remove for a retry', () async {
      final first = await request(1);
      final second = await request(2);

      await removeAll([first.id, second.id], failed: {2});

      check(await repository.getAll()).isEmpty();
      final pending = await repository.getPendingFileRemovals();
      check(pending.map((removal) => removal.episodeId)).deepEquals([2]);
    });

    test('a thrown removal keeps every task', () async {
      final first = await request(1);
      final second = await request(2);

      await check(
        repository.removeTasksWithFiles(
          taskIds: [first.id, second.id],
          isRemovable: (_) => true,
          removeFiles: (_) async => throw const FormatException('disk'),
        ),
      ).throws<FormatException>();

      check(await repository.getAll()).length.equals(2);
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
      expect(await repository.getById(task.id), isNull);
    });
  });

  group('getActiveCount', () {
    test('counts pending, downloading, and paused tasks', () async {
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

      expect(await repository.getActiveCount(), 3);
    });

    test('excludes completed and failed tasks', () async {
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

      expect(await repository.getActiveCount(), 0);
    });
  });

  group('getByEpisodeIds', () {
    test('returns only the tasks of the given episodes', () async {
      for (final episodeId in [1, 2, 3]) {
        await repository.createDownload(
          episodeId: episodeId,
          audioUrl: 'https://example.com/ep$episodeId.mp3',
          wifiOnly: false,
        );
      }

      final tasks = await repository.getByEpisodeIds([1, 3, 99]);

      check(tasks.map((t) => t.episodeId)).unorderedEquals([1, 3]);
    });

    test('returns nothing for no episodes', () async {
      await repository.createDownload(
        episodeId: 1,
        audioUrl: 'https://example.com/ep1.mp3',
        wifiOnly: false,
      );

      check(await repository.getByEpisodeIds(const [])).isEmpty();
    });
  });

  group('getAll', () {
    test('returns all tasks ordered by creation date', () async {
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
      expect(await repository.getAll(), isEmpty);
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

      expect(await repository.getCompletedForEpisode(1), isNull);
    });

    test('returns null for non-existent episode', () async {
      expect(await repository.getCompletedForEpisode(9999), isNull);
    });
  });

  group('getTotalStorageUsed', () {
    test('returns sum of totalBytes for completed downloads', () async {
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

      expect(await repository.getTotalStorageUsed(), equals(8000));
    });

    test('returns zero when no completed downloads exist', () async {
      await repository.createDownload(
        episodeId: 1,
        audioUrl: 'https://example.com/ep1.mp3',
        wifiOnly: false,
      );

      expect(await repository.getTotalStorageUsed(), equals(0));
    });
  });

  group('incrementRetryCount edge cases', () {
    test('does nothing for non-existent task', () async {
      await repository.incrementRetryCount(9999);
    });
  });
}
