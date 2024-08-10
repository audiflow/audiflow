import 'package:audiflow/common/ui/placeholder_builder.dart';
import 'package:audiflow/features/browser/podcast/ui/podcast_page_header_image.dart';
import 'package:audiflow/features/browser/season/model/season.dart';
import 'package:audiflow/localization/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PodcastSeasonAppBar extends ConsumerWidget {
  const PodcastSeasonAppBar({
    super.key,
    required this.season,
    required this.heroPrefix,
  });

  final Season season;
  final String heroPrefix;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final placeholderBuilder = PlaceholderBuilder.of(context);

    final menus = <_MenuItem>[
      _MenuItem(
        L10n.of(context).downloadAllEpisodes,
        Icons.download,
        onSelected: () {
          // ref.read(downloadServiceProvider)
          // .downloadEpisodes(season.episodes);
        },
      ),
      _MenuItem(
        L10n.of(context).downloadUnplayedEpisodes,
        Icons.download,
        onSelected: () {
          // ref
          //     .read(downloadServiceProvider)
          //     .downloadEpisodes(season.episodes, unplayedOnly: true);
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
                  child: Hero(
                    key: Key(
                      'seasonHero:${season.imageUrl}:${season.guid}',
                    ),
                    tag: '$heroPrefix:${season.id}',
                    child: ExcludeSemantics(
                      child: Padding(
                        padding:
                            EdgeInsets.only(top: safeAreaTop + kToolbarHeight),
                        child: PodcastHeaderImage.large(
                          imageUrl: season.imageUrl!,
                          placeholderBuilder: placeholderBuilder,
                        ),
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
