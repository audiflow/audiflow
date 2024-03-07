import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:seasoning/core/l10n.dart';
import 'package:seasoning/core/types.dart';
import 'package:seasoning/entities/entities.dart';
import 'package:seasoning/providers/podcast/episode_info_provider.dart';
import 'package:seasoning/services/audio/audio_player_service.dart';

class AnimatedPlayButton extends HookConsumerWidget {
  const AnimatedPlayButton(
    this.episode, {
    super.key,
  });

  final Episode episode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playPauseController = useAnimationController(
      duration: const Duration(milliseconds: 300),
    );

    final episodeState = ref.watch(episodeInfoProvider(episode));
    final playerState = ref.watch(audioPlayerServiceProvider);

    final isTarget =
        episodeState.hasValue && playerState?.episode.guid == episode.guid;
    final playing = isTarget && playerState?.phase == PlayerPhase.play;
    final buffering =
        isTarget && playerState?.audioState == AudioState.buffering;

    return Stack(
      alignment: AlignmentDirectional.center,
      children: [
        if (buffering)
          SpinKitRing(
            lineWidth: 4,
            color: Theme.of(context).splashColor,
            size: 84,
          ),
        if (!buffering)
          const SizedBox(
            height: 84,
            width: 84,
          ),
        Tooltip(
          message: playing
              ? L10n.of(context)!.pause_button_label
              : L10n.of(context)!.play_button_label,
          child: TextButton(
            style: TextButton.styleFrom(
              shape: CircleBorder(
                side: BorderSide(
                  color: Theme.of(context).highlightColor,
                  width: 0,
                ),
              ),
              backgroundColor: Theme.of(context).brightness == Brightness.light
                  ? Colors.orange
                  : Colors.grey[800],
              foregroundColor: Theme.of(context).brightness == Brightness.light
                  ? Colors.orange
                  : Colors.grey[800],
              padding: const EdgeInsets.all(6),
            ),
            onPressed: () {
              PlayButtonTappedNotification(episode).dispatch(context);
            },
            child: AnimatedIcon(
              semanticLabel: playing
                  ? L10n.of(context)!.pause_button_label
                  : L10n.of(context)!.play_button_label,
              icon:
                  playing ? AnimatedIcons.pause_play : AnimatedIcons.play_pause,
              color: Colors.white,
              progress: playPauseController,
            ),
          ),
        ),
      ],
    );
  }
}
