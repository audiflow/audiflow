import 'package:audiflow_core/audiflow_core.dart' show EpisodeData;
import 'package:dio/dio.dart';
import 'package:drift/drift.dart';
import 'package:logger/logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../common/database/app_database.dart';
import '../../../common/providers/http_client_provider.dart';
import '../../../common/providers/logger_provider.dart';
import '../../../features/subscription/repositories/subscription_repository_impl.dart';
import '../models/feed_parse_progress.dart';
import '../models/feed_sync_result.dart';
import '../providers/smart_playlist_providers.dart';
import '../repositories/episode_repository_impl.dart';
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

  static const _syncInterval = Duration(hours: 1);

  /// Syncs all subscribed podcast feeds in parallel.
  ///
  /// When [forceRefresh] is true, skips the timing window check
  /// and syncs all feeds regardless of when they were last refreshed.
  Future<FeedSyncResult> syncAllSubscriptions({
    bool forceRefresh = false,
  }) async {
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

      // Fetch RSS content
      final response = await dio.get<String>(
        sub.feedUrl,
        options: Options(
          headers: {'Accept': 'application/rss+xml, application/xml, text/xml'},
          responseType: ResponseType.plain,
        ),
      );

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

      // Look up smart playlist extractor from pattern config
      final patternConfig = await _ref.read(
        smartPlaylistPatternByFeedUrlProvider(sub.feedUrl).future,
      );
      final extractor = patternConfig?.playlists
          .map((d) => d.smartPlaylistEpisodeExtractor)
          .nonNulls
          .firstOrNull;

      // Parse with progress and batch storage
      var newEpisodeCount = 0;
      await for (final progress in feedParser.parseWithProgress(
        xmlContent: xmlContent,
        podcastId: sub.id,
        knownGuids: knownGuids,
        onBatchReady: (companions) async {
          // Apply extractor if available
          if (extractor != null) {
            final enriched = companions.map((c) {
              final title = c.title.value;
              final episodeData = _CompanionEpisodeData(
                title: title,
                seasonNumber: c.seasonNumber.value,
                episodeNumber: c.episodeNumber.value,
              );
              final extracted = extractor.extract(episodeData);
              if (extracted.hasValues) {
                return c.copyWith(
                  seasonNumber: Value(
                    extracted.seasonNumber ?? c.seasonNumber.value,
                  ),
                  episodeNumber: Value(
                    extracted.episodeNumber ?? c.episodeNumber.value,
                  ),
                );
              }
              return c;
            }).toList();
            await episodeRepo.upsertEpisodes(enriched);
          } else {
            await episodeRepo.upsertEpisodes(companions);
          }
        },
      )) {
        if (progress is FeedParseComplete) {
          newEpisodeCount = progress.total;
        }
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

/// Adapter for EpisodesCompanion to work with episode extractor.
class _CompanionEpisodeData implements EpisodeData {
  const _CompanionEpisodeData({
    required this.title,
    this.seasonNumber,
    this.episodeNumber,
  });

  @override
  final String title;

  @override
  String? get description => null;

  @override
  final int? seasonNumber;

  @override
  final int? episodeNumber;
}
