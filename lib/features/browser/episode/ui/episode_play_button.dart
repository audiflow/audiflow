import 'package:audiflow/features/browser/episode/data/episode_stats_provider.dart';
import 'package:audiflow/features/player/service/audio_player_service.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class EpisodePlayButton extends ConsumerWidget {
  const EpisodePlayButton({
    required this.episode,
    super.key,
  });

  final Episode episode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPlaying = ref.watch(
      audioPlayerServiceProvider.select(
        (state) =>
            state?.episode.guid == episode.guid &&
            state?.phase == PlayerPhase.play,
      ),
    );
    final stats = ref.watch(episodeStatsProvider(eid: episode.id));
    return Opacity(
      opacity: stats.hasValue ? 1 : 0,
      child: FilledButton.tonal(
        child: Text(_caption(context, stats.valueOrNull, isPlaying: isPlaying)),
        onPressed: () {},
      ),
    );
  }

  String _caption(
    BuildContext context,
    EpisodeStats? stats, {
    required bool isPlaying,
  }) {
    if (isPlaying) {
      return 'Pause';
    }

    if (stats == null) {
      return 'Play';
    }

    final percentage = stats.percentagePlayed(episode.duration);
    if (0 < percentage && percentage < 1) {
      return 'Resume';
    }
    if (percentage == 0 && !stats.played) {
      return 'Play';
    } else {
      return 'Play again';
    }
  }
}
