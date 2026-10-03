import 'dart:io';

import 'package:audiflow_core/audiflow_core.dart';
import 'package:dio/dio.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../common/providers/http_client_provider.dart';
import 'download_path.dart';

part 'download_file_service.g.dart';

/// Whether [error] is a 416 reply to a resume request, meaning the partial
/// file on disk cannot be extended and the download must start over.
bool isRangeNotSatisfiable(DioException error) =>
    error.response?.statusCode == 416;

/// Callback for download progress updates.
typedef DownloadProgressCallback =
    void Function(int downloadedBytes, int totalBytes);

/// Service for file download operations.
///
/// Handles actual HTTP downloads using Dio with progress callbacks,
/// file path management, and storage operations.
@Riverpod(keepAlive: true)
DownloadFileService downloadFileService(Ref ref) {
  final dio = ref.watch(dioProvider);
  return DownloadFileService(dio: dio);
}

class DownloadFileService {
  DownloadFileService({required this._dio});

  final Dio _dio;
  final Map<int, CancelToken> _cancelTokens = {};

  /// Downloads a file from URL to local storage.
  ///
  /// [taskId] - Download task ID for cancellation tracking
  /// [url] - Remote file URL
  /// [episodeId] - Episode ID for filename
  /// [episodeTitle] - Episode title for filename
  /// [onProgress] - Progress callback
  /// [resumeFromBytes] - Bytes already fetched (0 for fresh download); when
  ///   non-zero, the download resumes from the partial file on disk
  ///
  /// Returns local file path on success.
  /// Throws [DownloadException] on failure.
  Future<String> downloadFile({
    required int taskId,
    required String url,
    required int episodeId,
    required String episodeTitle,
    required DownloadProgressCallback onProgress,
    int resumeFromBytes = 0,
  }) async {
    final cancelToken = CancelToken();
    _cancelTokens[taskId] = cancelToken;
    String? localPath;

    try {
      localPath = await _getLocalPath(episodeId, episodeTitle, url);
      final file = File(localPath);

      // Ensure directory exists
      final dir = file.parent;
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }

      final resumeOffset = await _resumeOffset(file, resumeFromBytes);
      final headers = <String, dynamic>{};
      if (0 < resumeOffset) {
        headers['Range'] = 'bytes=$resumeOffset-';
      }

      final response = await _dio.download(
        url,
        localPath,
        cancelToken: cancelToken,
        deleteOnError: false,
        // Append when resuming so the partial file is extended rather than
        // replaced by the tail the server sends back.
        fileAccessMode: 0 < resumeOffset
            ? FileAccessMode.append
            : FileAccessMode.write,
        options: Options(headers: headers, responseType: ResponseType.stream),
        onReceiveProgress: (received, total) {
          final totalBytes = total == -1 ? 0 : total + resumeOffset;
          final downloadedBytes = received + resumeOffset;
          onProgress(downloadedBytes, totalBytes);
        },
      );

      if (response.statusCode != 200 && response.statusCode != 206) {
        throw DownloadException(
          DownloadErrorType.serverError,
          'Server returned status ${response.statusCode}',
        );
      }
      if (0 < resumeOffset && response.statusCode == 200) {
        // The server ignored Range and sent the whole file after the
        // partial bytes. Drop the corrupted file; the retry starts afresh.
        await deleteFile(localPath);
        throw DownloadException(
          DownloadErrorType.serverError,
          'Server ignored range request',
        );
      }

      return localPath;
    } on DioException catch (e) {
      if (e.type == DioExceptionType.cancel) {
        throw DownloadException.cancelled();
      }
      if (isRangeNotSatisfiable(e) && localPath != null) {
        // The partial file no longer lines up with the remote file (it may
        // already be complete, or the episode was replaced). Drop it so the
        // retry starts afresh instead of repeating the same request.
        await deleteFile(localPath);
        throw DownloadException(
          DownloadErrorType.serverError,
          'Range not satisfiable; restarting download',
        );
      }
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout) {
        throw DownloadException(
          DownloadErrorType.networkUnavailable,
          'Network unavailable: ${e.message}',
        );
      }
      throw DownloadException(
        DownloadErrorType.serverError,
        'Download failed: ${e.message}',
      );
    } on FileSystemException catch (e) {
      if (e.osError?.errorCode == 28) {
        // ENOSPC - No space left
        throw DownloadException(
          DownloadErrorType.insufficientStorage,
          'Insufficient storage space',
        );
      }
      throw DownloadException(
        DownloadErrorType.fileWriteError,
        'File write error: ${e.message}',
      );
    } finally {
      _cancelTokens.remove(taskId);
    }
  }

  /// Returns the byte offset to resume from: the partial file's length when
  /// resuming, since the stored count lags behind throttled progress writes
  /// and a mismatched Range would corrupt the file.
  Future<int> _resumeOffset(File file, int resumeFromBytes) async {
    if (resumeFromBytes <= 0 || !await file.exists()) return 0;
    return file.length();
  }

  /// Cancels an active download.
  void cancelDownload(int taskId) {
    _cancelTokens[taskId]?.cancel();
    _cancelTokens.remove(taskId);
  }

  /// Deletes a downloaded file.
  Future<void> deleteFile(String localPath) async {
    final file = File(localPath);
    if (await file.exists()) {
      await file.delete();
    }
  }

  /// Returns the size of a downloaded file in bytes.
  Future<int> getFileSize(String localPath) async {
    final file = File(localPath);
    if (await file.exists()) {
      return file.length();
    }
    return 0;
  }

  /// Checks if a file exists at the given path.
  Future<bool> fileExists(String localPath) async {
    return File(localPath).exists();
  }

  /// Returns the downloads directory path.
  Future<String> getDownloadsDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    return p.join(appDir.path, 'downloads');
  }

  /// Generates a local path for a download.
  Future<String> _getLocalPath(
    int episodeId,
    String episodeTitle,
    String url,
  ) async {
    return buildDownloadPath(
      downloadsDir: await getDownloadsDirectory(),
      episodeId: episodeId,
      episodeTitle: episodeTitle,
      url: url,
    );
  }
}
