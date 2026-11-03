import 'dart:async';

import 'package:audio_service/audio_service.dart' as audio_service;
import 'package:audio_session/audio_session.dart';
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:logger/logger.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import '../../car/services/car_media_browser.dart';
import '../../car/services/car_media_controls.dart';
import '../../car/services/car_playback.dart';
import '../../car/services/car_providers.dart';
import '../../monitoring/services/sentry_diagnostics.dart';
import '../../settings/presentation/controllers/locale_controller.dart';
import 'audio_interruption_handler.dart';
import 'now_playing_artwork_provider.dart';
import 'now_playing_media_item_sync.dart';
import 'session_queue_channel.dart';
import 'session_queue_publisher.dart';

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
    logger: _log,
  );

  /// What the published controls show; see [updateMediaControlValues].
  NowPlayingControlValues? _controlValues;

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
        seek: _controller.seekAutomatically,
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
    if (!sentryDiagnosticsEnabled) return;
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
    // just_audio emits the event for a speed change before the speed it
    // reports has changed, so that event still carries the old rate, and the
    // session would extrapolate the position with it. The replayed current
    // value is not a change.
    _player.speedStream.skip(1).listen((_) => _republishPlaybackState());
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
    // Not event.currentIndex: the player holds one source at a time, so that
    // index says nothing about the queue.
    return _buildPlaybackState(
      playing: _player.playing,
      queueIndex: playbackState.valueOrNull?.queueIndex,
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
      controls: nowPlayingMediaControls(
        playing: playing,
        values: _controlValues,
      ),
      systemActions: const {
        audio_service.MediaAction.seek,
        audio_service.MediaAction.seekForward,
        audio_service.MediaAction.seekBackward,
      },
      androidCompactActionIndices: nowPlayingCompactActionIndices(
        values: _controlValues,
      ),
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
      await _play(automatic: true);
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

  /// Republishes the controls for [values], as a speed or skip change on
  /// the phone produces no playback event of its own that would show them.
  ///
  void updateMediaControlValues(NowPlayingControlValues values) {
    if (_controlValues == values) return;
    _controlValues = values;
    _republishPlaybackState();
  }

  /// Publishes the current player values. Keeps the published `playing`
  /// flag: it can differ from the player's during an interruption.
  void _republishPlaybackState() {
    final published = playbackState.value;
    playbackState.add(
      _buildPlaybackState(
        playing: published.playing,
        queueIndex: published.queueIndex,
      ),
    );
  }

  /// Updates the platform media item (lock screen / notification metadata).
  void syncNowPlaying(NowPlayingInfo? info) => _nowPlayingSync.sync(info);

  /// Updates the media item duration without changing other fields.
  void updateDuration(Duration duration) =>
      _nowPlayingSync.updateDuration(duration);

  @override
  Future<void> play() => _play();

  /// [play] on the player's own account (resuming after an interruption),
  /// which must not reopen a finished listen.
  Future<void> _play({bool automatic = false}) async {
    // Ensure the audio session is configured before first playback.
    await _sessionReady;
    // The user explicitly asked to play. If we are mid-interruption
    // (e.g. a long phone call), drop the committed pause so the
    // upcoming interruption-end event does not double-resume or fight
    // the user's own action. Awaited so the volume restore finishes
    // before the controller resumes — prevents a racing onBegin(duck)
    // from being clobbered by an in-flight restore.
    await _interruptionHandler.markUserOverride();
    if (automatic) {
      await _controller.resumeAutomatically();
    } else {
      await _controller.resume();
    }
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
    _sessionQueue?.forgetPublished();
    await super.stop();
  }

  @override
  Future<void> seek(Duration position) async {
    await _controller.seek(position);
  }

  // Android Auto's media browser (FR 19). iOS never calls these. A browser
  // that fails to start leaves the head unit with empty lists, never an
  // error thrown into audio_service.

  // Created on the first browse request: iOS and phones that never browse
  // must not start the browser.
  late final _carBrowserLink = CarBrowserLink(_ref);

  Future<CarMediaBrowser> get _carBrowser => _carBrowserLink.browser;

  void _logCarBrowserError(Object error, StackTrace stack) {
    _log.e(
      '[AudioHandler] Android Auto browser failed',
      error: error,
      stackTrace: stack,
    );
  }

  @override
  Future<List<audio_service.MediaItem>> getChildren(
    String parentMediaId, [
    Map<String, dynamic>? options,
  ]) async {
    try {
      return await (await _carBrowser).getChildren(parentMediaId);
    } on Object catch (e, stack) {
      _logCarBrowserError(e, stack);
      return const [];
    }
  }

  @override
  ValueStream<Map<String, dynamic>> subscribeToChildren(String parentMediaId) {
    // audio_service needs the stream synchronously; forward the browser's
    // once it exists.
    final relay = BehaviorSubject<Map<String, dynamic>>.seeded(const {});
    unawaited(
      _carBrowser
          .then<void>((browser) {
            browser
                .subscribeToChildren(parentMediaId)
                .skip(1)
                .listen(relay.add);
          })
          .catchError(_logCarBrowserError),
    );
    return relay;
  }

  @override
  Future<void> playFromMediaId(
    String mediaId, [
    Map<String, dynamic>? extras,
  ]) async {
    try {
      await (await _carBrowser).playFromMediaId(mediaId);
    } on Object catch (e, stack) {
      _logCarBrowserError(e, stack);
    }
  }

  late final _carPlayback = CarPlayback(
    _ref,
    catalog: () => _ref.read(carCatalogProvider),
  );

  @override
  Future<dynamic> customAction(
    String name, [
    Map<String, dynamic>? extras,
  ]) async {
    if (name != carCycleSpeedAction) return super.customAction(name, extras);
    // Nothing above this handler can show a failure to the driver; the
    // button simply keeps its icon.
    try {
      await _carPlayback.cycleSpeed();
    } on Object catch (e, stack) {
      _log.e(
        '[AudioHandler] Android Auto speed change failed',
        error: e,
        stackTrace: stack,
      );
      unawaited(Sentry.captureException(e, stackTrace: stack));
    }
  }

  // Publishes the queue to the media session. Only Android reads it: the iOS
  // plugin drops setQueue, and CarPlay builds its Up Next from templates.
  SessionQueuePublisher? _sessionQueue;

  /// Starts following the queue and the now-playing episode.
  void startSessionQueue() {
    final publisher = SessionQueuePublisher(
      readQueue: () => _ref.read(playbackQueueProvider).value,
      readNowPlaying: () => _ref.read(nowPlayingControllerProvider),
      readTitle: () => carAppLocalizations(_ref).carUpNextTab,
      publish: _publishSessionQueue,
      playQueueItem: _carPlayback.playQueueItem,
      continueNowPlaying: _continueNowPlaying,
      resolveArtwork: (url) async {
        final resolver = await _ref.read(carArtworkResolverProvider.future);
        return resolver.resolve(url, background: true);
      },
      logger: _log,
    );
    _sessionQueue = publisher;
    _ref
      ..listen(playbackQueueProvider, (_, next) {
        if (next case AsyncError(:final error, :final stackTrace)) {
          _log.e(
            '[AudioHandler] Session queue read failed',
            error: error,
            stackTrace: stackTrace,
          );
        }
        publisher.markChanged();
      })
      ..listen(
        nowPlayingControllerProvider.select(
          (info) => (
            info?.episodeTitle,
            info?.episodeUrl,
            info?.episode?.id,
            info?.podcastTitle,
            info?.artworkUrl,
          ),
        ),
        (_, _) => publisher.markChanged(),
      )
      ..listen(localeControllerProvider, (_, _) => publisher.markChanged())
      // A browse can arrive while this handler is still being set up.
      ..listen(carBrowsedProvider, (_, browsed) {
        if (browsed) publisher.enableArtwork();
      }, fireImmediately: true)
      ..onDispose(publisher.dispose);
    publisher.markChanged();
  }

  void _publishSessionQueue(
    List<audio_service.MediaItem> items,
    int? activeIndex,
    String title,
  ) {
    queue.add(items);
    unawaited(_sendSessionQueueTitle(title));
    playbackState.add(
      _buildPlaybackState(
        playing: playbackState.value.playing,
        queueIndex: activeIndex,
      ),
    );
  }

  /// Sent with every list: a stopped service loses it with its session.
  ///
  /// Android registers the channel with the Activity, so a car starting the
  /// app with no Activity cannot be sent the title yet. The next flush tries
  /// again, by which time the phone app may have been opened.
  Future<void> _sendSessionQueueTitle(String title) async {
    final sent = await _ref.read(sessionQueueChannelProvider).setTitle(title);
    if (!sent) _sessionQueue?.forgetPublished();
  }

  /// The playing row was tapped. An episode with no record has nothing to
  /// look up, and may have lost it while its audio is still loaded, so it
  /// only resumes.
  Future<bool> _continueNowPlaying(int? episodeId) async {
    if (episodeId != null && await _carPlayback.continueEpisode(episodeId)) {
      return true;
    }
    await _controller.resume();
    return true;
  }

  @override
  Future<void> skipToQueueItem(int index) async {
    // Nothing above this handler can show a failure to the driver.
    try {
      // As in play(): an interruption ending later must not undo this choice.
      await _interruptionHandler.markUserOverride();
      await _sessionQueue?.tap(index);
    } on Object catch (e, stack) {
      _log.e(
        '[AudioHandler] Session queue tap failed',
        error: e,
        stackTrace: stack,
      );
      unawaited(Sentry.captureException(e, stackTrace: stack));
    }
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
