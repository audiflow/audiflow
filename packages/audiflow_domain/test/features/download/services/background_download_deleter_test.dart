import 'dart:io';

import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeDownloadRepository implements DownloadRepository {
  final List<int> deletedIds = [];

  @override
  Future<void> delete(int id) async => deletedIds.add(id);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

DownloadTask _task({required DownloadStatus status, String? localPath}) {
  return DownloadTask()
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

    await deleter(
      _task(
        status: const DownloadStatus.completed(),
        localPath: '/old-container/Documents/downloads/10_episode.mp3',
      ),
    );

    check(file.existsSync()).isFalse();
    check(repository.deletedIds).deepEquals([1]);
    check(changedEpisodeIds).deepEquals([10]);
  });

  test('removes the partial file of a task that recorded no path', () async {
    // A paused or cancelled task has no localPath; its partial file is
    // still named after the episode.
    final partial = File('${downloadsDir.path}/10_Episode_Title.mp3')
      ..writeAsStringSync('partial');

    await deleter(_task(status: const DownloadStatus.paused()));

    check(partial.existsSync()).isFalse();
    check(repository.deletedIds).deepEquals([1]);
  });

  test('removes the record when there is no file', () async {
    await deleter(_task(status: const DownloadStatus.pending()));

    check(repository.deletedIds).deepEquals([1]);
  });

  test('leaves a task that is actively downloading alone', () async {
    await deleter(_task(status: const DownloadStatus.downloading()));

    check(repository.deletedIds).isEmpty();
    check(changedEpisodeIds).isEmpty();
  });
}
