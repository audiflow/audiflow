import 'package:audiflow/api/podcast/mobile_podcast_api.dart';
import 'package:audiflow/api/podcast/podcast_api.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

export 'package:audiflow/api/podcast/podcast_api.dart';

part 'podcast_api_provider.g.dart';

@Riverpod(keepAlive: true)
PodcastApi podcastApi(PodcastApiRef ref) => MobilePodcastApi(ref);
