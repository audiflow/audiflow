import 'package:audiflow/events/podcast_event.dart';
import 'package:audiflow/features/feed/data/podcast_repository.dart';
import 'package:audiflow/features/feed/model/model.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'podcast_provider.g.dart';

@riverpod
Future<Podcast?> podcast(PodcastRef ref, int pid) {
  ref.listen(podcastEventStreamProvider, (_, next) {
    next.whenData((event) {
      if (event case PodcastUpdatedEvent(podcast: final podcast)) {
        if (podcast.id == pid) {
          ref.state = AsyncData(podcast);
        }
      }
    });
  });

  return ref.read(podcastRepositoryProvider).findPodcast(pid);
}
