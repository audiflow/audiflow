import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:seasoning/providers/podcast_service_provider.dart';
import 'package:seasoning/providers/repository_provider.dart';
import 'package:seasoning/providers/settings_service_provider.dart';
import 'package:seasoning/services/audio/audio_player_service.dart';
import 'package:seasoning/services/audio/default_audio_player_service.dart';

export 'package:seasoning/services/audio/audio_player_service.dart';

part 'audio_player_service_provider.g.dart';

@riverpod
AudioPlayerService audioPlayerService(AudioPlayerServiceRef ref) {
  final repository = ref.watch(repositoryProvider);
  final settingsService = ref.watch(settingsServiceProvider);
  final podcastService = ref.watch(podcastServiceProvider);
  return DefaultAudioPlayerService(
      repository: repository,
      settingsService: settingsService,
      podcastService: podcastService,);
}
