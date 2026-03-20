import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../common/providers/database_provider.dart';
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
  return SubscriptionRepositoryImpl(
    datasource: datasource,
    reconcilerService: reconcilerService,
  );
}

/// Implementation of [SubscriptionRepository] using Isar database.
class SubscriptionRepositoryImpl implements SubscriptionRepository {
  SubscriptionRepositoryImpl({
    required SubscriptionLocalDatasource datasource,
    StationReconcilerService? reconcilerService,
  }) : _datasource = datasource,
       _reconcilerService = reconcilerService;

  final SubscriptionLocalDatasource _datasource;
  final StationReconcilerService? _reconcilerService;

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
  }) async {
    // Check for existing cached entry and promote it
    final existing = await _datasource.getByItunesId(itunesId);
    if (existing != null && existing.isCached) {
      final promoted = await _datasource.promoteToSubscribed(itunesId);
      if (promoted != null) return promoted;
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

    return _datasource.insert(subscription);
  }

  @override
  Future<void> unsubscribe(String itunesId) async {
    final rowsDeleted = await _datasource.deleteByItunesId(itunesId);
    if (rowsDeleted == 0) {
      throw SubscriptionNotFoundException(itunesId);
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
}
