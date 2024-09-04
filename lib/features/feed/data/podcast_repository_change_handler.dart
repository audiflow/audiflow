import 'package:audiflow/events/podcast_event.dart';
import 'package:audiflow/features/feed/data/podcast_repository.dart';
import 'package:audiflow/features/feed/model/model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';

class PodcastRepositoryChangeHandler implements PodcastRepository {
  PodcastRepositoryChangeHandler(this._ref, this._inner);

  final Ref _ref;
  final PodcastRepository _inner;

  @override
  Future<Podcast?> findPodcast(Id id) => _inner.findPodcast(id);

  @override
  Future<Podcast?> findPodcastBy({
    String? feedUrl,
    int? collectionId,
  }) =>
      _inner.findPodcastBy(
        feedUrl: feedUrl,
        collectionId: collectionId,
      );

  @override
  Future<void> savePodcast(Podcast podcast) async {
    await _inner.savePodcast(podcast);
    _ref
        .read(podcastEventStreamProvider.notifier)
        .add(PodcastUpdatedEvent(podcast));
  }
}
