import 'package:logger/logger.dart';

import '../models/episode.dart';
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
    Logger? logger,
  }) : _resolvers = resolvers,
       _patterns = patterns,
       _logger = logger;

  final List<SmartPlaylistResolver> _resolvers;
  final List<SmartPlaylistPatternConfig> _patterns;
  final Logger? _logger;

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
    _logger?.d(
      'Resolving ${sorted.length} definitions, '
      'available resolvers: ${_resolvers.map((r) => r.type).toList()}',
    );

    for (final definition in sorted) {
      final filtered = _filterEpisodes(episodes, definition, claimedIds);
      _logger?.d(
        'Definition "${definition.id}" '
        'resolverType=${definition.grouping.by}, '
        'filtered=${filtered.length}/${episodes.length} episodes',
      );
      if (filtered.isEmpty) continue;

      final resolver = _findResolverByType(definition.grouping.by);
      if (resolver == null) {
        _logger?.w('No resolver found for type "${definition.grouping.by}"');
        continue;
      }

      final result = resolver.resolve(filtered, definition);
      if (result == null) {
        _logger?.d(
          'Resolver "${definition.grouping.by}" returned null '
          'for "${definition.id}"',
        );
        continue;
      }
      _logger?.d(
        'Resolver "${definition.grouping.by}" produced '
        '${result.playlists.length} playlists, '
        '${result.ungroupedEpisodeIds.length} ungrouped',
      );

      resolverType ??= result.resolverType;

      final yearBinding =
          definition.groupListing?.yearBinding ?? YearBinding.none;

      // When isSeparate is false, the resolver's playlists
      // become groups inside a single parent playlist named after
      // the definition.
      if (!definition.isSeparate) {
        final groupDefMap = {
          for (final g
              in definition.grouping.staticClassifiers ??
                  <SmartPlaylistGroupDef>[])
            g.id: g,
        };
        final defEpisodeSort = definition.episodeListing?.sort;
        final groups = result.playlists.map((p) {
          final gDef = groupDefMap[p.id];
          return SmartPlaylistGroup(
            id: p.id,
            displayName: p.displayName,
            sortKey: p.sortKey,
            episodeIds: p.episodeIds,
            thumbnailUrl: p.thumbnailUrl,
            yearOverride:
                gDef?.groupListing?.yearBinding ??
                (gDef?.groupItem?.pinToYear == true
                    ? YearBinding.pinToYear
                    : null),
            showDateRange:
                gDef?.groupItem?.showDateRange ??
                definition.groupItem?.showDateRange ??
                false,
            showYearHeaders: gDef?.episodeListing?.showYearHeaders,
            episodeSort: gDef?.episodeListing?.sort ?? defEpisodeSort,
          );
        }).toList();
        final allEpisodeIds = groups.expand((g) => g.episodeIds).toList();

        allPlaylists.add(
          SmartPlaylist(
            id: definition.id,
            displayName: definition.displayName,
            sortKey: allPlaylists.length,
            episodeIds: allEpisodeIds,
            isSeparate: definition.isSeparate,
            yearBinding: yearBinding,
            showDateRange: definition.groupItem?.showDateRange ?? false,
            showYearHeaders:
                definition.episodeListing?.showYearHeaders ?? false,
            userSortable: definition.groupListing?.userSortable ?? true,
            prependSeasonNumber:
                definition.groupItem?.prependSeasonNumber ?? false,
            groupSort: definition.groupListing?.sort,
            episodeSort: defEpisodeSort,
            groups: groups,
          ),
        );
      } else {
        // Episodes mode: each resolver playlist is a top-level
        // smart playlist.
        final decorated = result.playlists.map((playlist) {
          return playlist.copyWith(
            isSeparate: definition.isSeparate,
            yearBinding: yearBinding,
            showDateRange: definition.groupItem?.showDateRange ?? false,
            showYearHeaders:
                definition.episodeListing?.showYearHeaders ?? false,
            userSortable: definition.groupListing?.userSortable ?? true,
            prependSeasonNumber:
                definition.groupItem?.prependSeasonNumber ?? false,
            groupSort: definition.groupListing?.sort,
            episodeSort: definition.episodeListing?.sort,
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

  /// Sorts definitions so filtered definitions process before fallbacks,
  /// with priority-based ordering within each group.
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
