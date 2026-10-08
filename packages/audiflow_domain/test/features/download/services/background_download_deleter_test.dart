import 'dart:io';

import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fake_background_download_worker_lock.dart';
import '../../../helpers/fake_download_repository.dart';

void main() {
  late Directory downloadsDir;
  late FakeDownloadRepository repository;
  late FakeBackgroundDownloadWorkerLock lock;
  late List<int> changedEpisodeIds;
  late BackgroundDownloadDeleter deleter;

  setUp(() async {
    downloadsDir = await Directory.systemTemp.createTemp('bg_deleter_');
    repository = FakeDownloadRepository();
    lock = FakeBackgroundDownloadWorkerLock();
    changedEpisodeIds = [];
    deleter = BackgroundDownloadDeleter(
      downloadRepository: repository,
      downloadsDir: downloadsDir.path,
      lock: lock,
      onDeleted: (episodeId) async => changedEpisodeIds.add(episodeId),
    );
  });

  tearDown(() => downloadsDir.delete(recursive: true));

  /// Stores a task for episode 10 and returns a copy, as a caller that
  /// read it earlier would hold.
  DownloadTask storeTask({required DownloadStatus status, String? localPath}) {
    repository.tasks.add(
      fakeDownloadTask(
        episodeId: 10,
        id: 1,
        status: status,
        localPath: localPath,
      ),
    );
    return fakeDownloadTask(
      episodeId: 10,
      id: 1,
      status: status,
      localPath: localPath,
    );
  }

  test('deletes the file at its current location even when the stored '
      'container path is stale', () async {
    final file = File('${downloadsDir.path}/10_episode.mp3')
      ..writeAsStringSync('audio');

    await deleter(
      storeTask(
        status: const DownloadStatus.completed(),
        localPath: '/old-container/Documents/downloads/10_episode.mp3',
      ),
    );

    check(file.existsSync()).isFalse();
    check(repository.tasks).isEmpty();
    check(changedEpisodeIds).deepEquals([10]);
  });

  test('removes the partial file of a task that recorded no path', () async {
    // A paused or cancelled task has no localPath; its partial file is
    // still named after the episode.
    final partial = File('${downloadsDir.path}/10_Episode_Title.mp3')
      ..writeAsStringSync('partial');

    await deleter(storeTask(status: const DownloadStatus.paused()));

    check(partial.existsSync()).isFalse();
    check(repository.tasks).isEmpty();
  });

  test('removes the record when there is no file', () async {
    await deleter(storeTask(status: const DownloadStatus.pending()));

    check(repository.tasks).isEmpty();
    check(lock.acquireCount).equals(1);
    check(lock.isHeld).isFalse();
  });

  test('leaves a task that is actively downloading alone', () async {
    await deleter(storeTask(status: const DownloadStatus.downloading()));

    check(repository.tasks).length.equals(1);
    check(changedEpisodeIds).isEmpty();
    check(lock.isHeld).isFalse();
  });

  test(
    'leaves the task alone while a download worker holds the lock',
    () async {
      // The worker may be about to start this pending task; its file would
      // outlive a record deleted now.
      final partial = File('${downloadsDir.path}/10_Episode.mp3')
        ..writeAsStringSync('partial');
      lock.isHeldElsewhere = true;

      await deleter(storeTask(status: const DownloadStatus.pending()));

      check(partial.existsSync()).isTrue();
      check(repository.tasks).length.equals(1);
      check(changedEpisodeIds).isEmpty();
    },
  );

  test('judges the task by its record once the lock is held, not by the '
      'copy it was given', () async {
    final staleCopy = storeTask(status: const DownloadStatus.pending());
    // A worker started the task after the caller read it.
    lock.onAcquired = () async {
      repository.tasks.single.status = const DownloadStatus.downloading()
          .toDbValue();
    };

    await deleter(staleCopy);

    check(repository.tasks).length.equals(1);
    check(changedEpisodeIds).isEmpty();
  });

  test('does nothing for a task whose record is already gone', () async {
    await deleter(
      fakeDownloadTask(episodeId: 10, status: const DownloadStatus.pending()),
    );

    check(changedEpisodeIds).isEmpty();
    check(lock.isHeld).isFalse();
  });

  group('deleteAuto', () {
    DownloadTask storeAuto({
      DownloadStatus status = const DownloadStatus.completed(),
      DownloadOrigin origin = DownloadOrigin.auto,
      String? localPath,
    }) {
      final task = fakeDownloadTask(
        episodeId: 10,
        id: 1,
        status: status,
        origin: origin,
        localPath: localPath,
      );
      repository.tasks.add(task);
      return fakeDownloadTask(
        episodeId: 10,
        id: 1,
        status: status,
        origin: DownloadOrigin.auto,
        localPath: localPath,
      );
    }

    test('removes an auto download and its files', () async {
      final file = File('${downloadsDir.path}/10_episode.mp3')
        ..writeAsStringSync('audio');

      final deleted = await deleter.deleteAuto(
        storeAuto(localPath: '${downloadsDir.path}/10_episode.mp3'),
      );

      check(deleted).isTrue();
      check(file.existsSync()).isFalse();
      check(repository.tasks).isEmpty();
      check(changedEpisodeIds).deepEquals([10]);
      check(lock.isHeld).isFalse();
    });

    test('leaves a task that is actively downloading alone', () async {
      final task = storeAuto(status: const DownloadStatus.downloading());

      check(await deleter.deleteAuto(task)).isFalse();
      check(repository.tasks).length.equals(1);
      check(changedEpisodeIds).isEmpty();
    });

    test('keeps the file of a task promoted after the caller checked '
        'it', () async {
      final file = File('${downloadsDir.path}/10_episode.mp3')
        ..writeAsStringSync('audio');
      // The caller saw an auto task; a keep request promoted it since.
      final listed = storeAuto(
        origin: DownloadOrigin.manual,
        localPath: '${downloadsDir.path}/10_episode.mp3',
      );

      check(await deleter.deleteAuto(listed)).isFalse();

      check(file.existsSync()).isTrue();
      check(repository.tasks).length.equals(1);
      check(changedEpisodeIds).isEmpty();
    });
  });
}
