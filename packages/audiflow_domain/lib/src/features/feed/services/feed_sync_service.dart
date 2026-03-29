import 'package:audiflow_core/audiflow_core.dart' show EpisodeData;
import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../common/providers/http_client_provider.dart';
import '../../../common/providers/logger_provider.dart';
import '../../../features/subscription/models/subscriptions.dart';
import '../../../features/subscription/repositories/subscription_repository_impl.dart';
import '../../station/repositories/station_podcast_repository_impl.dart';
import '../../station/services/station_reconciler_service.dart';
import '../models/episode.dart';
import '../models/feed_parse_progress.dart';
import '../models/feed_sync_result.dart';
import '../../settings/providers/settings_providers.dart';
import '../providers/smart_playlist_providers.dart';
import '../repositories/episode_repository_impl.dart';
import 'episode_extractor_resolver.dart';
import 'feed_parser_service.dart';

part 'feed_sync_service.g.dart';

/// Provides a singleton [FeedSyncService] for syncing podcast feeds.
@Riverpod(keepAlive: true)
FeedSyncService feedSyncService(Ref ref) {
  final logger = ref.watch(namedLoggerProvider('FeedSync'));
  return FeedSyncService(ref: ref, logger: logger);
}

/// Service for syncing RSS feeds of subscribed podcasts.
///
/// Fetches and parses feeds in parallel with early termination
/// when known episode GUIDs are encountered.
class FeedSyncService {
  FeedSyncService({required Ref ref, required Logger logger})
    : _ref = ref,
      _logger = logger;

  final Ref _ref;
  final Logger _logger;

  /// Sync interval derived from user settings.
  Duration get _syncInterval {
    final repo = _ref.read(appSettingsRepositoryProvider);
    return Duration(minutes: repo.getSyncIntervalMinutes());
  }

  /// Syncs all subscribed podcast feeds in parallel.
  ///
  /// When [forceRefresh] is true, skips the timing window check
  /// and syncs all feeds regardless of when they were last refreshed.
  /// Also skips sync when auto-sync is disabled (unless forced).
  Future<FeedSyncResult> syncAllSubscriptions({
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh) {
      final settingsRepo = _ref.read(appSettingsRepositoryProvider);
      if (!settingsRepo.getAutoSync()) {
        _logger.i('Auto-sync disabled, skipping');
        return const FeedSyncResult(
          totalCount: 0,
          successCount: 0,
          skipCount: 0,
          errorCount: 0,
        );
      }
    }

    final subscriptionRepo = _ref.read(subscriptionRepositoryProvider);
    final subscriptions = await subscriptionRepo.getSubscriptions();

    if (subscriptions.isEmpty) {
      _logger.i('No subscriptions to sync');
      return const FeedSyncResult(
        totalCount: 0,
        successCount: 0,
        skipCount: 0,
        errorCount: 0,
      );
    }

    _logger.i(
      'Starting feed sync for ${subscriptions.length} subscriptions '
      '(force: $forceRefresh)',
    );

    final results = await Future.wait(
      subscriptions.map((sub) => syncFeed(sub, forceRefresh: forceRefresh)),
    );

    final successCount = results.where((r) => r.success).length;
    final skipCount = results.where((r) => r.skipped).length;
    final errorCount = results.where((r) => !r.success && !r.skipped).length;

    final result = FeedSyncResult(
      totalCount: subscriptions.length,
      successCount: successCount,
      skipCount: skipCount,
      errorCount: errorCount,
    );

    _logger.i('Feed sync complete: $result');
    return result;
  }

  /// Syncs only the podcast feeds belonging to a station.
  ///
  /// Looks up the station's podcast links, resolves each to a
  /// [Subscription], and syncs their feeds in parallel.  Always
  /// forces a refresh regardless of the timing window.
  Future<FeedSyncResult> syncStationFeeds(int stationId) async {
    final stationPodcastRepo = _ref.read(stationPodcastRepositoryProvider);
    final subscriptionRepo = _ref.read(subscriptionRepositoryProvider);

    final stationPodcasts = await stationPodcastRepo.getByStation(stationId);
    if (stationPodcasts.isEmpty) {
      _logger.d('Station $stationId has no podcasts to sync');
      return const FeedSyncResult(
        totalCount: 0,
        successCount: 0,
        skipCount: 0,
        errorCount: 0,
      );
    }

    final lookups = await Future.wait(
      stationPodcasts.map((sp) => subscriptionRepo.getById(sp.podcastId)),
    );
    final subscriptions = lookups.whereType<Subscription>().toList();

    if (subscriptions.isEmpty) {
      _logger.w('Station $stationId: no matching subscriptions found');
      return const FeedSyncResult(
        totalCount: 0,
        successCount: 0,
        skipCount: 0,
        errorCount: 0,
      );
    }

    _logger.i('Syncing ${subscriptions.length} feeds for station $stationId');

    final results = await Future.wait(
      subscriptions.map((sub) => syncFeed(sub, forceRefresh: true)),
    );

    final successCount = results.where((r) => r.success).length;
    final skipCount = results.where((r) => r.skipped).length;
    final errorCount = results.where((r) => !r.success && !r.skipped).length;

    final result = FeedSyncResult(
      totalCount: subscriptions.length,
      successCount: successCount,
      skipCount: skipCount,
      errorCount: errorCount,
    );

    _logger.i('Station $stationId feed sync complete: $result');
    return result;
  }

  /// Syncs a single podcast feed with early termination.
  ///
  /// Skips sync if less than 1 hour has elapsed since the last
  /// refresh, unless [forceRefresh] is true.
  Future<SingleFeedSyncResult> syncFeed(
    Subscription sub, {
    bool forceRefresh = false,
  }) async {
    try {
      if (!forceRefresh && !_shouldSync(sub.lastRefreshedAt)) {
        _logger.d('Skipping sync for "${sub.title}" (recently refreshed)');
        return SingleFeedSyncResult(
          podcastId: sub.id,
          success: true,
          skipped: true,
        );
      }

      _logger.d('Syncing feed for "${sub.title}"');

      final dio = _ref.read(dioProvider);
      final episodeRepo = _ref.read(episodeRepositoryProvider);
      final feedParser = _ref.read(feedParserServiceProvider);
      final subscriptionRepo = _ref.read(subscriptionRepositoryProvider);

      // Build conditional request headers
      final conditionalHeaders = <String, String>{
        'Accept': 'application/rss+xml, application/xml, text/xml',
      };
      if (sub.httpEtag != null) {
        conditionalHeaders['If-None-Match'] = sub.httpEtag!;
      }
      if (sub.httpLastModified != null) {
        conditionalHeaders['If-Modified-Since'] = sub.httpLastModified!;
      }

      // Fetch RSS content
      final response = await dio.get<String>(
        sub.feedUrl,
        options: Options(
          headers: conditionalHeaders,
          responseType: ResponseType.plain,
          validateStatus: (status) => status != null && status < 400,
        ),
      );

      // 304 Not Modified — feed unchanged, skip parsing
      if (response.statusCode == 304) {
        _logger.d('Feed not modified (304) for "${sub.title}"');
        await subscriptionRepo.updateLastRefreshed(
          sub.itunesId,
          DateTime.now(),
        );
        return SingleFeedSyncResult(
          podcastId: sub.id,
          success: true,
          skipped: false,
        );
      }

      // Capture HTTP cache headers — persisted only after successful import
      final etag = response.headers.value('etag');
      final lastModified = response.headers.value('last-modified');

      final xmlContent = response.data;
      if (xmlContent == null || xmlContent.isEmpty) {
        _logger.w('Empty RSS response for "${sub.title}"');
        return SingleFeedSyncResult(
          podcastId: sub.id,
          success: false,
          skipped: false,
          errorMessage: 'Empty RSS response',
        );
      }

      // Get known GUIDs for early termination
      final knownGuids = await episodeRepo.getGuidsByPodcastId(sub.id);

      // Look up smart playlist pattern config for per-group extraction
      final patternConfig = await _ref.read(
        smartPlaylistPatternByFeedUrlProvider(sub.feedUrl).future,
      );
      final resolver = patternConfig != null
          ? EpisodeExtractorResolver()
          : null;

      // Parse with progress and batch storage
      var newEpisodeCount = 0;
      await for (final progress in feedParser.parseWithProgress(
        xmlContent: xmlContent,
        podcastId: sub.id,
        knownGuids: knownGuids,
        onBatchReady: (episodes, mediaMetas) async {
          // Apply per-group extractor resolution if pattern config
          // is available.
          if (resolver != null) {
            for (final episode in episodes) {
              final extractor = resolver.resolve(
                episode.title,
                episode.description,
                patternConfig!,
              );
              if (extractor == null) continue;

              final episodeData = _EpisodeDataAdapter(
                title: episode.title,
                description: episode.description,
                seasonNumber: episode.seasonNumber,
                episodeNumber: episode.episodeNumber,
              );
              final extracted = extractor.extract(episodeData);
              if (extracted.hasValues) {
                episode
                  ..seasonNumber =
                      extracted.seasonNumber ?? episode.seasonNumber
                  ..episodeNumber =
                      extracted.episodeNumber ?? episode.episodeNumber;
              }
            }
          }
          await episodeRepo.upsertEpisodes(episodes);

          // Notify stations about newly inserted/updated episodes.
          final reconcilerService = _ref.read(stationReconcilerServiceProvider);
          for (final episode in episodes) {
            await reconcilerService.onEpisodeChanged(episode.id);
          }

          // Store transcript and chapter metadata
          if (mediaMetas.isNotEmpty) {
            await episodeRepo.storeTranscriptAndChapterDataFromParsed(
              sub.id,
              mediaMetas,
            );
          }
        },
      )) {
        if (progress is FeedParseComplete) {
          newEpisodeCount = progress.total;
        }
      }

      // Persist HTTP cache headers only after successful parse + upsert
      if (etag != null || lastModified != null) {
        await subscriptionRepo.updateHttpCacheHeaders(
          sub.id,
          etag: etag,
          lastModified: lastModified,
        );
      }

      // Update lastRefreshedAt
      await subscriptionRepo.updateLastRefreshed(sub.itunesId, DateTime.now());

      // Invalidate smart playlist providers to pick up new episodes
      _ref.invalidate(podcastSmartPlaylistsProvider(sub.id));

      _logger.i('Synced "${sub.title}": $newEpisodeCount episodes processed');

      return SingleFeedSyncResult(
        podcastId: sub.id,
        success: true,
        skipped: false,
        newEpisodeCount: newEpisodeCount,
      );
    } catch (e, stack) {
      _logger.e(
        'Failed to sync feed for "${sub.title}"',
        error: e,
        stackTrace: stack,
      );
      return SingleFeedSyncResult(
        podcastId: sub.id,
        success: false,
        skipped: false,
        errorMessage: e.toString(),
      );
    }
  }

  bool _shouldSync(DateTime? lastRefreshedAt) {
    if (lastRefreshedAt == null) return true;
    final elapsed = DateTime.now().difference(lastRefreshedAt);
    return _syncInterval <= elapsed;
  }
}

/// Adapter for [Episode] to work with episode extractor.
class _EpisodeDataAdapter implements EpisodeData {
  const _EpisodeDataAdapter({
    required this.title,
    this.description,
    this.seasonNumber,
    this.episodeNumber,
  });

  @override
  final String title;

  @override
  final String? description;

  @override
  final int? seasonNumber;

  @override
  final int? episodeNumber;
}
