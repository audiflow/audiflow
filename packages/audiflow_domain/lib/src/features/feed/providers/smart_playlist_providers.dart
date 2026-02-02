import 'package:drift/drift.dart';
import 'package:meta/meta.dart' show visibleForTesting;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../common/database/app_database.dart';
import '../../../common/providers/database_provider.dart';
import '../../../common/providers/logger_provider.dart';
import '../../../features/subscription/repositories/subscription_repository_impl.dart';
import '../../player/models/episode_with_progress.dart';
import '../../player/repositories/playback_history_repository_impl.dart';
import '../datasources/local/smart_playlist_local_datasource.dart';
import '../models/smart_playlist.dart';
import '../models/smart_playlist_pattern_config.dart';
import '../repositories/episode_repository.dart';
import '../repositories/episode_repository_impl.dart';
import '../resolvers/category_resolver.dart';
import '../resolvers/rss_metadata_resolver.dart';
import '../resolvers/year_resolver.dart';
import '../services/smart_playlist_resolver_service.dart';

part 'smart_playlist_providers.g.dart';

/// Provides the registered smart playlist pattern configs.
///
/// Initially empty; the app layer overrides this to set patterns
/// loaded from JSON config files.
@Riverpod(keepAlive: true)
class SmartPlaylistPatterns extends _$SmartPlaylistPatterns {
  @override
  List<SmartPlaylistPatternConfig> build() => [];

  /// Replaces the current patterns with the given list.
  void setPatterns(List<SmartPlaylistPatternConfig> patterns) {
    state = patterns;
  }
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
/// The resolver chain tries RSS metadata first, then falls back to
/// year-based grouping. Custom patterns can be added for specific
/// podcasts.
@Riverpod(keepAlive: true)
SmartPlaylistResolverService smartPlaylistResolverService(Ref ref) {
  final patterns = ref.watch(smartPlaylistPatternsProvider);
  return SmartPlaylistResolverService(
    resolvers: [RssMetadataResolver(), CategoryResolver(), YearResolver()],
    patterns: patterns,
  );
}

/// Finds the smart playlist pattern config that matches a given
/// feed URL.
///
/// Returns null if no pattern matches.
@riverpod
SmartPlaylistPatternConfig? smartPlaylistPatternByFeedUrl(
  Ref ref,
  String feedUrl,
) {
  final patterns = ref.watch(smartPlaylistPatternsProvider);
  for (final config in patterns) {
    if (config.matchesPodcast(null, feedUrl)) {
      return config;
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
/// When a pattern config matches, re-resolves from episodes using
/// the resolver service (groups are not cached). For season-based
/// resolvers without a config match, groups by episode.seasonNumber.
Future<SmartPlaylistGrouping?> _buildGroupingFromCache(
  Ref ref,
  int podcastId,
  List<SmartPlaylistEntity> cachedPlaylists,
  EpisodeRepository episodeRepo,
  String feedUrl,
) async {
  final config = ref.read(smartPlaylistPatternByFeedUrlProvider(feedUrl));

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

    // Enrich groups with thumbnails
    final enrichedGroups = playlist.groups?.map((group) {
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

      DateTime? earliest;
      DateTime? latest;
      var totalMs = 0;
      var hasDuration = false;
      for (final ep in groupEpisodes) {
        final pub = ep.publishedAt;
        if (pub != null) {
          if (earliest == null || pub.isBefore(earliest)) earliest = pub;
          if (latest == null || pub.isAfter(latest)) latest = pub;
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
        earliestDate: earliest,
        latestDate: latest,
        totalDurationMs: hasDuration ? totalMs : null,
      );
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
      ),
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
        );
      }).toList();
      await playlistDatasource.upsertGroupsForPlaylist(
        podcastId,
        playlist.id,
        groupCompanions,
      );
    }
  }

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

  // Enrich playlists and their groups with thumbnails
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

      return SmartPlaylistGroup(
        id: group.id,
        displayName: group.displayName,
        sortKey: group.sortKey,
        episodeIds: group.episodeIds,
        thumbnailUrl: groupThumb,
      );
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
