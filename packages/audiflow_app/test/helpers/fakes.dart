import 'package:audiflow_core/audiflow_core.dart' show AutoPlayOrder;
import 'package:audiflow_domain/audiflow_domain.dart';

/// Fake [SubscriptionRepository] backed by an in-memory list.
class FakeSubscriptionRepository implements SubscriptionRepository {
  FakeSubscriptionRepository({this.subscriptions = const []});

  final List<Subscription> subscriptions;

  @override
  Future<Subscription?> getById(int id) async {
    return subscriptions.where((s) => s.id == id).firstOrNull;
  }

  @override
  Future<List<Subscription>> getSubscriptions() async {
    return subscriptions.where((s) => !s.isCached).toList();
  }

  // -- Methods below are unused by the lookup tests --

  @override
  Future<Subscription> subscribe({
    required String itunesId,
    required String feedUrl,
    required String title,
    required String artistName,
    String? artworkUrl,
    String? description,
    List<String> genres = const [],
    bool explicit = false,
    SubscribeSource source = SubscribeSource.unknown,
  }) => throw UnimplementedError();

  @override
  Future<void> unsubscribe(String itunesId) => throw UnimplementedError();

  @override
  Future<bool> isSubscribed(String itunesId) => throw UnimplementedError();

  @override
  Future<bool> isSubscribedByFeedUrl(String feedUrl) =>
      throw UnimplementedError();

  @override
  Stream<List<Subscription>> watchSubscriptions() => throw UnimplementedError();

  @override
  Future<Subscription?> getSubscription(String itunesId) =>
      throw UnimplementedError();

  @override
  Future<Subscription?> getByFeedUrl(String feedUrl) =>
      throw UnimplementedError();

  @override
  Future<void> updateLastRefreshed(String itunesId, DateTime timestamp) =>
      throw UnimplementedError();

  @override
  Future<Subscription> getOrCreateCached({
    required String itunesId,
    required String feedUrl,
    required String title,
    required String artistName,
    String? artworkUrl,
    String? description,
    List<String> genres = const [],
    bool explicit = false,
  }) => throw UnimplementedError();

  @override
  Future<Subscription?> promoteToSubscribed(String itunesId) =>
      throw UnimplementedError();

  @override
  Future<void> updateLastAccessed(int id) => throw UnimplementedError();

  @override
  Future<List<Subscription>> getCachedSubscriptions() =>
      throw UnimplementedError();

  @override
  Future<bool> deleteById(int id) => throw UnimplementedError();

  @override
  Future<void> updateAutoDownload(int id, {required bool autoDownload}) =>
      throw UnimplementedError();

  @override
  Future<bool> recordAutoDownloads(
    int id,
    int count, {
    required int pauseThreshold,
    required DateTime at,
  }) => throw UnimplementedError();

  @override
  Future<void> resetAutoDownloadActivity(int id) async {
    for (final subscription in subscriptions.where((s) => s.id == id)) {
      subscription
        ..autoDownloadsSinceLastPlay = 0
        ..autoDownloadPausedAt = null;
    }
  }

  @override
  Future<void> updateAutoDownloadKeepCount(int id, int? keepCount) async {
    for (final subscription in subscriptions.where((s) => s.id == id)) {
      subscription.autoDownloadKeepCount = keepCount;
    }
  }

  @override
  Future<void> updateDescription(int id, String? description) =>
      throw UnimplementedError();

  @override
  Future<void> updateFeedMetadata(
    int id, {
    String? artworkUrl,
    String? artistName,
    String? description,
    DateTime? syncedAt,
  }) => throw UnimplementedError();

  @override
  Future<void> updateHttpCacheHeaders(
    int id, {
    String? etag,
    String? lastModified,
  }) => throw UnimplementedError();

  @override
  Future<void> clearAllHttpCacheHeaders() => throw UnimplementedError();
}

/// Play order preferences held in memory; unset podcasts follow the
/// default order.
class FakePlayOrderPreferenceRepository
    implements PlayOrderPreferenceRepository {
  final Map<int, AutoPlayOrder?> podcastOrders = {};

  @override
  Future<AutoPlayOrder?> getPodcastPlayOrder(int podcastId) async =>
      podcastOrders[podcastId];

  @override
  Future<void> setPodcastPlayOrder(int podcastId, AutoPlayOrder? order) async =>
      podcastOrders[podcastId] = order;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
