import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'rss_repository.g.dart';

abstract class RssRepository {
  Future<String?> findFeedUrl({required int collectionId});

  Future<void> saveFeedUrl({
    required int collectionId,
    required String feedUrl,
  });

  Future<int?> findCollectionId({required String feedUrl});
}

@Riverpod(keepAlive: true)
RssRepository rssRepository(RssRepositoryRef ref) {
  // * Override this in the main method
  throw UnimplementedError();
}
