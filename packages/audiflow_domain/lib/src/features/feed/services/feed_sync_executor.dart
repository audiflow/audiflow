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
    Set<String> protectedGuids = const {},
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

      final response = await _dio.get<String>(
        sub.feedUrl,
        options: Options(
          headers: conditionalHeaders,
          responseType: ResponseType.plain,
          validateStatus: (status) =>
              status != null &&
              (status == 304 || (200 <= status && status < 300)),
        ),
      );

      // 304 Not Modified — feed unchanged, skip parsing.
      // RFC 9110 allows 304 to include updated validators, so persist them.
      if (response.statusCode == 304) {
        _logger?.d('Feed not modified (304) for "${sub.title}"');
        final newEtag = response.headers.value('etag');
        final newLastModified = response.headers.value('last-modified');
        await _subscriptionRepo.updateHttpCacheHeaders(
          sub.id,
          etag: newEtag ?? sub.httpEtag,
          lastModified: newLastModified ?? sub.httpLastModified,
        );
        await _subscriptionRepo.updateLastRefreshed(
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
      final observedGuids = <String>{};
      await for (final progress in _feedParser.parseWithProgress(
        xmlContent: xmlContent,
        podcastId: sub.id,
        knownGuids: knownGuids,
        onBatchReady: (episodes, mediaMetas) async {
          observedGuids.addAll(episodes.map((e) => e.guid));
          await _episodeRepo.upsertEpisodes(episodes);
        },
      )) {
        if (progress is FeedParseComplete) {
          newEpisodeCount = progress.total;
          observedGuids.addAll(progress.tailGuids);
        }
      }

      // Remove episodes whose GUIDs are no longer in the feed.
      // observedGuids now includes both newly parsed episodes and GUIDs
      // scanned (regex-only) after the early-stop point, giving a complete
      // picture even for incremental syncs. Guard against malformed feeds
      // that parse to zero items.
      if (observedGuids.isNotEmpty) {
        final droppedGuids = knownGuids.difference(observedGuids);
        if (droppedGuids.isNotEmpty) {
          final deleted = await _episodeRepo.deleteByPodcastIdAndGuids(
            sub.id,
            droppedGuids,
            protectedGuids: protectedGuids,
          );
          _logger?.i('Removed $deleted dropped episodes from "${sub.title}"');
        }
      }

      // Persist HTTP cache headers only after successful parse + upsert.
      // Always update so previously stored values are cleared when headers
      // are no longer sent by the server.
      await _subscriptionRepo.updateHttpCacheHeaders(
        sub.id,
        etag: etag,
        lastModified: lastModified,
      );

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
