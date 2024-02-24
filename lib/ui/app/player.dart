import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:seasoning/services/audio/audio_player_service.dart';
import 'package:seasoning/ui/app/app_bottom_navigation_bar.dart';
import 'package:seasoning/ui/mini_player/mini_player.dart';
import 'package:seasoning/ui/mini_player/utils.dart';

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
  const DetailedPlayer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final episode =
        ref.watch(audioPlayerServiceProvider.select((state) => state?.episode));
    if (episode == null) {
      return const SizedBox.shrink();
    }

    return MiniPlayer(
      valueNotifier: playerExpandProgress,
      minHeight: playerMinHeight,
      maxHeight: playerMaxHeight,
      controller: controller,
      elevation: 4,
      onDismissed: () {
        ref.read(audioPlayerServiceProvider.notifier).stop();
      },
      builder: (height, percentage) {
        final showsMiniPlayer = percentage < miniPlayerPercentageDeclaration;
        final width = MediaQuery.of(context).size.width;
        final maxImgSize = width * 0.4;

        final img = Image.network(episode.imageUrl!);
        final text = Text(episode.title);
        final buttonPlay = IconButton(
          icon: const Icon(Icons.pause),
          onPressed: () => ref.read(audioPlayerServiceProvider.notifier).play(),
        );

        //Declare additional widgets (eg. SkipButton) and variables
        if (!showsMiniPlayer) {
          var percentageExpandedPlayer = percentageFromValueInRange(
            min: playerMaxHeight * miniPlayerPercentageDeclaration +
                playerMinHeight,
            max: playerMaxHeight,
            value: height,
          );
          if (percentageExpandedPlayer < 0) {
            percentageExpandedPlayer = 0;
          }
          final paddingVertical = valueFromPercentageInRange(
            min: 0,
            max: 10,
            percentage: percentageExpandedPlayer,
          );
          final heightWithoutPadding = height - paddingVertical * 2;
          final imageSize = heightWithoutPadding > maxImgSize
              ? maxImgSize
              : heightWithoutPadding;
          final paddingLeft = valueFromPercentageInRange(
                min: 0,
                max: width - imageSize,
                percentage: percentageExpandedPlayer,
              ) /
              2;

          return Column(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: EdgeInsets.only(
                    left: paddingLeft,
                    top: paddingVertical,
                    bottom: paddingVertical,
                  ),
                  child: SizedBox(
                    height: imageSize,
                    child: img,
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 33),
                  child: Opacity(
                    opacity: percentageExpandedPlayer,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(child: text),
                        const Flexible(
                          child: SizedBox(
                            height: 80,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _SkipButton(forward: false),
                                _PlayButton(),
                                _SkipButton(forward: true),
                              ],
                            ),
                          ),
                        ),
                        const _ProgressIndicator(),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        }

        //MiniPlayer
        final percentageMiniPlayer = percentageFromValueInRange(
          min: playerMinHeight,
          max: playerMaxHeight * miniPlayerPercentageDeclaration +
              playerMinHeight,
          value: height,
        );

        final elementOpacity = 1 - 1 * percentageMiniPlayer;
        final progressIndicatorHeight = 4 - 4 * percentageMiniPlayer;

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
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium!
                                  .copyWith(
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
                  IconButton(
                    icon: const Icon(Icons.fullscreen),
                    onPressed: () {
                      controller.animateToHeight(state: PanelState.max);
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 3),
                    child: Opacity(
                      opacity: elementOpacity,
                      child: buttonPlay,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ProgressIndicator extends ConsumerWidget {
  const _ProgressIndicator();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playerState = ref.watch(audioPlayerServiceProvider);
    if (playerState == null) {
      return const SizedBox.shrink();
    }
    return LinearProgressIndicator(value: playerState.percentagePlayed);
  }
}

class _PlayButton extends ConsumerWidget {
  const _PlayButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playing =
        ref.watch(audioPlayerServiceProvider.select((state) => state?.playing));
    if (playing == null) {
      return const SizedBox.shrink();
    }
    return SizedBox(
      width: 70,
      height: 70,
      child: IconButton(
        iconSize: 50,
        icon: playing
            ? const Icon(Icons.pause_circle_filled)
            : const Icon(Icons.play_circle_filled),
        onPressed: () {
          if (playing) {
            ref.read(audioPlayerServiceProvider.notifier).pause();
          } else {
            ref.read(audioPlayerServiceProvider.notifier).play();
          }
        },
      ),
    );
  }
}

class _SkipButton extends ConsumerWidget {
  const _SkipButton({required this.forward});

  final bool forward;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final (position, episode) = ref.watch(audioPlayerServiceProvider
        .select((state) => (state?.position, state?.episode)));
    if (position == null) {
      return const SizedBox.shrink();
    }
    return IconButton(
      icon: forward
          ? const Icon(Icons.forward_30, size: 33)
          : const Icon(Icons.replay_10, size: 33),
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
