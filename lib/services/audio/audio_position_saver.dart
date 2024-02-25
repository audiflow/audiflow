import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:seasoning/entities/entities.dart';
import 'package:seasoning/repository/repository_provider.dart';
import 'package:seasoning/services/audio/audio_player_event.dart';
import 'package:seasoning/services/audio/audio_player_service.dart';

part 'audio_position_saver.g.dart';

@Riverpod(keepAlive: true)
bool audioPositionSaver(AudioPositionSaverRef ref) {
  ref
    ..listen(
        audioPlayerServiceProvider.select(
          (state) => (
            state?.episode,
            _roundInTwoSeconds(state?.position),
            state?.audioState
          ),
        ), (
      _,
      next,
    ) {
      final (episode, position, audioState) = next;
      if (episode != null &&
          position != null &&
          audioState == AudioState.ready) {
        _savePosition(ref, episode, position);
      }
    })
    ..listen(audioPlayerEventStreamProvider, (prev, next) {
      if (next.requireValue
          case AudioPlayerActionEvent(
            episode: final episode,
            position: final position,
          )) {
        if (prev?.valueOrNull
            case AudioPlayerActionEvent(
              episode: final prevEpisode,
              position: final prevPosition
            )) {
          if (prevEpisode.guid == episode.guid && prevPosition == position) {
            return;
          }
        }
        _savePosition(ref, episode, position);
      }
    });
  return true;
}

Duration? _roundInTwoSeconds(Duration? duration) {
  if (duration == null) {
    return null;
  }
  final seconds = duration.inSeconds;
  final remainder = seconds % 2;
  return Duration(seconds: seconds - remainder);
}

Future<void> _savePosition(
  ProviderRef<bool> ref,
  Episode episode,
  Duration position,
) async {
  final completed = episode.duration!.inSeconds - 3 <= position.inSeconds;
  await ref.read(repositoryProvider).updateEpisodeStats(
        EpisodeStatsUpdateParam(
          guid: episode.guid,
          position: position,
          // completed: completed ? completed : null,
        ),
      );
}
