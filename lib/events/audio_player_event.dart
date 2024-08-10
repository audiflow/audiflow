import 'package:audiflow/features/feed/model/episode.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'audio_player_event.g.dart';

sealed class AudioPlayerEvent {}

enum AudioPlayerAction { play, completed }

class AudioPlayerActionEvent implements AudioPlayerEvent {
  const AudioPlayerActionEvent({
    required this.episode,
    required this.action,
    required this.position,
  });

  final Episode episode;
  final AudioPlayerAction action;
  final Duration position;
}

@Riverpod(keepAlive: true)
class AudioPlayerEventStream extends _$AudioPlayerEventStream {
  @override
  Stream<AudioPlayerEvent> build() async* {}

  void add(AudioPlayerEvent event) {
    state = AsyncData(event);
  }
}
