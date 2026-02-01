import '../../../common/database/app_database.dart';
import '../extensions/episode_extensions.dart';
import '../models/smart_playlist.dart';
import '../models/smart_playlist_pattern.dart';
import '../models/smart_playlist_sort.dart';
import '../models/smart_playlist_title_extractor.dart';
import 'smart_playlist_resolver.dart';

/// Resolver that groups episodes using RSS metadata (seasonNumber field).
class RssMetadataResolver implements SmartPlaylistResolver {
  @override
  String get type => 'rss';

  @override
  SmartPlaylistSortSpec get defaultSort => const SimpleSmartPlaylistSort(
    SmartPlaylistSortField.playlistNumber,
    SortOrder.ascending,
  );

  @override
  SmartPlaylistGrouping? resolve(
    List<Episode> episodes,
    SmartPlaylistPattern? pattern,
  ) {
    final grouped = <int, List<Episode>>{};
    final ungrouped = <int>[];

    // Check for groupNullSeasonAs config
    final groupNullAs = pattern?.config['groupNullSeasonAs'] as int?;

    for (final episode in episodes) {
      final seasonNum = episode.seasonNumber;

      if (seasonNum != null && 1 <= seasonNum) {
        // Positive season number - group normally
        grouped.putIfAbsent(seasonNum, () => []).add(episode);
      } else if (groupNullAs != null) {
        // Null/zero season number with groupNullSeasonAs config
        grouped.putIfAbsent(groupNullAs, () => []).add(episode);
      } else {
        // No config for grouping - mark as ungrouped
        ungrouped.add(episode.id);
      }
    }

    // Return null if no episodes have season numbers
    if (grouped.isEmpty) {
      return null;
    }

    final titleExtractor = pattern?.titleExtractor;

    final yearGroupedMap =
        pattern?.config['yearGroupedPlaylists'] as Map<String, dynamic>?;

    final playlists = grouped.entries.map((entry) {
      final seasonNumber = entry.key;
      final playlistEpisodes = entry.value;
      final displayName = _extractDisplayName(
        seasonNumber: seasonNumber,
        episodes: playlistEpisodes,
        titleExtractor: titleExtractor,
      );

      return SmartPlaylist(
        id: 'season_$seasonNumber',
        displayName: displayName,
        sortKey: seasonNumber,
        episodeIds: playlistEpisodes.map((e) => e.id).toList(),
        yearHeaderMode: yearGroupedMap?['$seasonNumber'] == true
            ? YearHeaderMode.firstEpisode
            : YearHeaderMode.none,
      );
    }).toList()..sort((a, b) => a.sortKey.compareTo(b.sortKey));

    return SmartPlaylistGrouping(
      playlists: playlists,
      ungroupedEpisodeIds: ungrouped,
      resolverType: type,
    );
  }

  String _extractDisplayName({
    required int seasonNumber,
    required List<Episode> episodes,
    required SmartPlaylistTitleExtractor? titleExtractor,
  }) {
    if (titleExtractor == null || episodes.isEmpty) {
      return 'Season $seasonNumber';
    }

    final extracted = titleExtractor.extract(episodes.first.toEpisodeData());
    return extracted ?? 'Season $seasonNumber';
  }
}
