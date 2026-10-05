import 'dart:async';

import 'package:audiflow_core/audiflow_core.dart';
import 'package:flutter/foundation.dart';

import 'package:just_audio/just_audio.dart';
import 'package:riverpod/riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:rxdart/rxdart.dart';

import 'package:logger/logger.dart';

import '../../../common/providers/logger_provider.dart';
import '../../download/services/download_service.dart';
import '../../feed/repositories/episode_repository_impl.dart';
import '../../monitoring/models/analytics_event.dart';
import '../../monitoring/providers/analytics_providers.dart';
import '../../queue/services/queue_service.dart';
import '../../settings/models/audio_settings.dart';
import '../../settings/models/audio_settings_scope.dart';
import '../../settings/models/playback_effects.dart';
import '../../settings/providers/playback_effects_settings_provider.dart';
import '../../settings/providers/playback_speed_settings_provider.dart';
import '../../settings/providers/podcast_audio_override_provider.dart';
import '../../settings/providers/settings_providers.dart';
import '../../subscription/repositories/subscription_repository_impl.dart';
import '../models/now_playing_info.dart';
import '../models/playback_progress.dart';
import '../models/playback_state.dart';
import '../repositories/playback_history_repository_impl.dart';
import 'audio_playback_controller.dart';
import 'effective_audio_settings_applier.dart';
import 'listen_session_tracker.dart';
import 'now_playing_controller.dart';
import 'playback_history_service.dart';
import 'player_lifecycle_events.dart';

part 'audio_player_service.g.dart';

/// Target gain of the voice boost effect in decibels.
///
/// Initial value; tune on a device so speech is clearly louder without
/// clipping.
const double voiceBoostTargetGainDb = 6.0;

/// Whether the player applies [PlaybackEffect]s on this platform.
///
/// just_audio implements silence skipping and audio effects only on
/// Android. Elsewhere the effects UI is hidden and stored effect values
/// are ignored.
@Riverpod(keepAlive: true)
bool audioEffectsSupported(Ref ref) =>
    defaultTargetPlatform == TargetPlatform.android;

/// The loudness effect behind voice boost, or null where effects are not
/// supported.
///
/// Created once for the player: just_audio attaches an effect to a
/// single player, and only when that player is constructed.
@Riverpod(keepAlive: true)
AndroidLoudnessEnhancer? voiceBoostEffect(Ref ref) {
  if (!ref.watch(audioEffectsSupportedProvider)) return null;
  final effect = AndroidLoudnessEnhancer();
  // The player is not connected yet, so this only stores the gain; it is
  // sent with the pipeline when the player connects.
  unawaited(effect.setTargetGain(voiceBoostTargetGainDb));
  return effect;
}

/// Provides a singleton [AudioPlayer] instance.
///
/// This provider is kept alive for the app's lifetime to maintain audio state
/// across navigation and screen changes.
@Riverpod(keepAlive: true)
AudioPlayer audioPlayer(Ref ref) {
  final voiceBoost = ref.watch(voiceBoostEffectProvider);
  // handleInterruptions must be false when using audio_service,
  // which manages the remote command center and audio session.
  final player = AudioPlayer(
    handleInterruptions: false,
    // Effects can only be attached here, at construction.
    audioPipeline: voiceBoost == null
        ? null
        : AudioPipeline(androidAudioEffects: [voiceBoost]),
  );
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
  bool _suppressNextAutoAdvance = false;
  PlaySource? _nextPlaySource;

  /// Episode id for which `episode_complete` has already been emitted in
  /// the current load. Prevents duplicate emits when just_audio briefly
  /// transitions to `ProcessingState.completed` during seeks near the
  /// end of an episode and then returns to `ready`. Cleared in [play]
  /// when a new episode is loaded.
  int? _lastCompletedAnalyticsEpisodeId;

  final ListenSessionTracker _listenSession = ListenSessionTracker();

  // While true, the player state stream must not open a listen segment:
  // play() moves the position (saved resume point) and speed before
  // playback really starts, and seek() closes/reopens explicitly.
  bool _isPreparingPlay = false;
  bool _isSeeking = false;

  // Pairs each seek announcement with its completion or failure report.
  int _lastSeekId = 0;

  // The play() still loading. A second play() of the same episode, such as
  // a repeated tap while a slow device stalls, joins it: another setUrl
  // would interrupt this load and fail both with "Loading interrupted".
  ({String url, Duration? startAt, Future<void> done})? _pendingPlay;

  // Bumped by every play() load and by stop(). An engine failure reported
  // after a newer attempt began belongs to the old attempt, even when both
  // attempts play the same URL, so it must not overwrite the newer state.
  int _playAttempt = 0;

  // Engine values requested through [applySpeed] or [applyAudioSettings]
  // and not yet applied by [_engineDrain]; null when nothing is pending.
  double? _targetSpeed;
  bool? _targetSkipSilence;
  bool? _targetVoiceBoost;
  Future<void>? _engineDrain;
  final StreamController<PlayerLifecycleEvent> _lifecycleEvents =
      StreamController<PlayerLifecycleEvent>.broadcast();

  /// Records the surface that initiated the next [play] call so the
  /// `episode_play_start` analytics emit can report the correct
  /// [PlaySource]. Consumed exactly once on the next emit; if a caller
  /// forgets to set it, the emit defaults to [PlaySource.unknown].
  void markPlaySource(PlaySource source) {
    _nextPlaySource = source;
  }

  /// Resolves the current podcast/episode IDs and titles for analytics
  /// emits, using the latest [NowPlayingInfo]. Returns null when the
  /// feed URL or GUID is missing so emitters can no-op cleanly.
  ///
  /// `podcastId` resolves to the raw iTunes ID when available
  /// (non-OPML import), else the hashed feed key. `episodeId` is the raw RSS
  /// guid. Titles come straight from `NowPlayingInfo`; truncation to
  /// GA's 100-char param limit happens at the event boundary.
  EpisodeAnalyticsIds? _currentAnalyticsIds() {
    final info = ref.read(nowPlayingControllerProvider);
    if (info == null) {
      _log.w('[Analytics] ids: NowPlayingInfo null');
      return null;
    }
    final guid = info.episodeGuid;
    if (guid == null || guid.isEmpty) {
      _log.w('[Analytics] ids: missing guid');
      return null;
    }
    final podcastId = analyticsPodcastId(
      itunesId: info.itunesId,
      feedUrl: info.feedUrl,
    );
    if (podcastId == null) {
      _log.w(
        '[Analytics] ids: no podcastId source — '
        'itunesId=${info.itunesId} feedUrl=${info.feedUrl}',
      );
      return null;
    }
    return (
      podcastId: podcastId,
      feedUrl: info.feedUrl,
      episodeId: guid,
      podcastTitle: info.podcastTitle,
      episodeTitle: info.episodeTitle,
    );
  }

  /// Opens a listen segment at the current position unless one is
  /// already open or play()/seek() is mid-flight. [ids] overrides the
  /// [NowPlayingInfo]-derived identity (play() may run without metadata,
  /// leaving [NowPlayingInfo] on the previous episode).
  void _openListenSession({EpisodeAnalyticsIds? ids}) {
    if (_isPreparingPlay || _isSeeking || _listenSession.isOpen) return;
    final resolved = ids ?? _currentAnalyticsIds();
    if (resolved == null) return;
    _listenSession.open(
      ids: resolved,
      positionSec: _player.position.inSeconds,
      speed: _player.speed,
    );
  }

  /// Closes the open listen segment (if any) and emits it. [position]
  /// overrides the live player position for callers that captured it
  /// before moving the playhead.
  void _closeListenSession(ListenEndReason reason, {Duration? position}) {
    final session = _listenSession.close(
      positionSec: (position ?? _player.position).inSeconds,
      durationSec: _player.duration?.inSeconds ?? 0,
      reason: reason,
    );
    if (session == null) return;
    unawaited(ref.read(analyticsServiceProvider).log(session));
  }

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
          _closeListenSession(ListenEndReason.complete);

          // Emit `episode_complete` exactly once per episode load.
          // just_audio can transiently report `completed` during seeks
          // near the end of a track and then return to `ready`; dedup
          // by `_currentEpisodeId` so those false transitions do not
          // double-fire the analytics event.
          if (_currentEpisodeId != null &&
              _currentEpisodeId != _lastCompletedAnalyticsEpisodeId) {
            _lastCompletedAnalyticsEpisodeId = _currentEpisodeId;
            final ids = _currentAnalyticsIds();
            if (ids != null) {
              final durationSec = _player.duration?.inSeconds ?? 0;
              unawaited(
                ref
                    .read(analyticsServiceProvider)
                    .log(
                      EpisodeCompleted(
                        podcastId: ids.podcastId,
                        feedUrl: ids.feedUrl,
                        episodeId: ids.episodeId,
                        podcastTitle: ids.podcastTitle,
                        episodeTitle: ids.episodeTitle,
                        durationSec: durationSec,
                        speed: _player.speed,
                      ),
                    ),
              );
            }
          }

          _lifecycleEvents.add(const EpisodeCompletedLifecycle());
          // Save final progress before clearing.
          // Yielding here drains microtasks, letting the sleep timer
          // observe EpisodeCompletedLifecycle and call
          // suppressNextAutoAdvance() before we decide whether to advance.
          await _saveProgressOnStop();

          if (_suppressNextAutoAdvance) {
            _suppressNextAutoAdvance = false;
            _log.i(
              '[StateStream] Auto-advance suppressed by sleep timer; '
              'pausing at episode end',
            );
            state = PlaybackState.paused(episodeUrl: url);
            return;
          }

          // Try to auto-play next from queue
          await _handlePlaybackComplete();
          _log.i('[StateStream] _handlePlaybackComplete finished');
        } else if (processingState == ProcessingState.loading ||
            processingState == ProcessingState.buffering) {
          state = PlaybackState.loading(episodeUrl: url);
        } else if (playing) {
          // The stream (not pause()/resume()) drives segment open/close so
          // fade-out, OS interruptions, and lock-screen controls that call
          // just_audio directly are covered too.
          _openListenSession();
          state = PlaybackState.playing(episodeUrl: url);
        } else {
          _log.d('[StateStream] paused (processing=$processingState)');
          _closeListenSession(ListenEndReason.pause);
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

        // Auto-play next episode. Tag the surface as queue so the
        // `episode_play_start` emit reports PlaySource.queue rather
        // than unknown.
        markPlaySource(PlaySource.queue);
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
            episode: nextEpisode,
            itunesId: subscription?.itunesId,
            episodeGuid: nextEpisode.guid,
            feedUrl: subscription?.feedUrl,
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
  Future<void> play(String url, {NowPlayingInfo? metadata, Duration? startAt}) {
    final pending = _pendingPlay;
    if (pending != null && pending.url == url && pending.startAt == startAt) {
      return pending.done;
    }
    final done = _loadAndPlay(url, metadata: metadata, startAt: startAt);
    _pendingPlay = (url: url, startAt: startAt, done: done);
    return done.whenComplete(() {
      if (identical(_pendingPlay?.done, done)) _pendingPlay = null;
    });
  }

  Future<void> _loadAndPlay(
    String url, {
    NowPlayingInfo? metadata,
    Duration? startAt,
  }) async {
    final attempt = ++_playAttempt;
    _isPreparingPlay = true;
    try {
      _log.i('[Play] Starting: url=$url');
      _closeListenSession(ListenEndReason.switchEpisode);

      // A restored episode has no audio loaded yet, but leaving it for
      // another one is still a switch.
      final previousUrl =
          _currentUrl ?? ref.read(nowPlayingControllerProvider)?.episodeUrl;
      if (previousUrl != null && previousUrl != url) {
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
        // Reset the `episode_complete` dedup so the new episode can emit
        // its own completion. Without this, a re-play of the same
        // episode id within one app session would never re-emit.
        if (_lastCompletedAnalyticsEpisodeId != episode?.id) {
          _lastCompletedAnalyticsEpisodeId = null;
        }
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
        final seekId = _announceSeek(Duration(milliseconds: clampedMs));
        await _seekPlayer(Duration(milliseconds: clampedMs), seekId: seekId);
        _lifecycleEvents.add(
          SeekLifecycle(Duration(milliseconds: clampedMs), seekId: seekId),
        );
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
            final target = Duration(milliseconds: history.positionMs);
            final seekId = _announceSeek(target, automatic: true);
            await _seekPlayer(target, seekId: seekId);
            _lifecycleEvents.add(SeekLifecycle(target, seekId: seekId));
          }
        }
      }

      // Apply the episode's podcast override, or the global settings.
      // Resolve the podcast the way NowPlayingInfo exposes it, so this
      // agrees with effectiveAudioSettingsApplier and the Audio button.
      final settings = await _resolveSettings(
        metadata?.episode?.podcastId ?? episode?.podcastId,
      );
      final speed = settings.speed;
      // A newer play() may have started while the override loaded; its
      // own resolution owns the settings now.
      if (_currentUrl == url) await applyAudioSettings(settings);

      // Notify history service of playback start
      if (_currentEpisodeId != null) {
        final historyService = ref.read(playbackHistoryServiceProvider);
        await historyService.onPlaybackStarted(
          _currentEpisodeId!,
          _player.position.inMilliseconds,
        );
      }

      // Emit `episode_play_start` once per initial play(url, ...) call.
      // Resume after pause goes through resume() and does NOT re-emit —
      // the spec defines this event as the start of an episode, not the
      // restart of playback. Prefer the explicit metadata when supplied;
      // fall back to the resolved Isar episode for the GUID.
      //
      // IMPORTANT: emit BEFORE awaiting `_player.play()`. just_audio's
      // `play()` future does not complete until playback stops/pauses,
      // so any analytics emit placed after the await would be deferred
      // until the user pauses (and would also race the `episode_pause`
      // emit at that boundary).
      String? feedUrlForEmit = metadata?.feedUrl;
      final guidForEmit = metadata?.episodeGuid ?? episode?.guid;
      final itunesIdForEmit = metadata?.itunesId;
      String? podcastTitleForEmit = metadata?.podcastTitle;

      // Fall back to the subscription record when the caller did not pass
      // full metadata. Older episodes / non-detail entry points may omit
      // feedUrl + iTunes ID, but the subscription always has both.
      if ((feedUrlForEmit == null || feedUrlForEmit.isEmpty) &&
          episode != null) {
        final sub = await ref
            .read(subscriptionRepositoryProvider)
            .getById(episode.podcastId);
        feedUrlForEmit ??= sub?.feedUrl;
        podcastTitleForEmit ??= sub?.title;
      }

      final podcastIdForEmit = analyticsPodcastId(
        itunesId: itunesIdForEmit,
        feedUrl: feedUrlForEmit,
      );

      EpisodeAnalyticsIds? playIds;
      if (podcastIdForEmit == null ||
          guidForEmit == null ||
          guidForEmit.isEmpty) {
        _log.w(
          '[Analytics] episode_play_start SKIP — '
          'itunesId=$itunesIdForEmit feedUrl=$feedUrlForEmit guid=$guidForEmit',
        );
      } else {
        playIds = (
          podcastId: podcastIdForEmit,
          feedUrl: feedUrlForEmit,
          episodeId: guidForEmit,
          podcastTitle: podcastTitleForEmit ?? '',
          episodeTitle: metadata?.episodeTitle ?? episode?.title ?? '',
        );
        final source = _nextPlaySource ?? PlaySource.unknown;
        _nextPlaySource = null;
        unawaited(
          ref
              .read(analyticsServiceProvider)
              .log(
                EpisodePlayStarted(
                  podcastId: playIds.podcastId,
                  feedUrl: playIds.feedUrl,
                  episodeId: playIds.episodeId,
                  podcastTitle: playIds.podcastTitle,
                  episodeTitle: playIds.episodeTitle,
                  source: source,
                  speed: speed,
                ),
              ),
        );
      }

      // Open explicitly: when switching from an episode that was already
      // playing, just_audio keeps `playing == true` across setUrl, so the
      // state stream may never report a fresh playing transition.
      _isPreparingPlay = false;
      _openListenSession(ids: playIds);

      _log.d('[Play] Calling _player.play()...');
      // Fire-and-forget: just_audio's `play()` future completes when
      // playback stops/pauses, not when it starts. Awaiting it would
      // pin this method until the next pause and defer any work below.
      _startEngine();
      _log.i('[Play] _player.play() dispatched');
    } catch (e, stack) {
      _log.e('[Play] ERROR', error: e, stackTrace: stack);
      // A newer play() or stop() interrupted this load and owns the state.
      if (_playAttempt != attempt) return;
      state = PlaybackState.error(message: 'Failed to play audio: $e');
    } finally {
      _isPreparingPlay = false;
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

  /// Marks the next [ProcessingState.completed] transition to skip the
  /// queue auto-advance.
  ///
  /// Called by the sleep timer when firing for end-of-episode triggers so
  /// the player stops at the current episode's end instead of starting and
  /// fading out the next one. Consumed exactly once.
  void suppressNextAutoAdvance() {
    _suppressNextAutoAdvance = true;
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
    // Capture position before delegating so a racing seek cannot move
    // the reported position out from under the analytics emit.
    final positionSec = _player.position.inSeconds;
    await _player.pause();

    final ids = _currentAnalyticsIds();
    if (ids != null) {
      unawaited(
        ref
            .read(analyticsServiceProvider)
            .log(
              EpisodePaused(
                podcastId: ids.podcastId,
                feedUrl: ids.feedUrl,
                episodeId: ids.episodeId,
                podcastTitle: ids.podcastTitle,
                episodeTitle: ids.episodeTitle,
                positionSec: positionSec,
              ),
            ),
      );
    }
  }

  /// Pauses, then moves to [position] on the player's own account and
  /// saves it as the resume point.
  ///
  /// Used by the end-of-chapter sleep timer, which notices a chapter
  /// boundary only after playback has crossed it. Pausing first keeps the
  /// next chapter from being heard while the seek runs; the explicit save
  /// afterwards replaces the position [pause] recorded just past the
  /// boundary, because a seek while paused is not saved on its own.
  Future<void> pauseAt(Duration position) async {
    await pause();
    final episodeId = _currentEpisodeId;
    if (_currentUrl == null || episodeId == null) return;
    final target = _clampToKnownDuration(position, _player.duration);
    await seekAutomatically(target);
    // A play() of another episode during the seek owns the history now.
    if (_currentEpisodeId != episodeId) return;
    await ref
        .read(playbackHistoryRepositoryProvider)
        .saveProgress(episodeId: episodeId, positionMs: target.inMilliseconds);
  }

  /// Resumes playback if paused.
  ///
  /// No-op when no audio source is loaded (e.g. after app restart before
  /// the user taps play on an episode).
  @override
  Future<void> resume() async {
    if (_currentUrl == null) return;
    ref.read(playbackHistoryServiceProvider).onPlaybackResumed();
    // Emit BEFORE dispatching `_player.play()`. just_audio's `play()`
    // future does not complete until playback stops/pauses, so awaiting
    // it would defer the `episode_resume` emit until the next pause and
    // race it against `episode_pause`.
    final ids = _currentAnalyticsIds();
    if (ids != null) {
      unawaited(
        ref
            .read(analyticsServiceProvider)
            .log(
              EpisodeResumed(
                podcastId: ids.podcastId,
                feedUrl: ids.feedUrl,
                episodeId: ids.episodeId,
                podcastTitle: ids.podcastTitle,
                episodeTitle: ids.episodeTitle,
                positionSec: _player.position.inSeconds,
              ),
            ),
      );
    }
    _startEngine();
  }

  // just_audio's play() future lasts until playback stops, so nothing awaits
  // it, and it fails when the load behind it is interrupted ("Loading
  // interrupted"). Handled here so the failure shows instead of escaping as
  // an unhandled error. A newer play() or a stop() owns the state from then
  // on, so a late failure of this attempt is only logged.
  void _startEngine() {
    final url = _currentUrl;
    final attempt = _playAttempt;
    unawaited(
      _player.play().onError((error, stackTrace) {
        _log.e(
          '[Play] Engine play failed',
          error: error,
          stackTrace: stackTrace,
        );
        if (_playAttempt != attempt || _currentUrl != url) return;
        state = PlaybackState.error(message: 'Failed to play audio: $error');
      }),
    );
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
    // Cleared before any await: a play() right after stop() must start its
    // own load, not join the one this stop interrupts.
    _pendingPlay = null;
    final attempt = ++_playAttempt;
    _closeListenSession(ListenEndReason.stop);
    // Save final progress before stopping
    await _saveProgressOnStop();
    // A play() that began while this stop awaited owns the player now;
    // stopping or clearing would cancel it.
    if (_playAttempt != attempt) return;

    await _player.stop();
    if (_playAttempt != attempt) return;
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
    // The state stream may never see this pause either, so the listen
    // segment has to be closed here too.
    _closeListenSession(ListenEndReason.pause);
    state = PlaybackState.paused(episodeUrl: url);
  }

  /// Counterpart to [markPausedByInterruption] used after
  /// [AudiflowAudioHandler]'s resume path completes the
  /// `setActive(true)` + seek-reprime + `play()` sequence. Belt-and-
  /// suspenders in case just_audio fails to emit the transition.
  void markPlayingByInterruption() {
    final url = _currentUrl;
    if (url == null) return;
    _openListenSession();
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

  /// Seeks the now-playing episode to [position].
  ///
  /// With audio loaded this seeks the player. After a restore, before any
  /// audio is loaded, it moves the saved position instead so the display
  /// reflects the seek and the next play() starts there.
  Future<void> seekNowPlaying(Duration position) async {
    if (currentUrl != null) return seek(position);
    await _saveSeekWithoutAudio(position);
  }

  Future<void> _saveSeekWithoutAudio(Duration position) async {
    final nowPlaying = ref.read(nowPlayingControllerProvider);
    if (nowPlaying == null) return;
    // Mirror seek()'s clamp so a chapter start past the end (bad feed data)
    // cannot become the resume position.
    final clamped = _clampToKnownDuration(position, nowPlaying.totalDuration);
    final seekId = _announceSeek(clamped);
    ref
        .read(nowPlayingControllerProvider.notifier)
        .setNowPlaying(nowPlaying.copyWith(savedPosition: clamped));
    _lifecycleEvents.add(SeekLifecycle(clamped, seekId: seekId));
    final episode = nowPlaying.episode;
    if (episode == null) return;
    // Persist so play() seeks to this position.
    await ref
        .read(playbackHistoryRepositoryProvider)
        .saveProgress(
          episodeId: episode.id,
          positionMs: clamped.inMilliseconds,
        );
  }

  // Announced before the position moves so a chapter change caused by the
  // jump is not mistaken for playback crossing a chapter boundary. Returns
  // the id the closing report must carry.
  int _announceSeek(Duration target, {bool automatic = false}) {
    _lastSeekId += 1;
    _lifecycleEvents.add(
      SeekStartedLifecycle(target, seekId: _lastSeekId, automatic: automatic),
    );
    return _lastSeekId;
  }

  // Closes an announced seek the player rejected, so listeners that moved
  // their state to the target can roll it back.
  Future<void> _seekPlayer(Duration target, {required int seekId}) async {
    try {
      await _player.seek(target);
    } on Object {
      _lifecycleEvents.add(
        SeekFailedLifecycle(_player.position, seekId: seekId),
      );
      rethrow;
    }
  }

  static Duration _clampToKnownDuration(Duration position, Duration? duration) {
    if (position.isNegative) return Duration.zero;
    // Zero means unknown, as elsewhere in the player.
    if (duration == null || duration == Duration.zero) return position;
    return duration < position ? duration : position;
  }

  /// Seeks to the specified position.
  ///
  /// Clamps position between zero and duration to prevent invalid seeks.
  /// No-op if no audio is loaded. If the duration has not resolved yet
  /// (common transient state right after loading a remote source), waits
  /// briefly for [durationStream] to publish before giving up.
  @override
  Future<void> seek(Duration position) => _seekLoaded(position);

  /// Seeks like [seek], on the player's own account rather than the
  /// listener's (a rewind after an audio interruption).
  ///
  /// Listeners that follow where the listener is, such as the
  /// end-of-chapter sleep timer, treat it as staying in place.
  Future<void> seekAutomatically(Duration position) =>
      _seekLoaded(position, automatic: true);

  Future<void> _seekLoaded(Duration position, {bool automatic = false}) async {
    if (_currentUrl == null) return;
    final duration = _player.duration ?? await _awaitDuration();
    if (duration == null) return;

    // Capture the from-position before the just_audio call moves it.
    final fromPosition = _player.position;
    final fromSec = fromPosition.inSeconds;
    final clampedMs = position.inMilliseconds.clamp(0, duration.inMilliseconds);

    // A seek ends the current segment so every session is one gap-free
    // range of content; the jump itself is what "skipped" analysis reads.
    final segmentIds = _listenSession.openIds;
    _closeListenSession(ListenEndReason.seek, position: fromPosition);
    final seekId = _announceSeek(
      Duration(milliseconds: clampedMs),
      automatic: automatic,
    );
    _isSeeking = true;
    try {
      await _seekPlayer(Duration(milliseconds: clampedMs), seekId: seekId);
    } finally {
      _isSeeking = false;
    }
    if (_player.playing) _openListenSession(ids: segmentIds);
    _lifecycleEvents.add(
      SeekLifecycle(Duration(milliseconds: clampedMs), seekId: seekId),
    );

    final ids = _currentAnalyticsIds();
    if (ids != null) {
      unawaited(
        ref
            .read(analyticsServiceProvider)
            .log(
              EpisodeSeeked(
                podcastId: ids.podcastId,
                feedUrl: ids.feedUrl,
                episodeId: ids.episodeId,
                podcastTitle: ids.podcastTitle,
                episodeTitle: ids.episodeTitle,
                fromSec: fromSec,
                toSec: Duration(milliseconds: clampedMs).inSeconds,
              ),
            ),
      );
    }
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

  /// Persists [speed] to [scope] and applies it to the player when
  /// [scope] is the one the now-playing podcast resolves to.
  ///
  /// [speed] is snapped to [PlaybackSpeedScale.steps]. Editing the global
  /// scope while the now-playing podcast has an override persists the
  /// global value without touching the player, and a podcast scope with
  /// no override is ignored rather than creating one. Pass [transient]
  /// for intermediate slider steps during a drag: the speed is applied
  /// and held in memory, but not persisted, recorded as a recent speed,
  /// or reported to analytics. The final value of the gesture must then
  /// be committed with a non-transient call.
  ///
  /// Committed speeds are recorded in the shared recent-speed list
  /// whichever scope they were saved to.
  Future<void> setSpeed(
    double speed, {
    required AudioSettingsScope scope,
    bool transient = false,
  }) async {
    final snapped = PlaybackSpeedScale.snap(speed);
    // Start saving before awaiting the engine: saving updates the speed
    // state synchronously, so speed controls follow a fast slider drag
    // instead of trailing behind queued engine calls.
    final saved = _saveSpeed(scope, snapped, transient: transient);
    // A failed save must not surface as an unhandled error while the
    // engine call is awaited; it is still rethrown by `await saved` below.
    saved.ignore();
    if (ref.read(nowPlayingAudioSettingsProvider)?.scope == scope) {
      await applySpeed(snapped);
    }
    if (!await saved || transient) return;
    unawaited(
      ref
          .read(analyticsServiceProvider)
          .log(PlaybackSpeedChanged(speed: snapped)),
    );
  }

  /// Returns false when nothing was saved.
  Future<bool> _saveSpeed(
    AudioSettingsScope scope,
    double speed, {
    required bool transient,
  }) async {
    final global = ref.read(playbackSpeedSettingsControllerProvider.notifier);
    switch (scope) {
      case GlobalAudioSettingsScope():
        await global.save(speed, commit: !transient);
      case PodcastAudioSettingsScope(:final podcastId):
        final override = ref.read(
          podcastAudioOverrideControllerProvider(podcastId).notifier,
        );
        // The override was switched off under a pending edit: drop the
        // edit rather than recording a speed nothing saved.
        if (!override.hasOverride) return false;
        // Record only once the write succeeded: a failed write rolls the
        // override back, and the chip must not offer a speed never saved.
        await override.saveSpeed(speed, persist: !transient);
        if (!transient) await global.recordRecent(speed);
    }
    return true;
  }

  /// Persists [effect] to [scope] and applies it to the player when
  /// [scope] is the one the now-playing podcast resolves to.
  ///
  /// Mirrors [setSpeed]: a podcast scope with no override is ignored
  /// rather than creating one. The value is stored on every platform but
  /// reaches the player only where `audioEffectsSupportedProvider` is
  /// true.
  Future<void> setEffect(
    PlaybackEffect effect, {
    required bool enabled,
    required AudioSettingsScope scope,
  }) async {
    switch (scope) {
      case GlobalAudioSettingsScope():
        await ref
            .read(playbackEffectsSettingsControllerProvider.notifier)
            .save(effect, enabled: enabled);
      case PodcastAudioSettingsScope(:final podcastId):
        await ref
            .read(podcastAudioOverrideControllerProvider(podcastId).notifier)
            .saveEffect(effect, enabled: enabled);
    }
    final now = ref.read(nowPlayingAudioSettingsProvider);
    if (now?.scope == scope) await applyAudioSettings(now!.settings);
  }

  /// Applies [speed] to the player without persisting it anywhere.
  ///
  /// Settings changes reach the player through [setSpeed], [setEffect],
  /// `effectiveAudioSettingsApplierProvider`, and [play]; this and
  /// [applyAudioSettings] are their single engine step. It is idempotent
  /// and serialized: a value equal to the one already applied or pending
  /// is a no-op, at most one engine call runs at a time, and requests made
  /// while one runs collapse into the latest. Both setSpeed and the
  /// applier request the same change, so without this every slider step
  /// would reach the engine twice, with the calls overlapping on the
  /// platform channel.
  Future<void> applySpeed(double speed) {
    _requestSpeed(speed);
    return _drainEngineIfPending();
  }

  /// Applies the speed and effects of [settings] through the same
  /// serialized, idempotent path as [applySpeed].
  ///
  /// Effects are skipped where `audioEffectsSupportedProvider` is false,
  /// so stored values never reach an engine that does not implement them.
  Future<void> applyAudioSettings(AudioSettings settings) {
    _requestSpeed(settings.speed);
    _requestEffects(settings.effects);
    return _drainEngineIfPending();
  }

  void _requestSpeed(double speed) {
    final snapped = PlaybackSpeedScale.snap(speed);
    if (snapped != (_targetSpeed ?? _player.speed)) _targetSpeed = snapped;
  }

  void _requestEffects(PlaybackEffects effects) {
    if (!ref.read(audioEffectsSupportedProvider)) return;
    final skipSilence = effects.skipSilence;
    if (skipSilence != (_targetSkipSilence ?? _player.skipSilenceEnabled)) {
      _targetSkipSilence = skipSilence;
    }
    final voiceBoost = ref.read(voiceBoostEffectProvider);
    if (voiceBoost == null) return;
    if (effects.voiceBoost != (_targetVoiceBoost ?? voiceBoost.enabled)) {
      _targetVoiceBoost = effects.voiceBoost;
    }
  }

  bool get _hasEngineTarget =>
      _targetSpeed != null ||
      _targetSkipSilence != null ||
      _targetVoiceBoost != null;

  Future<void> _drainEngineIfPending() {
    final pending = _engineDrain;
    if (pending != null) return pending;
    if (!_hasEngineTarget) return Future<void>.value();
    // The drain always awaits before finishing, so it is still running
    // when stored here.
    return _engineDrain = _drainEngine();
  }

  Future<void> _drainEngine() async {
    // A failed engine call must not drop a newer pending request, so the
    // loop keeps going. A failure is reported unless a newer request for
    // the same setting replaced it; another setting succeeding later does
    // not clear it.
    final steps = [
      _applyTargetSpeed,
      _applyTargetSkipSilence,
      _applyTargetVoiceBoost,
    ];
    final failures = <int, (Object, StackTrace)>{};
    try {
      // Each pass consumes the targets, so the loop is bounded by the
      // requests made while it runs, even when the engine ignores a call
      // (a disposed player does not update its values).
      while (_hasEngineTarget) {
        for (final (index, step) in steps.indexed) {
          try {
            if (await step()) failures.remove(index);
          } catch (error, stackTrace) {
            failures[index] = (error, stackTrace);
          }
        }
      }
      final failure = failures.values.firstOrNull;
      if (failure != null) Error.throwWithStackTrace(failure.$1, failure.$2);
    } finally {
      _targetSpeed = null;
      _targetSkipSilence = null;
      _targetVoiceBoost = null;
      _engineDrain = null;
    }
  }

  // Each step takes its target only when it runs. Taking every target at
  // the start of a pass would lose a request made while an earlier step
  // awaits: the request is compared against the engine value, which the
  // queued step has not changed yet. The engine values update before the
  // platform call is awaited, so a request made during a step's own call
  // is compared correctly. Each returns whether it took a target, which
  // supersedes an earlier failure of the same setting.
  Future<bool> _applyTargetSpeed() async {
    final speed = _targetSpeed;
    _targetSpeed = null;
    if (speed == null) return false;
    if (speed != _player.speed) await _applyToEngine(speed);
    return true;
  }

  Future<bool> _applyTargetSkipSilence() async {
    final enabled = _targetSkipSilence;
    _targetSkipSilence = null;
    if (enabled == null) return false;
    await _player.setSkipSilenceEnabled(enabled);
    return true;
  }

  Future<bool> _applyTargetVoiceBoost() async {
    final enabled = _targetVoiceBoost;
    _targetVoiceBoost = null;
    if (enabled == null) return false;
    final effect = ref.read(voiceBoostEffectProvider);
    if (effect != null && effect.enabled != enabled) {
      await effect.setEnabled(enabled);
    }
    return true;
  }

  Future<void> _applyToEngine(double speed) async {
    // Split the segment so each session has a single speed.
    final segmentIds = _listenSession.openIds;
    if (segmentIds != null) _closeListenSession(ListenEndReason.speedChange);
    try {
      await _player.setSpeed(speed);
    } finally {
      // Reopen even when the engine rejected the speed, since playback
      // continues. Playback may have paused while the engine applied the
      // speed; the stream has then already closed the segment and must
      // not reopen it.
      if (segmentIds != null && _player.playing) {
        _openListenSession(ids: segmentIds);
      }
    }
  }

  /// Resolves through the same in-memory state the Audio sheet edits
  /// (rather than reading the database) so playback never starts with
  /// settings the UI does not show.
  Future<AudioSettings> _resolveSettings(int? podcastId) async {
    final global = AudioSettings(
      speed: ref.read(playbackSpeedSettingsControllerProvider).speed,
      effects: ref.read(playbackEffectsSettingsControllerProvider),
    );
    if (podcastId == null) return global;
    try {
      final override = await ref.read(
        podcastAudioOverrideControllerProvider(podcastId).future,
      );
      return override ?? global;
    } catch (error) {
      // Same fallback as effectiveAudioSettingsProvider on a failed load.
      _log.w('[Play] Override load failed, using global settings: $error');
      return global;
    }
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
