import 'package:audiflow/common/ui/placeholder_builder.dart';
import 'package:audiflow/features/browser/common/data/stats_repository.dart';
import 'package:audiflow/features/browser/episode/ui/episodes_list_event.dart';
import 'package:audiflow/features/browser/podcast/ui/podcast_page_header_image.dart';
import 'package:audiflow/features/feed/model/model.dart';
import 'package:audiflow/localization/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PodcastDetailsAppBar extends ConsumerWidget {
  const PodcastDetailsAppBar({
    super.key,
    required this.podcast,
    required this.stats,
  });

  final Podcast podcast;
  final PodcastStats? stats;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final placeholderBuilder = PlaceholderBuilder.of(context);
    final subscribed = stats?.subscribed;
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    return SliverLayoutBuilder(
      builder: (BuildContext context, SliverConstraints constraints) {
        return SliverAppBar(
          expandedHeight: 350,
          pinned: true,
          title: AnimatedOpacity(
            opacity: 300 < constraints.scrollOffset ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 200),
            child: Text(
              podcast.title,
              style: textTheme.titleMedium,
            ),
          ),
          actions: [
            subscribed == true
                ? IconButton(
                    icon: const Icon(Icons.check),
                    onPressed: () {
                      ref
                          .read(statsRepositoryProvider)
                          .unsubscribePodcast(podcast);
                    },
                  )
                : IconButton(
                    icon: const Icon(Icons.bookmark_add),
                    onPressed: () {
                      ref
                          .read(statsRepositoryProvider)
                          .subscribePodcast(podcast);
                    },
                  ),
            PopupMenuButton<String>(
              onSelected: (_) {
                ref
                    .read(episodesListEventStreamProvider.notifier)
                    .add(const MenuScrollToEpisodeEvent());
              },
              itemBuilder: (BuildContext context) {
                return ['jumpToLastEpisode'].map((String choice) {
                  return PopupMenuItem<String>(
                    value: choice,
                    child: Text(L10n.of(context).jumpToLastEpisode),
                  );
                }).toList();
              },
            ),
          ],
          flexibleSpace: FlexibleSpaceBar(
            background: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 46),
                Expanded(
                  child: ExcludeSemantics(
                    child: PodcastHeaderImage.large(
                      imageUrl: podcast.image,
                      placeholderBuilder: placeholderBuilder,
                    ),
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        );
      },
    );
  }
}

class PodcastDetailsLoadingAppBar extends ConsumerWidget {
  const PodcastDetailsLoadingAppBar({
    super.key,
    required this.title,
    required this.thumbnailUrl,
  });

  final String title;
  final String thumbnailUrl;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final placeholderBuilder = PlaceholderBuilder.of(context);
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    return SliverLayoutBuilder(
      builder: (BuildContext context, SliverConstraints constraints) {
        return SliverAppBar(
          expandedHeight: 350,
          pinned: true,
          // foregroundColor: foregroundColor,
          // backgroundColor: backgroundColor,
          title: AnimatedOpacity(
            opacity: 300 < constraints.scrollOffset ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 200),
            child: Text(title, style: textTheme.titleMedium),
          ),
          flexibleSpace: FlexibleSpaceBar(
            background: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 46),
                Expanded(
                  child: ExcludeSemantics(
                    child: PodcastHeaderImage.large(
                      imageUrl: thumbnailUrl,
                      placeholderBuilder: placeholderBuilder,
                    ),
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        );
      },
    );
  }
}
