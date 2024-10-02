import 'package:audiflow/constants/app_sizes.dart';
import 'package:audiflow/features/browser/podcast/data/podcast_provider.dart';
import 'package:audiflow/features/player/service/audio_player_service.dart';
import 'package:audiflow/features/player/ui/expandable_player/expandable_player_controller.dart';
import 'package:audiflow/features/player/ui/expandable_player/mini_player_height_provider.dart';
import 'package:audiflow/features/player/ui/expandable_player/player_buttons.dart';
import 'package:audiflow/features/player/ui/expandable_player_frame/utils.dart';
import 'package:audiflow/features/player/ui/seekbar_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MiniPlayerContent extends ConsumerWidget {
  const MiniPlayerContent({
    required this.episode,
    required this.height,
    required this.minHeight,
    required this.maxHeight,
    super.key,
  });

  final Episode episode;
  final double height;
  final double minHeight;
  final double maxHeight;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final width = MediaQuery.of(context).size.width;
    final maxImgSize = width * 0.13;

    final percentageMiniPlayer = percentageFromValueInRange(
      min: minHeight,
      max: maxHeight * miniPlayerPercentageDeclaration + minHeight,
      value: height,
    );
    final playerPhase =
        ref.watch(audioPlayerServiceProvider.select((state) => state?.phase));
    final hasPlayerAudio = playerPhase != null;
    final isPlaying = playerPhase == PlayerPhase.play;

    final seekbarState = hasPlayerAudio
        ? ref.watch(audioSeekbarControllerProvider)
        : ref.watch(episodeSeekbarControllerProvider(episode));

    final podcastState = ref.watch(podcastProvider(episode.pid));
    final imageUrl = episode.imageUrl ?? podcastState.valueOrNull?.image;

    final elementOpacity = 1 - 1 * percentageMiniPlayer;
    final theme = Theme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: const [0, 0.1],
          colors: [
            theme.colorScheme.surfaceContainer.withOpacity(0),
            theme.colorScheme.surfaceContainer,
          ],
        ),
      ),
      child: Opacity(
        opacity: elementOpacity,
        child: Column(
          children: [
            gapH8,
            _PositionBar(
              position: seekbarState?.position,
              duration: seekbarState?.duration,
            ),
            Expanded(
              child: Row(
                children: [
                  gapW12,
                  if (imageUrl != null) ...[
                    ConstrainedBox(
                      constraints: BoxConstraints(maxHeight: maxImgSize),
                      child: Image.network(
                        imageUrl,
                        errorBuilder: (context, error, stackTrace) {
                          return const SizedBox.shrink();
                        },
                      ),
                    ),
                    gapW8,
                  ],
                  Expanded(
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
                              .bodyMedium!
                              .copyWith(fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                  PlayButton.small(
                    isPlaying: isPlaying,
                    onTap: () => ref
                        .read(expandablePlayerControllerProvider.notifier)
                        .togglePlayPause(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PositionBar extends StatelessWidget {
  const _PositionBar({
    required this.position,
    required this.duration,
  });

  final Duration? position;
  final Duration? duration;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      height: 2,
      width: double.infinity,
      child: SliderTheme(
        data: SliderTheme.of(context).copyWith(
          trackHeight: 2,
          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 0),
          overlayShape: const RoundSliderOverlayShape(overlayRadius: 2),
          overlayColor: Colors.transparent,
          inactiveTrackColor: theme.colorScheme.inversePrimary.withOpacity(0.5),
        ),
        child: (position == null || duration == null)
            ? const Slider(value: 0, onChanged: null)
            : Slider(
                value: position!.inMilliseconds.toDouble(),
                max: duration!.inMilliseconds.toDouble(),
                onChanged: (_) {},
              ),
      ),
    );
  }
}
