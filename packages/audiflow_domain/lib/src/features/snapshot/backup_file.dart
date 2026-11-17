import 'dart:typed_data';

import 'package:isar_community/isar.dart';

import 'snapshot_exporter.dart';
import 'snapshot_file.dart';

/// The extension of a manual backup (plan decision D4).
const backupFileExtension = 'audiflow-backup';

/// `audiflow-YYYYMMDD.audiflow-backup`, by the local date of [now].
String backupFileName(DateTime now) {
  String two(int n) => n.toString().padLeft(2, '0');
  final date = '${now.year}${two(now.month)}${two(now.day)}';
  return 'audiflow-$date.$backupFileExtension';
}

/// A manual backup, ready to save.
class BackupFile {
  BackupFile(this.bytes, {this.unkeyedPodcasts = 0});

  final Uint8List bytes;

  /// Subscribed podcasts the file could not include (see
  /// [ExportedSnapshot.unkeyedPodcasts]), so the user can be told.
  final int unkeyedPodcasts;
}

/// Builds a manual backup of this device's user data.
Future<BackupFile> buildBackupFile(
  Isar isar, {
  required DateTime now,
  required String appVersion,
  required String platform,
}) async {
  final exported = await SnapshotExporter(isar).export();
  final bytes = encodeSnapshotFile(
    body: exported.body,
    createdAt: now,
    historyId: exported.historyId,
    appVersion: appVersion,
    platform: platform,
    counts: exported.counts,
    tombstoneHorizon: exported.tombstoneHorizon,
  );
  return BackupFile(bytes, unkeyedPodcasts: exported.unkeyedPodcasts);
}
