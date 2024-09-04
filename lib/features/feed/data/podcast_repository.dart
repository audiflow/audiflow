import 'package:audiflow/features/feed/model/model.dart';
import 'package:isar/isar.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'podcast_repository.g.dart';

abstract class PodcastRepository {
  Future<Podcast?> findPodcast(Id id);

  Future<Podcast?> findPodcastBy({
    String? feedUrl,
    int? collectionId,
  });

  Future<void> savePodcast(Podcast podcast);
}

@Riverpod(keepAlive: true)
PodcastRepository podcastRepository(PodcastRepositoryRef ref) {
  // * Override this in the main method
  throw UnimplementedError();
}
