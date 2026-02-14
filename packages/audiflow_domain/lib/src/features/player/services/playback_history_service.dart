import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../settings/providers/settings_providers.dart';
import '../models/playback_progress.dart';
import '../repositories/playback_history_repository.dart';
import '../repositories/playback_history_repository_impl.dart';

part 'playback_history_service.g.dart';

/// Provides the PlaybackHistoryService.
@Riverpod(keepAlive: true)
PlaybackHistoryService playbackHistoryService(Ref ref) {
  final repository = ref.watch(playbackHistoryRepositoryProvider);
  final settingsRepo = ref.watch(appSettingsRepositoryProvider);
  return PlaybackHistoryService(
    repository,
    getCompletionThreshold: settingsRepo.getAutoCompleteThreshold,
  );
}

/// Service for managing playback history with auto-completion logic.
///
/// Handles progress saving throttling and automatic completion detection.
class PlaybackHistoryService {
  PlaybackHistoryService(
    this._repository, {
    required double Function() getCompletionThreshold,
  }) : _getCompletionThreshold = getCompletionThreshold;

  final PlaybackHistoryRepository _repository;
  final double Function() _getCompletionThreshold;

  /// Minimum interval between progress saves (15 seconds).
  static const int saveIntervalMs = 15000;

  /// Position threshold for considering playback "from beginning" (5 seconds).
  static const int fromBeginningThresholdMs = 5000;

  int _lastSavedPositionMs = 0;

  /// Called when playback starts for an episode.
  ///
  /// Increments play count if starting from the beginning.
  Future<void> onPlaybackStarted(int episodeId, int positionMs) async {
    _lastSavedPositionMs = positionMs;

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

    // Throttle saves to every 15 seconds
    final delta = (positionMs - _lastSavedPositionMs).abs();
    if (delta < saveIntervalMs) return;

    _lastSavedPositionMs = positionMs;

    await _repository.saveProgress(
      episodeId: episodeId,
      positionMs: positionMs,
      durationMs: durationMs,
    );

    // Auto-complete check
    if (0 < durationMs) {
      final progressPercent = positionMs / durationMs;
      if (_getCompletionThreshold() <= progressPercent) {
        final isAlreadyCompleted = await _repository.isCompleted(episodeId);
        if (!isAlreadyCompleted) {
          await _repository.markCompleted(episodeId);
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
    await _repository.saveProgress(
      episodeId: episodeId,
      positionMs: progress.position.inMilliseconds,
      durationMs: progress.duration.inMilliseconds,
    );

    _lastSavedPositionMs = 0;
  }

  /// Manually marks an episode as completed.
  Future<void> markCompleted(int episodeId) {
    return _repository.markCompleted(episodeId);
  }

  /// Manually marks an episode as incomplete.
  Future<void> markIncomplete(int episodeId) {
    return _repository.markIncomplete(episodeId);
  }

  /// Resets tracking state (e.g., when app goes to background).
  void reset() {
    _lastSavedPositionMs = 0;
  }
}
