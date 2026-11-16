import 'package:isar_community/isar.dart';
import 'package:logger/logger.dart';

import '../models/sync_meta.dart';
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

/// The app's migration steps, in order. Empty until a step needs one.
const List<DataMigrationStep> dataMigrationSteps = [];

/// Runs the pending [DataMigrationStep]s in order, before providers start.
class DataMigrationRunner {
  DataMigrationRunner(
    this._isar, {
    required List<DataMigrationStep> steps,
    this._logger,
    this._createHistoryId,
  }) : _steps = _validated(steps);

  final Isar _isar;
  final List<DataMigrationStep> _steps;
  final Logger? _logger;
  final String Function()? _createHistoryId;

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
  Future<void> run() async {
    final meta = await _isar.writeTxn(
      () => loadOrCreateSyncMeta(_isar, createHistoryId: _createHistoryId),
    );
    var version = meta.schemaVersion;
    for (final step in _steps) {
      if (step.version <= version) continue;
      _logger?.i('Running data migration ${step.version} (${step.name})');
      await step.run(_isar);
      await _record(step.version);
      version = step.version;
    }
  }

  Future<void> _record(int version) {
    return _isar.writeTxn(() async {
      final meta = await loadOrCreateSyncMeta(
        _isar,
        createHistoryId: _createHistoryId,
      );
      meta.schemaVersion = version;
      await _isar.syncMetas.put(meta);
    });
  }
}
