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
        totalBytes: totalBytes != null
            ? Value(totalBytes)
            : const Value.absent(),
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
