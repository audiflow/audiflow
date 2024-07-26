import 'dart:async';

import 'package:audiflow/events/episode_event.dart';
import 'package:audiflow/features/browser/common/data/stats_repository.dart';
import 'package:audiflow/features/browser/podcast/model/season.dart';
import 'package:audiflow/features/feed/model/model.dart';
import 'package:collection/collection.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'podcast_season_info.freezed.dart';
part 'podcast_season_info.g.dart';

@riverpod
class PodcastSeasonInfo extends _$PodcastSeasonInfo {
  StatsRepository get _statsRepository => ref.read(statsRepositoryProvider);

  @override
  Future<PodcastSeasonInfoState> build(Season season) async {
    final statsList = await _statsRepository
        .findEpisodeStatsList(season.episodes.map((e) => e.id));
    _listen();
    return PodcastSeasonInfoState(
      episodes: season.episodes,
      statsList: statsList.whereNotNull().toList(),
    );
  }

  void _listen() {
    ref.listen(episodeEventStreamProvider, (_, next) {
      final event = next.requireValue;
      if (event case EpisodeUpdatedEvent(episode: final episode)) {
        final episodes = state.requireValue.episodes;
        if (!episodes.any(
          (e) => e.pid == episode.pid && e.season == episode.season,
        )) {
          return;
        }
        final oldEpisode = episodes.firstWhereOrNull(
          (e) => e.guid == episode.guid,
        );
        if (oldEpisode != null) {
          state = AsyncData(
            state.requireValue.copyWith(
              episodes: episodes
                  .map((e) => e.guid == episode.guid ? episode : e)
                  .toList(),
            ),
          );
        } else {
          state = AsyncData(
            state.requireValue.copyWith(
              episodes: [...episodes, episode],
            ),
          );
        }
      } else if (event case EpisodeStatsUpdatedEvent(stats: final stats)) {
        final statsList = state.requireValue.statsList;
        final oldStats = statsList.firstWhereOrNull((s) => s.pid == stats.pid);
        if (oldStats == null || oldStats.played == stats.played) {
          return;
        }

        state = AsyncData(
          state.requireValue.copyWith(
            statsList: statsList
                .map((s) => s.pid == stats.pid ? event.stats : s)
                .toList(),
          ),
        );
      }
    });
  }
}

@freezed
class PodcastSeasonInfoState with _$PodcastSeasonInfoState {
  const factory PodcastSeasonInfoState({
    required List<Episode> episodes,
    required List<EpisodeStats> statsList,
  }) = _PodcastSeasonInfoState;
}

extension PodcastSeasonInfoStateExt on PodcastSeasonInfoState {
  int get playedCount {
    return statsList.where((stats) => stats.played).length;
  }
}
