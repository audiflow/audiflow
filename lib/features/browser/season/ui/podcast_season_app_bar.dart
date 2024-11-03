import 'package:audiflow/features/browser/podcast/ui/podcast_page_header_image.dart';
import 'package:audiflow/features/browser/season/model/season.dart';
import 'package:audiflow/features/browser/season/ui/season_episodes_page_controller.dart';
import 'package:audiflow/localization/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PodcastSeasonAppBar extends ConsumerWidget {
  const PodcastSeasonAppBar({
    super.key,
    required this.season,
  });

  final Season season;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final menus = <_MenuItem>[
      _MenuItem(
        L10n.of(context).downloadAllEpisodes,
        Icons.download,
        onSelected: () {
          ref
              .read(seasonEpisodesPageControllerProvider(season).notifier)
              .downloadAllEpisodes();
        },
      ),
      _MenuItem(
        L10n.of(context).downloadUnplayedEpisodes,
        Icons.download,
        onSelected: () {
          ref
              .read(seasonEpisodesPageControllerProvider(season).notifier)
              .downloadUnplayedEpisodes();
        },
      ),
    ];

    final safeAreaTop = MediaQuery.of(context).viewPadding.top;
    return SliverLayoutBuilder(
      builder: (BuildContext context, SliverConstraints constraints) {
        return SliverAppBar(
          expandedHeight: 350,
          pinned: true,
          title: AnimatedOpacity(
            opacity: 300 < constraints.scrollOffset ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 200),
            child: Text(season.title ?? ''),
          ),
          actions: [
            PopupMenuButton<_MenuItem>(
              onSelected: (menu) {
                menu.onSelected();
              },
              itemBuilder: (BuildContext context) {
                return menus.map((menu) {
                  return PopupMenuItem(
                    value: menu,
                    child: Text(menu.label),
                  );
                }).toList();
              },
            ),
          ],
          flexibleSpace: FlexibleSpaceBar(
            background: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Expanded(
                  child: ExcludeSemantics(
                    child: Padding(
                      padding:
                          EdgeInsets.only(top: safeAreaTop + kToolbarHeight),
                      child: PodcastHeaderImage.large(
                        imageUrl: season.imageUrl!,
                      ),
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

class _MenuItem {
  const _MenuItem(this.label, this.icon, {required this.onSelected});

  final String label;
  final IconData icon;
  final VoidCallback onSelected;
}
