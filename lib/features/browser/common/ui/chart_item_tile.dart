import 'package:audiflow/features/browser/chart/ui/tile_image.dart';
import 'package:audiflow/features/browser/common/model/itunes_item.dart';
import 'package:audiflow/routing/app_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ITunesItemTile extends ConsumerWidget {
  const ITunesItemTile({
    super.key,
    required this.itunesItem,
  });

  final ITunesItem itunesItem;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: () {
        ref
            .read(appRouterProvider.notifier)
            .pushPodcastDetailFromChart(itunesItem);
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
                child: TileImage(
                  url: itunesItem.thumbnailArtworkUrl,
                  size: 60,
                ),
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    itunesItem.trackName,
                    maxLines: 2,
                    textHeightBehavior: const TextHeightBehavior(
                      applyHeightToFirstAscent: false,
                    ),
                    style: theme.textTheme.titleSmall!.copyWith(height: 1.3),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    itunesItem.artistName,
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
