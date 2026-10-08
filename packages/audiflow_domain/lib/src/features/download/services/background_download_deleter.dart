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
    final deleted = await _withIdleTask(task, (current) async {
      await _deleteFiles(current);
      await _downloadRepository.delete(current.id);
      return true;
    });
    if (deleted) await _onDeleted?.call(task.episodeId);
  }

  /// Removes [task]'s record and files if it is still an auto download.
  /// Returns whether it did. Skips the same busy tasks as [call].
  ///
  /// The record goes first, checked and deleted atomically, so a keep
  /// request that lands after the caller's check still keeps the file.
  Future<bool> deleteAuto(DownloadTask task) async {
    final deleted = await _withIdleTask(task, (current) async {
      final removed = await _downloadRepository.deleteIfAuto(current.id);
      if (removed == null) return false;
      await _deleteFiles(removed);
      return true;
    });
    if (deleted) await _onDeleted?.call(task.episodeId);
    return deleted;
  }

  /// Runs [action] on the task's current record while holding the worker
  /// lock, unless the lock is busy, the record is gone, or it is
  /// downloading. Returns what [action] returned, or false if skipped.
  Future<bool> _withIdleTask(
    DownloadTask task,
    Future<bool> Function(DownloadTask current) action,
  ) async {
    if (!await _lock.tryAcquire()) return false;
    try {
      // [task] may have been read before the lock was taken; a worker
      // could have started it since.
      final current = await _downloadRepository.getById(task.id);
      if (current == null) return false;
      if (current.downloadStatus is DownloadStatusDownloading) return false;
      return await action(current);
    } finally {
      await _lock.release();
    }
  }

  Future<void> _deleteFiles(DownloadTask task) => deleteEpisodeDownloadFiles(
    downloadsDir: _downloadsDir,
    episodeId: task.episodeId,
    storedPath: task.localPath,
  );
}
