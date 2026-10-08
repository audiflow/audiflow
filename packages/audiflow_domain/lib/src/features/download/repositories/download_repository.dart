import '../models/download_origin.dart';
import '../models/download_status.dart';
import '../models/download_task.dart';

/// Repository interface for download task operations.
///
/// Abstracts the data layer for managing episode downloads.
abstract class DownloadRepository {
  /// Creates a new download task for an episode.
  ///
  /// Returns the created task, or null if episode already has an active
  /// download. A [DownloadOrigin.manual] request for an episode whose
  /// existing download is [DownloadOrigin.auto] promotes it to manual so
  /// retention rules stop treating it as disposable.
  Future<DownloadTask?> createDownload({
    required int episodeId,
    required String audioUrl,
    required bool wifiOnly,
    DownloadOrigin origin = DownloadOrigin.manual,
  });

  /// Promotes an [DownloadOrigin.auto] task to [DownloadOrigin.manual] so
  /// retention rules never remove it.
  ///
  /// Returns true only if the task still existed and was auto when the
  /// change was made; false if it is unknown, was deleted, or is already
  /// manual.
  Future<bool> markManual(int id);

  /// Deletes the task's record only if it is still [DownloadOrigin.auto],
  /// checking and deleting atomically so a concurrent [markManual] wins.
  ///
  /// Returns the deleted task, whose file the caller then removes, or null
  /// if the task is gone or was kept.
  Future<DownloadTask?> deleteIfAuto(int id);

  /// Returns a download task by ID.
  Future<DownloadTask?> getById(int id);

  /// Returns a download task by episode ID.
  Future<DownloadTask?> getByEpisodeId(int episodeId);

  /// Watches a download task by episode ID.
  Stream<DownloadTask?> watchByEpisodeId(int episodeId);

  /// Returns all download tasks.
  Future<List<DownloadTask>> getAll();

  /// Returns the download tasks of the given episodes.
  Future<List<DownloadTask>> getByEpisodeIds(Iterable<int> episodeIds);

  /// Watches all download tasks.
  Stream<List<DownloadTask>> watchAll();

  /// Returns download tasks by status.
  Future<List<DownloadTask>> getByStatus(DownloadStatus status);

  /// Watches download tasks by status.
  Stream<List<DownloadTask>> watchByStatus(DownloadStatus status);

  /// Returns a completed download for an episode (for playback).
  Future<DownloadTask?> getCompletedForEpisode(int episodeId);

  /// Returns the next pending download.
  ///
  /// Tasks whose ids are in [excludeIds] are skipped, so a task waiting out
  /// a retry backoff does not hold up the tasks queued behind it.
  Future<DownloadTask?> getNextPending({
    required bool isOnWifi,
    Set<int> excludeIds = const {},
  });

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

  /// Resets retry count to zero, giving the task a fresh retry budget.
  Future<void> resetRetryCount(int id);

  /// Deletes a download task and optionally its file.
  Future<void> delete(int id);

  /// Returns count of active downloads.
  Future<int> getActiveCount();

  /// Returns total storage used by completed downloads in bytes.
  Future<int> getTotalStorageUsed();
}
