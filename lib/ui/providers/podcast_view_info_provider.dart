// Copyright (c) 2024 by HANAI, Tohru.
// Copyright (c) 2024 Reedom, Inc.
// Additional contributions from project contributors.
// All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:audiflow/entities/entities.dart';
import 'package:audiflow/repository/podcast_event.dart';
import 'package:audiflow/repository/repository_provider.dart';
import 'package:audiflow/services/audio/audio_player_event.dart';
import 'package:audiflow/ui/providers/podcast_info_provider.dart';
import 'package:audiflow/ui/providers/podcast_seasons_provider.dart';
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
    if (viewStats != null) {
      return viewStats;
    }

    // If the viewStats is not found, determine the default viewMode by the
    // existence of seasons.
    return _determineDefaultViewMode(guid);
  }

  Future<PodcastViewStats> _determineDefaultViewMode(String guid) async {
    final podcastState =
        ref.watch(podcastInfoProvider(guid, needsEpisodes: true));
    final podcast = podcastState.valueOrNull?.podcast;

    final completer = Completer<PodcastViewStats>();
    if (podcast == null) {
      ref.onDispose(() {
        completer.complete(PodcastViewStats(guid: guid));
      });
      return completer.future;
    }

    final seasonState = ref.watch(podcastSeasonsProvider(podcast));
    if (seasonState.valueOrNull == null) {
      ref.onDispose(() {
        completer.complete(PodcastViewStats(guid: guid));
      });
      return completer.future;
    }

    final viewMode = seasonState.valueOrNull!.isNotEmpty
        ? PodcastDetailViewMode.seasons
        : PodcastDetailViewMode.episodes;
    await _repository.updatePodcastViewStats(
      PodcastViewStatsUpdateParam(guid: guid, viewMode: viewMode),
    );
    return PodcastViewStats(guid: guid, viewMode: viewMode);
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
