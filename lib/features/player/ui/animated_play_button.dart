import 'package:audiflow/events/play_button_notification.dart';
import 'package:audiflow/features/player/service/audio_player_service.dart';
import 'package:audiflow/localization/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

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

    final playerState = ref.watch(audioPlayerServiceProvider);

    final isTarget = playerState?.episode.guid == episode.guid;
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
              ? L10n.of(context).tooltipPause
              : L10n.of(context).tooltipPlay,
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
                  ? L10n.of(context).tooltipPause
                  : L10n.of(context).tooltipPlay,
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
