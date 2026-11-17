import 'dart:typed_data';

import 'package:isar_community/isar.dart';
import 'package:logger/logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../common/providers/background_task_canceller_provider.dart';
import '../../common/providers/database_provider.dart';
import '../../common/providers/logger_provider.dart';
import '../../common/services/suspendable_writer.dart';
import '../download/services/download_queue_service.dart';
import '../feed/services/feed_sync_service.dart';
import '../player/services/audio_player_service.dart';
import '../station/services/station_reconciler_service.dart';
import 'restore_projector.dart';
import 'snapshot_file.dart';
import 'snapshot_merger.dart';

part 'backup_restore_service.g.dart';

/// Provides the [BackupRestoreService] behind "Restore from Backup".
@Riverpod(keepAlive: true)
BackupRestoreService backupRestoreService(Ref ref) {
  final playback = ref.watch(audioPlayerControllerProvider.notifier);
  final feedSync = ref.watch(feedSyncServiceProvider);
  final reconciler = ref.watch(stationReconcilerServiceProvider);
  return BackupRestoreService(
    isar: ref.watch(isarProvider),
    stopPlayback: playback.stop,
    cancelBackgroundTasks: ref.watch(backgroundTaskCancellerProvider),
    writers: [ref.watch(downloadQueueServiceProvider), feedSync],
    syncFeeds: (urls) async {
      await feedSync.syncFeedsByUrls(urls);
    },
    onStationChanged: reconciler.onStationConfigChanged,
    logger: ref.watch(namedLoggerProvider('BackupRestore')),
  );
}

/// What a restore changed, and the work it left running.
class BackupRestoreResult {
  BackupRestoreResult(this.changedRows, this.postProcessing);

  /// Rows the merge changed; 0 when this device already had everything.
  final int changedRows;

  /// Feed refetch, queue projection, and station reconcile. Never throws:
  /// the restore has already succeeded when this runs, and the regular
  /// feed refresh catches up on whatever it could not fetch.
  final Future<void> postProcessing;
}

/// Restores a backup file: always a merge under the sync rules, so data on
/// this device that is newer than the backup stays.
///
/// [read] is phase A (validation, no writes) and [restore] phase B, run
/// with playback stopped and every writer suspended, like a data reset.
class BackupRestoreService {
  BackupRestoreService({
    required this._isar,
    required this._stopPlayback,
    required this._cancelBackgroundTasks,
    required this._writers,
    required this._syncFeeds,
    required this._onStationChanged,
    required this._logger,
    this._nowMillis,
  });

  final Isar _isar;
  final Future<void> Function() _stopPlayback;
  final WriterCanceller _cancelBackgroundTasks;

  /// Foreground services that write to storage, in suspend order.
  final List<SuspendableWriter> _writers;
  final Future<void> Function(List<String> feedUrls) _syncFeeds;
  final Future<void> Function(int stationId) _onStationChanged;
  final Logger _logger;
  final int Function()? _nowMillis;

  /// Validates [bytes] as a backup without touching the database. Throws a
  /// [SnapshotReadFailure] for a file that is not one, is damaged, or was
  /// made by a newer version.
  SnapshotFile read(Uint8List bytes) => readSnapshotFile(bytes);

  /// Merges [file] into this device's data and puts the result in the rows
  /// the app reads. Throws when either step fails. A failed merge rolls
  /// back; a failed projection leaves the merge in place, and restoring the
  /// same file again merges nothing new and projects again.
  Future<BackupRestoreResult> restore(SnapshotFile file) async {
    // The service outlives any one screen: a second restore started from a
    // new confirmation would resume the writers under the first one.
    if (_restoring) throw StateError('A backup restore is already running');
    _restoring = true;
    try {
      return await _restore(file);
    } finally {
      _restoring = false;
    }
  }

  bool _restoring = false;

  Future<BackupRestoreResult> _restore(SnapshotFile file) async {
    // Playback stops first: its progress ticker would otherwise write the
    // current episode's position over the restored one.
    await _stopPlayback();
    await _cancelBackgroundTasks();
    final SnapshotMergeResult merged;
    final RestoreProjection projection;
    final projector = RestoreProjector(_isar);
    // Suspending happens inside the try so a writer that fails to suspend
    // does not strand the ones suspended before it.
    try {
      for (final writer in _writers) {
        await writer.suspend();
      }
      merged = await SnapshotMerger(_isar, nowMillis: _nowMillis).merge(file);
      // A separate transaction from the merge: if it fails, running the
      // restore again merges nothing new and projects again.
      projection = await projector.projectLibrary(
        podcastInfo: merged.podcastInfo,
        now: _now(),
      );
    } finally {
      for (final writer in _writers.reversed) {
        writer.resume();
      }
    }
    return BackupRestoreResult(
      merged.changedRows,
      _postProcess(projector, projection),
    );
  }

  /// Runs after the writers resume: a suspended feed sync writes nothing.
  Future<void> _postProcess(
    RestoreProjector projector,
    RestoreProjection projection,
  ) async {
    try {
      if (projection.feedUrls.isNotEmpty) {
        await _syncFeeds(projection.feedUrls);
      }
    } on Object catch (e, stack) {
      _logger.w(
        'Feed refetch after restore failed',
        error: e,
        stackTrace: stack,
      );
    }
    // Queue entries name episodes by key, which only fetched feeds carry.
    try {
      await projector.projectQueue();
    } on Object catch (e, stack) {
      _logger.e(
        'Queue projection after restore failed',
        error: e,
        stackTrace: stack,
      );
    }
    for (final id in projection.stationIds) {
      try {
        await _onStationChanged(id);
      } on Object catch (e, stack) {
        _logger.w(
          'Station reconcile after restore failed',
          error: e,
          stackTrace: stack,
        );
      }
    }
  }

  DateTime? _now() {
    final now = _nowMillis;
    return now == null
        ? null
        : DateTime.fromMillisecondsSinceEpoch(now(), isUtc: true);
  }
}
