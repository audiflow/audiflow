import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:seasoning/entities/entities.dart';
import 'package:seasoning/repository/episode_event.dart';
import 'package:seasoning/services/podcast/podcast_service_provider.dart';
import 'package:seasoning/services/queue/queue_manager.dart';

part 'episode_info_provider.freezed.dart';
part 'episode_info_provider.g.dart';

@riverpod
class EpisodeInfo extends _$EpisodeInfo {
  @override
  Future<EpisodeInfoState> build(
    Episode episode, {
    EpisodeStats? stats,
  }) async {
    final queue = ref.read(queueManagerProvider.select((value) => value.queue));
    final queueIndex = queue.indexWhere((item) => item.guid == episode.guid);

    final initial = EpisodeInfoState(
      episode: episode,
      stats: stats ??
          await ref.read(podcastServiceProvider).loadEpisodeStats(episode),
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
        final index =
            next.queue.indexWhere((item) => item.guid == episode.guid);
        final queueIndex = 0 <= index ? index : null;
        if (state.requireValue.queueIndex != queueIndex) {
          state =
              AsyncData(state.requireValue.copyWith(queueIndex: queueIndex));
        }
      })
      ..listen(episodeEventStreamProvider, (_, next) {
        final event = next.valueOrNull;
        switch (event) {
          case EpisodeInsertedEvent(episode: final episode) ||
                EpisodeUpdatedEvent(episode: final episode) ||
                EpisodeDeletedEvent(episode: final episode):
            state = AsyncData(state.requireValue.copyWith(episode: episode));
          case EpisodeStatsUpdatedEvent(stats: final stats):
            state = AsyncData(state.requireValue.copyWith(stats: stats));
          case null:
        }
      });
  }
}

@freezed
class EpisodeInfoState with _$EpisodeInfoState {
  const factory EpisodeInfoState({
    required Episode episode,
    EpisodeStats? stats,
    Downloadable? download,
    int? queueIndex,
  }) = _EpisodeState;
}
