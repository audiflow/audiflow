import 'package:audiflow/entities/entities.dart';
import 'package:audiflow/services/podcast/podcast_service_provider.dart';
import 'package:audiflow/stopwatch.dart';
import 'package:audiflow/ui/app/router/router_provider.dart';
import 'package:audiflow/ui/widgets/tile_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ChartItemTile extends ConsumerWidget {
  const ChartItemTile({
    super.key,
    required this.chartItem,
  });

  final ITunesChartItem chartItem;
  static const heroPrefix = 'tileHero';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: () {
        sw
          ..reset()
          ..start();
        elapsedTime('start');
        ref
            .read(podcastServiceProvider)
            .findPodcastBy(collectionId: chartItem.collectionId)
            .then((podcast) {
          if (podcast != null) {
            ref.read(routerProvider).pushPodcastDetail(podcast);
          } else {
            ref.read(routerProvider).pushPodcastIntro(chartItem.collectionId);
          }
        });
      },
      child: Container(
        height: 77,
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            ExcludeSemantics(
              child: Padding(
                padding: const EdgeInsets.only(left: 20, right: 10),
                child: Hero(
                  key: Key('$heroPrefix:${chartItem.artworkUrl100}:'
                      '${chartItem.collectionId}'),
                  tag: '$heroPrefix:${chartItem.collectionId}',
                  child: TileImage(
                    url: chartItem.thumbnailArtworkUrl,
                    size: 60,
                  ),
                ),
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    chartItem.trackName,
                    maxLines: 2,
                    textHeightBehavior: const TextHeightBehavior(
                      applyHeightToFirstAscent: false,
                    ),
                    style: theme.textTheme.titleSmall!.copyWith(height: 1.3),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    chartItem.artistName,
                    maxLines: 1,
                    style: theme.textTheme.bodySmall!
                        .copyWith(color: theme.hintColor),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
