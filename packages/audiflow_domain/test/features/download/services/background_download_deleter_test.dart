import 'dart:io';

import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeDownloadRepository implements DownloadRepository {
  final List<int> deletedIds = [];

  /// The stored row; null once deleted or when the task is unknown.
  DownloadTask? stored;

  @override
  Future<DownloadTask?> deleteIfAuto(int id) async {
    final task = stored;
    if (task == null || task.downloadOrigin != DownloadOrigin.auto) {
      return null;
    }
    stored = null;
    deletedIds.add(id);
    return task;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

DownloadTask _task({
  required DownloadStatus status,
  String? localPath,
  DownloadOrigin origin = DownloadOrigin.auto,
}) {
  return DownloadTask()
    ..origin = origin.dbValue
    ..id = 1
    ..episodeId = 10
    ..audioUrl = 'https://example.com/10.mp3'
    ..status = status.toDbValue()
    ..localPath = localPath
    ..createdAt = DateTime(2026);
}

void main() {
  late Directory downloadsDir;
  late _FakeDownloadRepository repository;
  late List<int> changedEpisodeIds;
  late BackgroundDownloadDeleter deleter;

  setUp(() async {
    downloadsDir = await Directory.systemTemp.createTemp('bg_deleter_');
    repository = _FakeDownloadRepository();
    changedEpisodeIds = [];
    deleter = BackgroundDownloadDeleter(
      downloadRepository: repository,
      downloadsDir: downloadsDir.path,
      onDeleted: (episodeId) async => changedEpisodeIds.add(episodeId),
    );
  });

  tearDown(() => downloadsDir.delete(recursive: true));

  test('deletes the file at its current location even when the stored '
      'container path is stale', () async {
    final file = File('${downloadsDir.path}/10_episode.mp3')
      ..writeAsStringSync('audio');
    final task = repository.stored = _task(
      status: const DownloadStatus.completed(),
      localPath: '/old-container/Documents/downloads/10_episode.mp3',
    );

    check(await deleter(task)).isTrue();

    check(file.existsSync()).isFalse();
    check(repository.deletedIds).deepEquals([1]);
    check(changedEpisodeIds).deepEquals([10]);
  });

  test('removes the record when there is no file', () async {
    final task = repository.stored = _task(
      status: const DownloadStatus.pending(),
    );

    check(await deleter(task)).isTrue();
    check(repository.deletedIds).deepEquals([1]);
  });

  test('leaves a task that is actively downloading alone', () async {
    final task = repository.stored = _task(
      status: const DownloadStatus.downloading(),
    );

    check(await deleter(task)).isFalse();

    check(repository.deletedIds).isEmpty();
    check(changedEpisodeIds).isEmpty();
  });

  test(
    'keeps the file of a task promoted after the caller checked it',
    () async {
      final file = File('${downloadsDir.path}/10_episode.mp3')
        ..writeAsStringSync('audio');
      final listed = _task(
        status: const DownloadStatus.completed(),
        localPath: '${downloadsDir.path}/10_episode.mp3',
      );
      // The caller saw an auto task; a keep request promoted it since.
      repository.stored = _task(
        status: const DownloadStatus.completed(),
        localPath: listed.localPath,
        origin: DownloadOrigin.manual,
      );

      check(await deleter(listed)).isFalse();

      check(file.existsSync()).isTrue();
      check(repository.deletedIds).isEmpty();
      check(changedEpisodeIds).isEmpty();
    },
  );
}
