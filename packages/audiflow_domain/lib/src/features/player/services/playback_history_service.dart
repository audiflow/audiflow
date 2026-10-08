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

  /// The listen being tracked, from [onPlaybackStarted] to
  /// [onPlaybackStopped]. Only save throttling lives here; whether the
  /// listen is open or finished is persisted on [PlaybackHistory] so a
  /// restart and other episodes' changes cannot lose it (FR 04).
  _ListenSession _session = const _ListenSession.none();

  /// Called when playback starts for an episode.
  ///
  /// Reopens a finished listen as a replay when it starts below the
  /// completion threshold, and increments play count if starting from
  /// the beginning. Only a replay from the beginning counts another
  /// completion when it finishes.
  Future<void> onPlaybackStarted(int episodeId, int positionMs) async {
    _session = _ListenSession(
      lastSavedPositionMs: positionMs,
      lastSaveTime: _clock(),
    );

    final history = await _repository.getByEpisodeId(episodeId);
    await _reopenListenBelowThreshold(
      episodeId,
      positionMs: positionMs,
      durationMs: history?.durationMs ?? 0,
    );

    // Increment play count if starting from beginning
    if (positionMs < fromBeginningThresholdMs) {
      await _repository.incrementPlayCount(episodeId);
    }

    // Arm the review-prompt trigger; it fires after the configured delay
    // unless playback is paused or stopped first.
    _reviewPromptTrigger?.armForPlayback();

    await _tryRecordPodcastPlayed(episodeId);
  }

  /// Called when the listener seeks the playing episode from [from] to
  /// [to]. Seeks the player makes on its own account (interruption
  /// rewinds, the end-of-chapter sleep timer) are not reported.
  ///
  /// A rewind below the completion threshold reopens a finished listen as
  /// a replay, so the rewound position is resumable; it counts another
  /// completion only if it rewinds to the beginning. Playing on, or
  /// skipping forward, after "mark as played" keeps the listen finished.
  Future<void> onSeeked(
    int episodeId, {
    required Duration from,
    required Duration to,
    required Duration duration,
  }) async {
    if (to < from) {
      await _reopenListenBelowThreshold(
        episodeId,
        positionMs: to.inMilliseconds,
        durationMs: duration.inMilliseconds,
      );
    }
  }

  /// A finished listen taken up again below the threshold is a new
  /// listen (a replay); past the threshold it is the finished listen's
  /// tail, which must not count a second completion. [durationMs] of zero
  /// means unknown, which counts as below. See
  /// [PlaybackHistoryRepository.startReplay] for when it changes nothing.
  Future<void> _reopenListenBelowThreshold(
    int episodeId, {
    required int positionMs,
    required int durationMs,
  }) async {
    if (_isPastThreshold(positionMs, durationMs)) return;
    await _repository.startReplay(
      episodeId,
      positionMs: positionMs,
      fromStart: positionMs < fromBeginningThresholdMs,
    );
  }

  bool _isPastThreshold(int positionMs, int durationMs) {
    if (durationMs <= 0) return false;
    return _getCompletionThreshold() <= positionMs / durationMs;
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
    final delta = (positionMs - _session.lastSavedPositionMs).abs();
    if (delta < saveIntervalMs) return;

    final now = _clock();
    final durations = _computeListenDurations(
      positionMs: positionMs,
      now: now,
      speed: speed,
    );

    _session = _session.saved(positionMs: positionMs, at: now);

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
    if (!_session.notifiedInProgress && 0 < positionMs) {
      _session = _session.inProgressNotified();
      await _tryReconcile(episodeId);
    }

    if (_isPastThreshold(positionMs, durationMs)) {
      await _finishListen(episodeId);
    }
  }

  /// Auto-completion: finishes the current listen once. A finished listen
  /// playing out its tail, also after an automatic rewind, is left alone.
  Future<void> _finishListen(int episodeId) async {
    if (!await _repository.finishListen(episodeId)) return;
    if (!_progressSaved.isClosed) _progressSaved.add(episodeId);
    await _tryReconcile(episodeId);
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

    _session = _session.saved(
      positionMs: progress.position.inMilliseconds,
      at: now,
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

    _session = const _ListenSession.none();
  }

  /// Manually marks an episode as completed, which finishes its listen.
  /// Marking a played episode does not count another completion.
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
  /// podcast at once), skipping those already played, also any being
  /// replayed. Returns how many were marked.
  ///
  /// Stations are reconciled once for the batch, also when a write fails
  /// partway, so they match the episodes that did change.
  Future<int> markAllCompleted(Iterable<int> episodeIds) =>
      _markAll(episodeIds, _repository.markCompletedUnlessPlayed);

  /// Marks every episode in [episodeIds] as not played. Returns how many
  /// were marked.
  Future<int> markAllIncomplete(Iterable<int> episodeIds) =>
      _markAll(episodeIds, (id) async {
        await _repository.markIncomplete(id);
        return true;
      });

  Future<int> _markAll(
    Iterable<int> episodeIds,
    Future<bool> Function(int episodeId) mark,
  ) async {
    final changed = <int>[];
    try {
      for (final id in episodeIds) {
        if (await mark(id)) changed.add(id);
      }
    } finally {
      if (changed.isNotEmpty) await _tryReconcileAll(changed);
    }
    return changed.length;
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
  /// Rebaselines the session's last save time so that the pause duration
  /// is not counted as real-time in the next [onProgressUpdate].
  void onPlaybackResumed() {
    _session = _session.resumedAt(_clock());
  }

  /// Resets tracking state (e.g., when app goes to background).
  void reset() {
    _session = const _ListenSession.none();
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
    final lastSaveTime = _session.lastSaveTime;
    if (lastSaveTime == null) {
      return const _ListenDurations(listenedMs: 0, realtimeMs: 0);
    }

    final contentDeltaMs = positionMs - _session.lastSavedPositionMs;
    final wallClockDeltaMs = now.difference(lastSaveTime).inMilliseconds;

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

/// Save-throttling state of the listen being tracked. Immutable so every
/// event replaces it as a whole and no flag can outlive the listen.
class _ListenSession {
  const _ListenSession({
    required this.lastSavedPositionMs,
    required this.lastSaveTime,
    this.notifiedInProgress = false,
  });

  const _ListenSession.none()
    : lastSavedPositionMs = 0,
      lastSaveTime = null,
      notifiedInProgress = false;

  final int lastSavedPositionMs;
  final DateTime? lastSaveTime;
  final bool notifiedInProgress;

  _ListenSession saved({required int positionMs, required DateTime at}) =>
      _copyWith(lastSavedPositionMs: positionMs, lastSaveTime: at);

  _ListenSession resumedAt(DateTime at) => _copyWith(lastSaveTime: at);

  _ListenSession inProgressNotified() => _copyWith(notifiedInProgress: true);

  _ListenSession _copyWith({
    int? lastSavedPositionMs,
    DateTime? lastSaveTime,
    bool? notifiedInProgress,
  }) => _ListenSession(
    lastSavedPositionMs: lastSavedPositionMs ?? this.lastSavedPositionMs,
    lastSaveTime: lastSaveTime ?? this.lastSaveTime,
    notifiedInProgress: notifiedInProgress ?? this.notifiedInProgress,
  );
}
