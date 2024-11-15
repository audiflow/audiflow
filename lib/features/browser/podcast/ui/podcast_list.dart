import 'package:audiflow/features/browser/podcast/ui/podcast_tile.dart';
import 'package:audiflow/features/feed/model/model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PodcastList extends ConsumerWidget {
  const PodcastList({
    super.key,
    required this.podcasts,
  });

  final List<Podcast> podcasts;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (podcasts.isEmpty) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (BuildContext context, int index) {
          return PodcastTile(podcast: podcasts[index]);
        },
        childCount: podcasts.length,
        addAutomaticKeepAlives: false,
      ),
    );
  }
}
