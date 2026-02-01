import 'package:drift/drift.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../common/database/app_database.dart';
import '../../../common/providers/database_provider.dart';
import '../../../common/providers/logger_provider.dart';
import '../../../features/subscription/repositories/subscription_repository_impl.dart';
import '../../player/models/episode_with_progress.dart';
import '../../player/repositories/playback_history_repository_impl.dart';
import '../datasources/local/smart_playlist_local_datasource.dart';
import '../models/smart_playlist.dart';
import '../models/smart_playlist_pattern.dart';
import '../patterns/coten_radio_pattern.dart';
import '../patterns/news_connect_pattern.dart';
import '../repositories/episode_repository.dart';
import '../repositories/episode_repository_impl.dart';
import '../resolvers/category_resolver.dart';
import '../resolvers/rss_metadata_resolver.dart';
import '../resolvers/year_resolver.dart';
import '../services/smart_playlist_resolver_service.dart';

part 'smart_playlist_providers.g.dart';

/// List of registered smart playlist patterns.
///
/// Add new podcast-specific patterns here.
const _registeredPatterns = [cotenRadioPattern, newsConnectPattern];

/// Provides the smart playlist local datasource for database
/// operations.
@Riverpod(keepAlive: true)
SmartPlaylistLocalDatasource smartPlaylistLocalDatasource(Ref ref) {
  final db = ref.watch(databaseProvider);
  return SmartPlaylistLocalDatasource(db);
}

/// Provides the smart playlist resolver service with built-in
/// resolvers.
///
/// The resolver chain tries RSS metadata first, then falls back to
/// year-based grouping. Custom patterns can be added for specific
/// podcasts.
@Riverpod(keepAlive: true)
SmartPlaylistResolverService smartPlaylistResolverService(Ref ref) {
  return SmartPlaylistResolverService(
    resolvers: [RssMetadataResolver(), CategoryResolver(), YearResolver()],
    patterns: _registeredPatterns,
  );
}

/// Finds the smart playlist pattern that matches a given feed URL.
///
/// Returns null if no pattern matches.
@riverpod
SmartPlaylistPattern? smartPlaylistPatternByFeedUrl(Ref ref, String feedUrl) {
  for (final pattern in _registeredPatterns) {
    if (pattern.matchesPodcast(null, feedUrl)) {
      return pattern;
    }
  }
  return null;
}

/// Resolves smart playlists for a podcast by its ID.
///
/// First checks the database for cached smart playlists. Only
/// resolves from episodes if no cached playlists exist. Returns
/// null if no resolver can group episodes.
@riverpod
Future<SmartPlaylistGrouping?> podcastSmartPlaylists(
  Ref ref,
  int podcastId,
) async {
  final logger = ref.watch(namedLoggerProvider('PodcastSmartPlaylists'));
  final subscriptionRepo = ref.watch(subscriptionRepositoryProvider);
  final episodeRepo = ref.watch(episodeRepositoryProvider);
  final playlistDatasource = ref.watch(smartPlaylistLocalDatasourceProvider);

  final subscription = await subscriptionRepo.getById(podcastId);
  if (subscription == null) {
    logger.d('No subscription found for podcastId=$podcastId');
    return null;
  }

  // Check for cached smart playlists first
  final cachedPlaylists = await playlistDatasource.getByPodcastId(podcastId);
  if (cachedPlaylists.isNotEmpty) {
    logger.d(
      'Using ${cachedPlaylists.length} cached smart playlists '
      'for podcastId=$podcastId',
    );
    return _buildGroupingFromCache(
      ref,
      podcastId,
      cachedPlaylists,
      episodeRepo,
      subscription.feedUrl,
    );
  }

  // No cached smart playlists - resolve from episodes
  return _resolveAndPersistSmartPlaylists(
    ref,
    podcastId,
    subscription.feedUrl,
    logger,
  );
}

/// Builds SmartPlaylistGrouping from cached SmartPlaylistEntity
/// records.
///
/// For patterns with `playlists` config, re-resolves directly from
/// episodes using the resolver (groups are not cached). For
/// category-based resolvers, re-resolves by title pattern. For
/// season-based resolvers, groups by episode.seasonNumber.
Future<SmartPlaylistGrouping?> _buildGroupingFromCache(
  Ref ref,
  int podcastId,
  List<SmartPlaylistEntity> cachedPlaylists,
  EpisodeRepository episodeRepo,
  String feedUrl,
) async {
  final pattern = ref.read(smartPlaylistPatternByFeedUrlProvider(feedUrl));

  // Patterns with `playlists` config: re-resolve from episodes
  // since groups are not persisted in cache.
  if (pattern?.config['playlists'] != null) {
    return _reResolveFromEpisodes(ref, podcastId, feedUrl);
  }

  final episodes = await episodeRepo.getByPodcastId(podcastId);
  if (episodes.isEmpty) return null;

  final resolverType = cachedPlaylists.first.resolverType;

  // Category-based resolvers need to re-resolve by title pattern
  if (resolverType == 'category' && pattern != null) {
    return _buildCategoryGroupingFromCache(episodes, cachedPlaylists, pattern);
  }

  // Season-number-based grouping
  final groupNullAs = pattern?.config['groupNullSeasonAs'] as int?;
  final episodesByPlaylistNum = <int, List<int>>{};
  final ungroupedIds = <int>[];

  for (final episode in episodes) {
    final seasonNum = episode.seasonNumber;
    if (seasonNum != null && 1 <= seasonNum) {
      episodesByPlaylistNum.putIfAbsent(seasonNum, () => []).add(episode.id);
    } else if (groupNullAs != null) {
      episodesByPlaylistNum.putIfAbsent(groupNullAs, () => []).add(episode.id);
    } else {
      ungroupedIds.add(episode.id);
    }
  }

  final playlists = cachedPlaylists.map((entity) {
    final episodeIds = episodesByPlaylistNum[entity.playlistNumber] ?? [];
    return SmartPlaylist(
      id: 'season_${entity.playlistNumber}',
      displayName: entity.displayName,
      sortKey: entity.sortKey,
      episodeIds: episodeIds,
      thumbnailUrl: entity.thumbnailUrl,
      yearHeaderMode: entity.yearGrouped
          ? YearHeaderMode.firstEpisode
          : YearHeaderMode.none,
    );
  }).toList();

  return SmartPlaylistGrouping(
    playlists: playlists,
    ungroupedEpisodeIds: ungroupedIds,
    resolverType: resolverType,
  );
}

/// Builds grouping for category-based resolvers by re-running
/// title pattern matching against episodes.
SmartPlaylistGrouping? _buildCategoryGroupingFromCache(
  List<Episode> episodes,
  List<SmartPlaylistEntity> cachedPlaylists,
  SmartPlaylistPattern pattern,
) {
  final categoriesRaw = pattern.config['categories'] as List<dynamic>?;
  if (categoriesRaw == null || categoriesRaw.isEmpty) return null;

  final categories = categoriesRaw.cast<Map<String, dynamic>>();
  final matchers = categories.map((c) {
    return (
      regex: RegExp(c['pattern'] as String),
      id: c['id'] as String,
      sortKey: c['sortKey'] as int,
    );
  }).toList();

  // Match episodes to categories by title
  final episodeIdsByCategory = <String, List<int>>{};
  final ungroupedIds = <int>[];

  for (final episode in episodes) {
    var matched = false;
    for (final matcher in matchers) {
      if (matcher.regex.hasMatch(episode.title)) {
        episodeIdsByCategory.putIfAbsent(matcher.id, () => []).add(episode.id);
        matched = true;
        break;
      }
    }
    if (!matched) {
      ungroupedIds.add(episode.id);
    }
  }

  // Map cached entities to category IDs via sortKey
  final entityBySortKey = <int, SmartPlaylistEntity>{};
  for (final entity in cachedPlaylists) {
    entityBySortKey[entity.sortKey] = entity;
  }

  // Build episode lookup by ID for sub-category resolution
  final episodeById = <int, Episode>{};
  for (final episode in episodes) {
    episodeById[episode.id] = episode;
  }

  final playlists = <SmartPlaylist>[];
  for (final matcher in matchers) {
    final entity = entityBySortKey[matcher.sortKey];
    if (entity == null) continue;
    final ids = episodeIdsByCategory[matcher.id] ?? [];

    // Resolve sub-categories from pattern config
    final categoryConfig = categories.firstWhere((c) => c['id'] == matcher.id);
    final subCategoriesConfig =
        categoryConfig['subCategories'] as List<dynamic>?;
    List<SmartPlaylistGroup>? groups;
    if (subCategoriesConfig != null) {
      final categoryEpisodes = ids
          .map((id) => episodeById[id])
          .nonNulls
          .toList();
      groups = _resolveGroupsFromConfig(subCategoriesConfig, categoryEpisodes);
    }

    playlists.add(
      SmartPlaylist(
        id: 'playlist_${matcher.id}',
        displayName: entity.displayName,
        sortKey: entity.sortKey,
        episodeIds: ids,
        thumbnailUrl: entity.thumbnailUrl,
        yearHeaderMode: entity.yearGrouped
            ? YearHeaderMode.firstEpisode
            : YearHeaderMode.none,
        groups: groups,
      ),
    );
  }

  return SmartPlaylistGrouping(
    playlists: playlists,
    ungroupedEpisodeIds: ungroupedIds,
    resolverType: cachedPlaylists.first.resolverType,
  );
}

/// Resolves smart playlists from episodes and persists to database.
Future<SmartPlaylistGrouping?> _resolveAndPersistSmartPlaylists(
  Ref ref,
  int podcastId,
  String feedUrl,
  dynamic logger,
) async {
  final episodeRepo = ref.watch(episodeRepositoryProvider);
  final playlistDatasource = ref.watch(smartPlaylistLocalDatasourceProvider);
  final resolverService = ref.watch(smartPlaylistResolverServiceProvider);

  final episodes = await episodeRepo.getByPodcastId(podcastId);
  if (episodes.isEmpty) {
    logger.d('No episodes found for podcastId=$podcastId');
    return null;
  }

  // Debug: count episodes with season numbers
  final withSeason = episodes.where((e) => e.seasonNumber != null).length;
  logger.d(
    'Resolving smart playlists: podcastId=$podcastId, '
    'feedUrl=$feedUrl, '
    'episodes=${episodes.length}, '
    'withSeasonNumber=$withSeason',
  );

  final result = resolverService.resolveSmartPlaylists(
    podcastGuid: null,
    feedUrl: feedUrl,
    episodes: episodes,
  );

  logger.d(
    'Smart playlist resolution result: '
    '${result?.playlists.length ?? 0} playlists, '
    '${result?.ungroupedEpisodeIds.length ?? 0} ungrouped',
  );

  if (result == null) return null;

  // Find the latest episode thumbnail for each smart playlist
  final enrichedPlaylists = <SmartPlaylist>[];
  final companions = <SmartPlaylistsCompanion>[];

  for (final playlist in result.playlists) {
    // Get episodes for this playlist, sorted by publishedAt
    // (newest first)
    final playlistEpisodes =
        episodes.where((e) => playlist.episodeIds.contains(e.id)).toList()
          ..sort((a, b) {
            final aPub = a.publishedAt;
            final bPub = b.publishedAt;
            if (aPub == null && bPub == null) return 0;
            if (aPub == null) return 1;
            if (bPub == null) return -1;
            return bPub.compareTo(aPub); // Newest first
          });

    // Get thumbnail from latest episode (first in sorted list)
    String? thumbnailUrl;
    for (final ep in playlistEpisodes) {
      if (ep.imageUrl != null) {
        thumbnailUrl = ep.imageUrl;
        break;
      }
    }

    enrichedPlaylists.add(playlist.copyWith(thumbnailUrl: thumbnailUrl));
    companions.add(
      SmartPlaylistsCompanion.insert(
        podcastId: podcastId,
        playlistNumber: playlist.sortKey,
        displayName: playlist.displayName,
        sortKey: playlist.sortKey,
        resolverType: result.resolverType,
        thumbnailUrl: Value(thumbnailUrl),
        yearGrouped: Value(playlist.yearHeaderMode != YearHeaderMode.none),
      ),
    );
  }

  await playlistDatasource.upsertAllForPodcast(podcastId, companions);
  logger.d('Persisted ${companions.length} smart playlists to database');

  return SmartPlaylistGrouping(
    playlists: enrichedPlaylists,
    ungroupedEpisodeIds: result.ungroupedEpisodeIds,
    resolverType: result.resolverType,
  );
}

/// Whether the smart playlist view toggle should be visible for a
/// podcast.
@riverpod
Future<bool> hasSmartPlaylistView(Ref ref, int podcastId) async {
  final grouping = await ref.watch(
    podcastSmartPlaylistsProvider(podcastId).future,
  );
  return grouping != null;
}

/// Whether the smart playlist view toggle should be visible for a
/// podcast by feed URL.
///
/// Looks up the subscription by feedUrl and delegates to
/// [hasSmartPlaylistView]. Returns false if the podcast is not
/// subscribed.
@riverpod
Future<bool> hasSmartPlaylistViewByFeedUrl(Ref ref, String feedUrl) async {
  final subscriptionRepo = ref.watch(subscriptionRepositoryProvider);
  final subscription = await subscriptionRepo.getByFeedUrl(feedUrl);
  if (subscription == null) return false;

  return ref.watch(hasSmartPlaylistViewProvider(subscription.id).future);
}

/// Provides the smart playlist grouping for a podcast by feed URL.
///
/// Looks up the subscription by feedUrl and returns the
/// [SmartPlaylistGrouping] if episodes can be grouped into smart
/// playlists. Returns null if the podcast is not subscribed or if
/// no resolver can group the episodes.
@riverpod
Future<SmartPlaylistGrouping?> podcastSmartPlaylistsByFeedUrl(
  Ref ref,
  String feedUrl,
) async {
  final subscriptionRepo = ref.watch(subscriptionRepositoryProvider);
  final subscription = await subscriptionRepo.getByFeedUrl(feedUrl);
  if (subscription == null) return null;

  return ref.watch(podcastSmartPlaylistsProvider(subscription.id).future);
}

/// Data class containing an episode with its progress information.
class SmartPlaylistEpisodeData {
  const SmartPlaylistEpisodeData({
    required this.episode,
    this.progress,
    this.siblingEpisodeIds,
  });

  final Episode episode;
  final EpisodeWithProgress? progress;

  /// Episode IDs in the same group for adhoc queue building.
  /// Set by the screen when episodes are displayed in a sub-category.
  final List<int>? siblingEpisodeIds;

  /// Creates a copy with the given [siblingEpisodeIds].
  SmartPlaylistEpisodeData withSiblingEpisodeIds(List<int> ids) =>
      SmartPlaylistEpisodeData(
        episode: episode,
        progress: progress,
        siblingEpisodeIds: ids,
      );
}

/// Fetches episodes for a smart playlist by their IDs with
/// progress data.
///
/// Episodes are sorted by episode number (ascending) with fallback
/// to publish date (newest first).
@riverpod
Future<List<SmartPlaylistEpisodeData>> smartPlaylistEpisodes(
  Ref ref,
  List<int> episodeIds,
) async {
  if (episodeIds.isEmpty) return [];

  final episodeRepo = ref.watch(episodeRepositoryProvider);
  final historyRepo = ref.watch(playbackHistoryRepositoryProvider);

  // Fetch episodes
  final episodes = await episodeRepo.getByIds(episodeIds);
  if (episodes.isEmpty) return [];

  // Batch fetch all histories for these episodes
  final historyMap = <int, PlaybackHistory>{};
  for (final episode in episodes) {
    final history = await historyRepo.getByEpisodeId(episode.id);
    if (history != null) {
      historyMap[episode.id] = history;
    }
  }

  // Build result with progress data
  final result = episodes.map((episode) {
    final history = historyMap[episode.id];
    return SmartPlaylistEpisodeData(
      episode: episode,
      progress: EpisodeWithProgress(episode: episode, history: history),
    );
  }).toList();

  // Sort: episode number ascending (if available), fallback to
  // publish date
  result.sort((a, b) {
    final aNum = a.episode.episodeNumber;
    final bNum = b.episode.episodeNumber;

    // Both have episode numbers: sort ascending
    if (aNum != null && bNum != null) {
      return aNum.compareTo(bNum);
    }

    // One has episode number, prioritize it
    if (aNum != null) return -1;
    if (bNum != null) return 1;

    // Neither has episode number: sort by publish date
    // (newest first)
    final aPub = a.episode.publishedAt;
    final bPub = b.episode.publishedAt;
    if (aPub != null && bPub != null) {
      return bPub.compareTo(aPub);
    }

    // Fallback: one or both missing dates
    if (aPub != null) return -1;
    if (bPub != null) return 1;
    return 0;
  });

  return result;
}

/// Re-resolves smart playlists from episodes using the resolver
/// service, enriches with thumbnails, but does not persist (data
/// is already cached).
Future<SmartPlaylistGrouping?> _reResolveFromEpisodes(
  Ref ref,
  int podcastId,
  String feedUrl,
) async {
  final episodeRepo = ref.watch(episodeRepositoryProvider);
  final resolverService = ref.watch(smartPlaylistResolverServiceProvider);

  final episodes = await episodeRepo.getByPodcastId(podcastId);
  if (episodes.isEmpty) return null;

  final result = resolverService.resolveSmartPlaylists(
    podcastGuid: null,
    feedUrl: feedUrl,
    episodes: episodes,
  );
  if (result == null) return null;

  // Enrich playlists with thumbnail from latest episode
  final enriched = result.playlists.map((playlist) {
    final playlistEpisodes =
        episodes.where((e) => playlist.episodeIds.contains(e.id)).toList()
          ..sort((a, b) {
            final aPub = a.publishedAt;
            final bPub = b.publishedAt;
            if (aPub == null && bPub == null) return 0;
            if (aPub == null) return 1;
            if (bPub == null) return -1;
            return bPub.compareTo(aPub);
          });

    String? thumbnailUrl;
    for (final ep in playlistEpisodes) {
      if (ep.imageUrl != null) {
        thumbnailUrl = ep.imageUrl;
        break;
      }
    }

    return playlist.copyWith(thumbnailUrl: thumbnailUrl);
  }).toList();

  return SmartPlaylistGrouping(
    playlists: enriched,
    ungroupedEpisodeIds: result.ungroupedEpisodeIds,
    resolverType: result.resolverType,
  );
}

/// Resolves groups from pattern config for cached rebuilds.
///
/// Supports both old `subCategories` format (all entries have
/// `pattern`) and new `groups` format (entries without `pattern`
/// act as fallback groups).
List<SmartPlaylistGroup>? _resolveGroupsFromConfig(
  List<dynamic> groupsConfig,
  List<Episode> episodes,
) {
  final configs = groupsConfig.cast<Map<String, dynamic>>();

  // Separate pattern-based and fallback groups
  final patternMatchers =
      <
        ({
          RegExp regex,
          String id,
          String displayName,
          YearHeaderMode? yearOverride,
        })
      >[];
  String? fallbackId;
  String? fallbackDisplayName;

  for (final c in configs) {
    final patternStr = c['pattern'] as String?;
    if (patternStr != null) {
      final yearGrouped = c['yearGrouped'] as bool? ?? false;
      final yearOverrideStr = c['yearOverride'] as String?;
      patternMatchers.add((
        regex: RegExp(patternStr),
        id: c['id'] as String,
        displayName: c['displayName'] as String,
        yearOverride: yearOverrideStr != null
            ? _parseYearOverride(yearOverrideStr)
            : (yearGrouped ? YearHeaderMode.perEpisode : null),
      ));
    } else {
      fallbackId = c['id'] as String;
      fallbackDisplayName = c['displayName'] as String;
    }
  }

  final grouped = <String, List<int>>{};
  final fallbackIds = <int>[];

  for (final episode in episodes) {
    var matched = false;
    for (final matcher in patternMatchers) {
      if (matcher.regex.hasMatch(episode.title)) {
        grouped.putIfAbsent(matcher.id, () => []).add(episode.id);
        matched = true;
        break;
      }
    }
    if (!matched) {
      fallbackIds.add(episode.id);
    }
  }

  final result = <SmartPlaylistGroup>[];
  for (final matcher in patternMatchers) {
    final ids = grouped[matcher.id];
    if (ids != null && ids.isNotEmpty) {
      result.add(
        SmartPlaylistGroup(
          id: matcher.id,
          displayName: matcher.displayName,
          episodeIds: ids,
          yearOverride: matcher.yearOverride,
        ),
      );
    }
  }

  if (fallbackIds.isNotEmpty) {
    final id = fallbackId ?? 'other';
    final name = fallbackDisplayName ?? 'Other';
    result.add(
      SmartPlaylistGroup(id: id, displayName: name, episodeIds: fallbackIds),
    );
  }

  return result.isEmpty ? null : result;
}

/// Parses a yearOverride string into [YearHeaderMode].
YearHeaderMode _parseYearOverride(String value) {
  return switch (value) {
    'firstEpisode' => YearHeaderMode.firstEpisode,
    'perEpisode' => YearHeaderMode.perEpisode,
    _ => YearHeaderMode.none,
  };
}
