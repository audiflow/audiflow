// Copyright (c) 2024 by HANAI, Tohru.
// Copyright (c) 2024 Reedom, Inc.
// Additional contributions from project contributors.
// All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:audiflow/entities/entities.dart';
import 'package:audiflow/repository/repository_provider.dart';
import 'package:audiflow/services/audio/audio_player_event.dart';
import 'package:audiflow/services/audio/audio_player_service.dart';
import 'package:audiflow/services/connectivity/connectivity_state.dart';
import 'package:audiflow/services/queue/queue_manager.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'audio_queue_manager.g.dart';

@Riverpod(keepAlive: true)
class AudioQueueManager extends _$AudioQueueManager {
  Repository get _repository => ref.read(repositoryProvider);

  AudioPlayerService get _audioPlayerService =>
      ref.read(audioPlayerServiceProvider.notifier);

  QueueManager get _queueManager => ref.read(queueManagerProvider.notifier);

  List<QueueItem> get _queue => ref.read(queueManagerProvider).queue;

  List<ConnectivityResult> get _connectivityResult =>
      ref.read(connectivityStateProvider);

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
        _repository.findEpisode(queueItem.eid),
        _repository.findEpisodeStats(queueItem.eid),
      ]);
      final episode = ret[0] as Episode?;
      final stats = ret[1] as EpisodeStats?;
      if (episode == null) {
        await _queueManager.pop();
        continue;
      }

      if (stats?.downloaded == true || _connectivityResult.isConnected) {
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
