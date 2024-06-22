import 'package:audiflow/entities/entities.dart';
import 'package:audiflow/gen/l10n/l10n.dart';
import 'package:audiflow/services/settings/settings_service.dart';
import 'package:audiflow/stopwatch.dart';
import 'package:audiflow/ui/pages/app_bars/podcast_intro_app_bar.dart';
import 'package:audiflow/ui/providers/episodes_list_event_provider.dart';
import 'package:audiflow/ui/providers/podcast_intro_provider.dart';
import 'package:audiflow/ui/widgets/fill_remaining_loading.dart';
import 'package:audiflow/ui/widgets/podcast_html.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:scrolls_to_top/scrolls_to_top.dart';

class PodcastIntroPage extends HookConsumerWidget {
  const PodcastIntroPage({
    required this.collectionId,
    required this.title,
    required this.author,
    required this.thumbnailUrl,
    super.key,
  });

  final int collectionId;
  final String title;
  final String author;
  final String thumbnailUrl;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(podcastIntroProvider(collectionId: collectionId));
    return state.hasValue
        ? _PodcastIntroPageContent(
            thumbnailUrl: thumbnailUrl,
            podcast: state.requireValue.podcast,
            episodes: state.requireValue.episodes,
          )
        : _PodcastIntroPageLoading(
            title: title,
            author: author,
            thumbnailUrl: thumbnailUrl,
          );
  }
}

class _PodcastIntroPageLoading extends StatelessWidget {
  const _PodcastIntroPageLoading({
    required this.title,
    required this.author,
    required this.thumbnailUrl,
  });

  final String title;
  final String author;
  final String thumbnailUrl;

  @override
  Widget build(BuildContext context) {
    elapsedTime('_PodcastIntroPageLoading.build');
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: CustomScrollView(
        physics: const NeverScrollableScrollPhysics(),
        slivers: <Widget>[
          PodcastIntroAppBar(
            title: title,
            author: author,
            thumbnailUrl: thumbnailUrl,
          ),
          const FillRemainingLoading(),
        ],
      ),
    );
  }
}

class _PodcastIntroPageContent extends HookConsumerWidget {
  const _PodcastIntroPageContent({
    required this.thumbnailUrl,
    required this.podcast,
    required this.episodes,
  });

  final String thumbnailUrl;
  final Podcast podcast;
  final List<Episode> episodes;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    elapsedTime('_PodcastIntroPageContent.build');
    final controller = useScrollController();
    return ProviderScope(
      overrides: [
        episodesListEventStreamProvider
            .overrideWith(EpisodesListEventStream.new),
      ],
      child: Semantics(
        header: false,
        label: L10n.of(context).semantics_podcast_details_header,
        child: ScrollsToTop(
          onScrollsToTop: (event) async {
            await controller.animateTo(
              event.to,
              duration: event.duration,
              curve: event.curve,
            );
          },
          child: Scaffold(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            body: RefreshIndicator(
              displacement: 60,
              onRefresh: () async {
                // await ref
                //     .read(podcastServiceProvider)
                //     .loadPodcast(metadata, refresh: true);
              },
              child: CustomScrollView(
                controller: controller,
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: <Widget>[
                  PodcastIntroAppBar(
                    thumbnailUrl: thumbnailUrl,
                    podcast: podcast,
                  ),
                  _PodcastTitle(podcast),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PodcastTitle extends HookConsumerWidget {
  const _PodcastTitle(this.podcast);

  final Podcast podcast;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    elapsedTime('_PodcastTitle.build');
    final textTheme = Theme.of(context).textTheme;
    final settings = ref.watch(settingsServiceProvider);
    final descriptionKey = useState(GlobalKey()).value;

    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
      sliver: SliverList(
        delegate: SliverChildListDelegate.fixed(
          <Widget>[
            const SizedBox(height: 8),
            Text(
              podcast.title,
              style: textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            Text(
              podcast.author ?? '',
              style: textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
            _PodcastDescription(
              key: descriptionKey,
              content: PodcastHtml(
                content: podcast.description,
                fontSize: FontSize.medium,
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(left: 8, right: 8),
              child: Row(
                children: <Widget>[
                  // FollowButton(podcast),
                  // PodcastContextMenu(podcast),
                  // settings.showFunding
                  //     ? FundingMenu(podcast.funding)
                  //     :
                  SizedBox.shrink(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PodcastDescription extends StatelessWidget {
  const _PodcastDescription({
    super.key,
    required this.content,
  });

  final PodcastHtml content;
  static const maxHeight = 100.0;
  static const padding = 4.0;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: _PodcastDescription.padding),
      child: AnimatedSize(
        duration: const Duration(milliseconds: 150),
        curve: Curves.fastOutSlowIn,
        alignment: Alignment.topCenter,
        child: Container(
          constraints: BoxConstraints.loose(
            const Size(double.infinity, maxHeight - padding),
          ),
          child: ShaderMask(
            shaderCallback: LinearGradient(
              colors: [Colors.white, Colors.white.withAlpha(0)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: const [0.9, 1],
            ).createShader,
            child: content,
          ),
        ),
      ),
    );
  }
}
