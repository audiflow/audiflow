import 'package:audiflow/features/browser/common/model/episode_filter_mode.dart';
import 'package:audiflow/features/player/service/audio_player_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'audio_queue_service.g.dart';

abstract class AudioQueueService {
  Future<void> playFromPodcastDetailsPage({
    required Episode start,
    required EpisodeFilterMode filterMode,
  });
}

@Riverpod(keepAlive: true)
AudioQueueService audioQueueService(AudioQueueServiceRef ref) {
  // * Override this in the main method
  throw UnimplementedError();
}
