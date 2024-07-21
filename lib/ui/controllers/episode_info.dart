import 'package:audiflow/entities/entities.dart';
import 'package:audiflow/repository/episode_event.dart';
import 'package:audiflow/services/podcast/podcast_service.dart';
import 'package:audiflow/services/queue/queue_manager.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'episode_info.freezed.dart';
part 'episode_info.g.dart';

@riverpod
class EpisodeInfo extends _$EpisodeInfo {
  @override
  Future<EpisodeInfoState> build(
    Episode episode, {
    EpisodeStats? stats,
  }) async {
    final queue = ref.read(queueManagerProvider.select((value) => value.queue));
    final queueIndex = queue.indexWhere((item) => item.eid == episode.id);

    final values = await Future.wait([
      ref.read(podcastServiceProvider).loadPodcastById(episode.pid),
      stats != null
          ? Future.value(stats)
          : ref.read(podcastServiceProvider).loadEpisodeStats(episode),
      ref.read(podcastServiceProvider).loadEpisodeStats(episode),
    ]);

    final podcast = values[0] as Podcast?;
    if (podcast == null) {
      throw StateError(
        'podcast not found for episode: ${episode.guid}',
      );
    }

    final initial = EpisodeInfoState(
      podcast: podcast,
      episode: episode,
      stats: values[1] as EpisodeStats?,
      queueIndex: 0 <= queueIndex ? queueIndex : null,
    );

    _listen(episode);
    return initial;
  }

  void _listen(Episode episode) {
    ref
      ..listen(queueManagerProvider, (_, next) {
        if (!state.hasValue) {
          return;
        }
        final index = next.queue.indexWhere((item) => item.eid == episode.id);
        final queueIndex = 0 <= index ? index : null;
        if (state.requireValue.queueIndex != queueIndex) {
          state =
              AsyncData(state.requireValue.copyWith(queueIndex: queueIndex));
        }
      })
      ..listen(episodeEventStreamProvider, (_, next) {
        final event = next.valueOrNull;
        switch (event) {
          case EpisodeUpdatedEvent(episode: final episode) ||
                EpisodeDeletedEvent(episode: final episode):
            if (episode.id == state.requireValue.episode.id) {
              state = AsyncData(state.requireValue.copyWith(episode: episode));
            }
          case EpisodeStatsUpdatedEvent(stats: final stats):
            if (stats.id == state.requireValue.episode.id) {
              state = AsyncData(state.requireValue.copyWith(stats: stats));
            }
          case null:
        }
      });
  }
}

@freezed
class EpisodeInfoState with _$EpisodeInfoState {
  const factory EpisodeInfoState({
    required Podcast podcast,
    required Episode episode,
    EpisodeStats? stats,
    Downloadable? download,
    int? queueIndex,
  }) = _EpisodeState;
}
