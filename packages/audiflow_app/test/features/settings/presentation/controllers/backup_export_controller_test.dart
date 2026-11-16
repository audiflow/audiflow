import 'dart:io';
import 'dart:typed_data';

import 'package:audiflow_app/features/settings/presentation/controllers/backup_export_controller.dart';
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:checks/checks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';
import 'package:package_info_plus/package_info_plus.dart';

class _FakeSharer implements BackupSharer {
  _FakeSharer({this.sent = true, this.error});

  final bool sent;
  final Exception? error;
  Uint8List? bytes;
  String? fileName;

  @override
  Future<bool> share(Uint8List bytes, String fileName) async {
    this.bytes = bytes;
    this.fileName = fileName;
    if (error != null) throw error!;
    return sent;
  }
}

void main() {
  late Isar isar;
  late Directory dir;

  setUpAll(() async {
    await Isar.initializeIsarCore(download: true);
  });

  setUp(() async {
    dir = await Directory.systemTemp.createTemp('backup_export_test_');
    isar = await Isar.open(isarSchemas, directory: dir.path);
  });

  tearDown(() async {
    await isar.close(deleteFromDisk: true);
    await dir.delete(recursive: true);
  });

  ProviderContainer containerWith(BackupSharer sharer) {
    final container = ProviderContainer(
      overrides: [
        isarProvider.overrideWithValue(isar),
        packageInfoProvider.overrideWithValue(
          PackageInfo(
            appName: 'audiflow',
            packageName: 'com.example',
            version: '2.3.0',
            buildNumber: '1',
          ),
        ),
        backupSharerProvider.overrideWithValue(sharer),
      ],
    );
    addTearDown(container.dispose);
    // Keeps the auto-dispose controller alive across awaits.
    container.listen(backupExportControllerProvider, (_, _) {});
    return container;
  }

  test('shares a readable backup named by date', () async {
    final sharer = _FakeSharer();
    final container = containerWith(sharer);

    await container
        .read(backupExportControllerProvider.notifier)
        .export(now: DateTime(2026, 11, 15, 9));

    check(
      container.read(backupExportControllerProvider),
    ).isA<BackupExportSuccess>();
    check(sharer.fileName).equals('audiflow-20261115.audiflow-backup');
    final header = readSnapshotHeader(sharer.bytes!);
    check(header.appVersion).equals('2.3.0');
  });

  test('a dismissed share sheet goes back to idle', () async {
    final container = containerWith(_FakeSharer(sent: false));

    await container.read(backupExportControllerProvider.notifier).export();

    check(
      container.read(backupExportControllerProvider),
    ).isA<BackupExportIdle>();
  });

  test('a failure becomes an error state', () async {
    final container = containerWith(
      _FakeSharer(error: const FileSystemException('disk full')),
    );

    await container.read(backupExportControllerProvider.notifier).export();

    check(
      container.read(backupExportControllerProvider),
    ).isA<BackupExportError>();
  });
}
