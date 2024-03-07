import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:seasoning/api/podcast/mobile_podcast_api.dart';
import 'package:seasoning/api/podcast/podcast_api.dart';

export 'package:seasoning/api/podcast/podcast_api.dart';

part 'podcast_api_provider.g.dart';

@Riverpod(keepAlive: true)
PodcastApi podcastApi(PodcastApiRef ref) => MobilePodcastApi();
