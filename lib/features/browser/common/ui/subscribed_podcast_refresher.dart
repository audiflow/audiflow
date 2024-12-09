import 'dart:async';

import 'package:audiflow/features/browser/common/data/podcast_subscriptions.dart';
import 'package:audiflow/features/browser/podcast/data/podcast_stats_provider.dart';
import 'package:audiflow/features/feed/model/model.dart';
import 'package:audiflow/features/feed/service/podcast_feed_loader.dart';
import 'package:audiflow/utils/logger.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class SubscribedPodcastRefresher extends ConsumerWidget {
  const SubscribedPodcastRefresher({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final podcastsState = ref.watch(podcastSubscriptionsProvider);
    return podcastsState.maybeWhen<Widget>(
      data: (podcasts) => Column(
        children: podcasts.map(_PodcastRefresher.new).toList(),
      ),
      orElse: () => const SizedBox.shrink(),
    );
  }
}

class _PodcastRefresher extends HookConsumerWidget {
  const _PodcastRefresher(this.podcast, {super.key});

  static const _checkInterval = Duration(hours: 3);
  final Podcast podcast;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loader = ref.watch(
      podcastFeedLoaderProvider(
        feedUrl: podcast.newFeedUrl ?? podcast.feedUrl,
      ).notifier,
    );
    if (podcast.collectionId != null) {
      loader.collectionId = podcast.collectionId;
    }

    final lastCheckedAt = ref.watch(
      podcastStatsProvider(podcast.id)
          .select((stats) => stats.valueOrNull?.lastCheckedAt),
    );

    final rebuildTrigger = useState(0);

    useEffect(
      () {
        if (lastCheckedAt == null) {
          return null;
        }

        final now = DateTime.now();
        if (lastCheckedAt.add(_checkInterval).isAfter(now)) {
          final nextCheckAt = lastCheckedAt.add(_checkInterval);
          final interval = nextCheckAt.difference(now);
          final timer = Timer(interval, () => rebuildTrigger.value++);
          logger.d('nextCheckAt $nextCheckAt for $podcast');
          return timer.cancel;
        }

        logger.d('needs check');
        if (loader.startLoading()) {
          return null;
        } else {
          final timer =
              Timer(const Duration(seconds: 1), () => rebuildTrigger.value++);
          return timer.cancel;
        }
      },
      [lastCheckedAt],
    );

    return const SizedBox.shrink();
  }
}
