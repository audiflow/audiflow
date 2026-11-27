import 'package:isar_community/isar.dart';
import 'package:logger/logger.dart';

import '../models/sync_meta.dart';
import 'episode_locator_backfill.dart';
import 'episode_user_state_backfill.dart';
import 'podcast_user_state_backfill.dart';
import 'queue_entry_backfill.dart';
import 'station_state_backfill.dart';
import 'sync_meta_access.dart';

/// One data-rewriting migration, run once at launch.
///
/// `isar_community` adds fields and collections by itself but cannot
/// rewrite data, so steps such as moving user state into new collections
/// run here. A step may be interrupted at any point (the app can be killed
/// mid-run) and is then run again from the start, so it must be idempotent.
abstract interface class DataMigrationStep {
  /// Position in the sequence; recorded in `SyncMeta.schemaVersion` once
  /// the step completes. Never reused or reordered.
  int get version;

  /// Short name for logs.
  String get name;

  Future<void> run(Isar isar);
}

/// The app's migration steps, in order.
const List<DataMigrationStep> dataMigrationSteps = [
  EpisodeUserStateBackfill(),
  PodcastUserStateBackfill(),
  // Runs the copy again for the subscription section added after step 2.
  // Sections already copied are skipped.
  PodcastUserStateBackfill(version: 3),
  QueueEntryBackfill(),
  StationStateBackfill(),
  EpisodeLocatorBackfill(),
];

/// Runs the pending [DataMigrationStep]s in order, before providers start.
class DataMigrationRunner {
  DataMigrationRunner(
    this._isar, {
    required List<DataMigrationStep> steps,
    this._logger,
    this._createHistoryId,
    this._deviceId,
  }) : _steps = _validated(steps);

  final Isar _isar;
  final List<DataMigrationStep> _steps;
  final Logger? _logger;
  final String Function()? _createHistoryId;

  /// This device's id, recorded in [SyncMeta] when it has none; null in the
  /// background, where device-only storage is not read.
  final String? _deviceId;

  static List<DataMigrationStep> _validated(List<DataMigrationStep> steps) {
    for (var i = 1; i < steps.length; i++) {
      if (steps[i].version <= steps[i - 1].version) {
        throw ArgumentError.value(
          steps.map((s) => s.version).toList(),
          'steps',
          'versions must strictly increase',
        );
      }
    }
    return List.unmodifiable(steps);
  }

  /// Ensures [SyncMeta] exists, then runs every step newer than the
  /// recorded version.
  ///
  /// Each completed step is recorded before the next starts, so a failure
  /// keeps the earlier ones done; the failing step is rethrown and runs
  /// again from the start on the next launch.
  ///
  /// The foreground app and a background task can open the database at the
  /// same moment and run the same pending step together. Steps are
  /// idempotent, so that is safe; the runner rereads the recorded version
  /// before each step to skip work the other one finished, and a record
  /// only ever raises the version, so a slower runner cannot lower it.
  Future<void> run() async {
    await _isar.writeTxn(() async {
      final meta = await loadOrCreateSyncMeta(
        _isar,
        createHistoryId: _createHistoryId,
      );
      final deviceId = _deviceId;
      // Only filled in, never replaced: a differing id means this data was
      // restored from another device, which restore detection (M5) handles.
      if (deviceId != null && meta.deviceId == null) {
        await _isar.syncMetas.put(meta..deviceId = deviceId);
      }
    });
    for (final step in _steps) {
      if (step.version <= await _recordedVersion()) continue;
      _logger?.i('Running data migration ${step.version} (${step.name})');
      await step.run(_isar);
      await _record(step.version);
    }
  }

  Future<int> _recordedVersion() async {
    final meta = await _isar.syncMetas.get(SyncMeta.singletonId);
    return meta?.schemaVersion ?? 0;
  }

  Future<void> _record(int version) {
    return _isar.writeTxn(() async {
      final meta = await loadOrCreateSyncMeta(
        _isar,
        createHistoryId: _createHistoryId,
      );
      if (version <= meta.schemaVersion) return;
      meta.schemaVersion = version;
      await _isar.syncMetas.put(meta);
    });
  }
}
