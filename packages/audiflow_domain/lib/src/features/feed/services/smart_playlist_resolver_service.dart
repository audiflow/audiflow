import '../../../common/database/app_database.dart';
import '../models/smart_playlist.dart';
import '../models/smart_playlist_definition.dart';
import '../models/smart_playlist_pattern_config.dart';
import '../resolvers/rss_metadata_resolver.dart';
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

    // Sort definitions by priority (higher first)
    final sorted = List.of(config.playlists)
      ..sort((a, b) => b.priority.compareTo(a.priority));

    for (final definition in sorted) {
      final filtered = _filterEpisodes(episodes, definition, claimedIds);
      if (filtered.isEmpty) continue;

      final resolver = _findResolverByType(definition.resolverType);
      if (resolver == null) continue;

      final result = resolver.resolve(filtered, definition);
      if (result == null) continue;

      resolverType ??= result.resolverType;

      // Apply display config from definition
      final decorated = result.playlists.map((playlist) {
        return playlist.copyWith(
          contentType: RssMetadataResolver.parseContentType(
            definition.contentType,
          ),
          yearHeaderMode: RssMetadataResolver.parseYearHeaderMode(
            definition.yearHeaderMode,
          ),
          episodeYearHeaders: definition.episodeYearHeaders,
        );
      }).toList();

      allPlaylists.addAll(decorated);
      allUngroupedIds.addAll(result.ungroupedEpisodeIds);

      // Track claimed episode IDs
      for (final p in result.playlists) {
        claimedIds.addAll(p.episodeIds);
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
  /// Episodes already claimed by a higher-priority definition
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

    final hasTitleFilter = definition.titleFilter != null;
    final hasExcludeFilter = definition.excludeFilter != null;
    final hasRequireFilter = definition.requireFilter != null;

    // No filters means fallback: gets all unclaimed episodes
    if (!hasTitleFilter && !hasExcludeFilter && !hasRequireFilter) {
      return unclaimed;
    }

    final titleRegex = hasTitleFilter ? RegExp(definition.titleFilter!) : null;
    final excludeRegex = hasExcludeFilter
        ? RegExp(definition.excludeFilter!)
        : null;
    final requireRegex = hasRequireFilter
        ? RegExp(definition.requireFilter!)
        : null;

    return unclaimed.where((episode) {
      final title = episode.title;
      if (titleRegex != null && !titleRegex.hasMatch(title)) {
        return false;
      }
      if (excludeRegex != null && excludeRegex.hasMatch(title)) {
        return false;
      }
      if (requireRegex != null && !requireRegex.hasMatch(title)) {
        return false;
      }
      return true;
    }).toList();
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
}
