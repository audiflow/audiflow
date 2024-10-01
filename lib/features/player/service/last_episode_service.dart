import 'package:audiflow/features/browser/common/data/episode_stats_repository/episode_stats_repository.dart';
import 'package:audiflow/features/feed/data/episode_repository.dart';
import 'package:audiflow/features/player/data/player_state_repository.dart';
import 'package:audiflow/features/player/service/audio_player_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'last_episode_service.g.dart';

@riverpod
LastEpisodeService lastEpisodeService(LastEpisodeServiceRef ref) {
  return LastEpisodeService(ref);
}

class LastEpisodeService {
  LastEpisodeService(this._ref);

  final Ref _ref;

  PlayerStateRepository get _playerStateRepository =>
      _ref.read(playerStateRepositoryProvider);

  EpisodeRepository get _episodeRepository =>
      _ref.read(episodeRepositoryProvider);

  EpisodeStatsRepository get _episodeStatsRepository =>
      _ref.read(episodeStatsRepositoryProvider);

  AudioPlayerService get _audioPlayerService =>
      _ref.read(audioPlayerServiceProvider.notifier);

  Future<void> resumeEpisode() async {
    final eid = await _playerStateRepository.playingEpisodeId();
    if (eid == null) {
      return;
    }

    final values = await Future.wait([
      _episodeRepository.findEpisode(eid),
      _episodeStatsRepository.findEpisodeStats(eid),
    ]);
    final episode = values[0] as Episode?;
    final stats = values[1] as EpisodeStats?;
    if (episode != null) {
      await _audioPlayerService.loadEpisode(
        episode: episode,
        position: stats?.position ?? Duration.zero,
        duration: stats?.duration ?? episode.duration ?? Duration.zero,
        autoPlay: false,
      );
    }
  }
}
