import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../player/services/audio_player_service.dart';
import '../../queue/services/queue_service.dart';

part 'voice_command_executor.g.dart';

/// Executes voice command actions against player and queue services.
@riverpod
VoiceCommandExecutor voiceCommandExecutor(Ref ref) {
  return VoiceCommandExecutor(
    audioController: ref.watch(audioPlayerControllerProvider.notifier),
    queueService: ref.watch(queueServiceProvider),
  );
}

/// Executes voice command intents by delegating to
/// the appropriate domain services.
class VoiceCommandExecutor {
  VoiceCommandExecutor({
    required AudioPlayerController audioController,
    required QueueService queueService,
  }) : _audioController = audioController,
       _queueService = queueService;

  final AudioPlayerController _audioController;
  final QueueService _queueService;

  /// Pauses the current playback.
  Future<void> pause() async {
    await _audioController.pause();
  }

  /// Stops the current playback.
  Future<void> stop() async {
    await _audioController.stop();
  }

  /// Skips forward by the user-configured duration.
  Future<void> skipForward() async {
    await _audioController.skipForward();
  }

  /// Skips backward by the user-configured duration.
  Future<void> skipBackward() async {
    await _audioController.skipBackward();
  }

  /// Seeks to an absolute position.
  Future<void> seek(Duration position) async {
    await _audioController.seek(position);
  }

  /// Clears the playback queue.
  Future<void> clearQueue() async {
    await _queueService.clearQueue();
  }
}
