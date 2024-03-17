// Copyright (c) 2024 by HANAI, Tohru.
// Copyright (c) 2024 Reedom, Inc.
// Additional contributions from project contributors.
// All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:audiflow/entities/entities.dart';
import 'package:audiflow/repository/podcast_event.dart';
import 'package:audiflow/repository/repository_provider.dart';
import 'package:audiflow/services/audio/audio_player_event.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:logging/logging.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'podcast_view_info_provider.freezed.dart';
part 'podcast_view_info_provider.g.dart';

@riverpod
class PodcastViewInfo extends _$PodcastViewInfo {
  final _log = Logger('PodcastViewInfo');

  Repository get _repository => ref.read(repositoryProvider);

  @override
  Future<PodcastViewStats> build(String guid) async {
    _log.fine('build $guid');

    final viewStats = await _repository.findPodcastViewStats(guid);

    _listen();
    return viewStats ?? PodcastViewStats(guid: guid);
  }

  void _listen() {
    ref
      ..listen(podcastEventStreamProvider, (_, next) {
        final event = next.valueOrNull;
        if (event
            case PodcastViewStatsUpdatedEvent(viewStats: final viewStats)) {
          state = AsyncData(viewStats);
        }
      })
      ..listen(audioPlayerEventStreamProvider, (_, next) async {
        next.whenData((event) {
          if (event
              case AudioPlayerActionEvent(
                episode: final episode,
                action: final action,
              )) {
            if (action == AudioPlayerAction.play &&
                episode.pguid == state.requireValue.guid) {
              _onEpisodeStartsPlaying(episode);
            }
          }
        });
      });
  }

  void setViewMode(PodcastDetailViewMode viewMode) {
    if (state.valueOrNull == null) {
      return;
    }

    _repository.updatePodcastViewStats(
      PodcastViewStatsUpdateParam(
        guid: state.requireValue.guid,
        viewMode: viewMode,
      ),
    );
  }

  void toggleAscend() {
    if (state.valueOrNull == null) {
      return;
    }

    _repository.updatePodcastViewStats(
      PodcastViewStatsUpdateParam(
        guid: state.requireValue.guid,
        ascend: !state.requireValue.ascend,
      ),
    );
  }

  void toggleAscendSeasonEpisode() {
    if (state.valueOrNull == null) {
      return;
    }

    _repository.updatePodcastViewStats(
      PodcastViewStatsUpdateParam(
        guid: state.requireValue.guid,
        ascendSeasonEpisodes: !state.requireValue.ascendSeasonEpisodes,
      ),
    );
  }

  void _onEpisodeStartsPlaying(Episode episode) {
    final listenedEpisodes =
        Map<String, DateTime>.from(state.requireValue.listenedEpisodes);
    listenedEpisodes[episode.guid] = DateTime.now();

    _repository.updatePodcastViewStats(
      PodcastViewStatsUpdateParam(
        guid: state.requireValue.guid,
        listenedEpisodes: listenedEpisodes,
      ),
    );
  }
}

@freezed
class PodcastViewInfoState with _$PodcastViewInfoState {
  const factory PodcastViewInfoState({
    required PodcastViewStats viewStats,
  }) = _PodcastViewInfoState;
}
