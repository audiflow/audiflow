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

  /// Returns all subscriptions ordered by subscription date (newest first).
  Future<List<Subscription>> getAll() {
    return _isar.subscriptions.where().sortBySubscribedAtDesc().findAll();
  }

  /// Watches all subscriptions, emitting updates when data changes.
  Stream<List<Subscription>> watchAll() {
    return _isar.subscriptions.where().sortBySubscribedAtDesc().watch(
      fireImmediately: true,
    );
  }

  /// Returns a subscription by its iTunes ID, or null if not found.
  Future<Subscription?> getByItunesId(String itunesId) {
    return _isar.subscriptions.getByItunesId(itunesId);
  }

  /// Returns true if a subscription exists for the given iTunes ID.
  Future<bool> exists(String itunesId) async {
    final result = await getByItunesId(itunesId);
    return result != null;
  }

  /// Returns true if a subscription exists for the given feed URL.
  Future<bool> existsByFeedUrl(String feedUrl) async {
    final result = await getByFeedUrl(feedUrl);
    return result != null;
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
}
