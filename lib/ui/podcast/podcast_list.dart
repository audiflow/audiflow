import 'package:audiflow/entities/entities.dart';
import 'package:audiflow/ui/podcast/podcast_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PodcastList extends ConsumerWidget {
  const PodcastList({
    super.key,
    required this.results,
  });

  final List<Podcast> results;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (results.isEmpty) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (BuildContext context, int index) {
          return PodcastTile(podcast: results[index]);
        },
        childCount: results.length,
        addAutomaticKeepAlives: false,
      ),
    );
  }
}
