import 'package:logger/logger.dart';
import 'package:meta/meta.dart' show visibleForTesting;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../common/providers/database_provider.dart';
import '../../../common/providers/http_client_provider.dart';
import '../../../common/providers/logger_provider.dart';
import '../../../common/providers/platform_providers.dart';
import '../../../features/subscription/repositories/subscription_repository_impl.dart';
import '../../player/models/episode_with_progress.dart';
import '../../player/models/playback_history.dart';
import '../../player/repositories/playback_history_repository_impl.dart';
import '../datasources/local/smart_playlist_cache_datasource.dart';
import '../datasources/local/smart_playlist_local_datasource.dart';
import '../datasources/remote/smart_playlist_remote_datasource.dart';
import '../models/episode.dart';
import '../models/episode_sort_rule.dart';
import '../models/smart_playlist_groups.dart';
import '../models/smart_playlists.dart';
import '../models/pattern_summary.dart';
import '../models/smart_playlist.dart';
import '../models/smart_playlist_pattern_config.dart';
import '../models/smart_playlist_sort.dart';
import '../repositories/episode_repository.dart';
import '../repositories/episode_repository_impl.dart';
import '../repositories/smart_playlist_config_repository.dart';
import '../repositories/smart_playlist_config_repository_impl.dart';
import '../resolvers/season_number_resolver.dart';
import '../resolvers/title_classifier_resolver.dart';
import '../resolvers/title_discovery_resolver.dart';
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

/// Holds the schema version from the most recent root meta.
///
/// Set alongside [PatternSummaries] on startup and
/// pull-to-refresh. Used to construct GitHub branch URLs
/// (e.g. `dev/v5`).
@Riverpod(keepAlive: true)
class SmartPlaylistSchemaVersion extends _$SmartPlaylistSchemaVersion {
  @override
  int build() => 0;

  /// Updates the schema version.
  void setSchemaVersion(int version) {
    state = version;
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
  final isar = ref.watch(isarProvider);
  return SmartPlaylistLocalDatasource(isar);
}

/// Provides the smart playlist resolver service with built-in
/// resolvers.
///
/// Patterns are loaded lazily via repository. The resolver
/// operates in auto-detect mode (empty patterns list).
@Riverpod(keepAlive: true)
SmartPlaylistResolverService smartPlaylistResolverService(Ref ref) {
  final logger = ref.watch(namedLoggerProvider('SmartPlaylistResolverService'));
  return SmartPlaylistResolverService(
    resolvers: [
      SeasonNumberResolver(logger: logger),
      TitleClassifierResolver(),
      TitleDiscoveryResolver(),
      YearResolver(),
    ],
    patterns: [],
    logger: logger,
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
/// records and their persisted groups.
///
/// Reconstructs the full grouping from database entities.
/// Re-resolves only when config version has changed (upstream
/// config update).
Future<SmartPlaylistGrouping?> _buildGroupingFromCache(
  Ref ref,
  int podcastId,
  List<SmartPlaylistEntity> cachedPlaylists,
  EpisodeRepository episodeRepo,
  String feedUrl,
) async {
  final playlistDatasource = ref.watch(smartPlaylistLocalDatasourceProvider);

  // Check if config version has changed
  final configRepo = ref.watch(smartPlaylistConfigRepositoryProvider);
  final summary = configRepo.findMatchingPattern(null, feedUrl);
  if (summary != null) {
    final cachedVersion = cachedPlaylists.first.configVersion;
    if (cachedVersion == null || cachedVersion != summary.dataVersion) {
      // Config has been updated upstream -- re-resolve
      return _reResolveFromEpisodes(ref, podcastId, feedUrl);
    }
  }

  final episodes = await episodeRepo.getByPodcastId(podcastId);
  if (episodes.isEmpty) return null;

  final resolverType = cachedPlaylists.first.resolverType;
  final ungroupedIds = <int>[];
  final allGroupedEpisodeIds = <int>{};

  // Reconstruct playlists from cached entities + persisted groups
  final playlists = <SmartPlaylist>[];
  for (final entity in cachedPlaylists) {
    // Use stored playlistId; fall back for legacy records.
    // Derive prefix from resolverType so year-resolved playlists
    // get 'year_N' instead of 'season_N'.
    final playlistId = entity.playlistId.isNotEmpty
        ? entity.playlistId
        : '${resolverType == 'year' ? 'year' : 'season'}_${entity.playlistNumber}';

    // Load persisted groups for this playlist
    final groupEntities = await playlistDatasource.getGroupsByPlaylist(
      podcastId,
      playlistId,
    );

    List<SmartPlaylistGroup>? groups;
    List<int> episodeIds;

    if (groupEntities.isNotEmpty) {
      // Reconstruct groups from persisted entities
      groups = groupEntities.map((g) {
        final gEpisodeIds = g.episodeIds.isEmpty
            ? <int>[]
            : g.episodeIds.split(',').map(int.parse).toList();
        allGroupedEpisodeIds.addAll(gEpisodeIds);
        return SmartPlaylistGroup(
          id: g.groupId,
          displayName: g.displayName,
          sortKey: g.sortKey,
          episodeIds: gEpisodeIds,
          thumbnailUrl: g.thumbnailUrl,
          yearOverride: g.yearOverride != null
              ? YearBinding.fromString(g.yearOverride)
              : null,
          showDateRange: g.showDateRange,
          showYearHeaders: g.showYearHeaders,
          prependSeasonNumber: g.prependSeasonNumber,
          episodeSort: g.episodeSortField != null
              ? EpisodeSortRule(
                  field: EpisodeSortField.values.byName(g.episodeSortField!),
                  order: SortOrder.values.byName(
                    g.episodeSortOrder ?? 'ascending',
                  ),
                )
              : null,
          earliestDate: g.earliestDate,
          latestDate: g.latestDate,
          totalDurationMs: g.totalDurationMs,
        );
      }).toList();
      episodeIds = groups.expand((g) => g.episodeIds).toList();
    } else if (resolverType == 'year') {
      // Year-resolved: match by publishedAt year
      episodeIds = episodes
          .where((e) => e.publishedAt?.year == entity.playlistNumber)
          .map((e) => e.id)
          .toList();
      allGroupedEpisodeIds.addAll(episodeIds);
    } else {
      // Fallback: season-number-based grouping
      episodeIds = episodes
          .where((e) => e.seasonNumber == entity.playlistNumber)
          .map((e) => e.id)
          .toList();
      allGroupedEpisodeIds.addAll(episodeIds);
    }

    // Infer structure from persisted groups: if groups exist in
    // the database the playlist was originally resolved as
    // non-separate (combined), regardless of what the entity field
    // says. This handles stale records created before the field was
    // added.
    // Accept both 'separate' (v5) and legacy 'split' (v4/v3)
    // so cached data written before the rename still works.
    final isSeparate = groups == null || groups.isEmpty
        ? entity.playlistStructure == 'separate' ||
              entity.playlistStructure == 'split'
        : false;

    playlists.add(
      SmartPlaylist(
        id: playlistId,
        displayName: entity.displayName,
        sortKey: entity.sortKey,
        episodeIds: episodeIds,
        thumbnailUrl: entity.thumbnailUrl,
        isSeparate: isSeparate,
        yearBinding: YearBinding.fromString(entity.yearHeaderMode),
        showDateRange: entity.showDateRange,
        showYearHeaders: entity.showYearHeaders,
        userSortable: entity.userSortable,
        prependSeasonNumber: entity.prependSeasonNumber,
        groupSort: entity.groupSortField != null
            ? SmartPlaylistSortRule(
                field: SmartPlaylistSortField.values.byName(
                  entity.groupSortField!,
                ),
                order: SortOrder.values.byName(
                  entity.groupSortOrder ?? 'ascending',
                ),
              )
            : null,
        episodeSort: entity.episodeSortField != null
            ? EpisodeSortRule(
                field: EpisodeSortField.values.byName(entity.episodeSortField!),
                order: SortOrder.values.byName(
                  entity.episodeSortOrder ?? 'ascending',
                ),
              )
            : null,
        groups: groups,
      ),
    );
  }

  // Ungrouped = episodes not in any playlist
  for (final episode in episodes) {
    if (!allGroupedEpisodeIds.contains(episode.id)) {
      ungroupedIds.add(episode.id);
    }
  }

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
  Logger logger, {
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
    resolvers: [
      SeasonNumberResolver(logger: logger),
      TitleClassifierResolver(),
      TitleDiscoveryResolver(),
      YearResolver(),
    ],
    patterns: config != null ? [config] : [],
    logger: logger,
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
  final entities = <SmartPlaylistEntity>[];
  final podcastImage = podcastImageUrl ?? findPodcastImageUrl(episodes);

  final configVersion = summary?.dataVersion;

  for (final playlist in result.playlists) {
    _enrichPlaylist(
      playlist,
      episodes,
      result,
      podcastId,
      enrichedPlaylists,
      entities,
      podcastImageUrl: podcastImage,
      configVersion: configVersion,
    );
  }

  await playlistDatasource.upsertAllForPodcast(podcastId, entities);

  // Persist groups with cached metadata
  for (final playlist in enrichedPlaylists) {
    if (playlist.groups != null && playlist.groups!.isNotEmpty) {
      final groupEntities = playlist.groups!.map((g) {
        return SmartPlaylistGroupEntity()
          ..podcastId = podcastId
          ..playlistId = playlist.id
          ..groupId = g.id
          ..displayName = g.displayName
          ..sortKey = g.sortKey
          ..thumbnailUrl = g.thumbnailUrl
          ..episodeIds = g.episodeIds.join(',')
          ..yearOverride = g.yearOverride?.name
          ..earliestDate = g.earliestDate
          ..latestDate = g.latestDate
          ..totalDurationMs = g.totalDurationMs
          ..showDateRange = g.showDateRange
          ..showYearHeaders = g.showYearHeaders
          ..prependSeasonNumber = g.prependSeasonNumber
          ..episodeSortField = g.episodeSort?.field.name
          ..episodeSortOrder = g.episodeSort?.order.name;
      }).toList();
      await playlistDatasource.upsertGroupsForPlaylist(
        podcastId,
        playlist.id,
        groupEntities,
      );
    }
  }

  logger.d(
    'Persisted ${entities.length} smart playlists '
    'to database',
  );

  return SmartPlaylistGrouping(
    playlists: enrichedPlaylists,
    ungroupedEpisodeIds: result.ungroupedEpisodeIds,
    resolverType: result.resolverType,
  );
}

/// Finds the podcast-level imageUrl when a clear majority of
/// episodes share the same artwork.
///
/// Returns the most common imageUrl only if it appears in more
/// than half of the episodes that have an imageUrl. This avoids
/// false positives when seasons use distinct artwork with
/// similar episode counts.
@visibleForTesting
String? findPodcastImageUrl(List<Episode> episodes) {
  final counts = <String, int>{};
  var totalWithImage = 0;
  for (final ep in episodes) {
    final url = ep.imageUrl;
    if (url != null) {
      totalWithImage++;
      counts[url] = (counts[url] ?? 0) + 1;
    }
  }
  if (counts.isEmpty) return null;

  String? mostCommon;
  var maxCount = 0;
  for (final entry in counts.entries) {
    if (maxCount < entry.value) {
      maxCount = entry.value;
      mostCommon = entry.key;
    }
  }

  // Require a strict majority to avoid ambiguous cases
  if (maxCount * 2 <= totalWithImage) return null;

  return mostCommon;
}

/// Enriches a playlist with thumbnails and builds the
/// entity for database persistence.
void _enrichPlaylist(
  SmartPlaylist playlist,
  List<Episode> episodes,
  SmartPlaylistGrouping result,
  int podcastId,
  List<SmartPlaylist> enrichedPlaylists,
  List<SmartPlaylistEntity> entities, {
  String? podcastImageUrl,
  int? configVersion,
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
  entities.add(
    SmartPlaylistEntity()
      ..podcastId = podcastId
      ..playlistNumber = playlist.sortKey
      ..playlistId = playlist.id
      ..displayName = playlist.displayName
      ..sortKey = playlist.sortKey
      ..resolverType = result.resolverType
      ..thumbnailUrl = thumbnailUrl
      ..playlistStructure = playlist.isSeparate ? 'separate' : 'combined'
      ..yearGrouped = playlist.yearBinding != YearBinding.none
      ..yearHeaderMode = playlist.yearBinding.name
      ..showDateRange = playlist.showDateRange
      ..showYearHeaders = playlist.showYearHeaders
      ..userSortable = playlist.userSortable
      ..prependSeasonNumber = playlist.prependSeasonNumber
      ..groupSortField = playlist.groupSort?.field.name
      ..groupSortOrder = playlist.groupSort?.order.name
      ..episodeSortField = playlist.episodeSort?.field.name
      ..episodeSortOrder = playlist.episodeSort?.order.name
      ..configVersion = configVersion,
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
    yearOverride: group.yearOverride,
    showDateRange: group.showDateRange,
    showYearHeaders: group.showYearHeaders,
    episodeSort: group.episodeSort,
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
/// [hasSmartPlaylistView]. All visited podcasts have a
/// subscription entry (real or cached).
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
/// smart playlists. All visited podcasts have a subscription
/// entry (real or cached).
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
  final logger = ref.watch(namedLoggerProvider('ReResolveSmartPlaylists'));
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
    resolvers: [
      SeasonNumberResolver(logger: logger),
      TitleClassifierResolver(),
      TitleDiscoveryResolver(),
      YearResolver(),
    ],
    patterns: config != null ? [config] : [],
    logger: logger,
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
  final podcastImage = podcastImageUrl ?? findPodcastImageUrl(episodes);
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

/// Sorts [SmartPlaylistEpisodeData] using the given [rule].
///
/// When [rule] is null, defaults to publishedAt ascending.
/// The sort is performed in-place.
void sortEpisodeData(
  List<SmartPlaylistEpisodeData> data,
  EpisodeSortRule? rule,
) {
  if (rule == null) {
    sortEpisodeDataByPublishDate(data);
    return;
  }

  final ascending = rule.order == SortOrder.ascending;

  data.sort((a, b) {
    final cmp = switch (rule.field) {
      EpisodeSortField.publishedAt => _comparePublishDate(a, b),
      EpisodeSortField.episodeNumber => _compareEpisodeNumber(a, b),
      EpisodeSortField.title => a.episode.title.compareTo(b.episode.title),
    };
    return ascending ? cmp : -cmp;
  });
}

int _comparePublishDate(
  SmartPlaylistEpisodeData a,
  SmartPlaylistEpisodeData b,
) {
  final aPub = a.episode.publishedAt;
  final bPub = b.episode.publishedAt;
  if (aPub != null && bPub != null) return aPub.compareTo(bPub);
  if (aPub != null) return -1;
  if (bPub != null) return 1;
  return 0;
}

int _compareEpisodeNumber(
  SmartPlaylistEpisodeData a,
  SmartPlaylistEpisodeData b,
) {
  final aNum = a.episode.episodeNumber;
  final bNum = b.episode.episodeNumber;
  if (aNum != null && bNum != null) return aNum.compareTo(bNum);
  if (aNum != null) return -1;
  if (bNum != null) return 1;
  return 0;
}
