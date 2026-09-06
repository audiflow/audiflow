import 'dart:async';

import 'package:audio_service/audio_service.dart' as audio_service;
import 'package:audio_session/audio_session.dart';
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:logger/logger.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import 'audio_interruption_handler.dart';
import 'now_playing_artwork_provider.dart';
import 'now_playing_media_item_sync.dart';

final _log = Logger(printer: PrefixPrinter(PrettyPrinter(methodCount: 0)));

/// Volume applied while ducking; matches the common platform convention
/// of roughly halving output while another short sound plays.
const double _duckedVolume = 0.3;

/// Full-volume level restored after a duck ends.
const double _fullVolume = 1.0;

/// Audio handler that bridges platform media controls to the app's
/// existing playback infrastructure.
///
/// Uses the official audio_service pattern: pipes just_audio's
/// [PlaybackEvent] stream directly into [playbackState] for reliable
/// platform media control sync (lock screen, control center).
///
/// Delegates all playback actions to [AudioPlayerController].
class AudiflowAudioHandler extends audio_service.BaseAudioHandler
    with audio_service.SeekHandler {
  AudiflowAudioHandler(this._ref) {
    _log.i('[AudioHandler] Initializing AudiflowAudioHandler');
    _player = _ref.read(audioPlayerProvider);
    _sessionReady = _configureAudioSession();
    _pipePlaybackState();
  }

  final Ref _ref;
  late final AudioPlayer _player;

  /// Publishes now-playing metadata and its downscaled artwork to
  /// [mediaItem]; see [NowPlayingMediaItemSync].
  late final NowPlayingMediaItemSync _nowPlayingSync = NowPlayingMediaItemSync(
    readCurrent: () => mediaItem.valueOrNull,
    publish: mediaItem.add,
    artworkPreparer: _ref.read(nowPlayingArtworkPreparerProvider),
  );

  /// Completes when the audio session is configured and listeners are active.
  late final Future<void> _sessionReady;

  AudioPlayerController get _controller =>
      _ref.read(audioPlayerControllerProvider.notifier);

  AppSettingsRepository get _settings =>
      _ref.read(appSettingsRepositoryProvider);

  /// Handles interruption begin/end decisions. Lazily built so tests may
  /// override the internal callbacks; see [AudioInterruptionHandler].
  late final AudioInterruptionHandler _interruptionHandler =
      AudioInterruptionHandler(
        // Re-resolve the repository on every call so a provider
        // invalidation cannot leave the handler holding a stale
        // method tear-off from an old repository instance.
        readDuckBehavior: () => _settings.getDuckInterruptionBehavior(),
        isPlaying: () => _player.playing,
        currentPosition: () => _player.position,
        seek: _controller.seek,
        pause: () async {
          await _controller.pause();
          // just_audio's internal `playing` flag does not flip during
          // an iOS OS-initiated interruption, so we force the in-app
          // UI state and the platform media-control state here. See
          // `docs/architecture/playback-pipeline.md`.
          _controller.markPausedByInterruption();
          _publishInterruptionPausedPlaybackState();
        },
        resume: () async {
          final session = await AudioSession.instance;
          await _reactivateAndResume(session);
        },
        setVolume: _player.setVolume,
        duckedVolume: _duckedVolume,
        fullVolume: _fullVolume,
        onDiagnostic: _emitInterruptionDiagnostic,
      );

  /// Bridges [AudioInterruptionHandler] decision points into the logger and
  /// Sentry so a real-device phone-call reproduction produces a structured
  /// trail (breadcrumbs + a captureMessage at the pause commit). Remove
  /// alongside the interruption investigation when it concludes.
  void _emitInterruptionDiagnostic(String event, Map<String, Object?> data) {
    _log.i('[Interruption] $event data=$data');
    Sentry.addBreadcrumb(
      Breadcrumb(message: event, category: 'player.interruption', data: data),
    );
    // Capture the post-pause state and the long-call resume outcomes
    // (success bail-out vs. unexpected failure) so the on-device session
    // surfaces without needing a crash.
    if (event == 'player.interruption:begin-paused' ||
        event == 'player.interruption:begin-pause-failed' ||
        event == 'player.interruption:resume-skipped-session-busy' ||
        event == 'player.interruption:resume-failed') {
      unawaited(
        Sentry.captureMessage(
          event,
          level: SentryLevel.info,
          withScope: (scope) =>
              scope.setContexts('player_interruption', {...data}),
        ),
      );
    }
  }

  /// Forwards just_audio's playbackEventStream to audio_service's
  /// playbackState BehaviorSubject.
  ///
  /// We use `listen(...add)` instead of `.pipe(...)` so the interruption
  /// wiring can also emit manual updates (see
  /// [_publishInterruptionPausedPlaybackState] and
  /// [_publishInterruptionPlayingPlaybackState]) on iOS paths where
  /// just_audio's own `playing` flag fails to flip and no event is
  /// produced.
  void _pipePlaybackState() {
    _player.playbackEventStream.map(_transformEvent).listen(playbackState.add);
    // `episode_complete` analytics emit lives in
    // `AudioPlayerController._playerStateListener`'s
    // `ProcessingState.completed` branch — owned by the controller so
    // emit + state cleanup are sequenced (no race with nowPlaying
    // clear) and dedup'd against transient just_audio
    // ProcessingState.completed transitions during near-end seeks.
  }

  /// Publishes a `paused` platform playback state that mirrors what
  /// [_transformEvent] would emit if just_audio had produced a real
  /// pause event. Used by the iOS interruption path where the library's
  /// `playing` flag stays stuck at `true` after `_player.pause()`.
  void _publishInterruptionPausedPlaybackState() {
    playbackState.add(_interruptionPlaybackState(playing: false));
  }

  /// Counterpart to [_publishInterruptionPausedPlaybackState] for the
  /// resume path, used only after we've confirmed the player is actually
  /// playing and ready.
  void _publishInterruptionPlayingPlaybackState() {
    playbackState.add(_interruptionPlaybackState(playing: true));
  }

  /// Builds a platform [audio_service.PlaybackState] with an overridden
  /// `playing` flag. All other fields are read from the live player so
  /// the lock screen / Control Center position and speed remain accurate.
  audio_service.PlaybackState _interruptionPlaybackState({
    required bool playing,
  }) {
    return _buildPlaybackState(
      playing: playing,
      queueIndex: playbackState.valueOrNull?.queueIndex,
    );
  }

  audio_service.PlaybackState _transformEvent(PlaybackEvent event) {
    return _buildPlaybackState(
      playing: _player.playing,
      queueIndex: event.currentIndex,
    );
  }

  /// Shared builder for platform playback state snapshots. Centralises
  /// the control set, processing-state mapping, and read-through fields
  /// so the natural event pipe and the interruption overrides can never
  /// drift.
  audio_service.PlaybackState _buildPlaybackState({
    required bool playing,
    required int? queueIndex,
  }) {
    return audio_service.PlaybackState(
      controls: [
        audio_service.MediaControl.skipToPrevious,
        audio_service.MediaControl.rewind,
        if (playing)
          audio_service.MediaControl.pause
        else
          audio_service.MediaControl.play,
        audio_service.MediaControl.fastForward,
        audio_service.MediaControl.skipToNext,
        audio_service.MediaControl.stop,
      ],
      systemActions: const {
        audio_service.MediaAction.seek,
        audio_service.MediaAction.seekForward,
        audio_service.MediaAction.seekBackward,
      },
      androidCompactActionIndices: const [0, 2, 4],
      processingState: switch (_player.processingState) {
        ProcessingState.idle => audio_service.AudioProcessingState.idle,
        ProcessingState.loading => audio_service.AudioProcessingState.loading,
        ProcessingState.buffering =>
          audio_service.AudioProcessingState.buffering,
        ProcessingState.ready => audio_service.AudioProcessingState.ready,
        ProcessingState.completed =>
          audio_service.AudioProcessingState.completed,
      },
      playing: playing,
      updatePosition: _player.position,
      bufferedPosition: _player.bufferedPosition,
      speed: _player.speed,
      queueIndex: queueIndex,
    );
  }

  Future<void> _configureAudioSession() async {
    final session = await AudioSession.instance;
    // Extend speech() with route sharing and deactivation notification
    // so other audio apps resume gracefully when we stop.
    await session.configure(
      AudioSessionConfiguration.speech().copyWith(
        avAudioSessionRouteSharingPolicy:
            AVAudioSessionRouteSharingPolicy.defaultPolicy,
        avAudioSessionSetActiveOptions:
            AVAudioSessionSetActiveOptions.notifyOthersOnDeactivation,
      ),
    );

    session.interruptionEventStream.listen((event) {
      // Raw breadcrumb so we can verify the OS actually delivered the
      // interruption event (and with what type) independently of the
      // handler's branch choices. Remove with the rest of the
      // interruption investigation.
      _emitInterruptionDiagnostic('player.interruption:raw-event', {
        'begin': event.begin,
        'type': event.type.name,
        'isPlaying': _player.playing,
        'processingState': _player.processingState.name,
      });
      if (event.begin) {
        unawaited(
          _interruptionHandler.onBegin(event.type).catchError((
            Object e,
            StackTrace s,
          ) {
            _log.e(
              '[AudioHandler] Interruption begin handler failed',
              error: e,
              stackTrace: s,
            );
            unawaited(Sentry.captureException(e, stackTrace: s));
          }),
        );
      } else {
        unawaited(
          _interruptionHandler.onEnd(event.type).catchError((
            Object e,
            StackTrace s,
          ) {
            _log.e(
              '[AudioHandler] Interruption end handler failed',
              error: e,
              stackTrace: s,
            );
            unawaited(Sentry.captureException(e, stackTrace: s));
          }),
        );
      }
    });

    session.becomingNoisyEventStream.listen((_) {
      // Headphone disconnect ("becoming noisy"). pause() is async and
      // routes through the controller; capture failures so a stuck
      // mid-state-transition cannot silently leave audio blaring out
      // of the speaker.
      unawaited(
        pause().catchError((Object e, StackTrace s) {
          _log.e(
            '[AudioHandler] becomingNoisy pause failed',
            error: e,
            stackTrace: s,
          );
          unawaited(Sentry.captureException(e, stackTrace: s));
        }),
      );
    });
  }

  Future<void> _reactivateAndResume(AudioSession session) async {
    try {
      final activated = await session.setActive(true);
      if (!activated) {
        // Another app holds the audio session (e.g. user switched to
        // Spotify mid-call). Bail without `play()` so we don't barge in
        // on their playback.
        _emitInterruptionDiagnostic(
          'player.interruption:resume-skipped-session-busy',
          {'isPlaying': _player.playing},
        );
        return;
      }
      // iOS tears down AVPlayer's audio output pipeline during an
      // interruption. `play()` alone returns "playing" but produces no
      // sound; a position-neutral seek rebuilds the pipeline before we
      // resume. See `docs/architecture/playback-pipeline.md`.
      //
      // Isolate the seek so that non-seekable sources (live streams,
      // servers without range support) cannot abort the resume: a failed
      // reprime is still better than leaving playback permanently paused.
      try {
        await _player.seek(_player.position);
      } on Object catch (e, stack) {
        _log.w(
          '[AudioHandler] Seek-reprime failed; resuming without it',
          error: e,
          stackTrace: stack,
        );
      }
      await play();
      // Only force the UI / platform into `playing` when just_audio
      // actually reached `ready`. If the source is still loading or
      // buffering after an interruption, the natural state stream will
      // emit the correct `loading` / `buffering` -> `playing`
      // transition; overriding here would otherwise stomp on that
      // legitimate intermediate state.
      if (_player.playing && _player.processingState == ProcessingState.ready) {
        _controller.markPlayingByInterruption();
        _publishInterruptionPlayingPlaybackState();
      }
    } catch (e, stack) {
      // The `resume-failed` event is the *actual* "long phone call
      // didn't resume" signal — without Sentry capture here, the very
      // failure mode this handler is meant to make observable would
      // stay invisible in production.
      _log.e(
        '[AudioHandler] Failed to reactivate session',
        error: e,
        stackTrace: stack,
      );
      _emitInterruptionDiagnostic('player.interruption:resume-failed', {
        'error': e.toString(),
      });
      unawaited(Sentry.captureException(e, stackTrace: stack));
    }
  }

  /// Updates the platform media item (lock screen / notification metadata).
  void syncNowPlaying(NowPlayingInfo? info) => _nowPlayingSync.sync(info);

  /// Updates the media item duration without changing other fields.
  void updateDuration(Duration duration) =>
      _nowPlayingSync.updateDuration(duration);

  @override
  Future<void> play() async {
    // Ensure the audio session is configured before first playback.
    await _sessionReady;
    // The user explicitly asked to play. If we are mid-interruption
    // (e.g. a long phone call), drop the committed pause so the
    // upcoming interruption-end event does not double-resume or fight
    // the user's own action. Awaited so the volume restore finishes
    // before the controller resumes — prevents a racing onBegin(duck)
    // from being clobbered by an in-flight restore.
    await _interruptionHandler.markUserOverride();
    await _controller.resume();
  }

  @override
  Future<void> pause() async {
    // Same rationale as play(): keep onEnd from undoing the user's
    // action and serialize the volume restore.
    await _interruptionHandler.markUserOverride();
    await _controller.pause();
  }

  @override
  Future<void> stop() async {
    await _interruptionHandler.markUserOverride();
    await _controller.stop();
    await super.stop();
  }

  @override
  Future<void> seek(Duration position) async {
    await _controller.seek(position);
  }

  @override
  Future<void> skipToNext() async => _controller.skipForward();

  @override
  Future<void> skipToPrevious() async => _controller.skipBackward();

  @override
  Future<void> fastForward() async => _controller.skipForward();

  @override
  Future<void> rewind() async => _controller.skipBackward();
}
