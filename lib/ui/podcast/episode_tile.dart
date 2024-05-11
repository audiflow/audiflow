import 'package:audiflow/core/types.dart';
import 'package:audiflow/entities/entities.dart';
import 'package:audiflow/ui/app/router/router_provider.dart';
import 'package:audiflow/ui/podcast/episode_date.dart';
import 'package:audiflow/ui/widgets/download_button.dart';
import 'package:audiflow/ui/widgets/queue_button.dart';
import 'package:audiflow/ui/widgets/small_play_button.dart';
import 'package:audiflow/ui/widgets/tile_image.dart';
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
    final showsThumbnail = this.showsThumbnail && episode.thumbnailUrl != null;
    return showsThumbnail
        ? _EpisodeTileWithThumbnail(episode)
        : _EpisodeTileNoThumbnail(episode);
  }
}

class _EpisodeTileWithThumbnail extends HookConsumerWidget {
  const _EpisodeTileWithThumbnail(
    this.episode,
  );

  final Episode episode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final thumbnailUrl = episode.thumbnailUrl ?? episode.imageUrl;
    final theme = Theme.of(context);
    return Material(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        foregroundDecoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: theme.dividerColor,
              width: 0.5,
            ),
          ),
        ),
        height: 140,
        child: Stack(
          children: [
            Positioned(
              top: 0,
              left: 90,
              right: 0,
              child: InkWell(
                onTap: () {
                  ref.read(routerProvider).pushEpisodeDetail(
                    episode: episode,
                    heroPrefix: 'episodeHero',
                  );
                },
                child: Container(
                  height: 64,
                  padding: const EdgeInsets.only(right: 8),
                  child: _Content(episode),
                ),
              ),
            ),
            Positioned(
              left: 0,
              top: 0,
              child: InkWell(
                onTap: () {
                  PlayButtonTappedNotification(episode).dispatch(context);
                },
                child: Padding(
                  padding: const EdgeInsets.only(left: 20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TileImage(
                        url: thumbnailUrl!,
                        size: 60,
                      ),
                      const SizedBox(height: 6),
                      EpisodeDate(episode, color: theme.hintColor),
                      SmallPlayButton(
                        episode: episode,
                        onPressed: () {
                          PlayButtonTappedNotification(episode)
                              .dispatch(context);
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              right: 0,
              bottom: -6,
              child: Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Row(
                  children: [
                    DownloadButton(episode),
                    const SizedBox(width: 6),
                    QueueButton(episode),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EpisodeTileNoThumbnail extends HookConsumerWidget {
  const _EpisodeTileNoThumbnail(
    this.episode,
  );

  final Episode episode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return Material(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
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
                ref.read(routerProvider).pushEpisodeDetail(
                  episode: episode,
                  heroPrefix: 'episodeHero',
                );
              },
              child: Padding(
                padding: const EdgeInsets.only(left: 20, right: 8),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _Content(episode),
                    const SizedBox(height: 4),
                    EpisodeDate(episode, color: theme.hintColor),
                  ],
                ),
              ),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 20),
                  child: SmallPlayButton(
                    episode: episode,
                    onPressed: () {
                      PlayButtonTappedNotification(episode).dispatch(context);
                    },
                  ),
                ),
                const Spacer(),
                DownloadButton(episode),
                const SizedBox(width: 6),
                QueueButton(episode),
                const SizedBox(width: 8),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Content extends ConsumerWidget {
  const _Content(this.episode);

  final Episode episode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => ref.read(routerProvider).pushEpisodeDetail(
            episode: episode,
            heroPrefix: 'episodeHero',
          ),
          child: SizedBox(
            width: double.infinity,
            child: Text(
              episode.title,
              overflow: TextOverflow.ellipsis,
              maxLines: 3,
              softWrap: false,
              style: textTheme.titleSmall,
            ),
          ),
        ),
      ],
    );
  }
}
