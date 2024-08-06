import 'dart:async';

import 'package:audiflow/events/podcast_event.dart';
import 'package:audiflow/exceptions/app_exception.dart';
import 'package:audiflow/features/feed/data/podcast_repository.dart';
import 'package:audiflow/features/feed/model/model.dart';
import 'package:audiflow/features/feed/service/podcast_feed_loader_igniter.dart';
import 'package:audiflow/utils/logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'podcast_auto_loader.g.dart';

@riverpod
class PodcastAutoLoader extends _$PodcastAutoLoader {
  PodcastRepository get _podcastRepository =>
      ref.read(podcastRepositoryProvider);

  final _completer = Completer<Podcast?>();

  @override
  Future<Podcast?> build({
    String? feedUrl,
    int? collectionId,
  }) async {
    logger.d('build: feedUrl="$feedUrl", collectionId=$collectionId');
    assert(feedUrl != null || collectionId != null);

    ref.onCancel(() {
      if (!_completer.isCompleted) {
        _completer.completeError(const NotFoundException());
      }
    });

    _listenRepository();
    _listenFeedLoader();
    final podcast = feedUrl != null
        ? await _setupWithFeedUrl(feedUrl, collectionId)
        : collectionId != null
            ? await _setupWithCollectionId(collectionId)
            : null;
    return podcast ?? _completer.future;
  }

  void _listenFeedLoader() {
    ref.listen(
      podcastFeedLoaderIgniterProvider(
        feedUrl: feedUrl,
        collectionId: collectionId,
      ),
      (_, next) {},
    );
  }

  void _listenRepository() {
    bool isTargetPodcast(Podcast podcast) {
      if (collectionId != null) {
        return podcast.collectionId == collectionId;
      } else if (feedUrl != null) {
        return podcast.feedUrl == feedUrl;
      }
      return false;
    }

    ref.listen(podcastEventStreamProvider, (_, next) {
      next.whenData((event) {
        switch (event) {
          case PodcastSubscribedEvent() ||
                PodcastUnsubscribedEvent() ||
                PodcastStatsUpdatedEvent():
            break;
          case PodcastUpdatedEvent(podcast: final podcast):
            if (isTargetPodcast(podcast)) {
              state = AsyncData(podcast);
              if (!_completer.isCompleted) {
                _completer.complete(podcast);
              }
            }
        }
      });
    });
  }

  Future<Podcast?> _setupWithFeedUrl(
    String feedUrl,
    int? collectionId,
  ) async {
    return _podcastRepository.findPodcastBy(feedUrl: feedUrl);
  }

  Future<Podcast?> _setupWithCollectionId(int collectionId) async {
    return _podcastRepository.findPodcastBy(collectionId: collectionId);
  }
}
