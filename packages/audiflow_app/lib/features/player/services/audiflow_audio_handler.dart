import 'dart:async';

import 'package:audio_service/audio_service.dart' as audio_service;
import 'package:audio_session/audio_session.dart';
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:logger/logger.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import 'audio_interruption_handler.dart';

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
          // an iOS OS-initiated interruption, so we force the UI state
          // here. See `docs/architecture/playback-pipeline.md`.
          _controller.markPausedByInterruption();
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
    // Capture the post-pause state and the unwanted-unknown-end path as
    // messages so the on-device session surfaces without needing a crash.
    if (event == 'player.interruption:begin-paused' ||
        event == 'player.interruption:begin-pause-failed' ||
        event == 'player.interruption:end-unknown-no-resume') {
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

  /// Pipes just_audio's playbackEventStream directly to audio_service's
  /// playbackState BehaviorSubject, matching the official pattern.
  void _pipePlaybackState() {
    _player.playbackEventStream.map(_transformEvent).pipe(playbackState);
  }

  audio_service.PlaybackState _transformEvent(PlaybackEvent event) {
    return audio_service.PlaybackState(
      controls: [
        audio_service.MediaControl.skipToPrevious,
        audio_service.MediaControl.rewind,
        if (_player.playing)
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
      playing: _player.playing,
      updatePosition: _player.position,
      bufferedPosition: _player.bufferedPosition,
      speed: _player.speed,
      queueIndex: event.currentIndex,
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

    session.becomingNoisyEventStream.listen((_) => pause());
  }

  Future<void> _reactivateAndResume(AudioSession session) async {
    try {
      await session.setActive(true);
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
      // Only force the UI into `playing` when just_audio actually
      // reached `ready`. If the source is still loading or buffering
      // after an interruption, the natural state stream will emit the
      // correct `loading` / `buffering` -> `playing` transition; calling
      // `markPlayingByInterruption` here would otherwise stomp on that
      // legitimate intermediate state.
      if (_player.playing && _player.processingState == ProcessingState.ready) {
        _controller.markPlayingByInterruption();
      }
    } catch (e, stack) {
      _log.e(
        '[AudioHandler] Failed to reactivate session',
        error: e,
        stackTrace: stack,
      );
    }
  }

  /// Updates the platform media item (lock screen / notification metadata).
  void syncNowPlaying(NowPlayingInfo? info) {
    if (info == null) {
      _log.d('[AudioHandler] NowPlaying cleared');
      mediaItem.add(null);
      return;
    }

    _log.i(
      '[AudioHandler] NowPlaying: '
      '${info.episodeTitle} - ${info.podcastTitle}',
    );

    mediaItem.add(
      audio_service.MediaItem(
        id: info.episodeUrl,
        title: info.episodeTitle,
        artist: info.podcastTitle,
        artUri: info.artworkUrl != null ? Uri.parse(info.artworkUrl!) : null,
        duration: info.totalDuration,
      ),
    );
  }

  /// Updates the media item duration without changing other fields.
  void updateDuration(Duration duration) {
    final current = mediaItem.value;
    if (current != null && current.duration != duration) {
      mediaItem.add(current.copyWith(duration: duration));
    }
  }

  @override
  Future<void> play() async {
    // Ensure the audio session is configured before first playback.
    await _sessionReady;
    await _controller.resume();
  }

  @override
  Future<void> pause() async => _controller.pause();

  @override
  Future<void> stop() async {
    await _controller.stop();
    await super.stop();
  }

  @override
  Future<void> seek(Duration position) async => _controller.seek(position);

  @override
  Future<void> skipToNext() async => _controller.skipForward();

  @override
  Future<void> skipToPrevious() async => _controller.skipBackward();

  @override
  Future<void> fastForward() async => _controller.skipForward();

  @override
  Future<void> rewind() async => _controller.skipBackward();
}
