import 'package:drift/drift.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../common/database/app_database.dart';
import '../../../common/providers/database_provider.dart';
import '../datasources/local/subscription_local_datasource.dart';
import 'subscription_repository.dart';

part 'subscription_repository_impl.g.dart';

/// Provides a singleton [SubscriptionRepository] instance.
@Riverpod(keepAlive: true)
SubscriptionRepository subscriptionRepository(Ref ref) {
  final db = ref.watch(databaseProvider);
  final datasource = SubscriptionLocalDatasource(db);
  return SubscriptionRepositoryImpl(datasource: datasource);
}

/// Implementation of [SubscriptionRepository] using Drift database.
class SubscriptionRepositoryImpl implements SubscriptionRepository {
  SubscriptionRepositoryImpl({required SubscriptionLocalDatasource datasource})
    : _datasource = datasource;

  final SubscriptionLocalDatasource _datasource;

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
    final companion = SubscriptionsCompanion.insert(
      itunesId: itunesId,
      feedUrl: feedUrl,
      title: title,
      artistName: artistName,
      artworkUrl: Value(artworkUrl),
      description: Value(description),
      genres: Value(genres.join(',')),
      explicit: Value(explicit),
      subscribedAt: DateTime.now(),
    );

    return _datasource.insert(companion);
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
}
