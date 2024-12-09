import 'package:audiflow/exceptions/app_exception.dart';
import 'package:audiflow/features/feed/data/podcast_repository.dart';
import 'package:audiflow/features/feed/service/podcast_feed_loader.dart';
import 'package:audiflow/features/feed/service/podcast_service.dart';
import 'package:audiflow/utils/logger.dart';
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
    logger.d('build: feedUrl="$feedUrl", collectionId=$collectionId');

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
      throw const NotFoundException();
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
    final loader =
        ref.read(podcastFeedLoaderProvider(feedUrl: feedUrl).notifier);
    final loaderState = ref.read(podcastFeedLoaderProvider(feedUrl: feedUrl));
    if (loader.hasCollectionId ||
        loaderState.loadingState != LoadingState.loadingPodcast) {
      return loaderState;
    }

    if (collectionId != null) {
      await Future<void>.delayed(Duration.zero);
      loader
        ..collectionId = collectionId
        ..startLoading();
    } else {
      final podcast = await ref
          .read(podcastRepositoryProvider)
          .findPodcastBy(feedUrl: feedUrl);
      if (podcast?.collectionId != null) {
        loader.collectionId = podcast!.collectionId;
      }
      loader.startLoading();
    }

    return ref.read(podcastFeedLoaderProvider(feedUrl: feedUrl));
  }
}
