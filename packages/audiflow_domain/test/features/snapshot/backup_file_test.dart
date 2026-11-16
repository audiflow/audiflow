import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart' hide expect;
import 'package:isar_community/isar.dart';

import '../../helpers/isar_test_helper.dart';

void main() {
  test('names the file by local date', () {
    check(
      backupFileName(DateTime(2026, 3, 7, 23, 59)),
    ).equals('audiflow-20260307.audiflow-backup');
  });

  group('buildBackupFile', () {
    late Isar isar;

    setUpAll(() async {
      await Isar.initializeIsarCore(download: true);
    });

    setUp(() async {
      isar = await openTestIsar(isarSchemas);
    });

    tearDown(() async {
      await isar.close(deleteFromDisk: true);
    });

    test('writes a file that reads back with its header', () async {
      await isar.writeTxn(() async {
        await isar.syncMetas.put(
          SyncMeta()
            ..historyId = 'h1'
            ..tombstoneHorizon = 9,
        );
        await isar.podcastUserStates.put(
          PodcastUserState()
            ..podcastKey = 'pk'
            ..subscribed = true
            ..subscribedHlc = 5,
        );
      });

      final bytes = await buildBackupFile(
        isar,
        now: DateTime.utc(2026, 11, 15),
        appVersion: '2.3.0',
        platform: 'android',
      );
      final file = readSnapshotFile(bytes);

      check(file.header.historyId).equals('h1');
      check(file.header.tombstoneHorizon).equals(9);
      check(file.header.platform).equals('android');
      check(file.header.appVersion).equals('2.3.0');
      check(file.header.counts.podcasts).equals(1);
      check(file.body.sections['podcast']!.single.key).equals('pk');
    });
  });
}
