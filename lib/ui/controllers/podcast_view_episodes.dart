import 'dart:async';

import 'package:audiflow/core/logger.dart';
import 'package:audiflow/entities/entities.dart';
import 'package:audiflow/repository/download_event.dart';
import 'package:audiflow/repository/repository_provider.dart';
import 'package:audiflow/services/audio/audio_player_event.dart';
import 'package:audiflow/ui/controllers/podcast_view_info_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'podcast_view_episodes.g.dart';

@riverpod
class PodcastViewEpisodes extends _$PodcastViewEpisodes {
  Repository get _repository => ref.read(repositoryProvider);

  @override
  Future<List<Episode>> build(String guid) async {
    logger.d('build $guid');

    _listen(guid);
    final completer = Completer<List<Episode>>();
    ref.onDispose(() => completer.complete([]));
    return completer.future;
  }

  void _listen(String guid) {
    Podcast? podcast;
    PodcastDetailViewMode? viewMode;
    bool? ascend;

    Future<void> onUpdate() async {
      if (podcast != null && viewMode != null && ascend != null) {
        final episodes =
            await _getEpisodes(podcast!, viewMode!, ascend: ascend!);
        state = AsyncData(episodes);
      }
    }

    ref
      ..listen(
        podcastInfoProvider(guid, needsEpisodes: true)
            .selectAsync((data) => data.podcast),
        (_, next) async {
          podcast = await next;
          await onUpdate();
        },
        fireImmediately: true,
      )
      ..listen(
        podcastViewInfoProvider(guid)
            .selectAsync((data) => (data.viewMode, data.ascend)),
        (_, next) async {
          (viewMode, ascend) = await next;
          await onUpdate();
        },
        fireImmediately: true,
      )
      ..listen(downloadEventStreamProvider, (_, next) {
        if (podcast == null || viewMode != PodcastDetailViewMode.downloaded) {
          return;
        }

        final event = next.requireValue;
        if (event
            case DownloadUpdatedEvent(download: final download) ||
                DownloadDeletedEvent(download: final download)) {
          if (download.state == DownloadState.downloaded &&
              podcast!.episodes.any((e) => e.guid == download.guid)) {
            onUpdate();
          }
        }
      })
      ..listen(audioPlayerEventStreamProvider, (_, next) {
        if (podcast == null ||
            ![
              PodcastDetailViewMode.unplayed,
              PodcastDetailViewMode.played,
            ].contains(viewMode)) {
          return;
        }

        final event = next.requireValue;
        if (event
            case AudioPlayerActionEvent(
              episode: final episode,
              action: final action
            )) {
          if (action == AudioPlayerAction.completed &&
              podcast!.episodes.any((e) => e.guid == episode.guid)) {
            onUpdate();
          }
        }
      });
  }

  Future<List<Episode>> _getEpisodes(
    Podcast podcast,
    PodcastDetailViewMode viewMode, {
    required bool ascend,
  }) async {
    switch (viewMode) {
      case PodcastDetailViewMode.seasons:
        return [];
      case PodcastDetailViewMode.episodes:
        return ascend ? podcast.episodes.reversed.toList() : podcast.episodes;
      case PodcastDetailViewMode.played:
        return _filterEpisodesBy(
          viewMode,
          podcast.episodes,
          await _repository.findPlayedEpisodeStatsList(podcast.guid),
          ascend: ascend,
        );
      case PodcastDetailViewMode.unplayed:
        return _filterEpisodesBy(
          viewMode,
          podcast.episodes,
          await _repository.findPlayedEpisodeStatsList(podcast.guid),
          ascend: ascend,
        );
      case PodcastDetailViewMode.downloaded:
        return _filterEpisodesBy(
          viewMode,
          podcast.episodes,
          await _repository.findDownloadedEpisodeStatsList(podcast.guid),
          ascend: ascend,
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
}
