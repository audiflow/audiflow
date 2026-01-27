import 'dart:async';

import 'package:logger/logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../common/database/app_database.dart';
import '../../../common/providers/logger_provider.dart';
import '../../feed/repositories/episode_repository.dart';
import '../../feed/repositories/episode_repository_impl.dart';
import '../models/download_status.dart';
import '../repositories/download_repository.dart';
import '../repositories/download_repository_impl.dart';
import 'download_file_service.dart';
import 'download_queue_service.dart';

part 'download_service.g.dart';

/// Provider for WiFi-only download setting.
///
/// Override this with SharedPreferences in the app.
@riverpod
bool downloadWifiOnly(Ref ref) => true;

/// Provider for auto-delete played setting.
///
/// Override this with SharedPreferences in the app.
@riverpod
bool downloadAutoDeletePlayed(Ref ref) => false;

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

  final service = DownloadService(
    repository: repository,
    queueService: queueService,
    fileService: fileService,
    episodeRepository: episodeRepo,
    logger: logger,
    getWifiOnly: () => ref.read(downloadWifiOnlyProvider),
    getAutoDeletePlayed: () => ref.read(downloadAutoDeletePlayedProvider),
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
  }) : _repository = repository,
       _queueService = queueService,
       _fileService = fileService,
       _episodeRepo = episodeRepository,
       _logger = logger,
       _getWifiOnly = getWifiOnly,
       _getAutoDeletePlayed = getAutoDeletePlayed;

  final DownloadRepository _repository;
  final DownloadQueueService _queueService;
  final DownloadFileService _fileService;
  final EpisodeRepository _episodeRepo;
  final Logger _logger;
  final bool Function() _getWifiOnly;
  final bool Function() _getAutoDeletePlayed;

  /// Downloads a single episode.
  ///
  /// [wifiOnly] defaults to user's global setting if not specified.
  /// Returns the created download task, or null if already downloading.
  Future<DownloadTask?> downloadEpisode(int episodeId, {bool? wifiOnly}) async {
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
      _queueService.startQueue();
    } else {
      _logger.i('Episode already has active download: $episodeId');
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
      final task = await downloadEpisode(episode.id, wifiOnly: wifiOnly);
      if (task != null) queued++;
    }

    _logger.i('Queued $queued downloads for season $seasonNumber');
    return queued;
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
  }

  /// Returns the local file path for an episode if downloaded.
  Future<String?> getLocalPath(int episodeId) async {
    final task = await _repository.getCompletedForEpisode(episodeId);
    if (task?.localPath == null) return null;

    // Verify file exists
    if (!await _fileService.fileExists(task!.localPath!)) {
      _logger.w('Download file missing: ${task.localPath}');
      await _repository.updateStatus(
        id: task.id,
        status: const DownloadStatus.failed(),
        lastError: 'File not found',
      );
      return null;
    }

    return task.localPath;
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

    for (final task in completed) {
      if (task.localPath == null ||
          !await _fileService.fileExists(task.localPath!)) {
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
      _queueService.startQueue();
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
