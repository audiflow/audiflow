import 'package:audiflow/features/browser/chart/ui/tile_image.dart';
import 'package:audiflow/features/feed/model/model.dart';
import 'package:audiflow/routing/app_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PodcastListHorizontal extends ConsumerWidget {
  const PodcastListHorizontal({
    super.key,
    required this.podcasts,
  });

  final List<Podcast> podcasts;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SliverToBoxAdapter(
      child: SizedBox(
        height: 242,
        width: 100,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
          ),
          itemBuilder: (context, index) {
            return _ListTile(
              key: ValueKey(podcasts[index].guid),
              podcast: podcasts[index],
            );
          },
          separatorBuilder: (context, index) {
            return const SizedBox(width: 20);
          },
          itemCount: podcasts.length,
        ),
      ),
    );
  }
}

class _ListTile extends ConsumerWidget {
  const _ListTile({
    super.key,
    required this.podcast,
  });

  final Podcast podcast;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: () {
        ref.read(appRouterProvider.notifier).pushPodcastDetail(podcast);
      },
      child: GridTile(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 20),
          width: 200,
          decoration: BoxDecoration(
            color: theme.colorScheme.secondaryContainer,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              TileImage(
                url: podcast.image,
                size: 150,
              ),
              const SizedBox(height: 10),
              Text(
                podcast.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.start,
                style: theme.textTheme.titleSmall!
                    .copyWith(color: theme.colorScheme.onSecondaryContainer),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
