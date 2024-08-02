import 'package:audiflow/common/ui/fill_remaining_loading.dart';
import 'package:audiflow/constants/types.dart';
import 'package:audiflow/core/types.dart';
import 'package:audiflow/features/browser/common/model/episode_filter_mode.dart';
import 'package:audiflow/features/browser/episode/ui/episode_list_controller.dart';
import 'package:audiflow/features/browser/episode/ui/episode_tile.dart';
import 'package:audiflow/features/feed/model/model.dart';
import 'package:audiflow/utils/logger.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class EpisodeList extends HookConsumerWidget {
  const EpisodeList({
    super.key,
    required this.podcast,
    required this.scrollController,
    required this.filterMode,
    required this.ascending,
    this.thumbnailVisibility = ThumbnailVisibility.auto,
  });

  final Podcast podcast;
  final ScrollController scrollController;
  final ThumbnailVisibility thumbnailVisibility;
  final EpisodeFilterMode filterMode;
  final bool ascending;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final episodeListState = ref.watch(
      episodeListControllerProvider(
        pid: podcast.id,
        filterMode: filterMode,
        ascending: ascending,
      ),
    );
    logger.d(episodeListState);

    return episodeListState.when(
      loading: FillRemainingLoading.new,
      error: (_, __) => const FillRemainingLoading(),
      data: (episodeListState) {
        return NotificationListener<PlayButtonTappedNotification>(
          onNotification: (notification) {
            // episodesGroup.togglePlayState(episode: notification.episode);
            return false;
          },
          child: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => _episodeTileAt(context, ref, index),
              childCount: episodeListState.loadedCount,
              addAutomaticKeepAlives: false,
            ),
          ),
        );
      },
    );
  }

  Widget _episodeTileAt(BuildContext context, WidgetRef ref, int index) {
    final controller = ref.watch(
      episodeListControllerProvider(
        pid: podcast.id,
        filterMode: filterMode,
        ascending: ascending,
      ).notifier,
    );

    return FutureBuilder(
      future: controller.getEpisodeAt(index),
      builder: (context, data) {
        if (data.data == null) {
          return const SizedBox(height: 140);
        }

        final episode = data.data!;
        final bool showsThumbnail;
        switch (thumbnailVisibility) {
          case ThumbnailVisibility.auto:
            showsThumbnail = episode.imageUrl != podcast.image;
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
    );
  }
}
