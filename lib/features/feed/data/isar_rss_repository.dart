import 'package:audiflow/features/feed/data/rss_repository.dart';
import 'package:audiflow/features/feed/model/model.dart';
import 'package:isar/isar.dart';

class IsarRssRepository implements RssRepository {
  IsarRssRepository(this.isar);

  final Isar isar;

  @override
  Future<String?> findFeedUrl({required int collectionId}) async {
    final podcast = await isar.podcasts
        .where()
        .filter()
        .collectionIdEqualTo(collectionId)
        .findFirst();
    if (podcast != null) {
      return podcast.feedUrl;
    }

    final record = await isar.feedUrls
        .where()
        .filter()
        .collectionIdEqualTo(collectionId)
        .findFirst();
    if (record != null) {
      return record.feedUrl;
    }

    return null;
  }

  @override
  Future<void> saveFeedUrl({
    required int collectionId,
    required String feedUrl,
  }) async {
    final record = FeedUrl(collectionId: collectionId, feedUrl: feedUrl);
    await isar.writeTxn(() => isar.feedUrls.put(record));
  }

  @override
  Future<int?> findCollectionId({required String feedUrl}) async {
    final podcast = await isar.podcasts
        .where()
        .filter()
        .feedUrlEqualTo(feedUrl)
        .findFirst();
    return podcast?.collectionId;
  }
}
