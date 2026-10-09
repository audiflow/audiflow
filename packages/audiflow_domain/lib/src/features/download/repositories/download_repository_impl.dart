import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../common/providers/database_provider.dart';
import '../datasources/local/download_local_datasource.dart';
import '../models/download_file_removal.dart';
import '../models/download_origin.dart';
import '../models/download_status.dart';
import '../models/download_task.dart';
import 'download_repository.dart';

part 'download_repository_impl.g.dart';

/// Provides a singleton [DownloadRepository] instance.
@Riverpod(keepAlive: true)
DownloadRepository downloadRepository(Ref ref) {
  final isar = ref.watch(isarProvider);
  final datasource = DownloadLocalDatasource(isar);
  return DownloadRepositoryImpl(datasource: datasource);
}

/// Implementation of [DownloadRepository] using Isar database.
class DownloadRepositoryImpl implements DownloadRepository {
  DownloadRepositoryImpl({required this._datasource});

  final DownloadLocalDatasource _datasource;

  @override
  Future<DownloadTask?> createDownload({
    required int episodeId,
    required String audioUrl,
    required bool wifiOnly,
    DownloadOrigin origin = DownloadOrigin.manual,
  }) async {
    // Check if download already exists for this episode
    final existing = await _datasource.getByEpisodeId(episodeId);
    if (existing != null) {
      final status = existing.downloadStatus;
      // Allow re-download only if cancelled or failed
      if (status is! DownloadStatusCancelled &&
          status is! DownloadStatusFailed) {
        await _promoteToManualIfRequested(existing, origin);
        return null;
      }
      // Delete old record and create new
      await _datasource.delete(existing.id);
    }

    final task = DownloadTask()
      ..episodeId = episodeId
      ..audioUrl = audioUrl
      ..wifiOnly = wifiOnly
      ..origin = origin.dbValue
      ..createdAt = DateTime.now();

    final id = await _datasource.create(task);
    return _datasource.getById(id);
  }

  Future<void> _promoteToManualIfRequested(
    DownloadTask existing,
    DownloadOrigin requested,
  ) async {
    if (requested != DownloadOrigin.manual) return;
    if (existing.downloadOrigin == DownloadOrigin.manual) return;
    await _datasource.markManual(existing.id);
  }

  @override
  Future<bool> markManual(int id) => _datasource.markManual(id);

  @override
  Future<DeletedAutoDownload?> deleteIfAuto(int id) =>
      _datasource.deleteIfAuto(id);

  @override
  Future<List<DownloadFileRemoval>> getPendingFileRemovals() =>
      _datasource.getFileRemovals();

  @override
  Future<bool> removeEpisodeFiles({
    required int episodeId,
    required Future<void> Function() removeFiles,
    int? taskId,
    int? fileRemovalId,
  }) => _datasource.removeEpisodeFiles(
    episodeId: episodeId,
    removeFiles: removeFiles,
    taskId: taskId,
    fileRemovalId: fileRemovalId,
  );

  @override
  Future<List<DownloadTask>> removeTasksWithFiles({
    required Iterable<int> taskIds,
    required bool Function(DownloadTask task) isRemovable,
    required Future<Set<int>> Function(List<DownloadTask> tasks) removeFiles,
  }) => _datasource.removeTasksWithFiles(
    taskIds: taskIds,
    isRemovable: isRemovable,
    removeFiles: removeFiles,
  );

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
  Future<List<DownloadTask>> getByEpisodeIds(Iterable<int> episodeIds) =>
      _datasource.getByEpisodeIds(episodeIds);

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
  Future<DownloadTask?> getNextPending({
    required bool isOnWifi,
    Set<int> excludeIds = const {},
  }) => _datasource.getNextPending(isOnWifi: isOnWifi, excludeIds: excludeIds);

  // Every writer below changes its fields inside one write transaction
  // (see DownloadLocalDatasource.modify), so a progress or status write
  // racing a keep request cannot restore the old origin.

  @override
  Future<void> updateProgress({
    required int id,
    required int downloadedBytes,
    int? totalBytes,
  }) async {
    await _datasource.modify(id, (task) {
      task.downloadedBytes = downloadedBytes;
      if (totalBytes != null) task.totalBytes = totalBytes;
    });
  }

  @override
  Future<void> updateStatus({
    required int id,
    required DownloadStatus status,
    String? localPath,
    String? lastError,
  }) async {
    await _datasource.modify(id, (task) {
      // Only set completedAt when transitioning to completed, not when
      // the task is already completed (e.g. path migration updates).
      final wasAlreadyCompleted =
          task.downloadStatus is DownloadStatusCompleted;
      task.status = status.toDbValue();
      if (localPath != null) task.localPath = localPath;
      if (lastError != null) task.lastError = lastError;
      if (status is DownloadStatusCompleted && !wasAlreadyCompleted) {
        task.completedAt = DateTime.now();
      }
    });
  }

  @override
  Future<void> incrementRetryCount(int id) async {
    await _datasource.modify(id, (task) => task.retryCount++);
  }

  @override
  Future<void> resetRetryCount(int id) async {
    await _datasource.modify(id, (task) => task.retryCount = 0);
  }

  @override
  Future<void> delete(int id) => _datasource.delete(id).then((_) {});

  @override
  Future<int> getActiveCount() => _datasource.getActiveCount();

  @override
  Future<int> getTotalStorageUsed() => _datasource.getTotalStorageUsed();
}
