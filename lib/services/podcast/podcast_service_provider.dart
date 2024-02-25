import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:seasoning/services/podcast/mobile_podcast_service.dart';
import 'package:seasoning/services/podcast/podcast_service.dart';

export 'package:seasoning/services/podcast/podcast_service.dart';

part 'podcast_service_provider.g.dart';

@Riverpod(keepAlive: true)
PodcastService podcastService(PodcastServiceRef ref) =>
    MobilePodcastService(ref);
