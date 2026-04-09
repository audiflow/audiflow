import 'dart:async';

import 'package:audiflow_core/audiflow_core.dart';
import 'package:logger/logger.dart';
import 'package:path/path.dart' as p;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../common/providers/logger_provider.dart';
import '../models/download_task.dart';
import '../../feed/repositories/episode_repository.dart';
import '../../feed/repositories/episode_repository_impl.dart';
import '../models/download_status.dart';
import '../../settings/providers/settings_providers.dart';
import '../../station/services/station_reconciler_service.dart';
import '../repositories/download_repository.dart';
import '../repositories/download_repository_impl.dart';
import 'download_file_service.dart';
import 'download_queue_service.dart';

part 'download_service.g.dart';

/// Provider for WiFi-only download setting.
///
/// Reads from user settings via [AppSettingsRepository].
@riverpod
bool downloadWifiOnly(Ref ref) {
  final repo = ref.watch(appSettingsRepositoryProvider);
  return repo.getWifiOnlyDownload();
}

/// Provider for auto-delete played setting.
///
/// Reads from user settings via [AppSettingsRepository].
@riverpod
bool downloadAutoDeletePlayed(Ref ref) {
  final repo = ref.watch(appSettingsRepositoryProvider);
  return repo.getAutoDeletePlayed();
}

/// Provider for batch download limit setting.
@riverpod
int batchDownloadLimit(Ref ref) {
  final repo = ref.watch(appSettingsRepositoryProvider);
  return repo.getBatchDownloadLimit();
}

/// Main service for managing episode downloads.
///
/// Provides high-level API for downloading episodes, managing the queue,
/// and integrating with playback history for auto-delete.
@Riverpod(keepAlive: true)
DownloadService downloadService(Ref ref) {
  final repository = ref.watch(downloadRepositoryProvider);
  final queueService = ref.watch(downloadQueueServiceProvider);
  final fileService = ref.watch(downloadFileServiceProvider);
  final episodeRepo = ref.watch(episodeRepositoryProvider);
  final logger = ref.watch(namedLoggerProvider('Download'));
  final reconcilerService = ref.watch(stationReconcilerServiceProvider);

  final service = DownloadService(
    repository: repository,
    queueService: queueService,
    fileService: fileService,
    episodeRepository: episodeRepo,
    logger: logger,
    getWifiOnly: () => ref.read(downloadWifiOnlyProvider),
    getAutoDeletePlayed: () => ref.read(downloadAutoDeletePlayedProvider),
    getBatchDownloadLimit: () => ref.read(batchDownloadLimitProvider),
    reconcilerService: reconcilerService,
  );

  ref.onDispose(() => service.dispose());

  return service;
}

class DownloadService {
  DownloadService({
    required DownloadRepository repository,
    required DownloadQueueService queueService,
    required DownloadFileService fileService,
    required EpisodeRepository episodeRepository,
    required Logger logger,
    required bool Function() getWifiOnly,
    required bool Function() getAutoDeletePlayed,
    required int Function() getBatchDownloadLimit,
    StationReconcilerService? reconcilerService,
  }) : _repository = repository,
       _queueService = queueService,
       _fileService = fileService,
       _episodeRepo = episodeRepository,
       _logger = logger,
       _getWifiOnly = getWifiOnly,
       _getAutoDeletePlayed = getAutoDeletePlayed,
       _getBatchDownloadLimit = getBatchDownloadLimit,
       _reconcilerService = reconcilerService;

  final DownloadRepository _repository;
  final DownloadQueueService _queueService;
  final DownloadFileService _fileService;
  final EpisodeRepository _episodeRepo;
  final Logger _logger;
  final bool Function() _getWifiOnly;
  final bool Function() _getAutoDeletePlayed;
  final int Function() _getBatchDownloadLimit;
  final StationReconcilerService? _reconcilerService;

  /// Downloads a single episode.
  ///
  /// [wifiOnly] defaults to user's global setting if not specified.
  /// Returns the created download task, or null if already downloading.
  Future<DownloadTask?> downloadEpisode(int episodeId, {bool? wifiOnly}) async {
    final task = await _createDownloadTask(episodeId, wifiOnly: wifiOnly);
    if (task != null) {
      unawaited(_queueService.startQueue());
    }
    return task;
  }

  /// Downloads all episodes in a season.
  ///
  /// Returns the number of downloads queued.
  Future<int> downloadSeason(
    int podcastId,
    int seasonNumber, {
    bool? wifiOnly,
  }) async {
    final episodes = await _episodeRepo.getByPodcastId(podcastId);
    final seasonEpisodes = episodes
        .where((e) => e.seasonNumber == seasonNumber)
        .toList();

    var queued = 0;
    for (final episode in seasonEpisodes) {
      final task = await _createDownloadTask(episode.id, wifiOnly: wifiOnly);
      if (task != null) queued++;
    }

    if (0 < queued) unawaited(_queueService.startQueue());
    _logger.i('Queued $queued downloads for season $seasonNumber');
    return queued;
  }

  /// Downloads episodes by ID, capped at the user's batch limit.
  ///
  /// Episodes are processed in list order (reflecting display sort).
  /// Returns the number of downloads actually queued.
  Future<int> downloadEpisodes(List<int> episodeIds, {bool? wifiOnly}) async {
    if (episodeIds.isEmpty) return 0;

    final limit = _getBatchDownloadLimit().clamp(
      SettingsDefaults.batchDownloadLimitMin,
      SettingsDefaults.batchDownloadLimitMax,
    );

    var queued = 0;
    for (final id in episodeIds) {
      if (limit <= queued) break;
      final task = await _createDownloadTask(id, wifiOnly: wifiOnly);
      if (task != null) queued++;
    }

    if (0 < queued) unawaited(_queueService.startQueue());
    _logger.i(
      'Batch download: queued $queued of ${episodeIds.length} episodes',
    );
    return queued;
  }

  /// Creates a download task without starting the queue.
  Future<DownloadTask?> _createDownloadTask(
    int episodeId, {
    bool? wifiOnly,
  }) async {
    final episode = await _episodeRepo.getById(episodeId);
    if (episode == null) {
      _logger.w('Episode not found: $episodeId');
      return null;
    }

    final task = await _repository.createDownload(
      episodeId: episodeId,
      audioUrl: episode.audioUrl,
      wifiOnly: wifiOnly ?? _getWifiOnly(),
    );

    if (task != null) {
      _logger.i('Created download task for episode: $episodeId');
    } else {
      _logger.i('Episode already has an existing download task: $episodeId');
    }

    return task;
  }

  /// Cancels all active downloads for the given episode IDs.
  ///
  /// Two-pass approach to prevent the queue from picking up the next
  /// pending task after each cancellation:
  /// 1. Mark all active tasks as cancelled (queue's getNextPending
  ///    returns null).
  /// 2. Cancel any in-progress file downloads.
  ///
  /// Returns the number of downloads cancelled.
  Future<int> cancelEpisodeDownloads(List<int> episodeIds) async {
    // Pass 1: collect active tasks and mark all as cancelled.
    final activeTasks = <DownloadTask>[];
    for (final episodeId in episodeIds) {
      final task = await _repository.getByEpisodeId(episodeId);
      if (task == null) continue;
      if (!task.downloadStatus.isActive) continue;
      activeTasks.add(task);
      await _repository.updateStatus(
        id: task.id,
        status: const DownloadStatus.cancelled(),
      );
    }

    // Pass 2: cancel in-progress file downloads.
    for (final task in activeTasks) {
      _fileService.cancelDownload(task.id);
    }

    _logger.i('Batch cancel: cancelled ${activeTasks.length} downloads');
    return activeTasks.length;
  }

  /// Resumes all paused downloads for the given episode IDs.
  ///
  /// Returns the number of downloads resumed.
  Future<int> resumeEpisodeDownloads(List<int> episodeIds) async {
    var resumed = 0;
    for (final episodeId in episodeIds) {
      final task = await _repository.getByEpisodeId(episodeId);
      if (task == null) continue;
      if (task.downloadStatus is! DownloadStatusPaused) continue;
      await _queueService.resumeDownload(task.id);
      resumed++;
    }
    _logger.i('Batch resume: resumed $resumed downloads');
    return resumed;
  }

  /// Pauses an active download.
  Future<void> pause(int taskId) => _queueService.pauseDownload(taskId);

  /// Resumes a paused download.
  Future<void> resume(int taskId) => _queueService.resumeDownload(taskId);

  /// Cancels a download (removes from queue).
  Future<void> cancel(int taskId) => _queueService.cancelDownload(taskId);

  /// Retries a failed download.
  Future<void> retry(int taskId) => _queueService.retryDownload(taskId);

  /// Deletes a download and its file.
  Future<void> delete(int taskId) async {
    final task = await _repository.getById(taskId);
    if (task == null) return;

    // Cancel if active
    if (task.downloadStatus.isActive) {
      _queueService.cancelDownload(taskId);
    }

    // Delete file if exists
    if (task.localPath != null) {
      await _fileService.deleteFile(task.localPath!);
    }

    await _repository.delete(taskId);
    _logger.i('Deleted download: $taskId');

    // Best-effort station reconciliation.
    try {
      await _reconcilerService?.onEpisodeChanged(task.episodeId);
    } on Exception catch (e) {
      _logger.w(
        'Station reconciliation failed for episode ${task.episodeId}',
        error: e,
      );
    }
  }

  /// Deletes all completed downloads and their files.
  Future<void> deleteAllCompleted() async {
    final completed = await _repository.getByStatus(
      const DownloadStatus.completed(),
    );

    for (final task in completed) {
      if (task.localPath != null) {
        await _fileService.deleteFile(task.localPath!);
      }
    }

    final count = await _repository.deleteAllCompleted();
    _logger.i('Deleted $count completed downloads');

    // Best-effort station reconciliation.
    for (final task in completed) {
      try {
        await _reconcilerService?.onEpisodeChanged(task.episodeId);
      } on Exception catch (e) {
        _logger.w(
          'Station reconciliation failed for episode ${task.episodeId}',
          error: e,
        );
      }
    }
  }

  /// Returns the local file path for an episode if downloaded.
  ///
  /// On iOS the app container path can change between launches (the UUID
  /// segment is rotated). When the stored absolute path is stale, we
  /// reconstruct it from the current documents directory + the original
  /// filename and update the record so future lookups are fast.
  Future<String?> getLocalPath(int episodeId) async {
    final task = await _repository.getCompletedForEpisode(episodeId);
    if (task?.localPath == null) return null;

    final storedPath = task!.localPath!;

    // Fast path: file exists at the stored absolute path.
    if (await _fileService.fileExists(storedPath)) {
      return storedPath;
    }

    // Slow path: container UUID may have changed. Reconstruct path from
    // the current documents directory and the stored filename.
    final filename = p.basename(storedPath);
    final currentDir = await _fileService.getDownloadsDirectory();
    final reconstructed = p.join(currentDir, filename);

    if (await _fileService.fileExists(reconstructed)) {
      _logger.i(
        'Download path migrated for episode $episodeId: '
        '$storedPath -> $reconstructed',
      );
      await _repository.updateStatus(
        id: task.id,
        status: const DownloadStatus.completed(),
        localPath: reconstructed,
      );
      return reconstructed;
    }

    _logger.w('Download file missing: $storedPath (also tried $reconstructed)');
    await _repository.updateStatus(
      id: task.id,
      status: const DownloadStatus.failed(),
      lastError: 'File not found',
    );
    return null;
  }

  /// Validates all downloads on app startup.
  ///
  /// - Removes orphaned records (file missing)
  /// - Resumes interrupted downloads
  Future<void> validateDownloads() async {
    _logger.i('Validating downloads...');

    // Check completed downloads have valid files
    final completed = await _repository.getByStatus(
      const DownloadStatus.completed(),
    );

    final currentDir = await _fileService.getDownloadsDirectory();
    for (final task in completed) {
      if (task.localPath == null) {
        _logger.w('Orphaned download record (no path): ${task.id}');
        await _repository.delete(task.id);
        continue;
      }

      // Try stored path first, then reconstruct from current directory
      // in case the iOS container UUID changed.
      final storedPath = task.localPath!;
      if (await _fileService.fileExists(storedPath)) continue;

      final filename = p.basename(storedPath);
      final reconstructed = p.join(currentDir, filename);
      if (await _fileService.fileExists(reconstructed)) {
        _logger.i(
          'Startup migration: ${task.id} path updated to $reconstructed',
        );
        await _repository.updateStatus(
          id: task.id,
          status: const DownloadStatus.completed(),
          localPath: reconstructed,
        );
      } else {
        _logger.w('Orphaned download record: ${task.id}');
        await _repository.delete(task.id);
      }
    }

    // Resume any interrupted downloads
    final downloading = await _repository.getByStatus(
      const DownloadStatus.downloading(),
    );

    for (final task in downloading) {
      await _repository.updateStatus(
        id: task.id,
        status: const DownloadStatus.pending(),
      );
    }

    if (downloading.isNotEmpty) {
      unawaited(_queueService.startQueue());
    }

    _logger.i('Validation complete');
  }

  /// Handles auto-delete when episode is marked as played.
  Future<void> onEpisodeCompleted(int episodeId) async {
    if (!_getAutoDeletePlayed()) return;

    final task = await _repository.getByEpisodeId(episodeId);
    if (task == null) return;

    if (task.downloadStatus is DownloadStatusCompleted) {
      await delete(task.id);
      _logger.i('Auto-deleted played episode: $episodeId');
    }
  }

  /// Returns total storage used by downloads in bytes.
  Future<int> getTotalStorageUsed() => _repository.getTotalStorageUsed();

  /// Stream of the currently active download.
  Stream<DownloadTask?> get activeDownloadStream =>
      _queueService.activeDownloadStream;

  void dispose() {
    // Cleanup handled by queue service
  }
}
