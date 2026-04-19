import 'dart:async';

import 'package:just_audio/just_audio.dart';
import 'package:riverpod/riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:rxdart/rxdart.dart';

import 'package:logger/logger.dart';

import '../../../common/providers/logger_provider.dart';
import '../../download/services/download_service.dart';
import '../../feed/repositories/episode_repository_impl.dart';
import '../../queue/services/queue_service.dart';
import '../../settings/providers/settings_providers.dart';
import '../../subscription/repositories/subscription_repository_impl.dart';
import '../models/now_playing_info.dart';
import '../models/playback_progress.dart';
import '../models/playback_state.dart';
import '../repositories/playback_history_repository_impl.dart';
import 'audio_playback_controller.dart';
import 'now_playing_controller.dart';
import 'playback_history_service.dart';
import 'player_lifecycle_events.dart';

part 'audio_player_service.g.dart';

/// Provides a singleton [AudioPlayer] instance.
///
/// This provider is kept alive for the app's lifetime to maintain audio state
/// across navigation and screen changes.
@Riverpod(keepAlive: true)
AudioPlayer audioPlayer(Ref ref) {
  // handleInterruptions must be false when using audio_service,
  // which manages the remote command center and audio session.
  final player = AudioPlayer(handleInterruptions: false);
  ref.onDispose(() => player.dispose());
  return player;
}

/// Provides a stream of the current playback speed.
///
/// Reactively updates when speed changes via [AudioPlayerController.setSpeed].
@Riverpod(keepAlive: true)
Stream<double> playbackSpeed(Ref ref) {
  final player = ref.watch(audioPlayerProvider);
  return player.speedStream;
}

/// Provides a stream of playback progress updates.
///
/// Combines position, duration, and buffered position into a single stream.
/// Updates approximately every 200ms while playing.
@Riverpod(keepAlive: true)
Stream<PlaybackProgress> playbackProgressStream(Ref ref) {
  final player = ref.watch(audioPlayerProvider);

  return Rx.combineLatest3<Duration, Duration?, Duration, PlaybackProgress>(
    player.positionStream,
    player.durationStream,
    player.bufferedPositionStream,
    (position, duration, buffered) => PlaybackProgress(
      position: position,
      duration: duration ?? Duration.zero,
      bufferedPosition: buffered,
    ),
  );
}

/// Provides the current playback progress.
///
/// Returns null when no audio is loaded.
@riverpod
PlaybackProgress? playbackProgress(Ref ref) {
  final asyncProgress = ref.watch(playbackProgressStreamProvider);
  return asyncProgress.value;
}

/// Controller for managing audio playback.
///
/// Wraps [AudioPlayer] to provide a simplified interface and exposes
/// playback state as a reactive [PlaybackState] stream.
///
/// Integrates with [PlaybackHistoryService] to track playback progress
/// and auto-mark episodes as completed.
///
/// Usage:
/// ```dart
/// final state = ref.watch(audioPlayerControllerProvider);
/// final controller = ref.read(audioPlayerControllerProvider.notifier);
/// await controller.play('https://example.com/episode.mp3');
/// ```
@Riverpod(keepAlive: true)
class AudioPlayerController extends _$AudioPlayerController
    implements AudioPlaybackController {
  late AudioPlayer _player;
  late Logger _log;
  StreamSubscription<PlayerState>? _stateSubscription;
  String? _currentUrl;
  int? _currentEpisodeId;
  bool _isLoadingSource = false;
  Timer? _fadeTimer;
  double? _preFadeVolume;
  Completer<void>? _fadeCompleter;
  final StreamController<PlayerLifecycleEvent> _lifecycleEvents =
      StreamController<PlayerLifecycleEvent>.broadcast();

  /// Broadcast stream of lifecycle events. Exposed via
  /// [playerLifecycleEventsProvider].
  Stream<PlayerLifecycleEvent> get lifecycleEvents => _lifecycleEvents.stream;

  @override
  PlaybackState build() {
    _player = ref.watch(audioPlayerProvider);
    _log = ref.watch(namedLoggerProvider('AudioPlayer'));
    _listenToPlayerState();
    _listenToProgress();
    ref.onDispose(_cleanup);
    return const PlaybackState.idle();
  }

  void _listenToProgress() {
    ref.listen<AsyncValue<PlaybackProgress>>(playbackProgressStreamProvider, (
      previous,
      next,
    ) {
      final progress = next.value;
      if (progress == null || _currentEpisodeId == null || _isLoadingSource) {
        return;
      }

      final historyService = ref.read(playbackHistoryServiceProvider);
      unawaited(
        historyService.onProgressUpdate(
          _currentEpisodeId!,
          progress,
          speed: _player.speed,
        ),
      );
    });
  }

  void _listenToPlayerState() {
    _stateSubscription = _player.playerStateStream.listen(
      (playerState) async {
        final processingState = playerState.processingState;
        final playing = playerState.playing;

        _log.d(
          '[StateStream] processing=$processingState, playing=$playing, '
          'currentUrl=${_currentUrl != null ? "set" : "null"}, '
          'episodeId=$_currentEpisodeId',
        );

        if (_currentUrl == null) {
          _log.d('[StateStream] currentUrl is null -> idle');
          state = const PlaybackState.idle();
          return;
        }

        final url = _currentUrl!;

        if (processingState == ProcessingState.completed) {
          _log.i('[StateStream] COMPLETED detected, advancing queue...');
          _lifecycleEvents.add(const EpisodeCompletedLifecycle());
          // Save final progress before clearing
          await _saveProgressOnStop();

          // Try to auto-play next from queue
          await _handlePlaybackComplete();
          _log.i('[StateStream] _handlePlaybackComplete finished');
        } else if (processingState == ProcessingState.loading ||
            processingState == ProcessingState.buffering) {
          state = PlaybackState.loading(episodeUrl: url);
        } else if (playing) {
          state = PlaybackState.playing(episodeUrl: url);
        } else {
          _log.d('[StateStream] paused (processing=$processingState)');
          state = PlaybackState.paused(episodeUrl: url);
        }
      },
      onError: (error, stack) {
        _log.e('[StateStream] stream error', error: error, stackTrace: stack);
        state = PlaybackState.error(message: error.toString());
      },
    );
  }

  Future<void> _saveProgressOnStop() async {
    if (_currentEpisodeId == null || _isLoadingSource) return;

    final progress = ref.read(playbackProgressProvider);
    if (progress == null) return;

    final historyService = ref.read(playbackHistoryServiceProvider);
    await historyService.onPlaybackStopped(
      _currentEpisodeId!,
      progress,
      speed: _player.speed,
    );
  }

  /// Handles playback completion by attempting to play the next episode.
  ///
  /// If there's a next episode in the queue, starts playing it automatically.
  /// Otherwise, clears the playback state.
  Future<void> _handlePlaybackComplete() async {
    try {
      _log.i('[Complete] Getting next episode from queue...');
      final queueService = ref.read(queueServiceProvider);
      final nextEpisode = await queueService.popNextEpisode();

      if (nextEpisode != null) {
        _log.i(
          '[Complete] Next episode found: '
          'id=${nextEpisode.id}, title="${nextEpisode.title}", '
          'audioUrl=${nextEpisode.audioUrl}',
        );

        // Fetch podcast title for the next episode
        final subscriptionRepo = ref.read(subscriptionRepositoryProvider);
        final subscription = await subscriptionRepo.getById(
          nextEpisode.podcastId,
        );
        final podcastTitle = subscription?.title ?? '';
        _log.d('[Complete] Podcast title: "$podcastTitle"');

        // Auto-play next episode
        _log.i('[Complete] Calling play() for next episode...');
        await play(
          nextEpisode.audioUrl,
          metadata: NowPlayingInfo(
            episodeUrl: nextEpisode.audioUrl,
            episodeTitle: nextEpisode.title,
            podcastTitle: podcastTitle,
            artworkUrl: nextEpisode.imageUrl ?? subscription?.artworkUrl,
            totalDuration: nextEpisode.durationMs != null
                ? Duration(milliseconds: nextEpisode.durationMs!)
                : null,
          ),
        );
        _log.i('[Complete] play() returned successfully');
      } else {
        _log.i('[Complete] No next episode, going idle');
        // No more episodes in queue, go idle
        state = const PlaybackState.idle();
        _currentUrl = null;
        _currentEpisodeId = null;
        ref.read(nowPlayingControllerProvider.notifier).clear();
      }
    } catch (e, stack) {
      _log.e(
        '[Complete] ERROR in _handlePlaybackComplete',
        error: e,
        stackTrace: stack,
      );
    }
  }

  void _cleanup() {
    _stateSubscription?.cancel();
    _fadeTimer?.cancel();
    _lifecycleEvents.close();
  }

  /// Plays audio from the specified URL.
  ///
  /// If a completed download exists for this episode, plays from local file.
  /// Otherwise streams from the remote URL.
  ///
  /// If audio is already playing from a different URL, it will stop the
  /// current playback and start the new audio.
  ///
  /// Optional [metadata] can be provided to display episode information
  /// in the mini player without needing to fetch it from the database.
  ///
  /// When [startAt] is non-null, playback begins at that position and the
  /// saved-resume history for this episode is ignored. Used by timestamped
  /// share links (`?t=<seconds>`) to honour explicit user intent.
  ///
  /// Integrates with [PlaybackHistoryService] to track playback progress.
  Future<void> play(
    String url, {
    NowPlayingInfo? metadata,
    Duration? startAt,
  }) async {
    try {
      _log.i('[Play] Starting: url=$url');

      if (_currentUrl != null && _currentUrl != url) {
        _lifecycleEvents.add(const EpisodeSwitchedLifecycle());
      }

      // Save progress of previous episode before switching
      if (_currentEpisodeId != null && _currentUrl != url) {
        _log.d('[Play] Saving progress of previous episode $_currentEpisodeId');
        await _saveProgressOnStop();
      }

      // Look up episode ID from URL
      final episodeRepo = ref.read(episodeRepositoryProvider);
      final episode = await episodeRepo.getByAudioUrl(url);
      _log.d('[Play] Episode lookup: ${episode?.id ?? "not found"}');

      // Guard progress listener (and pause/stop save paths) before mutating
      // current-episode state. Without this, awaited work below can yield to
      // the progress listener which would save stale position data under the
      // new episode ID.
      _isLoadingSource = true;
      Duration? loadedDuration;
      try {
        _currentUrl = url;
        _currentEpisodeId = episode?.id;
        state = PlaybackState.loading(episodeUrl: url);

        // Update now playing controller if metadata is provided
        if (metadata != null) {
          // Ensure the episode object is attached so the player screen
          // can access episodeId for the transcript tab.
          final enriched = episode != null && metadata.episode == null
              ? metadata.copyWith(episode: episode)
              : metadata;
          ref
              .read(nowPlayingControllerProvider.notifier)
              .setNowPlaying(enriched);
        }

        // Check for local download
        String playUrl = url;
        if (episode != null) {
          final downloadService = ref.read(downloadServiceProvider);
          final localPath = await downloadService.getLocalPath(episode.id);
          if (localPath != null) {
            // Percent-encode the path so URI-reserved characters (#, ?, %)
            // in the filename don't get parsed as fragment/query by the
            // underlying player.
            playUrl = Uri.file(localPath).toString();
            _log.d('[Play] Using local file: $playUrl');
          }
        }

        _log.d('[Play] Calling setUrl...');
        // setUrl returns the resolved duration once loaded; prefer it over
        // the property getter so an explicit startAt can be clamped against
        // the real episode length even when durationStream hasn't pushed yet.
        loadedDuration = await _player.setUrl(playUrl);
      } finally {
        _isLoadingSource = false;
      }

      // Honour explicit startAt over saved history.
      // Otherwise, seek to saved position if resuming a previously played
      // episode. If position is within 2s of the end, replay from start.
      if (startAt != null) {
        final duration =
            loadedDuration ?? _player.duration ?? await _awaitDuration();
        final clampedMs = duration == null
            ? startAt.inMilliseconds.clamp(0, 1 << 31)
            : startAt.inMilliseconds.clamp(0, duration.inMilliseconds);
        _log.d('[Play] Honouring explicit startAt: ${clampedMs}ms');
        await _player.seek(Duration(milliseconds: clampedMs));
        _lifecycleEvents.add(SeekLifecycle(Duration(milliseconds: clampedMs)));
      } else if (_currentEpisodeId != null) {
        final historyRepo = ref.read(playbackHistoryRepositoryProvider);
        final history = await historyRepo.getByEpisodeId(_currentEpisodeId!);
        if (history != null && 0 < history.positionMs) {
          final nearEnd =
              history.durationMs != null &&
              0 < history.durationMs! &&
              history.durationMs! - 2000 <= history.positionMs;
          if (nearEnd) {
            _log.d('[Play] Position near end, replaying from start');
          } else {
            _log.d('[Play] Seeking to saved position: ${history.positionMs}ms');
            await _player.seek(Duration(milliseconds: history.positionMs));
          }
        }
      }

      // Apply persisted playback speed
      final settingsRepo = ref.read(appSettingsRepositoryProvider);
      final speed = settingsRepo.getPlaybackSpeed();
      await _player.setSpeed(speed);

      // Notify history service of playback start
      if (_currentEpisodeId != null) {
        final historyService = ref.read(playbackHistoryServiceProvider);
        await historyService.onPlaybackStarted(
          _currentEpisodeId!,
          _player.position.inMilliseconds,
        );
      }

      _log.d('[Play] Calling _player.play()...');
      await _player.play();
      _log.i('[Play] _player.play() returned');
    } catch (e, stack) {
      _log.e('[Play] ERROR', error: e, stackTrace: stack);
      state = PlaybackState.error(message: 'Failed to play audio: $e');
    }
  }

  /// Waits briefly for [_player.duration] to resolve.
  ///
  /// Remote streams can publish duration asynchronously after [setUrl]
  /// resolves; when we need to clamp an explicit seek target we want to
  /// avoid racing that stream. Returns the first non-null duration or
  /// null if the timeout elapses first.
  Future<Duration?> _awaitDuration({
    Duration timeout = const Duration(seconds: 2),
  }) async {
    try {
      return await _player.durationStream
          .firstWhere((duration) => duration != null)
          .timeout(timeout);
    } on TimeoutException {
      return null;
    }
  }

  /// Fades the player's volume to 0 linearly over [total], then pauses.
  ///
  /// Restores the original volume on completion so future playback starts
  /// at the user's preferred level. Call [cancelFade] to abort in-flight
  /// and restore volume without pausing.
  Future<void> fadeOutAndPause({
    Duration total = const Duration(seconds: 8),
  }) async {
    // Already fading. Treat re-entry as a no-op — the in-flight fade will
    // complete normally and pause the player. The returned future resolves
    // immediately so callers using `unawaited(...)` don't accumulate work.
    if (_fadeTimer != null) return;

    _preFadeVolume = _player.volume;
    final startVolume = _preFadeVolume ?? 1.0;
    const stepMs = 100;
    final steps = (total.inMilliseconds / stepMs).ceil().clamp(1, 1000);
    var elapsedSteps = 0;

    final completer = Completer<void>();
    _fadeCompleter = completer;
    _fadeTimer = Timer.periodic(const Duration(milliseconds: stepMs), (
      timer,
    ) async {
      elapsedSteps += 1;
      final progress = (elapsedSteps / steps).clamp(0.0, 1.0);
      final next = (startVolume * (1.0 - progress)).clamp(0.0, 1.0);
      await _player.setVolume(next);

      if (steps <= elapsedSteps) {
        timer.cancel();
        _fadeTimer = null;
        await _player.pause();
        if (_preFadeVolume != null) {
          await _player.setVolume(_preFadeVolume!);
          _preFadeVolume = null;
        }
        if (!completer.isCompleted) completer.complete();
        _fadeCompleter = null;
      }
    });

    return completer.future;
  }

  /// Cancels an in-flight fade and restores the pre-fade volume.
  ///
  /// Awaits the volume restore so callers that resume playback immediately
  /// after [cancelFade] don't briefly play at near-zero volume.
  Future<void> cancelFade() async {
    if (_fadeTimer == null) return;
    _fadeTimer!.cancel();
    _fadeTimer = null;
    final completer = _fadeCompleter;
    _fadeCompleter = null;
    if (completer != null && !completer.isCompleted) {
      completer.complete();
    }
    if (_preFadeVolume != null) {
      final restoreTo = _preFadeVolume!;
      _preFadeVolume = null;
      await _player.setVolume(restoreTo);
    }
  }

  /// Pauses the current playback.
  ///
  /// Saves playback progress to history.
  @override
  Future<void> pause() async {
    // Save progress on pause — skip during source loading to avoid
    // persisting stale data from the previous episode.
    if (_currentEpisodeId != null && !_isLoadingSource) {
      final progress = ref.read(playbackProgressProvider);
      if (progress != null) {
        final historyService = ref.read(playbackHistoryServiceProvider);
        await historyService.onPlaybackPaused(
          _currentEpisodeId!,
          progress,
          speed: _player.speed,
        );
      }
    }
    await _player.pause();
  }

  /// Resumes playback if paused.
  ///
  /// No-op when no audio source is loaded (e.g. after app restart before
  /// the user taps play on an episode).
  @override
  Future<void> resume() async {
    if (_currentUrl == null) return;
    ref.read(playbackHistoryServiceProvider).onPlaybackResumed();
    await _player.play();
  }

  /// Toggles between play and pause states.
  ///
  /// If audio is playing, it will pause. If paused, it will resume.
  /// If a URL is provided and no audio is loaded, it will start playing
  /// from that URL.
  Future<void> togglePlayPause([String? url]) async {
    if (_player.playing) {
      await pause();
    } else if (_currentUrl != null) {
      await resume();
    } else if (url != null) {
      await play(url);
    }
  }

  /// Stops playback and clears the current audio source.
  ///
  /// Saves final playback progress to history.
  @override
  Future<void> stop() async {
    // Save final progress before stopping
    await _saveProgressOnStop();

    await _player.stop();
    _currentUrl = null;
    _currentEpisodeId = null;
    state = const PlaybackState.idle();
    ref.read(nowPlayingControllerProvider.notifier).clear();
  }

  /// Forcibly syncs the controller's [PlaybackState] to paused.
  ///
  /// Used only by the interruption wiring in `AudiflowAudioHandler`. On
  /// iOS, `_player.pause()` during an OS-initiated interruption does not
  /// always flip just_audio's internal `playing` flag, so
  /// `playerStateStream` never emits a transition and the UI would stay
  /// in [PlaybackPlaying]. This bypasses the stream to guarantee UI sync.
  ///
  /// Scoped to the interruption path on purpose: the common pause
  /// callers (user tap, becomingNoisy, voice command, lock screen) do
  /// not have this problem because the session is still active.
  void markPausedByInterruption() {
    final url = _currentUrl;
    if (url == null) return;
    state = PlaybackState.paused(episodeUrl: url);
  }

  /// Counterpart to [markPausedByInterruption] used after
  /// [AudiflowAudioHandler]'s resume path completes the
  /// `setActive(true)` + seek-reprime + `play()` sequence. Belt-and-
  /// suspenders in case just_audio fails to emit the transition.
  void markPlayingByInterruption() {
    final url = _currentUrl;
    if (url == null) return;
    state = PlaybackState.playing(episodeUrl: url);
  }

  /// Returns the URL of the currently loaded audio, if any.
  String? get currentUrl => _currentUrl;

  /// Returns the episode ID of the currently loaded audio, if any.
  int? get currentEpisodeId => _currentEpisodeId;

  /// Returns true if the specified URL is currently playing.
  bool isPlaying(String url) {
    return state.maybeWhen(
      playing: (episodeUrl) => episodeUrl == url,
      orElse: () => false,
    );
  }

  /// Returns true if the specified URL is currently loaded (playing or paused).
  bool isLoaded(String url) {
    return _currentUrl == url;
  }

  /// Seeks to the specified position.
  ///
  /// Clamps position between zero and duration to prevent invalid seeks.
  /// No-op if no audio is loaded. If the duration has not resolved yet
  /// (common transient state right after loading a remote source), waits
  /// briefly for [durationStream] to publish before giving up.
  @override
  Future<void> seek(Duration position) async {
    if (_currentUrl == null) return;
    final duration = _player.duration ?? await _awaitDuration();
    if (duration == null) return;

    final clampedMs = position.inMilliseconds.clamp(0, duration.inMilliseconds);
    await _player.seek(Duration(milliseconds: clampedMs));
    _lifecycleEvents.add(SeekLifecycle(Duration(milliseconds: clampedMs)));
  }

  /// Skips forward by the user-configured duration.
  ///
  /// Clamped to duration if near the end.
  @override
  Future<void> skipForward() async {
    if (_currentUrl == null) return;
    final settingsRepo = ref.read(appSettingsRepositoryProvider);
    final seconds = settingsRepo.getSkipForwardSeconds();
    await seek(_player.position + Duration(seconds: seconds));
  }

  /// Skips backward by the user-configured duration.
  ///
  /// Clamped to zero if near the start.
  @override
  Future<void> skipBackward() async {
    if (_currentUrl == null) return;
    final settingsRepo = ref.read(appSettingsRepositoryProvider);
    final seconds = settingsRepo.getSkipBackwardSeconds();
    await seek(_player.position - Duration(seconds: seconds));
  }

  /// Sets the playback speed and persists it to settings.
  @override
  Future<void> setSpeed(double speed) async {
    await _player.setSpeed(speed);
    final settingsRepo = ref.read(appSettingsRepositoryProvider);
    await settingsRepo.setPlaybackSpeed(speed);
  }
}

/// Broadcast stream of player lifecycle events.
///
/// Consumers observe this for "what just happened" hints (sleep timer, etc.)
/// rather than polling player state.
///
/// Exposed as a plain [Provider] of [Stream] (not a [StreamProvider]) so
/// listeners can subscribe directly without the [AsyncValue] wrapper —
/// the controller's lifecycle stream is long-lived and already broadcast,
/// so materializing it through a stream provider only added friction.
final playerLifecycleEventsProvider = Provider<Stream<PlayerLifecycleEvent>>((
  ref,
) {
  final controller = ref.watch(audioPlayerControllerProvider.notifier);
  return controller.lifecycleEvents;
});
