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
    required SubscriptionLocalDatasource datasource,
    StationReconcilerService? reconcilerService,
    AnalyticsService? analytics,
    ParentalControlRepository? parentalControlRepository,
    Logger? logger,
  }) : _datasource = datasource,
       _reconcilerService = reconcilerService,
       _analytics = analytics,
       _parentalControlRepository = parentalControlRepository,
       _logger = logger;

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
    // Raw podcast_id: iTunes ID when not OPML-imported, else feedUrl.
    // GA reports read directly without external joins; truncation lives
    // at the event boundary in AnalyticsEvent.params.
    final podcastId = itunesId.startsWith('opml:') ? feedUrl : itunesId;

    // Check for existing cached entry and promote it
    final existing = await _datasource.getByItunesId(itunesId);
    if (existing != null && existing.isCached) {
      final promoted = await _datasource.promoteToSubscribed(itunesId);
      if (promoted != null) {
        await _analytics?.log(
          PodcastSubscribed(
            podcastId: podcastId,
            podcastTitle: title,
            source: source,
          ),
        );
        return promoted;
      }
      // Concurrent delete -- fall through to create fresh
    }

    final subscription = Subscription()
      ..itunesId = itunesId
      ..feedUrl = feedUrl
      ..title = title
      ..artistName = artistName
      ..artworkUrl = artworkUrl
      ..description = description
      ..genres = genres.join(',')
      ..explicit = explicit
      ..subscribedAt = DateTime.now();

    final inserted = await _datasource.insert(subscription);
    await _analytics?.log(
      PodcastSubscribed(
        podcastId: podcastId,
        podcastTitle: title,
        source: source,
      ),
    );
    return inserted;
  }

  @override
  Future<void> unsubscribe(String itunesId) async {
    final existing = await _datasource.getByItunesId(itunesId);
    final rowsDeleted = await _datasource.deleteByItunesId(itunesId);
    if (rowsDeleted == 0) {
      throw SubscriptionNotFoundException(itunesId);
    }
    if (existing != null) {
      final podcastId = existing.itunesId.startsWith('opml:')
          ? existing.feedUrl
          : existing.itunesId;
      await _analytics?.log(
        PodcastUnsubscribed(podcastId: podcastId, podcastTitle: existing.title),
      );
      // Best-effort: remove per-podcast parental control flags.
      // Use catch (e, st) instead of on Exception because Isar can throw
      // Error subclasses (not Exception) on database failures.
      try {
        await _parentalControlRepository?.pruneFlagsFor(existing.id);
      } catch (e, st) {
        _logger?.w(
          'parentalControl.pruneFlagsFor failed for id=${existing.id}; '
          'unsubscribe continues',
          error: e,
          stackTrace: st,
        );
      }
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
      // Best-effort station cleanup — id IS the podcastId (Isar auto-increment).
      try {
        await _reconcilerService?.onSubscriptionDeleted(id);
      } on Exception {
        // Station reconciliation is best-effort; do not break delete flow.
      }
    }
    return deleted;
  }

  @override
  Future<void> updateAutoDownload(int id, {required bool autoDownload}) {
    return _datasource.updateAutoDownload(id, autoDownload: autoDownload);
  }

  @override
  Future<void> updateDescription(int id, String? description) {
    return _datasource.updateDescription(id, description);
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
