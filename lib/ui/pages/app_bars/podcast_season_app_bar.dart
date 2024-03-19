// Copyright (c) 2024 by HANAI, Tohru.
// Copyright (c) 2024 Reedom, Inc.
// Additional contributions from project contributors.
// All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:audiflow/core/l10n.dart';
import 'package:audiflow/entities/entities.dart';
import 'package:audiflow/services/download/download_service_provider.dart';
import 'package:audiflow/ui/pages/app_bars/podcast_page_header_image.dart';
import 'package:audiflow/ui/widgets/placeholder_builder.dart';
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
        L10n.of(context)!.downloadAllEpisodes,
        Icons.download,
        onSelected: () {
          ref.read(downloadServiceProvider).downloadEpisodes(season.episodes);
        },
      ),
      _MenuItem(
        L10n.of(context)!.downloadUnplayedEpisodes,
        Icons.download,
        onSelected: () {
          ref
              .read(downloadServiceProvider)
              .downloadEpisodes(season.episodes, unplayedOnly: true);
        },
      ),
    ];

    return SliverLayoutBuilder(
      builder: (BuildContext context, SliverConstraints constraints) {
        return SliverAppBar(
          expandedHeight: 350,
          pinned: true,
          title: AnimatedOpacity(
            opacity: 300 < constraints.scrollOffset ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 200),
            child: Text(season.title ?? season.episodes.first.title),
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
                const SizedBox(height: 46),
                Expanded(
                  child: Hero(
                    key: Key(
                      'seasonHero:${season.imageUrl}:${season.guid}',
                    ),
                    tag: '$heroPrefix:${season.guid}',
                    child: ExcludeSemantics(
                      child: PodcastHeaderImage(
                        imageUrl: season.imageUrl!,
                        placeholderBuilder: placeholderBuilder,
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
