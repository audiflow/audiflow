import 'package:logger/logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../common/providers/logger_provider.dart';
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
  final log = ref.watch(namedLoggerProvider('PlaybackHistory'));
  return PlaybackHistoryService(
    repository,
    log: log,
    getCompletionThreshold: settingsRepo.getAutoCompleteThreshold,
    reconcilerService: reconcilerService,
  );
}

/// Service for managing playback history with auto-completion logic.
///
/// Handles progress saving throttling and automatic completion detection.
class PlaybackHistoryService {
  PlaybackHistoryService(
    this._repository, {
    required Logger log,
    required double Function() getCompletionThreshold,
    StationReconcilerService? reconcilerService,
  }) : _log = log,
       _getCompletionThreshold = getCompletionThreshold,
       _reconcilerService = reconcilerService;

  final PlaybackHistoryRepository _repository;
  final Logger _log;
  final double Function() _getCompletionThreshold;
  final StationReconcilerService? _reconcilerService;

  /// Minimum interval between progress saves (5 seconds).
  static const int saveIntervalMs = 5000;

  /// Position threshold for considering playback "from beginning" (5 seconds).
  static const int fromBeginningThresholdMs = 5000;

  int _lastSavedPositionMs = 0;
  bool _notifiedInProgressThisSession = false;

  /// Called when playback starts for an episode.
  ///
  /// Increments play count if starting from the beginning.
  Future<void> onPlaybackStarted(int episodeId, int positionMs) async {
    _log.i(
      '[Started] episodeId=$episodeId, positionMs=$positionMs, '
      'fromBeginning=${positionMs < fromBeginningThresholdMs}',
    );
    _lastSavedPositionMs = positionMs;
    _notifiedInProgressThisSession = false;

    // Increment play count if starting from beginning
    if (positionMs < fromBeginningThresholdMs) {
      await _repository.incrementPlayCount(episodeId);
    }
  }

  /// Called on each progress update during playback.
  ///
  /// Throttles saves to every 15 seconds. Auto-marks as completed
  /// when progress reaches 95%.
  Future<void> onProgressUpdate(
    int episodeId,
    PlaybackProgress progress,
  ) async {
    final positionMs = progress.position.inMilliseconds;
    final durationMs = progress.duration.inMilliseconds;

    // Skip when source hasn't loaded yet — position data is stale from
    // the previous episode during track transitions.
    if (durationMs == 0) {
      _log.d('[Skipped] episodeId=$episodeId, dur=0 (source not loaded)');
      return;
    }

    // Throttle saves to every 5 seconds
    final delta = (positionMs - _lastSavedPositionMs).abs();
    if (delta < saveIntervalMs) {
      _log.d(
        '[Throttled] episodeId=$episodeId, delta=${delta}ms, '
        'need=${saveIntervalMs}ms',
      );
      return;
    }

    _lastSavedPositionMs = positionMs;

    _log.i(
      '[Save] episodeId=$episodeId, pos=${positionMs}ms, '
      'dur=${durationMs}ms',
    );
    await _repository.saveProgress(
      episodeId: episodeId,
      positionMs: positionMs,
      durationMs: durationMs,
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
        }
      }
    }
  }

  /// Called when playback is paused.
  ///
  /// Forces an immediate save regardless of throttle interval.
  Future<void> onPlaybackPaused(
    int episodeId,
    PlaybackProgress progress,
  ) async {
    _log.i(
      '[Paused] episodeId=$episodeId, '
      'pos=${progress.position.inMilliseconds}ms, '
      'dur=${progress.duration.inMilliseconds}ms',
    );
    _lastSavedPositionMs = progress.position.inMilliseconds;

    await _repository.saveProgress(
      episodeId: episodeId,
      positionMs: progress.position.inMilliseconds,
      durationMs: progress.duration.inMilliseconds,
    );
  }

  /// Called when playback stops or switches to a different episode.
  ///
  /// Forces final save and resets tracking state.
  Future<void> onPlaybackStopped(
    int episodeId,
    PlaybackProgress progress,
  ) async {
    _log.i(
      '[Stopped] episodeId=$episodeId, '
      'pos=${progress.position.inMilliseconds}ms, '
      'dur=${progress.duration.inMilliseconds}ms',
    );
    await _repository.saveProgress(
      episodeId: episodeId,
      positionMs: progress.position.inMilliseconds,
      durationMs: progress.duration.inMilliseconds,
    );

    _lastSavedPositionMs = 0;
  }

  /// Manually marks an episode as completed.
  Future<void> markCompleted(int episodeId) async {
    await _repository.markCompleted(episodeId);
    await _tryReconcile(episodeId);
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

  /// Resets tracking state (e.g., when app goes to background).
  void reset() {
    _lastSavedPositionMs = 0;
  }
}
