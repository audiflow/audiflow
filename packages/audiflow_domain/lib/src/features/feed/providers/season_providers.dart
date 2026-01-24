import 'package:riverpod_annotation/riverpod_annotation.dart';

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
