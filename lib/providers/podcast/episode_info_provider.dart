import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:seasoning/entities/entities.dart';
import 'package:seasoning/repository/episode_event.dart';
import 'package:seasoning/services/podcast/mobile_podcast_service.dart';
import 'package:seasoning/services/queue/default_queue_manager.dart';

part 'episode_info_provider.freezed.dart';
part 'episode_info_provider.g.dart';

@riverpod
class EpisodeInfo extends _$EpisodeInfo {
  @override
  Future<EpisodeInfoState> build(
    Episode episode, {
    EpisodeStats? stats,
  }) async {
    // ignore: avoid_manual_providers_as_generated_provider_dependency
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
    // ignore: avoid_manual_providers_as_generated_provider_dependency
    ref.listen(queueManagerProvider, (_, next) {
      if (!state.hasValue) {
        return;
      }
      final index = next.queue.indexWhere((item) => item.guid == episode.guid);
      final queueIndex = 0 <= index ? index : null;
      if (state.requireValue.queueIndex != queueIndex) {
        state = AsyncData(state.requireValue.copyWith(queueIndex: queueIndex));
      }
    });

    final sub = ref.read(podcastServiceProvider).episodeStream.listen((event) {
      switch (event) {
        case EpisodeInsertedEvent(episode: final episode) ||
              EpisodeUpdatedEvent(episode: final episode) ||
              EpisodeDeletedEvent(episode: final episode):
          state = AsyncData(state.requireValue.copyWith(episode: episode));
        case EpisodeStatsUpdatedEvent(stats: final stats):
          state = AsyncData(state.requireValue.copyWith(stats: stats));
      }
    });
    ref.onDispose(sub.cancel);
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
