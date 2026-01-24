import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../common/database/app_database.dart';
import '../../../features/subscription/repositories/subscription_repository_impl.dart';
import '../../player/models/episode_with_progress.dart';
import '../../player/repositories/playback_history_repository_impl.dart';
import '../models/season.dart';
import '../repositories/episode_repository_impl.dart';
import '../resolvers/rss_metadata_resolver.dart';
import '../resolvers/year_resolver.dart';
import '../services/season_resolver_service.dart';

part 'season_providers.g.dart';

/// Provides the season resolver service with built-in resolvers.
///
/// The resolver chain tries RSS metadata first, then falls back to year-based
/// grouping. Custom patterns can be added for specific podcasts.
@Riverpod(keepAlive: true)
SeasonResolverService seasonResolverService(Ref ref) {
  return SeasonResolverService(
    resolvers: [RssMetadataResolver(), YearResolver()],
    patterns: [], // V1: No custom patterns yet
  );
}

/// Resolves seasons for a podcast by its ID.
///
/// Returns null if no resolver can group the episodes.
@riverpod
Future<SeasonGrouping?> podcastSeasons(Ref ref, int podcastId) async {
  final episodeRepo = ref.watch(episodeRepositoryProvider);
  final resolverService = ref.watch(seasonResolverServiceProvider);

  final episodes = await episodeRepo.getByPodcastId(podcastId);
  if (episodes.isEmpty) return null;

  // For now, we'll pass null for guid and empty for feedUrl
  // TODO: Add subscription repository to get podcast details
  return resolverService.resolveSeasons(
    podcastGuid: null,
    feedUrl: '',
    episodes: episodes,
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
