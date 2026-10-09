import 'package:logger/logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../common/providers/database_provider.dart';
import '../../../common/providers/logger_provider.dart';
import '../../monitoring/models/analytics_event.dart';
import '../../monitoring/providers/analytics_providers.dart';
import '../../monitoring/services/analytics_service.dart';
import '../../parental_control/providers/parental_control_providers.dart';
import '../../parental_control/repositories/parental_control_repository.dart';
import '../../station/services/station_reconciler_service.dart';
import '../../subscription/models/subscriptions.dart';
import '../datasources/local/subscription_local_datasource.dart';
import 'subscription_repository.dart';

part 'subscription_repository_impl.g.dart';

/// Provides a singleton [SubscriptionRepository] instance.
@Riverpod(keepAlive: true)
SubscriptionRepository subscriptionRepository(Ref ref) {
  final isar = ref.watch(isarProvider);
  final datasource = SubscriptionLocalDatasource(isar);
  final reconcilerService = ref.watch(stationReconcilerServiceProvider);
  final analytics = ref.watch(analyticsServiceProvider);
  final parentalControl = ref.watch(parentalControlRepositoryProvider);
  final logger = ref.watch(namedLoggerProvider('Subscription'));
  return SubscriptionRepositoryImpl(
    datasource: datasource,
    reconcilerService: reconcilerService,
    analytics: analytics,
    parentalControlRepository: parentalControl,
    logger: logger,
  );
}

/// Implementation of [SubscriptionRepository] using Isar database.
class SubscriptionRepositoryImpl implements SubscriptionRepository {
  SubscriptionRepositoryImpl({
    required this._datasource,
    this._reconcilerService,
    this._analytics,
    this._parentalControlRepository,
    this._logger,
  });

  final SubscriptionLocalDatasource _datasource;
  final StationReconcilerService? _reconcilerService;
  final AnalyticsService? _analytics;
  final ParentalControlRepository? _parentalControlRepository;
  final Logger? _logger;

  @override
  Future<Subscription> subscribe({
    required String itunesId,
    required String feedUrl,
    required String title,
    required String artistName,
    String? artworkUrl,
    String? description,
    List<String> genres = const <String>[],
    bool explicit = false,
    SubscribeSource source = SubscribeSource.unknown,
  }) async {
    final incoming = Subscription()
      ..itunesId = itunesId
      ..feedUrl = feedUrl
      ..title = title
      ..artistName = artistName
      ..artworkUrl = artworkUrl
      ..description = description
      ..genres = genres.join(',')
      ..explicit = explicit
      ..subscribedAt = DateTime.now();

    final saved =
        await _promoteCached(incoming) ?? await _datasource.insert(incoming);
    await _analytics?.log(
      PodcastSubscribed(
        podcastId:
            analyticsPodcastId(itunesId: itunesId, feedUrl: feedUrl) ?? feedUrl,
        feedUrl: feedUrl,
        podcastTitle: title,
        source: source,
      ),
    );
    return saved;
  }

  /// Promotes this podcast's cached entry, matched by iTunes ID or else by
  /// feed URL: an OPML import stores a placeholder iTunes ID, so the same
  /// feed can come back under another one after an unsubscribe.
  Future<Subscription?> _promoteCached(Subscription incoming) async {
    final existing =
        await _datasource.getByItunesId(incoming.itunesId) ??
        await _datasource.getByFeedUrl(incoming.feedUrl);
    if (existing == null || !existing.isCached) return null;
    // Null after a concurrent eviction; the caller then inserts afresh.
    return _datasource.promoteCached(existing.id, incoming);
  }

  @override
  Future<void> unsubscribe(String itunesId) async {
    final demoted = await _datasource.demoteToCached(itunesId);
    if (demoted == null) {
      throw SubscriptionNotFoundException(itunesId);
    }
    // Only subscribed podcasts belong to a station (FR 07).
    await _bestEffort(
      'stationReconciler.onSubscriptionRemoved',
      demoted.id,
      () async => _reconcilerService?.onSubscriptionRemoved(demoted.id),
    );
    await _bestEffort(
      'parentalControl.pruneFlagsFor',
      demoted.id,
      () async => _parentalControlRepository?.pruneFlagsFor(demoted.id),
    );
    await _analytics?.log(
      PodcastUnsubscribed(
        podcastId:
            analyticsPodcastId(
              itunesId: demoted.itunesId,
              feedUrl: demoted.feedUrl,
            ) ??
            demoted.feedUrl,
        feedUrl: demoted.feedUrl,
        podcastTitle: demoted.title,
      ),
    );
  }

  /// Runs a side effect of removing a subscription that must not undo the
  /// removal.
  ///
  /// Catches everything rather than `on Exception` because Isar can throw
  /// Error subclasses (not Exception) on database failures.
  Future<void> _bestEffort(
    String operation,
    int id,
    Future<void> Function() action,
  ) async {
    try {
      await action();
    } catch (e, st) {
      _logger?.w(
        '$operation failed for id=$id; continuing',
        error: e,
        stackTrace: st,
      );
    }
  }

  @override
  Future<bool> isSubscribed(String itunesId) {
    return _datasource.exists(itunesId);
  }

  @override
  Future<bool> isSubscribedByFeedUrl(String feedUrl) {
    return _datasource.existsByFeedUrl(feedUrl);
  }

  @override
  Future<List<Subscription>> getSubscriptions() {
    return _datasource.getAll();
  }

  @override
  Stream<List<Subscription>> watchSubscriptions() {
    return _datasource.watchAll();
  }

  @override
  Future<Subscription?> getSubscription(String itunesId) {
    return _datasource.getByItunesId(itunesId);
  }

  @override
  Future<Subscription?> getByFeedUrl(String feedUrl) {
    return _datasource.getByFeedUrl(feedUrl);
  }

  @override
  Future<Subscription?> getById(int id) {
    return _datasource.getById(id);
  }

  @override
  Future<void> updateLastRefreshed(String itunesId, DateTime timestamp) async {
    await _datasource.updateLastRefreshed(itunesId, timestamp);
  }

  @override
  Future<Subscription> getOrCreateCached({
    required String itunesId,
    required String feedUrl,
    required String title,
    required String artistName,
    String? artworkUrl,
    String? description,
    List<String> genres = const <String>[],
    bool explicit = false,
  }) {
    return _datasource.getOrCreateCached(
      itunesId: itunesId,
      feedUrl: feedUrl,
      title: title,
      artistName: artistName,
      artworkUrl: artworkUrl,
      description: description,
      genres: genres.join(','),
      explicit: explicit,
    );
  }

  @override
  Future<Subscription?> promoteToSubscribed(String itunesId) {
    return _datasource.promoteToSubscribed(itunesId);
  }

  @override
  Future<void> updateLastAccessed(int id) {
    return _datasource.updateLastAccessed(id, DateTime.now());
  }

  @override
  Future<List<Subscription>> getCachedSubscriptions() {
    return _datasource.getCachedSubscriptions();
  }

  @override
  Future<bool> deleteById(int id) async {
    final deleted = await _datasource.deleteById(id);
    if (deleted) {
      // id IS the podcastId (Isar auto-increment).
      await _bestEffort(
        'stationReconciler.onSubscriptionRemoved',
        id,
        () async => _reconcilerService?.onSubscriptionRemoved(id),
      );
    }
    return deleted;
  }

  @override
  Future<void> updateAutoDownload(int id, {required bool autoDownload}) {
    return _datasource.updateAutoDownload(id, autoDownload: autoDownload);
  }

  @override
  Future<bool> recordAutoDownloads(
    int id,
    int count, {
    required int pauseThreshold,
    required DateTime at,
  }) {
    return _datasource.recordAutoDownloads(
      id,
      count,
      pauseThreshold: pauseThreshold,
      at: at,
    );
  }

  @override
  Future<void> resetAutoDownloadActivity(int id) {
    return _datasource.resetAutoDownloadActivity(id);
  }

  @override
  Future<void> updateAutoDownloadKeepCount(int id, int? keepCount) {
    return _datasource.updateAutoDownloadKeepCount(id, keepCount);
  }

  @override
  Future<void> updateDescription(int id, String? description) {
    return _datasource.updateDescription(id, description);
  }

  @override
  Future<void> updateWebsiteUrl(
    int id,
    String? websiteUrl, {
    required DateTime syncedAt,
  }) {
    return _datasource.updateWebsiteUrl(id, websiteUrl, syncedAt: syncedAt);
  }

  @override
  Future<void> updateFeedMetadata(
    int id, {
    String? artworkUrl,
    String? artistName,
    String? description,
    DateTime? syncedAt,
  }) {
    return _datasource.updateFeedMetadata(
      id,
      artworkUrl: artworkUrl,
      artistName: artistName,
      description: description,
      syncedAt: syncedAt,
    );
  }

  @override
  Future<void> updateHttpCacheHeaders(
    int id, {
    String? etag,
    String? lastModified,
  }) {
    return _datasource.updateHttpCacheHeaders(
      id,
      etag: etag,
      lastModified: lastModified,
    );
  }

  @override
  Future<void> clearAllHttpCacheHeaders() {
    return _datasource.clearAllHttpCacheHeaders();
  }
}
