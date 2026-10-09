import 'package:isar_community/isar.dart';

import '../../models/download_file_removal.dart';
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

  /// Replaces the stored task with [task].
  ///
  /// Writes the whole row, so a copy read earlier overwrites fields other
  /// writers changed since. Use [modify] to change fields of a live task.
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

  /// Applies [change] to the stored task and saves it. Returns false if
  /// [id] is unknown.
  ///
  /// The read happens inside the write transaction: a copy read before it
  /// would put back fields that a concurrent writer changed in between,
  /// such as the origin a keep request just promoted.
  Future<bool> modify(int id, void Function(DownloadTask task) change) {
    return _isar.writeTxn(() async {
      final task = await _isar.downloadTasks.get(id);
      if (task == null) return false;
      change(task);
      await _isar.downloadTasks.put(task);
      return true;
    });
  }

  /// Promotes an auto download to manual. Returns true only if the task
  /// still exists and was auto, so a caller can tell a real promotion
  /// from a task that was deleted or already manual in the meantime.
  Future<bool> markManual(int id) {
    return _isar.writeTxn(() async {
      final task = await _isar.downloadTasks.get(id);
      if (task == null || task.downloadOrigin != DownloadOrigin.auto) {
        return false;
      }
      task.origin = DownloadOrigin.manual.dbValue;
      await _isar.downloadTasks.put(task);
      return true;
    });
  }

  /// Deletes the task only if it is still an auto download, recording a
  /// [DownloadFileRemoval] for its files. Returns the deleted row and that
  /// record, or null if the task is gone or was kept.
  ///
  /// The origin check, the delete, and the removal record share one
  /// transaction, so a keep request cannot land between retention's check
  /// and its delete, and the files are never left with nothing pointing at
  /// them.
  Future<({DownloadTask task, DownloadFileRemoval fileRemoval})?> deleteIfAuto(
    int id,
  ) {
    return _isar.writeTxn(() async {
      final task = await _isar.downloadTasks.get(id);
      if (task == null || task.downloadOrigin != DownloadOrigin.auto) {
        return null;
      }
      await _isar.downloadTasks.delete(id);
      final fileRemoval = DownloadFileRemoval()
        ..episodeId = task.episodeId
        ..storedPath = task.localPath;
      await _isar.downloadFileRemovals.put(fileRemoval);
      return (task: task, fileRemoval: fileRemoval);
    });
  }

  /// Returns the file removals still pending, oldest first.
  Future<List<DownloadFileRemoval>> getFileRemovals() {
    return _isar.downloadFileRemovals.where().findAll();
  }

  /// Runs [removeFiles] unless a download task of [episodeId] exists,
  /// after deleting the task [taskId] and the file removal record
  /// [fileRemovalId] when given. Returns whether [removeFiles] ran.
  ///
  /// Every download of an episode writes the same file name, so the check
  /// and the removal must not let a new task in between. Both run inside
  /// one write transaction, and Isar's write lock holds across isolates,
  /// so a task created meanwhile, in the foreground or a background
  /// worker, is only committed once the files are gone. If [removeFiles]
  /// throws, nothing is committed: the task and the record stay for a
  /// retry.
  ///
  /// [removeFiles] must not open a transaction of its own.
  Future<bool> removeEpisodeFiles({
    required int episodeId,
    required Future<void> Function() removeFiles,
    int? taskId,
    int? fileRemovalId,
  }) {
    return _isar.writeTxn(() async {
      if (taskId != null) await _isar.downloadTasks.delete(taskId);
      if (fileRemovalId != null) {
        await _isar.downloadFileRemovals.delete(fileRemovalId);
      }
      // A task of the episode owns its files now; deleting them would take
      // its download too. Removing that task later sweeps the same files.
      if (await _isar.downloadTasks.getByEpisodeId(episodeId) != null) {
        return false;
      }
      await removeFiles();
      return true;
    });
  }

  /// [removeEpisodeFiles] for many tasks in one transaction. Re-reads the
  /// tasks [taskIds], deletes those [isRemovable] accepts, then removes
  /// with [removeFiles] the files of their episodes that have no task left.
  /// Returns the deleted tasks.
  ///
  /// [removeFiles] returns the episodes whose files it could not delete.
  /// Those get a [DownloadFileRemoval] in the same transaction, retried
  /// with the retention removals, because the files it did delete cannot
  /// come back and so their records must go. [removeFiles] must not open a
  /// transaction of its own.
  Future<List<DownloadTask>> removeTasksWithFiles({
    required Iterable<int> taskIds,
    required bool Function(DownloadTask task) isRemovable,
    required Future<Set<int>> Function(List<DownloadTask> tasks) removeFiles,
  }) {
    return _isar.writeTxn(() async {
      final tasks = [
        for (final task in await _isar.downloadTasks.getAll(taskIds.toList()))
          if (task != null && isRemovable(task)) task,
      ];
      if (tasks.isEmpty) return tasks;
      await _isar.downloadTasks.deleteAll([for (final task in tasks) task.id]);
      final orphaned = await _withoutTaskLeft(tasks);
      if (orphaned.isEmpty) return tasks;
      final failed = await removeFiles(orphaned);
      await _isar.downloadFileRemovals.putAll([
        for (final task in orphaned)
          if (failed.contains(task.episodeId))
            DownloadFileRemoval()
              ..episodeId = task.episodeId
              ..storedPath = task.localPath,
      ]);
      return tasks;
    });
  }

  /// The [tasks] whose episode has no download task left. A task of the
  /// episode owns its files now; deleting them would take its download
  /// too. Removing that task later sweeps the same files.
  Future<List<DownloadTask>> _withoutTaskLeft(List<DownloadTask> tasks) async {
    final owned = {
      for (final task in await getByEpisodeIds({
        for (final task in tasks) task.episodeId,
      }))
        task.episodeId,
    };
    return [
      for (final task in tasks)
        if (!owned.contains(task.episodeId)) task,
    ];
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
  Future<List<DownloadTask>> getByEpisodeIds(Iterable<int> episodeIds) async {
    // An empty anyOf adds no where clause, which would match every task.
    if (episodeIds.isEmpty) return [];
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
