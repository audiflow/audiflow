import 'package:audiflow/gen/l10n/l10n.dart';
import 'package:audiflow/core/types.dart';
import 'package:audiflow/entities/entities.dart';
import 'package:audiflow/services/audio/audio_player_service.dart';
import 'package:audiflow/ui/providers/episodes_group_provider.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

class ContextualPlayButton extends ConsumerWidget {
  const ContextualPlayButton(
    this.episodes, {
    required this.episodeGroupKey,
    required this.playOrder,
    required this.isSeries,
    super.key,
  });

  final Key episodeGroupKey;
  final List<Episode> episodes;
  final PlayOrder playOrder;
  final bool isSeries;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder(
      future: _buttonCaptionAndIcon(context, ref),
      builder: (context, snapshot) {
        final (captionText, icon, targetEpisode) =
            snapshot.data ?? (null, null, null);
        return FilledButton.tonalIcon(
          icon: AnimatedOpacity(
            opacity: captionText == null ? 0 : 1,
            duration: const Duration(milliseconds: 200),
            child: Icon(icon),
          ),
          label: AnimatedOpacity(
            opacity: captionText == null ? 0 : 1,
            duration: const Duration(milliseconds: 200),
            child: Text(captionText ?? ''),
          ),
          onPressed: targetEpisode == null
              ? null
              : () {
                  ref
                      .read(episodesGroupProvider(episodeGroupKey).notifier)
                      .togglePlayState(episode: targetEpisode);
                },
        );
      },
    );
  }

  Future<(String?, IconData?, Episode?)> _buttonCaptionAndIcon(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final playerState = ref.watch(audioPlayerServiceProvider);
    final isPlayerActive = playerState != null;
    final playerEpisode = isPlayerActive
        ? episodes.firstWhereOrNull((e) => e.guid == playerState.episode.guid)
        : null;

    final l10n = L10n.of(context)!;
    if (playerEpisode != null) {
      if (playerState!.phase == PlayerPhase.play) {
        return (l10n.pause, Symbols.pause_rounded, playerEpisode);
      } else {
        return (l10n.resume, Symbols.play_arrow_rounded, playerEpisode);
      }
    }

    final state = ref.watch(episodesGroupProvider(episodeGroupKey));
    if (!state.hasValue) {
      return (null, null, null);
    }

    final (targetEpisode, buttonState) = await ref
        .read(episodesGroupProvider(episodeGroupKey).notifier)
        .nextEpisodeToPlay(
          playOrder: playOrder,
          isSeries: isSeries,
        );
    var captionText = '';
    switch (buttonState) {
      case ConditionalPlayButtonState.fromStart:
        captionText = l10n.playFromStart;
      case ConditionalPlayButtonState.latest:
        captionText = l10n.playLatest;
      case ConditionalPlayButtonState.latestAgain:
        captionText = l10n.playAgain;
      case ConditionalPlayButtonState.resume:
        captionText = l10n.resume;
    }
    return (captionText, Symbols.play_arrow_rounded, targetEpisode);
  }
}
