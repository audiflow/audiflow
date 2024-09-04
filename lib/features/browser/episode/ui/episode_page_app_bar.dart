import 'package:audiflow/features/browser/podcast/ui/podcast_page_header_image.dart';
import 'package:audiflow/features/feed/model/episode.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class EpisodePageAppBar extends ConsumerWidget {
  const EpisodePageAppBar({
    super.key,
    required this.episode,
  });

  final Episode episode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SliverLayoutBuilder(
      builder: (BuildContext context, SliverConstraints constraints) {
        return SliverAppBar(
          expandedHeight: 300,
          pinned: true,
          title: AnimatedOpacity(
            opacity: 300 < constraints.scrollOffset ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 200),
            child: Text(episode.title),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {},
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
                      imageUrl: episode.imageUrl ?? '',
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
