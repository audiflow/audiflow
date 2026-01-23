import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'podcast_detail_controller.g.dart';

/// Provider for subscription repository access.
///
/// Re-exported from audiflow_domain for convenience.
@riverpod
SubscriptionRepository subscriptionRepositoryAccess(Ref ref) {
  return ref.watch(subscriptionRepositoryProvider);
}

/// Provides a Dio client for RSS feed fetching.
@Riverpod(keepAlive: true)
Dio feedHttpClient(Ref ref) {
  final dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 10),
      headers: {
        'Accept': 'application/rss+xml, application/xml, text/xml, */*',
        'User-Agent': 'Audiflow/2.0 (Podcast Player)',
      },
    ),
  );
  ref.onDispose(() => dio.close());
  return dio;
}

/// Fetches and provides parsed podcast feed data for a given feed URL.
///
/// Uses Dio for network requests to avoid dart:io HttpClient issues on mobile.
/// Returns [ParsedFeed] containing podcast metadata and episodes.
/// Throws [PodcastException] if the feed cannot be fetched or parsed.
@riverpod
Future<ParsedFeed> podcastDetail(Ref ref, String feedUrl) async {
  final logger = ref.watch(namedLoggerProvider('PodcastDetail'));
  logger.i('Starting to fetch feed from: $feedUrl');

  final dio = ref.watch(feedHttpClientProvider);
  final feedParser = ref.watch(feedParserServiceProvider);

  try {
    // Fetch XML content using Dio (better mobile compatibility)
    final response = await dio.get<String>(
      feedUrl,
      options: Options(responseType: ResponseType.plain),
    );

    if (response.data == null || response.data!.isEmpty) {
      throw PodcastException(
        message: 'Empty response from feed URL',
        sourceUrl: feedUrl,
      );
    }

    logger.d('Fetched ${response.data!.length} bytes, parsing...');

    // Parse the XML content
    final result = await feedParser.parseFromString(response.data!);

    logger.i('Successfully parsed feed: ${result.episodeCount} episodes');

    // Persist episodes if user is subscribed to this podcast
    final subscriptionRepo = ref.read(subscriptionRepositoryProvider);
    final subscription = await subscriptionRepo.getByFeedUrl(feedUrl);

    if (subscription != null) {
      final episodeRepo = ref.read(episodeRepositoryProvider);
      await episodeRepo.upsertFromFeedItems(subscription.id, result.episodes);
      logger.d('Persisted ${result.episodes.length} episodes for subscription');
    }

    return result;
  } on DioException catch (e) {
    logger.e('Network error fetching feed', error: e);
    throw PodcastException(
      message: 'Network error: ${e.message}',
      sourceUrl: feedUrl,
    );
  } catch (e, stack) {
    logger.e('Error fetching/parsing feed', error: e, stackTrace: stack);
    rethrow;
  }
}

/// Fetches episode progress for a given audio URL.
///
/// Returns [EpisodeWithProgress] if the episode exists in the database,
/// otherwise returns null (episode not yet persisted).
@riverpod
Future<EpisodeWithProgress?> episodeProgress(Ref ref, String audioUrl) async {
  final episodeRepo = ref.watch(episodeRepositoryProvider);
  final historyRepo = ref.watch(playbackHistoryRepositoryProvider);

  final episode = await episodeRepo.getByAudioUrl(audioUrl);
  if (episode == null) return null;

  final history = await historyRepo.getByEpisodeId(episode.id);
  return EpisodeWithProgress(episode: episode, history: history);
}
