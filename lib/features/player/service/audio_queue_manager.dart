import 'package:audiflow/common/data/connectivity.dart';
import 'package:audiflow/features/browser/common/data/stats_repository.dart';
import 'package:audiflow/features/feed/data/episode_repository.dart';
import 'package:audiflow/features/player/service/audio_player_service.dart';
import 'package:audiflow/features/queue/model/queue.dart';
import 'package:audiflow/features/queue/service/queue_manager.dart';
import 'package:audiflow/events/audio_player_event.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'audio_queue_manager.g.dart';

@Riverpod(keepAlive: true)
class AudioQueueManager extends _$AudioQueueManager {
  EpisodeRepository get _episodeRepository =>
      ref.read(episodeRepositoryProvider);

  StatsRepository get _statsRepository => ref.read(statsRepositoryProvider);

  AudioPlayerService get _audioPlayerService =>
      ref.read(audioPlayerServiceProvider.notifier);

  QueueManager get _queueManager => ref.read(queueManagerProvider.notifier);

  List<QueueItem> get _queue => ref.read(queueManagerProvider).queue;

  List<ConnectivityResult> get _connectivityResult =>
      ref.read(connectivityProvider);

  @override
  bool build() {
    ref.listen(audioPlayerEventStreamProvider, (_, next) {
      if (next.valueOrNull == null) {
        return;
      }

      switch (next.requireValue) {
        case AudioPlayerActionEvent(
            episode: final episode,
            action: final action
          ):
          if (action == AudioPlayerAction.play) {
            if (_queue.firstOrNull?.eid == episode.id) {
              ref.read(queueManagerProvider.notifier).pop();
            }
          } else if (action == AudioPlayerAction.completed) {
            _playNext();
          }
      }
    });

    return true;
  }

  Future<void> _playNext() async {
    while (_queue.isNotEmpty) {
      final queueItem = _queue.first;
      final ret = await Future.wait([
        _episodeRepository.findEpisode(queueItem.eid),
        _statsRepository.findEpisodeStats(queueItem.eid),
      ]);
      final episode = ret[0] as Episode?;
      final stats = ret[1] as EpisodeStats?;
      if (episode == null) {
        await _queueManager.pop();
        continue;
      }

      if (stats?.downloaded == true || _connectivityResult.hasConnectivity) {
        await _audioPlayerService.loadEpisode(
          episode: episode,
          position: stats?.position ?? Duration.zero,
          autoPlay: true,
        );
        return;
      }

      break;
    }
    await _audioPlayerService.stop();
  }
}
