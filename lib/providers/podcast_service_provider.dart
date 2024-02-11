import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:seasoning/providers/podcast_api_provider.dart';
import 'package:seasoning/providers/repository_provider.dart';
import 'package:seasoning/providers/settings_service_provider.dart';
import 'package:seasoning/services/podcast/mobile_podcast_service.dart';
import 'package:seasoning/services/podcast/podcast_service.dart';

export 'package:seasoning/services/podcast/podcast_service.dart';

part 'podcast_service_provider.g.dart';

@riverpod
PodcastService podcastService(PodcastServiceRef ref) {
  final api = ref.watch(podcastApiProvider);
  final repository = ref.watch(repositoryProvider);
  final settingsService = ref.watch(settingsServiceProvider);
  return MobilePodcastService(
    api: api,
    repository: repository,
    settingsService: settingsService,
  );
}
