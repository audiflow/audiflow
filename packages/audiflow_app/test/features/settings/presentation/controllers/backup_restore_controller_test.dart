import 'dart:io';
import 'dart:typed_data';

import 'package:audiflow_app/features/settings/presentation/controllers/backup_restore_controller.dart';
import 'package:audiflow_app/features/settings/services/backup_file_picker.dart';
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:checks/checks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';
import 'package:logger/logger.dart';

class _FakePicker implements BackupFilePicker {
  _FakePicker(this.bytes);

  /// Null means the user cancelled.
  final Future<Uint8List> Function()? bytes;

  @override
  Future<PickedBackupFile?> pick() async =>
      bytes == null ? null : PickedBackupFile(bytes!);
}

void main() {
  late Isar isar;
  late Directory dir;

  setUpAll(() async {
    await Isar.initializeIsarCore(download: true);
  });

  setUp(() async {
    dir = await Directory.systemTemp.createTemp('backup_restore_test_');
    isar = await Isar.open(isarSchemas, directory: dir.path);
  });

  tearDown(() async {
    if (isar.isOpen) await isar.close(deleteFromDisk: true);
    await dir.delete(recursive: true);
  });

  Uint8List backupBytes() => encodeSnapshotFile(
    body: SnapshotBody({}),
    createdAt: DateTime.utc(2026, 11, 17),
    historyId: 'h',
    appVersion: '2.3.0',
    platform: 'ios',
    counts: SnapshotCounts(podcasts: 0, episodes: 0, queue: 0, stations: 0),
  );

  ProviderContainer containerWith(BackupFilePicker picker) {
    final container = ProviderContainer(
      overrides: [
        backupFilePickerProvider.overrideWithValue(picker),
        backupRestoreServiceProvider.overrideWithValue(
          BackupRestoreService(
            isar: isar,
            stopPlayback: () async {},
            cancelBackgroundTasks: () async {},
            writers: const [],
            syncFeeds: (_) async {},
            onStationChanged: (_) async {},
            logger: Logger(level: Level.off),
          ),
        ),
      ],
    );
    addTearDown(container.dispose);
    // Keeps the auto-dispose controller alive across awaits.
    container.listen(backupRestoreControllerProvider, (_, _) {});
    return container;
  }

  Future<BackupPickOutcome> pickWith(Future<Uint8List> Function()? bytes) =>
      containerWith(
        _FakePicker(bytes),
      ).read(backupRestoreControllerProvider.notifier).pick();

  test('a cancelled picker is a cancel', () async {
    check(await pickWith(null)).isA<BackupPickCancelled>();
  });

  test('a valid file comes back with its header', () async {
    final outcome = await pickWith(() async => backupBytes());

    check(outcome)
        .isA<BackupPicked>()
        .has((o) => o.file.header.platform, 'platform')
        .equals('ios');
  });

  test('a file that is not a backup says so', () async {
    final outcome = await pickWith(() async => Uint8List.fromList([1, 2]));

    check(outcome)
        .isA<BackupPickFailed>()
        .has((o) => o.failure, 'failure')
        .equals(BackupPickFailure.notABackup);
  });

  test('a truncated file is damaged', () async {
    final bytes = backupBytes();
    final outcome = await pickWith(
      () async => Uint8List.sublistView(bytes, 0, bytes.length - 4),
    );

    check(outcome)
        .isA<BackupPickFailed>()
        .has((o) => o.failure, 'failure')
        .equals(BackupPickFailure.damaged);
  });

  test('a file that cannot be read is unreadable', () async {
    final outcome = await pickWith(
      () async => throw const FormatException('gone'),
    );

    check(outcome)
        .isA<BackupPickFailed>()
        .has((o) => o.failure, 'failure')
        .equals(BackupPickFailure.unreadable);
  });

  test('a restore ends done', () async {
    final container = containerWith(_FakePicker(null));
    final file = readSnapshotFile(backupBytes());

    await container
        .read(backupRestoreControllerProvider.notifier)
        .restore(file);

    check(
      container.read(backupRestoreControllerProvider),
    ).isA<BackupRestoreDone>();
  });

  test('a failed merge ends in an error', () async {
    final container = containerWith(_FakePicker(null));
    final file = readSnapshotFile(backupBytes());
    await isar.close();

    await container
        .read(backupRestoreControllerProvider.notifier)
        .restore(file);

    check(
      container.read(backupRestoreControllerProvider),
    ).isA<BackupRestoreError>();
  });
}
