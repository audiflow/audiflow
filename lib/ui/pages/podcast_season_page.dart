// Copyright 2024 HANAI Tohru, Reedom, INC.
// All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:seasoning/entities/entities.dart';
import 'package:seasoning/l10n/L.dart';
import 'package:seasoning/providers/podcast/podcast_info_provider.dart';
import 'package:seasoning/services/settings/settings_service.dart';
import 'package:seasoning/ui/pages/app_bars/podcast_season_app_bar.dart';
import 'package:seasoning/ui/podcast/episode_list.dart';
import 'package:seasoning/ui/podcast/funding_menu.dart';
import 'package:seasoning/ui/podcast/types.dart';
import 'package:seasoning/ui/widgets/podcast_html.dart';

class PodcastSeasonPage extends HookConsumerWidget {
  const PodcastSeasonPage({
    required this.podcast,
    required this.season,
    required this.heroPrefix,
    super.key,
  });

  final Podcast podcast;
  final Season season;
  final String heroPrefix;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scaffoldMessengerKey =
        useState(GlobalKey<ScaffoldMessengerState>()).value;
    return Semantics(
      header: false,
      label: L.of(context)!.semantics_podcast_details_header,
      child: ScaffoldMessenger(
        key: scaffoldMessengerKey,
        child: Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          body: RefreshIndicator(
            displacement: 60,
            onRefresh: () async {},
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: <Widget>[
                PodcastSeasonAppBar(season: season, heroPrefix: heroPrefix),
                EpisodeList(
                  thumbnailVisibility: ThumbnailVisibility.hidden,
                  summary: podcast,
                  episodes: season.episodes,
                  play: true,
                  download: true,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Renders the podcast or episode image.

/// Renders the podcast title, copyright, description, follow/unfollow and
/// overflow button.
///
/// If the episode description is fairly long, an overflow icon is also shown
/// and a portion of the episode description is shown. Tapping the overflow
/// icons allows the user to expand and collapse the text.
///
/// Description is rendered by [_PodcastDescription].
/// Follow/Unfollow button rendered by [FollowButton].
class _PodcastTitle extends HookConsumerWidget {
  const _PodcastTitle(this.podcast);

  final Podcast podcast;

  static const maxHeight = 100.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final settings = ref.watch(settingsServiceProvider);
    final showOverflowState = useState(false);
    final descriptionKey = useState(GlobalKey()).value;
    final expandedState = useState(false);

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
              podcast.copyright,
              style: textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Visibility(
                  visible: showOverflowState.value,
                  child: SizedBox(
                    height: 48,
                    width: 48,
                    child: expandedState.value
                        ? TextButton(
                            style: const ButtonStyle(
                              visualDensity: VisualDensity.compact,
                            ),
                            child: Icon(
                              Icons.expand_less,
                              semanticLabel: L
                                  .of(context)!
                                  .semantics_collapse_podcast_description,
                            ),
                            onPressed: () {
                              expandedState.value = false;
                            },
                          )
                        : TextButton(
                            style: const ButtonStyle(
                              visualDensity: VisualDensity.compact,
                            ),
                            child: Icon(
                              Icons.expand_more,
                              semanticLabel: L
                                  .of(context)!
                                  .semantics_expand_podcast_description,
                            ),
                            onPressed: () {
                              expandedState.value = true;
                            },
                          ),
                  ),
                ),
              ],
            ),
            _PodcastDescription(
                key: descriptionKey,
                content: PodcastHtml(
                  content: podcast.description!,
                  fontSize: FontSize.medium,
                ),
                isExpanded: expandedState.value),
            Padding(
              padding: const EdgeInsets.only(left: 8, right: 8),
              child: Row(
                children: <Widget>[
                  // FollowButton(podcast),
                  // PodcastContextMenu(podcast),
                  settings.showFunding
                      ? FundingMenu(podcast.funding)
                      : const SizedBox.shrink(),
                  // const Expanded(
                  //   child: Align(
                  //     alignment: Alignment.centerRight,
                  //     child: SyncSpinner(),
                  //   ),
                  // ),
                  // hasSeasons
                  //    ? SeasonSwitch(isOn: podcast!.seasonView)
                  //    : const SizedBox.shrink();
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
// @override
// void initState() {
//   super.initState();
//
//
//   WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
//     if (descriptionKey.currentContext!.size!.height == maxHeight) {
//       setState(() {
//         showOverflow = true;
//       });
//     }
//   });
// }
}

/// This class wraps the description in an expandable box.
///
/// This handles the common case whereby the description is very long and, without
/// this constraint, would require the use to always scroll before reaching the
/// podcast episodes.
///
/// TODO: Animate between the two states.
class _PodcastDescription extends StatelessWidget {
  const _PodcastDescription({
    super.key,
    required this.content,
    required this.isExpanded,
  });

  final PodcastHtml content;
  final bool isExpanded;
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
          constraints: isExpanded
              ? const BoxConstraints()
              : BoxConstraints.loose(
                  const Size(double.infinity, maxHeight - padding),
                ),
          child: isExpanded
              ? content
              : ShaderMask(
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

// class FollowButton extends StatelessWidget {
//   const FollowButton(this.podcast, {super.key});
//
//   final Podcast podcast;
//
//   @override
//   Widget build(BuildContext context) {
//     final bloc = Provider.of<PodcastBloc>(context);
//
//     return StreamBuilder<BlocState<Podcast>>(
//       stream: bloc.details,
//       builder: (context, snapshot) {
//         if (snapshot.hasData) {
//           final state = snapshot.data;
//
//           if (state is BlocPopulatedState<Podcast>) {
//             final p = state.results!;
//
//             return Semantics(
//               liveRegion: true,
//               child: p.subscribed
//                   ? OutlinedButton.icon(
//                       style: OutlinedButton.styleFrom(
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(8),
//                         ),
//                       ),
//                       icon: const Icon(
//                         Icons.delete_outline,
//                       ),
//                       label: Text(L.of(context)!.unsubscribe_label),
//                       onPressed: () {
//                         showPlatformDialog<void>(
//                           context: context,
//                           useRootNavigator: false,
//                           builder: (_) => BasicDialogAlert(
//                             title: Text(L.of(context)!.unsubscribe_label),
//                             content: Text(L.of(context)!.unsubscribe_message),
//                             actions: <Widget>[
//                               BasicDialogAction(
//                                 title: ExcludeSemantics(
//                                   child: ActionText(
//                                     L.of(context)!.cancel_button_label,
//                                   ),
//                                 ),
//                                 onPressed: () {
//                                   Navigator.pop(context);
//                                 },
//                               ),
//                               BasicDialogAction(
//                                 title: ExcludeSemantics(
//                                   child: ActionText(
//                                     L.of(context)!.unsubscribe_button_label,
//                                   ),
//                                 ),
//                                 iosIsDefaultAction: true,
//                                 iosIsDestructiveAction: true,
//                                 onPressed: () {
//                                   bloc.podcastEvent(PodcastEvent.unsubscribe);
//
//                                   Navigator.pop(context);
//                                   Navigator.pop(context);
//                                 },
//                               ),
//                             ],
//                           ),
//                         );
//                       },
//                     )
//                   : OutlinedButton.icon(
//                       style: OutlinedButton.styleFrom(
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(8),
//                         ),
//                       ),
//                       icon: const Icon(
//                         Icons.add,
//                       ),
//                       label: Text(L.of(context)!.subscribe_label),
//                       onPressed: () {
//                         bloc.podcastEvent(PodcastEvent.subscribe);
//                       },
//                     ),
//             );
//           }
//         }
//         return Container();
//       },
//     );
//   }
// }

class _SwitchBar extends ConsumerWidget {
  const _SwitchBar({
    required this.podcast,
    required this.seasons,
  });

  final Podcast podcast;
  final List<Season> seasons;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(
      podcastInfoProvider(podcast).select((value) => value.value?.stats),
    );

    final selectedViewMode = stats?.viewMode ?? PodcastDetailViewMode.episodes;

    final theme = Theme.of(context);
    return SliverToBoxAdapter(
      child: Container(
        color: theme.dividerColor,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            _PodcastViewModeSwitch(
              viewMode: selectedViewMode,
              onChanged: (mode) {
                ref
                    .read(podcastInfoProvider(podcast).notifier)
                    .setViewMode(mode);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _PodcastViewModeSwitch extends ConsumerWidget {
  const _PodcastViewModeSwitch({
    required this.viewMode,
    required this.onChanged,
  });

  final PodcastDetailViewMode viewMode;
  final ValueChanged<PodcastDetailViewMode> onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return PopupMenuButton<PodcastDetailViewMode>(
      onSelected: onChanged,
      position: PopupMenuPosition.under,
      child: Row(
        children: [
          Text(
            viewMode.label,
            style: theme.textTheme.titleMedium,
          ),
          const Icon(Icons.arrow_drop_down),
        ],
      ),
      itemBuilder: (context) {
        return PodcastDetailViewMode.values
            .map(
              (mode) => PopupMenuItem(
                value: mode,
                child: Text(mode.label),
              ),
            )
            .toList();
      },
    );
  }

  void _showViewModeMenu(BuildContext context) {
    final theme = Theme.of(context);
    final items = PodcastDetailViewMode.values
        .map((mode) => PopupMenuItem(
              value: mode,
              child: Text(mode.label),
            ))
        .toList();

    showMenu(
      context: context,
      position: const RelativeRect.fromLTRB(0, 0, 0, 0),
      items: items,
    ).then((value) {
      if (value != null) {
        onChanged(value);
      }
    });
  }
}

// class SeasonSwitch extends StatelessWidget {
//   const SeasonSwitch({required this.isOn, super.key});
//
//   final bool isOn;
//
//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       children: [
//         const Text('Season'),
//         Switch(
//           value: isOn,
//           onChanged: (isOn) {
//             final podcastBloc =
//                 Provider.of<PodcastBloc>(context, listen: false);
//             podcastBloc.toggleSeasonView();
//           },
//         ),
//       ],
//     );
//   }
// }
