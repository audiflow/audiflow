import '../models/download_status.dart';
import '../models/download_task.dart';

/// Repository interface for download task operations.
///
/// Abstracts the data layer for managing episode downloads.
abstract class DownloadRepository {
  /// Creates a new download task for an episode.
  ///
  /// Returns the created task, or null if episode already has an active
  /// download.
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
