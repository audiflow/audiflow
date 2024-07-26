import 'package:audiflow/core/exception/app_exception.dart';
import 'package:audiflow/features/feed/data/podcast_repository.dart';
import 'package:audiflow/features/feed/service/podcast_feed_loader.dart';
import 'package:audiflow/features/feed/service/podcast_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'podcast_feed_loader_igniter.g.dart';

@riverpod
class PodcastFeedLoaderIgniter extends _$PodcastFeedLoaderIgniter {
  @override
  Future<PodcastFeedLoaderState> build({
    String? feedUrl,
    int? collectionId,
  }) async {
    assert(feedUrl != null || collectionId != null);

    if (feedUrl != null) {
      ref.listen(
        podcastFeedLoaderProvider(feedUrl: feedUrl),
        (_, next) => state = AsyncValue.data(next),
      );
      return _setupLoader(feedUrl, collectionId);
    }

    final podcast = await ref
        .read(podcastRepositoryProvider)
        .findPodcastBy(collectionId: collectionId);
    if (podcast != null) {
      ref.listen(
        podcastFeedLoaderProvider(feedUrl: podcast.feedUrl),
        (_, next) => state = AsyncValue.data(next),
      );
      return _setupLoader(
        podcast.feedUrl,
        collectionId ?? podcast.collectionId,
      );
    }

    if (collectionId == null) {
      throw ArgumentError('collectionId is required');
    }

    final foundFeedUrl = await ref
        .read(podcastServiceProvider)
        .findOrFetchFeedUrlBy(collectionId: collectionId);
    if (foundFeedUrl == null) {
      throw NotFoundException();
    }

    ref.listen(
      podcastFeedLoaderProvider(feedUrl: foundFeedUrl),
      (_, next) => state = AsyncValue.data(next),
    );
    return _setupLoader(foundFeedUrl, collectionId);
  }

  Future<PodcastFeedLoaderState> _setupLoader(
    String feedUrl,
    int? collectionId,
  ) async {
    final loaderState = ref.read(podcastFeedLoaderProvider(feedUrl: feedUrl));
    if (loaderState.collectionId != null ||
        loaderState.loadingState != LoadingState.loadingPodcast) {
      return loaderState;
    }

    final loader =
        ref.read(podcastFeedLoaderProvider(feedUrl: feedUrl).notifier);
    if (collectionId != null) {
      loader.setup(collectionId: collectionId);
    } else {
      final podcast = await ref
          .read(podcastRepositoryProvider)
          .findPodcastBy(feedUrl: feedUrl);
      loader.setup(collectionId: podcast?.collectionId);
    }

    return ref.read(podcastFeedLoaderProvider(feedUrl: feedUrl));
  }
}
