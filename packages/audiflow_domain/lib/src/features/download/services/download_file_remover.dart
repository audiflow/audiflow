import 'package:logger/logger.dart';

import '../models/download_file_removal.dart';
import '../repositories/download_repository.dart';

/// Removes the files [DownloadRepository.deleteIfAuto] left pending, and
/// retries the removals that failed or were cut short.
class DownloadFileRemover {
  DownloadFileRemover({
    required this._repository,
    required this._deleteEpisodeFiles,
    this._logger,
  });

  final DownloadRepository _repository;

  /// Deletes every `<episodeId>_*` download file, plus [storedPath]
  /// resolved against the current downloads directory.
  final Future<void> Function(int episodeId, String? storedPath)
  _deleteEpisodeFiles;
  final Logger? _logger;

  /// Removes [removal]'s files and drops its record. Returns false, keeping
  /// the record for [retryPending], if the files could not be removed.
  Future<bool> remove(DownloadFileRemoval removal) async {
    try {
      // A download requested since owns the episode's files now, and the
      // sweep would take its file too, so the repository skips it then.
      // Removing that download later sweeps the same prefix, so the old
      // files go with it.
      await _repository.removeEpisodeFiles(
        episodeId: removal.episodeId,
        fileRemovalId: removal.id,
        removeFiles: () =>
            _deleteEpisodeFiles(removal.episodeId, removal.storedPath),
      );
      return true;
    } on Exception catch (e, stack) {
      _logger?.w(
        'Failed to remove files of episode ${removal.episodeId}; '
        'will retry',
        error: e,
        stackTrace: stack,
      );
      return false;
    }
  }

  /// Retries every pending removal. Returns the number completed.
  Future<int> retryPending() async {
    var completed = 0;
    for (final removal in await _repository.getPendingFileRemovals()) {
      if (await remove(removal)) completed++;
    }
    if (0 < completed) _logger?.i('Completed $completed file removals');
    return completed;
  }
}
