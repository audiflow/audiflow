import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../download/services/auto_download_pause_service.dart';
import '../../review_prompt/providers/review_prompt_providers.dart';
import '../../review_prompt/repositories/review_prompt_repository.dart';
import '../../review_prompt/services/review_prompt_trigger.dart';
import '../../settings/providers/settings_providers.dart';
import '../../station/services/station_reconciler_service.dart';
import '../models/playback_history.dart';
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
  final reviewPromptRepository = ref.watch(reviewPromptRepositoryProvider);
  final reviewPromptTrigger = ref.watch(reviewPromptTriggerProvider);
  final service = PlaybackHistoryService(
    repository,
    getCompletionThreshold: settingsRepo.getAutoCompleteThreshold,
    reconcilerService: reconcilerService,
    reviewPromptRepository: reviewPromptRepository,
    reviewPromptTrigger: reviewPromptTrigger,
    autoDownloadPause: ref.watch(autoDownloadPauseServiceProvider),
  );
  ref.onDispose(service.dispose);
  return service;
}

/// Service for managing playback history with auto-completion logic.
///
/// Handles progress saving throttling, automatic completion detection,
/// and accumulation of listen-time statistics (content duration vs
/// real-time duration).
class PlaybackHistoryService {
  PlaybackHistoryService(
    this._repository, {
    required this._getCompletionThreshold,
    this._reconcilerService,
    this._reviewPromptRepository,
    this._reviewPromptTrigger,
    this._autoDownloadPause,
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now;

  final PlaybackHistoryRepository _repository;
  final double Function() _getCompletionThreshold;
  final StationReconcilerService? _reconcilerService;
  final ReviewPromptRepository? _reviewPromptRepository;
  final ReviewPromptTrigger? _reviewPromptTrigger;
  final AutoDownloadPauseService? _autoDownloadPause;

  /// Injectable clock for testing.
  final DateTime Function() _clock;

  /// Minimum interval between progress saves (5 seconds).
  static const int saveIntervalMs = 5000;

  /// Position threshold for considering playback "from beginning" (5 seconds).
  static const int fromBeginningThresholdMs = 5000;

  /// Maximum ratio of content delta to expected content delta before
  /// treating the update as a seek (and discarding time accumulation).
  static const double seekDetectionMultiplier = 3.0;

  final _progressSaved = StreamController<int>.broadcast();

  /// Episode IDs whose position was just saved on pause or stop, or that
  /// just passed the completion threshold. Views that show played state
  /// refresh on it: neither changes anything else they listen to (the
  /// completion lifecycle event fires only at the track's end).
  Stream<int> get progressSaved => _progressSaved.stream;

  void dispose() => _progressSaved.close();

  int _lastSavedPositionMs = 0;
  DateTime? _lastSaveTime;
  bool _notifiedInProgressThisSession = false;

  /// Called when playback starts for an episode.
  ///
  /// Starts a replay when the episode is played, so the new listen shows
  /// in "last played" queries while the episode stays played, and
  /// increments play count if starting from the beginning.
  Future<void> onPlaybackStarted(int episodeId, int positionMs) async {
    _lastSavedPositionMs = positionMs;
    _lastSaveTime = _clock();
    _notifiedInProgressThisSession = false;

    // No-op unless the last listen finished. Resuming past the completion
    // threshold continues the finished listen rather than starting a new
    // one, which would otherwise count a second completion.
    if (!await _isPastCompletion(episodeId, positionMs)) {
      await _repository.startReplay(episodeId, positionMs: positionMs);
    }

    // Increment play count if starting from beginning
    if (positionMs < fromBeginningThresholdMs) {
      await _repository.incrementPlayCount(episodeId);
    }

    // Arm the review-prompt trigger; it fires after the configured delay
    // unless playback is paused or stopped first.
    _reviewPromptTrigger?.armForPlayback();

    await _tryRecordPodcastPlayed(episodeId);
  }

  Future<bool> _isPastCompletion(int episodeId, int positionMs) async {
    final history = await _repository.getByEpisodeId(episodeId);
    final durationMs = history?.durationMs;
    if (durationMs == null || durationMs <= 0) return false;
    return _getCompletionThreshold() <= positionMs / durationMs;
  }

  /// A finished listen resumed past the threshold is not a replay until
  /// playback moves back below it (e.g. a seek backward); from then on the
  /// listen is resumable like any replay.
  Future<void> _startReplayIfRewound(
    int episodeId,
    int positionMs,
    int durationMs,
  ) async {
    if (durationMs <= 0) return;
    if (_getCompletionThreshold() <= positionMs / durationMs) return;
    // No-op unless the last listen finished.
    await _repository.startReplay(episodeId, positionMs: positionMs);
  }

  /// Best-effort: playing a podcast resumes its paused auto-download.
  Future<void> _tryRecordPodcastPlayed(int episodeId) async {
    try {
      await _autoDownloadPause?.recordPlayback(episodeId);
    } on Exception {
      // Auto-download bookkeeping must never break playback.
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

    await _startReplayIfRewound(episodeId, positionMs, durationMs);
    await _repository.saveProgress(
      episodeId: episodeId,
      positionMs: positionMs,
      durationMs: durationMs,
      listenedDeltaMs: durations.listenedMs,
      realtimeDeltaMs: durations.realtimeMs,
    );

    // Accumulate into the app-wide review-prompt counter.
    if (0 < durations.listenedMs) {
      await _reviewPromptRepository?.addListened(
        Duration(milliseconds: durations.listenedMs),
      );
    }

    // Notify stations once per session when episode transitions to in-progress.
    if (!_notifiedInProgressThisSession && 0 < positionMs) {
      _notifiedInProgressThisSession = true;
      await _tryReconcile(episodeId);
    }

    // Auto-complete check
    if (0 < durationMs) {
      final progressPercent = positionMs / durationMs;
      if (_getCompletionThreshold() <= progressPercent) {
        // A replay completes again even though the episode is played.
        final history = await _repository.getByEpisodeId(episodeId);
        if (!(history?.isListenFinished ?? false)) {
          await _repository.markCompleted(episodeId);
          if (!_progressSaved.isClosed) _progressSaved.add(episodeId);
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

    await _startReplayIfRewound(
      episodeId,
      progress.position.inMilliseconds,
      progress.duration.inMilliseconds,
    );
    await _repository.saveProgress(
      episodeId: episodeId,
      positionMs: progress.position.inMilliseconds,
      durationMs: progress.duration.inMilliseconds,
      listenedDeltaMs: durations.listenedMs,
      realtimeDeltaMs: durations.realtimeMs,
    );
    if (!_progressSaved.isClosed) _progressSaved.add(episodeId);

    if (0 < durations.listenedMs) {
      await _reviewPromptRepository?.addListened(
        Duration(milliseconds: durations.listenedMs),
      );
    }

    // Pausing within the trigger delay should not surprise the user.
    _reviewPromptTrigger?.cancel();
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
    if (!_progressSaved.isClosed) _progressSaved.add(episodeId);

    if (0 < durations.listenedMs) {
      await _reviewPromptRepository?.addListened(
        Duration(milliseconds: durations.listenedMs),
      );
    }

    _reviewPromptTrigger?.cancel();

    _lastSavedPositionMs = 0;
    _lastSaveTime = null;
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

  /// Marks every episode in [episodeIds] as completed (e.g. a whole
  /// podcast at once). Returns how many were marked.
  ///
  /// Stations are reconciled once for the batch, also when a write fails
  /// partway, so they match the episodes that did change.
  Future<int> markAllCompleted(Iterable<int> episodeIds) =>
      _markAll(episodeIds, _repository.markCompleted);

  /// Marks every episode in [episodeIds] as not played. Returns how many
  /// were marked.
  Future<int> markAllIncomplete(Iterable<int> episodeIds) =>
      _markAll(episodeIds, _repository.markIncomplete);

  Future<int> _markAll(
    Iterable<int> episodeIds,
    Future<void> Function(int episodeId) mark,
  ) async {
    final ids = episodeIds.toList();
    var count = 0;
    try {
      for (final id in ids) {
        await mark(id);
        count++;
      }
    } finally {
      if (0 < count) await _tryReconcileAll(ids.take(count));
    }
    return count;
  }

  Future<void> _tryReconcileAll(Iterable<int> episodeIds) async {
    try {
      await _reconcilerService?.onEpisodesChanged(episodeIds);
    } on Exception {
      // Station reconciliation is best-effort; do not break the batch.
    }
  }

  /// Best-effort station reconciliation — never breaks the calling flow.
  Future<void> _tryReconcile(int episodeId) async {
    try {
      await _reconcilerService?.onEpisodeChanged(episodeId);
    } on Exception {
      // Station reconciliation is best-effort; do not break playback.
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
