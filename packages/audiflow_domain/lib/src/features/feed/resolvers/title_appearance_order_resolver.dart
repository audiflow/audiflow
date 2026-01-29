import '../../../common/database/app_database.dart';
import '../extensions/episode_extensions.dart';
import '../models/smart_playlist.dart';
import '../models/smart_playlist_pattern.dart';
import '../models/smart_playlist_sort.dart';
import '../models/smart_playlist_title_extractor.dart';
import 'smart_playlist_resolver.dart';

/// Resolver that groups by title pattern with playlist order by
/// first appearance.
///
/// Useful for podcasts like:
/// - [Rome 1] First Steps
/// - [Rome 2] The Colosseum
/// - [Venezia 1] Arrival
///
/// Where "Rome" becomes playlist 1 (appeared first), "Venezia"
/// becomes playlist 2.
///
/// When a titleExtractor is provided in the pattern, it uses that
/// to extract playlist names. Otherwise, falls back to the
/// 'pattern' config with capture group 1.
class TitleAppearanceOrderResolver implements SmartPlaylistResolver {
  @override
  String get type => 'title_appearance';

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
    if (pattern == null) return null;

    final titleExtractor = pattern.titleExtractor;
    final patternStr = pattern.config['pattern'] as String?;

    // Need either a titleExtractor or a pattern config
    if (titleExtractor == null && patternStr == null) {
      return null;
    }

    // Sort episodes by publish date (oldest first) to determine
    // appearance order
    final sorted = episodes.where((e) => e.publishedAt != null).toList()
      ..sort((a, b) => a.publishedAt!.compareTo(b.publishedAt!));

    final playlistOrder = <String>[];
    final grouped = <String, List<Episode>>{};
    final ungrouped = <int>[];

    // Also process episodes without publish date at the end
    final allEpisodes = [
      ...sorted,
      ...episodes.where((e) => e.publishedAt == null),
    ];

    for (final episode in allEpisodes) {
      final playlistName = _extractPlaylistName(
        episode: episode,
        titleExtractor: titleExtractor,
        patternStr: patternStr,
      );

      if (playlistName != null) {
        if (!playlistOrder.contains(playlistName)) {
          playlistOrder.add(playlistName);
        }
        grouped.putIfAbsent(playlistName, () => []).add(episode);
      } else {
        ungrouped.add(episode.id);
      }
    }

    // Return null if no matches
    if (grouped.isEmpty) {
      return null;
    }

    final playlists = <SmartPlaylist>[];
    for (var i = 0; i < playlistOrder.length; i++) {
      final name = playlistOrder[i];
      final playlistEpisodes = grouped[name]!;
      playlists.add(
        SmartPlaylist(
          id: 'season_${i + 1}',
          displayName: name,
          sortKey: i + 1,
          episodeIds: playlistEpisodes.map((e) => e.id).toList(),
        ),
      );
    }

    return SmartPlaylistGrouping(
      playlists: playlists,
      ungroupedEpisodeIds: ungrouped,
      resolverType: type,
    );
  }

  String? _extractPlaylistName({
    required Episode episode,
    required SmartPlaylistTitleExtractor? titleExtractor,
    required String? patternStr,
  }) {
    // Try titleExtractor first if available
    if (titleExtractor != null) {
      return titleExtractor.extract(episode.toEpisodeData());
    }

    // Fall back to pattern config
    if (patternStr != null) {
      final regex = RegExp(patternStr);
      final match = regex.firstMatch(episode.title);
      if (match != null && 1 <= match.groupCount) {
        return match.group(1);
      }
    }

    return null;
  }
}
