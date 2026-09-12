import 'dart:async';

import 'package:audiflow_core/audiflow_core.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:logger/logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../common/providers/logger_provider.dart';
import '../../../common/services/suspendable_writer.dart';
import '../models/download_task.dart';
import '../../feed/repositories/episode_repository.dart';
import '../../feed/repositories/episode_repository_impl.dart';
import '../../monitoring/models/analytics_event.dart';
import '../../monitoring/providers/analytics_providers.dart';
import '../models/download_status.dart';
import '../../station/services/station_reconciler_service.dart';
import '../../subscription/repositories/subscription_repository_impl.dart';
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
  final reconcilerService = ref.watch(stationReconcilerServiceProvider);

  final service = DownloadQueueService(
    repository: repository,
    fileService: fileService,
    episodeRepository: episodeRepo,
    logger: logger,
    onDownloadCompleted: reconcilerService.onEpisodeChanged,
    onDownloadCompletedWithBytes: (episodeId, bytes) =>
        _emitDownloadCompleted(ref, episodeId, bytes),
  );

  ref.onDispose(() => service.dispose());

  return service;
}

/// Resolves analytics IDs/titles and emits [EpisodeDownloadCompleted]
/// using the queue provider's [Ref]. Lives at the provider seam so the
/// service stays decoupled from analytics wiring.
///
/// `podcastId` is the raw iTunes ID when available (non-OPML import),
/// else the feed URL. `episodeId` is the raw RSS guid.
Future<void> _emitDownloadCompleted(Ref ref, int episodeId, int bytes) async {
  final episodeRepo = ref.read(episodeRepositoryProvider);
  final episode = await episodeRepo.getById(episodeId);
  if (episode == null) return;
  final guid = episode.guid;
  if (guid.isEmpty) return;
  final subscriptionRepo = ref.read(subscriptionRepositoryProvider);
  final sub = await subscriptionRepo.getById(episode.podcastId);
  if (sub == null) return;
  final feedUrl = sub.feedUrl;
  if (feedUrl.isEmpty) return;
  final podcastId = sub.itunesId.startsWith('opml:') ? feedUrl : sub.itunesId;
  final analytics = ref.read(analyticsServiceProvider);
  unawaited(
    analytics.log(
      EpisodeDownloadCompleted(
        podcastId: podcastId,
        episodeId: guid,
        podcastTitle: sub.title,
        episodeTitle: episode.title,
        bytes: bytes,
      ),
    ),
  );
}

class DownloadQueueService implements SuspendableWriter {
  DownloadQueueService({
    required this._repository,
    required this._fileService,
    required EpisodeRepository episodeRepository,
    required this._logger,
    this._onDownloadCompleted,
    this._onDownloadCompletedWithBytes,
  }) : _episodeRepo = episodeRepository {
    _init();
  }

  final DownloadRepository _repository;
  final DownloadFileService _fileService;
  final EpisodeRepository _episodeRepo;
  final Future<void> Function(int episodeId)? _onDownloadCompleted;
  final Future<void> Function(int episodeId, int bytes)?
  _onDownloadCompletedWithBytes;
  final Logger _logger;

  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  DownloadTask? _activeDownload;
  bool _isOnWifi = false;
  Timer? _retryTimer;

  /// The running queue drain, so [suspend] can wait for it to settle.
  Future<void>? _processing;

  bool get _isProcessing => _processing != null;

  /// Progress writes are fired from the download callback without being
  /// awaited; [suspend] waits for them so none lands after a reset clears
  /// the task row.
  final _pendingProgressWrites = <Future<void>>{};

  /// Set by [suspend], cleared by [resume]. While set, the drain loop stops
  /// instead of picking up the next pending task and every start request
  /// leaves the queue idle, so it stays quiet while a reset clears storage.
  bool _isSuspended = false;

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

  /// Starts processing the download queue. A no-op while suspended.
  Future<void> startQueue() async {
    await _processQueue();
  }

  Future<void> _processQueue() async {
    if (_isProcessing) return;
    _processing = _drainQueue();
    await _processing;
  }

  Future<void> _drainQueue() async {
    try {
      // The flag is checked twice: once so a cancelled download does not
      // trigger another query, and again after the query so a suspend
      // that landed while it ran does not start a download it has no
      // token to cancel.
      while (!_isSuspended) {
        final nextTask = await _repository.getNextPending(isOnWifi: _isOnWifi);
        if (nextTask == null || _isSuspended) break;

        await _processDownload(nextTask);
      }
    } finally {
      _processing = null;
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

      // The file service only registers its cancel token once the download
      // starts, so a suspend that landed during the awaits above would
      // otherwise let this download run to completion unopposed.
      if (_isSuspended) throw DownloadException.cancelled();

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
            _trackProgressWrite(
              _repository.updateProgress(
                id: task.id,
                downloadedBytes: downloaded,
                totalBytes: total,
              ),
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
      await _onDownloadCompleted?.call(task.episodeId);
      // Read the persisted task to obtain the final byte count - the
      // throttled progress updates may not have flushed the last delta.
      final completedTask = await _repository.getById(task.id);
      final bytes = completedTask?.downloadedBytes ?? 0;
      await _onDownloadCompletedWithBytes?.call(task.episodeId, bytes);
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
    unawaited(_processQueue());
  }

  /// Cancels a download.
  Future<void> cancelDownload(int taskId) async {
    _fileService.cancelDownload(taskId);
    await _repository.updateStatus(
      id: taskId,
      status: const DownloadStatus.cancelled(),
    );
  }

  /// Cancels the active download, stops the queue loop, waits for the
  /// in-flight task and its progress writes to settle, and holds the queue
  /// idle until [resume].
  ///
  /// "Reset All Data" calls this before clearing storage: without the wait,
  /// the cancelled task's status write could land after `Isar.clear()` and
  /// the file service could recreate the downloads directory it just
  /// removed. Pending tasks are left in place; the caller clears them.
  @override
  Future<void> suspend() async {
    _isSuspended = true;
    _retryTimer?.cancel();
    final active = _activeDownload;
    if (active != null) _fileService.cancelDownload(active.id);
    try {
      await _processing;
    } catch (e, stack) {
      // The drain's own caller already receives this error; a failing
      // queue is no reason to refuse the reset that would clear it.
      _logger.w(
        'Queue drain failed while suspending',
        error: e,
        stackTrace: stack,
      );
    }
    await Future.wait(_pendingProgressWrites.toList());
  }

  @override
  void resume() {
    _isSuspended = false;
  }

  void _trackProgressWrite(Future<void> write) {
    // Best-effort tracking; a failed progress write must not surface as an
    // unhandled error from the download callback.
    final tracked = write.catchError((Object _) {});
    _pendingProgressWrites.add(tracked);
    tracked.whenComplete(() => _pendingProgressWrites.remove(tracked));
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

    unawaited(_processQueue());
  }

  void dispose() {
    _connectivitySubscription?.cancel();
    _retryTimer?.cancel();
    _activeDownloadController.close();
  }
}
