import 'package:audiflow/common/ui/error_notifier.dart';
import 'package:audiflow/common/ui/fill_remaining_error.dart';
import 'package:audiflow/common/ui/fill_remaining_loading.dart';
import 'package:audiflow/constants/types.dart';
import 'package:audiflow/features/browser/common/data/latest_episodes_provider.dart';
import 'package:audiflow/features/browser/common/ui/basic_app_bar.dart';
import 'package:audiflow/features/browser/episode/ui/episode_list.dart';
import 'package:audiflow/localization/generated/l10n.dart';
import 'package:collection/collection.dart' show IterableExtension;
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:scrolls_to_top/scrolls_to_top.dart';

class LatestEpisodesPage extends HookConsumerWidget {
  const LatestEpisodesPage({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(latestEpisodesProvider);
    final episodes = state.valueOrNull?.episodes
        .where((e) => !state.valueOrNull!.playedEids.contains(e.id))
        .toList(growable: false);
    final scrollController = useScrollController();

    return ScrollsToTop(
      onScrollsToTop: (event) async {
        await scrollController.animateTo(
          event.to,
          duration: event.duration,
          curve: event.curve,
        );
      },
      child: Scaffold(
        body: Stack(
          children: [
            CustomScrollView(
              controller: scrollController,
              slivers: <Widget>[
                BasicAppBar(title: L10n.of(context).latestEpisodes),
                if (state.isLoading)
                  const FillRemainingLoading()
                else if (state.hasError)
                  FillRemainingError.podcastNoResults()
                else
                  EpisodeList(
                    getEpisodeAt: (index) => episodes![index],
                    scrollController: scrollController,
                    episodeCount: episodes?.length ?? 0,
                    getParentThumbnailUrl: (index) => state
                        .requireValue.podcasts
                        .firstWhereOrNull((p) => p.id == episodes![index].pid)
                        ?.image,
                    thumbnailVisibility: ThumbnailVisibility.visible,
                  ),
              ],
            ),
            const ErrorNotifier(),
          ],
        ),
      ),
    );
  }
}
