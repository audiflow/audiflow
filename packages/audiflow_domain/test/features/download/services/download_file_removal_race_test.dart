import 'dart:async';
import 'dart:io';

import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:audiflow_domain/src/features/download/services/episode_download_files.dart';
import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';
import 'package:logger/logger.dart';
import 'package:path/path.dart' as p;

import '../../../helpers/isar_test_helper.dart';

/// Every download of an episode writes the same file name, so these tests
/// pause a file removal right after its task check and land a new download
/// of the same episode there, against a real Isar and a real directory.

const _episodeId = 10;
const _fileName = '${_episodeId}_Episode.mp3';

/// Holds a file removal open after its task check until [release].
class _Gate {
  final _entered = Completer<void>();
  final _released = Completer<void>();

  Future<void> get entered => _entered.future;

  Future<void> pass() async {
    _entered.complete();
    await _released.future;
  }

  void release() => _released.complete();
}

class _FakeQueueService implements DownloadQueueService {
  @override
  Future<void> cancelDownload(int taskId) async {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// Sweeps [downloadsDir] for real, pausing at [gate] first when set.
class _GatedFileService implements DownloadFileService {
  _GatedFileService(this.downloadsDir);

  final String downloadsDir;
  _Gate? gate;

  @override
  Future<void> deleteEpisodeFiles(int episodeId, {String? storedPath}) async {
    await gate?.pass();
    await deleteEpisodeDownloadFiles(
      downloadsDir: downloadsDir,
      episodeId: episodeId,
      storedPath: storedPath,
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _UnusedEpisodeRepository implements EpisodeRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _UnusedSubscriptionRepository implements SubscriptionRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late Isar isar;
  late DownloadRepositoryImpl repository;
  late Directory downloadsDir;
  late _GatedFileService fileService;

  setUpAll(() async {
    await Isar.initializeIsarCore(download: true);
  });

  setUp(() async {
    isar = await openTestIsar([DownloadTaskSchema, DownloadFileRemovalSchema]);
    repository = DownloadRepositoryImpl(
      datasource: DownloadLocalDatasource(isar),
    );
    downloadsDir = await Directory.systemTemp.createTemp('audiflow_dl_');
    fileService = _GatedFileService(downloadsDir.path);
  });

  tearDown(() async {
    await isar.close(deleteFromDisk: true);
    await downloadsDir.delete(recursive: true);
  });

  File downloadFile() => File(p.join(downloadsDir.path, _fileName));

  Future<DownloadTask> createTask({
    DownloadOrigin origin = DownloadOrigin.auto,
    DownloadStatus status = const DownloadStatus.completed(),
  }) async {
    final task = await repository.createDownload(
      episodeId: _episodeId,
      audioUrl: 'https://example.com/$_episodeId.mp3',
      wifiOnly: false,
      origin: origin,
    );
    await repository.updateStatus(id: task!.id, status: status);
    return task;
  }

  /// Requests the episode again and, as the queue would, writes its file
  /// once the task exists.
  Future<void> downloadAgain() async {
    final task = await repository.createDownload(
      episodeId: _episodeId,
      audioUrl: 'https://example.com/$_episodeId.mp3',
      wifiOnly: false,
    );
    check(task).isNotNull();
    await downloadFile().writeAsString('new');
  }

  DownloadFileRemover remover() => DownloadFileRemover(
    repository: repository,
    deleteEpisodeFiles: (episodeId, storedPath) =>
        fileService.deleteEpisodeFiles(episodeId, storedPath: storedPath),
  );

  test('a download requested while the old files are removed keeps its '
      'file', () async {
    await downloadFile().writeAsString('old');
    final old = await createTask();
    final deleted = await repository.deleteIfAuto(old.id);
    final gate = fileService.gate = _Gate();

    final removal = remover().remove(deleted!.fileRemoval);
    await gate.entered;
    final request = downloadAgain();
    await Future<void>.delayed(const Duration(milliseconds: 50));
    gate.release();
    await removal;
    await request;

    check(await downloadFile().readAsString()).equals('new');
    check(await repository.getPendingFileRemovals()).isEmpty();
  });

  test('a download requested while a deleted download is removed keeps its '
      'file', () async {
    await downloadFile().writeAsString('old');
    // A cancelled download may be replaced by a new request at any time.
    final old = await createTask(
      origin: DownloadOrigin.manual,
      status: const DownloadStatus.cancelled(),
    );
    final service = DownloadService(
      repository: repository,
      queueService: _FakeQueueService(),
      fileService: fileService,
      episodeRepository: _UnusedEpisodeRepository(),
      subscriptionRepository: _UnusedSubscriptionRepository(),
      logger: Logger(level: Level.off),
      getWifiOnly: () => false,
      getBatchDownloadLimit: () => 10,
    );
    final gate = fileService.gate = _Gate();

    final deletion = service.delete(old.id);
    await gate.entered;
    final request = downloadAgain();
    await Future<void>.delayed(const Duration(milliseconds: 50));
    gate.release();
    await deletion;
    await request;

    check(await downloadFile().readAsString()).equals('new');
    final current = await repository.getByEpisodeId(_episodeId);
    check(current)
        .isNotNull()
        .has((t) => t.downloadStatus, 'status')
        .equals(const DownloadStatus.pending());
  });

  test('a pending removal leaves the partial file of a running '
      'download', () async {
    final old = await createTask();
    await repository.deleteIfAuto(old.id);
    // The episode was downloaded again and is mid-transfer, writing the
    // same file name the old download used.
    await createTask(
      origin: DownloadOrigin.manual,
      status: const DownloadStatus.downloading(),
    );
    await downloadFile().writeAsString('partial');

    check(await remover().retryPending()).equals(1);

    check(await downloadFile().readAsString()).equals('partial');
    check(await repository.getPendingFileRemovals()).isEmpty();
  });
}
