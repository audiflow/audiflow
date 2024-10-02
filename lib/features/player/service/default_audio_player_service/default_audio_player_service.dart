import 'dart:async';

import 'package:audiflow/common/data/connectivity.dart';
import 'package:audiflow/common/service/error_manager.dart';
import 'package:audiflow/events/audio_player_event.dart';
import 'package:audiflow/features/download/data/download_repository.dart';
import 'package:audiflow/features/download/model/downloadable.dart';
import 'package:audiflow/features/download/service/download_path.dart';
import 'package:audiflow/features/player/service/audio_player_service.dart';
import 'package:audiflow/features/player/service/default_audio_player_service/audio_player_engine.dart';
import 'package:audiflow/features/player/service/default_audio_player_service/audio_player_handler.dart';
import 'package:audiflow/utils/duration.dart';
import 'package:audiflow/utils/logger.dart';
import 'package:audio_service/audio_service.dart';
import 'package:audio_session/audio_session.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'default_audio_player_service.g.dart';

/// This is the default implementation of [AudioPlayerService].
///
/// This implementation uses the [audio_service](https://pub.dev/packages/audio_service)
/// package to run the audio layer as a service to allow background play, and
/// playback is handled by the [just_audio](https://pub.dev/packages/just_audio)
/// package.
@Riverpod(keepAlive: true)
class DefaultAudioPlayerService extends _$DefaultAudioPlayerService
    implements AudioPlayerService {
  ErrorManager get _errorManager => ref.read(errorManagerProvider.notifier);

  DownloadPath get _downloadPath => ref.read(downloadPathProvider);

  DownloadRepository get _downloadRepository =>
      ref.read(downloadRepositoryProvider);

  late final AudioHandler _audioHandler;

  /// Subscription to the position ticker.
  StreamSubscription<int>? _positionSubscription;

  /// Ticks whilst playing. Updates our current position within an episode.
  final _durationTicker = Stream<int>.periodic(
    const Duration(milliseconds: 500),
    (count) => count,
  ).asBroadcastStream();

  @override
  AudioPlayerState? build() => null;

  var _initialized = false;

  @override
  Future<void> ensureInitialized() async {
    if (_initialized) {
      return;
    }

    _initialized = true;
    _audioHandler = await ref
        .read(audioPlayerHandlerProvider.selectAsync((service) => service));
    _handleAudioServiceTransitions();
    await ref.read(audioPlayerEngineProvider).ensureInitialized();

    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.speech());
    _handleAudioInterruptions(session);
  }

  @override
  FutureOr<void> play() {
    if (state?.phase == PlayerPhase.pause &&
        state?.audioState == AudioState.ready) {
      state = state!.copyWith(phase: PlayerPhase.play);
      return null;
    }

    if (state != null) {
      return loadEpisode(
        episode: state!.episode,
        position: state!.position,
        duration: state!.duration,
        autoPlay: true,
      );
    }
  }

  @override
  FutureOr<void> stop() {
    if (state == null) {
      return null;
    }

    state = state!.copyWith(phase: PlayerPhase.stop);
    state = null;
  }

  @override
  Future<void> togglePlayPause() async {
    if (state?.phase == PlayerPhase.play) {
      return pause();
    } else if (state?.phase == PlayerPhase.pause) {
      return play();
    }
  }

  /// Called by the client (UI), or when we move to a different episode within
  /// the queue, to play an episode.
  ///
  /// If we have a downloaded copy of the requested episode we will use that;
  /// otherwise we will stream the episode directly.
  @override
  Future<void> loadEpisode({
    required Episode episode,
    required Duration position,
    required Duration duration,
    required bool autoPlay,
  }) async {
    if (episode.guid.isEmpty) {
      logger.w('ERROR: Attempting to play an empty episode');
      return;
    }

    final (uri, downloaded) = await _generateEpisodeUri(episode);

    if (!downloaded && !await hasConnectivity()) {
      // TODO(reedom): skip to a downloaded episode, by a provider in charge
      _errorManager.noticeConnectivityError();
      return;
    }

    final playPosition =
        (episode.duration?.inSeconds ?? 0) - 1 <= position.inSeconds
            ? Duration.zero
            : position;

    logger.i(
      () => 'Playing episode ${episode.guid} - '
          '${episode.title} from position $playPosition',
    );

    if (state?.phase == PlayerPhase.play && state?.episode != episode) {
      state = state!.copyWith(phase: PlayerPhase.pause);
    }

    state = AudioPlayerState(
      episode: episode,
      position: playPosition,
      duration: duration,
      phase: autoPlay ? PlayerPhase.play : PlayerPhase.pause,
      audioState: autoPlay ? AudioState.buffering : AudioState.idle,
    );

    _notifyAudioPlayerEvent(AudioPlayerAction.play);

    try {
      // if (autoPlay) {
      //   final mediaItem = _episodeToMediaItem(
      //     episode,
      //     playPosition,
      //     uri,
      //     downloaded,
      //   );
      //   await _audioHandler.playMediaItem(mediaItem);
      // }
      // ignore: avoid_catches_without_on_clauses
    } catch (e) {
      logger
        ..d('Error during playback')
        ..d(e.toString());

      state = AudioPlayerState(
        episode: episode,
        position: playPosition,
        duration: duration,
        audioState: AudioState.error,
        phase: PlayerPhase.stop,
      );

      await _audioHandler.stop();
    }
  }

  @override
  Future<void> pause({bool interrupted = false}) async {
    if (state != null) {
      state = state!.copyWith(
        phase: PlayerPhase.pause,
        interrupted: interrupted,
      );
    }
  }

  @override
  Future<void> rewind() => _audioHandler.rewind();

  @override
  Future<void> fastForward() => _audioHandler.fastForward();

  @override
  Future<void> seek({required Duration position}) async {
    if (state == null) {
      return;
    }

    // Pause the ticker whilst we seek to prevent jumpy UI.
    _positionSubscription?.pause();

    final seekPosition = maxDuration(
      Duration.zero,
      // FIXME: use state.duration
      minDuration(position, state!.episode.duration!),
    );

    state = state!.copyWith(
      position: seekPosition,
      audioState: AudioState.buffering,
    );

    await _audioHandler.seek(seekPosition);
    _positionSubscription?.resume();
  }

  @override
  Future<void> suspend() async {
    await _stopPositionTicker();
  }

  @override
  Future<void> resume() async {
    if (state == null) {
      return;
    }
    final playbackState = _audioHandler.playbackState.value;
    final audioState = AudioState.from(playbackState.processingState);

    // If we have no state we'll have to assume we stopped whilst suspended.
    if (audioState == AudioState.idle) {
      // We will have to assume we have stopped.
      state = state!.copyWith(
        phase: PlayerPhase.pause,
        audioState: audioState,
      );
    } else if (audioState == AudioState.ready) {
      await _startPositionTicker();
    }
  }

  Future<(String, bool)> _generateEpisodeUri(Episode episode) async {
    final download = await _downloadRepository.findDownload(episode.id);
    if (download?.state != DownloadState.downloaded) {
      return (episode.contentUrl, false);
    }

    if (!await _downloadPath.hasStoragePermission()) {
      throw Exception('Insufficient storage permissions');
    }

    return (await _downloadPath.resolvePath(download!), true);
  }

  void _handleAudioServiceTransitions() {
    _audioHandler.playbackState.distinct((previous, current) {
      return previous.playing == current.playing &&
          previous.processingState == current.processingState;
    }).listen((PlaybackState playbackState) {
      final audioState = AudioState.from(playbackState.processingState);
      logger.d(
        () =>
            'Audio state is $audioState - playing is ${playbackState.playing}',
      );

      // Handle play/pause transitions by the Control Center.
      // There is a tricky situation at playback start:
      // iOS:
      //   when audioState is ready, the playbackState.playing is true
      // Android:
      //   when audioState is ready, the playbackState.playing is false
      // To cope with this, we utilize _positionSubscription state.
      var phase = state?.phase ?? PlayerPhase.stop;
      if (audioState == AudioState.ready) {
        if (_positionSubscription != null && !playbackState.playing) {
          phase = PlayerPhase.pause;
        } else if (_positionSubscription == null && playbackState.playing) {
          phase = PlayerPhase.play;
        }
      }

      if (audioState == AudioState.ready) {
        if (playbackState.playing) {
          _startPositionTicker();
        } else {
          _stopPositionTicker();
        }
      }
      state = state?.copyWith(
        position: playbackState.position,
        phase: phase,
        audioState: audioState,
      );
      if (audioState == AudioState.completed) {
        _completed();
      }
    });
  }

  void _handleAudioInterruptions(AudioSession session) {
    session.interruptionEventStream.listen((event) {
      if (event.begin) {
        switch (event.type) {
          case AudioInterruptionType.duck:
            break;
          case AudioInterruptionType.pause:
          case AudioInterruptionType.unknown:
            pause();
        }
      } else {
        switch (event.type) {
          case AudioInterruptionType.duck:
            break;
          case AudioInterruptionType.pause:
            if (state?.interrupted == true) {
              play();
            }
          case AudioInterruptionType.unknown:
            break;
        }
      }
    });
  }

  Future<void> _completed() async {
    if (state != null) {
      _notifyAudioPlayerEvent(AudioPlayerAction.completed);
      // logger.d('We have completed episode ${state?.episode.guid}');
      //
      // await _stopPositionTicker();
      //
      // if (_queue.isEmpty) {
      //   logger.d('Queue is empty so we will stop');
      //   _queue = <Episode>[];
      //   _currentEpisode = null;
      //   _audioState.add(AudioState.stopped);
      //
      //   await _audioHandler.customAction('queueend');
      // } else if (_sleep.type == SleepType.episode) {
      //   logger.d('Sleeping at end of episode');
      //
      //   await _audioHandler.customAction('sleep');
      //   _audioState.add(AudioState.pausing);
      //   await _stopSleepTicker();
      // } else {
      //   logger.d('Queue has ${_queue.length} episodes left');
      //   _currentEpisode = null;
      //   final ep = _queue.removeAt(0);
      //
      //   await playEpisode(episode: ep);
      //
      //   _updateQueueState();
    }
  }

  /// Called when play starts. Each time we receive an event in the stream
  /// we check the current position of the episode from the audio service
  /// and then push that information out via the _playPosition stream
  /// to inform our listeners.
  Future<void> _startPositionTicker() async {
    if (_positionSubscription == null) {
      _positionSubscription = _durationTicker.listen((int period) async {
        await _onUpdatePosition();
      });
    } else if (_positionSubscription!.isPaused) {
      _positionSubscription!.resume();
    }
  }

  Future<void> _stopPositionTicker() async {
    if (_positionSubscription != null) {
      await _positionSubscription!.cancel();
      _positionSubscription = null;
    }
  }

  Future<void> _onUpdatePosition() async {
    final playbackState = _audioHandler.playbackState.value;
    state = state?.copyWith(
      position: playbackState.position,
      audioState: AudioState.from(playbackState.processingState),
    );
  }

  void _notifyAudioPlayerEvent(AudioPlayerAction action) =>
      ref.read(audioPlayerEventStreamProvider.notifier).add(
            AudioPlayerActionEvent(
              episode: state!.episode,
              action: action,
              position: state!.position,
            ),
          );
}
