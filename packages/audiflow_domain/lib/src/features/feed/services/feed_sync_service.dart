import 'dart:collection';
import 'dart:math';

import 'package:audiflow_core/audiflow_core.dart' show EpisodeData;
import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../common/providers/http_client_provider.dart';
import '../../../common/providers/logger_provider.dart';
import '../../../common/services/suspendable_writer.dart';
import '../../../features/subscription/models/subscriptions.dart';
import '../../../features/subscription/repositories/subscription_repository_impl.dart';
import '../../download/providers/download_providers.dart';
import '../../station/repositories/station_podcast_repository_impl.dart';
import '../../station/services/station_reconciler_service.dart';
import '../models/episode.dart';
import '../models/feed_parse_progress.dart';
import '../models/feed_sync_result.dart';
import '../../settings/providers/settings_providers.dart';
import '../providers/preset_providers.dart';
import '../repositories/episode_repository_impl.dart';
import 'episode_extractor_resolver.dart';
import 'feed_parser_service.dart';
import 'feed_sync_diagnostic.dart';
import 'subscription_metadata_updater.dart';

part 'feed_sync_service.g.dart';

/// Caps how many feeds sync at the same time.
///
/// Each sync fetches a feed, spawns a parser isolate, and writes episodes.
/// A large OPML import would otherwise start one of those per subscription
/// at once, which a phone cannot absorb.
const _maxConcurrentFeedSyncs = 4;

/// Result of a sync that had nothing to sync.
const _emptyResult = FeedSyncResult(
  totalCount: 0,
  successCount: 0,
  skipCount: 0,
  errorCount: 0,
);

/// Provides a singleton [FeedSyncService] for syncing podcast feeds.
@Riverpod(keepAlive: true)
FeedSyncService feedSyncService(Ref ref) {
  final logger = ref.watch(namedLoggerProvider('FeedSync'));
  final onDiagnostic = ref.watch(feedSyncDiagnosticSinkProvider);
  return FeedSyncService(ref: ref, logger: logger, onDiagnostic: onDiagnostic);
}

/// Service for syncing RSS feeds of subscribed podcasts.
///
/// Fetches and parses feeds in parallel with early termination
/// when known episode GUIDs are encountered.
class FeedSyncService implements SuspendableWriter {
  FeedSyncService({
    required this._ref,
    required this._logger,
    FeedSyncDiagnosticSink? onDiagnostic,
  }) : _onDiagnostic = onDiagnostic ?? noopFeedSyncDiagnosticSink;

  final Ref _ref;
  final Logger _logger;
  final FeedSyncDiagnosticSink _onDiagnostic;

  /// Every public sync call that has not completed yet, so [suspend] can
  /// wait for them to unwind before the caller touches storage.
  final _inFlight = <Future<void>>{};

  /// Captured by every public sync at entry, before its first lookup, and
  /// carried through to the writes. Cancelling it aborts feed fetches, marks
  /// pending writes as skipped, and stops batch workers from starting the
  /// next feed. It stays cancelled until [resume] issues a fresh one, so a
  /// sync started while suspended writes nothing.
  CancelToken _cancelToken = CancelToken();

  /// Cancels every in-flight feed sync, waits for them to settle, and holds
  /// new syncs idle until [resume].
  ///
  /// "Reset All Data" calls this before clearing storage: a sync awaiting
  /// a feed response would otherwise resume afterwards and write episodes
  /// back, and one started during the reset would do the same.
  @override
  Future<void> suspend() async {
    _cancelToken.cancel('Feed sync suspended');
    await Future.wait(_inFlight.toList());
  }

  @override
  void resume() {
    if (_cancelToken.isCancelled) _cancelToken = CancelToken();
  }

  Future<T> _track<T>(Future<T> work) {
    _inFlight.add(work);
    return work.whenComplete(() => _inFlight.remove(work));
  }

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
  Future<FeedSyncResult> syncAllSubscriptions({bool forceRefresh = false}) =>
      _track(_syncAll(forceRefresh: forceRefresh, cancelToken: _cancelToken));

  Future<FeedSyncResult> _syncAll({
    required bool forceRefresh,
    required CancelToken cancelToken,
  }) async {
    if (!forceRefresh) {
      final settingsRepo = _ref.read(appSettingsRepositoryProvider);
      if (!settingsRepo.getAutoSync()) {
        _logger.i('Auto-sync disabled, skipping');
        return _emptyResult;
      }
    }

    final subscriptionRepo = _ref.read(subscriptionRepositoryProvider);
    final subscriptions = await subscriptionRepo.getSubscriptions();

    if (subscriptions.isEmpty) {
      _logger.i('No subscriptions to sync');
      return _emptyResult;
    }

    _logger.i(
      'Starting feed sync for ${subscriptions.length} subscriptions '
      '(force: $forceRefresh)',
    );

    final result = await _syncSubscriptions(
      subscriptions,
      forceRefresh: forceRefresh,
      cancelToken: cancelToken,
    );

    _logger.i('Feed sync complete: $result');
    return result;
  }

  /// Syncs only the podcast feeds belonging to a station.
  ///
  /// Looks up the station's podcast links, resolves each to a
  /// [Subscription], and syncs their feeds in parallel.  Always
  /// forces a refresh regardless of the timing window.
  Future<FeedSyncResult> syncStationFeeds(int stationId) =>
      _track(_syncStation(stationId, cancelToken: _cancelToken));

  Future<FeedSyncResult> _syncStation(
    int stationId, {
    required CancelToken cancelToken,
  }) async {
    final stationPodcastRepo = _ref.read(stationPodcastRepositoryProvider);
    final subscriptionRepo = _ref.read(subscriptionRepositoryProvider);

    final stationPodcasts = await stationPodcastRepo.getByStation(stationId);
    if (stationPodcasts.isEmpty) {
      _logger.d('Station $stationId has no podcasts to sync');
      return _emptyResult;
    }

    final lookups = await Future.wait(
      stationPodcasts.map((sp) => subscriptionRepo.getById(sp.podcastId)),
    );
    final subscriptions = lookups.whereType<Subscription>().toList();

    if (subscriptions.isEmpty) {
      _logger.w('Station $stationId: no matching subscriptions found');
      return _emptyResult;
    }

    _logger.i('Syncing ${subscriptions.length} feeds for station $stationId');

    final result = await _syncSubscriptions(
      subscriptions,
      forceRefresh: true,
      cancelToken: cancelToken,
    );

    _logger.i('Station $stationId feed sync complete: $result');
    return result;
  }

  /// Syncs the feeds of the subscriptions matching [feedUrls].
  ///
  /// Used right after an OPML import. OPML carries only a title and a
  /// feed URL, so those subscriptions reach the library with no artwork,
  /// author or description; one fetch per feed fills them in instead of
  /// leaving placeholders until the next scheduled sync. Always forces a
  /// refresh regardless of the timing window. Feed URLs with no matching
  /// subscription are ignored.
  Future<FeedSyncResult> syncFeedsByUrls(List<String> feedUrls) =>
      _track(_syncByUrls(feedUrls, cancelToken: _cancelToken));

  Future<FeedSyncResult> _syncByUrls(
    List<String> feedUrls, {
    required CancelToken cancelToken,
  }) async {
    if (feedUrls.isEmpty) return _emptyResult;

    final subscriptionRepo = _ref.read(subscriptionRepositoryProvider);
    final lookups = await Future.wait(
      feedUrls.map(subscriptionRepo.getByFeedUrl),
    );
    final subscriptions = lookups.whereType<Subscription>().toList();

    if (subscriptions.isEmpty) {
      _logger.w('No subscriptions matched ${feedUrls.length} feed urls');
      return _emptyResult;
    }

    _logger.i('Syncing ${subscriptions.length} newly imported feeds');

    final result = await _syncSubscriptions(
      subscriptions,
      forceRefresh: true,
      cancelToken: cancelToken,
    );

    _logger.i('Imported feed sync complete: $result');
    return result;
  }

  /// Syncs a single podcast feed with early termination.
  ///
  /// Skips sync if less than 1 hour has elapsed since the last
  /// refresh, unless [forceRefresh] is true.
  Future<SingleFeedSyncResult> syncFeed(
    Subscription sub, {
    bool forceRefresh = false,
  }) => _track(
    _syncFeed(sub, forceRefresh: forceRefresh, cancelToken: _cancelToken),
  );

  Future<SingleFeedSyncResult> _syncFeed(
    Subscription sub, {
    required bool forceRefresh,
    required CancelToken cancelToken,
  }) async {
    try {
      if (cancelToken.isCancelled) return _cancelledResult(sub);
      if (!forceRefresh && !_shouldSync(sub.lastRefreshedAt)) {
        _logger.d('Skipping sync for "${sub.title}" (recently refreshed)');
        _onDiagnostic('feed-sync:skipped', {
          'path': 'foreground',
          'podcastId': sub.id,
          'title': sub.title,
          'reason': 'recently-refreshed',
        });
        return SingleFeedSyncResult(
          podcastId: sub.id,
          success: true,
          skipped: true,
        );
      }

      _logger.d('Syncing feed for "${sub.title}"');
      _onDiagnostic('feed-sync:start', {
        'path': 'foreground',
        'podcastId': sub.id,
        'title': sub.title,
        'forceRefresh': forceRefresh,
        'hasEtag': sub.httpEtag != null,
        'hasLastModified': sub.httpLastModified != null,
      });

      final dio = _ref.read(dioProvider);
      final episodeRepo = _ref.read(episodeRepositoryProvider);
      final feedParser = _ref.read(feedParserServiceProvider);
      final subscriptionRepo = _ref.read(subscriptionRepositoryProvider);
      final metadataUpdater = SubscriptionMetadataUpdater(subscriptionRepo);

      // Build conditional request headers. A subscription still missing its
      // artwork has to parse the feed to get it, so it asks unconditionally:
      // a 304 skips the parse, and a show that never publishes again would
      // stay blank forever.
      final needsArtwork = SubscriptionMetadataUpdater.needsArtworkBackfill(
        sub,
      );
      final conditionalHeaders = <String, String>{
        'Accept': 'application/rss+xml, application/xml, text/xml',
      };
      if (!needsArtwork && sub.httpEtag != null) {
        conditionalHeaders['If-None-Match'] = sub.httpEtag!;
      }
      if (!needsArtwork && sub.httpLastModified != null) {
        conditionalHeaders['If-Modified-Since'] = sub.httpLastModified!;
      }

      // Fetch RSS content
      final response = await dio.get<String>(
        sub.feedUrl,
        cancelToken: cancelToken,
        options: Options(
          headers: conditionalHeaders,
          responseType: ResponseType.plain,
          validateStatus: (status) =>
              status != null &&
              (status == 304 || (200 <= status && status < 300)),
        ),
      );

      // Dio only throws for a cancellation that lands mid-request; one that
      // lands between the response and the first write needs this check.
      if (cancelToken.isCancelled) return _cancelledResult(sub);

      // 304 Not Modified — feed unchanged, skip parsing.
      // RFC 9110 allows 304 to include updated validators, so persist them.
      if (response.statusCode == 304) {
        _logger.d('Feed not modified (304) for "${sub.title}"');
        _onDiagnostic('feed-sync:not-modified', {
          'path': 'foreground',
          'podcastId': sub.id,
          'title': sub.title,
        });
        final newEtag = response.headers.value('etag');
        final newLastModified = response.headers.value('last-modified');
        await subscriptionRepo.updateHttpCacheHeaders(
          sub.id,
          etag: newEtag ?? sub.httpEtag,
          lastModified: newLastModified ?? sub.httpLastModified,
        );
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

      // Look up preset config for per-group extraction
      final presetConfig = await _ref.read(
        presetByFeedUrlProvider(sub.feedUrl).future,
      );
      final resolver = presetConfig != null ? EpisodeExtractorResolver() : null;

      // Parse with progress and batch storage
      var newEpisodeCount = 0;
      var stoppedEarly = false;
      final observedGuids = <String>{};
      await for (final progress in feedParser.parseWithProgress(
        xmlContent: xmlContent,
        podcastId: sub.id,
        knownGuids: knownGuids,
        onBatchReady: (episodes, mediaMetas) async {
          // The parser calls back between progress events, so a batch can
          // arrive after the loop below decided to break.
          if (cancelToken.isCancelled) return;
          observedGuids.addAll(episodes.map((e) => e.guid));
          // Apply per-group extractor resolution if pattern config
          // is available.
          if (resolver != null) {
            for (final episode in episodes) {
              final extractor = resolver.resolve(
                episode.title,
                episode.description,
                presetConfig!,
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
        // Returning from inside the loop also cancels the parser stream.
        if (cancelToken.isCancelled) return _cancelledResult(sub);
        if (progress is FeedMetaReady) {
          // Cosmetic metadata must not fail the sync: without this guard a
          // failed write would abort the loop before drop detection, the
          // cache headers, and lastRefreshedAt, so the feed stops converging.
          // Use catch (e, st) instead of on Exception: Isar throws Error
          // subclasses, not Exception, on database failures.
          try {
            await metadataUpdater.applyFeedMeta(sub, progress);
          } catch (e, st) {
            _logger.w(
              'Metadata backfill failed for "${sub.title}"; sync continues',
              error: e,
              stackTrace: st,
            );
          }
        }
        if (progress is FeedParseComplete) {
          newEpisodeCount = progress.total;
          stoppedEarly = progress.stoppedEarly;
          observedGuids.addAll(progress.tailGuids);
          _onDiagnostic('feed-sync:parse-complete', {
            'path': 'foreground',
            'podcastId': sub.id,
            'title': sub.title,
            'stoppedEarly': progress.stoppedEarly,
            'knownGuidsCount': knownGuids.length,
            'observedGuidsCount': observedGuids.length,
            'tailGuidsCount': progress.tailGuids.length,
            'newEpisodeCount': newEpisodeCount,
          });
        }
      }

      // Remove episodes whose GUIDs are no longer in the feed. Mirrors the
      // logic in FeedSyncExecutor so the foreground and background paths
      // stay consistent. RSS is the source of truth; no protection is
      // applied. Synthetic IDs are skipped when parsing stopped early
      // because the tail scan cannot match them.
      if (observedGuids.isNotEmpty) {
        final droppedBefore = knownGuids.difference(observedGuids);
        var droppedGuids = droppedBefore;
        if (stoppedEarly) {
          droppedGuids = droppedGuids
              .where((g) => !g.startsWith('unknown-'))
              .toSet();
        }

        _onDiagnostic('feed-sync:drop-candidates', {
          'path': 'foreground',
          'podcastId': sub.id,
          'title': sub.title,
          'stoppedEarly': stoppedEarly,
          'droppedBeforeSyntheticFilter': droppedBefore.length,
          'droppedAfterSyntheticFilter': droppedGuids.length,
          'sampleDroppedGuids': droppedGuids.take(5).toList(),
        });

        if (droppedGuids.isNotEmpty) {
          final deleted = await episodeRepo.deleteByPodcastIdAndGuids(
            sub.id,
            droppedGuids,
          );
          _logger.i('Removed $deleted dropped episodes from "${sub.title}"');
          _onDiagnostic('feed-sync:drop-result', {
            'path': 'foreground',
            'podcastId': sub.id,
            'title': sub.title,
            'requested': droppedGuids.length,
            'deleted': deleted,
          });
        }
      }

      // Persist HTTP cache headers only after successful parse + upsert.
      // Always update so previously stored values are cleared when headers
      // are no longer sent by the server.
      await subscriptionRepo.updateHttpCacheHeaders(
        sub.id,
        etag: etag,
        lastModified: lastModified,
      );

      // Update lastRefreshedAt
      await subscriptionRepo.updateLastRefreshed(sub.itunesId, DateTime.now());

      // Invalidate smart playlist providers to pick up new episodes
      _ref.invalidate(podcastSmartPlaylistsProvider(sub.id));

      // Process auto-downloads for any pending episodes (covers both new
      // episodes from this sync and any leftover from a previous sync that
      // ran on a different code path).
      final settingsRepo = _ref.read(appSettingsRepositoryProvider);
      final enqueuer = _ref.read(autoDownloadEnqueuerProvider);
      await enqueuer.enqueueForSubscription(
        sub,
        wifiOnly: settingsRepo.getWifiOnlyDownload(),
      );

      _logger.i('Synced "${sub.title}": $newEpisodeCount episodes processed');

      return SingleFeedSyncResult(
        podcastId: sub.id,
        success: true,
        skipped: false,
        newEpisodeCount: newEpisodeCount,
      );
    } catch (e, stack) {
      if (e is DioException && e.type == DioExceptionType.cancel) {
        return _cancelledResult(sub);
      }
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

  /// Syncs [subscriptions] and tallies the outcomes.
  ///
  /// Runs at most [_maxConcurrentFeedSyncs] at a time. Workers pull from a
  /// shared queue rather than splitting the list into fixed chunks, so one
  /// slow feed cannot hold back the rest.
  ///
  /// The whole batch shares the caller's cancel token: a [suspend] must
  /// stop workers from pulling the next feed, not only abort the fetches
  /// that were running when it landed.
  Future<FeedSyncResult> _syncSubscriptions(
    List<Subscription> subscriptions, {
    required bool forceRefresh,
    required CancelToken cancelToken,
  }) async {
    final pending = Queue<Subscription>.of(subscriptions);
    final results = <SingleFeedSyncResult>[];

    Future<void> drainQueue() async {
      while (pending.isNotEmpty && !cancelToken.isCancelled) {
        final sub = pending.removeFirst();
        results.add(
          await _syncFeed(
            sub,
            forceRefresh: forceRefresh,
            cancelToken: cancelToken,
          ),
        );
      }
    }

    final workerCount = min(_maxConcurrentFeedSyncs, subscriptions.length);
    await Future.wait([for (var i = 0; i < workerCount; i++) drainQueue()]);

    return FeedSyncResult(
      totalCount: results.length,
      successCount: results.where((r) => r.success).length,
      skipCount: results.where((r) => r.skipped).length,
      errorCount: results.where((r) => !r.success && !r.skipped).length,
    );
  }

  /// A sync that [suspend] stopped before it wrote anything.
  ///
  /// Reported as skipped rather than failed: nothing went wrong with the
  /// feed, and the caller asked for the sync to stop.
  SingleFeedSyncResult _cancelledResult(Subscription sub) {
    _logger.d('Sync cancelled for "${sub.title}"');
    return SingleFeedSyncResult(
      podcastId: sub.id,
      success: false,
      skipped: true,
      errorMessage: 'Sync cancelled',
    );
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
