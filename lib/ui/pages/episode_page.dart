// Copyright 2024 HANAI Tohru, Reedom, INC.
// All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:seasoning/entities/entities.dart';
import 'package:seasoning/providers/podcast/episode_info_provider.dart';
import 'package:seasoning/ui/pages/app_bars/episode_page_app_bar.dart';
import 'package:seasoning/ui/widgets/podcast_html.dart';

/// This Widget takes a search result and builds a list of currently available
/// podcasts.
///
/// From here a user can option to subscribe/unsubscribe or play a podcast
/// directly from a search result.
class EpisodePage extends HookConsumerWidget {
  const EpisodePage({
    required this.metadata,
    required this.episode,
    required this.heroPrefix,
    super.key,
  });

  final PodcastMetadata metadata;
  final Episode episode;
  final String heroPrefix;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final episodeState = ref.watch(episodeInfoProvider(episode));
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: <Widget>[
          EpisodePageAppBar(
            metadata: metadata,
            episode: episode,
            heroPrefix: heroPrefix,
          ),
          _EpisodeTitle(metadata, episode),
          DecoratedSliver(
            decoration: BoxDecoration(
              color: theme.canvasColor,
            ),
            sliver: _EpisodeBody(metadata, episode),
          ),
        ],
      ),
    );
  }
}

class _EpisodeTitle extends HookConsumerWidget {
  const _EpisodeTitle(this.metadata, this.episode);

  final PodcastMetadata metadata;
  final Episode episode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;

    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
      sliver: SliverList(
        delegate: SliverChildListDelegate.fixed(
          <Widget>[
            const SizedBox(height: 8),
            Text(
              episode.title,
              style: textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            Text(
              metadata.title,
              style: textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _EpisodeBody extends HookConsumerWidget {
  const _EpisodeBody(this.metadata, this.episode);

  final PodcastMetadata metadata;
  final Episode episode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Container(
          constraints: const BoxConstraints(),
          child: PodcastHtml(
            content: episode.description,
            fontSize: FontSize.medium,
          ),
        ),
      ),
    );
  }
}
