import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:seasoning/entities/entities.dart';
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
        //Declare additional widgets (eg. SkipButton) and variables
        return showsMiniPlayer
            ? _MiniPlayerContent(episode: episode, height: height)
            : _DetailedPlayerContent(episode: episode, height: height);
      },
    );
  }
}

class _MiniPlayerContent extends StatelessWidget {
  const _MiniPlayerContent({
    required this.episode,
    required this.height,
  });

  final Episode episode;
  final double height;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final maxImgSize = width * 0.4;
    final img = Image.network(episode.thumbImageUrl!);

    //MiniPlayer
    final percentageMiniPlayer = percentageFromValueInRange(
      min: playerMinHeight,
      max: playerMaxHeight * miniPlayerPercentageDeclaration + playerMinHeight,
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
              _IconButton(
                icon: Icons.fullscreen,
                iconSize: IconSize.small,
                onPressed: () {
                  controller.animateToHeight(state: PanelState.max);
                },
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

class _DetailedPlayerContent extends StatelessWidget {
  const _DetailedPlayerContent({
    required this.height,
    required this.episode,
  });

  final Episode episode;
  final double height;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final maxImgSize = width * 0.4;
    final image = Image.network(episode.imageUrl!);
    final text = Text(episode.title);

    var percentageExpandedPlayer = percentageFromValueInRange(
      min: playerMaxHeight * miniPlayerPercentageDeclaration + playerMinHeight,
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
    final imageSize =
        maxImgSize < heightWithoutPadding ? maxImgSize : heightWithoutPadding;
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
              child: image,
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
                          _PlayButton.large(),
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
    final playing =
        ref.watch(audioPlayerServiceProvider.select((state) => state?.playing));
    return playing == null
        ? const SizedBox.shrink()
        : playing
            ? _IconButton(
                icon: pauseIcon,
                iconSize: iconSize,
                onPressed: () =>
                    ref.read(audioPlayerServiceProvider.notifier).pause(),
              )
            : _IconButton(
                icon: pauseIcon,
                iconSize: iconSize,
                onPressed: () =>
                    ref.read(audioPlayerServiceProvider.notifier).pause(),
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
