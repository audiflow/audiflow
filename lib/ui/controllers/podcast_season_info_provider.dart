import 'dart:async';

import 'package:audiflow/entities/entities.dart';
import 'package:audiflow/repository/episode_event.dart';
import 'package:audiflow/repository/repository_provider.dart';
import 'package:collection/collection.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'podcast_season_info_provider.freezed.dart';
part 'podcast_season_info_provider.g.dart';

@riverpod
class PodcastSeasonInfo extends _$PodcastSeasonInfo {
  Repository get _repository => ref.read(repositoryProvider);

  @override
  Future<PodcastSeasonInfoState> build(Season season) async {
    final statsList = await _repository
        .findEpisodeStatsList(season.episodes.map((e) => e.guid));
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
          (e) => e.pguid == episode.guid && e.season == episode.season,
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
        final oldStats =
            statsList.firstWhereOrNull((s) => s.guid == stats.guid);
        if (oldStats == null || oldStats.played == stats.played) {
          return;
        }

        state = AsyncData(
          state.requireValue.copyWith(
            statsList: statsList
                .map((s) => s.guid == stats.guid ? event.stats : s)
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
