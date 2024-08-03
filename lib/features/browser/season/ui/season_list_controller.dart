import 'package:audiflow/features/browser/common/model/season_filter_mode.dart';
import 'package:audiflow/features/browser/podcast/ui/podcast_details_page/podcast_details_page_controller.dart';
import 'package:audiflow/features/browser/season/data/podcast_seasons_and_stats.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'season_list_controller.freezed.dart';
part 'season_list_controller.g.dart';

@riverpod
class SeasonListController extends _$SeasonListController {
  @override
  SeasonListState build(int pid) {
    var pairs = ref.watch(podcastSeasonsAndStatsProvider(pid)).requireValue;
    final pageState =
        ref.watch(podcastDetailsPageControllerProvider(pid)).requireValue;
    if (pageState.seasonFilterMode == SeasonFilterMode.unplayed) {
      pairs = pairs
          .where(
            (p) =>
                p.stats == null ||
                !p.season.episodeIds
                    .every(p.stats!.completedEpisodeIds.contains),
          )
          .toList();
    }
    if (pageState.seasonsAscending) {
      pairs = pairs.reversed.toList();
    }
    return SeasonListState(
      pairs: pairs,
      filterMode: pageState.seasonFilterMode,
      ascending: pageState.seasonsAscending,
    );
  }
}

@freezed
class SeasonListState with _$SeasonListState {
  const factory SeasonListState({
    required List<SeasonPair> pairs,
    required SeasonFilterMode filterMode,
    required bool ascending,
  }) = _SeasonListState;
}
