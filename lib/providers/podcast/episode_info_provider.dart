import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:seasoning/entities/entities.dart';
import 'package:seasoning/events/episode_event.dart';
import 'package:seasoning/providers/podcast_service_provider.dart';

part 'episode_info_provider.freezed.dart';
part 'episode_info_provider.g.dart';

@riverpod
class EpisodeInfo extends _$EpisodeInfo {
  @override
  Future<EpisodeInfoState> build(
    Episode episode, {
    EpisodeStats? stats,
  }) async {
    final initial = EpisodeInfoState(
      episode: episode,
      stats: stats ??
          await ref.read(podcastServiceProvider).loadEpisodeStats(episode),
    );

    _listen();
    return initial;
  }

  void _listen() {
    final sub =
        ref.read(podcastServiceProvider).episodeListener.listen((event) {
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
  }) = _EpisodeState;
}
