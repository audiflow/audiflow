import 'package:freezed_annotation/freezed_annotation.dart';

part 'download_status.freezed.dart';

/// Status of a download task.
///
/// State transitions:
/// - pending -> downloading -> completed
/// - downloading -> paused -> downloading
/// - downloading -> failed (after retries)
/// - any -> cancelled
@freezed
sealed class DownloadStatus with _$DownloadStatus {
  const DownloadStatus._();

  /// Queued, waiting to start
  const factory DownloadStatus.pending() = DownloadStatusPending;

  /// Actively downloading
  const factory DownloadStatus.downloading() = DownloadStatusDownloading;

  /// Paused by user or system
  const factory DownloadStatus.paused() = DownloadStatusPaused;

  /// Successfully completed
  const factory DownloadStatus.completed() = DownloadStatusCompleted;

  /// Failed after retries exhausted
  const factory DownloadStatus.failed() = DownloadStatusFailed;

  /// Cancelled by user
  const factory DownloadStatus.cancelled() = DownloadStatusCancelled;

  /// Convert to int for database storage
  int toDbValue() => switch (this) {
    DownloadStatusPending() => 0,
    DownloadStatusDownloading() => 1,
    DownloadStatusPaused() => 2,
    DownloadStatusCompleted() => 3,
    DownloadStatusFailed() => 4,
    DownloadStatusCancelled() => 5,
  };

  /// Create from database int value
  static DownloadStatus fromDbValue(int value) => switch (value) {
    0 => const DownloadStatus.pending(),
    1 => const DownloadStatus.downloading(),
    2 => const DownloadStatus.paused(),
    3 => const DownloadStatus.completed(),
    4 => const DownloadStatus.failed(),
    5 => const DownloadStatus.cancelled(),
    _ => const DownloadStatus.pending(),
  };

  /// Whether download is in an active state (can be paused/cancelled)
  bool get isActive => switch (this) {
    DownloadStatusPending() => true,
    DownloadStatusDownloading() => true,
    DownloadStatusPaused() => true,
    _ => false,
  };

  /// Whether download needs user attention
  bool get needsAttention => this is DownloadStatusFailed;
}
