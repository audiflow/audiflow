import 'package:audiflow/features/browser/common/data/episode_stats_repository/episode_stats_repository.dart';
import 'package:audiflow/features/player/service/audio_player_service.dart';
import 'package:audiflow/features/queue/data/queue_top_episode_provider.dart';
import 'package:audiflow/features/queue/service/queue_controller.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'expandable_player_controller.freezed.dart';
part 'expandable_player_controller.g.dart';

@riverpod
class ExpandablePlayerController extends _$ExpandablePlayerController {
  AudioPlayerState? get _audioPlayerState =>
      ref.read(audioPlayerServiceProvider);

  AudioPlayerService get _audioPlayerService =>
      ref.read(audioPlayerServiceProvider.notifier);

  EpisodeStatsRepository get _episodeStatsRepository =>
      ref.read(episodeStatsRepositoryProvider);

  QueueController get _queueController =>
      ref.read(queueControllerProvider.notifier);

  @override
  ExpandablePlayerState build() {
    _listen();

    final audioEpisode = ref.read(audioPlayerServiceProvider)?.episode;
    final queueTopEpisode = ref.read(queueTopEpisodeProvider);
    return ExpandablePlayerState(
      audioEpisode: audioEpisode,
      queueTopEpisode: queueTopEpisode,
      episode: audioEpisode ?? queueTopEpisode,
    );
  }

  Future<void> togglePlayPause() async {
    final episode = state.episode;
    if (episode == null) {
      return;
    }

    if (_audioPlayerState?.episode.id == episode.id) {
      await _audioPlayerService.togglePlayPause();
    } else {
      if (state.audioEpisode == null && state.queueTopEpisode != null) {
        await _queueController.pop();
      }
      final episodeStats =
          await _episodeStatsRepository.findEpisodeStats(episode.id);
      await _audioPlayerService.loadEpisode(
        episode: episode,
        position: episodeStats?.position ?? Duration.zero,
        autoPlay: true,
      );
    }
  }

  Future<void> fastForward() => _audioPlayerService.fastForward();

  Future<void> rewind() => _audioPlayerService.rewind();

  void _listen() {
    ref
      ..listen(audioPlayerServiceProvider.select((state) => state?.episode),
          (_, episode) {
        state = ExpandablePlayerState(
          audioEpisode: episode,
          episode: episode ?? state.episode,
        );
      })
      ..listen(queueTopEpisodeProvider, (_, episode) {
        state = ExpandablePlayerState(
          queueTopEpisode: episode,
          episode: state.audioEpisode ?? episode ?? state.episode,
        );
      });
  }
}

@freezed
class ExpandablePlayerState with _$ExpandablePlayerState {
  const factory ExpandablePlayerState({
    Episode? audioEpisode,
    Episode? queueTopEpisode,
    Episode? episode,
  }) = _ExpandablePlayerState;
}
