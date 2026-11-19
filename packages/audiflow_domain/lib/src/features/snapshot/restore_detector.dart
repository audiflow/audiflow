import 'dart:async';
import 'dart:io';

import 'package:isar_community/isar.dart';
import 'package:logger/logger.dart';
import 'package:path/path.dart' as p;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../common/providers/database_provider.dart';
import '../../common/providers/logger_provider.dart';
import '../user_state/models/sync_meta.dart';
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
/// A snapshot it cannot read is moved aside rather than deleted, and merged
/// on a later launch once an updated app can read it.
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
  /// readable snapshot exists, or finishes a launch restore that a crash cut
  /// short. Returns whether the "carried over" notice is due. Never throws:
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
    final file = File(await _resolveSnapshotPath());
    final retained = File(p.join(file.parent.path, retainedSnapshotFileName));
    // Decided before the retained file is merged: that merge fills the
    // database, and the current snapshot, newer than the retained one,
    // must still be restored after it.
    final pending = await _isPending();
    final needsCurrent = pending || await hasNoUserData(_isar);
    final recovered = await _recoverRetained(retained);
    if (!needsCurrent) return recovered;
    if (!await file.exists()) {
      if (pending) await _setPending(false);
      return recovered;
    }
    final SnapshotFile snapshot;
    try {
      snapshot = readSnapshotFile(await file.readAsBytes());
    } on SnapshotReadFailure catch (e) {
      _logger.w('Continuity snapshot unreadable, not restoring: $e');
      await _retain(file, retained);
      if (pending) await _setPending(false);
      return recovered;
    }
    // A snapshot of settings alone is never written (the scheduler skips a
    // database without user data), so this is not worth a restore that
    // would rerun on every launch.
    if (!pending && _carriesNothing(snapshot.header.counts)) return recovered;
    // Marked before the merge and cleared once the library is rebuilt: the
    // two commit separately, and a retry merges nothing new.
    await _setPending(true);
    final result = await restoreService.restore(snapshot);
    await _setPending(false);
    unawaited(result.postProcessing);
    _logger.i('Restored continuity snapshot (${result.changedRows} rows)');
    return true;
  }

  /// Merges a snapshot an earlier launch could not read, once this version
  /// can, and drops it. Into data that is no longer empty: the merge keeps
  /// whatever changed here since, so the user's older data only fills in.
  Future<bool> _recoverRetained(File retained) async {
    if (!await retained.exists()) return false;
    final SnapshotFile snapshot;
    try {
      snapshot = readSnapshotFile(await retained.readAsBytes());
    } on SnapshotReadFailure catch (e) {
      _logger.w('Retained snapshot still unreadable: $e');
      return false;
    }
    final result = await restoreService.restore(snapshot);
    await retained.delete();
    unawaited(result.postProcessing);
    _logger.i('Recovered retained snapshot (${result.changedRows} rows)');
    return !_carriesNothing(snapshot.header.counts);
  }

  /// Moves an unreadable snapshot aside, so the next snapshot does not
  /// replace what may be the only copy of the user's data. The first one
  /// moved aside stays: it predates anything this device wrote.
  Future<void> _retain(File file, File retained) async {
    if (await retained.exists()) return;
    await file.rename(retained.path);
  }

  Future<bool> _isPending() async =>
      (await _isar.syncMetas.get(
        SyncMeta.singletonId,
      ))?.continuityRestorePending ??
      false;

  Future<void> _setPending(bool pending) => _isar.writeTxn(() async {
    final meta = await _isar.syncMetas.get(SyncMeta.singletonId);
    if (meta == null || meta.continuityRestorePending == pending) return;
    await _isar.syncMetas.put(meta..continuityRestorePending = pending);
  });

  /// A snapshot written before any podcast, episode, queue, or station
  /// existed has nothing worth telling the user about.
  bool _carriesNothing(SnapshotCounts counts) =>
      counts.podcasts == 0 &&
      counts.episodes == 0 &&
      counts.queue == 0 &&
      counts.stations == 0;
}
