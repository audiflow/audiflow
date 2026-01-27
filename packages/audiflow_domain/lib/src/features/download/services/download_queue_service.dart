import 'dart:async';

import 'package:audiflow_core/audiflow_core.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
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

part 'download_queue_service.g.dart';

/// Maximum number of retry attempts per download.
const int maxRetryAttempts = 5;

/// Backoff delays in seconds for retries: 5s, 15s, 45s, 135s, 405s
const List<int> retryDelaysSeconds = [5, 15, 45, 135, 405];

/// Service for managing the download queue.
///
/// Handles sequential download processing, network state monitoring,
/// and smart retry with exponential backoff.
@Riverpod(keepAlive: true)
DownloadQueueService downloadQueueService(Ref ref) {
  final repository = ref.watch(downloadRepositoryProvider);
  final fileService = ref.watch(downloadFileServiceProvider);
  final episodeRepo = ref.watch(episodeRepositoryProvider);
  final logger = ref.watch(namedLoggerProvider('DownloadQueue'));

  final service = DownloadQueueService(
    repository: repository,
    fileService: fileService,
    episodeRepository: episodeRepo,
    logger: logger,
  );

  ref.onDispose(() => service.dispose());

  return service;
}

class DownloadQueueService {
  DownloadQueueService({
    required DownloadRepository repository,
    required DownloadFileService fileService,
    required EpisodeRepository episodeRepository,
    required Logger logger,
  }) : _repository = repository,
       _fileService = fileService,
       _episodeRepo = episodeRepository,
       _logger = logger {
    _init();
  }

  final DownloadRepository _repository;
  final DownloadFileService _fileService;
  final EpisodeRepository _episodeRepo;
  final Logger _logger;

  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  DownloadTask? _activeDownload;
  bool _isProcessing = false;
  bool _isOnWifi = false;
  Timer? _retryTimer;

  final _activeDownloadController = StreamController<DownloadTask?>.broadcast();

  /// Stream of the currently active download.
  Stream<DownloadTask?> get activeDownloadStream =>
      _activeDownloadController.stream;

  /// The currently active download, if any.
  DownloadTask? get activeDownload => _activeDownload;

  void _init() {
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen(
      _onConnectivityChanged,
    );

    // Check initial connectivity
    Connectivity().checkConnectivity().then(_onConnectivityChanged);
  }

  void _onConnectivityChanged(List<ConnectivityResult> results) {
    final wasOnWifi = _isOnWifi;
    _isOnWifi = results.contains(ConnectivityResult.wifi);

    final isConnected = results.any(
      (r) =>
          r == ConnectivityResult.wifi ||
          r == ConnectivityResult.mobile ||
          r == ConnectivityResult.ethernet,
    );

    _logger.i('Connectivity changed: wifi=$_isOnWifi, connected=$isConnected');

    if (isConnected && !_isProcessing) {
      // Network restored - try to process queue
      _processQueue();
    }

    // WiFi connected - retry WiFi-only downloads
    if (_isOnWifi && !wasOnWifi) {
      _processQueue();
    }
  }

  /// Starts processing the download queue.
  Future<void> startQueue() async {
    if (_isProcessing) return;
    await _processQueue();
  }

  Future<void> _processQueue() async {
    if (_isProcessing) return;
    _isProcessing = true;

    try {
      while (true) {
        final nextTask = await _repository.getNextPending(isOnWifi: _isOnWifi);
        if (nextTask == null) break;

        await _processDownload(nextTask);
      }
    } finally {
      _isProcessing = false;
      _activeDownload = null;
      _activeDownloadController.add(null);
    }
  }

  Future<void> _processDownload(DownloadTask task) async {
    _activeDownload = task;
    _activeDownloadController.add(task);

    _logger.i('Starting download: episodeId=${task.episodeId}');

    // Update status to downloading
    await _repository.updateStatus(
      id: task.id,
      status: const DownloadStatus.downloading(),
    );

    try {
      // Get episode details for filename
      final episode = await _episodeRepo.getById(task.episodeId);
      if (episode == null) {
        throw DownloadException(DownloadErrorType.unknown, 'Episode not found');
      }

      // Throttle progress updates to avoid overwhelming the database
      var lastUpdateTime = DateTime.now();
      var lastReportedBytes = 0;
      const minUpdateInterval = Duration(milliseconds: 250);
      const minBytesDelta = 100 * 1024; // 100 KB

      final localPath = await _fileService.downloadFile(
        taskId: task.id,
        url: task.audioUrl,
        episodeId: task.episodeId,
        episodeTitle: episode.title,
        resumeFromBytes: task.downloadedBytes,
        onProgress: (downloaded, total) {
          final now = DateTime.now();
          final bytesDelta = downloaded - lastReportedBytes;
          final timeDelta = now.difference(lastUpdateTime);

          // Update if enough time passed OR enough bytes downloaded
          if (minUpdateInterval <= timeDelta || minBytesDelta <= bytesDelta) {
            lastUpdateTime = now;
            lastReportedBytes = downloaded;
            _repository.updateProgress(
              id: task.id,
              downloadedBytes: downloaded,
              totalBytes: total,
            );
          }
        },
      );

      // Download completed successfully
      await _repository.updateStatus(
        id: task.id,
        status: const DownloadStatus.completed(),
        localPath: localPath,
      );

      _logger.i('Download completed: episodeId=${task.episodeId}');
    } on DownloadException catch (e) {
      await _handleDownloadError(task, e);
    } catch (e) {
      await _handleDownloadError(
        task,
        DownloadException(DownloadErrorType.unknown, e.toString()),
      );
    }
  }

  Future<void> _handleDownloadError(
    DownloadTask task,
    DownloadException error,
  ) async {
    _logger.e('Download error: ${error.message}', error: error);

    if (error.type == DownloadErrorType.cancelled) {
      await _repository.updateStatus(
        id: task.id,
        status: const DownloadStatus.cancelled(),
        lastError: error.message,
      );
      return;
    }

    // Check if we should retry
    if (task.retryCount < maxRetryAttempts) {
      await _repository.incrementRetryCount(task.id);
      await _repository.updateStatus(
        id: task.id,
        status: const DownloadStatus.pending(),
        lastError: error.message,
      );

      // Schedule retry with backoff
      final delayIndex = task.retryCount < retryDelaysSeconds.length
          ? task.retryCount
          : retryDelaysSeconds.length - 1;
      final delay = Duration(seconds: retryDelaysSeconds[delayIndex]);
      _logger.i('Scheduling retry in ${delay.inSeconds}s');

      _retryTimer?.cancel();
      _retryTimer = Timer(delay, () {
        if (!_isProcessing) _processQueue();
      });
    } else {
      // Max retries exceeded
      await _repository.updateStatus(
        id: task.id,
        status: const DownloadStatus.failed(),
        lastError: error.message,
      );
      _logger.w('Download failed after $maxRetryAttempts retries');
    }
  }

  /// Pauses an active download.
  Future<void> pauseDownload(int taskId) async {
    _fileService.cancelDownload(taskId);
    await _repository.updateStatus(
      id: taskId,
      status: const DownloadStatus.paused(),
    );
  }

  /// Resumes a paused download by moving it back to pending.
  Future<void> resumeDownload(int taskId) async {
    await _repository.updateStatus(
      id: taskId,
      status: const DownloadStatus.pending(),
    );
    if (!_isProcessing) _processQueue();
  }

  /// Cancels a download.
  Future<void> cancelDownload(int taskId) async {
    _fileService.cancelDownload(taskId);
    await _repository.updateStatus(
      id: taskId,
      status: const DownloadStatus.cancelled(),
    );
  }

  /// Retries a failed download.
  Future<void> retryDownload(int taskId) async {
    final task = await _repository.getById(taskId);
    if (task == null) return;

    // Reset retry count and set to pending
    await _repository.updateStatus(
      id: taskId,
      status: const DownloadStatus.pending(),
      lastError: null,
    );

    if (!_isProcessing) _processQueue();
  }

  void dispose() {
    _connectivitySubscription?.cancel();
    _retryTimer?.cancel();
    _activeDownloadController.close();
  }
}
