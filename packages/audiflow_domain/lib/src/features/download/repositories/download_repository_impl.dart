import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../common/providers/database_provider.dart';
import '../datasources/local/download_local_datasource.dart';
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

    final task = DownloadTask()
      ..episodeId = episodeId
      ..audioUrl = audioUrl
      ..wifiOnly = wifiOnly
      ..createdAt = DateTime.now();

    final id = await _datasource.create(task);
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
  }) async {
    final task = await _datasource.getById(id);
    if (task == null) return;

    task.downloadedBytes = downloadedBytes;
    if (totalBytes != null) {
      task.totalBytes = totalBytes;
    }
    await _datasource.updateById(id, task);
  }

  @override
  Future<void> updateStatus({
    required int id,
    required DownloadStatus status,
    String? localPath,
    String? lastError,
  }) async {
    final task = await _datasource.getById(id);
    if (task == null) return;

    // Only set completedAt when transitioning to completed, not when
    // the task is already completed (e.g. path migration updates).
    final wasAlreadyCompleted =
        DownloadStatus.fromDbValue(task.status) is DownloadStatusCompleted;

    task.status = status.toDbValue();
    if (localPath != null) {
      task.localPath = localPath;
    }
    if (lastError != null) {
      task.lastError = lastError;
    }
    if (status is DownloadStatusCompleted && !wasAlreadyCompleted) {
      task.completedAt = DateTime.now();
    }
    await _datasource.updateById(id, task);
  }

  @override
  Future<void> incrementRetryCount(int id) async {
    final task = await _datasource.getById(id);
    if (task == null) return;

    task.retryCount = task.retryCount + 1;
    await _datasource.updateById(id, task);
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
