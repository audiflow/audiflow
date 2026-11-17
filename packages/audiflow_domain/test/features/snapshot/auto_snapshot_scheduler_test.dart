import 'dart:async';
import 'dart:io';

import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart' hide expect;
import 'package:isar_community/isar.dart';
import 'package:logger/logger.dart';
import 'package:path/path.dart' as p;

import '../../helpers/isar_test_helper.dart';

void main() {
  late Isar isar;
  late Directory dir;
  late DateTime now;

  setUpAll(() async {
    await Isar.initializeIsarCore(download: true);
  });

  setUp(() async {
    isar = await openTestIsar(isarSchemas);
    dir = await Directory.systemTemp.createTemp('audiflow_snapshot_');
    now = DateTime.utc(2026, 11, 17, 9);
  });

  tearDown(() async {
    await isar.close(deleteFromDisk: true);
    if (await dir.exists()) await dir.delete(recursive: true);
  });

  String target() => p.join(dir.path, continuitySnapshotFileName);

  AutoSnapshotScheduler scheduler({ContinuitySnapshotPathResolver? path}) =>
      AutoSnapshotScheduler(
        isar: isar,
        resolveSnapshotPath: path ?? () async => target(),
        appVersion: () => '2.3.0',
        platform: 'ios',
        logger: Logger(level: Level.off),
        clock: () => now,
      );

  Future<void> seed({required int hlc}) async {
    await isar.writeTxn(() async {
      final meta =
          await isar.syncMetas.get(SyncMeta.singletonId) ??
          (SyncMeta()..historyId = 'h1');
      await isar.syncMetas.put(meta..hlc = hlc);
      // A new podcast per call: each call stands for a later change.
      await isar.podcastUserStates.put(
        PodcastUserState()
          ..podcastKey = 'pk$hlc'
          ..subscribed = true
          ..subscribedHlc = hlc,
      );
    });
  }

  Future<int> lastSnapshotHlc() async =>
      (await isar.syncMetas.get(SyncMeta.singletonId))!.lastSnapshotHlc;

  test('writes a snapshot that reads back and records its hlc', () async {
    await seed(hlc: 7);

    final outcome = await scheduler().onBackground();

    check(outcome).equals(AutoSnapshotOutcome.written);
    final file = readSnapshotFile(await File(target()).readAsBytes());
    check(file.header.historyId).equals('h1');
    check(file.header.counts.podcasts).equals(1);
    check(file.header.platform).equals('ios');
    check(await lastSnapshotHlc()).equals(7);
  });

  test('skips when nothing changed since the last write', () async {
    await seed(hlc: 7);
    final s = scheduler();
    await s.onBackground();
    now = now.add(const Duration(hours: 1));

    check(await s.onBackground()).equals(AutoSnapshotOutcome.unchanged);
  });

  test('writes again once something changed', () async {
    await seed(hlc: 7);
    final s = scheduler();
    await s.onBackground();
    await seed(hlc: 9);
    now = now.add(const Duration(minutes: 15));

    check(await s.onBackground()).equals(AutoSnapshotOutcome.written);
    check(await lastSnapshotHlc()).equals(9);
  });

  test('skips within 15 minutes of the last write', () async {
    await seed(hlc: 7);
    final s = scheduler();
    await s.onBackground();
    await seed(hlc: 9);
    now = now.add(const Duration(minutes: 14, seconds: 59));

    check(await s.onBackground()).equals(AutoSnapshotOutcome.tooSoon);
    check(await lastSnapshotHlc()).equals(7);
  });

  test('writes when the file is missing even if the hlc matches', () async {
    // An install upgraded from before snapshots, or a file removed by hand:
    // the recorded hlc alone would never write one.
    await seed(hlc: 7);
    await isar.writeTxn(() async {
      final meta = (await isar.syncMetas.get(SyncMeta.singletonId))!;
      await isar.syncMetas.put(meta..lastSnapshotHlc = 7);
    });

    check(await scheduler().onBackground()).equals(AutoSnapshotOutcome.written);
    check(await File(target()).exists()).isTrue();
  });

  test('writes nothing for a database without user data', () async {
    await isar.writeTxn(
      () => isar.syncMetas.put(
        SyncMeta()
          ..historyId = 'h1'
          ..hlc = 3,
      ),
    );

    check(await scheduler().onBackground()).equals(AutoSnapshotOutcome.empty);
    check(await File(target()).exists()).isFalse();
  });

  test('replaces an existing file and leaves no temporary file', () async {
    await File(target()).writeAsString('old snapshot');
    await seed(hlc: 7);

    await scheduler().onBackground();

    final names = await dir.list().map((e) => p.basename(e.path)).toList();
    check(names).deepEquals([continuitySnapshotFileName]);
    check(
      readSnapshotFile(await File(target()).readAsBytes()).header.historyId,
    ).equals('h1');
  });

  test('never throws on I/O failure and keeps the old file', () async {
    await seed(hlc: 7);
    // A directory where the temporary file should go makes the write fail.
    await Directory('${target()}.tmp').create();
    await File(target()).writeAsString('old snapshot');

    final outcome = await scheduler().onBackground();

    check(outcome).equals(AutoSnapshotOutcome.failed);
    check(await File(target()).readAsString()).equals('old snapshot');
    check(await lastSnapshotHlc()).equals(0);
  });

  test('never throws when the path cannot be resolved', () async {
    await seed(hlc: 7);

    final outcome = await scheduler(
      path: () async => throw const FileSystemException('no support dir'),
    ).onBackground();

    check(outcome).equals(AutoSnapshotOutcome.failed);
  });

  test('a failed write is retried without waiting 15 minutes', () async {
    await seed(hlc: 7);
    final blocker = Directory('${target()}.tmp');
    await blocker.create();
    final s = scheduler();
    await s.onBackground();
    await blocker.delete();

    check(await s.onBackground()).equals(AutoSnapshotOutcome.written);
  });

  test('writes nothing while suspended', () async {
    await seed(hlc: 7);
    final s = scheduler();

    await s.suspend();
    check(await s.onBackground()).equals(AutoSnapshotOutcome.suspended);
    s.resume();

    check(await s.onBackground()).equals(AutoSnapshotOutcome.written);
  });

  test('suspend waits for a write in flight', () async {
    await seed(hlc: 7);
    final gate = Completer<void>();
    final s = AutoSnapshotScheduler(
      isar: isar,
      resolveSnapshotPath: () async {
        await gate.future;
        return target();
      },
      appVersion: () => '2.3.0',
      platform: 'ios',
      logger: Logger(level: Level.off),
      clock: () => now,
    );

    final write = s.onBackground();
    var suspended = false;
    final suspending = s.suspend().then((_) => suspended = true);
    await Future<void>.delayed(Duration.zero);
    check(suspended).isFalse();

    gate.complete();
    await write;
    await suspending;
    check(suspended).isTrue();
  });
}
