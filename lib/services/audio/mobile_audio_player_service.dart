// Copyright 2024 HANAI Tohru, Reedom, INC.
// Copyright 2020 Ben Hills and the project contributors.
// All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:io';

import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';
import 'package:logging/logging.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:rxdart/rxdart.dart';
import 'package:seasoning/core/environment.dart';
import 'package:seasoning/core/utils.dart';
import 'package:seasoning/entities/entities.dart';
import 'package:seasoning/events/episode_event.dart';
import 'package:seasoning/providers/repository_provider.dart';
import 'package:seasoning/services/audio/audio_player_event.dart';
import 'package:seasoning/services/audio/audio_player_service.dart';
import 'package:seasoning/services/audio/audio_player_state.dart';
import 'package:seasoning/services/podcast/mobile_podcast_service.dart';
import 'package:seasoning/services/podcast/podcast_service.dart';
import 'package:seasoning/services/settings/settings_service.dart';

part 'mobile_audio_player_service.g.dart';

/// This is the default implementation of [AudioPlayerService].
///
/// This implementation uses the [audio_service](https://pub.dev/packages/audio_service)
/// package to run the audio layer as a service to allow background play, and
/// playback is handled by the [just_audio](https://pub.dev/packages/just_audio)
/// package.
@Riverpod(keepAlive: true)
class MobileAudioPlayerService extends _$MobileAudioPlayerService
    implements AudioPlayerService {
  final log = Logger('MobileAudioPlayerService');

  Repository get repository => ref.read(repositoryProvider);

  AppSettings get appSettings => ref.read(settingsServiceProvider);

  PodcastService get podcastService => ref.read(podcastServiceProvider);

  late AudioHandler _audioHandler;
  var _cold = false;
  var _sleep = const Sleep(type: SleepType.none);
  var _audioPlayerSettings = const AudioPlayerSetting();

  /// Subscription to the position ticker.
  StreamSubscription<int>? _positionSubscription;

  /// Subscription to the sleep ticker.
  StreamSubscription<int>? _sleepSubscription;

  /// Ticks whilst playing. Updates our current position within an episode.
  final _durationTicker = Stream<int>.periodic(
    const Duration(milliseconds: 500),
    (count) => count,
  ).asBroadcastStream();

  /// Ticks twice every second if a time-based sleep has been started.
  final _sleepTicker = Stream<int>.periodic(
    const Duration(milliseconds: 500),
    (count) => count,
  ).asBroadcastStream();

  final _sleepState = BehaviorSubject<Sleep>();

  final _audioPlayerEventSubject = BehaviorSubject<AudioPlayerEvent>();

  Stream<EpisodeEvent>? get episodeListener => repository.episodeStream;

  // @override
  // Stream<Sleep> get sleepStream => _sleepState.stream;

  @override
  AudioPlayerState? build() => null;

  var _initialized = false;

  @override
  Future<void> setup() async {
    if (_initialized) {
      return;
    }

    _initialized = true;
    _audioHandler = await AudioService.init(
      builder: () => _DefaultAudioPlayerHandler(
        repository: repository,
        settings: appSettings,
      ),
      config: const AudioServiceConfig(
        androidNotificationChannelName: 'Seasoning Podcast Player',
        androidNotificationIcon: 'drawable/ic_stat_name',
        fastForwardInterval: Duration(seconds: 30),
      ),
    );
    _handleAudioServiceTransitions();
  }

  void dispose() {
    _sleepState.close();
    _sleepSubscription?.cancel();
    _audioPlayerEventSubject.close();
  }

  @override
  Future<void> play() {
    if (_cold && state != null) {
      _cold = false;
      return playEpisode(
        episode: state!.episode,
        position: state!.position,
        resume: true,
      );
    } else {
      return _audioHandler.play();
    }
  }

  @override
  Future<void> stop() async {
    await _audioHandler.stop();
  }

  /// Called by the client (UI), or when we move to a different episode within
  /// the queue, to play an episode.
  ///
  /// If we have a downloaded copy of the requested episode we will use that;
  /// otherwise we will stream the episode directly.
  @override
  Future<void> playEpisode({
    required Episode episode,
    required Duration position,
    bool? resume,
  }) async {
    if (episode.guid.isEmpty) {
      log.warning('ERROR: Attempting to play an empty episode');
      return;
    }

    final (uri, downloaded) = await _generateEpisodeUri(episode);

    log.info('Playing episode ${episode.guid} - '
        '${episode.title} from position $position');

    if (state != null) {
      // If we are currently playing a track - save the position of the current
      // track before switching to the next.
      final currentState = _audioHandler.playbackState.value.processingState;
      final prevEpisode = state!.episode;

      if (currentState == AudioProcessingState.ready) {
        _audioPlayerEventSubject.add(
          AudioPlayerPositionEvent(
            episode: prevEpisode,
            position: state!.position,
            stopping: true,
          ),
        );
      } else if (currentState == AudioProcessingState.loading) {
        await _audioHandler.stop();
      }
    }

    state = AudioPlayerState(
      episode: episode,
      position: position,
      playing: true,
      audioState: AudioState.buffering,
    );

    _audioPlayerSettings = AudioPlayerSetting(
      speed: appSettings.playbackSpeed,
      trimSilence: appSettings.trimSilence,
      volumeBoost: appSettings.volumeBoost,
    );

    await repository.savePlayingEpisodeGuid(episode.guid);

    _audioPlayerEventSubject.add(
      AudioPlayerStateEvent(
        episode: episode,
        state: AudioState.buffering,
        position: position,
      ),
    );

    try {
      final mediaItem = _episodeToMediaItem(
        episode,
        position,
        uri,
        downloaded,
      );
      await _audioHandler.playMediaItem(mediaItem);
      // ignore: avoid_catches_without_on_clauses
    } catch (e) {
      log
        ..fine('Error during playback')
        ..fine(e.toString());

      state = AudioPlayerState(
        episode: episode,
        position: position,
        audioState: AudioState.error,
        playing: false,
      );
      _audioPlayerEventSubject.add(
        AudioPlayerStateEvent(
          episode: episode,
          state: AudioState.error,
          position: position,
        ),
      );

      await _audioHandler.stop();
    }
  }

  @override
  Future<void> pause() async {
    await _audioHandler.pause();
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

    state = state!.copyWith(
      position: position,
      audioState: AudioState.buffering,
    );
    await _audioHandler.seek(position);
    _positionSubscription?.resume();
  }

  @override
  Future<void> setPlaybackSpeed(double speed) {
    _audioPlayerSettings = _audioPlayerSettings.copyWith(speed: speed);
    return _audioHandler.setSpeed(speed);
  }

  @override
  Future<void> suspend() async {
    await _stopPositionTicker();
  }

  @override
  Future<void> resume() async {
    if (state != null) {
      final playbackState = _audioHandler.playbackState.value;
      final audioState = AudioState.from(playbackState.processingState);

      // If we have no state we'll have to assume we stopped whilst suspended.
      if (audioState == AudioState.idle) {
        // We will have to assume we have stopped.
        state = state!.copyWith(
          playing: false,
          audioState: audioState,
        );
      } else if (audioState == AudioState.ready) {
        await _startPositionTicker();
      }
      return;
    }

    // If _episode is null, we must have stopped whilst still active or we were
    // killed.
    final guid = await repository.playingEpisodeGuid();
    if (guid == null) {
      return;
    }
    final (id, episode) = await repository.findEpisodeByGuid(guid);
    if (id == null || episode == null) {
      return;
    }
    final stats = await repository.findEpisodeStatsById(id);
    if (stats == null) {
      return;
    }

    state = AudioPlayerState(
      episode: episode,
      position: stats.position,
      playing: false,
      audioState: AudioState.idle,
    );
  }

  @override
  void sleep(Sleep sleep) {
    switch (sleep.type) {
      case SleepType.none:
      case SleepType.episode:
        _stopSleepTicker();
      case SleepType.time:
        _startSleepTicker();
    }

    _sleep = sleep;
    _sleepState.sink.add(_sleep);
  }

  Future<(String, bool)> _generateEpisodeUri(Episode episode) async {
    final download = await repository.findDownloadByGuid(episode.guid);
    if (download?.state != DownloadState.downloaded) {
      return (episode.contentUrl!, false);
    }

    if (!await hasStoragePermission(appSettings)) {
      throw Exception('Insufficient storage permissions');
    }

    return (await resolvePath(appSettings, download!), true);
  }

  @override
  Future<void> trimSilence({required bool trim}) {
    return _audioHandler.customAction('trim', <String, dynamic>{
      'value': trim,
    });
  }

  @override
  Future<void> volumeBoost({required bool boost}) {
    return _audioHandler.customAction('boost', <String, dynamic>{
      'value': boost,
    });
  }

  MediaItem _episodeToMediaItem(
    Episode episode,
    Duration position,
    String uri,
    bool downloaded,
  ) {
    return MediaItem(
      id: uri,
      title: episode.title,
      artist: episode.author ?? 'Unknown Author',
      artUri: Uri.parse(episode.imageUrl ?? episode.thumbImageUrl ?? ''),
      duration: episode.duration,
      extras: <String, dynamic>{
        'position': position.inMilliseconds,
        'downloaded': downloaded,
        'speed': _audioPlayerSettings.speed,
        'trim': _audioPlayerSettings.trimSilence,
        'boost': _audioPlayerSettings.volumeBoost,
        'guid': episode.guid,
      },
    );
  }

  void _handleAudioServiceTransitions() {
    _audioHandler.playbackState.distinct((previous, current) {
      return previous.playing == current.playing &&
          previous.processingState == current.processingState;
    }).listen((PlaybackState playbackState) {
      final audioState = AudioState.from(playbackState.processingState);
      var playing = state?.playing ?? false;
      log.fine(
        'Audio state is $audioState - playing is ${playbackState.playing}',
      );
      if (audioState == AudioState.ready) {
        if (playbackState.playing) {
          _startPositionTicker();
          playing = true;
        } else {
          playing = false;
          _stopPositionTicker();
        }
      }
      state = state?.copyWith(
        position: playbackState.position,
        playing: playing,
        audioState: audioState,
      );
      if (audioState == AudioState.completed) {
        _completed();
      }
    });
  }

  Future<void> _completed() async {
    // await _saveCurrentEpisodePosition(complete: true);
    //
    // log.fine('We have completed episode ${state?.episode.guid}');
    //
    // await _stopPositionTicker();
    //
    // if (_queue.isEmpty) {
    //   log.fine('Queue is empty so we will stop');
    //   _queue = <Episode>[];
    //   _currentEpisode = null;
    //   _audioState.add(AudioState.stopped);
    //
    //   await _audioHandler.customAction('queueend');
    // } else if (_sleep.type == SleepType.episode) {
    //   log.fine('Sleeping at end of episode');
    //
    //   await _audioHandler.customAction('sleep');
    //   _audioState.add(AudioState.pausing);
    //   await _stopSleepTicker();
    // } else {
    //   log.fine('Queue has ${_queue.length} episodes left');
    //   _currentEpisode = null;
    //   final ep = _queue.removeAt(0);
    //
    //   await playEpisode(episode: ep);
    //
    //   _updateQueueState();
    // }
  }

  /// Saves the current play position to persistent storage. This enables a
  /// podcast to continue playing where it left off if played at a later
  /// time.
  // Future<void> _saveCurrentEpisodePosition({bool complete = false}) async {
  // if (state == null) {
  //   log.fine(' - Cannot save position as episode is null');
  // }
  //
  // // The episode may have been updated elsewhere - re-fetch it.
  // final currentPosition = _audioHandler.playbackState.value.position;
  //
// _currentEpisode = await repository.findEpisodeByGuid(_currentEpisode!.guid);
  //
  // log.fine(
  //   '_saveCurrentEpisodePosition(): Current position is $currentPosition -
  //   stored position is ${_currentEpisode!.position} complete is $complete',
  // );
  //
  // if (currentPosition != _currentEpisode!.position) {
  //   _currentEpisode!.position = complete ? 0 : currentPosition;
  //   _currentEpisode!.played = complete;
  //
  //   _currentEpisode = await repository.saveEpisode(_currentEpisode!);
  // }
  // }

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

  /// We only want to start the sleep timer ticker when the user has requested
  /// a sleep.
  Future<void> _startSleepTicker() async {
    _sleepSubscription ??= _sleepTicker.listen((int period) async {
      if (_sleep.type == SleepType.time &&
          DateTime.now().isAfter(_sleep.endTime)) {
        await pause();
        _sleep = const Sleep(type: SleepType.none);
        _sleepState.sink.add(_sleep);
        await _sleepSubscription?.cancel();
        _sleepSubscription = null;
      } else {
        _sleepState.sink.add(_sleep);
      }
    });
  }

  /// Once we have stopped sleeping we call this method to tidy up the ticker
  /// subscription.
  Future<void> _stopSleepTicker() async {
    _sleep = const Sleep(type: SleepType.none);
    _sleepState.sink.add(_sleep);

    if (_sleepSubscription != null) {
      await _sleepSubscription!.cancel();
      _sleepSubscription = null;
    }
  }

  Future<void> _onUpdatePosition() async {
    final playbackState = _audioHandler.playbackState.value;
    state = state?.copyWith(
      position: playbackState.position,
      audioState: AudioState.from(playbackState.processingState),
    );
  }
}

/// This is the default audio handler used by the [MobileAudioPlayerService]
/// service.
/// This handles the interaction between the service (via the audio service
/// package) and the underlying player.
class _DefaultAudioPlayerHandler extends BaseAudioHandler with SeekHandler {
  _DefaultAudioPlayerHandler({
    required this.repository,
    required this.settings,
  }) {
    _initPlayer();
  }

  final log = Logger('DefaultAudioPlayerHandler');
  final Repository repository;
  final AppSettings settings;

  static const rewindMillis = 10001;
  static const fastForwardMillis = 30000;
  static const audioGain = 0.8;
  bool _trimSilence = false;

  late AndroidLoudnessEnhancer _androidLoudnessEnhancer;
  AudioPipeline? _audioPipeline;
  late AudioPlayer _player;
  MediaItem? _currentItem;

  static const MediaControl rewindControl = MediaControl(
    androidIcon: 'drawable/ic_action_rewind_10',
    label: 'Rewind',
    action: MediaAction.rewind,
  );

  static const MediaControl fastforwardControl = MediaControl(
    androidIcon: 'drawable/ic_action_fastforward_30',
    label: 'Fastforward',
    action: MediaAction.fastForward,
  );

  void _initPlayer() {
    if (Platform.isAndroid) {
      _androidLoudnessEnhancer = AndroidLoudnessEnhancer();
      _androidLoudnessEnhancer.setEnabled(true);
      _audioPipeline =
          AudioPipeline(androidAudioEffects: [_androidLoudnessEnhancer]);
      _player = AudioPlayer(
        audioPipeline: _audioPipeline,
        userAgent: Environment.userAgent(),
      );
    } else {
      _player = AudioPlayer(
        userAgent: Environment.userAgent(),
        useProxyForRequestHeaders: false,
        audioLoadConfiguration: const AudioLoadConfiguration(
          androidLoadControl: AndroidLoadControl(
            backBufferDuration: Duration(seconds: 45),
          ),
          darwinLoadControl: DarwinLoadControl(),
        ),
      );
    }

    /// List to events from the player itself, transform the player event to an
    /// audio service one
    /// and hand it off to the playback state stream to inform our client(s).
    _player.playbackEventStream.map(_transformEvent).listen((data) {
      if (playbackState.isClosed) {
        log.warning('WARN: Playback state is already closed.');
      } else {
        playbackState.add(data);
      }
    }).onError((dynamic error) {
      log
        ..fine('Playback error received')
        ..fine(error.toString());

      _player.stop();
    });
  }

  @override
  Future<void> playMediaItem(MediaItem mediaItem) async {
    _currentItem = mediaItem;

    final downloaded = mediaItem.extras!['downloaded'] as bool? ?? false;
    final startPosition = mediaItem.extras!['position'] as int? ?? 0;
    final playbackSpeed = mediaItem.extras!['speed'] as double? ?? 0.0;
    final start = startPosition > 0
        ? Duration(milliseconds: startPosition)
        : Duration.zero;
    final boost = mediaItem.extras!['boost'] as bool? ?? true;
    // Commented out until just audio position bug is fixed
    // var trim = mediaItem.extras['trim'] as bool ?? true;

    log.fine(
      'loading new track ${mediaItem.id} - from position ${start.inSeconds}'
      ' ($start)',
    );

    final source = downloaded
        ? AudioSource.uri(
            Uri.parse('file://${mediaItem.id}'),
            tag: mediaItem.id,
          )
        : AudioSource.uri(Uri.parse(mediaItem.id), tag: mediaItem.id);

    log.fine('url: ${source.uri}');
    try {
      final duration =
          await _player.setAudioSource(source, initialPosition: start);

      /// If we don't already have a duration and we have been able to calculate
      /// it from beginning to fetch the media, update the current media item
      /// with the duration.
      if (duration != null &&
          (_currentItem!.duration == null ||
              _currentItem!.duration!.inSeconds == 0)) {
        _currentItem = _currentItem!.copyWith(duration: duration);
      }

      if (_player.processingState != ProcessingState.idle) {
        try {
          if (_player.speed != playbackSpeed) {
            await _player.setSpeed(playbackSpeed);
          }

          if (Platform.isAndroid) {
            if (_player.skipSilenceEnabled != _trimSilence) {
              await _player.setSkipSilenceEnabled(_trimSilence);
            }

            await volumeBoost(boost: boost);
          }

          await _player.play();
          // ignore: avoid_catches_without_on_clauses
        } catch (e) {
          log.fine('State error $e');
        }
      }
    } on PlayerException catch (e) {
      log.fine('PlayerException - Error code ${e.code} - ${e.message}');
      await stop();
      log.fine(e);
    } on PlayerInterruptedException catch (e) {
      log.fine('PlayerInterruptedException');
      await stop();
      log.fine(e);
      // ignore: avoid_catches_without_on_clauses
    } catch (e) {
      log.fine('General playback exception');
      await stop();
      log.fine(e);
    }

    super.mediaItem.add(_currentItem);
  }

  @override
  Future<void> play() async {
    await _player.play();
  }

  @override
  Future<void> pause() async {
    log.fine('pause() triggered - saving position');
    await _savePosition();
    await _player.pause();
  }

  @override
  Future<void> stop() async {
    log.fine('stop() triggered - saving position');

    await _player.stop();
    await _savePosition();
  }

  @override
  Future<void> fastForward() async {
    final forwardPosition = _player.position.inMilliseconds;

    await _player
        .seek(Duration(milliseconds: forwardPosition + fastForwardMillis));
  }

  @override
  Future<void> seek(Duration position) async {
    return _player.seek(position);
  }

  @override
  Future<void> rewind() async {
    var rewindPosition = _player.position.inMilliseconds;

    if (rewindPosition > 0) {
      rewindPosition -= rewindMillis;

      if (rewindPosition < 0) {
        rewindPosition = 0;
      }

      await _player.seek(Duration(milliseconds: rewindPosition));
    }
  }

  @override
  Future<dynamic> customAction(
    String name, [
    Map<String, dynamic>? extras,
  ]) async {
    switch (name) {
      case 'trim':
        final t = extras!['value'] as bool;
        return trimSilence(trim: t);
      case 'boost':
        final t = extras!['value'] as bool?;
        return volumeBoost(boost: t);
      case 'queueend':
        log.fine('Received custom action: queue end');
        await _player.stop();
        await super.stop();
      case 'sleep':
        log.fine('Received custom action: sleep end of episode');
        // We need to wind back a several milliseconds to stop just_audio
        // from sending more complete events on iOS when we pause.
        var position = _player.position.inMilliseconds - 200;

        if (position < 0) {
          position = 0;
        }

        await _player.seek(Duration(milliseconds: position));
        await _player.pause();
    }
  }

  @override
  Future<void> setSpeed(double speed) => _player.setSpeed(speed);

  Future<void> trimSilence({required bool trim}) async {
    _trimSilence = trim;
    await _player.setSkipSilenceEnabled(trim);
  }

  Future<void> volumeBoost({required bool? boost}) async {
    /// For now, we know we only have one effect so we can cheat
    final e = _audioPipeline!.androidAudioEffects[0];

    if (e is AndroidLoudnessEnhancer) {
      await e.setTargetGain(boost! ? audioGain : 0.0);
    }
  }

  PlaybackState _transformEvent(PlaybackEvent event) {
    log.fine('_transformEvent Sending state ${_player.processingState}');

    return PlaybackState(
      controls: [
        rewindControl,
        if (_player.playing) MediaControl.pause else MediaControl.play,
        fastforwardControl,
      ],
      systemActions: const {
        MediaAction.seek,
        MediaAction.seekForward,
        MediaAction.seekBackward,
      },
      androidCompactActionIndices: const [0, 1, 2],
      processingState: {
        ProcessingState.idle: _player.playing
            ? AudioProcessingState.ready
            : AudioProcessingState.idle,
        ProcessingState.loading: AudioProcessingState.loading,
        ProcessingState.buffering: AudioProcessingState.buffering,
        ProcessingState.ready: AudioProcessingState.ready,
        ProcessingState.completed: AudioProcessingState.completed,
      }[_player.processingState]!,
      playing: _player.playing,
      updatePosition: _player.position,
      bufferedPosition: _player.bufferedPosition,
      speed: _player.speed,
      queueIndex: event.currentIndex,
    );
  }

  Future<void> _savePosition({bool complete = false}) async {
    if (_currentItem == null) {
      return;
    }

    final guid = _currentItem!.extras!['guid'] as String;
    final stats = await repository.findEpisodeStatsByGuid(guid);
    if (stats == null) {
      return;
    }

    final newStats = stats.copyWith(
      position:
          complete ? _currentItem!.duration! : playbackState.value.position,
      played: complete || stats.played,
    );

    if (stats != newStats) {
      await repository.saveEpisodeStats(newStats);
    }
  }
}
