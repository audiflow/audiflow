import 'package:drift/drift.dart';

import '../../../../common/database/app_database.dart';

/// Local datasource for subscription operations using Drift.
///
/// Provides CRUD operations for the Subscriptions table.
class SubscriptionLocalDatasource {
  SubscriptionLocalDatasource(this._db);

  final AppDatabase _db;

  /// Inserts a new subscription into the database.
  ///
  /// Returns the inserted [Subscription] with its auto-generated id.
  Future<Subscription> insert(SubscriptionsCompanion companion) async {
    final id = await _db.into(_db.subscriptions).insert(companion);
    return _db.subscriptions.findById(id);
  }

  /// Deletes a subscription by its iTunes ID.
  ///
  /// Returns the number of rows affected (1 if deleted, 0 if not found).
  Future<int> deleteByItunesId(String itunesId) {
    return (_db.delete(
      _db.subscriptions,
    )..where((t) => t.itunesId.equals(itunesId))).go();
  }

  /// Returns all subscriptions ordered by subscription date (newest first).
  Future<List<Subscription>> getAll() {
    return (_db.select(_db.subscriptions)..orderBy([
          (t) =>
              OrderingTerm(expression: t.subscribedAt, mode: OrderingMode.desc),
        ]))
        .get();
  }

  /// Watches all subscriptions, emitting updates when data changes.
  Stream<List<Subscription>> watchAll() {
    return (_db.select(_db.subscriptions)..orderBy([
          (t) =>
              OrderingTerm(expression: t.subscribedAt, mode: OrderingMode.desc),
        ]))
        .watch();
  }

  /// Returns a subscription by its iTunes ID, or null if not found.
  Future<Subscription?> getByItunesId(String itunesId) {
    return (_db.select(
      _db.subscriptions,
    )..where((t) => t.itunesId.equals(itunesId))).getSingleOrNull();
  }

  /// Returns true if a subscription exists for the given iTunes ID.
  Future<bool> exists(String itunesId) async {
    final result = await getByItunesId(itunesId);
    return result != null;
  }

  /// Updates a subscription's lastRefreshedAt timestamp.
  Future<int> updateLastRefreshed(String itunesId, DateTime timestamp) {
    return (_db.update(_db.subscriptions)
          ..where((t) => t.itunesId.equals(itunesId)))
        .write(SubscriptionsCompanion(lastRefreshedAt: Value(timestamp)));
  }
}

/// Extension to find subscription by id.
extension SubscriptionByIdExtension on $SubscriptionsTable {
  Future<Subscription> findById(int id) {
    final db = attachedDatabase;
    return (db.select(this)..where((t) => t.id.equals(id))).getSingle();
  }
}
