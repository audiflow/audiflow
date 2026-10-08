import '../models/download_status.dart';
import '../models/download_task.dart';
import '../repositories/download_repository.dart';
import 'episode_download_files.dart';

/// Deletes a download from the background isolate, which has no download
/// queue to cancel through.
class BackgroundDownloadDeleter {
  BackgroundDownloadDeleter({
    required this._downloadRepository,
    required this._downloadsDir,
    this._onDeleted,
  });

  final DownloadRepository _downloadRepository;
  final String _downloadsDir;

  /// Follow-up work once the record is gone, such as station reconciliation.
  final Future<void> Function(int episodeId)? _onDeleted;

  /// Removes [task]'s files, including a partial one, and its record.
  ///
  /// A task another isolate is actively downloading is left alone: there
  /// is no way to stop that writer from here, so deleting the record would
  /// orphan the file it finishes. The next foreground trim removes it.
  Future<void> call(DownloadTask task) async {
    if (task.downloadStatus is DownloadStatusDownloading) return;

    await deleteEpisodeDownloadFiles(
      downloadsDir: _downloadsDir,
      episodeId: task.episodeId,
      storedPath: task.localPath,
    );
    await _downloadRepository.delete(task.id);
    await _onDeleted?.call(task.episodeId);
  }
}
