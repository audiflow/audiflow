import 'package:isar_community/isar.dart';

import '../../models/download_origin.dart';
import '../../models/download_status.dart';
import '../../models/download_task.dart';

/// Local datasource for download task operations using Isar.
///
/// Provides CRUD operations and queries for the DownloadTask collection.
class DownloadLocalDatasource {
  DownloadLocalDatasource(this._isar);

  final Isar _isar;

  /// Creates a new download task. Returns the task ID.
  Future<int> create(DownloadTask task) async {
    await _isar.writeTxn(() => _isar.downloadTasks.put(task));
    return task.id;
  }

  /// Updates a download task by ID.
  Future<int> updateById(int id, DownloadTask task) async {
    task.id = id;
    await _isar.writeTxn(() => _isar.downloadTasks.put(task));
    return 1;
  }

  /// Deletes a download task by ID.
  Future<int> delete(int id) async {
    final deleted = await _isar.writeTxn(() => _isar.downloadTasks.delete(id));
    return deleted ? 1 : 0;
  }

  /// Marks the task as a manual download. Reads the row inside the write
  /// transaction so concurrent progress or status writes are not
  /// overwritten with a stale copy. Does nothing if [id] is unknown.
  Future<void> markManual(int id) {
    return _isar.writeTxn(() async {
      final task = await _isar.downloadTasks.get(id);
      if (task == null) return;
      task.origin = DownloadOrigin.manual.dbValue;
      await _isar.downloadTasks.put(task);
    });
  }

  /// Returns a download task by ID.
  Future<DownloadTask?> getById(int id) {
    return _isar.downloadTasks.get(id);
  }

  /// Returns a download task by episode ID.
  Future<DownloadTask?> getByEpisodeId(int episodeId) {
    return _isar.downloadTasks.getByEpisodeId(episodeId);
  }

  /// Watches a download task by episode ID.
  Stream<DownloadTask?> watchByEpisodeId(int episodeId) {
    return _isar.downloadTasks
        .filter()
        .episodeIdEqualTo(episodeId)
        .watch(fireImmediately: true)
        .map((list) => list.isEmpty ? null : list.first);
  }

  /// Returns all download tasks ordered by creation date (oldest first).
  Future<List<DownloadTask>> getAll() {
    return _isar.downloadTasks.where().sortByCreatedAt().findAll();
  }

  /// Returns the download tasks of the given episodes.
  Future<List<DownloadTask>> getByEpisodeIds(Iterable<int> episodeIds) {
    return _isar.downloadTasks
        .where()
        .anyOf(episodeIds, (query, id) => query.episodeIdEqualTo(id))
        .findAll();
  }

  /// Watches all download tasks ordered by creation date.
  Stream<List<DownloadTask>> watchAll() {
    return _isar.downloadTasks.where().sortByCreatedAt().watch(
      fireImmediately: true,
    );
  }

  /// Returns download tasks by status.
  Future<List<DownloadTask>> getByStatus(DownloadStatus status) {
    return _isar.downloadTasks
        .filter()
        .statusEqualTo(status.toDbValue())
        .sortByCreatedAt()
        .findAll();
  }

  /// Watches download tasks by status.
  Stream<List<DownloadTask>> watchByStatus(DownloadStatus status) {
    return _isar.downloadTasks
        .filter()
        .statusEqualTo(status.toDbValue())
        .sortByCreatedAt()
        .watch(fireImmediately: true);
  }

  /// Returns completed downloads for an episode (for playback lookup).
  Future<DownloadTask?> getCompletedByEpisodeId(int episodeId) {
    return _isar.downloadTasks
        .filter()
        .episodeIdEqualTo(episodeId)
        .and()
        .statusEqualTo(const DownloadStatus.completed().toDbValue())
        .findFirst();
  }

  /// Returns the next pending download (FIFO order, respecting wifiOnly),
  /// skipping tasks whose ids are in [excludeIds].
  Future<DownloadTask?> getNextPending({
    required bool isOnWifi,
    Set<int> excludeIds = const {},
  }) {
    var query = _isar.downloadTasks.filter().statusEqualTo(
      const DownloadStatus.pending().toDbValue(),
    );

    if (!isOnWifi) {
      query = query.and().wifiOnlyEqualTo(false);
    }
    for (final id in excludeIds) {
      query = query.and().not().idEqualTo(id);
    }

    return query.sortByCreatedAt().findFirst();
  }

  /// Returns count of active downloads (pending + downloading + paused).
  Future<int> getActiveCount() {
    return _isar.downloadTasks
        .filter()
        .statusEqualTo(const DownloadStatus.pending().toDbValue())
        .or()
        .statusEqualTo(const DownloadStatus.downloading().toDbValue())
        .or()
        .statusEqualTo(const DownloadStatus.paused().toDbValue())
        .count();
  }

  /// Returns total storage used by completed downloads.
  Future<int> getTotalStorageUsed() async {
    final completed = await _isar.downloadTasks
        .filter()
        .statusEqualTo(const DownloadStatus.completed().toDbValue())
        .findAll();
    return completed.fold<int>(0, (sum, task) => sum + (task.totalBytes ?? 0));
  }
}
