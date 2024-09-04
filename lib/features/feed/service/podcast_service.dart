import 'package:audiflow/features/browser/common/data/podcast_api_repository.dart';
import 'package:audiflow/features/feed/data/rss_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'podcast_service.g.dart';

@Riverpod(keepAlive: true)
PodcastService podcastService(PodcastServiceRef ref) {
  return PodcastService(ref);
}

class PodcastService {
  PodcastService(this._ref);

  final Ref _ref;

  Future<String?> findOrFetchFeedUrlBy({required int collectionId}) async {
    final feedUrl = await _ref
        .read(rssRepositoryProvider)
        .findFeedUrl(collectionId: collectionId);
    if (feedUrl != null) {
      return feedUrl;
    }

    final itunesSearchItem = await _ref
        .read(podcastApiRepositoryProvider)
        .lookup(collectionId: collectionId);
    if (itunesSearchItem != null) {
      await _ref.read(rssRepositoryProvider).saveFeedUrl(
            collectionId: collectionId,
            feedUrl: itunesSearchItem.feedUrl,
          );
      return itunesSearchItem.feedUrl;
    }
    return null;
  }
}
