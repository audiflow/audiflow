import 'package:seasoning/entities/entities.dart';
import 'package:seasoning/services/audio/audio_player_service.dart';

sealed class AudioPlayerEvent {}

class AudioPlayerStateEvent implements AudioPlayerEvent {
  const AudioPlayerStateEvent({
    required this.episode,
    required this.state,
    required this.position,
  });

  final Episode episode;
  final AudioState state;
  final Duration position;
}

class AudioPlayerPositionEvent implements AudioPlayerEvent {
  const AudioPlayerPositionEvent({
    required this.episode,
    required this.position,
    this.stopping = false,
  });

  final Episode episode;
  final Duration position;
  final bool stopping;
}
