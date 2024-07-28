import 'package:audiflow/features/browser/common/data/stats_repository.dart';
import 'package:audiflow/features/browser/episode/ui/episodes_list_event.dart';
import 'package:audiflow/features/feed/model/model.dart';
import 'package:audiflow/localization/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PodcastDetailsAppBar extends ConsumerWidget {
  const PodcastDetailsAppBar({
    super.key,
    this.podcast,
    this.stats,
    this.title,
  });

  final Podcast? podcast;
  final PodcastStats? stats;
  final String? title;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return SliverLayoutBuilder(
      builder: (BuildContext context, SliverConstraints constraints) {
        return SliverAppBar(
          pinned: true,
          title: AnimatedOpacity(
            opacity: 300 < constraints.scrollOffset ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 200),
            child: Text(
              podcast?.title ?? title ?? '',
              style: textTheme.titleMedium,
            ),
          ),
          actions: _actions(ref),
        );
      },
    );
  }

  List<Widget>? _actions(WidgetRef ref) {
    if (podcast == null) {
      return null;
    }

    final subscribed = stats?.subscribed;
    return [
      subscribed == true
          ? IconButton(
              icon: const Icon(Icons.check),
              onPressed: () {
                ref.read(statsRepositoryProvider).unsubscribePodcast(podcast!);
              },
            )
          : IconButton(
              icon: const Icon(Icons.bookmark_add),
              onPressed: () {
                ref.read(statsRepositoryProvider).subscribePodcast(podcast!);
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
    ];
  }
}
