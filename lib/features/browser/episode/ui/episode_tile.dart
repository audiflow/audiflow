import 'package:audiflow/constants/app_sizes.dart';
import 'package:audiflow/features/browser/chart/ui/tile_image.dart';
import 'package:audiflow/features/browser/episode/ui/episode_control_panel.dart';
import 'package:audiflow/features/browser/episode/ui/episode_date.dart';
import 'package:audiflow/features/feed/model/model.dart';
import 'package:audiflow/routing/app_router.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// An EpisodeTitle is built with an ExpandedTile widget and displays the
/// episode's basic details, thumbnail and play button.
///
/// It can then be expanded to present addition information about the episode
/// and further controls.
///
class EpisodeTile extends HookConsumerWidget {
  const EpisodeTile({
    super.key,
    required this.showsThumbnail,
    required this.episode,
  });

  final bool showsThumbnail;
  final Episode episode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final thumbnailUrl = showsThumbnail ? episode.imageUrl : null;
    final theme = Theme.of(context);
    return Material(
      child: Container(
        padding: const EdgeInsets.only(top: 12),
        foregroundDecoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: theme.dividerColor,
              width: 0.5,
            ),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            InkWell(
              onTap: () {
                ref
                    .read(appRouterProvider.notifier)
                    .pushEpisodeDetail(episode: episode);
              },
              child: Padding(
                padding: const EdgeInsets.only(left: 12, right: 8),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        if (thumbnailUrl != null) ...[
                          gapH8,
                          TileImage(
                            url: thumbnailUrl,
                            size: 60,
                          ),
                          gapW8,
                        ],
                        Expanded(
                          child: Text(
                            episode.title,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 5,
                            style: theme.textTheme.titleSmall,
                          ),
                        ),
                      ],
                    ),
                    gapH4,
                    EpisodeDate(episode, color: theme.hintColor),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 12, right: 8),
              child: EpisodeControlPanel(episode: episode),
            ),
          ],
        ),
      ),
    );
  }
}
