import 'package:audiflow/core/exception/app_exception.dart';
import 'package:audiflow/services/podcast/api/podcast_feed_loader.dart';
import 'package:audiflow/services/podcast/podcast_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'podcast_feed_loader_igniter.g.dart';

@riverpod
Future<PodcastFeedLoaderState> podcastFeedLoaderIgniter(
  PodcastFeedLoaderIgniterRef ref, {
  String? feedUrl,
  int? collectionId,
}) async {
  assert(feedUrl != null || collectionId != null);

  if (feedUrl != null) {
    return ref.watch(
      podcastFeedLoaderProvider(feedUrl: feedUrl, collectionId: collectionId),
    );
  }

  final podcast = await ref
      .read(podcastServiceProvider)
      .findPodcastBy(collectionId: collectionId);
  if (podcast != null) {
    return ref.watch(
      podcastFeedLoaderProvider(
        feedUrl: podcast.feedUrl,
        collectionId: podcast.collectionId ?? collectionId,
      ),
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

  return ref.watch(
    podcastFeedLoaderProvider(
      feedUrl: foundFeedUrl,
      collectionId: collectionId,
    ),
  );
}
