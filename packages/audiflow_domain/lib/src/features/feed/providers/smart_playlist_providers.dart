import 'package:drift/drift.dart';
import 'package:meta/meta.dart' show visibleForTesting;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../common/database/app_database.dart';
import '../../../common/providers/database_provider.dart';
import '../../../common/providers/http_client_provider.dart';
import '../../../common/providers/logger_provider.dart';
import '../../../common/providers/platform_providers.dart';
import '../../../features/subscription/repositories/subscription_repository_impl.dart';
import '../../player/models/episode_with_progress.dart';
import '../../player/repositories/playback_history_repository_impl.dart';
import '../datasources/local/smart_playlist_cache_datasource.dart';
import '../datasources/local/smart_playlist_local_datasource.dart';
import '../datasources/remote/smart_playlist_remote_datasource.dart';
import '../models/pattern_summary.dart';
import '../models/smart_playlist.dart';
import '../models/smart_playlist_pattern_config.dart';
import '../repositories/episode_repository.dart';
import '../repositories/episode_repository_impl.dart';
import '../repositories/smart_playlist_config_repository.dart';
import '../repositories/smart_playlist_config_repository_impl.dart';
import '../resolvers/category_resolver.dart';
import '../resolvers/rss_metadata_resolver.dart';
import '../resolvers/year_resolver.dart';
import '../services/smart_playlist_resolver_service.dart';

part 'smart_playlist_providers.g.dart';

/// Provides the pattern summaries loaded from remote
/// root meta.json.
///
/// Initially empty; populated on startup after fetching
/// root meta.
@Riverpod(keepAlive: true)
class PatternSummaries extends _$PatternSummaries {
  @override
  List<PatternSummary> build() => [];

  /// Replaces the current summaries.
  void setSummaries(List<PatternSummary> summaries) {
    state = summaries;
  }
}

/// Provides the smart playlist config repository.
///
/// Uses Dio for HTTP and path_provider for cache directory.
@Riverpod(keepAlive: true)
SmartPlaylistConfigRepository smartPlaylistConfigRepository(Ref ref) {
  final dio = ref.watch(dioProvider);
  final baseUrl = ref.watch(smartPlaylistConfigBaseUrlProvider);
  final cacheDir = ref.watch(cacheDirProvider);

  final remote = SmartPlaylistRemoteDatasource(
    baseUrl: baseUrl,
    httpGet: (Uri url) async {
      final response = await dio.getUri<String>(url);
      return response.data!;
    },
  );
  final cache = SmartPlaylistCacheDatasource(cacheDir: cacheDir);

  final repo = SmartPlaylistConfigRepositoryImpl(remote: remote, cache: cache);

  // Seed with current summaries so findMatchingPattern works.
  final summaries = ref.watch(patternSummariesProvider);
  repo.setPatternSummaries(summaries);

  return repo;
}

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
/// Patterns are loaded lazily via repository. The resolver
/// operates in auto-detect mode (empty patterns list).
@Riverpod(keepAlive: true)
SmartPlaylistResolverService smartPlaylistResolverService(Ref ref) {
  return SmartPlaylistResolverService(
    resolvers: [RssMetadataResolver(), CategoryResolver(), YearResolver()],
    patterns: [],
  );
}

/// Finds and loads the smart playlist config for a feed URL.
///
/// Returns null if no pattern matches. Lazily fetches the
/// full config from remote/cache when a match is found.
@riverpod
Future<SmartPlaylistPatternConfig?> smartPlaylistPatternByFeedUrl(
  Ref ref,
  String feedUrl,
) async {
  final repo = ref.watch(smartPlaylistConfigRepositoryProvider);
  final summary = repo.findMatchingPattern(null, feedUrl);
  if (summary == null) return null;
  return repo.getConfig(summary);
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

  // Log matched pattern for this podcast
  final configRepo = ref.watch(smartPlaylistConfigRepositoryProvider);
  final matchedSummary = configRepo.findMatchingPattern(
    null,
    subscription.feedUrl,
  );
  if (matchedSummary != null) {
    logger.d(
      'Matched smart playlist pattern: '
      '"${matchedSummary.displayName}" '
      'dataVersion=${matchedSummary.dataVersion}',
    );
  }

  // Check for cached smart playlists first
  final cachedPlaylists = await playlistDatasource.getByPodcastId(podcastId);
  if (cachedPlaylists.isNotEmpty) {
    logger.d(
      'Using ${cachedPlaylists.length} cached smart '
      'playlists for podcastId=$podcastId',
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
/// When a pattern config matches, re-resolves from episodes
/// using the resolver service (groups are not cached). For
/// season-based resolvers without a config match, groups by
/// episode.seasonNumber.
Future<SmartPlaylistGrouping?> _buildGroupingFromCache(
  Ref ref,
  int podcastId,
  List<SmartPlaylistEntity> cachedPlaylists,
  EpisodeRepository episodeRepo,
  String feedUrl,
) async {
  final config = await ref.read(
    smartPlaylistPatternByFeedUrlProvider(feedUrl).future,
  );

  // Pattern configs always have playlists with resolvers;
  // re-resolve from episodes since groups are not persisted.
  if (config != null) {
    return _reResolveFromEpisodes(ref, podcastId, feedUrl);
  }

  final episodes = await episodeRepo.getByPodcastId(podcastId);
  if (episodes.isEmpty) return null;

  final resolverType = cachedPlaylists.first.resolverType;

  // Season-number-based grouping (generic podcasts)
  final episodesByPlaylistNum = <int, List<int>>{};
  final ungroupedIds = <int>[];

  for (final episode in episodes) {
    final seasonNum = episode.seasonNumber;
    if (seasonNum != null && 1 <= seasonNum) {
      episodesByPlaylistNum.putIfAbsent(seasonNum, () => []).add(episode.id);
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
      yearHeaderMode: RssMetadataResolver.parseYearHeaderMode(
        entity.yearHeaderMode,
      ),
    );
  }).toList();

  return SmartPlaylistGrouping(
    playlists: playlists,
    ungroupedEpisodeIds: ungroupedIds,
    resolverType: resolverType,
  );
}

/// Resolves smart playlists from episodes and persists to
/// database.
Future<SmartPlaylistGrouping?> _resolveAndPersistSmartPlaylists(
  Ref ref,
  int podcastId,
  String feedUrl,
  dynamic logger, {
  String? podcastImageUrl,
}) async {
  final episodeRepo = ref.watch(episodeRepositoryProvider);
  final playlistDatasource = ref.watch(smartPlaylistLocalDatasourceProvider);

  // Load matching config from repository
  final repo = ref.watch(smartPlaylistConfigRepositoryProvider);
  final summary = repo.findMatchingPattern(null, feedUrl);
  SmartPlaylistPatternConfig? config;
  if (summary != null) {
    logger.d(
      'Matched smart playlist pattern: '
      '"${summary.displayName}" dataVersion=${summary.dataVersion}',
    );
    try {
      config = await repo.getConfig(summary);
    } on Object {
      // If remote fetch fails, continue without config
    }
  }

  final resolverService = SmartPlaylistResolverService(
    resolvers: [RssMetadataResolver(), CategoryResolver(), YearResolver()],
    patterns: config != null ? [config] : [],
  );

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
  final podcastImage = podcastImageUrl ?? _findPodcastImageUrl(episodes);

  for (final playlist in result.playlists) {
    _enrichPlaylist(
      playlist,
      episodes,
      result,
      podcastId,
      enrichedPlaylists,
      companions,
      podcastImageUrl: podcastImage,
    );
  }

  await playlistDatasource.upsertAllForPodcast(podcastId, companions);

  // Persist groups with cached metadata
  for (final playlist in enrichedPlaylists) {
    if (playlist.groups != null && playlist.groups!.isNotEmpty) {
      final groupCompanions = playlist.groups!.map((g) {
        return SmartPlaylistGroupsCompanion.insert(
          podcastId: podcastId,
          playlistId: playlist.id,
          groupId: g.id,
          displayName: g.displayName,
          sortKey: g.sortKey,
          thumbnailUrl: Value(g.thumbnailUrl),
          episodeIds: g.episodeIds.join(','),
          yearOverride: Value(g.yearOverride?.name),
          earliestDate: Value(g.earliestDate),
          latestDate: Value(g.latestDate),
          totalDurationMs: Value(g.totalDurationMs),
          episodeYearHeaders: Value(g.episodeYearHeaders),
        );
      }).toList();
      await playlistDatasource.upsertGroupsForPlaylist(
        podcastId,
        playlist.id,
        groupCompanions,
      );
    }
  }

  logger.d(
    'Persisted ${companions.length} smart playlists '
    'to database',
  );

  return SmartPlaylistGrouping(
    playlists: enrichedPlaylists,
    ungroupedEpisodeIds: result.ungroupedEpisodeIds,
    resolverType: result.resolverType,
  );
}

/// Finds the most common imageUrl across all episodes.
///
/// When most episodes share the same imageUrl, it's the
/// podcast-level artwork (not distinct per-season).
String? _findPodcastImageUrl(List<Episode> episodes) {
  final counts = <String, int>{};
  for (final ep in episodes) {
    final url = ep.imageUrl;
    if (url != null) {
      counts[url] = (counts[url] ?? 0) + 1;
    }
  }
  if (counts.isEmpty) return null;

  // Return the most frequent imageUrl
  String? mostCommon;
  var maxCount = 0;
  for (final entry in counts.entries) {
    if (maxCount < entry.value) {
      maxCount = entry.value;
      mostCommon = entry.key;
    }
  }
  return mostCommon;
}

/// Enriches a playlist with thumbnails and builds the
/// companion for database persistence.
void _enrichPlaylist(
  SmartPlaylist playlist,
  List<Episode> episodes,
  SmartPlaylistGrouping result,
  int podcastId,
  List<SmartPlaylist> enrichedPlaylists,
  List<SmartPlaylistsCompanion> companions, {
  String? podcastImageUrl,
}) {
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

  // Enrich groups with thumbnails
  final enrichedGroups = playlist.groups?.map((group) {
    return _enrichGroup(group, episodes, podcastImageUrl: podcastImageUrl);
  }).toList();

  enrichedPlaylists.add(
    playlist.copyWith(thumbnailUrl: thumbnailUrl, groups: enrichedGroups),
  );
  companions.add(
    SmartPlaylistsCompanion.insert(
      podcastId: podcastId,
      playlistNumber: playlist.sortKey,
      displayName: playlist.displayName,
      sortKey: playlist.sortKey,
      resolverType: result.resolverType,
      thumbnailUrl: Value(thumbnailUrl),
      yearGrouped: Value(playlist.yearHeaderMode != YearHeaderMode.none),
      yearHeaderMode: Value(playlist.yearHeaderMode.name),
    ),
  );
}

/// Enriches a group with thumbnail and date/duration metadata.
///
/// When [podcastImageUrl] is provided, group thumbnails that match
/// it are suppressed (set to null) to avoid redundant artwork.
SmartPlaylistGroup _enrichGroup(
  SmartPlaylistGroup group,
  List<Episode> episodes, {
  String? podcastImageUrl,
}) {
  final groupEpisodes =
      episodes.where((e) => group.episodeIds.contains(e.id)).toList()
        ..sort((a, b) {
          final aPub = a.publishedAt;
          final bPub = b.publishedAt;
          if (aPub == null && bPub == null) return 0;
          if (aPub == null) return 1;
          if (bPub == null) return -1;
          return bPub.compareTo(aPub);
        });

  String? groupThumb;
  for (final ep in groupEpisodes) {
    if (ep.imageUrl != null) {
      groupThumb = ep.imageUrl;
      break;
    }
  }

  // Suppress thumbnail if it matches the podcast-level image
  if (groupThumb != null && podcastImageUrl != null) {
    if (groupThumb == podcastImageUrl) {
      groupThumb = null;
    }
  }

  DateTime? earliest;
  DateTime? latest;
  var totalMs = 0;
  var hasDuration = false;
  for (final ep in groupEpisodes) {
    final pub = ep.publishedAt;
    if (pub != null) {
      if (earliest == null || pub.isBefore(earliest)) {
        earliest = pub;
      }
      if (latest == null || pub.isAfter(latest)) {
        latest = pub;
      }
    }
    final dur = ep.durationMs;
    if (dur != null && 0 < dur) {
      totalMs += dur;
      hasDuration = true;
    }
  }

  return SmartPlaylistGroup(
    id: group.id,
    displayName: group.displayName,
    sortKey: group.sortKey,
    episodeIds: group.episodeIds,
    thumbnailUrl: groupThumb,
    episodeYearHeaders: group.episodeYearHeaders,
    showDateRange: group.showDateRange,
    earliestDate: earliest,
    latestDate: latest,
    totalDurationMs: hasDuration ? totalMs : null,
  );
}

/// Whether the smart playlist view toggle should be visible
/// for a podcast.
@riverpod
Future<bool> hasSmartPlaylistView(Ref ref, int podcastId) async {
  final grouping = await ref.watch(
    podcastSmartPlaylistsProvider(podcastId).future,
  );
  return grouping != null;
}

/// Whether the smart playlist view toggle should be visible
/// for a podcast by feed URL.
///
/// Looks up the subscription by feedUrl and delegates to
/// [hasSmartPlaylistView]. Returns false if the podcast is
/// not subscribed.
@riverpod
Future<bool> hasSmartPlaylistViewByFeedUrl(Ref ref, String feedUrl) async {
  final subscriptionRepo = ref.watch(subscriptionRepositoryProvider);
  final subscription = await subscriptionRepo.getByFeedUrl(feedUrl);
  if (subscription == null) return false;

  return ref.watch(hasSmartPlaylistViewProvider(subscription.id).future);
}

/// Provides the smart playlist grouping for a podcast by
/// feed URL.
///
/// Looks up the subscription by feedUrl and returns the
/// [SmartPlaylistGrouping] if episodes can be grouped into
/// smart playlists. Returns null if the podcast is not
/// subscribed or if no resolver can group the episodes.
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

/// Data class containing an episode with its progress
/// information.
class SmartPlaylistEpisodeData {
  const SmartPlaylistEpisodeData({
    required this.episode,
    this.progress,
    this.siblingEpisodeIds,
  });

  final Episode episode;
  final EpisodeWithProgress? progress;

  /// Episode IDs in the same group for adhoc queue building.
  /// Set by the screen when episodes are displayed in a
  /// sub-category.
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
/// Episodes are sorted by publish date (oldest first).
/// Callers reverse the list for "newest first" display.
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

  sortEpisodeDataByPublishDate(result);

  return result;
}

/// Re-resolves smart playlists from episodes using the
/// resolver service, enriches with thumbnails, but does not
/// persist (data is already cached).
Future<SmartPlaylistGrouping?> _reResolveFromEpisodes(
  Ref ref,
  int podcastId,
  String feedUrl, {
  String? podcastImageUrl,
}) async {
  final episodeRepo = ref.watch(episodeRepositoryProvider);

  // Load matching config from repository
  final repo = ref.watch(smartPlaylistConfigRepositoryProvider);
  final summary = repo.findMatchingPattern(null, feedUrl);
  SmartPlaylistPatternConfig? config;
  if (summary != null) {
    try {
      config = await repo.getConfig(summary);
    } on Object {
      // If remote fetch fails, continue without config
    }
  }

  final resolverService = SmartPlaylistResolverService(
    resolvers: [RssMetadataResolver(), CategoryResolver(), YearResolver()],
    patterns: config != null ? [config] : [],
  );

  final episodes = await episodeRepo.getByPodcastId(podcastId);
  if (episodes.isEmpty) return null;

  final result = resolverService.resolveSmartPlaylists(
    podcastGuid: null,
    feedUrl: feedUrl,
    episodes: episodes,
  );
  if (result == null) return null;

  // Enrich playlists and their groups with thumbnails
  final podcastImage = podcastImageUrl ?? _findPodcastImageUrl(episodes);
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

    // Enrich groups with thumbnails
    final enrichedGroups = playlist.groups?.map((group) {
      return _enrichGroup(group, episodes, podcastImageUrl: podcastImage);
    }).toList();

    return playlist.copyWith(
      thumbnailUrl: thumbnailUrl,
      groups: enrichedGroups,
    );
  }).toList();

  return SmartPlaylistGrouping(
    playlists: enriched,
    ungroupedEpisodeIds: result.ungroupedEpisodeIds,
    resolverType: result.resolverType,
  );
}

/// Sorts [SmartPlaylistEpisodeData] by publish date ascending
/// (oldest first). Episodes with null dates sort after those
/// with dates.
@visibleForTesting
void sortEpisodeDataByPublishDate(List<SmartPlaylistEpisodeData> data) {
  data.sort((a, b) {
    final aPub = a.episode.publishedAt;
    final bPub = b.episode.publishedAt;
    if (aPub != null && bPub != null) {
      return aPub.compareTo(bPub);
    }
    if (aPub != null) return -1;
    if (bPub != null) return 1;
    return 0;
  });
}
