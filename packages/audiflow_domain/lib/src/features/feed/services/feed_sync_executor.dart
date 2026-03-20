import 'package:dio/dio.dart';
import 'package:logger/logger.dart';

import '../../settings/repositories/app_settings_repository.dart';
import '../../subscription/models/subscriptions.dart';
import '../../subscription/repositories/subscription_repository.dart';
import '../models/feed_parse_progress.dart';
import '../models/feed_sync_result.dart';
import '../repositories/episode_repository.dart';
import 'feed_parser_service.dart';

/// Pure feed sync executor with constructor-injected dependencies.
///
/// Unlike [FeedSyncService], this class has no Riverpod [Ref] dependency,
/// making it safe to use inside background isolates (e.g. workmanager).
///
/// It performs the core RSS fetch → parse → upsert → timestamp update cycle
/// without smart playlist resolution or transcript/chapter extraction.
class FeedSyncExecutor {
  FeedSyncExecutor({
    required SubscriptionRepository subscriptionRepo,
    required EpisodeRepository episodeRepo,
    required AppSettingsRepository settingsRepo,
    required FeedParserService feedParser,
    required Dio dio,
    Logger? logger,
  }) : _subscriptionRepo = subscriptionRepo,
       _episodeRepo = episodeRepo,
       _settingsRepo = settingsRepo,
       _feedParser = feedParser,
       _dio = dio,
       _logger = logger;

  final SubscriptionRepository _subscriptionRepo;
  final EpisodeRepository _episodeRepo;
  final AppSettingsRepository _settingsRepo;
  final FeedParserService _feedParser;
  final Dio _dio;
  final Logger? _logger;

  /// Sync interval derived from user settings.
  Duration get _syncInterval =>
      Duration(minutes: _settingsRepo.getSyncIntervalMinutes());

  /// Syncs a single podcast feed with early termination.
  ///
  /// Skips if the feed was refreshed within the sync interval,
  /// unless [forceRefresh] is true.
  Future<SingleFeedSyncResult> syncFeed(
    Subscription sub, {
    bool forceRefresh = false,
  }) async {
    try {
      if (!forceRefresh && !_shouldSync(sub.lastRefreshedAt)) {
        _logger?.d('Skipping sync for "${sub.title}" (recently refreshed)');
        return SingleFeedSyncResult(
          podcastId: sub.id,
          success: true,
          skipped: true,
        );
      }

      _logger?.d('Syncing feed for "${sub.title}"');

      final response = await _dio.get<String>(
        sub.feedUrl,
        options: Options(
          headers: {'Accept': 'application/rss+xml, application/xml, text/xml'},
          responseType: ResponseType.plain,
        ),
      );

      final xmlContent = response.data;
      if (xmlContent == null || xmlContent.isEmpty) {
        _logger?.w('Empty RSS response for "${sub.title}"');
        return SingleFeedSyncResult(
          podcastId: sub.id,
          success: false,
          skipped: false,
          errorMessage: 'Empty RSS response',
        );
      }

      final knownGuids = await _episodeRepo.getGuidsByPodcastId(sub.id);

      var newEpisodeCount = 0;
      await for (final progress in _feedParser.parseWithProgress(
        xmlContent: xmlContent,
        podcastId: sub.id,
        knownGuids: knownGuids,
        onBatchReady: (episodes, _mediaMetas) async {
          await _episodeRepo.upsertEpisodes(episodes);
        },
      )) {
        if (progress is FeedParseComplete) {
          newEpisodeCount = progress.total;
        }
      }

      await _subscriptionRepo.updateLastRefreshed(sub.itunesId, DateTime.now());

      _logger?.i('Synced "${sub.title}": $newEpisodeCount episodes processed');

      return SingleFeedSyncResult(
        podcastId: sub.id,
        success: true,
        skipped: false,
        newEpisodeCount: newEpisodeCount,
      );
    } catch (e, stack) {
      _logger?.e(
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
