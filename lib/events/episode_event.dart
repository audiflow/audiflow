import 'package:audiflow/features/feed/model/model.dart';
import 'package:audiflow/utils/logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'episode_event.g.dart';

sealed class EpisodeEvent {}

class EpisodeUpdatedEvent implements EpisodeEvent {
  const EpisodeUpdatedEvent(this.episode);

  final Episode episode;

  @override
  String toString() {
    return 'EpisodeUpdatedEvent(episode: $episode)';
  }
}

class EpisodesUpdatedEvent implements EpisodeEvent {
  const EpisodesUpdatedEvent(this.episodes);

  final List<Episode> episodes;

  @override
  String toString() {
    return 'EpisodesUpdatedEvent(episodes: $episodes)';
  }
}

class EpisodesAddedEvent implements EpisodeEvent {
  const EpisodesAddedEvent(this.episodes);

  final List<PartialEpisode> episodes;

  @override
  String toString() {
    return 'EpisodesUpdatedEvent(episodes: $episodes)';
  }
}

class EpisodeDeletedEvent implements EpisodeEvent {
  const EpisodeDeletedEvent(this.eid);

  final int eid;

  @override
  String toString() {
    return 'EpisodeDeletedEvent(eid: $eid)';
  }
}

class EpisodesDeletedEvent implements EpisodeEvent {
  const EpisodesDeletedEvent(this.eids);

  final List<int> eids;

  @override
  String toString() {
    return 'EpisodesDeletedEvent(eids: $eids)';
  }
}

class EpisodeStatsUpdatedEvent implements EpisodeEvent {
  const EpisodeStatsUpdatedEvent(this.stats);

  final EpisodeStats stats;

  @override
  String toString() {
    return 'EpisodeStatsUpdatedEvent(stats: $stats)';
  }
}

class EpisodeStatsListUpdatedEvent implements EpisodeEvent {
  const EpisodeStatsListUpdatedEvent(this.statsList);

  final List<EpisodeStats> statsList;

  @override
  String toString() {
    return 'EpisodeStatsListUpdatedEvent(statsList: $statsList)';
  }
}

@Riverpod(keepAlive: true)
class EpisodeEventStream extends _$EpisodeEventStream {
  @override
  Stream<EpisodeEvent> build() async* {}

  void add(EpisodeEvent event) {
    logger.t(() => 'EpisodeEventStream.add: $event');
    state = AsyncData(event);
  }
}
