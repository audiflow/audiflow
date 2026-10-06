import 'dart:io';

import 'package:path/path.dart' as p;

import '../models/download_status.dart';
import '../models/download_task.dart';
import '../repositories/download_repository.dart';

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

  /// Removes [task]'s file and record.
  ///
  /// A task another isolate is actively downloading is left alone: there
  /// is no way to stop that writer from here, so deleting the record would
  /// orphan the file it finishes. The next foreground trim removes it.
  Future<void> call(DownloadTask task) async {
    if (task.downloadStatus is DownloadStatusDownloading) return;

    final path = _currentPath(task.localPath);
    if (path != null) {
      final file = File(path);
      if (await file.exists()) await file.delete();
    }
    await _downloadRepository.delete(task.id);
    await _onDeleted?.call(task.episodeId);
  }

  /// The stored absolute path goes stale when iOS rotates the app container,
  /// so resolve the file name against the current downloads directory.
  String? _currentPath(String? storedPath) {
    if (storedPath == null) return null;
    return p.join(_downloadsDir, p.basename(storedPath));
  }
}
