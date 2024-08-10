import 'dart:async';

import 'package:audiflow/constants/types.dart';
import 'package:audiflow/features/browser/episode/ui/episode_tile.dart';
import 'package:audiflow/features/feed/model/model.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class EpisodeList extends HookConsumerWidget {
  const EpisodeList({
    super.key,
    required this.episodeCount,
    required this.getEpisodeAt,
    required this.scrollController,
    this.thumbnailVisibility = ThumbnailVisibility.auto,
    this.parentThumbnailUrl,
  });

  factory EpisodeList.fixed({
    Key? key,
    required List<Episode> episodes,
    required ScrollController scrollController,
    ThumbnailVisibility thumbnailVisibility = ThumbnailVisibility.auto,
    String? parentThumbnailUrl,
  }) {
    return EpisodeList(
      key: key,
      episodeCount: episodes.length,
      getEpisodeAt: (index) => episodes[index],
      scrollController: scrollController,
      thumbnailVisibility: thumbnailVisibility,
      parentThumbnailUrl: parentThumbnailUrl,
    );
  }

  final int episodeCount;
  final FutureOr<Episode?> Function(int index) getEpisodeAt;
  final ScrollController scrollController;
  final ThumbnailVisibility thumbnailVisibility;
  final String? parentThumbnailUrl;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) => _episodeTileAt(context, ref, index),
        childCount: episodeCount,
        addAutomaticKeepAlives: false,
      ),
    );
  }

  Widget _episodeTileAt(BuildContext context, WidgetRef ref, int index) {
    Widget createEpisodeTile(Episode episode) {
      final bool showsThumbnail;
      switch (thumbnailVisibility) {
        case ThumbnailVisibility.auto:
          showsThumbnail = episode.imageUrl != parentThumbnailUrl;
        case ThumbnailVisibility.visible:
          showsThumbnail = true;
        case ThumbnailVisibility.hidden:
          showsThumbnail = false;
      }

      return EpisodeTile(
        showsThumbnail: showsThumbnail,
        episode: episode,
      );
    }

    final episode = getEpisodeAt(index);
    switch (episode) {
      case Episode():
        return createEpisodeTile(episode);
      case Future<Episode?>():
        return FutureBuilder(
          future: episode,
          builder: (context, data) {
            return data.data == null
                ? const SizedBox(height: 140)
                : createEpisodeTile(data.data!);
          },
        );
      default:
        return const SizedBox(height: 140);
    }
  }
}
