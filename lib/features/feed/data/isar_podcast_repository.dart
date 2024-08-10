import 'package:audiflow/features/feed/data/podcast_repository.dart';
import 'package:audiflow/features/feed/model/model.dart';
import 'package:isar/isar.dart';

class IsarPodcastRepository implements PodcastRepository {
  IsarPodcastRepository(this.isar);

  final Isar isar;

  @override
  Future<Podcast?> findPodcast(Id id) {
    return isar.podcasts.get(id);
  }

  @override
  Future<Podcast?> findPodcastBy({
    String? feedUrl,
    int? collectionId,
  }) async {
    if (feedUrl != null) {
      return isar.podcasts
          .where()
          .filter()
          .newFeedUrlEqualTo(feedUrl)
          .or()
          .feedUrlEqualTo(feedUrl)
          .findFirst();
    }
    if (collectionId != null) {
      return isar.podcasts
          .where()
          .filter()
          .collectionIdEqualTo(collectionId)
          .findFirst();
    }
    return null;
  }

  @override
  Future<void> savePodcast(Podcast podcast) async {
    await isar.writeTxn(() async {
      await isar.podcasts.put(podcast);
    });
  }
}
