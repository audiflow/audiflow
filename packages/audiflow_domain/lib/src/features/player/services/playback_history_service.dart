import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../download/services/download_service.dart';
import '../../settings/providers/settings_providers.dart';
import '../../station/services/station_reconciler_service.dart';
import '../models/playback_progress.dart';
import '../repositories/playback_history_repository.dart';
import '../repositories/playback_history_repository_impl.dart';

part 'playback_history_service.g.dart';

/// Provides the PlaybackHistoryService.
@Riverpod(keepAlive: true)
PlaybackHistoryService playbackHistoryService(Ref ref) {
  final repository = ref.watch(playbackHistoryRepositoryProvider);
  final settingsRepo = ref.watch(appSettingsRepositoryProvider);
  final reconcilerService = ref.watch(stationReconcilerServiceProvider);
  final downloadService = ref.watch(downloadServiceProvider);
  return PlaybackHistoryService(
    repository,
    getCompletionThreshold: settingsRepo.getAutoCompleteThreshold,
    reconcilerService: reconcilerService,
    downloadService: downloadService,
  );
}

/// Service for managing playback history with auto-completion logic.
///
/// Handles progress saving throttling, automatic completion detection,
/// and accumulation of listen-time statistics (content duration vs
/// real-time duration).
class PlaybackHistoryService {
  PlaybackHistoryService(
    this._repository, {
    required double Function() getCompletionThreshold,
    StationReconcilerService? reconcilerService,
    DownloadService? downloadService,
    DateTime Function()? clock,
  }) : _getCompletionThreshold = getCompletionThreshold,
       _reconcilerService = reconcilerService,
       _downloadService = downloadService,
       _clock = clock ?? DateTime.now;

  final PlaybackHistoryRepository _repository;
  final double Function() _getCompletionThreshold;
  final StationReconcilerService? _reconcilerService;
  final DownloadService? _downloadService;

  /// Injectable clock for testing.
  final DateTime Function() _clock;

  /// Minimum interval between progress saves (5 seconds).
  static const int saveIntervalMs = 5000;

  /// Position threshold for considering playback "from beginning" (5 seconds).
  static const int fromBeginningThresholdMs = 5000;

  /// Maximum ratio of content delta to expected content delta before
  /// treating the update as a seek (and discarding time accumulation).
  static const double seekDetectionMultiplier = 3.0;

  int _lastSavedPositionMs = 0;
  DateTime? _lastSaveTime;
  bool _notifiedInProgressThisSession = false;

  /// Called when playback starts for an episode.
  ///
  /// Clears completion status so the episode appears in "last played"
  /// queries, and increments play count if starting from the beginning.
  Future<void> onPlaybackStarted(int episodeId, int positionMs) async {
    _lastSavedPositionMs = positionMs;
    _lastSaveTime = _clock();
    _notifiedInProgressThisSession = false;

    // Clear completed status so getLastPlayed() can find this episode.
    final isCompleted = await _repository.isCompleted(episodeId);
    if (isCompleted) {
      await _repository.markIncomplete(episodeId);
    }

    // Increment play count if starting from beginning
    if (positionMs < fromBeginningThresholdMs) {
      await _repository.incrementPlayCount(episodeId);
    }
  }

  /// Called on each progress update during playback.
  ///
  /// Throttles saves to every 5 seconds. Auto-marks as completed
  /// when progress reaches the configured threshold.
  /// Accumulates content and real-time durations using seek detection.
  Future<void> onProgressUpdate(
    int episodeId,
    PlaybackProgress progress, {
    double speed = 1.0,
  }) async {
    final positionMs = progress.position.inMilliseconds;
    final durationMs = progress.duration.inMilliseconds;

    // Skip when source hasn't loaded yet — position data is stale from
    // the previous episode during track transitions.
    if (durationMs == 0) return;

    // Throttle saves to every 5 seconds
    final delta = (positionMs - _lastSavedPositionMs).abs();
    if (delta < saveIntervalMs) return;

    final now = _clock();
    final durations = _computeListenDurations(
      positionMs: positionMs,
      now: now,
      speed: speed,
    );

    _lastSavedPositionMs = positionMs;
    _lastSaveTime = now;

    await _repository.saveProgress(
      episodeId: episodeId,
      positionMs: positionMs,
      durationMs: durationMs,
      listenedDeltaMs: durations.listenedMs,
      realtimeDeltaMs: durations.realtimeMs,
    );

    // Notify stations once per session when episode transitions to in-progress.
    if (!_notifiedInProgressThisSession && 0 < positionMs) {
      _notifiedInProgressThisSession = true;
      await _tryReconcile(episodeId);
    }

    // Auto-complete check
    if (0 < durationMs) {
      final progressPercent = positionMs / durationMs;
      if (_getCompletionThreshold() <= progressPercent) {
        final isAlreadyCompleted = await _repository.isCompleted(episodeId);
        if (!isAlreadyCompleted) {
          await _repository.markCompleted(episodeId);
          await _tryReconcile(episodeId);
          await _tryAutoDeleteDownload(episodeId);
        }
      }
    }
  }

  /// Called when playback is paused.
  ///
  /// Forces an immediate save regardless of throttle interval.
  Future<void> onPlaybackPaused(
    int episodeId,
    PlaybackProgress progress, {
    double speed = 1.0,
  }) async {
    final now = _clock();
    final durations = _computeListenDurations(
      positionMs: progress.position.inMilliseconds,
      now: now,
      speed: speed,
    );

    _lastSavedPositionMs = progress.position.inMilliseconds;
    _lastSaveTime = now;

    await _repository.saveProgress(
      episodeId: episodeId,
      positionMs: progress.position.inMilliseconds,
      durationMs: progress.duration.inMilliseconds,
      listenedDeltaMs: durations.listenedMs,
      realtimeDeltaMs: durations.realtimeMs,
    );
  }

  /// Called when playback stops or switches to a different episode.
  ///
  /// Forces final save and resets tracking state.
  Future<void> onPlaybackStopped(
    int episodeId,
    PlaybackProgress progress, {
    double speed = 1.0,
  }) async {
    final now = _clock();
    final durations = _computeListenDurations(
      positionMs: progress.position.inMilliseconds,
      now: now,
      speed: speed,
    );

    await _repository.saveProgress(
      episodeId: episodeId,
      positionMs: progress.position.inMilliseconds,
      durationMs: progress.duration.inMilliseconds,
      listenedDeltaMs: durations.listenedMs,
      realtimeDeltaMs: durations.realtimeMs,
    );

    _lastSavedPositionMs = 0;
    _lastSaveTime = null;
  }

  /// Manually marks an episode as completed.
  Future<void> markCompleted(int episodeId) async {
    await _repository.markCompleted(episodeId);
    await _tryReconcile(episodeId);
    await _tryAutoDeleteDownload(episodeId);
  }

  /// Manually marks an episode as incomplete.
  Future<void> markIncomplete(int episodeId) async {
    await _repository.markIncomplete(episodeId);
    await _tryReconcile(episodeId);
  }

  /// Best-effort station reconciliation — never breaks the calling flow.
  Future<void> _tryReconcile(int episodeId) async {
    try {
      await _reconcilerService?.onEpisodeChanged(episodeId);
    } on Exception {
      // Station reconciliation is best-effort; do not break playback.
    }
  }

  /// Best-effort auto-delete of downloaded file when episode completes.
  Future<void> _tryAutoDeleteDownload(int episodeId) async {
    final service = _downloadService;
    if (service == null) return;
    try {
      await service.onEpisodeCompleted(episodeId);
    } on Exception {
      // Auto-delete is best-effort; do not break playback flow.
    }
  }

  /// Called when playback resumes after a pause.
  ///
  /// Rebaselines [_lastSaveTime] so that the pause duration is not
  /// counted as real-time in the next [onProgressUpdate].
  void onPlaybackResumed() {
    _lastSaveTime = _clock();
  }

  /// Resets tracking state (e.g., when app goes to background).
  void reset() {
    _lastSavedPositionMs = 0;
    _lastSaveTime = null;
  }

  /// Computes incremental listen durations since the last save.
  ///
  /// Uses seek detection: if the content position delta is unreasonably
  /// large relative to the wall-clock time * speed, the update is treated
  /// as a seek and no time is accumulated.
  _ListenDurations _computeListenDurations({
    required int positionMs,
    required DateTime now,
    required double speed,
  }) {
    if (_lastSaveTime == null) {
      return const _ListenDurations(listenedMs: 0, realtimeMs: 0);
    }

    final contentDeltaMs = positionMs - _lastSavedPositionMs;
    final wallClockDeltaMs = now.difference(_lastSaveTime!).inMilliseconds;

    // Only accumulate for positive deltas (not backwards seeks)
    if (contentDeltaMs <= 0 || wallClockDeltaMs <= 0) {
      return const _ListenDurations(listenedMs: 0, realtimeMs: 0);
    }

    // Seek detection: expected content = wall-clock * speed.
    // If actual content delta exceeds that by a large margin, it's a seek.
    final expectedContentMs = (wallClockDeltaMs * speed).round();
    if (0 < expectedContentMs &&
        seekDetectionMultiplier * expectedContentMs < contentDeltaMs) {
      return const _ListenDurations(listenedMs: 0, realtimeMs: 0);
    }

    return _ListenDurations(
      listenedMs: contentDeltaMs,
      realtimeMs: wallClockDeltaMs,
    );
  }
}

class _ListenDurations {
  const _ListenDurations({required this.listenedMs, required this.realtimeMs});

  final int listenedMs;
  final int realtimeMs;
}
