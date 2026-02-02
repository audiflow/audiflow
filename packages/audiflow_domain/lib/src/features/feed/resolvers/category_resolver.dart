import '../../../common/database/app_database.dart';
import '../models/smart_playlist.dart';
import '../models/smart_playlist_definition.dart';
import '../models/smart_playlist_group_def.dart';
import '../models/smart_playlist_sort.dart';
import 'smart_playlist_resolver.dart';

/// Resolver that groups episodes into predefined categories
/// by title pattern.
///
/// Reads group definitions from the definition's [groups] field.
/// Each group has a regex pattern, display name, and sort key.
/// Episodes are matched against groups in order (first match wins).
/// Groups without a pattern act as catch-all fallbacks.
class CategoryResolver implements SmartPlaylistResolver {
  @override
  String get type => 'category';

  @override
  SmartPlaylistSortSpec get defaultSort => const SimpleSmartPlaylistSort(
    SmartPlaylistSortField.playlistNumber,
    SortOrder.ascending,
  );

  @override
  SmartPlaylistGrouping? resolve(
    List<Episode> episodes,
    SmartPlaylistDefinition? definition,
  ) {
    if (definition == null) return null;

    final groupDefs = definition.groups;
    if (groupDefs == null || groupDefs.isEmpty) return null;

    return _resolveWithGroups(episodes, groupDefs);
  }

  SmartPlaylistGrouping? _resolveWithGroups(
    List<Episode> episodes,
    List<SmartPlaylistGroupDef> groupDefs,
  ) {
    // Separate pattern groups from fallback
    final patternGroups = <({RegExp regex, String id, String displayName})>[];
    String? fallbackId;
    String? fallbackDisplayName;

    for (final g in groupDefs) {
      if (g.pattern != null) {
        patternGroups.add((
          regex: RegExp(g.pattern!),
          id: g.id,
          displayName: g.displayName,
        ));
      } else {
        fallbackId = g.id;
        fallbackDisplayName = g.displayName;
      }
    }

    final grouped = <String, List<int>>{};
    final fallbackIds = <int>[];
    final ungrouped = <int>[];

    for (final episode in episodes) {
      var matched = false;
      for (final pg in patternGroups) {
        if (pg.regex.hasMatch(episode.title)) {
          grouped.putIfAbsent(pg.id, () => []).add(episode.id);
          matched = true;
          break;
        }
      }
      if (!matched) {
        if (fallbackId != null) {
          fallbackIds.add(episode.id);
        } else {
          ungrouped.add(episode.id);
        }
      }
    }

    final groups = <SmartPlaylistGroup>[];
    for (final pg in patternGroups) {
      final ids = grouped[pg.id];
      if (ids != null && ids.isNotEmpty) {
        groups.add(
          SmartPlaylistGroup(
            id: pg.id,
            displayName: pg.displayName,
            episodeIds: ids,
          ),
        );
      }
    }

    if (fallbackIds.isNotEmpty) {
      groups.add(
        SmartPlaylistGroup(
          id: fallbackId!,
          displayName: fallbackDisplayName!,
          episodeIds: fallbackIds,
        ),
      );
    }

    if (groups.isEmpty && ungrouped.isEmpty) return null;

    final allEpisodeIds = episodes.map((e) => e.id).toList();

    final playlists = [
      SmartPlaylist(
        id: 'playlist_${type}',
        displayName: 'All',
        sortKey: 0,
        episodeIds: allEpisodeIds,
        groups: groups.isEmpty ? null : groups,
      ),
    ];

    return SmartPlaylistGrouping(
      playlists: playlists,
      ungroupedEpisodeIds: ungrouped,
      resolverType: type,
    );
  }

  static SmartPlaylistContentType parseContentType(String? value) {
    return switch (value) {
      'groups' => SmartPlaylistContentType.groups,
      _ => SmartPlaylistContentType.episodes,
    };
  }

  static YearHeaderMode parseYearHeaderMode(String? value) {
    return switch (value) {
      'firstEpisode' => YearHeaderMode.firstEpisode,
      'perEpisode' => YearHeaderMode.perEpisode,
      _ => YearHeaderMode.none,
    };
  }
}
