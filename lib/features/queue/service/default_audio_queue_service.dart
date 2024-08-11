import 'package:audiflow/events/audio_player_event.dart';
import 'package:audiflow/features/browser/common/data/episode_stats_repository/episode_stats_repository.dart';
import 'package:audiflow/features/browser/common/model/episode_filter_mode.dart';
import 'package:audiflow/features/feed/data/episode_repository.dart';
import 'package:audiflow/features/player/service/audio_player_service.dart';
import 'package:audiflow/features/queue/service/audio_queue_service.dart';
import 'package:audiflow/features/queue/service/manual_queue_controller.dart';
import 'package:audiflow/features/queue/service/smart_queue_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DefaultAudioQueueService implements AudioQueueService {
  DefaultAudioQueueService(this.ref) {
    _listen();
  }

  final Ref ref;

  EpisodeRepository get _episodeRepository =>
      ref.read(episodeRepositoryProvider);

  EpisodeStatsRepository get _episodeStatsRepository =>
      ref.read(episodeStatsRepositoryProvider);

  AudioPlayerService get _audioPlayerService =>
      ref.read(audioPlayerServiceProvider.notifier);

  ManualQueueController get _manualQueueController =>
      ref.read(manualQueueControllerProvider.notifier);

  SmartQueueController get _smartQueueController =>
      ref.read(smartQueueControllerProvider.notifier);

  void _listen() {
    ref.listen(audioPlayerEventStreamProvider, (_, next) {
      if (next.valueOrNull == null) {
        return;
      }

      switch (next.requireValue) {
        case AudioPlayerActionEvent(action: final action):
          if (action == AudioPlayerAction.completed) {
            _playNext();
          }
      }
    });
  }

  Future<void> playFromPodcastDetailsPage({
    required Episode start,
    required EpisodeFilterMode filterMode,
  }) async {
    await _smartQueueController.buildFromPodcastDetailsPage(
      start: start,
      filterMode: filterMode,
    );
    await _play(eid: start.id);
  }

  Future<bool> _play({required int eid}) async {
    final ret = await Future.wait([
      _episodeRepository.findEpisode(eid),
      _episodeStatsRepository.findEpisodeStats(eid),
    ]);

    final episode = ret[0] as Episode?;
    final stats = ret[1] as EpisodeStats?;
    if (episode == null) {
      return false;
    }

    await _audioPlayerService.loadEpisode(
      episode: episode,
      position: stats?.position ?? Duration.zero,
      autoPlay: true,
    );
    return true;
  }

  Future<bool> _playNext() async {
    var item = await _manualQueueController.pop();
    if (item != null) {
      return _play(eid: item.eid);
    }

    item = await _smartQueueController.pop();
    if (item != null) {
      return _play(eid: item.eid);
    }

    await _audioPlayerService.stop();
    return false;
  }
}
