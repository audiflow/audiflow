import 'dart:async';

import 'package:audiflow/constants/app_sizes.dart';
import 'package:audiflow/features/browser/common/model/episode_filter_mode.dart';
import 'package:audiflow/features/browser/podcast/ui/podcast_details_page/podcast_details_page_controller.dart';
import 'package:audiflow/features/feed/model/model.dart';
import 'package:audiflow/localization/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

class PodcastDetailsFilterModeSwitch extends ConsumerWidget {
  const PodcastDetailsFilterModeSwitch({
    required this.podcast,
    super.key,
  });

  final Podcast podcast;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pid = podcast.id;
    final pageState = ref.watch(podcastDetailsPageControllerProvider(pid));

    final l10n = L10n.of(context);
    return pageState.maybeMap(
      data: (data) => Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          TextButton(
            onPressed: () async {
              final mode = await _showFilterModeSelector(
                context,
                data.value.episodeFilterMode,
              );
              if (mode != null) {
                unawaited(
                  ref
                      .read(podcastDetailsPageControllerProvider(pid).notifier)
                      .setEpisodeFilter(mode),
                );
              }
            },
            child: Text(data.value.episodeFilterMode.labelOf(l10n)),
          ),
          IconButton(
            onPressed: () => ref
                .read(podcastDetailsPageControllerProvider(pid).notifier)
                .toggleEpisodesAscending(),
            icon: const Icon(Symbols.swap_vert),
          ),
          gapW4,
        ],
      ),
      orElse: SizedBox.shrink,
    );
  }

  Future<EpisodeFilterMode?> _showFilterModeSelector(
    BuildContext context,
    EpisodeFilterMode current,
  ) async {
    final l10n = L10n.of(context);
    return showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l10n.episodeFilterMode,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              gapH12,
              ...EpisodeFilterMode.values.map((mode) {
                return ListTile(
                  selected: mode == current,
                  title: Text(mode.labelOf(l10n)),
                  trailing: mode == current ? const Icon(Symbols.check) : null,
                  onTap: () => Navigator.of(context).pop(mode),
                );
              }),
              gapH24,
            ],
          ),
        );
      },
    );
  }
}
