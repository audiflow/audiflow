import 'package:audiflow/features/player/service/audio_player_service.dart';
import 'package:audiflow/features/player/ui/expandable_player/expandable_player_controller.dart';
import 'package:audiflow/features/player/ui/expandable_player/mini_player_height_provider.dart';
import 'package:audiflow/features/player/ui/expandable_player/player_buttons.dart';
import 'package:audiflow/features/player/ui/expandable_player_frame/utils.dart';
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

    final isPlaying =
        ref.watch(audioPlayerServiceProvider)?.phase == PlayerPhase.play;

    final elementOpacity = 1 - 1 * percentageMiniPlayer;
    return ColoredBox(
      color: Colors.grey[50]!,
      child: Column(
        children: [
          Expanded(
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 16, right: 10),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxHeight: maxImgSize),
                    child: Image.network(
                      episode.imageUrl!,
                      errorBuilder: (context, error, stackTrace) {
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                ),
                Expanded(
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
                              .bodyMedium!
                              .copyWith(fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 3),
                  child: Opacity(
                    opacity: elementOpacity,
                    child: PlayButton.small(
                      isPlaying: isPlaying,
                      onTap: () => ref
                          .read(expandablePlayerControllerProvider.notifier)
                          .togglePlayPause(),
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
