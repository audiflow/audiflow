# Download Episode Feature - Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Enable users to download podcast episodes for offline playback with queue management, smart retry, and background downloads.

**Architecture:** Domain-driven with Drift for persistence, Dio for HTTP downloads, Riverpod for state management. Downloads tracked in separate `DownloadTasks` table. Sequential queue processing with network-aware retry logic.

**Tech Stack:** Drift (SQLite), Dio, Riverpod 3.x with code generation, connectivity_plus, path_provider

---

## Task 1: Add DownloadException to Core

**Files:**
- Modify: `packages/audiflow_core/lib/src/errors/exceptions.dart`
- Modify: `packages/audiflow_core/lib/audiflow_core.dart` (if not already exported)

**Step 1: Add DownloadException class**

```dart
// Add after ValidationException in exceptions.dart

/// Error types for download operations
enum DownloadErrorType {
  networkUnavailable,
  serverError,
  insufficientStorage,
  fileWriteError,
  cancelled,
  unknown,
}

/// Exception for download-related errors
class DownloadException extends AppException {
  DownloadException(
    this.type, [
    String message = 'Download error occurred',
  ]) : super(message, 'DOWNLOAD_ERROR_${type.name.toUpperCase()}');

  final DownloadErrorType type;
}
```

**Step 2: Verify export in audiflow_core.dart**

Ensure `exceptions.dart` is exported (should already be).

**Step 3: Run analyzer**

Run: `dart analyze packages/audiflow_core`
Expected: No errors

**Step 4: Commit**

```bash
jj describe -m "feat(core): add DownloadException for download error handling"
```

---

## Task 2: Create DownloadStatus Enum

**Files:**
- Create: `packages/audiflow_domain/lib/src/features/download/models/download_status.dart`

**Step 1: Create the freezed enum**

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'download_status.freezed.dart';

/// Status of a download task.
///
/// State transitions:
/// - pending → downloading → completed
/// - downloading → paused → downloading
/// - downloading → failed (after retries)
/// - any → cancelled
@freezed
sealed class DownloadStatus with _$DownloadStatus {
  const DownloadStatus._();

  /// Queued, waiting to start
  const factory DownloadStatus.pending() = DownloadStatusPending;

  /// Actively downloading
  const factory DownloadStatus.downloading() = DownloadStatusDownloading;

  /// Paused by user or system
  const factory DownloadStatus.paused() = DownloadStatusPaused;

  /// Successfully completed
  const factory DownloadStatus.completed() = DownloadStatusCompleted;

  /// Failed after retries exhausted
  const factory DownloadStatus.failed() = DownloadStatusFailed;

  /// Cancelled by user
  const factory DownloadStatus.cancelled() = DownloadStatusCancelled;

  /// Convert to int for database storage
  int toDbValue() => switch (this) {
    DownloadStatusPending() => 0,
    DownloadStatusDownloading() => 1,
    DownloadStatusPaused() => 2,
    DownloadStatusCompleted() => 3,
    DownloadStatusFailed() => 4,
    DownloadStatusCancelled() => 5,
  };

  /// Create from database int value
  static DownloadStatus fromDbValue(int value) => switch (value) {
    0 => const DownloadStatus.pending(),
    1 => const DownloadStatus.downloading(),
    2 => const DownloadStatus.paused(),
    3 => const DownloadStatus.completed(),
    4 => const DownloadStatus.failed(),
    5 => const DownloadStatus.cancelled(),
    _ => const DownloadStatus.pending(),
  };

  /// Whether download is in an active state (can be paused/cancelled)
  bool get isActive => switch (this) {
    DownloadStatusPending() => true,
    DownloadStatusDownloading() => true,
    DownloadStatusPaused() => true,
    _ => false,
  };

  /// Whether download needs user attention
  bool get needsAttention => this is DownloadStatusFailed;
}
```

**Step 2: Run build_runner**

Run: `cd packages/audiflow_domain && dart run build_runner build --delete-conflicting-outputs`
Expected: Generates `download_status.freezed.dart`

**Step 3: Run analyzer**

Run: `dart analyze packages/audiflow_domain`
Expected: No errors

**Step 4: Commit**

```bash
jj describe -m "feat(domain): add DownloadStatus enum for download state tracking"
```

---

## Task 3: Create DownloadTasks Drift Table

**Files:**
- Create: `packages/audiflow_domain/lib/src/features/download/models/download_task.dart`

**Step 1: Create the Drift table definition**

```dart
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

/// Extension to convert between Drift model and domain status.
extension DownloadTaskStatusX on DownloadTask {
  /// Get the status as a typed enum.
  DownloadStatus get downloadStatus => DownloadStatus.fromDbValue(status);

  /// Calculate download progress (0.0 to 1.0).
  double get progress {
    if (totalBytes == null || totalBytes == 0) return 0.0;
    return downloadedBytes / totalBytes!;
  }
}
```

**Step 2: Run analyzer**

Run: `dart analyze packages/audiflow_domain`
Expected: No errors (table not yet added to database)

**Step 3: Commit**

```bash
jj describe -m "feat(domain): add DownloadTasks Drift table definition"
```

---

## Task 4: Add DownloadTasks to Database Schema

**Files:**
- Modify: `packages/audiflow_domain/lib/src/common/database/app_database.dart`

**Step 1: Import the new table**

Add import at top:
```dart
import '../../features/download/models/download_task.dart';
```

**Step 2: Add table to @DriftDatabase annotation**

```dart
@DriftDatabase(
  tables: [
    Subscriptions,
    Episodes,
    PlaybackHistories,
    Seasons,
    PodcastViewPreferences,
    DownloadTasks,  // Add this
  ],
)
```

**Step 3: Increment schema version and add migration**

Change `schemaVersion` to 9 and add migration:

```dart
@override
int get schemaVersion => 9;

@override
MigrationStrategy get migration => MigrationStrategy(
  onCreate: (m) => m.createAll(),
  onUpgrade: (m, from, to) async {
    // ... existing migrations ...

    // Migration from v8 to v9: add DownloadTasks table
    if (9 <= to && from < 9) {
      await m.createTable(downloadTasks);
    }
  },
);
```

**Step 4: Run build_runner**

Run: `cd packages/audiflow_domain && dart run build_runner build --delete-conflicting-outputs`
Expected: Regenerates `app_database.g.dart` with DownloadTask model

**Step 5: Run analyzer**

Run: `dart analyze packages/audiflow_domain`
Expected: No errors

**Step 6: Commit**

```bash
jj describe -m "feat(domain): add DownloadTasks table to database schema (v9)"
```

---

## Task 5: Create DownloadLocalDatasource

**Files:**
- Create: `packages/audiflow_domain/lib/src/features/download/datasources/local/download_local_datasource.dart`

**Step 1: Create the datasource class**

```dart
import 'package:drift/drift.dart';

import '../../../../common/database/app_database.dart';
import '../../models/download_status.dart';

/// Local datasource for download task operations using Drift.
///
/// Provides CRUD operations and queries for the DownloadTasks table.
class DownloadLocalDatasource {
  DownloadLocalDatasource(this._db);

  final AppDatabase _db;

  /// Creates a new download task. Returns the task ID.
  Future<int> create(DownloadTasksCompanion companion) {
    return _db.into(_db.downloadTasks).insert(companion);
  }

  /// Updates a download task.
  Future<bool> update(DownloadTasksCompanion companion) {
    return _db.update(_db.downloadTasks).replace(
      companion as Insertable<DownloadTask>,
    );
  }

  /// Updates specific fields of a download task by ID.
  Future<int> updateById(int id, DownloadTasksCompanion companion) {
    return (_db.update(_db.downloadTasks)
      ..where((t) => t.id.equals(id)))
      .write(companion);
  }

  /// Deletes a download task by ID.
  Future<int> delete(int id) {
    return (_db.delete(_db.downloadTasks)
      ..where((t) => t.id.equals(id)))
      .go();
  }

  /// Returns a download task by ID.
  Future<DownloadTask?> getById(int id) {
    return (_db.select(_db.downloadTasks)
      ..where((t) => t.id.equals(id)))
      .getSingleOrNull();
  }

  /// Returns a download task by episode ID.
  Future<DownloadTask?> getByEpisodeId(int episodeId) {
    return (_db.select(_db.downloadTasks)
      ..where((t) => t.episodeId.equals(episodeId)))
      .getSingleOrNull();
  }

  /// Watches a download task by episode ID.
  Stream<DownloadTask?> watchByEpisodeId(int episodeId) {
    return (_db.select(_db.downloadTasks)
      ..where((t) => t.episodeId.equals(episodeId)))
      .watchSingleOrNull();
  }

  /// Returns all download tasks ordered by creation date (oldest first = FIFO).
  Future<List<DownloadTask>> getAll() {
    return (_db.select(_db.downloadTasks)
      ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
      .get();
  }

  /// Watches all download tasks ordered by creation date.
  Stream<List<DownloadTask>> watchAll() {
    return (_db.select(_db.downloadTasks)
      ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
      .watch();
  }

  /// Returns download tasks by status.
  Future<List<DownloadTask>> getByStatus(DownloadStatus status) {
    return (_db.select(_db.downloadTasks)
      ..where((t) => t.status.equals(status.toDbValue()))
      ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
      .get();
  }

  /// Watches download tasks by status.
  Stream<List<DownloadTask>> watchByStatus(DownloadStatus status) {
    return (_db.select(_db.downloadTasks)
      ..where((t) => t.status.equals(status.toDbValue()))
      ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
      .watch();
  }

  /// Returns completed downloads for an episode (for playback lookup).
  Future<DownloadTask?> getCompletedByEpisodeId(int episodeId) {
    return (_db.select(_db.downloadTasks)
      ..where((t) =>
        t.episodeId.equals(episodeId) &
        t.status.equals(DownloadStatus.completed().toDbValue())))
      .getSingleOrNull();
  }

  /// Returns the next pending download (FIFO order, respecting wifiOnly).
  Future<DownloadTask?> getNextPending({required bool isOnWifi}) {
    final query = _db.select(_db.downloadTasks)
      ..where((t) => t.status.equals(DownloadStatus.pending().toDbValue()));

    if (!isOnWifi) {
      query.where((t) => t.wifiOnly.equals(false));
    }

    query.orderBy([(t) => OrderingTerm.asc(t.createdAt)]);
    query.limit(1);

    return query.getSingleOrNull();
  }

  /// Returns count of active downloads (pending + downloading + paused).
  Future<int> getActiveCount() async {
    final activeStatuses = [
      DownloadStatus.pending().toDbValue(),
      DownloadStatus.downloading().toDbValue(),
      DownloadStatus.paused().toDbValue(),
    ];

    final query = _db.selectOnly(_db.downloadTasks)
      ..addColumns([_db.downloadTasks.id.count()])
      ..where(_db.downloadTasks.status.isIn(activeStatuses));

    final result = await query.getSingle();
    return result.read(_db.downloadTasks.id.count()) ?? 0;
  }

  /// Returns total storage used by completed downloads.
  Future<int> getTotalStorageUsed() async {
    final query = _db.selectOnly(_db.downloadTasks)
      ..addColumns([_db.downloadTasks.totalBytes.sum()])
      ..where(_db.downloadTasks.status.equals(
        DownloadStatus.completed().toDbValue(),
      ));

    final result = await query.getSingle();
    return result.read(_db.downloadTasks.totalBytes.sum()) ?? 0;
  }

  /// Deletes all completed downloads.
  Future<int> deleteAllCompleted() {
    return (_db.delete(_db.downloadTasks)
      ..where((t) => t.status.equals(DownloadStatus.completed().toDbValue())))
      .go();
  }
}
```

**Step 2: Run analyzer**

Run: `dart analyze packages/audiflow_domain`
Expected: No errors

**Step 3: Commit**

```bash
jj describe -m "feat(domain): add DownloadLocalDatasource for download CRUD operations"
```

---

## Task 6: Create DownloadRepository Interface

**Files:**
- Create: `packages/audiflow_domain/lib/src/features/download/repositories/download_repository.dart`

**Step 1: Create the repository interface**

```dart
import '../../../common/database/app_database.dart';
import '../models/download_status.dart';

/// Repository interface for download task operations.
///
/// Abstracts the data layer for managing episode downloads.
abstract class DownloadRepository {
  /// Creates a new download task for an episode.
  ///
  /// Returns the created task, or null if episode already has an active download.
  Future<DownloadTask?> createDownload({
    required int episodeId,
    required String audioUrl,
    required bool wifiOnly,
  });

  /// Returns a download task by ID.
  Future<DownloadTask?> getById(int id);

  /// Returns a download task by episode ID.
  Future<DownloadTask?> getByEpisodeId(int episodeId);

  /// Watches a download task by episode ID.
  Stream<DownloadTask?> watchByEpisodeId(int episodeId);

  /// Returns all download tasks.
  Future<List<DownloadTask>> getAll();

  /// Watches all download tasks.
  Stream<List<DownloadTask>> watchAll();

  /// Returns download tasks by status.
  Future<List<DownloadTask>> getByStatus(DownloadStatus status);

  /// Watches download tasks by status.
  Stream<List<DownloadTask>> watchByStatus(DownloadStatus status);

  /// Returns a completed download for an episode (for playback).
  Future<DownloadTask?> getCompletedForEpisode(int episodeId);

  /// Returns the next pending download.
  Future<DownloadTask?> getNextPending({required bool isOnWifi});

  /// Updates download progress.
  Future<void> updateProgress({
    required int id,
    required int downloadedBytes,
    int? totalBytes,
  });

  /// Updates download status.
  Future<void> updateStatus({
    required int id,
    required DownloadStatus status,
    String? localPath,
    String? lastError,
  });

  /// Increments retry count.
  Future<void> incrementRetryCount(int id);

  /// Deletes a download task and optionally its file.
  Future<void> delete(int id);

  /// Returns count of active downloads.
  Future<int> getActiveCount();

  /// Returns total storage used by completed downloads in bytes.
  Future<int> getTotalStorageUsed();

  /// Deletes all completed downloads.
  Future<int> deleteAllCompleted();
}
```

**Step 2: Run analyzer**

Run: `dart analyze packages/audiflow_domain`
Expected: No errors

**Step 3: Commit**

```bash
jj describe -m "feat(domain): add DownloadRepository interface"
```

---

## Task 7: Create DownloadRepository Implementation

**Files:**
- Create: `packages/audiflow_domain/lib/src/features/download/repositories/download_repository_impl.dart`

**Step 1: Create the implementation**

```dart
import 'package:drift/drift.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../common/database/app_database.dart';
import '../../../common/providers/database_provider.dart';
import '../datasources/local/download_local_datasource.dart';
import '../models/download_status.dart';
import 'download_repository.dart';

part 'download_repository_impl.g.dart';

/// Provides a singleton [DownloadRepository] instance.
@Riverpod(keepAlive: true)
DownloadRepository downloadRepository(Ref ref) {
  final db = ref.watch(databaseProvider);
  final datasource = DownloadLocalDatasource(db);
  return DownloadRepositoryImpl(datasource: datasource);
}

/// Implementation of [DownloadRepository] using Drift database.
class DownloadRepositoryImpl implements DownloadRepository {
  DownloadRepositoryImpl({required DownloadLocalDatasource datasource})
    : _datasource = datasource;

  final DownloadLocalDatasource _datasource;

  @override
  Future<DownloadTask?> createDownload({
    required int episodeId,
    required String audioUrl,
    required bool wifiOnly,
  }) async {
    // Check if download already exists for this episode
    final existing = await _datasource.getByEpisodeId(episodeId);
    if (existing != null) {
      final status = existing.downloadStatus;
      // Allow re-download only if cancelled or failed
      if (status is! DownloadStatusCancelled &&
          status is! DownloadStatusFailed) {
        return null;
      }
      // Delete old record and create new
      await _datasource.delete(existing.id);
    }

    final companion = DownloadTasksCompanion.insert(
      episodeId: episodeId,
      audioUrl: audioUrl,
      wifiOnly: Value(wifiOnly),
      createdAt: DateTime.now(),
    );

    final id = await _datasource.create(companion);
    return _datasource.getById(id);
  }

  @override
  Future<DownloadTask?> getById(int id) => _datasource.getById(id);

  @override
  Future<DownloadTask?> getByEpisodeId(int episodeId) =>
      _datasource.getByEpisodeId(episodeId);

  @override
  Stream<DownloadTask?> watchByEpisodeId(int episodeId) =>
      _datasource.watchByEpisodeId(episodeId);

  @override
  Future<List<DownloadTask>> getAll() => _datasource.getAll();

  @override
  Stream<List<DownloadTask>> watchAll() => _datasource.watchAll();

  @override
  Future<List<DownloadTask>> getByStatus(DownloadStatus status) =>
      _datasource.getByStatus(status);

  @override
  Stream<List<DownloadTask>> watchByStatus(DownloadStatus status) =>
      _datasource.watchByStatus(status);

  @override
  Future<DownloadTask?> getCompletedForEpisode(int episodeId) =>
      _datasource.getCompletedByEpisodeId(episodeId);

  @override
  Future<DownloadTask?> getNextPending({required bool isOnWifi}) =>
      _datasource.getNextPending(isOnWifi: isOnWifi);

  @override
  Future<void> updateProgress({
    required int id,
    required int downloadedBytes,
    int? totalBytes,
  }) {
    return _datasource.updateById(
      id,
      DownloadTasksCompanion(
        downloadedBytes: Value(downloadedBytes),
        totalBytes: totalBytes != null ? Value(totalBytes) : const Value.absent(),
      ),
    );
  }

  @override
  Future<void> updateStatus({
    required int id,
    required DownloadStatus status,
    String? localPath,
    String? lastError,
  }) {
    return _datasource.updateById(
      id,
      DownloadTasksCompanion(
        status: Value(status.toDbValue()),
        localPath: localPath != null ? Value(localPath) : const Value.absent(),
        lastError: lastError != null ? Value(lastError) : const Value.absent(),
        completedAt: status is DownloadStatusCompleted
            ? Value(DateTime.now())
            : const Value.absent(),
      ),
    );
  }

  @override
  Future<void> incrementRetryCount(int id) async {
    final task = await _datasource.getById(id);
    if (task == null) return;

    await _datasource.updateById(
      id,
      DownloadTasksCompanion(retryCount: Value(task.retryCount + 1)),
    );
  }

  @override
  Future<void> delete(int id) => _datasource.delete(id).then((_) {});

  @override
  Future<int> getActiveCount() => _datasource.getActiveCount();

  @override
  Future<int> getTotalStorageUsed() => _datasource.getTotalStorageUsed();

  @override
  Future<int> deleteAllCompleted() => _datasource.deleteAllCompleted();
}
```

**Step 2: Run build_runner**

Run: `cd packages/audiflow_domain && dart run build_runner build --delete-conflicting-outputs`
Expected: Generates `download_repository_impl.g.dart`

**Step 3: Run analyzer**

Run: `dart analyze packages/audiflow_domain`
Expected: No errors

**Step 4: Commit**

```bash
jj describe -m "feat(domain): add DownloadRepositoryImpl with Riverpod provider"
```

---

## Task 8: Create DownloadFileService

**Files:**
- Create: `packages/audiflow_domain/lib/src/features/download/services/download_file_service.dart`

**Step 1: Create the file service**

```dart
import 'dart:io';

import 'package:audiflow_core/audiflow_core.dart';
import 'package:dio/dio.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../common/providers/http_client_provider.dart';

part 'download_file_service.g.dart';

/// Callback for download progress updates.
typedef DownloadProgressCallback = void Function(
  int downloadedBytes,
  int totalBytes,
);

/// Service for file download operations.
///
/// Handles actual HTTP downloads using Dio with progress callbacks,
/// file path management, and storage operations.
@Riverpod(keepAlive: true)
DownloadFileService downloadFileService(Ref ref) {
  final dio = ref.watch(httpClientProvider);
  return DownloadFileService(dio: dio);
}

class DownloadFileService {
  DownloadFileService({required Dio dio}) : _dio = dio;

  final Dio _dio;
  final Map<int, CancelToken> _cancelTokens = {};

  /// Downloads a file from URL to local storage.
  ///
  /// [taskId] - Download task ID for cancellation tracking
  /// [url] - Remote file URL
  /// [episodeId] - Episode ID for filename
  /// [episodeTitle] - Episode title for filename
  /// [onProgress] - Progress callback
  /// [resumeFromBytes] - Resume from this byte position (0 for fresh download)
  ///
  /// Returns local file path on success.
  /// Throws [DownloadException] on failure.
  Future<String> downloadFile({
    required int taskId,
    required String url,
    required int episodeId,
    required String episodeTitle,
    required DownloadProgressCallback onProgress,
    int resumeFromBytes = 0,
  }) async {
    final cancelToken = CancelToken();
    _cancelTokens[taskId] = cancelToken;

    try {
      final localPath = await _getLocalPath(episodeId, episodeTitle, url);
      final file = File(localPath);

      // Ensure directory exists
      final dir = file.parent;
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }

      // Set up headers for resume
      final headers = <String, dynamic>{};
      if (0 < resumeFromBytes) {
        headers['Range'] = 'bytes=$resumeFromBytes-';
      }

      final response = await _dio.download(
        url,
        localPath,
        cancelToken: cancelToken,
        deleteOnError: false,
        options: Options(
          headers: headers,
          responseType: ResponseType.stream,
        ),
        onReceiveProgress: (received, total) {
          final totalBytes = total == -1 ? 0 : total + resumeFromBytes;
          final downloadedBytes = received + resumeFromBytes;
          onProgress(downloadedBytes, totalBytes);
        },
      );

      if (response.statusCode != 200 && response.statusCode != 206) {
        throw DownloadException(
          DownloadErrorType.serverError,
          'Server returned status ${response.statusCode}',
        );
      }

      return localPath;
    } on DioException catch (e) {
      if (e.type == DioExceptionType.cancel) {
        throw DownloadException(DownloadErrorType.cancelled, 'Download cancelled');
      }
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout) {
        throw DownloadException(
          DownloadErrorType.networkUnavailable,
          'Network unavailable: ${e.message}',
        );
      }
      throw DownloadException(
        DownloadErrorType.serverError,
        'Download failed: ${e.message}',
      );
    } on FileSystemException catch (e) {
      if (e.osError?.errorCode == 28) {
        // ENOSPC - No space left
        throw DownloadException(
          DownloadErrorType.insufficientStorage,
          'Insufficient storage space',
        );
      }
      throw DownloadException(
        DownloadErrorType.fileWriteError,
        'File write error: ${e.message}',
      );
    } finally {
      _cancelTokens.remove(taskId);
    }
  }

  /// Cancels an active download.
  void cancelDownload(int taskId) {
    _cancelTokens[taskId]?.cancel();
    _cancelTokens.remove(taskId);
  }

  /// Deletes a downloaded file.
  Future<void> deleteFile(String localPath) async {
    final file = File(localPath);
    if (await file.exists()) {
      await file.delete();
    }
  }

  /// Returns the size of a downloaded file in bytes.
  Future<int> getFileSize(String localPath) async {
    final file = File(localPath);
    if (await file.exists()) {
      return file.length();
    }
    return 0;
  }

  /// Checks if a file exists at the given path.
  Future<bool> fileExists(String localPath) async {
    return File(localPath).exists();
  }

  /// Returns the downloads directory path.
  Future<String> getDownloadsDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    return p.join(appDir.path, 'downloads');
  }

  /// Generates a local path for a download.
  Future<String> _getLocalPath(
    int episodeId,
    String episodeTitle,
    String url,
  ) async {
    final downloadsDir = await getDownloadsDirectory();
    final sanitizedTitle = _sanitizeFilename(episodeTitle);
    final extension = _getExtension(url);
    return p.join(downloadsDir, '${episodeId}_$sanitizedTitle$extension');
  }

  String _sanitizeFilename(String name) {
    // Remove invalid characters and limit length
    return name
        .replaceAll(RegExp(r'[<>:"/\\|?*]'), '')
        .replaceAll(RegExp(r'\s+'), '_')
        .substring(0, name.length.clamp(0, 50));
  }

  String _getExtension(String url) {
    final uri = Uri.parse(url);
    final path = uri.path;
    final ext = p.extension(path);
    return ext.isNotEmpty ? ext : '.mp3';
  }
}
```

**Step 2: Run build_runner**

Run: `cd packages/audiflow_domain && dart run build_runner build --delete-conflicting-outputs`
Expected: Generates `download_file_service.g.dart`

**Step 3: Run analyzer**

Run: `dart analyze packages/audiflow_domain`
Expected: No errors

**Step 4: Commit**

```bash
jj describe -m "feat(domain): add DownloadFileService for HTTP downloads with progress"
```

---

## Task 9: Create DownloadQueueService

**Files:**
- Create: `packages/audiflow_domain/lib/src/features/download/services/download_queue_service.dart`

**Step 1: Create the queue service**

```dart
import 'dart:async';

import 'package:audiflow_core/audiflow_core.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../common/database/app_database.dart';
import '../../../common/providers/logger_provider.dart';
import '../../feed/repositories/episode_repository_impl.dart';
import '../models/download_status.dart';
import '../repositories/download_repository_impl.dart';
import 'download_file_service.dart';

part 'download_queue_service.g.dart';

/// Maximum number of retry attempts per download.
const int maxRetryAttempts = 5;

/// Backoff delays in seconds for retries: 5s, 15s, 45s, 135s, 405s
const List<int> retryDelaysSeconds = [5, 15, 45, 135, 405];

/// Service for managing the download queue.
///
/// Handles sequential download processing, network state monitoring,
/// and smart retry with exponential backoff.
@Riverpod(keepAlive: true)
DownloadQueueService downloadQueueService(Ref ref) {
  final repository = ref.watch(downloadRepositoryProvider);
  final fileService = ref.watch(downloadFileServiceProvider);
  final episodeRepo = ref.watch(episodeRepositoryProvider);
  final logger = ref.watch(namedLoggerProvider('DownloadQueue'));

  final service = DownloadQueueService(
    repository: repository,
    fileService: fileService,
    episodeRepository: episodeRepo,
    logger: logger,
  );

  ref.onDispose(() => service.dispose());

  return service;
}

class DownloadQueueService {
  DownloadQueueService({
    required DownloadRepository repository,
    required DownloadFileService fileService,
    required EpisodeRepository episodeRepository,
    required Logger logger,
  }) : _repository = repository,
       _fileService = fileService,
       _episodeRepo = episodeRepository,
       _logger = logger {
    _init();
  }

  final DownloadRepository _repository;
  final DownloadFileService _fileService;
  final EpisodeRepository _episodeRepo;
  final Logger _logger;

  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  DownloadTask? _activeDownload;
  bool _isProcessing = false;
  bool _isOnWifi = false;
  Timer? _retryTimer;

  final _activeDownloadController = StreamController<DownloadTask?>.broadcast();

  /// Stream of the currently active download.
  Stream<DownloadTask?> get activeDownloadStream =>
      _activeDownloadController.stream;

  /// The currently active download, if any.
  DownloadTask? get activeDownload => _activeDownload;

  void _init() {
    _connectivitySubscription = Connectivity()
        .onConnectivityChanged
        .listen(_onConnectivityChanged);

    // Check initial connectivity
    Connectivity().checkConnectivity().then(_onConnectivityChanged);
  }

  void _onConnectivityChanged(List<ConnectivityResult> results) {
    final wasOnWifi = _isOnWifi;
    _isOnWifi = results.contains(ConnectivityResult.wifi);

    final isConnected = results.any((r) =>
        r == ConnectivityResult.wifi ||
        r == ConnectivityResult.mobile ||
        r == ConnectivityResult.ethernet);

    _logger.i('Connectivity changed: wifi=$_isOnWifi, connected=$isConnected');

    if (isConnected && !_isProcessing) {
      // Network restored - try to process queue
      _processQueue();
    }

    // WiFi connected - retry WiFi-only downloads
    if (_isOnWifi && !wasOnWifi) {
      _processQueue();
    }
  }

  /// Starts processing the download queue.
  Future<void> startQueue() async {
    if (_isProcessing) return;
    await _processQueue();
  }

  Future<void> _processQueue() async {
    if (_isProcessing) return;
    _isProcessing = true;

    try {
      while (true) {
        final nextTask = await _repository.getNextPending(isOnWifi: _isOnWifi);
        if (nextTask == null) break;

        await _processDownload(nextTask);
      }
    } finally {
      _isProcessing = false;
      _activeDownload = null;
      _activeDownloadController.add(null);
    }
  }

  Future<void> _processDownload(DownloadTask task) async {
    _activeDownload = task;
    _activeDownloadController.add(task);

    _logger.i('Starting download: episodeId=${task.episodeId}');

    // Update status to downloading
    await _repository.updateStatus(
      id: task.id,
      status: const DownloadStatus.downloading(),
    );

    try {
      // Get episode details for filename
      final episode = await _episodeRepo.getById(task.episodeId);
      if (episode == null) {
        throw DownloadException(
          DownloadErrorType.unknown,
          'Episode not found',
        );
      }

      final localPath = await _fileService.downloadFile(
        taskId: task.id,
        url: task.audioUrl,
        episodeId: task.episodeId,
        episodeTitle: episode.title,
        resumeFromBytes: task.downloadedBytes,
        onProgress: (downloaded, total) {
          _repository.updateProgress(
            id: task.id,
            downloadedBytes: downloaded,
            totalBytes: total,
          );
        },
      );

      // Download completed successfully
      await _repository.updateStatus(
        id: task.id,
        status: const DownloadStatus.completed(),
        localPath: localPath,
      );

      _logger.i('Download completed: episodeId=${task.episodeId}');
    } on DownloadException catch (e) {
      await _handleDownloadError(task, e);
    } catch (e) {
      await _handleDownloadError(
        task,
        DownloadException(DownloadErrorType.unknown, e.toString()),
      );
    }
  }

  Future<void> _handleDownloadError(
    DownloadTask task,
    DownloadException error,
  ) async {
    _logger.e('Download error: ${error.message}', error: error);

    if (error.type == DownloadErrorType.cancelled) {
      await _repository.updateStatus(
        id: task.id,
        status: const DownloadStatus.cancelled(),
        lastError: error.message,
      );
      return;
    }

    // Check if we should retry
    if (task.retryCount < maxRetryAttempts) {
      await _repository.incrementRetryCount(task.id);
      await _repository.updateStatus(
        id: task.id,
        status: const DownloadStatus.pending(),
        lastError: error.message,
      );

      // Schedule retry with backoff
      final delayIndex = task.retryCount.clamp(0, retryDelaysSeconds.length - 1);
      final delay = Duration(seconds: retryDelaysSeconds[delayIndex]);
      _logger.i('Scheduling retry in ${delay.inSeconds}s');

      _retryTimer?.cancel();
      _retryTimer = Timer(delay, () {
        if (!_isProcessing) _processQueue();
      });
    } else {
      // Max retries exceeded
      await _repository.updateStatus(
        id: task.id,
        status: const DownloadStatus.failed(),
        lastError: error.message,
      );
      _logger.w('Download failed after $maxRetryAttempts retries');
    }
  }

  /// Pauses an active download.
  Future<void> pauseDownload(int taskId) async {
    _fileService.cancelDownload(taskId);
    await _repository.updateStatus(
      id: taskId,
      status: const DownloadStatus.paused(),
    );
  }

  /// Resumes a paused download by moving it back to pending.
  Future<void> resumeDownload(int taskId) async {
    await _repository.updateStatus(
      id: taskId,
      status: const DownloadStatus.pending(),
    );
    if (!_isProcessing) _processQueue();
  }

  /// Cancels a download.
  Future<void> cancelDownload(int taskId) async {
    _fileService.cancelDownload(taskId);
    await _repository.updateStatus(
      id: taskId,
      status: const DownloadStatus.cancelled(),
    );
  }

  /// Retries a failed download.
  Future<void> retryDownload(int taskId) async {
    final task = await _repository.getById(taskId);
    if (task == null) return;

    // Reset retry count and set to pending
    await _repository.updateStatus(
      id: taskId,
      status: const DownloadStatus.pending(),
      lastError: null,
    );

    if (!_isProcessing) _processQueue();
  }

  void dispose() {
    _connectivitySubscription?.cancel();
    _retryTimer?.cancel();
    _activeDownloadController.close();
  }
}
```

**Step 2: Run build_runner**

Run: `cd packages/audiflow_domain && dart run build_runner build --delete-conflicting-outputs`
Expected: Generates `download_queue_service.g.dart`

**Step 3: Run analyzer**

Run: `dart analyze packages/audiflow_domain`
Expected: No errors

**Step 4: Commit**

```bash
jj describe -m "feat(domain): add DownloadQueueService with network-aware retry"
```

---

## Task 10: Create DownloadService

**Files:**
- Create: `packages/audiflow_domain/lib/src/features/download/services/download_service.dart`

**Step 1: Create the main download service**

```dart
import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../common/database/app_database.dart';
import '../../../common/providers/logger_provider.dart';
import '../../feed/repositories/episode_repository_impl.dart';
import '../../player/services/playback_history_service.dart';
import '../models/download_status.dart';
import '../repositories/download_repository_impl.dart';
import 'download_file_service.dart';
import 'download_queue_service.dart';

part 'download_service.g.dart';

/// Provider for WiFi-only download setting.
///
/// Override this with SharedPreferences in the app.
@riverpod
bool downloadWifiOnly(Ref ref) => true;

/// Provider for auto-delete played setting.
///
/// Override this with SharedPreferences in the app.
@riverpod
bool downloadAutoDeletePlayed(Ref ref) => false;

/// Main service for managing episode downloads.
///
/// Provides high-level API for downloading episodes, managing the queue,
/// and integrating with playback history for auto-delete.
@Riverpod(keepAlive: true)
DownloadService downloadService(Ref ref) {
  final repository = ref.watch(downloadRepositoryProvider);
  final queueService = ref.watch(downloadQueueServiceProvider);
  final fileService = ref.watch(downloadFileServiceProvider);
  final episodeRepo = ref.watch(episodeRepositoryProvider);
  final logger = ref.watch(namedLoggerProvider('Download'));

  final service = DownloadService(
    repository: repository,
    queueService: queueService,
    fileService: fileService,
    episodeRepository: episodeRepo,
    logger: logger,
    getWifiOnly: () => ref.read(downloadWifiOnlyProvider),
    getAutoDeletePlayed: () => ref.read(downloadAutoDeletePlayedProvider),
  );

  // Listen for playback completed events for auto-delete
  ref.listen(playbackHistoryServiceProvider, (_, historyService) {
    // This is a simplified version - in production, use proper event streams
  });

  ref.onDispose(() => service.dispose());

  return service;
}

class DownloadService {
  DownloadService({
    required DownloadRepository repository,
    required DownloadQueueService queueService,
    required DownloadFileService fileService,
    required EpisodeRepository episodeRepository,
    required Logger logger,
    required bool Function() getWifiOnly,
    required bool Function() getAutoDeletePlayed,
  }) : _repository = repository,
       _queueService = queueService,
       _fileService = fileService,
       _episodeRepo = episodeRepository,
       _logger = logger,
       _getWifiOnly = getWifiOnly,
       _getAutoDeletePlayed = getAutoDeletePlayed;

  final DownloadRepository _repository;
  final DownloadQueueService _queueService;
  final DownloadFileService _fileService;
  final EpisodeRepository _episodeRepo;
  final Logger _logger;
  final bool Function() _getWifiOnly;
  final bool Function() _getAutoDeletePlayed;

  /// Downloads a single episode.
  ///
  /// [wifiOnly] defaults to user's global setting if not specified.
  /// Returns the created download task, or null if already downloading.
  Future<DownloadTask?> downloadEpisode(
    int episodeId, {
    bool? wifiOnly,
  }) async {
    final episode = await _episodeRepo.getById(episodeId);
    if (episode == null) {
      _logger.w('Episode not found: $episodeId');
      return null;
    }

    final task = await _repository.createDownload(
      episodeId: episodeId,
      audioUrl: episode.audioUrl,
      wifiOnly: wifiOnly ?? _getWifiOnly(),
    );

    if (task != null) {
      _logger.i('Created download task for episode: $episodeId');
      _queueService.startQueue();
    } else {
      _logger.i('Episode already has active download: $episodeId');
    }

    return task;
  }

  /// Downloads all episodes in a season.
  ///
  /// Returns the number of downloads queued.
  Future<int> downloadSeason(
    int podcastId,
    int seasonNumber, {
    bool? wifiOnly,
  }) async {
    final episodes = await _episodeRepo.getByPodcastId(podcastId);
    final seasonEpisodes = episodes
        .where((e) => e.seasonNumber == seasonNumber)
        .toList();

    var queued = 0;
    for (final episode in seasonEpisodes) {
      final task = await downloadEpisode(episode.id, wifiOnly: wifiOnly);
      if (task != null) queued++;
    }

    _logger.i('Queued $queued downloads for season $seasonNumber');
    return queued;
  }

  /// Pauses an active download.
  Future<void> pause(int taskId) => _queueService.pauseDownload(taskId);

  /// Resumes a paused download.
  Future<void> resume(int taskId) => _queueService.resumeDownload(taskId);

  /// Cancels a download (removes from queue).
  Future<void> cancel(int taskId) => _queueService.cancelDownload(taskId);

  /// Retries a failed download.
  Future<void> retry(int taskId) => _queueService.retryDownload(taskId);

  /// Deletes a download and its file.
  Future<void> delete(int taskId) async {
    final task = await _repository.getById(taskId);
    if (task == null) return;

    // Cancel if active
    if (task.downloadStatus.isActive) {
      _queueService.cancelDownload(taskId);
    }

    // Delete file if exists
    if (task.localPath != null) {
      await _fileService.deleteFile(task.localPath!);
    }

    await _repository.delete(taskId);
    _logger.i('Deleted download: $taskId');
  }

  /// Deletes all completed downloads and their files.
  Future<void> deleteAllCompleted() async {
    final completed = await _repository.getByStatus(
      const DownloadStatus.completed(),
    );

    for (final task in completed) {
      if (task.localPath != null) {
        await _fileService.deleteFile(task.localPath!);
      }
    }

    final count = await _repository.deleteAllCompleted();
    _logger.i('Deleted $count completed downloads');
  }

  /// Returns the local file path for an episode if downloaded.
  Future<String?> getLocalPath(int episodeId) async {
    final task = await _repository.getCompletedForEpisode(episodeId);
    if (task?.localPath == null) return null;

    // Verify file exists
    if (!await _fileService.fileExists(task!.localPath!)) {
      _logger.w('Download file missing: ${task.localPath}');
      await _repository.updateStatus(
        id: task.id,
        status: const DownloadStatus.failed(),
        lastError: 'File not found',
      );
      return null;
    }

    return task.localPath;
  }

  /// Validates all downloads on app startup.
  ///
  /// - Removes orphaned records (file missing)
  /// - Resumes interrupted downloads
  Future<void> validateDownloads() async {
    _logger.i('Validating downloads...');

    // Check completed downloads have valid files
    final completed = await _repository.getByStatus(
      const DownloadStatus.completed(),
    );

    for (final task in completed) {
      if (task.localPath == null ||
          !await _fileService.fileExists(task.localPath!)) {
        _logger.w('Orphaned download record: ${task.id}');
        await _repository.delete(task.id);
      }
    }

    // Resume any interrupted downloads
    final downloading = await _repository.getByStatus(
      const DownloadStatus.downloading(),
    );

    for (final task in downloading) {
      await _repository.updateStatus(
        id: task.id,
        status: const DownloadStatus.pending(),
      );
    }

    if (downloading.isNotEmpty) {
      _queueService.startQueue();
    }

    _logger.i('Validation complete');
  }

  /// Handles auto-delete when episode is marked as played.
  Future<void> onEpisodeCompleted(int episodeId) async {
    if (!_getAutoDeletePlayed()) return;

    final task = await _repository.getByEpisodeId(episodeId);
    if (task == null) return;

    if (task.downloadStatus is DownloadStatusCompleted) {
      await delete(task.id);
      _logger.i('Auto-deleted played episode: $episodeId');
    }
  }

  /// Returns total storage used by downloads in bytes.
  Future<int> getTotalStorageUsed() => _repository.getTotalStorageUsed();

  /// Stream of the currently active download.
  Stream<DownloadTask?> get activeDownloadStream =>
      _queueService.activeDownloadStream;

  void dispose() {
    // Cleanup handled by queue service
  }
}
```

**Step 2: Run build_runner**

Run: `cd packages/audiflow_domain && dart run build_runner build --delete-conflicting-outputs`
Expected: Generates `download_service.g.dart`

**Step 3: Run analyzer**

Run: `dart analyze packages/audiflow_domain`
Expected: No errors

**Step 4: Commit**

```bash
jj describe -m "feat(domain): add DownloadService as main download API"
```

---

## Task 11: Export Download Feature from Domain Package

**Files:**
- Modify: `packages/audiflow_domain/lib/audiflow_domain.dart`

**Step 1: Add exports for download feature**

Add these export lines in the appropriate section:

```dart
// Download feature
export 'src/features/download/models/download_status.dart';
export 'src/features/download/models/download_task.dart';
export 'src/features/download/repositories/download_repository.dart';
export 'src/features/download/repositories/download_repository_impl.dart';
export 'src/features/download/services/download_file_service.dart';
export 'src/features/download/services/download_queue_service.dart';
export 'src/features/download/services/download_service.dart';
```

**Step 2: Run analyzer**

Run: `dart analyze packages/audiflow_domain`
Expected: No errors

**Step 3: Commit**

```bash
jj describe -m "feat(domain): export download feature from domain package"
```

---

## Task 12: Integrate Downloads with AudioPlayerService

**Files:**
- Modify: `packages/audiflow_domain/lib/src/features/player/services/audio_player_service.dart`

**Step 1: Import download service**

Add import at top:
```dart
import '../../download/services/download_service.dart';
```

**Step 2: Modify play method to check for local file**

Update the `play` method in `AudioPlayerController`:

```dart
/// Plays audio from the specified URL.
///
/// If a completed download exists for this episode, plays from local file.
/// Otherwise streams from the remote URL.
///
/// Optional [metadata] can be provided to display episode information
/// in the mini player without needing to fetch it from the database.
///
/// Integrates with [PlaybackHistoryService] to track playback progress.
Future<void> play(String url, {NowPlayingInfo? metadata}) async {
  try {
    // Save progress of previous episode before switching
    if (_currentEpisodeId != null && _currentUrl != url) {
      await _saveProgressOnStop();
    }

    // Look up episode ID from URL
    final episodeRepo = ref.read(episodeRepositoryProvider);
    final episode = await episodeRepo.getByAudioUrl(url);

    _currentUrl = url;
    _currentEpisodeId = episode?.id;
    state = PlaybackState.loading(episodeUrl: url);

    // Update now playing controller if metadata is provided
    if (metadata != null) {
      ref.read(nowPlayingControllerProvider.notifier).setNowPlaying(metadata);
    }

    // Check for local download
    String playUrl = url;
    if (episode != null) {
      final downloadService = ref.read(downloadServiceProvider);
      final localPath = await downloadService.getLocalPath(episode.id);
      if (localPath != null) {
        playUrl = 'file://$localPath';
      }
    }

    await _player.setUrl(playUrl);

    // Notify history service of playback start
    if (_currentEpisodeId != null) {
      final historyService = ref.read(playbackHistoryServiceProvider);
      await historyService.onPlaybackStarted(
        _currentEpisodeId!,
        _player.position.inMilliseconds,
      );
    }

    await _player.play();
  } catch (e) {
    state = PlaybackState.error(message: 'Failed to play audio: $e');
  }
}
```

**Step 3: Run build_runner**

Run: `cd packages/audiflow_domain && dart run build_runner build --delete-conflicting-outputs`
Expected: No errors

**Step 4: Run analyzer**

Run: `dart analyze packages/audiflow_domain`
Expected: No errors

**Step 5: Commit**

```bash
jj describe -m "feat(player): integrate download service for offline playback"
```

---

## Task 13: Add Download Providers for UI

**Files:**
- Create: `packages/audiflow_domain/lib/src/features/download/providers/download_providers.dart`

**Step 1: Create UI-facing providers**

```dart
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../common/database/app_database.dart';
import '../models/download_status.dart';
import '../repositories/download_repository_impl.dart';
import '../services/download_service.dart';

part 'download_providers.g.dart';

/// Watches download task for a specific episode.
@riverpod
Stream<DownloadTask?> episodeDownload(Ref ref, int episodeId) {
  final repository = ref.watch(downloadRepositoryProvider);
  return repository.watchByEpisodeId(episodeId);
}

/// Watches all download tasks.
@riverpod
Stream<List<DownloadTask>> allDownloads(Ref ref) {
  final repository = ref.watch(downloadRepositoryProvider);
  return repository.watchAll();
}

/// Watches pending downloads (queue).
@riverpod
Stream<List<DownloadTask>> pendingDownloads(Ref ref) {
  final repository = ref.watch(downloadRepositoryProvider);
  return repository.watchByStatus(const DownloadStatus.pending());
}

/// Watches completed downloads.
@riverpod
Stream<List<DownloadTask>> completedDownloads(Ref ref) {
  final repository = ref.watch(downloadRepositoryProvider);
  return repository.watchByStatus(const DownloadStatus.completed());
}

/// Watches failed downloads.
@riverpod
Stream<List<DownloadTask>> failedDownloads(Ref ref) {
  final repository = ref.watch(downloadRepositoryProvider);
  return repository.watchByStatus(const DownloadStatus.failed());
}

/// Watches the currently active download.
@riverpod
Stream<DownloadTask?> activeDownload(Ref ref) {
  final service = ref.watch(downloadServiceProvider);
  return service.activeDownloadStream;
}

/// Returns count of downloads needing attention (failed).
@riverpod
Future<int> downloadsNeedingAttention(Ref ref) async {
  final repository = ref.watch(downloadRepositoryProvider);
  final failed = await repository.getByStatus(const DownloadStatus.failed());
  return failed.length;
}

/// Returns total storage used by downloads.
@riverpod
Future<int> downloadStorageUsed(Ref ref) {
  final service = ref.watch(downloadServiceProvider);
  return service.getTotalStorageUsed();
}

/// Check if an episode is downloaded.
@riverpod
Future<bool> isEpisodeDownloaded(Ref ref, int episodeId) async {
  final repository = ref.watch(downloadRepositoryProvider);
  final task = await repository.getCompletedForEpisode(episodeId);
  return task != null;
}
```

**Step 2: Add export to audiflow_domain.dart**

```dart
export 'src/features/download/providers/download_providers.dart';
```

**Step 3: Run build_runner**

Run: `cd packages/audiflow_domain && dart run build_runner build --delete-conflicting-outputs`
Expected: Generates `download_providers.g.dart`

**Step 4: Run analyzer**

Run: `dart analyze packages/audiflow_domain`
Expected: No errors

**Step 5: Commit**

```bash
jj describe -m "feat(domain): add download providers for reactive UI"
```

---

## Task 14: Create Download Status Widget

**Files:**
- Create: `packages/audiflow_ui/lib/src/widgets/downloads/download_status_icon.dart`

**Step 1: Create the status icon widget**

```dart
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:flutter/material.dart';

/// Displays an icon representing download status.
///
/// Shows different icons based on download state:
/// - Not downloaded: download icon
/// - Pending: clock icon with queue position
/// - Downloading: progress ring
/// - Paused: pause icon
/// - Completed: checkmark
/// - Failed: error icon
class DownloadStatusIcon extends StatelessWidget {
  const DownloadStatusIcon({
    super.key,
    required this.task,
    this.size = 24.0,
    this.onTap,
  });

  /// The download task, or null if not downloaded.
  final DownloadTask? task;

  /// Icon size.
  final double size;

  /// Callback when icon is tapped.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (task == null) {
      return _buildIconButton(
        icon: Icons.download_outlined,
        color: colorScheme.onSurfaceVariant,
      );
    }

    return task!.downloadStatus.when(
      pending: () => _buildIconButton(
        icon: Icons.schedule,
        color: colorScheme.onSurfaceVariant,
      ),
      downloading: () => _buildProgressRing(colorScheme),
      paused: () => _buildIconButton(
        icon: Icons.pause_circle_outline,
        color: colorScheme.primary,
      ),
      completed: () => _buildIconButton(
        icon: Icons.check_circle,
        color: colorScheme.primary,
      ),
      failed: () => _buildIconButton(
        icon: Icons.error_outline,
        color: colorScheme.error,
      ),
      cancelled: () => _buildIconButton(
        icon: Icons.download_outlined,
        color: colorScheme.onSurfaceVariant,
      ),
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required Color color,
  }) {
    return IconButton(
      icon: Icon(icon, size: size),
      color: color,
      onPressed: onTap,
      padding: EdgeInsets.zero,
      constraints: BoxConstraints(
        minWidth: size + 16,
        minHeight: size + 16,
      ),
    );
  }

  Widget _buildProgressRing(ColorScheme colorScheme) {
    final progress = task!.progress;

    return SizedBox(
      width: size + 16,
      height: size + 16,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              value: progress,
              strokeWidth: 2.5,
              backgroundColor: colorScheme.surfaceContainerHighest,
              color: colorScheme.primary,
            ),
          ),
          IconButton(
            icon: Icon(Icons.pause, size: size * 0.6),
            color: colorScheme.primary,
            onPressed: onTap,
            padding: EdgeInsets.zero,
            constraints: BoxConstraints(
              minWidth: size,
              minHeight: size,
            ),
          ),
        ],
      ),
    );
  }
}
```

**Step 2: Export from audiflow_ui**

Add to `packages/audiflow_ui/lib/audiflow_ui.dart`:
```dart
export 'src/widgets/downloads/download_status_icon.dart';
```

**Step 3: Run analyzer**

Run: `dart analyze packages/audiflow_ui`
Expected: No errors

**Step 4: Commit**

```bash
jj describe -m "feat(ui): add DownloadStatusIcon widget"
```

---

## Task 15: Add Download Button to SeasonEpisodeListTile

**Files:**
- Modify: `packages/audiflow_app/lib/features/podcast_detail/presentation/widgets/season_episode_list_tile.dart`

**Step 1: Import download providers**

Add at top:
```dart
import 'package:audiflow_domain/audiflow_domain.dart';
```
(DownloadTask and providers are exported from audiflow_domain)

**Step 2: Add download button next to play button**

In the `build` method, watch the download state:
```dart
final downloadAsync = ref.watch(episodeDownloadProvider(episode.id));
final downloadTask = downloadAsync.value;
```

**Step 3: Update _buildPlayButton to include download action**

Modify the trailing widget to show both play and download buttons:

```dart
trailing: Row(
  mainAxisSize: MainAxisSize.min,
  children: [
    _buildDownloadButton(context, ref, downloadTask),
    _buildPlayButton(
      context,
      ref,
      audioUrl: audioUrl,
      isPlaying: isPlaying,
      isLoading: isLoading,
    ),
  ],
),
```

**Step 4: Add _buildDownloadButton method**

```dart
Widget _buildDownloadButton(
  BuildContext context,
  WidgetRef ref,
  DownloadTask? task,
) {
  return DownloadStatusIcon(
    task: task,
    size: 24,
    onTap: () => _onDownloadTap(context, ref, task),
  );
}

Future<void> _onDownloadTap(
  BuildContext context,
  WidgetRef ref,
  DownloadTask? task,
) async {
  final downloadService = ref.read(downloadServiceProvider);
  final messenger = ScaffoldMessenger.of(context);

  if (task == null) {
    // Start download
    final result = await downloadService.downloadEpisode(episode.id);
    if (result != null) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Download started')),
      );
    }
    return;
  }

  task.downloadStatus.when(
    pending: () async {
      await downloadService.cancel(task.id);
      messenger.showSnackBar(
        const SnackBar(content: Text('Download cancelled')),
      );
    },
    downloading: () async {
      await downloadService.pause(task.id);
    },
    paused: () async {
      await downloadService.resume(task.id);
    },
    completed: () {
      _showDeleteConfirmation(context, ref, task);
    },
    failed: () async {
      await downloadService.retry(task.id);
      messenger.showSnackBar(
        const SnackBar(content: Text('Retrying download')),
      );
    },
    cancelled: () async {
      final result = await downloadService.downloadEpisode(episode.id);
      if (result != null) {
        messenger.showSnackBar(
          const SnackBar(content: Text('Download started')),
        );
      }
    },
  );
}

void _showDeleteConfirmation(
  BuildContext context,
  WidgetRef ref,
  DownloadTask task,
) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Delete download?'),
      content: const Text('The downloaded file will be removed.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () async {
            Navigator.pop(context);
            await ref.read(downloadServiceProvider).delete(task.id);
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Download deleted')),
              );
            }
          },
          child: const Text('Delete'),
        ),
      ],
    ),
  );
}
```

**Step 5: Add download actions to context menu**

In `_showContextMenu`, add download-related options based on state.

**Step 6: Run analyzer**

Run: `dart analyze packages/audiflow_app`
Expected: No errors

**Step 7: Commit**

```bash
jj describe -m "feat(app): add download button to SeasonEpisodeListTile"
```

---

## Task 16: Write Unit Tests for DownloadRepository

**Files:**
- Create: `packages/audiflow_domain/test/features/download/repositories/download_repository_impl_test.dart`

**Step 1: Create test file**

```dart
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../common/database/test_database.dart';

void main() {
  late AppDatabase db;
  late DownloadRepositoryImpl repository;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    final datasource = DownloadLocalDatasource(db);
    repository = DownloadRepositoryImpl(datasource: datasource);

    // Create test subscription and episode
    await db.into(db.subscriptions).insert(
      SubscriptionsCompanion.insert(
        feedUrl: 'https://example.com/feed.xml',
        title: 'Test Podcast',
        subscribedAt: DateTime.now(),
      ),
    );

    await db.into(db.episodes).insert(
      EpisodesCompanion.insert(
        podcastId: 1,
        guid: 'ep-1',
        title: 'Episode 1',
        audioUrl: 'https://example.com/ep1.mp3',
      ),
    );
  });

  tearDown(() async {
    await db.close();
  });

  group('createDownload', () {
    test('creates new download task', () async {
      final task = await repository.createDownload(
        episodeId: 1,
        audioUrl: 'https://example.com/ep1.mp3',
        wifiOnly: true,
      );

      expect(task, isNotNull);
      expect(task!.episodeId, 1);
      expect(task.wifiOnly, true);
      expect(task.downloadStatus, isA<DownloadStatusPending>());
    });

    test('returns null if episode already has active download', () async {
      await repository.createDownload(
        episodeId: 1,
        audioUrl: 'https://example.com/ep1.mp3',
        wifiOnly: true,
      );

      final duplicate = await repository.createDownload(
        episodeId: 1,
        audioUrl: 'https://example.com/ep1.mp3',
        wifiOnly: true,
      );

      expect(duplicate, isNull);
    });

    test('allows re-download after cancellation', () async {
      final first = await repository.createDownload(
        episodeId: 1,
        audioUrl: 'https://example.com/ep1.mp3',
        wifiOnly: true,
      );

      await repository.updateStatus(
        id: first!.id,
        status: const DownloadStatus.cancelled(),
      );

      final second = await repository.createDownload(
        episodeId: 1,
        audioUrl: 'https://example.com/ep1.mp3',
        wifiOnly: false,
      );

      expect(second, isNotNull);
      expect(second!.wifiOnly, false);
    });
  });

  group('updateProgress', () {
    test('updates download progress', () async {
      final task = await repository.createDownload(
        episodeId: 1,
        audioUrl: 'https://example.com/ep1.mp3',
        wifiOnly: true,
      );

      await repository.updateProgress(
        id: task!.id,
        downloadedBytes: 5000,
        totalBytes: 10000,
      );

      final updated = await repository.getById(task.id);
      expect(updated!.downloadedBytes, 5000);
      expect(updated.totalBytes, 10000);
      expect(updated.progress, 0.5);
    });
  });

  group('updateStatus', () {
    test('updates status to completed with local path', () async {
      final task = await repository.createDownload(
        episodeId: 1,
        audioUrl: 'https://example.com/ep1.mp3',
        wifiOnly: true,
      );

      await repository.updateStatus(
        id: task!.id,
        status: const DownloadStatus.completed(),
        localPath: '/path/to/file.mp3',
      );

      final updated = await repository.getById(task.id);
      expect(updated!.downloadStatus, isA<DownloadStatusCompleted>());
      expect(updated.localPath, '/path/to/file.mp3');
      expect(updated.completedAt, isNotNull);
    });
  });
}
```

**Step 2: Run tests**

Run: `cd packages/audiflow_domain && flutter test test/features/download/`
Expected: All tests pass

**Step 3: Commit**

```bash
jj describe -m "test(domain): add unit tests for DownloadRepository"
```

---

## Summary

This plan covers the core domain layer implementation:

1. **Tasks 1-4**: Data model (DownloadException, DownloadStatus, DownloadTask table, schema migration)
2. **Tasks 5-7**: Repository layer (datasource, interface, implementation)
3. **Tasks 8-10**: Service layer (file service, queue service, main service)
4. **Tasks 11-13**: Integration (exports, AudioPlayer integration, UI providers)
5. **Tasks 14-15**: Basic UI (status icon, episode tile integration)
6. **Task 16**: Testing

**Remaining work** (separate plan):
- Downloads management screen
- Settings integration
- Season-level "Download All" button
- Background download support (iOS/Android platform code)
- Widget tests
- Integration tests
