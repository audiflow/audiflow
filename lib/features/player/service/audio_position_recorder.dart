import 'package:audiflow/features/browser/common/data/stats_repository.dart';
import 'package:audiflow/features/feed/model/model.dart';
import 'package:audiflow/features/player/data/player_state_repository.dart';
import 'package:audiflow/features/player/service/audio_player_service.dart';
import 'package:audiflow/events/audio_player_event.dart';
import 'package:audiflow/utils/logger.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'audio_position_recorder.freezed.dart';
part 'audio_position_recorder.g.dart';

@Riverpod(keepAlive: true)
class AudioPositionRecorder extends _$AudioPositionRecorder {
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

      final statsRepository = ref.read(statsRepositoryProvider);
      switch (next.requireValue) {
        case AudioPlayerActionEvent(
            episode: final episode,
            action: AudioPlayerAction.play
          ):
          logger.d(() => 'save EpisodeStats.lastPlayedAt:${episode.title}');
          state = const AudioPositionSaverState();
          await statsRepository.updateEpisodeStats(
            EpisodeStatsUpdateParam(
              pid: episode.pid,
              id: episode.id,
              lastPlayedAt: DateTime.now(),
            ),
          );
          await statsRepository.saveRecentlyPlayedEpisode(episode);
        case AudioPlayerActionEvent(
            episode: final episode,
            action: AudioPlayerAction.completed,
          ):
          if ((episode.duration?.inSeconds ?? 0) < 1) {
            return;
          }
          final stats = await statsRepository.findEpisodeStats(episode.id);
          final playedDuration =
              stats!.playTotal - episode.duration! * stats.playCount;
          if (episode.duration! * 0.95 <= playedDuration) {
            logger.d(
              () => 'save EpisodeStats.completeCountDelta +1: ${episode.title}',
            );
            await statsRepository.updateEpisodeStats(
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
      final playerStateRepository = ref.read(playerStateRepositoryProvider);

      if (episode == null || position == null || phase == null) {
        state = const AudioPositionSaverState();
        return;
      }

      // Save playing episode's guid
      if (phase == PlayerPhase.stop) {
        playerStateRepository.clearPlayingEpisodeId();
      } else if (prevEpisode != episode) {
        playerStateRepository.savePlayingEpisodeId(episode.id);
      }

      final played = episode.duration == null
          ? null
          : (episode.duration! - position) < const Duration(seconds: 30)
              ? true
              : null;

      ref.read(statsRepositoryProvider).updateEpisodeStats(
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
