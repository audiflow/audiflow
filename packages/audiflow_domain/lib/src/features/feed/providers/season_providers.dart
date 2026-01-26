import 'package:drift/drift.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../common/database/app_database.dart';
import '../../../common/providers/database_provider.dart';
import '../../../common/providers/logger_provider.dart';
import '../../../features/subscription/repositories/subscription_repository_impl.dart';
import '../../player/models/episode_with_progress.dart';
import '../../player/repositories/playback_history_repository_impl.dart';
import '../datasources/local/season_local_datasource.dart';
import '../models/season.dart';
import '../models/season_pattern.dart';
import '../patterns/coten_radio_pattern.dart';
import '../repositories/episode_repository.dart';
import '../repositories/episode_repository_impl.dart';
import '../resolvers/rss_metadata_resolver.dart';
import '../resolvers/year_resolver.dart';
import '../services/season_resolver_service.dart';

part 'season_providers.g.dart';

/// List of registered season patterns.
///
/// Add new podcast-specific patterns here.
const _registeredPatterns = [cotenRadioPattern];

/// Provides the season local datasource for database operations.
@Riverpod(keepAlive: true)
SeasonLocalDatasource seasonLocalDatasource(Ref ref) {
  final db = ref.watch(databaseProvider);
  return SeasonLocalDatasource(db);
}

/// Provides the season resolver service with built-in resolvers.
///
/// The resolver chain tries RSS metadata first, then falls back to year-based
/// grouping. Custom patterns can be added for specific podcasts.
@Riverpod(keepAlive: true)
SeasonResolverService seasonResolverService(Ref ref) {
  return SeasonResolverService(
    resolvers: [RssMetadataResolver(), YearResolver()],
    patterns: _registeredPatterns,
  );
}

/// Finds the season pattern that matches a given feed URL.
///
/// Returns null if no pattern matches.
@riverpod
SeasonPattern? seasonPatternByFeedUrl(Ref ref, String feedUrl) {
  for (final pattern in _registeredPatterns) {
    if (pattern.matchesPodcast(null, feedUrl)) {
      return pattern;
    }
  }
  return null;
}

/// Resolves seasons for a podcast by its ID.
///
/// First checks the database for cached seasons. Only resolves from episodes
/// if no cached seasons exist. Returns null if no resolver can group episodes.
@riverpod
Future<SeasonGrouping?> podcastSeasons(Ref ref, int podcastId) async {
  final logger = ref.watch(namedLoggerProvider('PodcastSeasons'));
  final subscriptionRepo = ref.watch(subscriptionRepositoryProvider);
  final episodeRepo = ref.watch(episodeRepositoryProvider);
  final seasonDatasource = ref.watch(seasonLocalDatasourceProvider);

  final subscription = await subscriptionRepo.getById(podcastId);
  if (subscription == null) {
    logger.d('No subscription found for podcastId=$podcastId');
    return null;
  }

  // Check for cached seasons first
  final cachedSeasons = await seasonDatasource.getByPodcastId(podcastId);
  if (cachedSeasons.isNotEmpty) {
    logger.d(
      'Using ${cachedSeasons.length} cached seasons for podcastId=$podcastId',
    );
    return _buildGroupingFromCache(
      ref,
      podcastId,
      cachedSeasons,
      episodeRepo,
      subscription.feedUrl,
    );
  }

  // No cached seasons - resolve from episodes
  return _resolveAndPersistSeasons(
    ref,
    podcastId,
    subscription.feedUrl,
    logger,
  );
}

/// Builds SeasonGrouping from cached SeasonEntity records.
Future<SeasonGrouping?> _buildGroupingFromCache(
  Ref ref,
  int podcastId,
  List<SeasonEntity> cachedSeasons,
  EpisodeRepository episodeRepo,
  String feedUrl,
) async {
  final episodes = await episodeRepo.getByPodcastId(podcastId);
  if (episodes.isEmpty) return null;

  // Check for groupNullSeasonAs config from pattern
  final pattern = ref.read(seasonPatternByFeedUrlProvider(feedUrl));
  final groupNullAs = pattern?.config['groupNullSeasonAs'] as int?;

  // Group episodes by season number
  final episodesBySeasonNum = <int, List<int>>{};
  final ungroupedIds = <int>[];

  for (final episode in episodes) {
    final seasonNum = episode.seasonNumber;
    if (seasonNum != null && 1 <= seasonNum) {
      episodesBySeasonNum.putIfAbsent(seasonNum, () => []).add(episode.id);
    } else if (groupNullAs != null) {
      // Null/zero season number with groupNullSeasonAs config
      episodesBySeasonNum.putIfAbsent(groupNullAs, () => []).add(episode.id);
    } else {
      ungroupedIds.add(episode.id);
    }
  }

  // Build Season objects from cached entities
  final seasons = cachedSeasons.map((entity) {
    final episodeIds = episodesBySeasonNum[entity.seasonNumber] ?? [];
    return Season(
      id: 'season_${entity.seasonNumber}',
      displayName: entity.displayName,
      sortKey: entity.sortKey,
      episodeIds: episodeIds,
      thumbnailUrl: entity.thumbnailUrl,
    );
  }).toList();

  return SeasonGrouping(
    seasons: seasons,
    ungroupedEpisodeIds: ungroupedIds,
    resolverType: cachedSeasons.first.resolverType,
  );
}

/// Resolves seasons from episodes and persists to database.
Future<SeasonGrouping?> _resolveAndPersistSeasons(
  Ref ref,
  int podcastId,
  String feedUrl,
  dynamic logger,
) async {
  final episodeRepo = ref.watch(episodeRepositoryProvider);
  final seasonDatasource = ref.watch(seasonLocalDatasourceProvider);
  final resolverService = ref.watch(seasonResolverServiceProvider);

  final episodes = await episodeRepo.getByPodcastId(podcastId);
  if (episodes.isEmpty) {
    logger.d('No episodes found for podcastId=$podcastId');
    return null;
  }

  // Debug: count episodes with season numbers
  final withSeason = episodes.where((e) => e.seasonNumber != null).length;
  logger.d(
    'Resolving seasons: podcastId=$podcastId, feedUrl=$feedUrl, '
    'episodes=${episodes.length}, withSeasonNumber=$withSeason',
  );

  final result = resolverService.resolveSeasons(
    podcastGuid: null,
    feedUrl: feedUrl,
    episodes: episodes,
  );

  logger.d(
    'Season resolution result: ${result?.seasons.length ?? 0} seasons, '
    '${result?.ungroupedEpisodeIds.length ?? 0} ungrouped',
  );

  if (result == null) return null;

  // Find the latest episode thumbnail for each season
  final enrichedSeasons = <Season>[];
  final companions = <SeasonsCompanion>[];

  for (final season in result.seasons) {
    // Get episodes for this season, sorted by publishedAt (newest first)
    final seasonEpisodes =
        episodes.where((e) => season.episodeIds.contains(e.id)).toList()
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
    for (final ep in seasonEpisodes) {
      if (ep.imageUrl != null) {
        thumbnailUrl = ep.imageUrl;
        break;
      }
    }

    enrichedSeasons.add(season.copyWith(thumbnailUrl: thumbnailUrl));
    companions.add(
      SeasonsCompanion.insert(
        podcastId: podcastId,
        seasonNumber: season.sortKey,
        displayName: season.displayName,
        sortKey: season.sortKey,
        resolverType: result.resolverType,
        thumbnailUrl: Value(thumbnailUrl),
      ),
    );
  }

  await seasonDatasource.upsertAllForPodcast(podcastId, companions);
  logger.d('Persisted ${companions.length} seasons to database');

  return SeasonGrouping(
    seasons: enrichedSeasons,
    ungroupedEpisodeIds: result.ungroupedEpisodeIds,
    resolverType: result.resolverType,
  );
}

/// Whether the season view toggle should be visible for a podcast.
@riverpod
Future<bool> hasSeasonView(Ref ref, int podcastId) async {
  final grouping = await ref.watch(podcastSeasonsProvider(podcastId).future);
  return grouping != null;
}

/// Whether the season view toggle should be visible for a podcast by feed URL.
///
/// Looks up the subscription by feedUrl and delegates to [hasSeasonView].
/// Returns false if the podcast is not subscribed.
@riverpod
Future<bool> hasSeasonViewByFeedUrl(Ref ref, String feedUrl) async {
  final subscriptionRepo = ref.watch(subscriptionRepositoryProvider);
  final subscription = await subscriptionRepo.getByFeedUrl(feedUrl);
  if (subscription == null) return false;

  return ref.watch(hasSeasonViewProvider(subscription.id).future);
}

/// Provides the season grouping for a podcast by feed URL.
///
/// Looks up the subscription by feedUrl and returns the [SeasonGrouping] if
/// episodes can be grouped into seasons. Returns null if the podcast is not
/// subscribed or if no resolver can group the episodes.
@riverpod
Future<SeasonGrouping?> podcastSeasonsByFeedUrl(Ref ref, String feedUrl) async {
  final subscriptionRepo = ref.watch(subscriptionRepositoryProvider);
  final subscription = await subscriptionRepo.getByFeedUrl(feedUrl);
  if (subscription == null) return null;

  return ref.watch(podcastSeasonsProvider(subscription.id).future);
}

/// Data class containing an episode with its progress information.
class SeasonEpisodeData {
  const SeasonEpisodeData({required this.episode, this.progress});

  final Episode episode;
  final EpisodeWithProgress? progress;
}

/// Fetches episodes for a season by their IDs with progress data.
///
/// Episodes are sorted by episode number (ascending) with fallback to
/// publish date (newest first).
@riverpod
Future<List<SeasonEpisodeData>> seasonEpisodes(
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
    return SeasonEpisodeData(
      episode: episode,
      progress: EpisodeWithProgress(episode: episode, history: history),
    );
  }).toList();

  // Sort: episode number ascending (if available), fallback to publish date
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

    // Neither has episode number: sort by publish date (newest first)
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
