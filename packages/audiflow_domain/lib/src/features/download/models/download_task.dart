import 'package:drift/drift.dart';

import '../../feed/models/episode.dart';
import 'download_status.dart';

/// Drift table for download tasks.
///
/// Tracks episode downloads with progress, status, and retry information.
class DownloadTasks extends Table {
  /// Auto-incrementing primary key.
  IntColumn get id => integer().autoIncrement()();

  /// Foreign key to Episodes table.
  IntColumn get episodeId => integer().references(Episodes, #id)();

  /// Original audio URL (cached for offline reference).
  TextColumn get audioUrl => text()();

  /// Local file path when download completes.
  TextColumn get localPath => text().nullable()();

  /// Total file size in bytes (from Content-Length header).
  IntColumn get totalBytes => integer().nullable()();

  /// Bytes downloaded so far.
  IntColumn get downloadedBytes => integer().withDefault(const Constant(0))();

  /// Download status (stored as int, see [DownloadStatus]).
  IntColumn get status => integer().withDefault(const Constant(0))();

  /// Whether to only download on WiFi.
  BoolColumn get wifiOnly => boolean().withDefault(const Constant(true))();

  /// Number of retry attempts.
  IntColumn get retryCount => integer().withDefault(const Constant(0))();

  /// Last error message for debugging.
  TextColumn get lastError => text().nullable()();

  /// When the download was requested.
  DateTimeColumn get createdAt => dateTime()();

  /// When the download completed successfully.
  DateTimeColumn get completedAt => dateTime().nullable()();

  /// Ensure one download per episode.
  @override
  List<Set<Column>> get uniqueKeys => [
    {episodeId},
  ];
}

// Extension DownloadTaskStatusX is defined in app_database.dart after code generation
