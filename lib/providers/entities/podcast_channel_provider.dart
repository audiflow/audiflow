import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:seasoning/entities/entities.dart';
import 'package:seasoning/providers/podcast_service_provider.dart';

part 'podcast_channel_provider.g.dart';

@riverpod
class PodcastChannel extends _$PodcastChannel {
  @override
  Podcast? build() => null;

  Future<void> load(Feed feed) async {
    final podcast = await ref
        .read(podcastServiceProvider)
        .loadPodcast(podcast: feed.podcast);
    state = podcast;
  }
}
