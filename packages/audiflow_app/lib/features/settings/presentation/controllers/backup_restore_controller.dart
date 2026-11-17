import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../services/backup_file_picker.dart';

part 'backup_restore_controller.g.dart';

/// Why a picked file cannot be restored; each has its own message.
enum BackupPickFailure { notABackup, damaged, tooNew, unreadable }

/// The result of picking a file (phase A: nothing is written).
sealed class BackupPickOutcome {}

class BackupPickCancelled extends BackupPickOutcome {}

class BackupPicked extends BackupPickOutcome {
  BackupPicked(this.file);

  final SnapshotFile file;
}

class BackupPickFailed extends BackupPickOutcome {
  BackupPickFailed(this.failure);

  final BackupPickFailure failure;
}

sealed class BackupRestoreState {}

class BackupRestoreIdle extends BackupRestoreState {}

class BackupRestoreRunning extends BackupRestoreState {}

class BackupRestoreDone extends BackupRestoreState {}

class BackupRestoreError extends BackupRestoreState {
  BackupRestoreError(this.error);

  /// The underlying failure, kept for diagnostics; never shown to users.
  final Object error;
}

/// Controls "Restore from Backup": picks and validates a file, then merges
/// it once the user has confirmed.
@riverpod
class BackupRestoreController extends _$BackupRestoreController {
  @override
  BackupRestoreState build() => BackupRestoreIdle();

  /// Opens the picker and validates the chosen file without writing.
  Future<BackupPickOutcome> pick() async {
    // Read before the first await: leaving the screen disposes this
    // controller, and a disposed ref can no longer read.
    final picker = ref.read(backupFilePickerProvider);
    final service = ref.read(backupRestoreServiceProvider);
    final logger = ref.read(namedLoggerProvider('BackupRestore'));
    final picked = await picker.pick();
    if (picked == null) return BackupPickCancelled();
    try {
      return BackupPicked(service.read(await picked.read()));
    } on SnapshotReadFailure catch (e) {
      // The location only, never values: the file holds listening history.
      logger.w('Backup file rejected: $e');
      return BackupPickFailed(switch (e) {
        NotASnapshot() => BackupPickFailure.notABackup,
        DamagedSnapshot() => BackupPickFailure.damaged,
        SnapshotTooNew() => BackupPickFailure.tooNew,
      });
    } on FormatException catch (e) {
      logger.w('Backup file unreadable: ${e.message}');
      return BackupPickFailed(BackupPickFailure.unreadable);
    }
  }

  /// Merges [file]. The restore keeps running if the screen closes, since
  /// stopping it halfway would leave the writers to resume on their own.
  Future<void> restore(SnapshotFile file) async {
    if (state is BackupRestoreRunning) return;
    state = BackupRestoreRunning();
    final service = ref.read(backupRestoreServiceProvider);
    final logger = ref.read(namedLoggerProvider('BackupRestore'));
    try {
      final result = await service.restore(file);
      logger.i('Backup restored: ${result.changedRows} rows changed');
      if (ref.mounted) state = BackupRestoreDone();
    } on Object catch (e, stack) {
      // IsarError extends Error, not Exception; the merge rolled back.
      logger.e('Backup restore failed', error: e, stackTrace: stack);
      if (ref.mounted) state = BackupRestoreError(e);
    }
  }
}
