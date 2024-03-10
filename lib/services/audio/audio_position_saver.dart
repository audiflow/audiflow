import 'package:logging/logging.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:seasoning/entities/entities.dart';
import 'package:seasoning/repository/repository_provider.dart';
import 'package:seasoning/services/audio/audio_player_service.dart';

part 'audio_position_saver.g.dart';

@Riverpod(keepAlive: true)
bool audioPositionSaver(AudioPositionSaverRef ref) {
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
      ), (
    prev,
    next,
  ) {
    final (prevEpisode, _, prevPhase) = prev ?? (null, null, null);
    final (episode, position, phase) = next;
    final repository = ref.read(repositoryProvider);

    if (episode == null || position == null || phase == null) {
      return;
    }

    // Save playing episode's guid
    if (phase == PlayerPhase.stop) {
      repository.clearPlayingEpisodeGuid();
    } else if (prevEpisode != episode) {
      repository.savePlayingEpisodeGuid(episode.guid);
    }

    var statsUpdateParam = EpisodeStatsUpdateParam(
      guid: episode.guid,
      position: position,
    );

    final log = Logger('audioPositionSaver');
    // Save position
    // final completed = episode.duration!.inSeconds - 3 <=
    // position.inSeconds;
    if (phase == PlayerPhase.play &&
        (prevPhase != phase || prevEpisode != episode)) {
      statsUpdateParam = statsUpdateParam.copyWith(
        lastPlayedAt: DateTime.now(),
      );
    }

    repository.updateEpisodeStats(statsUpdateParam);
  });
  return true;
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
