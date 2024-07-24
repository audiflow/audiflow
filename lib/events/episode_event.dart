import 'package:audiflow/features/feed/model/model.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'episode_event.g.dart';

sealed class EpisodeEvent {}

class EpisodeUpdatedEvent implements EpisodeEvent {
  const EpisodeUpdatedEvent(this.episode);

  final Episode episode;
}

class EpisodesAddedEvent implements EpisodeEvent {
  const EpisodesAddedEvent(this.episodes);

  final List<PartialEpisode> episodes;
}

class EpisodeDeletedEvent implements EpisodeEvent {
  const EpisodeDeletedEvent(this.episode);

  final Episode episode;
}

class EpisodeStatsUpdatedEvent implements EpisodeEvent {
  const EpisodeStatsUpdatedEvent(this.stats);

  final EpisodeStats stats;
}

@Riverpod(keepAlive: true)
class EpisodeEventStream extends _$EpisodeEventStream {
  @override
  Stream<EpisodeEvent> build() async* {}

  void add(EpisodeEvent event) {
    state = AsyncData(event);
  }
}
