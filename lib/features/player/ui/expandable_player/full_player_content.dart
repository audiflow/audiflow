import 'package:audiflow/constants/app_sizes.dart';
import 'package:audiflow/features/player/service/audio_player_preference.dart';
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
import 'package:flutter_hooks/flutter_hooks.dart';
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

  static const double _totalContentMinHeight = 340;
  static const double _panelHeight = 160;

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

    final queueTopEpisode = ref.watch(
      expandablePlayerControllerProvider
          .select((state) => state.queueTopEpisode),
    );
    final showPlayerEpisode = hasPlayerAudio || queueTopEpisode == null;
    final queue = ref.watch(queueControllerProvider).queue;
    final theme = Theme.of(context);
    return SafeArea(
      child: ColoredBox(
        color: theme.colorScheme.surface,
        child: Opacity(
          opacity: percentageExpandedPlayer,
          child: Column(
            children: [
              const SizedBox(
                width: 50,
                height: 50,
                child: Divider(thickness: 5),
              ),
              if (showPlayerEpisode) PlayerEpisodeTile(episode: episode),
              Expanded(
                child: Stack(
                  children: [
                    ColoredBox(color: theme.colorScheme.surface),
                    if (queue.isNotEmpty)
                      const CustomScrollView(
                        slivers: [
                          QueueListBlock(queueType: QueueType.primary),
                          QueueListBlock(queueType: QueueType.adhoc),
                        ],
                      ),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        width: double.infinity,
                        height: 8,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            stops: const [0, 1],
                            colors: [
                              theme.colorScheme.surface.withOpacity(0),
                              theme.colorScheme.surface,
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              ClipRect(
                child: Align(
                  alignment: Alignment.topCenter,
                  heightFactor: _panelHeightFactor,
                  child: _PlayerControlPanel(episode: episode),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  double get _panelHeightFactor {
    return _totalContentMinHeight <= height
        ? 1
        : (height - (_totalContentMinHeight - _panelHeight)) / _panelHeight;
  }
}

class _PlayerControlPanel extends HookConsumerWidget {
  const _PlayerControlPanel({
    required this.episode,
  });

  final Episode episode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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

    final audioPlayerPreference = ref.read(audioPlayerPreferenceProvider);
    final speedState =
        useState<double>(audioPlayerPreference.valueOrNull?.speed ?? 1);
    ref.listen(audioPlayerPreferenceProvider, (_, next) {
      if (!next.hasValue) {
        return;
      }
      if (speedState.value != next.requireValue.speed) {
        speedState.value = next.requireValue.speed;
      }
    });

    return Column(
      children: [
        Seekbar(
          position: seekbarState?.position,
          duration: seekbarState?.duration,
          onSeek: seekbarController.seekTo,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            PlaybackSpeedButton(
              speed: speedState.value,
              onTap: () {
                ref.read(audioPlayerPreferenceProvider.notifier).changeSpeed();
              },
            ),
            const Spacer(),
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
            const Spacer(),
          ],
        ),
        gapH48,
      ],
    );
  }
}
