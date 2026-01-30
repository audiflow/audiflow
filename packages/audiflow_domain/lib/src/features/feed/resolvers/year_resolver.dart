import '../../../common/database/app_database.dart';
import '../extensions/episode_extensions.dart';
import '../models/smart_playlist.dart';
import '../models/smart_playlist_pattern.dart';
import '../models/smart_playlist_sort.dart';
import '../models/smart_playlist_title_extractor.dart';
import 'smart_playlist_resolver.dart';

/// Resolver that groups episodes by publication year.
class YearResolver implements SmartPlaylistResolver {
  @override
  String get type => 'year';

  @override
  SmartPlaylistSortSpec get defaultSort => const SimpleSmartPlaylistSort(
    SmartPlaylistSortField.playlistNumber,
    SortOrder.descending, // Newest years first
  );

  @override
  SmartPlaylistGrouping? resolve(
    List<Episode> episodes,
    SmartPlaylistPattern? pattern,
  ) {
    final grouped = <int, List<Episode>>{};
    final ungrouped = <int>[];

    for (final episode in episodes) {
      final pubDate = episode.publishedAt;
      if (pubDate != null) {
        grouped.putIfAbsent(pubDate.year, () => []).add(episode);
      } else {
        ungrouped.add(episode.id);
      }
    }

    // Return null if no episodes have publish dates
    if (grouped.isEmpty) {
      return null;
    }

    final titleExtractor = pattern?.titleExtractor;

    final playlists = grouped.entries.map((entry) {
      final playlistEpisodes = entry.value;
      final displayName = _extractDisplayName(
        year: entry.key,
        episodes: playlistEpisodes,
        titleExtractor: titleExtractor,
      );

      return SmartPlaylist(
        id: 'year_${entry.key}',
        displayName: displayName,
        sortKey: entry.key,
        episodeIds: playlistEpisodes.map((e) => e.id).toList(),
      );
    }).toList()..sort((a, b) => b.sortKey.compareTo(a.sortKey)); // Descending

    return SmartPlaylistGrouping(
      playlists: playlists,
      ungroupedEpisodeIds: ungrouped,
      resolverType: type,
    );
  }

  String _extractDisplayName({
    required int year,
    required List<Episode> episodes,
    required SmartPlaylistTitleExtractor? titleExtractor,
  }) {
    if (titleExtractor == null || episodes.isEmpty) {
      return '$year';
    }

    // Try to extract title from first episode
    final extracted = titleExtractor.extract(episodes.first.toEpisodeData());
    return extracted ?? '$year';
  }
}
