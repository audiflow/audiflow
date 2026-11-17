import 'dart:async';
import 'dart:io';

import 'package:isar_community/isar.dart';
import 'package:logger/logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../common/providers/database_provider.dart';
import '../../common/providers/logger_provider.dart';
import '../../common/providers/platform_providers.dart';
import '../../common/services/suspendable_writer.dart';
import '../user_state/models/sync_meta.dart';
import 'backup_file.dart';
import 'continuity_snapshot.dart';

part 'auto_snapshot_scheduler.g.dart';

/// Provides the [AutoSnapshotScheduler] the app calls on moving to the
/// background.
@Riverpod(keepAlive: true)
AutoSnapshotScheduler autoSnapshotScheduler(Ref ref) {
  return AutoSnapshotScheduler(
    isar: ref.watch(isarProvider),
    resolveSnapshotPath: ref.watch(continuitySnapshotPathProvider),
    // Read on each write rather than here: package info is an app-start
    // override that some tests building the reset service never provide.
    appVersion: () => ref.read(packageInfoProvider).version,
    platform: Platform.isIOS ? 'ios' : 'android',
    logger: ref.watch(namedLoggerProvider('AutoSnapshot')),
  );
}

/// What one [AutoSnapshotScheduler.onBackground] call did.
enum AutoSnapshotOutcome {
  /// A new snapshot replaced the old one.
  written,

  /// Nothing changed since the last snapshot.
  unchanged,

  /// The last snapshot is less than [AutoSnapshotScheduler.minInterval] old.
  tooSoon,

  /// The database holds no user data, so a snapshot would carry nothing.
  empty,

  /// A data reset holds writers quiet.
  suspended,

  /// Another write is still running.
  busy,

  /// The write failed; the previous snapshot, if any, is untouched.
  failed,
}

/// Writes the continuity snapshot when the app goes to the background and
/// something changed, at most once every [minInterval]
/// (docs/architecture/user-data-sync.md, "When the snapshot is written").
///
/// Quick Start and Android device transfer run when the user decides to
/// switch, so the snapshot must be close to current, yet exporting the whole
/// user state on every backgrounding would be wasteful.
///
/// A [SuspendableWriter] so "Reset All Data" can wait out a write in flight:
/// one that renamed its file after the reset deleted the snapshot would
/// bring the reset data back on the next launch.
class AutoSnapshotScheduler implements SuspendableWriter {
  AutoSnapshotScheduler({
    required this._isar,
    required this._resolveSnapshotPath,
    required this._appVersion,
    required this._platform,
    required this._logger,
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now;

  /// Shortest time between two snapshots.
  static const minInterval = Duration(minutes: 15);

  final Isar _isar;
  final ContinuitySnapshotPathResolver _resolveSnapshotPath;
  final String Function() _appVersion;
  final String _platform;
  final Logger _logger;
  final DateTime Function() _clock;

  /// Kept in memory: after a restart the first backgrounding may write
  /// again, which costs one export and keeps the rule simple.
  DateTime? _lastWrittenAt;
  Future<AutoSnapshotOutcome>? _inFlight;
  bool _suspended = false;

  /// Writes the snapshot if it is due. Never throws: a failed snapshot is
  /// logged and retried on the next backgrounding.
  Future<AutoSnapshotOutcome> onBackground() async {
    if (_suspended) return AutoSnapshotOutcome.suspended;
    if (_inFlight != null) return AutoSnapshotOutcome.busy;
    final run = _run();
    _inFlight = run;
    try {
      return await run;
    } finally {
      _inFlight = null;
    }
  }

  Future<AutoSnapshotOutcome> _run() async {
    try {
      return await _writeIfDue();
    } on Object catch (e, stack) {
      // IsarError extends Error, so a narrower clause would let it escape
      // into the lifecycle callback.
      _logger.e('Continuity snapshot failed', error: e, stackTrace: stack);
      return AutoSnapshotOutcome.failed;
    }
  }

  Future<AutoSnapshotOutcome> _writeIfDue() async {
    final now = _clock();
    final last = _lastWrittenAt;
    if (last != null && now.isBefore(last.add(minInterval))) {
      return AutoSnapshotOutcome.tooSoon;
    }
    final meta = await _isar.syncMetas.get(SyncMeta.singletonId);
    if (meta == null || await hasNoUserData(_isar)) {
      return AutoSnapshotOutcome.empty;
    }
    final target = File(await _resolveSnapshotPath());
    // A missing file counts as a change: an install upgraded from before
    // snapshots may have a clock that matches the recorded 0.
    if (meta.hlc == meta.lastSnapshotHlc && await target.exists()) {
      return AutoSnapshotOutcome.unchanged;
    }
    // Read before the export: a change landing during it is in the file but
    // not in the recorded clock, so the next backgrounding writes again.
    final hlc = meta.hlc;
    final backup = await buildBackupFile(
      _isar,
      now: now,
      appVersion: _appVersion(),
      platform: _platform,
    );
    await _replaceAtomically(target, backup.bytes);
    await _isar.writeTxn(() async {
      final current = await _isar.syncMetas.get(SyncMeta.singletonId);
      if (current == null) return;
      await _isar.syncMetas.put(current..lastSnapshotHlc = hlc);
    });
    _lastWrittenAt = now;
    _logger.i('Continuity snapshot written (${backup.bytes.length} bytes)');
    return AutoSnapshotOutcome.written;
  }

  /// Writes [bytes] next to [target] and renames it over [target], so a
  /// crash mid-write leaves the previous snapshot whole. The temporary file
  /// shares the directory because a rename is atomic only within one file
  /// system.
  Future<void> _replaceAtomically(File target, List<int> bytes) async {
    await target.parent.create(recursive: true);
    final temp = File('${target.path}.tmp');
    try {
      await temp.writeAsBytes(bytes, flush: true);
      await temp.rename(target.path);
    } on Object {
      await _deleteQuietly(temp);
      rethrow;
    }
  }

  Future<void> _deleteQuietly(File file) async {
    try {
      if (await file.exists()) await file.delete();
    } on FileSystemException catch (e) {
      _logger.w('Could not remove a partial snapshot', error: e);
    }
  }

  @override
  Future<void> suspend() async {
    _suspended = true;
    final inFlight = _inFlight;
    if (inFlight != null) await inFlight;
  }

  @override
  void resume() => _suspended = false;
}
