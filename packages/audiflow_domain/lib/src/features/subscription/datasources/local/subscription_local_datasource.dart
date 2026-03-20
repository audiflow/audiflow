import 'package:isar_community/isar.dart';

import '../../models/subscriptions.dart';

/// Local datasource for subscription operations using Isar.
///
/// Provides CRUD operations for the Subscription collection.
class SubscriptionLocalDatasource {
  SubscriptionLocalDatasource(this._isar);

  final Isar _isar;

  /// Inserts a new subscription into the database.
  ///
  /// Returns the inserted [Subscription] with its auto-generated id.
  Future<Subscription> insert(Subscription subscription) async {
    await _isar.writeTxn(() async {
      await _isar.subscriptions.put(subscription);
    });
    return subscription;
  }

  /// Deletes a subscription by its iTunes ID.
  ///
  /// Returns the number of rows affected.
  Future<int> deleteByItunesId(String itunesId) async {
    return _isar.writeTxn(
      () => _isar.subscriptions.filter().itunesIdEqualTo(itunesId).deleteAll(),
    );
  }

  /// Returns all real subscriptions (excludes cached entries),
  /// ordered by subscription date (newest first).
  ///
  /// Uses negated filter `not().isCachedEqualTo(true)` to
  /// safely match pre-existing records that may not have the
  /// isCached field written yet after schema migration.
  Future<List<Subscription>> getAll() {
    return _isar.subscriptions
        .filter()
        .not()
        .isCachedEqualTo(true)
        .sortBySubscribedAtDesc()
        .findAll();
  }

  /// Watches all real subscriptions (excludes cached entries),
  /// emitting updates when data changes.
  Stream<List<Subscription>> watchAll() {
    return _isar.subscriptions
        .filter()
        .not()
        .isCachedEqualTo(true)
        .sortBySubscribedAtDesc()
        .watch(fireImmediately: true);
  }

  /// Returns or creates a cached subscription entry.
  ///
  /// If a subscription (cached or real) already exists for the
  /// given [itunesId], returns it. Otherwise creates a new
  /// cached entry with [isCached] = true.
  Future<Subscription> getOrCreateCached({
    required String itunesId,
    required String feedUrl,
    required String title,
    required String artistName,
    String? artworkUrl,
    String? description,
    String genres = '',
    bool explicit = false,
  }) async {
    final existing = await getByItunesId(itunesId);
    if (existing != null) {
      return existing;
    }

    final subscription = Subscription()
      ..itunesId = itunesId
      ..feedUrl = feedUrl
      ..title = title
      ..artistName = artistName
      ..artworkUrl = artworkUrl
      ..description = description
      ..genres = genres
      ..explicit = explicit
      ..subscribedAt = DateTime.now()
      ..isCached = true
      ..lastAccessedAt = DateTime.now();

    await _isar.writeTxn(() async {
      await _isar.subscriptions.put(subscription);
    });
    return subscription;
  }

  /// Promotes a cached subscription to a real subscription.
  ///
  /// Sets [isCached] to false and updates [subscribedAt].
  /// Returns the updated subscription, or null if not found.
  Future<Subscription?> promoteToSubscribed(String itunesId) async {
    final existing = await getByItunesId(itunesId);
    if (existing == null) return null;

    existing
      ..isCached = false
      ..subscribedAt = DateTime.now();
    await _isar.writeTxn(() => _isar.subscriptions.put(existing));
    return existing;
  }

  /// Updates the [lastAccessedAt] timestamp for a subscription.
  Future<void> updateLastAccessed(int id, DateTime timestamp) async {
    final existing = await _isar.subscriptions.get(id);
    if (existing == null) return;

    existing.lastAccessedAt = timestamp;
    await _isar.writeTxn(() => _isar.subscriptions.put(existing));
  }

  /// Returns all cached subscriptions ordered by lastAccessedAt
  /// ascending (oldest first).
  Future<List<Subscription>> getCachedSubscriptions() {
    return _isar.subscriptions
        .filter()
        .isCachedEqualTo(true)
        .sortByLastAccessedAt()
        .findAll();
  }

  /// Deletes a subscription by its database ID.
  Future<bool> deleteById(int id) async {
    return _isar.writeTxn(() => _isar.subscriptions.delete(id));
  }

  /// Returns a subscription by its iTunes ID, or null if not found.
  Future<Subscription?> getByItunesId(String itunesId) {
    return _isar.subscriptions.getByItunesId(itunesId);
  }

  /// Returns true if a real (non-cached) subscription exists
  /// for the given iTunes ID.
  Future<bool> exists(String itunesId) async {
    final result = await getByItunesId(itunesId);
    return result != null && !result.isCached;
  }

  /// Returns true if a real (non-cached) subscription exists
  /// for the given feed URL.
  Future<bool> existsByFeedUrl(String feedUrl) async {
    final result = await getByFeedUrl(feedUrl);
    return result != null && !result.isCached;
  }

  /// Returns a subscription by its feed URL, or null if not found.
  Future<Subscription?> getByFeedUrl(String feedUrl) {
    return _isar.subscriptions.filter().feedUrlEqualTo(feedUrl).findFirst();
  }

  /// Returns a subscription by its database ID, or null if not found.
  Future<Subscription?> getById(int id) {
    return _isar.subscriptions.get(id);
  }

  /// Updates a subscription's lastRefreshedAt timestamp.
  ///
  /// Returns 1 if updated, 0 if not found.
  Future<int> updateLastRefreshed(String itunesId, DateTime timestamp) async {
    final existing = await _isar.subscriptions.getByItunesId(itunesId);
    if (existing == null) return 0;

    existing.lastRefreshedAt = timestamp;
    await _isar.writeTxn(() => _isar.subscriptions.put(existing));
    return 1;
  }

  /// Updates the auto-download setting for a subscription.
  ///
  /// Does nothing if no subscription is found for the given [id].
  Future<void> updateAutoDownload(int id, {required bool autoDownload}) async {
    final existing = await _isar.subscriptions.get(id);
    if (existing == null) return;

    existing.autoDownload = autoDownload;
    await _isar.writeTxn(() => _isar.subscriptions.put(existing));
  }
}
