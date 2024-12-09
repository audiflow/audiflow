import 'package:audiflow/features/feed/model/model.dart';
import 'package:audiflow/utils/logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'podcast_event.g.dart';

sealed class PodcastEvent {}

class PodcastSubscribedEvent implements PodcastEvent {
  const PodcastSubscribedEvent(this.podcast, this.stats);

  final Podcast podcast;
  final PodcastStats stats;

  @override
  String toString() {
    return 'PodcastSubscribedEvent(podcast: $podcast, stats: $stats)';
  }
}

class PodcastUnsubscribedEvent implements PodcastEvent {
  const PodcastUnsubscribedEvent(this.podcast, this.stats);

  final Podcast podcast;
  final PodcastStats stats;

  @override
  String toString() {
    return 'PodcastUnsubscribedEvent(podcast: $podcast, stats: $stats)';
  }
}

class PodcastUpdatedEvent implements PodcastEvent {
  const PodcastUpdatedEvent(this.podcast, {this.stats});

  final Podcast podcast;
  final PodcastStats? stats;

  @override
  String toString() {
    return 'PodcastUpdatedEvent(podcast: $podcast, stats: $stats)';
  }
}

class PodcastStatsUpdatedEvent implements PodcastEvent {
  const PodcastStatsUpdatedEvent(this.stats);

  final PodcastStats stats;

  @override
  String toString() {
    return 'PodcastStatsUpdatedEvent(stats: $stats)';
  }
}

@Riverpod(keepAlive: true)
class PodcastEventStream extends _$PodcastEventStream {
  @override
  Stream<PodcastEvent> build() async* {}

  void add(PodcastEvent event) {
    logger.t(() => 'PodcastEventStream.add: $event');
    state = AsyncData(event);
  }
}
