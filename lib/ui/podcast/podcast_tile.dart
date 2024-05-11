import 'package:audiflow/entities/entities.dart';
import 'package:audiflow/ui/app/router/router_provider.dart';
import 'package:audiflow/ui/widgets/tile_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PodcastTile extends ConsumerWidget {
  const PodcastTile({
    super.key,
    required this.podcast,
  });

  final Podcast podcast;
  static const heroPrefix = 'tileHero';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: () {
        // ref.read(routerProvider).pushPodcastDetail(
        //   podcast: podcast,
        //   heroPrefix: heroPrefix,
        // );
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
                  key: Key('tileHero:${podcast.image}:${podcast.guid}'),
                  tag: '$heroPrefix:${podcast.guid}',
                  child: TileImage(
                    url: podcast.image,
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
                    podcast.title,
                    maxLines: 2,
                    textHeightBehavior: const TextHeightBehavior(
                      applyHeightToFirstAscent: false,
                    ),
                    style: theme.textTheme.titleSmall!.copyWith(height: 1.3),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    podcast.copyright ?? podcast.author ?? '',
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
