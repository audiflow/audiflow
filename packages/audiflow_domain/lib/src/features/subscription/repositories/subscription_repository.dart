import '../models/subscriptions.dart';

/// Repository interface for podcast subscription operations.
///
/// Abstracts the data layer for subscribing/unsubscribing from podcasts.
abstract class SubscriptionRepository {
  /// Subscribes to a podcast.
  ///
  /// Creates a new subscription record with the provided podcast metadata.
  /// Returns the created [Subscription] with auto-generated id.
  Future<Subscription> subscribe({
    required String itunesId,
    required String feedUrl,
    required String title,
    required String artistName,
    String? artworkUrl,
    String? description,
    List<String> genres,
    bool explicit,
  });

  /// Unsubscribes from a podcast by its iTunes ID.
  ///
  /// Throws [SubscriptionNotFoundException] if the subscription doesn't exist.
  Future<void> unsubscribe(String itunesId);

  /// Returns whether the user is subscribed to a podcast.
  Future<bool> isSubscribed(String itunesId);

  /// Returns whether the user is subscribed to a podcast by feed URL.
  Future<bool> isSubscribedByFeedUrl(String feedUrl);

  /// Returns all subscriptions ordered by subscription date (newest first).
  Future<List<Subscription>> getSubscriptions();

  /// Watches all subscriptions, emitting updates when data changes.
  Stream<List<Subscription>> watchSubscriptions();

  /// Returns a subscription by its iTunes ID, or null if not found.
  Future<Subscription?> getSubscription(String itunesId);

  /// Returns a subscription by its feed URL, or null if not found.
  Future<Subscription?> getByFeedUrl(String feedUrl);

  /// Returns a subscription by its database ID, or null if not found.
  Future<Subscription?> getById(int id);

  /// Updates a subscription's lastRefreshedAt timestamp.
  Future<void> updateLastRefreshed(String itunesId, DateTime timestamp);

  /// Returns or creates a cached subscription entry.
  ///
  /// If a subscription already exists for [itunesId], returns it.
  /// Otherwise creates a new entry with [isCached] = true.
  Future<Subscription> getOrCreateCached({
    required String itunesId,
    required String feedUrl,
    required String title,
    required String artistName,
    String? artworkUrl,
    String? description,
    List<String> genres,
    bool explicit,
  });

  /// Promotes a cached subscription to a real subscription.
  ///
  /// Sets [isCached] = false and updates [subscribedAt] to now.
  /// Returns the promoted subscription, or null if not found.
  Future<Subscription?> promoteToSubscribed(String itunesId);

  /// Updates the [lastAccessedAt] timestamp for a subscription.
  Future<void> updateLastAccessed(int id);

  /// Returns all cached (non-subscribed) subscriptions ordered
  /// by lastAccessedAt ascending.
  Future<List<Subscription>> getCachedSubscriptions();

  /// Deletes a subscription by its database ID.
  Future<bool> deleteById(int id);

  /// Updates the auto-download setting for a subscription.
  Future<void> updateAutoDownload(int id, {required bool autoDownload});
}

/// Exception thrown when a subscription operation fails.
class SubscriptionException implements Exception {
  SubscriptionException(this.message);

  final String message;

  @override
  String toString() => 'SubscriptionException: $message';
}

/// Exception thrown when attempting to unsubscribe from a non-existent
/// subscription.
class SubscriptionNotFoundException extends SubscriptionException {
  SubscriptionNotFoundException(String itunesId)
    : super('Subscription not found for iTunes ID: $itunesId');
}
