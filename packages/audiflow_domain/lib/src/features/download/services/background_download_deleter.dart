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

  /// Removes [task]'s record and file if it is still an auto download.
  /// Returns whether it did.
  ///
  /// A task another isolate is actively downloading is left alone: there
  /// is no way to stop that writer from here, so deleting the record would
  /// orphan the file it finishes. The next foreground trim removes it.
  ///
  /// The record goes first, checked and deleted atomically, so a keep
  /// request that lands after the caller's check still keeps the file.
  Future<bool> call(DownloadTask task) async {
    if (task.downloadStatus is DownloadStatusDownloading) return false;

    final deleted = await _downloadRepository.deleteIfAuto(task.id);
    if (deleted == null) return false;
    final path = _currentPath(deleted.localPath);
    if (path != null) {
      final file = File(path);
      if (await file.exists()) await file.delete();
    }
    await _onDeleted?.call(deleted.episodeId);
    return true;
  }

  /// The stored absolute path goes stale when iOS rotates the app container,
  /// so resolve the file name against the current downloads directory.
  String? _currentPath(String? storedPath) {
    if (storedPath == null) return null;
    return p.join(_downloadsDir, p.basename(storedPath));
  }
}
