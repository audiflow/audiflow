import 'dart:async';

import 'package:audiflow/features/download/data/download_repository.dart';
import 'package:audiflow/features/download/model/downloadable.dart';
import 'package:audiflow/features/download/service/download_path.dart';
import 'package:audiflow/features/player/service/audio_player_preference.dart';
import 'package:audiflow/features/player/service/audio_player_service.dart';
import 'package:audiflow/features/player/service/default_audio_player_service/audio_player_handler.dart';
import 'package:audio_service/audio_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:rxdart/rxdart.dart';

part 'audio_player_engine.freezed.dart';
part 'audio_player_engine.g.dart';

@Riverpod(keepAlive: true)
AudioPlayerEngine audioPlayerEngine(AudioPlayerEngineRef ref) {
  return AudioPlayerEngine(ref);
}

class AudioPlayerEngine {
  AudioPlayerEngine(this._ref);

  final Ref _ref;
  late final AudioHandler _audioHandler;
  final _streamController =
      StreamController<(PartialAudioPlayerState?, PartialAudioPlayerState?)>();

  DownloadPath get _downloadPath => _ref.read(downloadPathProvider);

  DownloadRepository get _downloadRepository =>
      _ref.read(downloadRepositoryProvider);

  Future<void> ensureInitialized() async {
    _audioHandler = await _ref
        .read(audioPlayerHandlerProvider.selectAsync((service) => service));
    _listen();
  }

  void _listen() {
    _ref
      ..listen(
        audioPlayerServiceProvider.select(
          (state) => state == null
              ? null
              : PartialAudioPlayerState(
                  episode: state.episode,
                  phase: state.phase,
                  audioState: state.audioState,
                  interrupted: state.interrupted,
                ),
        ),
        (prev, state) {
          _streamController.add((prev, state));
        },
      )
      ..listen(audioPlayerPreferenceProvider, (prev, next) {
        if (prev == null || !prev.hasValue || !next.hasValue) {
          return;
        }
        final state = _ref.read(audioPlayerServiceProvider);
        if (state?.audioState != AudioState.ready) {
          return;
        }
        if (prev.requireValue.speed != next.requireValue.speed) {
          _audioHandler.setSpeed(next.requireValue.speed);
        }
        if (prev.requireValue.trimSilence != next.requireValue.trimSilence) {
          _audioHandler.customAction('trim', <String, dynamic>{
            'value': next.requireValue.trimSilence,
          });
        }
        if (prev.requireValue.volumeBoost != next.requireValue.volumeBoost) {
          _audioHandler.customAction('boost', <String, dynamic>{
            'value': next.requireValue.volumeBoost,
          });
        }
      });

    _streamController.stream.flatMap(
      (state) async* {
        final (prev, next) = state;

        if (next == null) {
          await _onPlayerClose();
        } else if (prev?.episode.id != next.episode.id) {
          await _onEpisodeChange();
        } else if (prev!.phase != next.phase) {
          await _onPhaseChange(prev, next);
        }
      },
      maxConcurrent: 1,
    ).drain<void>();
  }

  Future<void> _onPlayerClose() async {
    await _audioHandler.stop();
  }

  Future<void> _onEpisodeChange() async {
    final state = _ref.read(audioPlayerServiceProvider)!;
    if (state.phase == PlayerPhase.play) {
      final (uri, downloaded) = await _generateEpisodeUri(state.episode);

      final mediaItem = await _episodeToMediaItem(
        state.episode,
        state.position,
        uri,
        downloaded,
      );
      await _audioHandler.playMediaItem(mediaItem);
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

  Future<MediaItem> _episodeToMediaItem(
    Episode episode,
    Duration position,
    String uri,
    bool downloaded,
  ) async {
    final preference = await _ref
        .read(audioPlayerPreferenceProvider.selectAsync((state) => state));
    return MediaItem(
      id: uri,
      title: episode.title,
      artist: episode.author ?? 'Unknown Author',
      artUri: Uri.parse(episode.imageUrl ?? ''),
      duration: episode.duration,
      extras: <String, dynamic>{
        'position': position.inMilliseconds,
        'downloaded': downloaded,
        'speed': preference.speed,
        'trim': preference.trimSilence,
        'boost': preference.volumeBoost,
        'guid': episode.guid,
      },
    );
  }

  Future<void> _onPhaseChange(
    PartialAudioPlayerState prev,
    PartialAudioPlayerState next,
  ) async {
    if (next.phase == PlayerPhase.play) {
      if (next.audioState == AudioState.ready) {
        unawaited(_audioHandler.play());
      } else {
        // Resume after reboot.
        // In this case, there is the mini player on the screen, but the audio
        // service is not ready yet.
        await _onEpisodeChange();
      }
    } else if (next.phase == PlayerPhase.pause && !next.interrupted) {
      await _audioHandler.pause();
    } else if (next.phase == PlayerPhase.stop) {
      await _audioHandler.stop();
    }
  }
}

@freezed
class PartialAudioPlayerState with _$PartialAudioPlayerState {
  factory PartialAudioPlayerState({
    required Episode episode,
    required PlayerPhase phase,
    required AudioState audioState,
    required bool interrupted,
  }) = _PartialAudioPlayerState;
}
