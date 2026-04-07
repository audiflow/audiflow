import 'dart:async';
import 'dart:io';

import 'package:audiflow_core/audiflow_core.dart';
import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import 'package:path/path.dart' as p;

import '../../feed/repositories/episode_repository.dart';
import '../models/download_status.dart';
import '../models/download_task.dart';
import '../repositories/download_repository.dart';

/// Maximum retry attempts per download (matches DownloadQueueService).
const _maxRetryAttempts = 5;

/// Processes pending download tasks in a background isolate.
///
/// Unlike [DownloadQueueService] which runs in the foreground Riverpod
/// container, this service is designed for background execution via
/// Workmanager's BGProcessingTask. All dependencies are constructor-injected;
/// no Riverpod access required.
///
/// Downloads are processed sequentially within the [timeBudget]. Any
/// remaining tasks are left pending for the next background cycle or
/// foreground pickup.
class BackgroundDownloadService {
  BackgroundDownloadService({
    required DownloadRepository downloadRepo,
    required EpisodeRepository episodeRepo,
    required Dio dio,
    required String downloadsDir,
    Logger? logger,
    Duration timeBudget = const Duration(minutes: 5),
    bool isOnWifi = false,
  }) : _downloadRepo = downloadRepo,
       _episodeRepo = episodeRepo,
       _dio = dio,
       _downloadsDir = downloadsDir,
       _logger = logger,
       _timeBudget = timeBudget,
       _isOnWifi = isOnWifi;

  final DownloadRepository _downloadRepo;
  final EpisodeRepository _episodeRepo;
  final Dio _dio;
  final String _downloadsDir;
  final Logger? _logger;
  final Duration _timeBudget;
  final bool _isOnWifi;

  /// Processes all pending downloads within the time budget.
  ///
  /// Returns the number of successfully downloaded files.
  Future<int> execute() async {
    final stopwatch = Stopwatch()..start();
    var completedCount = 0;
    final errors = <(String, Object, StackTrace)>[];

    while (true) {
      if (_timeBudget <= stopwatch.elapsed) {
        _logger?.w(
          'BackgroundDownloadService: time budget exhausted after '
          '${stopwatch.elapsed.inSeconds}s',
        );
        break;
      }

      final task = await _downloadRepo.getNextPending(isOnWifi: _isOnWifi);
      if (task == null) break;

      // Re-check budget after the potentially slow getNextPending() call.
      // A negative Duration would cause ArgumentError in Timer().
      final remaining = _timeBudget - stopwatch.elapsed;
      if (remaining <= Duration.zero) {
        _logger?.w(
          'BackgroundDownloadService: time budget exhausted after '
          '${stopwatch.elapsed.inSeconds}s',
        );
        break;
      }

      try {
        final didComplete = await _processDownload(
          task,
          remainingBudget: remaining,
        );
        if (didComplete) completedCount++;
      } on DioException catch (e, stack) {
        if (e.type == DioExceptionType.cancel) {
          // Time budget exhausted mid-download. The task was already reset
          // to pending inside _processDownload, so just break the loop
          // without counting it as an error.
          _logger?.i(
            'BackgroundDownloadService: stopping — time budget exhausted '
            'during episodeId=${task.episodeId}',
          );
          break;
        }
        _logger?.e(
          'BackgroundDownloadService: download failed for '
          'episodeId=${task.episodeId}',
          error: e,
          stackTrace: stack,
        );
        errors.add(('episodeId=${task.episodeId}', e, stack));
        break;
      } catch (e, stack) {
        _logger?.e(
          'BackgroundDownloadService: download failed for '
          'episodeId=${task.episodeId}',
          error: e,
          stackTrace: stack,
        );
        errors.add(('episodeId=${task.episodeId}', e, stack));
        // Stop after first failure to avoid immediate retry of the same
        // pending task in a tight loop. The task stays pending for the next
        // scheduled background run or foreground pickup.
        break;
      }
    }

    _logger?.i(
      'BackgroundDownloadService: finished — '
      '$completedCount downloaded, ${errors.length} failed',
    );

    return completedCount;
  }

  /// Returns `true` when the download completes successfully, `false` when
  /// the task was reset to pending (e.g. server ignored Range header).
  Future<bool> _processDownload(
    DownloadTask task, {
    required Duration remainingBudget,
  }) async {
    _logger?.i(
      'BackgroundDownloadService: downloading episodeId=${task.episodeId}',
    );

    await _downloadRepo.updateStatus(
      id: task.id,
      status: const DownloadStatus.downloading(),
    );

    // Cancel the download if it exceeds the remaining time budget so
    // a single long-running download does not keep the BGProcessingTask
    // alive past the OS-imposed limit.
    final cancelToken = CancelToken();
    final budgetTimer = Timer(remainingBudget, () {
      cancelToken.cancel('Time budget exhausted');
    });

    try {
      final episode = await _episodeRepo.getById(task.episodeId);
      if (episode == null) {
        throw DownloadException(DownloadErrorType.unknown, 'Episode not found');
      }

      final localPath = _buildLocalPath(
        episodeId: task.episodeId,
        episodeTitle: episode.title,
        url: task.audioUrl,
      );

      final file = File(localPath);
      final dir = file.parent;
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }

      // Validate partial file before attempting resume. If the file is
      // missing or shorter than expected, reset to a fresh download.
      var resumeOffset = task.downloadedBytes;
      if (0 < resumeOffset) {
        final existingFile = File(localPath);
        if (!await existingFile.exists()) {
          resumeOffset = 0;
        } else {
          final fileLength = await existingFile.length();
          if (fileLength < resumeOffset) {
            resumeOffset = 0;
          }
        }
      }

      final headers = <String, dynamic>{};
      if (0 < resumeOffset) {
        headers['Range'] = 'bytes=$resumeOffset-';
      }

      var lastUpdateBytes = resumeOffset;
      const minBytesDelta = 256 * 1024; // 256 KB

      final response = await _dio.download(
        task.audioUrl,
        localPath,
        deleteOnError: false,
        cancelToken: cancelToken,
        // Append when resuming so the partial file is extended rather than
        // overwritten, which would produce a corrupted tail-only file.
        fileAccessMode: 0 < resumeOffset
            ? FileAccessMode.append
            : FileAccessMode.write,
        options: Options(headers: headers, responseType: ResponseType.stream),
        onReceiveProgress: (received, total) {
          final downloadedBytes = received + resumeOffset;
          final bytesDelta = downloadedBytes - lastUpdateBytes;
          if (minBytesDelta <= bytesDelta) {
            lastUpdateBytes = downloadedBytes;
            final totalBytes = total == -1 ? null : total + resumeOffset;
            unawaited(
              _downloadRepo
                  .updateProgress(
                    id: task.id,
                    downloadedBytes: downloadedBytes,
                    totalBytes: totalBytes,
                  )
                  .catchError((_) {
                    // Best-effort progress tracking; never abort the download
                    // because a progress write failed.
                  }),
            );
          }
        },
      );

      if (response.statusCode != 200 && response.statusCode != 206) {
        throw DownloadException(
          DownloadErrorType.serverError,
          'Server returned status ${response.statusCode}',
        );
      }

      // If we requested a Range but the server ignored it and returned the
      // full file (200 instead of 206), the file on disk is corrupted
      // (partial bytes + full file). Delete it, reset progress, and let
      // the next cycle retry from scratch.
      if (0 < resumeOffset && response.statusCode == 200) {
        _logger?.w(
          'BackgroundDownloadService: server ignored Range header for '
          'episodeId=${task.episodeId}, discarding corrupted file',
        );
        try {
          await File(localPath).delete();
        } on FileSystemException {
          // Best-effort cleanup; file may already be gone.
        }
        await _downloadRepo.updateProgress(
          id: task.id,
          downloadedBytes: 0,
          totalBytes: null,
        );
        await _downloadRepo.updateStatus(
          id: task.id,
          status: const DownloadStatus.pending(),
        );
        return false;
      }

      // Final progress write to ensure downloadedBytes is up to date even
      // if the file was smaller than minBytesDelta or the download completed
      // before the throttle triggered. Best-effort -- failure does not block
      // completion.
      final fileSize = await File(localPath).length();
      await _downloadRepo
          .updateProgress(
            id: task.id,
            downloadedBytes: fileSize,
            totalBytes: fileSize,
          )
          .catchError((_) {});

      await _downloadRepo.updateStatus(
        id: task.id,
        status: const DownloadStatus.completed(),
        localPath: localPath,
      );

      _logger?.i(
        'BackgroundDownloadService: completed episodeId=${task.episodeId}',
      );

      return true;
    } on DioException catch (e) {
      if (e.type == DioExceptionType.cancel) {
        // Download cancelled by the time budget timer. This is not a
        // download failure, so reset the task to pending without consuming
        // a retry attempt.
        await _downloadRepo.updateStatus(
          id: task.id,
          status: const DownloadStatus.pending(),
        );
        _logger?.i(
          'BackgroundDownloadService: paused episodeId=${task.episodeId} '
          'because time budget was exhausted',
        );
        rethrow;
      } else if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout) {
        await _handleError(
          task,
          DownloadException(
            DownloadErrorType.networkUnavailable,
            'Network unavailable: ${e.message}',
          ),
        );
      } else {
        await _handleError(
          task,
          DownloadException(
            DownloadErrorType.serverError,
            'Download failed: ${e.message}',
          ),
        );
      }
      rethrow;
    } on FileSystemException catch (e) {
      final error = e.osError?.errorCode == 28
          ? DownloadException(
              DownloadErrorType.insufficientStorage,
              'Insufficient storage space',
            )
          : DownloadException(
              DownloadErrorType.fileWriteError,
              'File write error: ${e.message}',
            );
      await _handleError(task, error);
      throw error;
    } on DownloadException catch (e) {
      await _handleError(task, e);
      rethrow;
    } catch (e, stackTrace) {
      // Catch-all for unexpected errors (FormatException, Isar errors, etc.)
      // to prevent tasks from being stuck in 'downloading' state.
      final error = DownloadException(
        DownloadErrorType.unknown,
        'Unexpected download error: $e',
      );
      await _handleError(task, error);
      Error.throwWithStackTrace(error, stackTrace);
    } finally {
      budgetTimer.cancel();
    }
  }

  Future<void> _handleError(DownloadTask task, DownloadException error) async {
    if (task.retryCount < _maxRetryAttempts) {
      await _downloadRepo.incrementRetryCount(task.id);
      await _downloadRepo.updateStatus(
        id: task.id,
        status: const DownloadStatus.pending(),
        lastError: error.message,
      );
    } else {
      await _downloadRepo.updateStatus(
        id: task.id,
        status: const DownloadStatus.failed(),
        lastError: error.message,
      );
      _logger?.w(
        'BackgroundDownloadService: failed after $_maxRetryAttempts retries '
        'episodeId=${task.episodeId}',
      );
    }
  }

  String _buildLocalPath({
    required int episodeId,
    required String episodeTitle,
    required String url,
  }) {
    final sanitized = episodeTitle
        .replaceAll(RegExp(r'[<>:"/\\|?*]'), '')
        .replaceAll(RegExp(r'\s+'), '_');
    final maxLength = sanitized.length < 50 ? sanitized.length : 50;
    final name = sanitized.substring(0, maxLength);

    final uri = Uri.tryParse(url);
    final ext = uri != null ? p.extension(uri.path) : '';
    final extension = ext.isNotEmpty ? ext : '.mp3';

    return p.join(_downloadsDir, '${episodeId}_$name$extension');
  }
}
