import 'dart:io';

import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fake_download_repository.dart';

void main() {
  late FakeDownloadRepository repository;
  late List<(int, String?)> sweeps;
  late int failuresLeft;
  late DownloadFileRemover remover;

  setUp(() {
    repository = FakeDownloadRepository();
    sweeps = [];
    failuresLeft = 0;
    remover = DownloadFileRemover(
      repository: repository,
      deleteEpisodeFiles: (episodeId, storedPath) async {
        if (0 < failuresLeft) {
          failuresLeft--;
          throw const FileSystemException('Operation not permitted');
        }
        sweeps.add((episodeId, storedPath));
      },
    );
  });

  /// Deletes an auto download of [episodeId] the way retention does and
  /// returns the file removal it recorded.
  Future<DownloadFileRemoval> deleteAuto(int episodeId) async {
    repository.tasks.add(
      fakeDownloadTask(
        episodeId: episodeId,
        origin: DownloadOrigin.auto,
        localPath: '/downloads/${episodeId}_episode.mp3',
      ),
    );
    final deleted = await repository.deleteIfAuto(episodeId);
    return deleted!.fileRemoval;
  }

  test('removes the files and drops the record', () async {
    final removal = await deleteAuto(10);

    check(await remover.remove(removal)).isTrue();

    check(sweeps).deepEquals([(10, '/downloads/10_episode.mp3')]);
    check(repository.fileRemovals).isEmpty();
  });

  test('keeps the record when the files cannot be removed', () async {
    final removal = await deleteAuto(10);
    failuresLeft = 1;

    check(await remover.remove(removal)).isFalse();

    check(repository.fileRemovals).length.equals(1);
  });

  test('a retry after a failure removes the files', () async {
    final removal = await deleteAuto(10);
    failuresLeft = 1;
    await remover.remove(removal);

    check(await remover.retryPending()).equals(1);

    check(sweeps).deepEquals([(10, '/downloads/10_episode.mp3')]);
    check(repository.fileRemovals).isEmpty();
  });

  test('one failing removal does not hold up the others', () async {
    await deleteAuto(10);
    await deleteAuto(11);
    failuresLeft = 1;

    check(await remover.retryPending()).equals(1);

    check(sweeps).deepEquals([(11, '/downloads/11_episode.mp3')]);
    check(repository.fileRemovals.single.episodeId).equals(10);
  });

  test('leaves the files of a download requested since', () async {
    final removal = await deleteAuto(10);
    repository.tasks.add(fakeDownloadTask(episodeId: 10, id: 99));

    check(await remover.remove(removal)).isTrue();

    check(sweeps).isEmpty();
    check(repository.fileRemovals).isEmpty();
  });
}
