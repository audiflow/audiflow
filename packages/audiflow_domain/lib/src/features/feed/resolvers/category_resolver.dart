import '../../../common/database/app_database.dart';
import '../models/smart_playlist.dart';
import '../models/smart_playlist_pattern.dart';
import '../models/smart_playlist_sort.dart';
import 'smart_playlist_resolver.dart';

/// Resolver that groups episodes into predefined categories
/// by title pattern.
///
/// Reads category definitions from the pattern's config. Each
/// category has a regex pattern, display name, sort key, and
/// yearGrouped flag. Episodes are matched against categories
/// in order (first match wins).
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
    SmartPlaylistPattern? pattern,
  ) {
    if (pattern == null) return null;

    final playlistsRaw = pattern.config['playlists'] as List<dynamic>?;
    if (playlistsRaw != null && playlistsRaw.isNotEmpty) {
      return _resolvePlaylists(playlistsRaw, episodes);
    }

    final categoriesRaw = pattern.config['categories'] as List<dynamic>?;
    if (categoriesRaw == null || categoriesRaw.isEmpty) {
      return null;
    }

    final categories = categoriesRaw.cast<Map<String, dynamic>>();

    // Build regex list
    final matchers = categories.map((c) {
      return (
        regex: RegExp(c['pattern'] as String),
        id: c['id'] as String,
        displayName: c['displayName'] as String,
        yearGrouped: c['yearGrouped'] as bool? ?? false,
        sortKey: c['sortKey'] as int,
      );
    }).toList();

    final grouped = <String, List<Episode>>{};
    final ungrouped = <int>[];

    for (final episode in episodes) {
      var matched = false;
      for (final matcher in matchers) {
        if (matcher.regex.hasMatch(episode.title)) {
          grouped.putIfAbsent(matcher.id, () => []).add(episode);
          matched = true;
          break;
        }
      }
      if (!matched) {
        ungrouped.add(episode.id);
      }
    }

    if (grouped.isEmpty) return null;

    final playlists = matchers.where((m) => grouped.containsKey(m.id)).map((m) {
      final categoryEpisodes = grouped[m.id]!;
      final episodeIds = categoryEpisodes.map((e) => e.id).toList();

      // Resolve sub-categories if configured
      final categoryConfig = categories.firstWhere((c) => c['id'] == m.id);
      final subCategoriesConfig =
          categoryConfig['subCategories'] as List<dynamic>?;
      final subCategories = subCategoriesConfig != null
          ? _resolveSubCategories(subCategoriesConfig, categoryEpisodes)
          : null;

      return SmartPlaylist(
        id: 'playlist_${m.id}',
        displayName: m.displayName,
        sortKey: m.sortKey,
        episodeIds: episodeIds,
        yearHeaderMode: m.yearGrouped
            ? YearHeaderMode.firstEpisode
            : YearHeaderMode.none,
        groups: subCategories,
      );
    }).toList();

    return SmartPlaylistGrouping(
      playlists: playlists,
      ungroupedEpisodeIds: ungrouped,
      resolverType: type,
    );
  }

  /// Groups episodes within a category into sub-categories by regex.
  ///
  /// Episodes not matching any sub-category pattern are placed into
  /// an implicit "Other" sub-category at the end.
  List<SmartPlaylistGroup>? _resolveSubCategories(
    List<dynamic> subCategoriesConfig,
    List<Episode> episodes,
  ) {
    final configs = subCategoriesConfig.cast<Map<String, dynamic>>();
    final matchers = configs.map((c) {
      return (
        regex: RegExp(c['pattern'] as String),
        id: c['id'] as String,
        displayName: c['displayName'] as String,
        yearGrouped: c['yearGrouped'] as bool? ?? false,
      );
    }).toList();

    final grouped = <String, List<int>>{};
    final otherIds = <int>[];

    for (final episode in episodes) {
      var matched = false;
      for (final matcher in matchers) {
        if (matcher.regex.hasMatch(episode.title)) {
          grouped.putIfAbsent(matcher.id, () => []).add(episode.id);
          matched = true;
          break;
        }
      }
      if (!matched) {
        otherIds.add(episode.id);
      }
    }

    final result = <SmartPlaylistGroup>[];
    for (final matcher in matchers) {
      final ids = grouped[matcher.id];
      if (ids != null && ids.isNotEmpty) {
        result.add(
          SmartPlaylistGroup(
            id: matcher.id,
            displayName: matcher.displayName,
            episodeIds: ids,
            yearOverride: matcher.yearGrouped
                ? YearHeaderMode.perEpisode
                : null,
          ),
        );
      }
    }

    if (otherIds.isNotEmpty) {
      result.add(
        SmartPlaylistGroup(
          id: 'other',
          displayName: 'Other',
          episodeIds: otherIds,
        ),
      );
    }

    return result.isEmpty ? null : result;
  }

  /// Resolves the `playlists` config path.
  ///
  /// Every playlist receives ALL episodes; groups within
  /// each playlist determine how episodes are categorized.
  SmartPlaylistGrouping? _resolvePlaylists(
    List<dynamic> playlistsRaw,
    List<Episode> episodes,
  ) {
    final configs = playlistsRaw.cast<Map<String, dynamic>>();
    final playlists = <SmartPlaylist>[];
    final ungrouped = <int>{};

    for (var i = 0; i < configs.length; i++) {
      final config = configs[i];
      final groups = _resolvePlaylistGroups(config, episodes, ungrouped);
      final allIds = episodes.map((e) => e.id).toList();

      playlists.add(
        SmartPlaylist(
          id: config['id'] as String,
          displayName: config['displayName'] as String,
          sortKey: i,
          episodeIds: allIds,
          contentType: _parseContentType(config['contentType'] as String?),
          yearHeaderMode: _parseYearHeaderMode(
            config['yearHeaderMode'] as String?,
          ),
          episodeYearHeaders: config['episodeYearHeaders'] as bool? ?? false,
          groups: groups,
        ),
      );
    }

    return SmartPlaylistGrouping(
      playlists: playlists,
      ungroupedEpisodeIds: ungrouped.toList(),
      resolverType: type,
    );
  }

  /// Groups episodes for a single playlist config.
  ///
  /// Episodes not matching any pattern go to the
  /// fallback group (one without `pattern` key).
  /// If no fallback exists, unmatched IDs are added
  /// to [ungroupedOut].
  List<SmartPlaylistGroup>? _resolvePlaylistGroups(
    Map<String, dynamic> playlistConfig,
    List<Episode> episodes,
    Set<int> ungroupedOut,
  ) {
    final groupsRaw = playlistConfig['groups'] as List<dynamic>?;
    if (groupsRaw == null || groupsRaw.isEmpty) {
      for (final e in episodes) {
        ungroupedOut.add(e.id);
      }
      return null;
    }

    final groupConfigs = groupsRaw.cast<Map<String, dynamic>>();

    // Separate pattern groups from fallback
    final patternGroups = <({RegExp regex, String id, String displayName})>[];
    String? fallbackId;
    String? fallbackDisplayName;

    for (final g in groupConfigs) {
      final patternStr = g['pattern'] as String?;
      if (patternStr != null) {
        patternGroups.add((
          regex: RegExp(patternStr),
          id: g['id'] as String,
          displayName: g['displayName'] as String,
        ));
      } else {
        fallbackId = g['id'] as String;
        fallbackDisplayName = g['displayName'] as String;
      }
    }

    final grouped = <String, List<int>>{};
    final fallbackIds = <int>[];

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
          ungroupedOut.add(episode.id);
        }
      }
    }

    final result = <SmartPlaylistGroup>[];
    for (final pg in patternGroups) {
      final ids = grouped[pg.id];
      if (ids != null && ids.isNotEmpty) {
        result.add(
          SmartPlaylistGroup(
            id: pg.id,
            displayName: pg.displayName,
            episodeIds: ids,
          ),
        );
      }
    }

    if (fallbackIds.isNotEmpty) {
      result.add(
        SmartPlaylistGroup(
          id: fallbackId!,
          displayName: fallbackDisplayName!,
          episodeIds: fallbackIds,
        ),
      );
    }

    return result.isEmpty ? null : result;
  }

  static SmartPlaylistContentType _parseContentType(String? value) {
    return switch (value) {
      'groups' => SmartPlaylistContentType.groups,
      _ => SmartPlaylistContentType.episodes,
    };
  }

  static YearHeaderMode _parseYearHeaderMode(String? value) {
    return switch (value) {
      'firstEpisode' => YearHeaderMode.firstEpisode,
      'perEpisode' => YearHeaderMode.perEpisode,
      _ => YearHeaderMode.none,
    };
  }
}
