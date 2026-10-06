import 'package:audiflow_core/audiflow_core.dart';
import 'package:logger/logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../common/providers/logger_provider.dart';
import '../../player/repositories/playback_history_repository.dart';
import '../../player/repositories/playback_history_repository_impl.dart';
import '../models/download_origin.dart';
import '../models/download_status.dart';
import '../models/download_task.dart';
import '../repositories/download_repository.dart';
import '../repositories/download_repository_impl.dart';
import 'download_service.dart';

part 'download_retention_service.g.dart';

@Riverpod(keepAlive: true)
DownloadRetentionService downloadRetentionService(Ref ref) {
  final downloadService = ref.watch(downloadServiceProvider);
  return DownloadRetentionService(
    downloadRepository: ref.watch(downloadRepositoryProvider),
    playbackHistoryRepository: ref.watch(playbackHistoryRepositoryProvider),
    isAutoDeletePlayedEnabled: () => ref.read(downloadAutoDeletePlayedProvider),
    deleteDownload: downloadService.delete,
    logger: ref.watch(namedLoggerProvider('DownloadRetention')),
  );
}

/// Removes auto-downloaded episodes the listener no longer needs.
///
/// Only [DownloadOrigin.auto] downloads are ever removed; downloads the
/// listener requested are left alone.
class DownloadRetentionService {
  DownloadRetentionService({
    required this._downloadRepository,
    required this._playbackHistoryRepository,
    required this._isAutoDeletePlayedEnabled,
    required this._deleteDownload,
    this._logger,
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now;

  final DownloadRepository _downloadRepository;
  final PlaybackHistoryRepository _playbackHistoryRepository;
  final bool Function() _isAutoDeletePlayedEnabled;
  final Future<void> Function(int taskId) _deleteDownload;
  final Logger? _logger;
  final DateTime Function() _clock;

  /// Deletes completed auto downloads whose episode was finished at least
  /// [AppConstants.playedDownloadGracePeriod] ago. Returns the number
  /// deleted.
  ///
  /// The grace period is checked against the episode's current completion
  /// time, so marking an episode unplayed within the window keeps its file.
  Future<int> sweepPlayed() async {
    if (!_isAutoDeletePlayedEnabled()) return 0;

    final completed = await _downloadRepository.getByStatus(
      const DownloadStatus.completed(),
    );
    var deleted = 0;
    for (final task in completed) {
      if (task.downloadOrigin != DownloadOrigin.auto) continue;
      if (!await _isPastGracePeriod(task.episodeId)) continue;
      if (await _tryDeleteAuto(task)) deleted++;
    }
    if (0 < deleted) _logger?.i('Deleted $deleted played auto downloads');
    return deleted;
  }

  Future<bool> _isPastGracePeriod(int episodeId) async {
    final history = await _playbackHistoryRepository.getByEpisodeId(episodeId);
    final completedAt = history?.completedAt;
    if (completedAt == null) return false;
    final deadline = completedAt.add(AppConstants.playedDownloadGracePeriod);
    return !_clock().isBefore(deadline);
  }

  /// One undeletable file must not keep the rest of the sweep from running.
  ///
  /// The row is re-read first: a manual download request may have promoted
  /// the task since it was listed, and the listener's choice wins.
  Future<bool> _tryDeleteAuto(DownloadTask task) async {
    try {
      final current = await _downloadRepository.getById(task.id);
      if (current == null || current.downloadOrigin != DownloadOrigin.auto) {
        return false;
      }
      await _deleteDownload(task.id);
      return true;
    } on Exception catch (e, stack) {
      _logger?.w(
        'Failed to delete played download ${task.id}',
        error: e,
        stackTrace: stack,
      );
      return false;
    }
  }
}
