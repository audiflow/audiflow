// Copyright 2024 HANAI Tohru, Reedom, INC.
// Copyright 2020 Ben Hills and the project contributors.
// All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:seasoning/entities/podcast.dart';
import 'package:seasoning/features/podcast_details/ui/podcast_details_app_bar.dart';
import 'package:seasoning/features/podcast_details/ui/podcast_episode_list.dart';
import 'package:seasoning/l10n/L.dart';
import 'package:seasoning/providers/podcast/podcast_details_provider.dart';
import 'package:seasoning/providers/settings_service_provider.dart';
import 'package:seasoning/ui/podcast/funding_menu.dart';
import 'package:seasoning/ui/widgets/fill_remaining_error.dart';
import 'package:seasoning/ui/widgets/fill_remaining_loading.dart';
import 'package:seasoning/ui/widgets/podcast_html.dart';

/// This Widget takes a search result and builds a list of currently available
/// podcasts.
///
/// From here a user can option to subscribe/unsubscribe or play a podcast
/// directly from a search result.
class PodcastDetails extends HookConsumerWidget {
  const PodcastDetails(
    this.baseInfo, {
    super.key,
  });

  final PodcastSummary baseInfo;

  // widget._podcastBloc.backgroundLoading
  //     .where((event) => event is BlocPopulatedState<void>)
  //     .listen((event) {
  //   if (mounted) {
  //     /// If we have not scrolled (save a few pixels) just refresh the episode
  //     /// list; otherwise prompt the user to prevent unexpected list jumping
  //     if (_sliverScrollController.offset < 20) {
  //       widget._podcastBloc.podcastEvent(PodcastEvent.refresh);
  //     } else {
  //       scaffoldMessengerKey.currentState!.showSnackBar(
  //         SnackBar(
  //           content: Text(L.of(context)!.new_episodes_label),
  //           behavior: SnackBarBehavior.floating,
  //           action: SnackBarAction(
  //             label: L.of(context)!.new_episodes_view_now_label,
  //             onPressed: () {
  //               _sliverScrollController.animateTo(
  //                 100,
  //                 duration: const Duration(milliseconds: 500),
  //                 curve: Curves.easeInOut,
  //               );
  //               widget._podcastBloc.podcastEvent(PodcastEvent.refresh);
  //             },
  //           ),
  //           duration: const Duration(seconds: 5),
  //         ),
  //       );
  //     }
  //   }
  // });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scaffoldMessengerKey =
        useState(GlobalKey<ScaffoldMessengerState>()).value;
    final podcastDetailsState =
        ref.watch(podcastDetailsProvider.call(baseInfo));
    final podcast = podcastDetailsState.value?.podcast;

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
                PodcastDetailsAppBar(summary: baseInfo),
                if (podcastDetailsState.isLoading)
                  const FillRemainingLoading()
                else if (podcastDetailsState.hasError || podcast == null)
                  FillRemainingError.podcastNoResults()
                else ...[
                  _PodcastTitle(podcast),
                  PodcastEpisodeList(
                    summary: podcast,
                    episodes: podcast.episodes,
                    play: true,
                    download: true,
                  ),
                ],
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
