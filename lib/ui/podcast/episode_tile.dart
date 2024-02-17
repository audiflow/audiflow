// Copyright 2024 HANAI Tohru, Reedom, INC.
// Copyright 2020 Ben Hills and the project contributors.
// All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_dialogs/flutter_dialogs.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:seasoning/entities/entities.dart';
import 'package:seasoning/l10n/L.dart';
import 'package:seasoning/providers/podcast/episode_info_provider.dart';
import 'package:seasoning/ui/widgets/action_text.dart';
import 'package:seasoning/ui/widgets/tile_image.dart';

/// An EpisodeTitle is built with an ExpandedTile widget and displays the
/// episode's basic details, thumbnail and play button.
///
/// It can then be expanded to present addition information about the episode
/// and further controls.
///
// TODO(unknown): Replace [Opacity] with [Container] with a transparent colour.
class EpisodeTile extends HookConsumerWidget {
  const EpisodeTile({
    super.key,
    required this.summary,
    required this.episode,
    required this.download,
    required this.play,
  });

  final PodcastSummary summary;
  final Episode episode;
  final bool download;
  final bool play;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final textTheme = Theme.of(context).textTheme;
    const descriptionText = '(description)';

    final expandedState = useState(false);
    final expanded = expandedState.value;

    final state = ref.watch(EpisodeInfoProvider(episode));
    final stats = state.value?.stats;
    final played = stats?.played ?? false;
    final percentagePlayed = stats?.percentagePlayed ?? 0.0;
    final downloaded = state.value?.download?.downloaded ?? false;

    return Semantics(
      liveRegion: true,
      label: expanded
          ? L.of(context)!.semantics_episode_tile_expanded
          : L.of(context)!.semantics_episode_tile_collapsed,
      onTapHint: expanded
          ? L.of(context)!.semantics_episode_tile_expanded_hint
          : L.of(context)!.semantics_episode_tile_collapsed_hint,
      child: ExpansionTile(
        tilePadding: const EdgeInsets.fromLTRB(16, 0, 8, 0),
        key: Key('PT${episode.guid}'),
        onExpansionChanged: (isExpanded) {
          expandedState.value = isExpanded;
        },
        trailing: Opacity(
          opacity: played ? 0.5 : 1.0,
          child: EpisodeTransportControls(
            episode: episode,
            download: download,
            play: play,
          ),
        ),
        leading: ExcludeSemantics(
          child: Stack(
            alignment: Alignment.bottomLeft,
            fit: StackFit.passthrough,
            children: <Widget>[
              Opacity(
                opacity: played ? 0.5 : 1.0,
                child: TileImage(
                  url: episode.thumbImageUrl ?? episode.imageUrl!,
                  size: 56,
                  // highlight: episode.highlight,
                ),
              ),
              SizedBox(
                height: 5,
                width: 56.0 * (percentagePlayed / 100.0),
                child: Container(
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ],
          ),
        ),
        subtitle: Opacity(
          opacity: played ? 0.5 : 1.0,
          child: EpisodeSubtitle(episode, stats),
        ),
        title: Opacity(
          opacity: played ? 0.5 : 1.0,
          child: Text(
            episode.title,
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
            softWrap: false,
            style: textTheme.bodyMedium,
          ),
        ),
        children: <Widget>[
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 4,
              ),
              child: Text(
                descriptionText,
                overflow: TextOverflow.ellipsis,
                softWrap: false,
                maxLines: 5,
                style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.normal,
                    ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 4, 0, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  child: TextButton(
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    onPressed: downloaded
                        ? () {
                            showPlatformDialog<void>(
                              context: context,
                              useRootNavigator: false,
                              builder: (_) => BasicDialogAlert(
                                title: Text(
                                  L.of(context)!.delete_episode_title,
                                ),
                                content: Text(
                                  L.of(context)!.delete_episode_confirmation,
                                ),
                                actions: <Widget>[
                                  BasicDialogAction(
                                    title: ActionText(
                                      L.of(context)!.cancel_button_label,
                                    ),
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                  ),
                                  BasicDialogAction(
                                    title: ActionText(
                                      L.of(context)!.delete_button_label,
                                    ),
                                    iosIsDefaultAction: true,
                                    iosIsDestructiveAction: true,
                                    onPressed: () {
                                      // episodeBloc
                                      //     .deleteDownload(episode);
                                      // Navigator.pop(context);
                                    },
                                  ),
                                ],
                              ),
                            );
                          }
                        : null,
                    child: Column(
                      children: <Widget>[
                        Icon(
                          Icons.delete_outline,
                          semanticLabel:
                              L.of(context)!.delete_episode_button_label,
                          size: 22,
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 2),
                        ),
                        ExcludeSemantics(
                          child: Text(
                            L.of(context)!.delete_label,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: TextButton(
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(0),
                      ),
                    ),
                    onPressed: () {},
                    // onPressed: playing
                    //     ? null
                    //     : () {
                    //         if (queued) {
                    //           // queueBloc.queueEvent(
                    //           //   QueueRemoveEvent(episode: episode),
                    //           // );
                    //         } else {
                    //           // queueBloc.queueEvent(
                    //           //   QueueAddEvent(episode: episode),
                    //           // );
                    //         }
                    //       },
                    child: Column(
                      children: <Widget>[
                        Icon(
                          // queued
                          //     ? Icons.playlist_add_check_outlined
                          //     :
                          Icons.playlist_add_outlined,
                          semanticLabel:
                              // queued
                              //     ? L.of(context)!.semantics_remove_from_queue
                              //     :
                              L.of(context)!.semantics_add_to_queue,
                          size: 22,
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 2),
                        ),
                        const ExcludeSemantics(
                          child: Text(
                            // queued ? 'Remove' : 'Add',
                            'Add',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: TextButton(
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(0),
                      ),
                    ),
                    onPressed: () {
                      // episodeBloc.togglePlayed(episode);
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Icon(
                          played
                              ? Icons.unpublished_outlined
                              : Icons.check_circle_outline,
                          size: 22,
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 2),
                        ),
                        Text(
                          played
                              ? L.of(context)!.mark_unplayed_label
                              : L.of(context)!.mark_played_label,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: TextButton(
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(0),
                      ),
                    ),
                    onPressed: () {
                      showModalBottomSheet<void>(
                        context: context,
                        backgroundColor: theme.bottomAppBarTheme.color,
                        isScrollControlled: true,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(10),
                            topRight: Radius.circular(10),
                          ),
                        ),
                        builder: (context) {
                          return const SizedBox.shrink();
                          // return EpisodeDetails(
                          //   episode: episode,
                          // );
                        },
                      );
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        const Icon(
                          Icons.unfold_more_outlined,
                          size: 22,
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 2),
                        ),
                        Text(
                          L.of(context)!.more_label,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class EpisodeTransportControls extends StatelessWidget {
  const EpisodeTransportControls({
    super.key,
    required this.episode,
    required this.download,
    required this.play,
  });

  final Episode episode;
  final bool download;
  final bool play;

  @override
  Widget build(BuildContext context) {
    final buttons = <Widget>[];

    if (download) {
      buttons.add(
        Semantics(
          container: true,
          // child: DownloadControl(
          //   episode: episode,
          // ),
        ),
      );
    }

    if (play) {
      buttons.add(
        Semantics(
          container: true,
          // child: PlayControl(
          //   episode: episode,
          // ),
        ),
      );
    }

    return SizedBox(
      width: buttons.length * 48.0,
      child: Row(
        children: <Widget>[...buttons],
      ),
    );
  }
}

class EpisodeSubtitle extends StatelessWidget {
  EpisodeSubtitle(this.episode, this.stats, {super.key})
      : date = episode.publicationDate == null
            ? ''
            : DateFormat(
                episode.publicationDate!.year == DateTime.now().year
                    ? 'yyyy.MM'
                    : 'yyyy.MM.dd',
              ).format(episode.publicationDate!);
  final Episode episode;
  final EpisodeStats? stats;
  final String date;

  @override
  Widget build(BuildContext context) {
    var title = Duration.zero == episode.duration
        ? date
        : episode.duration.inSeconds < 60
            ? '$date - ${episode.duration.inSeconds} sec'
            : '$date - ${episode.duration.inMinutes} min';

    final timeRemaining = stats?.timeRemaining ?? Duration.zero;
    if (Duration.zero < timeRemaining) {
      title = timeRemaining.inSeconds < 60
          ? '$title / ${timeRemaining.inSeconds} sec left'
          : '$title / ${timeRemaining.inMinutes} min left';
    }

    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Text(
        title,
        overflow: TextOverflow.ellipsis,
        softWrap: false,
        style: Theme.of(context).textTheme.bodySmall,
      ),
    );
  }
}
