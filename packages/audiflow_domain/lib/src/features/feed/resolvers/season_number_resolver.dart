import 'package:logger/logger.dart';

import '../models/episode.dart';
import '../extensions/episode_extensions.dart';
import '../models/smart_playlist.dart';
import '../models/smart_playlist_definition.dart';
import '../models/smart_playlist_sort.dart';
import '../models/smart_playlist_title_extractor.dart';
import 'smart_playlist_resolver.dart';

/// Whether a feed's `seasonNumber` metadata is trustworthy enough
/// to auto-group episodes by season.
///
/// Returns false (treat as non-seasonal) when **either** of these holds:
/// - No episode carries a `seasonNumber` of 2 or higher — the feed
///   either omits seasons or only tags S1 cosmetically.
/// - Episodes with a `seasonNumber` do not *strictly* outnumber those
///   without. Ties and unseasoned-majority both fall here, since
///   seasonal grouping would leave most episodes unassigned.
///
/// Returns true only when both conditions are false — see tests for
/// the exact boundary behavior.
bool hasReliableSeasonNumbers(Iterable<Episode> episodes) {
  var withSeason = 0;
  var withoutSeason = 0;
  var hasMultiSeason = false;
  for (final episode in episodes) {
    final season = episode.seasonNumber;
    if (season == null) {
      withoutSeason++;
      continue;
    }
    withSeason++;
    if (1 < season) hasMultiSeason = true;
  }
  if (!hasMultiSeason) return false;
  return withoutSeason < withSeason;
}

/// Resolver that groups episodes by the RSS seasonNumber field.
class SeasonNumberResolver implements SmartPlaylistResolver {
  SeasonNumberResolver({Logger? logger}) : _logger = logger;

  final Logger? _logger;

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
    // Auto-detect mode: skip when `seasonNumber` metadata looks broken.
    // With an explicit definition, the smart-playlist config author
    // opted in to seasonNumber grouping, so respect that and always
    // resolve.
    if (definition == null && !hasReliableSeasonNumbers(episodes)) {
      _logger?.d(
        'SeasonNumberResolver skipped in auto-detect: '
        'unreliable seasonNumber metadata '
        '(episodeCount=${episodes.length})',
      );
      return null;
    }
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
