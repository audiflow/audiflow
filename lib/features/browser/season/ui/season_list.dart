import 'package:audiflow/common/ui/fill_remaining_error.dart';
import 'package:audiflow/common/ui/fill_remaining_loading.dart';
import 'package:audiflow/features/browser/podcast/ui/podcast_seasons.dart';
import 'package:audiflow/features/browser/podcast/ui/podcast_view_info_controller.dart';
import 'package:audiflow/features/browser/season/ui/season_tile.dart';
import 'package:audiflow/features/feed/model/model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SeasonList extends ConsumerWidget {
  const SeasonList({
    super.key,
    required this.podcast,
    this.icon = _defaultIcon,
    this.emptyMessage = '',
  });

  final Podcast podcast;
  final IconData icon;
  final String emptyMessage;

  static const _defaultIcon = Icons.add_alert;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final seasonsState = ref.watch(podcastSeasonsProvider(podcast));
    final podcastViewState =
        ref.watch(podcastViewInfoControllerProvider(podcast.id));
    if (podcastViewState.isLoading || podcastViewState.isLoading) {
      return const FillRemainingLoading();
    } else if (seasonsState.hasError || seasonsState.value!.isEmpty) {
      return FillRemainingError.podcastNoResults();
    }

    final ascend = podcastViewState.valueOrNull?.ascend ?? false;
    final seasons =
        ascend ? seasonsState.value!.reversed.toList() : seasonsState.value!;
    return SliverSafeArea(
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (BuildContext context, int index) {
            return SeasonTile(
              podcast: podcast,
              season: seasons[index],
            );
          },
          childCount: seasons.length,
          addAutomaticKeepAlives: false,
        ),
      ),
    );
  }
}
