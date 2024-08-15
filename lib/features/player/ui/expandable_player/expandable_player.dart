import 'package:audiflow/features/player/ui/expandable_player/expandable_player_controller.dart';
import 'package:audiflow/features/player/ui/expandable_player/full_player_content.dart';
import 'package:audiflow/features/player/ui/expandable_player/mini_player_content.dart';
import 'package:audiflow/features/player/ui/expandable_player/mini_player_height_provider.dart';
import 'package:audiflow/features/player/ui/expandable_player_frame/expandable_player_frame.dart';
import 'package:audiflow/features/player/ui/expandable_player_frame/expandable_player_frame_controller.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final ValueNotifier<double> playerExpandProgress =
    ValueNotifier(playerMinHeight);

double valueFromPercentageInRange({
  required double min,
  required double max,
  required double percentage,
}) {
  return percentage * (max - min) + min;
}

final controller = ExpandablePlayerFrameController();

class ExpandablePlayer extends HookConsumerWidget {
  const ExpandablePlayer({
    super.key,
    required this.minHeight,
    required this.maxHeight,
  });

  final double minHeight;
  final double maxHeight;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expandablePlayerState = ref.watch(expandablePlayerControllerProvider);
    if (expandablePlayerState.episode == null) {
      return const SizedBox.shrink();
    }

    return ExpandablePlayerFrame(
      valueNotifier: playerExpandProgress,
      miniHeight: minHeight,
      fullHeight: maxHeight,
      controller: controller,
      elevation: 4,
      builder: (height, percentage) {
        final showsMiniPlayer = percentage < miniPlayerPercentageDeclaration;
        return showsMiniPlayer
            ? MiniPlayerContent(
                episode: expandablePlayerState.episode!,
                height: height,
                minHeight: minHeight,
                maxHeight: maxHeight,
              )
            : FullPlayerContent(
                episode: expandablePlayerState.episode!,
                isQueueTopEpisode: expandablePlayerState.audioEpisode == null &&
                    expandablePlayerState.queueTopEpisode != null,
                height: height,
                minHeight: minHeight,
                maxHeight: maxHeight,
              );
      },
    );
  }
}
