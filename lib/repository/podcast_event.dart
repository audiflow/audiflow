import 'package:seasoning/entities/entities.dart';

sealed class PodcastEvent {}

class PodcastSubscribedEvent implements PodcastEvent {
  const PodcastSubscribedEvent(this.podcast, this.stats);

  final Podcast podcast;
  final PodcastStats stats;
}

class PodcastUnsubscribedEvent implements PodcastEvent {
  const PodcastUnsubscribedEvent(this.podcast, this.stats);

  final Podcast podcast;
  final PodcastStats stats;
}

class PodcastUpdatedEvent implements PodcastEvent {
  const PodcastUpdatedEvent(this.id, this.podcast);

  final int id;
  final Podcast podcast;
}

class PodcastStatsUpdatedEvent implements PodcastEvent {
  const PodcastStatsUpdatedEvent(this.stats);

  final PodcastStats stats;
}
