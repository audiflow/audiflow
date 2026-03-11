import '../../../common/database/app_database.dart';
import '../models/smart_playlist.dart';
import '../models/smart_playlist_definition.dart';
import '../models/smart_playlist_group_def.dart';
import '../models/smart_playlist_pattern_config.dart';
import '../resolvers/smart_playlist_resolver.dart';

/// Service that orchestrates the smart playlist resolver chain.
///
/// When a [SmartPlaylistPatternConfig] matches the podcast, its
/// playlist definitions are used to route episodes through the
/// appropriate resolvers. Otherwise, resolvers are tried in order
/// with no definition (auto-detect mode).
class SmartPlaylistResolverService {
  SmartPlaylistResolverService({
    required List<SmartPlaylistResolver> resolvers,
    required List<SmartPlaylistPatternConfig> patterns,
  }) : _resolvers = resolvers,
       _patterns = patterns;

  final List<SmartPlaylistResolver> _resolvers;
  final List<SmartPlaylistPatternConfig> _patterns;

  /// Attempts to group episodes into smart playlists.
  ///
  /// Returns null if no resolver succeeds.
  SmartPlaylistGrouping? resolveSmartPlaylists({
    required String? podcastGuid,
    required String feedUrl,
    required List<Episode> episodes,
  }) {
    if (episodes.isEmpty) return null;

    final config = _findMatchingConfig(podcastGuid, feedUrl);
    if (config != null) {
      return _resolveWithConfig(config, episodes);
    }

    // Fallback: try resolvers in order with no definition
    for (final resolver in _resolvers) {
      final result = resolver.resolve(episodes, null);
      if (result != null) return result;
    }

    return null;
  }

  /// Resolves playlists using a matched pattern config.
  SmartPlaylistGrouping? _resolveWithConfig(
    SmartPlaylistPatternConfig config,
    List<Episode> episodes,
  ) {
    final allPlaylists = <SmartPlaylist>[];
    final allUngroupedIds = <int>{};
    final claimedIds = <int>{};
    String? resolverType;

    final sorted = _sortByProcessingOrder(config.playlists);

    for (final definition in sorted) {
      final filtered = _filterEpisodes(episodes, definition, claimedIds);
      if (filtered.isEmpty) continue;

      final resolver = _findResolverByType(definition.resolverType);
      if (resolver == null) continue;

      final result = resolver.resolve(filtered, definition);
      if (result == null) continue;

      resolverType ??= result.resolverType;

      final playlistStructure = PlaylistStructure.fromString(
        definition.playlistStructure,
      );
      final yearBinding = definition.groupList?.yearBinding ?? YearBinding.none;

      // When playlistStructure is "grouped", the resolver's playlists
      // become groups inside a single parent playlist named after
      // the definition.
      if (playlistStructure == PlaylistStructure.grouped) {
        final groupDefMap = {
          for (final g in definition.groups ?? <SmartPlaylistGroupDef>[])
            g.id: g,
        };
        final groups = result.playlists.map((p) {
          final gDef = groupDefMap[p.id];
          return SmartPlaylistGroup(
            id: p.id,
            displayName: p.displayName,
            sortKey: p.sortKey,
            episodeIds: p.episodeIds,
            thumbnailUrl: p.thumbnailUrl,
            showDateRange:
                gDef?.display?.showDateRange ??
                definition.groupList?.showDateRange ??
                false,
          );
        }).toList();
        final allEpisodeIds = groups.expand((g) => g.episodeIds).toList();

        allPlaylists.add(
          SmartPlaylist(
            id: definition.id,
            displayName: definition.displayName,
            sortKey: allPlaylists.length,
            episodeIds: allEpisodeIds,
            playlistStructure: playlistStructure,
            yearBinding: yearBinding,
            showDateRange: definition.groupList?.showDateRange ?? false,
            userSortable: definition.groupList?.userSortable ?? true,
            prependSeasonNumber: definition.prependSeasonNumber,
            groupSort: definition.groupList?.sort,
            groups: groups,
          ),
        );
      } else {
        // Episodes mode: each resolver playlist is a top-level
        // smart playlist.
        final decorated = result.playlists.map((playlist) {
          return playlist.copyWith(
            playlistStructure: playlistStructure,
            yearBinding: yearBinding,
            showDateRange: definition.groupList?.showDateRange ?? false,
            userSortable: definition.groupList?.userSortable ?? true,
            prependSeasonNumber: definition.prependSeasonNumber,
            groupSort: definition.groupList?.sort,
          );
        }).toList();
        allPlaylists.addAll(decorated);
      }

      allUngroupedIds.addAll(result.ungroupedEpisodeIds);

      if (_hasFilters(definition)) {
        for (final p in result.playlists) {
          claimedIds.addAll(p.episodeIds);
        }
      }
    }

    if (allPlaylists.isEmpty) return null;

    // Remove from ungrouped any IDs that ended up in a playlist
    allUngroupedIds.removeAll(claimedIds);

    return SmartPlaylistGrouping(
      playlists: allPlaylists,
      ungroupedEpisodeIds: allUngroupedIds.toList(),
      resolverType: resolverType ?? 'config',
    );
  }

  /// Filters episodes based on definition routing rules.
  ///
  /// Episodes already claimed by a lower-priority-number definition
  /// are excluded. A definition with no filters acts as a
  /// fallback, receiving all unclaimed episodes.
  List<Episode> _filterEpisodes(
    List<Episode> episodes,
    SmartPlaylistDefinition definition,
    Set<int> claimedIds,
  ) {
    final unclaimed = episodes
        .where((e) => !claimedIds.contains(e.id))
        .toList();

    final filters = definition.episodeFilters;
    if (filters == null || !filters.hasFilters) {
      return unclaimed;
    }

    // Pre-compile regexes once, outside the per-episode loop.
    final requireRegexes = filters.require
        ?.map(
          (e) => (
            title: e.title != null
                ? RegExp(e.title!, caseSensitive: false)
                : null,
            description: e.description != null
                ? RegExp(e.description!, caseSensitive: false)
                : null,
          ),
        )
        .toList();
    final excludeRegexes = filters.exclude
        ?.map(
          (e) => (
            title: e.title != null
                ? RegExp(e.title!, caseSensitive: false)
                : null,
            description: e.description != null
                ? RegExp(e.description!, caseSensitive: false)
                : null,
          ),
        )
        .toList();

    return unclaimed.where((episode) {
      final title = episode.title;
      final description = episode.description;

      // Require: OR across entries, AND within entry.
      if (requireRegexes != null && requireRegexes.isNotEmpty) {
        final matchesAny = requireRegexes.any(
          (r) => _entryMatches(r, title, description),
        );
        if (!matchesAny) return false;
      }

      // Exclude: OR across entries, AND within entry.
      if (excludeRegexes != null) {
        for (final r in excludeRegexes) {
          if (_entryMatches(r, title, description)) return false;
        }
      }

      return true;
    }).toList();
  }

  /// Checks if all specified fields in a filter entry match (AND within entry).
  bool _entryMatches(
    ({RegExp? title, RegExp? description}) r,
    String title,
    String? description,
  ) {
    if (r.title != null && !r.title!.hasMatch(title)) return false;
    if (r.description != null) {
      if (description == null || !r.description!.hasMatch(description)) {
        return false;
      }
    }
    return true;
  }

  SmartPlaylistPatternConfig? _findMatchingConfig(
    String? guid,
    String feedUrl,
  ) {
    for (final config in _patterns) {
      if (config.matchesPodcast(guid, feedUrl)) {
        return config;
      }
    }
    return null;
  }

  SmartPlaylistResolver? _findResolverByType(String type) {
    for (final resolver in _resolvers) {
      if (resolver.type == type) {
        return resolver;
      }
    }
    return null;
  }

  /// Sorts definitions so filtered definitions process before fallbacks.
  /// Within each group, sorts by priority ascending (lower number first).
  static List<SmartPlaylistDefinition> _sortByProcessingOrder(
    List<SmartPlaylistDefinition> definitions,
  ) {
    final filtered = <SmartPlaylistDefinition>[];
    final fallbacks = <SmartPlaylistDefinition>[];

    for (final def in definitions) {
      if (_hasFilters(def)) {
        filtered.add(def);
      } else {
        fallbacks.add(def);
      }
    }

    filtered.sort((a, b) => a.priority.compareTo(b.priority));
    fallbacks.sort((a, b) => a.priority.compareTo(b.priority));

    return [...filtered, ...fallbacks];
  }

  static bool _hasFilters(SmartPlaylistDefinition definition) {
    return definition.episodeFilters?.hasFilters ?? false;
  }
}
