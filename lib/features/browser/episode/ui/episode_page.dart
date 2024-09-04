import 'package:audiflow/common/ui/fill_remaining_loading.dart';
import 'package:audiflow/constants/app_sizes.dart';
import 'package:audiflow/features/browser/common/ui/podcast_html.dart';
import 'package:audiflow/features/browser/episode/ui/episode_control_panel.dart';
import 'package:audiflow/features/browser/episode/ui/episode_page_app_bar.dart';
import 'package:audiflow/features/browser/podcast/data/podcast_provider.dart';
import 'package:audiflow/features/player/service/audio_player_service.dart';
import 'package:audiflow/routing/app_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:scrolls_to_top/scrolls_to_top.dart';

/// This Widget takes a search result and builds a list of currently available
/// podcasts.
///
/// From here a user can option to subscribe/unsubscribe or play a podcast
/// directly from a search result.
class EpisodePage extends HookConsumerWidget {
  const EpisodePage({
    required this.episode,
    super.key,
  });

  final Episode episode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = useScrollController();
    final podcastState = ref.watch(podcastProvider(episode.pid));
    final podcast = podcastState.valueOrNull;
    return ScrollsToTop(
      onScrollsToTop: (event) async {
        await controller.animateTo(
          event.to,
          duration: event.duration,
          curve: event.curve,
        );
      },
      child: Scaffold(
        body: CustomScrollView(
          controller: controller,
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: <Widget>[
            if (podcastState.isLoading)
              const FillRemainingLoading()
            else if (podcastState.hasError)
              SliverFillRemaining(
                child: Center(
                  child: Text(podcastState.error.toString()),
                ),
              )
            else ...[
              EpisodePageAppBar(episode: episode),
              SliverPadding(
                padding: const EdgeInsets.only(top: 12),
                sliver: DecoratedSliver(
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                  ),
                  sliver: _EpisodeHeader(podcast!, episode),
                ),
              ),
              _EpisodeBody(podcast, episode),
            ],
          ],
        ),
      ),
    );
  }
}

class _EpisodeHeader extends HookConsumerWidget {
  const _EpisodeHeader(
    this.podcast,
    this.episode,
  );

  final Podcast podcast;
  final Episode episode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;

    return SliverList(
      delegate: SliverChildListDelegate.fixed(
        <Widget>[
          gapH8,
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: SelectionArea(
              child: Text(
                episode.title,
                style: textTheme.titleMedium,
              ),
            ),
          ),
          PodcastLink(
            title: podcast.title,
            thumbnailUrl:
                podcast.image != episode.imageUrl ? podcast.image : null,
            onTap: () {
              ref.read(appRouterProvider.notifier).pushPodcastDetail(podcast);
            },
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: EpisodeControlPanel(episode: episode),
          ),
        ],
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
    return TextButtonTheme(
      data: TextButtonThemeData(
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
          shape: const RoundedRectangleBorder(),
        ),
      ),
      child: TextButton(
        onPressed: onTap,
        child: Row(
          children: [
            if (thumbnailUrl != null) ...[
              Image.network(
                thumbnailUrl!,
                width: 20,
                height: 20,
              ),
              gapW8,
            ],
            Text(
              title,
              style: textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
            const Icon(Icons.arrow_forward_ios, size: 16),
          ],
        ),
      ),
    );
  }
}

class _EpisodeBody extends HookConsumerWidget {
  const _EpisodeBody(this.podcast, this.episode);

  final Podcast podcast;
  final Episode episode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: SelectionArea(
          child: PodcastHtml(
            content: episode.description ?? '',
            fontSize: FontSize.medium,
          ),
        ),
      ),
    );
  }
}
