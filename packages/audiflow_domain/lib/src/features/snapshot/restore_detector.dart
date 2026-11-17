import 'dart:async';
import 'dart:io';

import 'package:isar_community/isar.dart';
import 'package:logger/logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../common/providers/database_provider.dart';
import '../../common/providers/logger_provider.dart';
import 'backup_restore_service.dart';
import 'continuity_snapshot.dart';
import 'snapshot_file.dart';

part 'restore_detector.g.dart';

/// Provides the [RestoreDetector] run once at launch.
@Riverpod(keepAlive: true)
RestoreDetector restoreDetector(Ref ref) => RestoreDetector(
  isar: ref.watch(isarProvider),
  resolveSnapshotPath: ref.watch(continuitySnapshotPathProvider),
  restoreService: ref.watch(backupRestoreServiceProvider),
  logger: ref.watch(namedLoggerProvider('RestoreDetector')),
);

/// Provides the [ContinuityRestoreNotice] the launch restore raises.
@Riverpod(keepAlive: true)
ContinuityRestoreNotice continuityRestoreNotice(Ref ref) =>
    ContinuityRestoreNotice();

/// One-shot flag behind "Your data was carried over from your previous
/// device".
///
/// Held in memory only: once the restore fills the database, no later
/// launch restores again, so there is nothing to remember across launches.
class ContinuityRestoreNotice {
  bool _pending = false;

  /// Marks the notice as due.
  void raise() => _pending = true;

  /// Returns whether the notice is due, and clears it so it shows once.
  bool consume() {
    final pending = _pending;
    _pending = false;
    return pending;
  }
}

/// Restores the continuity snapshot at launch when the database is empty:
/// the state right after a device migration, where the OS carried the
/// snapshot over but not the database (decision C1 in
/// docs/architecture/user-data-sync.md).
///
/// Runs without asking: the OS restored the user's own data. It must run
/// after the data migrations and before anything reads user data.
///
/// The `deviceId` half of restore detection (a database copied from
/// another device) arrives with sync in M6; nothing here compares ids.
class RestoreDetector {
  RestoreDetector({
    required this._isar,
    required this._resolveSnapshotPath,
    required this.restoreService,
    required this._logger,
  });

  final Isar _isar;
  final ContinuitySnapshotPathResolver _resolveSnapshotPath;
  final BackupRestoreService restoreService;
  final Logger _logger;

  /// Restores the snapshot if the database holds no user data and a
  /// readable snapshot exists. Returns whether it restored. Never throws:
  /// launch goes on with whatever the database holds.
  ///
  /// The feed refetch after the restore keeps running in the background;
  /// waiting for it would hold the first frame on the network.
  Future<bool> restoreIfEmpty() async {
    try {
      return await _restoreIfEmpty();
    } on Object catch (e, stack) {
      // IsarError extends Error; a narrower clause would block launch.
      _logger.e('Launch restore failed', error: e, stackTrace: stack);
      return false;
    }
  }

  Future<bool> _restoreIfEmpty() async {
    if (!await hasNoUserData(_isar)) return false;
    final file = File(await _resolveSnapshotPath());
    if (!await file.exists()) return false;
    final SnapshotFile snapshot;
    try {
      snapshot = readSnapshotFile(await file.readAsBytes());
    } on SnapshotReadFailure catch (e) {
      // Kept, not deleted: the file may be the only copy of the user's
      // data, and a later version may read what this one cannot.
      _logger.w('Continuity snapshot unreadable, not restoring: $e');
      return false;
    }
    if (_carriesNothing(snapshot.header.counts)) return false;
    final result = await restoreService.restore(snapshot);
    unawaited(result.postProcessing);
    _logger.i('Restored continuity snapshot (${result.changedRows} rows)');
    return true;
  }

  /// A snapshot written before any podcast, episode, queue, or station
  /// existed has nothing worth telling the user about.
  bool _carriesNothing(SnapshotCounts counts) =>
      counts.podcasts == 0 &&
      counts.episodes == 0 &&
      counts.queue == 0 &&
      counts.stations == 0;
}
