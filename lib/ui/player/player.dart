import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:seasoning/entities/entities.dart';
import 'package:seasoning/services/audio/audio_player_service.dart';
import 'package:seasoning/services/queue/queue_list_provider.dart';
import 'package:seasoning/ui/app/app_bottom_navigation_bar.dart';
import 'package:seasoning/ui/mini_player/mini_player.dart';
import 'package:seasoning/ui/mini_player/utils.dart';
import 'package:seasoning/ui/player/player_episode_tile.dart';
import 'package:seasoning/ui/podcast/queue_list_block.dart';
import 'package:seasoning/ui/widgets/seek_bar.dart';

final ValueNotifier<double> playerExpandProgress =
    ValueNotifier(playerMinHeight);

double valueFromPercentageInRange({
  required double min,
  required double max,
  required double percentage,
}) {
  return percentage * (max - min) + min;
}

final controller = MiniPlayerController();

class DetailedPlayer extends HookConsumerWidget {
  const DetailedPlayer({
    super.key,
    required this.minHeight,
    required this.maxHeight,
  });

  final double minHeight;
  final double maxHeight;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final episode =
        ref.watch(audioPlayerServiceProvider.select((state) => state?.episode));
    if (episode == null) {
      return const SizedBox.shrink();
    }

    return MiniPlayer(
      valueNotifier: playerExpandProgress,
      minHeight: minHeight,
      maxHeight: maxHeight,
      controller: controller,
      elevation: 4,
      onDismissed: () {
        ref.read(audioPlayerServiceProvider.notifier).stop();
      },
      builder: (height, percentage) {
        final showsMiniPlayer = percentage < miniPlayerPercentageDeclaration;
        return showsMiniPlayer
            ? _MiniPlayerContent(
                episode: episode,
                height: height,
                minHeight: minHeight,
                maxHeight: maxHeight,
              )
            : _DetailedPlayerContent(
                episode: episode,
                height: height,
                minHeight: minHeight,
                maxHeight: maxHeight,
              );
      },
    );
  }
}

class _MiniPlayerContent extends StatelessWidget {
  const _MiniPlayerContent({
    required this.episode,
    required this.height,
    required this.minHeight,
    required this.maxHeight,
  });

  final Episode episode;
  final double height;
  final double minHeight;
  final double maxHeight;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final maxImgSize = width * 0.4;
    final img = Image.network(
      episode.thumbImageUrl!,
      errorBuilder: (context, error, stackTrace) {
        return const SizedBox.shrink();
      },
    );

    //MiniPlayer
    final percentageMiniPlayer = percentageFromValueInRange(
      min: minHeight,
      max: maxHeight * miniPlayerPercentageDeclaration + minHeight,
      value: height,
    );

    final elementOpacity = 1 - 1 * percentageMiniPlayer;
    return Column(
      children: [
        Expanded(
          child: Row(
            children: [
              ConstrainedBox(
                constraints: BoxConstraints(maxHeight: maxImgSize),
                child: img,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: Opacity(
                    opacity: elementOpacity,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          episode.title,
                          maxLines: 3,
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall!
                              .copyWith(fontSize: 16),
                        ),
                        Text(
                          '',
                          style:
                              Theme.of(context).textTheme.bodyMedium!.copyWith(
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodyMedium!
                                        .color!
                                        .withOpacity(0.55),
                                  ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 3),
                child: Opacity(
                  opacity: elementOpacity,
                  child: const _PlayButton.small(),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DetailedPlayerContent extends ConsumerWidget {
  const _DetailedPlayerContent({
    required this.episode,
    required this.height,
    required this.minHeight,
    required this.maxHeight,
  });

  final Episode episode;
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

    final queue = ref.watch(queueListProvider).queue;

    return Opacity(
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
                PlayerEpisodeTile(episode: episode),
                if (queue.isNotEmpty)
                  SizedBox(
                    height: max(0, min(maxHeight - 300, height - 350)),
                    child: const CustomScrollView(
                      slivers: [
                        QueueListBlock(),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SeekBar(),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _SkipButton(forward: false),
                    _PlayButton.large(),
                    _SkipButton(forward: true),
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
        ],
      ),
    );
  }
}

enum IconSize {
  small,
  middle,
  large;

  double get size {
    switch (this) {
      case IconSize.small:
        return 46;
      case IconSize.middle:
        return 60;
      case IconSize.large:
        return 70;
    }
  }

  double get iconSize {
    switch (this) {
      case IconSize.small:
        return 30;
      case IconSize.middle:
        return 40;
      case IconSize.large:
        return 50;
    }
  }
}

class _IconButton extends StatelessWidget {
  const _IconButton({
    required this.icon,
    required this.iconSize,
    required this.onPressed,
  });

  final IconData icon;
  final IconSize iconSize;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: iconSize.size,
      height: iconSize.size,
      child: IconButton(
        iconSize: iconSize.iconSize,
        icon: Icon(icon),
        onPressed: onPressed,
      ),
    );
  }
}

class _PlayButton extends ConsumerWidget {
  const _PlayButton({
    required this.iconSize,
    required this.playIcon,
    required this.pauseIcon,
  });

  const _PlayButton.large()
      : iconSize = IconSize.large,
        playIcon = Icons.play_circle_filled,
        pauseIcon = Icons.pause_circle_filled;

  const _PlayButton.small()
      : iconSize = IconSize.small,
        playIcon = Icons.play_arrow_outlined,
        pauseIcon = Icons.pause_rounded;

  final IconSize iconSize;

  final IconData pauseIcon;
  final IconData playIcon;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playerPhase = ref.watch(
      audioPlayerServiceProvider.select((state) => state?.phase),
    );
    return playerPhase == null
        ? const SizedBox.shrink()
        : playerPhase == PlayerPhase.play
            ? _IconButton(
                icon: pauseIcon,
                iconSize: iconSize,
                onPressed: () =>
                    ref.read(audioPlayerServiceProvider.notifier).pause(),
              )
            : _IconButton(
                icon: playIcon,
                iconSize: iconSize,
                onPressed: () =>
                    ref.read(audioPlayerServiceProvider.notifier).play(),
              );
  }
}

class _SkipButton extends ConsumerWidget {
  const _SkipButton({required this.forward});

  final bool forward;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final (position, episode) = ref.watch(
      audioPlayerServiceProvider
          .select((state) => (state?.position, state?.episode)),
    );
    if (position == null) {
      return const SizedBox.shrink();
    }
    return _IconButton(
      icon: forward ? Icons.forward_30 : Icons.replay_10,
      iconSize: IconSize.middle,
      onPressed: () {
        // final position = playerState.position +
        //     (forward
        //         ? const Duration(seconds: 30)
        //         : const Duration(seconds: -10));
        final newPosition = forward
            ? episode!.duration! - const Duration(seconds: 10)
            : position + const Duration(seconds: -10);
        ref
            .read(audioPlayerServiceProvider.notifier)
            .seek(position: newPosition);
      },
    );
  }
}
