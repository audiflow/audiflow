import '../../monitoring/models/analytics_event.dart';
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
    SubscribeSource source,
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

  /// Updates the auto-download setting for a subscription. Turning it on
  /// clears any inactivity pause and restarts the inactivity count.
  Future<void> updateAutoDownload(int id, {required bool autoDownload});

  /// Adds [count] to the auto-downloads created since the podcast was last
  /// played and, once the total reaches [pauseThreshold], pauses its
  /// auto-download as of [at]. Both happen atomically, so a concurrent
  /// playback reset cannot be followed by a stale pause. Returns true when
  /// this call paused it.
  Future<bool> recordAutoDownloads(
    int id,
    int count, {
    required int pauseThreshold,
    required DateTime at,
  });

  /// Clears the inactivity pause and count after the podcast is played.
  Future<void> resetAutoDownloadActivity(int id);

  /// Sets the per-podcast auto-download keep count; null follows the
  /// global setting.
  Future<void> updateAutoDownloadKeepCount(int id, int? keepCount);

  /// Updates the description for a subscription. Used to persist
  /// RSS-parsed descriptions so they survive 304 Not Modified cache hits.
  Future<void> updateDescription(int id, String? description);

  /// Records that the channel `<link>` was read at [syncedAt], storing
  /// [websiteUrl] so it survives 304 Not Modified cache hits. A null
  /// [websiteUrl] keeps the stored website.
  Future<void> updateWebsiteUrl(
    int id,
    String? websiteUrl, {
    required DateTime syncedAt,
  });

  /// Updates the podcast metadata a feed refresh parsed from the RSS channel.
  ///
  /// Only non-null arguments are written; a null argument leaves the stored
  /// value untouched. Callers pass null for fields the channel did not
  /// change, so an OPML-imported subscription can be filled in without
  /// clearing anything a podcast search already supplied.
  ///
  /// [syncedAt] records that the channel was read, so a feed carrying no
  /// artwork stops forcing unconditional requests.
  Future<void> updateFeedMetadata(
    int id, {
    String? artworkUrl,
    String? artistName,
    String? description,
    DateTime? syncedAt,
  });

  /// Updates HTTP cache headers (ETag / Last-Modified) for a subscription.
  ///
  /// Used by conditional requests (If-None-Match / If-Modified-Since)
  /// to avoid re-downloading unchanged RSS feeds.
  Future<void> updateHttpCacheHeaders(
    int id, {
    String? etag,
    String? lastModified,
  });

  /// Clears HTTP cache headers on all subscriptions.
  Future<void> clearAllHttpCacheHeaders();
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
