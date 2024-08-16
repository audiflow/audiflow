import 'dart:math';
import 'dart:ui' as ui;

import 'package:audiflow/features/player/service/audio_player_service.dart';
import 'package:audiflow/features/player/ui/expandable_player/expandable_player_controller.dart';
import 'package:audiflow/features/player/ui/expandable_player/mini_player_height_provider.dart';
import 'package:audiflow/features/player/ui/expandable_player/player_buttons.dart';
import 'package:audiflow/features/player/ui/expandable_player_frame/utils.dart';
import 'package:audiflow/features/player/ui/player_episode_tile.dart';
import 'package:audiflow/features/player/ui/seekbar.dart';
import 'package:audiflow/features/player/ui/seekbar_controller.dart';
import 'package:audiflow/features/queue/model/queue.dart';
import 'package:audiflow/features/queue/service/queue_controller.dart';
import 'package:audiflow/features/queue/ui/queue_list_block.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class FullPlayerContent extends ConsumerWidget {
  const FullPlayerContent({
    required this.episode,
    required this.isQueueTopEpisode,
    required this.height,
    required this.minHeight,
    required this.maxHeight,
    super.key,
  });

  final Episode episode;
  final bool isQueueTopEpisode;
  final double height;
  final double minHeight;
  final double maxHeight;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final percentageExpandedPlayer = percentageFromValueInRange(
      min: maxHeight * miniPlayerPercentageDeclaration + playerMinHeight,
      max: maxHeight,
      value: height,
    );

    final playerPhase =
        ref.watch(audioPlayerServiceProvider.select((state) => state?.phase));
    final hasPlayerAudio = playerPhase != null;
    final isPlaying = playerPhase == PlayerPhase.play;

    final seekbarState = hasPlayerAudio
        ? ref.watch(audioSeekbarControllerProvider)
        : ref.watch(episodeSeekbarControllerProvider(episode));
    final seekbarController = hasPlayerAudio
        ? ref.read(audioSeekbarControllerProvider.notifier) as SeekbarController
        : ref.read(episodeSeekbarControllerProvider(episode).notifier)
            as SeekbarController;

    final queueTopEpisode = ref.watch(
      expandablePlayerControllerProvider
          .select((state) => state.queueTopEpisode),
    );
    final showPlayerEpisode = hasPlayerAudio || queueTopEpisode == null;
    final queue = ref.watch(queueControllerProvider).queue;
    final theme = Theme.of(context);
    return SafeArea(
      child: Opacity(
        opacity: percentageExpandedPlayer,
        child: Stack(
          children: [
            Align(
              alignment: Alignment.topCenter,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(
                    width: 50,
                    height: 50,
                    child: Divider(
                      thickness: 5,
                    ),
                  ),
                  if (showPlayerEpisode) PlayerEpisodeTile(episode: episode),
                  if (queue.isNotEmpty)
                    SizedBox(
                      height: max(0, min(maxHeight - 300, height - 350)),
                      child: const CustomScrollView(
                        slivers: [
                          QueueListBlock(queueType: QueueType.primary),
                          QueueListBlock(queueType: QueueType.adhoc),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                padding: const EdgeInsets.only(top: 16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: const [0.0, 0.1],
                    colors: [
                      theme.colorScheme.surfaceContainerHighest.withOpacity(0),
                      theme.colorScheme.surfaceContainerHighest,
                    ],
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Seekbar(
                      position: seekbarState?.position,
                      duration: seekbarState?.duration,
                      onSeek: seekbarController.seekTo,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SkipButton(
                          forward: false,
                          onTap: seekbarController.rewind,
                        ),
                        PlayButton.large(
                          isPlaying: isPlaying,
                          onTap: () => ref
                              .read(expandablePlayerControllerProvider.notifier)
                              .togglePlayPause(),
                        ),
                        SkipButton(
                          forward: true,
                          onTap: seekbarController.fastForward,
                        ),
                      ],
                    ),
                    SizedBox(
                      height: MediaQueryData.fromView(
                        ui.PlatformDispatcher.instance.implicitView!,
                      ).padding.bottom,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
