import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';
import 'package:riverpod/riverpod.dart';

import '../../../helpers/isar_test_helper.dart';

void main() {
  late Isar isar;
  late DownloadRepositoryImpl repository;
  late ProviderContainer container;

  setUpAll(() async {
    await Isar.initializeIsarCore(download: true);
  });

  setUp(() async {
    isar = await openTestIsar([DownloadTaskSchema]);
    repository = DownloadRepositoryImpl(
      datasource: DownloadLocalDatasource(isar),
    );
    container = ProviderContainer(
      overrides: [downloadRepositoryProvider.overrideWithValue(repository)],
    );
  });

  tearDown(() async {
    container.dispose();
    await isar.close(deleteFromDisk: true);
  });

  Future<int> createTask(int episodeId) async {
    final task = await repository.createDownload(
      episodeId: episodeId,
      audioUrl: 'https://example.com/$episodeId.mp3',
      wifiOnly: false,
    );
    return task!.id;
  }

  Future<void> complete(int taskId) => repository.updateStatus(
    id: taskId,
    status: const DownloadStatus.completed(),
    localPath: '/tmp/$taskId.mp3',
  );

  /// Waits for the provider to emit [expected], failing after a timeout.
  Future<void> expectIds(Set<int> expected) async {
    final subscription = container.listen(
      completedDownloadEpisodeIdsProvider,
      (_, _) {},
    );
    addTearDown(subscription.close);
    for (var attempt = 0; attempt < 50; attempt++) {
      final value = subscription.read().value;
      if (value != null && value.length == expected.length) {
        if (value.containsAll(expected)) return;
      }
      await Future<void>.delayed(const Duration(milliseconds: 20));
    }
    check(subscription.read().value).isNotNull().deepEquals(expected);
  }

  group('completedDownloadEpisodeIds', () {
    test('lists only episodes whose download completed', () async {
      final first = await createTask(1);
      await createTask(2);
      await complete(first);

      await expectIds({1});
    });

    test('updates when a download completes or is removed', () async {
      final first = await createTask(1);
      await expectIds({});

      await complete(first);
      await expectIds({1});

      await repository.delete(first);
      await expectIds({});
    });
  });
}
