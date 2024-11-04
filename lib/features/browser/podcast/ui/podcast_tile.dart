import 'package:audiflow/features/browser/chart/ui/tile_image.dart';
import 'package:audiflow/features/feed/model/model.dart';
import 'package:audiflow/routing/app_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PodcastTile extends ConsumerWidget {
  const PodcastTile({
    super.key,
    required this.podcast,
  });

  final Podcast podcast;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: () {
        ref.read(appRouterProvider.notifier).pushPodcastDetail(podcast);
      },
      child: Container(
        height: 77,
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        child: Row(
          children: [
            ExcludeSemantics(
              child: Padding(
                padding: const EdgeInsets.only(left: 4, right: 10),
                child: TileImage(
                  url: podcast.image,
                  size: 60,
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
                    podcast.author ?? '',
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
