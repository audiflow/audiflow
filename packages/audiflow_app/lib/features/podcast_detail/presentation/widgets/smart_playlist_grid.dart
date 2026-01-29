import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:audiflow_ui/audiflow_ui.dart';
import 'package:flutter/material.dart';

import 'smart_playlist_card.dart';

/// List of smart playlist cards for the playlists view.
class SmartPlaylistGrid extends StatelessWidget {
  const SmartPlaylistGrid({
    super.key,
    required this.smartPlaylists,
    required this.ungroupedEpisodeIds,
    required this.onSmartPlaylistTap,
    required this.onUngroupedTap,
    this.episodeProgressMap = const {},
  });

  final List<SmartPlaylist> smartPlaylists;
  final List<int> ungroupedEpisodeIds;
  final void Function(SmartPlaylist playlist) onSmartPlaylistTap;
  final VoidCallback onUngroupedTap;

  /// Map of episode ID to played status.
  final Map<int, bool> episodeProgressMap;

  @override
  Widget build(BuildContext context) {
    final itemCount =
        smartPlaylists.length + (ungroupedEpisodeIds.isNotEmpty ? 1 : 0);

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: Spacing.md),
      sliver: SliverList.builder(
        itemCount: itemCount,
        itemBuilder: (context, index) {
          if (index < smartPlaylists.length) {
            return Padding(
              padding: const EdgeInsets.only(bottom: Spacing.sm),
              child: _buildSmartPlaylistCard(smartPlaylists[index]),
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

  Widget _buildSmartPlaylistCard(SmartPlaylist playlist) {
    final playedCount = playlist.episodeIds
        .where((id) => episodeProgressMap[id] == true)
        .length;

    return SmartPlaylistCard(
      smartPlaylist: playlist,
      episodeCount: playlist.episodeCount,
      playedCount: playedCount,
      thumbnailUrl: playlist.thumbnailUrl,
      onTap: () => onSmartPlaylistTap(playlist),
    );
  }

  Widget _buildUngroupedCard() {
    final playedCount = ungroupedEpisodeIds
        .where((id) => episodeProgressMap[id] == true)
        .length;

    return SmartPlaylistCard(
      smartPlaylist: SmartPlaylist(
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
