// Copyright (c) 2024 by HANAI, Tohru.
// Copyright (c) 2024 Reedom, Inc.
// Additional contributions from project contributors.
// All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:audiflow/entities/entities.dart';
import 'package:audiflow/repository/repository_provider.dart';
import 'package:audiflow/services/audio/audio_player_event.dart';
import 'package:audiflow/services/audio/audio_player_service.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:logging/logging.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'audio_position_saver.freezed.dart';
part 'audio_position_saver.g.dart';

@Riverpod(keepAlive: true)
class AudioPositionSaver extends _$AudioPositionSaver {
  final _log = Logger('AudioPositionSaver');

  @override
  AudioPositionSaverState build() {
    _listenAudioPlayerEvent();
    _listenAudioPlayerState();
    return const AudioPositionSaverState();
  }

  void _listenAudioPlayerEvent() {
    ref.listen(audioPlayerEventStreamProvider, (_, next) async {
      if (next.valueOrNull == null) {
        return;
      }

      final repository = ref.read(repositoryProvider);
      switch (next.requireValue) {
        case AudioPlayerActionEvent(
            episode: final episode,
            action: AudioPlayerAction.play
          ):
          _log.fine('save EpisodeStats.lastPlayedAt:${episode.title}');
          state = const AudioPositionSaverState();
          await repository.updateEpisodeStats(
            EpisodeStatsUpdateParam(
              pid: episode.pid,
              id: episode.id,
              lastPlayedAt: DateTime.now(),
            ),
          );
          await repository.saveRecentlyPlayedEpisode(episode);
        case AudioPlayerActionEvent(
            episode: final episode,
            action: AudioPlayerAction.completed,
          ):
          if ((episode.duration?.inSeconds ?? 0) < 1) {
            return;
          }
          final stats = await repository.findEpisodeStats(episode.id);
          final playedDuration =
              stats!.playTotal - episode.duration! * stats.playCount;
          if (episode.duration! * 0.95 <= playedDuration) {
            _log.fine('save EpisodeStats.completeCountDelta +1:'
                '${episode.title}');
            await repository.updateEpisodeStats(
              EpisodeStatsUpdateParam(
                pid: episode.pid,
                id: episode.id,
                position: episode.duration,
                completed: true,
              ),
            );
          }
      }
    });
  }

  void _listenAudioPlayerState() {
    ref.listen(
        audioPlayerServiceProvider.select(
          (state) => (
            state?.episode,
            _roundInTwoSeconds(
              position: state?.position,
              duration: state?.episode.duration,
            ),
            state?.phase,
          ),
        ), (prev, next) {
      final (prevEpisode, _, _) = prev ?? (null, null, null);
      final (episode, position, phase) = next;
      final repository = ref.read(repositoryProvider);

      if (episode == null || position == null || phase == null) {
        state = const AudioPositionSaverState();
        return;
      }

      // Save playing episode's guid
      if (phase == PlayerPhase.stop) {
        repository.clearPlayingEpisodeId();
      } else if (prevEpisode != episode) {
        repository.savePlayingEpisodeId(episode.id);
      }

      final played = episode.duration == null
          ? null
          : (episode.duration! - position) < const Duration(seconds: 30)
              ? true
              : null;

      repository.updateEpisodeStats(
        EpisodeStatsUpdateParam(
          pid: episode.pid,
          id: episode.id,
          position: position,
          played: played,
          playTotalDelta: state.lastSavedPosition != null &&
                  state.lastSavedPosition! < position
              ? position - state.lastSavedPosition!
              : null,
        ),
      );

      state = state.copyWith(
        episode: episode,
        lastSavedPosition: position,
      );
    });
  }

  Duration? _roundInTwoSeconds({
    required Duration? duration,
    required Duration? position,
  }) {
    if (position == null || duration == null) {
      return null;
    }

    final remains = duration - position;
    if (remains <= Duration.zero) {
      return duration;
    }

    final seconds = position.inSeconds;
    final remainder = seconds % 2;
    return Duration(seconds: seconds - remainder);
  }
}

@freezed
class AudioPositionSaverState with _$AudioPositionSaverState {
  const factory AudioPositionSaverState({
    Episode? episode,
    Duration? lastSavedPosition,
  }) = _AudioPositionSaverState;
}
