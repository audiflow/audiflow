import 'package:audiflow/entities/podcast.dart';
import 'package:audiflow/services/podcast/podcast_service_provider.dart';
import 'package:audiflow/ui/pages/app_bars/podcast_page_header_image.dart';
import 'package:audiflow/ui/widgets/placeholder_builder.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PodcastIntroAppBar extends ConsumerWidget {
  const PodcastIntroAppBar({
    super.key,
    this.title,
    this.author,
    required this.thumbnailUrl,
    this.podcast,
    this.subscribed,
  });

  final String? title;
  final String? author;
  final String thumbnailUrl;
  final Podcast? podcast;
  final bool? subscribed;

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
          title: AnimatedOpacity(
            opacity: 300 < constraints.scrollOffset ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 200),
            child: Text(
              podcast?.title ?? title!,
              style: textTheme.titleMedium,
            ),
          ),
          actions: [
            Opacity(
              opacity: subscribed == null ? 0 : 1,
              child: subscribed == true
                  ? IconButton(
                      icon: const Icon(Icons.check),
                      onPressed: () {
                        ref.read(podcastServiceProvider).unsubscribe(podcast!);
                      },
                    )
                  : IconButton(
                      icon: const Icon(Icons.bookmark_add),
                      onPressed: () {
                        ref.read(podcastServiceProvider).subscribe(podcast!);
                      },
                    ),
            ),
          ],
          flexibleSpace: FlexibleSpaceBar(
            background: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 46),
                Expanded(
                  child: ExcludeSemantics(
                    child: PodcastHeaderImage.middle(
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
