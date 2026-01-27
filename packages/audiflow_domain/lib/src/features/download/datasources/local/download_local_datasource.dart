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

  /// Updates specific fields of a download task by ID.
  Future<int> updateById(int id, DownloadTasksCompanion companion) {
    return (_db.update(
      _db.downloadTasks,
    )..where((t) => t.id.equals(id))).write(companion);
  }

  /// Deletes a download task by ID.
  Future<int> delete(int id) {
    return (_db.delete(_db.downloadTasks)..where((t) => t.id.equals(id))).go();
  }

  /// Returns a download task by ID.
  Future<DownloadTask?> getById(int id) {
    return (_db.select(
      _db.downloadTasks,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  /// Returns a download task by episode ID.
  Future<DownloadTask?> getByEpisodeId(int episodeId) {
    return (_db.select(
      _db.downloadTasks,
    )..where((t) => t.episodeId.equals(episodeId))).getSingleOrNull();
  }

  /// Watches a download task by episode ID.
  Stream<DownloadTask?> watchByEpisodeId(int episodeId) {
    return (_db.select(
      _db.downloadTasks,
    )..where((t) => t.episodeId.equals(episodeId))).watchSingleOrNull();
  }

  /// Returns all download tasks ordered by creation date (oldest first = FIFO).
  Future<List<DownloadTask>> getAll() {
    return (_db.select(
      _db.downloadTasks,
    )..orderBy([(t) => OrderingTerm.asc(t.createdAt)])).get();
  }

  /// Watches all download tasks ordered by creation date.
  Stream<List<DownloadTask>> watchAll() {
    return (_db.select(
      _db.downloadTasks,
    )..orderBy([(t) => OrderingTerm.asc(t.createdAt)])).watch();
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
    return (_db.select(_db.downloadTasks)..where(
          (t) =>
              t.episodeId.equals(episodeId) &
              t.status.equals(const DownloadStatus.completed().toDbValue()),
        ))
        .getSingleOrNull();
  }

  /// Returns the next pending download (FIFO order, respecting wifiOnly).
  Future<DownloadTask?> getNextPending({required bool isOnWifi}) {
    final query = _db.select(_db.downloadTasks)
      ..where(
        (t) => t.status.equals(const DownloadStatus.pending().toDbValue()),
      );

    if (!isOnWifi) {
      query.where((t) => t.wifiOnly.equals(false));
    }

    query
      ..orderBy([(t) => OrderingTerm.asc(t.createdAt)])
      ..limit(1);

    return query.getSingleOrNull();
  }

  /// Returns count of active downloads (pending + downloading + paused).
  Future<int> getActiveCount() async {
    final activeStatuses = [
      const DownloadStatus.pending().toDbValue(),
      const DownloadStatus.downloading().toDbValue(),
      const DownloadStatus.paused().toDbValue(),
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
      ..where(
        _db.downloadTasks.status.equals(
          const DownloadStatus.completed().toDbValue(),
        ),
      );

    final result = await query.getSingle();
    return result.read(_db.downloadTasks.totalBytes.sum()) ?? 0;
  }

  /// Deletes all completed downloads.
  Future<int> deleteAllCompleted() {
    return (_db.delete(_db.downloadTasks)..where(
          (t) => t.status.equals(const DownloadStatus.completed().toDbValue()),
        ))
        .go();
  }
}
