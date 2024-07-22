abstract class RssRepository {
  Future<String?> findFeedUrl({required int collectionId});

  Future<void> saveFeedUrl({
    required int collectionId,
    required String feedUrl,
  });

  Future<int?> findCollectionId({required String feedUrl});
}
