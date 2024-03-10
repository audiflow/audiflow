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
    final (prevEpisode, _, _) = prev ?? (null, null, null);
    final (episode, position, _) = next;
    final repository = ref.read(repositoryProvider);

    if (prevEpisode != episode && episode != null) {
      repository.savePlayingEpisodeGuid(episode.guid);
    }

    if (episode != null && position != null) {
      // final completed = episode.duration!.inSeconds - 3 <=
      // position.inSeconds;
      repository.updateEpisodeStats(
        EpisodeStatsUpdateParam(
          guid: episode.guid,
          position: position,
          // completed: completed ? completed : null,
        ),
      );
    }
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
