import '../models/download_status.dart';
import '../models/download_task.dart';
import '../repositories/download_repository.dart';
import 'background_download_worker_lock.dart';
import 'episode_download_files.dart';

/// Deletes a download from the background isolate, which has no download
/// queue to cancel through.
class BackgroundDownloadDeleter {
  BackgroundDownloadDeleter({
    required this._downloadRepository,
    required this._downloadsDir,
    required this._lock,
    this._onDeleted,
  });

  final DownloadRepository _downloadRepository;
  final String _downloadsDir;

  /// The lock background download workers hold while transferring.
  final BackgroundDownloadWorkerLock _lock;

  /// Follow-up work once the record is gone, such as station reconciliation.
  final Future<void> Function(int episodeId)? _onDeleted;

  /// Removes [task]'s files, including a partial one, and its record.
  ///
  /// Leaves the task alone while a background download worker holds the
  /// lock, or while the task is downloading: there is no way to stop that
  /// writer from here, so deleting the record would orphan the file it
  /// finishes. Callers see the record still there and retry later.
  Future<void> call(DownloadTask task) async {
    if (!await _lock.tryAcquire()) return;
    try {
      // [task] may have been read before the lock was taken; a worker
      // could have started it since.
      final current = await _downloadRepository.getById(task.id);
      if (current == null) return;
      if (current.downloadStatus is DownloadStatusDownloading) return;
      await deleteEpisodeDownloadFiles(
        downloadsDir: _downloadsDir,
        episodeId: current.episodeId,
        storedPath: current.localPath,
      );
      await _downloadRepository.delete(current.id);
    } finally {
      await _lock.release();
    }
    await _onDeleted?.call(task.episodeId);
  }
}
