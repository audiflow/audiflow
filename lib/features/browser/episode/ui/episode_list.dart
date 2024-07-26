import 'package:audiflow/common/ui/fill_remaining_error.dart';
import 'package:audiflow/constants/types.dart';
import 'package:audiflow/core/types.dart';
import 'package:audiflow/features/browser/episode/ui/episode_tile.dart';
import 'package:audiflow/features/browser/episode/ui/episodes_list_event.dart';
import 'package:audiflow/features/feed/model/model.dart';
import 'package:audiflow/features/browser/episode/ui/episodes_group.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class EpisodeList extends HookConsumerWidget {
  const EpisodeList({
    super.key,
    required this.episodeGroupKey,
    this.podcast,
    required this.episodes,
    required this.scrollController,
    this.thumbnailVisibility = ThumbnailVisibility.auto,
  });

  final Key episodeGroupKey;
  final Podcast? podcast;
  final List<Episode> episodes;
  final ThumbnailVisibility thumbnailVisibility;
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (episodes.isEmpty) {
      return FillRemainingError.podcastNoResults();
    }

    final episodesGroup =
        ref.watch(episodesGroupProvider(episodeGroupKey).notifier);
    useEffect(
      () {
        episodesGroup.setup(episodes);
        return null;
      },
      [],
    );

    ref.listen(episodesListEventStreamProvider, (_, next) {
      next.whenData((event) async {
        if (event is MenuScrollToEpisodeEvent) {
          final id = await episodesGroup.getLastListenedEpisode();
          if (id == null) {
            return;
          }
          final i = episodes.indexWhere((episode) => episode.id == id);
          if (i == -1) {
            return;
          }

          final offset = _ScrollOffsetCalculator.calcOffset(
            podcast,
            episodes.sublist(0, i + 1),
            id,
          );
          await scrollController.animateTo(
            offset,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        }
      });
    });

    return NotificationListener<PlayButtonTappedNotification>(
      onNotification: (notification) {
        episodesGroup.togglePlayState(episode: notification.episode);
        return false;
      },
      child: SliverSafeArea(
        sliver: SliverList(
          delegate: SliverChildBuilderDelegate(
            (BuildContext context, int index) {
              final episode = episodes[index];

              final bool showsThumbnail;
              switch (thumbnailVisibility) {
                case ThumbnailVisibility.auto:
                  showsThumbnail = episode.imageUrl != podcast?.image;
                case ThumbnailVisibility.visible:
                  showsThumbnail = true;
                case ThumbnailVisibility.hidden:
                  showsThumbnail = false;
              }

              return EpisodeTile(
                showsThumbnail: showsThumbnail,
                episode: episode,
              );
            },
            childCount: episodes.length,
            addAutomaticKeepAlives: false,
          ),
        ),
      ),
    );
  }
}

class _ScrollOffsetCalculator {
  _ScrollOffsetCalculator._();

  static const pageHeaderOffset = 200.0;
  static const episodeTileWithThumbnailHeight = 140.0;
  static const episodeTileNotThumbnailHeight = 124.0;

  static double calcOffset(
    Podcast? podcast,
    List<Episode> episodes,
    int id,
  ) {
    var offset = pageHeaderOffset;
    for (final episode in episodes) {
      if (episode.id == id) {
        break;
      }
      final showsThumbnail = episode.imageUrl != podcast?.image;
      offset += (showsThumbnail
          ? episodeTileWithThumbnailHeight
          : episodeTileNotThumbnailHeight);
    }
    return offset;
  }
}
