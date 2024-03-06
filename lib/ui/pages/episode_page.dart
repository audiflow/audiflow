// Copyright 2024 HANAI Tohru, Reedom, INC.
// All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:seasoning/entities/entities.dart';
import 'package:seasoning/providers/podcast/episode_info_provider.dart';
import 'package:seasoning/services/audio/audio_player_service.dart';
import 'package:seasoning/services/podcast/podcast_service_provider.dart';
import 'package:seasoning/ui/app/navigation_helper.dart';
import 'package:seasoning/ui/pages/app_bars/episode_page_app_bar.dart';
import 'package:seasoning/ui/widgets/podcast_html.dart';
import 'package:seasoning/ui/widgets/rounded_stadium_button.dart';

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
    return ColoredBox(
      color: Colors.green,
      child: SafeArea(
        child: Scaffold(
          body: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: <Widget>[
              EpisodePageAppBar(
                metadata: metadata,
                episode: episode,
                heroPrefix: heroPrefix,
              ),
              SliverPadding(
                padding: const EdgeInsets.only(top: 12),
                sliver: DecoratedSliver(
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                  ),
                  sliver: _EpisodeHeader(metadata, episode),
                ),
              ),
              _EpisodeBody(metadata, episode),
            ],
          ),
        ),
      ),
    );
  }
}

class _EpisodeHeader extends HookConsumerWidget {
  const _EpisodeHeader(this.metadata, this.episode);

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
            PodcastLink(
              title: metadata.title,
              thumbnailUrl: metadata.thumbImageUrl != episode.thumbImageUrl
                  ? metadata.thumbImageUrl
                  : null,
              onTap: () {
                NavigationHelper.router
                    .pushNamed('detail', extra: (metadata, ''));
              },
            ),
            _EpisodePlayButton(episode: episode),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}

class PodcastLink extends StatelessWidget {
  const PodcastLink({
    this.thumbnailUrl,
    required this.title,
    required this.onTap,
    super.key,
  });

  final String? thumbnailUrl;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return TextButton(
      onPressed: onTap,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (thumbnailUrl != null)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Image.network(
                thumbnailUrl!,
                width: 20,
                height: 20,
              ),
            ),
          Text(
            title,
            style: textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
          const Icon(Icons.arrow_forward_ios, size: 16),
        ],
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

class _EpisodePlayButton extends ConsumerWidget {
  const _EpisodePlayButton({
    required this.episode,
  });

  final Episode episode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPlaying = ref.watch(
      audioPlayerServiceProvider.select(
        (state) =>
            state?.episode.guid == episode.guid &&
            state?.phase == PlayerPhase.play,
      ),
    );
    final state = ref.watch(episodeInfoProvider(episode));
    final stats = state.valueOrNull?.stats;
    return Opacity(
      opacity: state.hasValue ? 1 : 0,
      child: RoundedStadiumButton.md(
        caption: Text(_caption(context, stats, isPlaying: isPlaying)),
        onPressed: () {
          ref.read(podcastServiceProvider).handlePlay(episode);
        },
      ),
    );
  }

  String _caption(
    BuildContext context,
    EpisodeStats? stats, {
    required bool isPlaying,
  }) {
    if (isPlaying) {
      return 'Pause';
    }

    if (stats == null) {
      return 'Play';
    }

    final percentage = stats.percentagePlayed;
    if (0 < percentage && percentage < 1) {
      return 'Resume';
    }
    if (percentage == 0 && stats.completeCount == 0) {
      return 'Play';
    } else {
      return 'Play again';
    }
  }
}
