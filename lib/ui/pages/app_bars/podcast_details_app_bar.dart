import 'package:audiflow/gen/l10n/l10n.dart';
import 'package:audiflow/entities/podcast.dart';
import 'package:audiflow/services/podcast/podcast_service_provider.dart';
import 'package:audiflow/ui/pages/app_bars/podcast_page_header_image.dart';
import 'package:audiflow/ui/providers/episodes_list_event_provider.dart';
import 'package:audiflow/ui/providers/podcast_info_provider.dart';
import 'package:audiflow/ui/widgets/placeholder_builder.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PodcastDetailsAppBar extends ConsumerWidget {
  const PodcastDetailsAppBar({
    super.key,
    required this.pid,
    required this.heroPrefix,
    required this.foregroundColor,
    required this.backgroundColor,
  });

  final int pid;
  final String heroPrefix;
  final Color? foregroundColor;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final placeholderBuilder = PlaceholderBuilder.of(context);
    final podcastState = ref.watch(podcastInfoProvider(metadata.guid));
    final subscribed = podcastState.value?.stats?.subscribed;
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    return SliverLayoutBuilder(
      builder: (BuildContext context, SliverConstraints constraints) {
        return SliverAppBar(
          expandedHeight: 350,
          pinned: true,
          foregroundColor: foregroundColor,
          backgroundColor: backgroundColor,
          title: AnimatedOpacity(
            opacity: 300 < constraints.scrollOffset ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 200),
            child: Text(
              metadata.title,
              style: textTheme.titleMedium?.copyWith(color: foregroundColor),
            ),
          ),
          actions: [
            Opacity(
              opacity: podcastState.hasValue ? 1.0 : 0.0,
              child: subscribed == true
                  ? IconButton(
                      icon: const Icon(Icons.check),
                      onPressed: () {
                        ref
                            .read(podcastServiceProvider)
                            .unsubscribe(podcastState.value!.podcast);
                      },
                    )
                  : IconButton(
                      icon: const Icon(Icons.bookmark_add),
                      onPressed: () {
                        ref
                            .read(podcastServiceProvider)
                            .subscribe(podcastState.value!.podcast);
                      },
                    ),
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
                    child: Text(L10n.of(context)!.jumpToLastEpisode),
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
                  child: Hero(
                    key: Key(
                      'detailHero:${metadata.artworkUrl}:${metadata.guid}',
                    ),
                    tag: '$heroPrefix:${metadata.guid}',
                    child: ExcludeSemantics(
                      child: PodcastHeaderImage(
                        imageUrl: metadata.artworkUrl,
                        placeholderBuilder: placeholderBuilder,
                      ),
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
