import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:audiflow_ui/audiflow_ui.dart';
import 'package:flutter/material.dart';

import 'season_card.dart';

/// List of season cards for the seasons view.
class SeasonGrid extends StatelessWidget {
  const SeasonGrid({
    super.key,
    required this.seasons,
    required this.ungroupedEpisodeIds,
    required this.onSeasonTap,
    required this.onUngroupedTap,
    this.episodeProgressMap = const {},
  });

  final List<Season> seasons;
  final List<int> ungroupedEpisodeIds;
  final void Function(Season season) onSeasonTap;
  final VoidCallback onUngroupedTap;

  /// Map of episode ID to played status.
  final Map<int, bool> episodeProgressMap;

  @override
  Widget build(BuildContext context) {
    final itemCount = seasons.length + (ungroupedEpisodeIds.isNotEmpty ? 1 : 0);

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: Spacing.md),
      sliver: SliverList.builder(
        itemCount: itemCount,
        itemBuilder: (context, index) {
          if (index < seasons.length) {
            return Padding(
              padding: const EdgeInsets.only(bottom: Spacing.sm),
              child: _buildSeasonCard(seasons[index]),
            );
          }
          return Padding(
            padding: const EdgeInsets.only(bottom: Spacing.sm),
            child: _buildUngroupedCard(),
          );
        },
      ),
    );
  }

  Widget _buildSeasonCard(Season season) {
    final playedCount = season.episodeIds
        .where((id) => episodeProgressMap[id] == true)
        .length;

    return SeasonCard(
      season: season,
      episodeCount: season.episodeCount,
      playedCount: playedCount,
      onTap: () => onSeasonTap(season),
    );
  }

  Widget _buildUngroupedCard() {
    final playedCount = ungroupedEpisodeIds
        .where((id) => episodeProgressMap[id] == true)
        .length;

    return SeasonCard(
      season: Season(
        id: 'ungrouped',
        displayName: 'Ungrouped',
        sortKey: 999999,
        episodeIds: ungroupedEpisodeIds,
      ),
      episodeCount: ungroupedEpisodeIds.length,
      playedCount: playedCount,
      onTap: onUngroupedTap,
    );
  }
}
