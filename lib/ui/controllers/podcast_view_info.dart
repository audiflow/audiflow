import 'dart:async';

import 'package:audiflow/core/logger.dart';
import 'package:audiflow/entities/entities.dart';
import 'package:audiflow/events/podcast_event.dart';
import 'package:audiflow/repository/repository_provider.dart';
import 'package:audiflow/services/audio/audio_player_event.dart';
import 'package:audiflow/ui/controllers/podcast_details.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'podcast_view_info.freezed.dart';
part 'podcast_view_info.g.dart';

@riverpod
class PodcastViewInfo extends _$PodcastViewInfo {
  Repository get _repository => ref.read(repositoryProvider);

  @override
  Future<PodcastViewStats> build({
    String? feedUrl,
    int? collectionId,
  }) async {
    logger.d('build feedUrl=$feedUrl collectionId=$collectionId');
    final pid = feedUrl != null
        ? Podcast.pidFrom(feedUrl)
        : (await _getPodcast(feedUrl, collectionId))?.id;
    if (pid == null) {
      throw StateError('cancelled');
    }

    final viewStats = await _repository.findPodcastViewStats(pid);
    _listen();
    return viewStats ?? PodcastViewStats(id: pid);
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
                episode.id == state.requireValue.id) {
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
        id: state.requireValue.id,
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
        id: state.requireValue.id,
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
        id: state.requireValue.id,
        ascendSeasonEpisodes: !state.requireValue.ascendSeasonEpisodes,
      ),
    );
  }

  void _onEpisodeStartsPlaying(Episode episode) {
    // final listenedEpisodes =
    //     Map<String, DateTime>.from(state.requireValue.listenedEpisodes);
    // listenedEpisodes[episode.guid] = DateTime.now();
    //
    // _repository.updatePodcastViewStats(
    //   PodcastViewStatsUpdateParam(
    //     id: state.requireValue.id,
    //     listenedEpisodes: listenedEpisodes,
    //   ),
    // );
  }

  Future<Podcast?> _getPodcast(String? feedUrl, int? collectionId) async {
    final completer = Completer<Podcast?>();
    ref
      ..listen(
        podcastDetailsProvider(feedUrl: feedUrl, collectionId: collectionId)
            .select((state) => state.podcast),
        (_, podcast) {
          if (podcast != null) {
            completer.complete(podcast);
          }
        },
        fireImmediately: true,
      )
      ..onDispose(() {
        completer.complete(null);
      });
    return completer.future;
  }
}

@freezed
class PodcastViewInfoState with _$PodcastViewInfoState {
  const factory PodcastViewInfoState({
    required PodcastViewStats viewStats,
  }) = _PodcastViewInfoState;
}
