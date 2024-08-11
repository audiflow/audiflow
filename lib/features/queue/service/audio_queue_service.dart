import 'package:audiflow/common/data/connectivity.dart';
import 'package:audiflow/events/audio_player_event.dart';
import 'package:audiflow/features/browser/common/data/episode_stats_repository/episode_stats_repository.dart';
import 'package:audiflow/features/browser/common/model/episode_filter_mode.dart';
import 'package:audiflow/features/download/data/download_repository.dart';
import 'package:audiflow/features/download/model/downloadable.dart';
import 'package:audiflow/features/feed/data/episode_repository.dart';
import 'package:audiflow/features/player/service/audio_player_service.dart';
import 'package:audiflow/features/queue/data/queue_repository.dart';
import 'package:audiflow/features/queue/model/auto_queue_builder_info.dart';
import 'package:audiflow/features/queue/model/queue.dart';
import 'package:audiflow/features/queue/service/auto_queue_builder/auto_queue_builder.dart';
import 'package:audiflow/features/queue/service/auto_queue_builder/auto_queue_from_podcast_details_page.dart';
import 'package:audiflow/features/queue/service/queue_controller.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'audio_queue_service.g.dart';

@Riverpod(keepAlive: true)
AudioQueueService audioQueueService(AudioQueueServiceRef ref) {
  // * Override this in the main method
  throw UnimplementedError();
}

class AudioQueueService {
  AudioQueueService(this.ref) {
    _listen();
  }

  final Ref ref;

  EpisodeRepository get _episodeRepository =>
      ref.read(episodeRepositoryProvider);

  EpisodeStatsRepository get _episodeStatsRepository =>
      ref.read(episodeStatsRepositoryProvider);

  DownloadRepository get _downloadRepository =>
      ref.read(downloadRepositoryProvider);

  AudioPlayerService get _audioPlayerService =>
      ref.read(audioPlayerServiceProvider.notifier);

  QueueController get _queueController =>
      ref.read(queueControllerProvider.notifier);

  List<QueueItem> get _queue => ref.read(queueControllerProvider).queue;

  List<ConnectivityResult> get _connectivityResult =>
      ref.read(connectivityProvider);

  AutoQueueBuilder? _autoQueueBuilder;

  void _listen() {
    ref.listen(audioPlayerEventStreamProvider, (_, next) {
      switch (next.valueOrNull) {
        case AudioPlayerActionEvent(
            episode: final episode,
            action: final action
          ):
          if (action == AudioPlayerAction.play) {
            if (_queue.firstOrNull?.eid == episode.id) {
              _queueController.pop();
            }
          } else if (action == AudioPlayerAction.completed) {
            _playNext();
          }
        case null:
      }
    });
  }

  Future<void> playFromPodcastDetailsPage({
    required Episode start,
    required EpisodeFilterMode filterMode,
  }) async {
    final builder = ref.read(autoQueueFromPodcastDetailsPageProvider.notifier)
      ..setup(start: start, filterMode: filterMode);
    _autoQueueBuilder?.clear();
    _autoQueueBuilder = builder;

    final json = builder.encodeState();
    await ref
        .read(queueRepositoryProvider)
        .saveAutoQueueBuilderData(AutoQueueBuilderType.detailsPage, json);
    await _play(eid: start.id);
  }

  Future<bool> _play({required int eid}) async {
    final ret = await Future.wait([
      _episodeRepository.findEpisode(eid),
      _episodeStatsRepository.findEpisodeStats(eid),
      _downloadRepository.findDownload(eid),
    ]);

    final episode = ret[0] as Episode?;
    final stats = ret[1] as EpisodeStats?;
    final download = ret[2] as Downloadable?;
    if (episode == null) {
      return false;
    }

    if (download?.downloaded == true || _connectivityResult.hasConnectivity) {
      await _audioPlayerService.loadEpisode(
        episode: episode,
        position: stats?.position ?? Duration.zero,
        autoPlay: true,
      );
      return true;
    }
    return false;
  }

  Future<void> _playNext() async {
    while (_queue.isNotEmpty) {
      final queueItem = _queue.first;
      final ret = await Future.wait([
        _episodeRepository.findEpisode(queueItem.eid),
        _episodeStatsRepository.findEpisodeStats(queueItem.eid),
        _downloadRepository.findDownload(queueItem.eid),
      ]);
      final episode = ret[0] as Episode?;
      final stats = ret[1] as EpisodeStats?;
      final download = ret[2] as Downloadable?;
      if (episode == null) {
        await _queueController.pop();
        continue;
      }

      if (download?.downloaded == true || _connectivityResult.hasConnectivity) {
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
