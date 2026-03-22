import 'package:audiflow_domain/audiflow_domain.dart';

/// In-memory fake [SubscriptionRepository] for share service tests.
///
/// Supports seeding subscriptions by id and itunesId via [addSubscription].
class FakeSubscriptionRepository implements SubscriptionRepository {
  final List<Subscription> _subscriptions = [];

  /// Seeds a subscription with the given fields.
  void addSubscription({
    required int id,
    required String itunesId,
    String feedUrl = 'https://example.com/feed.rss',
    String title = 'Test Podcast',
    String? artworkUrl,
  }) {
    final subscription = Subscription()
      ..id = id
      ..itunesId = itunesId
      ..feedUrl = feedUrl
      ..title = title
      ..artistName = 'Test Artist'
      ..artworkUrl = artworkUrl
      ..subscribedAt = DateTime(2024);
    _subscriptions.add(subscription);
  }

  @override
  Future<Subscription?> getById(int id) async {
    return _subscriptions.where((s) => s.id == id).firstOrNull;
  }

  @override
  Future<List<Subscription>> getSubscriptions() async {
    return _subscriptions.where((s) => !s.isCached).toList();
  }

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
  Future<Subscription?> getSubscription(String itunesId) async {
    return _subscriptions.where((s) => s.itunesId == itunesId).firstOrNull;
  }

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
}
