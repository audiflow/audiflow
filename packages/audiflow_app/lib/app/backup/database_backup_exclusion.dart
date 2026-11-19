import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:flutter/services.dart';
import 'package:logger/logger.dart';

/// Keeps the Isar database out of the iOS backup (decision C1 in
/// docs/architecture/user-data-sync.md) through the native
/// `audiflow/backup_exclusion` channel in `AppDelegate.swift`.
///
/// The continuity snapshot carries the user data to a new device instead;
/// the database can exceed what a backup should hold and would arrive with
/// the old device's download rows.
///
/// Called from Dart after the database opens rather than by Swift for fixed
/// paths: Isar creates its files on the first open, and schema recovery
/// deletes and re-creates them, so only a call after the open covers a
/// fresh install and a recovered database in the same launch. The flag
/// stays on the file while Isar writes to it in place; it is set again on
/// every launch anyway.
class DatabaseBackupExclusion {
  DatabaseBackupExclusion({
    required this._logger,
    this._channel = const MethodChannel(channelName),
  });

  static const channelName = 'audiflow/backup_exclusion';

  final Logger _logger;
  final MethodChannel _channel;

  /// Marks the database files in [directory] as excluded from backup.
  /// Never throws: a file left in the backup only costs backup space.
  Future<void> excludeDatabase(String directory) async {
    try {
      final files = await isarDatabaseFiles(directory: directory);
      if (files.isEmpty) return;
      await _channel.invokeMethod<void>('exclude', [
        for (final file in files) file.path,
      ]);
    } on Object catch (e, stack) {
      _logger.w(
        'Could not exclude the database from backup',
        error: e,
        stackTrace: stack,
      );
    }
  }
}
