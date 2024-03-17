// Copyright (c) 2024 by HANAI, Tohru.
// Copyright (c) 2024 Reedom, Inc.
// Additional contributions from project contributors.
// All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:audiflow/entities/entities.dart';
import 'package:audiflow/repository/download_event.dart';
import 'package:audiflow/repository/repository_provider.dart';
import 'package:audiflow/services/audio/audio_player_event.dart';
import 'package:audiflow/ui/providers/podcast_view_info_provider.dart';
import 'package:logging/logging.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'podcast_view_episodes_provider.g.dart';

@riverpod
class PodcastViewEpisodes extends _$PodcastViewEpisodes {
  final _log = Logger('PodcastViewEpisodes');

  Repository get _repository => ref.read(repositoryProvider);

  @override
  Future<List<Episode>> build(Podcast podcast) async {
    _log.fine('build ${podcast.title}');

    final viewStats = ref.watch(podcastViewInfoProvider(podcast.guid));
    final viewMode = viewStats.valueOrNull?.viewMode;

    if (viewMode != null) {
      _listenStats(viewMode, podcast);
    }

    switch (viewMode) {
      case null:
      case PodcastDetailViewMode.seasons:
        return [];
      case PodcastDetailViewMode.episodes:
        return viewStats.requireValue.ascend
            ? podcast.episodes.reversed.toList()
            : podcast.episodes;
      case PodcastDetailViewMode.played:
        return _filterEpisodesBy(
          viewMode,
          podcast.episodes,
          await _repository.findPlayedEpisodeStatsList(podcast.guid),
          ascend: viewStats.requireValue.ascend,
        );
      case PodcastDetailViewMode.unplayed:
        return _filterEpisodesBy(
          viewMode,
          podcast.episodes,
          await _repository.findPlayedEpisodeStatsList(podcast.guid),
          ascend: viewStats.requireValue.ascend,
        );
      case PodcastDetailViewMode.downloaded:
        return _filterEpisodesBy(
          viewMode,
          podcast.episodes,
          await _repository.findDownloadedEpisodeStatsList(podcast.guid),
          ascend: viewStats.requireValue.ascend,
        );
    }
  }

  List<Episode> _filterEpisodesBy(
    PodcastDetailViewMode viewMode,
    List<Episode> episodes,
    List<EpisodeStats> statsList, {
    required bool ascend,
  }) {
    final statsMap = statsList.fold<Map<String, EpisodeStats>>(
      {},
      (map, stats) => map..[stats.guid] = stats,
    );
    final list = viewMode == PodcastDetailViewMode.unplayed
        ? episodes
            .where((episode) => !statsMap.containsKey(episode.guid))
            .toList()
        : episodes
            .where((episode) => statsMap.containsKey(episode.guid))
            .toList();
    return ascend ? list.reversed.toList() : list;
  }

  void _listenStats(PodcastDetailViewMode viewMode, Podcast podcast) {
    if (viewMode == PodcastDetailViewMode.downloaded) {
      ref.listen(downloadEventStreamProvider, (_, next) {
        final event = next.requireValue;
        if (event case DownloadUpdatedEvent(download: final download)) {
          if (download.state == DownloadState.downloaded &&
              podcast.episodes.any((e) => e.guid == download.guid)) {
            ref.invalidateSelf();
          }
        }
      });
    }
    if ([PodcastDetailViewMode.unplayed, PodcastDetailViewMode.played]
        .contains(viewMode)) {
      ref.listen(audioPlayerEventStreamProvider, (_, next) {
        final event = next.requireValue;
        if (event
            case AudioPlayerActionEvent(
              episode: final episode,
              action: final action
            )) {
          if (action == AudioPlayerAction.completed &&
              podcast.episodes.any((e) => e.guid == episode.guid)) {
            ref.invalidateSelf();
          }
        }
      });
    }
  }
}
