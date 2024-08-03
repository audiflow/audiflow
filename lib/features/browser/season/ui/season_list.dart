import 'package:audiflow/features/browser/season/ui/season_list_controller.dart';
import 'package:audiflow/features/browser/season/ui/season_tile.dart';
import 'package:audiflow/features/feed/model/model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SeasonList extends ConsumerWidget {
  const SeasonList({
    super.key,
    required this.podcast,
    this.icon = _defaultIcon,
    this.emptyMessage = '',
  });

  final Podcast podcast;
  final IconData icon;
  final String emptyMessage;

  static const _defaultIcon = Icons.add_alert;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pairs = ref.watch(seasonListControllerProvider(podcast.id)).pairs;

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (BuildContext context, int index) {
          return SeasonTile(
            podcast: podcast,
            season: pairs[index].season,
          );
        },
        childCount: pairs.length,
        addAutomaticKeepAlives: false,
      ),
    );
  }
}
