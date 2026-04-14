import '../models/episode.dart';
import '../extensions/episode_extensions.dart';
import '../models/smart_playlist.dart';
import '../models/smart_playlist_definition.dart';
import '../models/smart_playlist_sort.dart';
import '../models/smart_playlist_title_extractor.dart';
import 'smart_playlist_resolver.dart';

/// Resolver that groups episodes by the RSS seasonNumber field.
class SeasonNumberResolver implements SmartPlaylistResolver {
  @override
  String get type => 'seasonNumber';

  @override
  SmartPlaylistSortRule get defaultSort => const SmartPlaylistSortRule(
    field: SmartPlaylistSortField.playlistNumber,
    order: SortOrder.ascending,
  );

  @override
  SmartPlaylistGrouping? resolve(
    List<Episode> episodes,
    SmartPlaylistDefinition? definition,
  ) {
    return _resolveBySeasonNumber(episodes, definition);
  }

  SmartPlaylistGrouping? _resolveBySeasonNumber(
    List<Episode> episodes,
    SmartPlaylistDefinition? definition,
  ) {
    final grouped = <int, List<Episode>>{};
    final ungrouped = <int>[];

    for (final episode in episodes) {
      final seasonNum = episode.seasonNumber;
      if (seasonNum != null && 1 <= seasonNum) {
        grouped.putIfAbsent(seasonNum, () => []).add(episode);
      } else {
        ungrouped.add(episode.id);
      }
    }

    if (grouped.isEmpty) return null;

    final titleExtractor = definition?.groupItem?.titleExtractor;

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
