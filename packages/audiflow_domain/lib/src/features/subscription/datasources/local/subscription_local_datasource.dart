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

  /// Promotes the cached entry [id] to a real subscription, taking the
  /// identity and metadata of [incoming]. Blank metadata keeps the stored
  /// value, so a sparse source such as an OPML import never erases details
  /// an earlier feed read supplied.
  ///
  /// Returns the promoted subscription, or null when [id] is missing or not
  /// a cached entry.
  Future<Subscription?> promoteCached(int id, Subscription incoming) {
    // Read inside the transaction, as in [updateLastAccessed].
    return _isar.writeTxn(() async {
      final existing = await _isar.subscriptions.get(id);
      if (existing == null || !existing.isCached) return null;
      existing
        ..itunesId = incoming.itunesId
        ..feedUrl = incoming.feedUrl
        ..title = _nonBlank(incoming.title) ?? existing.title
        ..artistName = _nonBlank(incoming.artistName) ?? existing.artistName
        ..artworkUrl = _nonBlank(incoming.artworkUrl) ?? existing.artworkUrl
        ..description = _nonBlank(incoming.description) ?? existing.description
        ..genres = _nonBlank(incoming.genres) ?? existing.genres
        ..explicit = incoming.explicit
        ..subscribedAt = incoming.subscribedAt
        ..isCached = false;
      await _isar.subscriptions.put(existing);
      return existing;
    });
  }

  static String? _nonBlank(String? value) =>
      (value == null || value.trim().isEmpty) ? null : value;

  /// Demotes a real subscription to a cached entry, keeping its id so the
  /// podcast's episodes and playback history stay attached to it.
  ///
  /// Marks it as accessed now, so cache eviction measures its age from the
  /// unsubscribe. Returns the demoted subscription, or null when no real
  /// subscription exists for [itunesId].
  Future<Subscription?> demoteToCached(String itunesId) {
    // Read inside the transaction, as in [updateLastAccessed].
    return _isar.writeTxn(() async {
      final existing = await _isar.subscriptions.getByItunesId(itunesId);
      if (existing == null || existing.isCached) return null;
      existing
        ..isCached = true
        ..lastAccessedAt = DateTime.now();
      await _isar.subscriptions.put(existing);
      return existing;
    });
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
  ///
  /// Reads inside the transaction: a read taken before it could be stale
  /// by the time the whole object is put back, undoing a feed refresh
  /// that committed in between.
  Future<void> updateLastAccessed(int id, DateTime timestamp) {
    return _isar.writeTxn(() async {
      final existing = await _isar.subscriptions.get(id);
      if (existing == null) return;
      existing.lastAccessedAt = timestamp;
      await _isar.subscriptions.put(existing);
    });
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

  /// Returns subscriptions by their database IDs.
  ///
  /// Order is not guaranteed; caller should index as needed.
  Future<List<Subscription>> getByIds(List<int> ids) async {
    if (ids.isEmpty) return [];
    final results = await _isar.subscriptions.getAll(ids);
    return results.whereType<Subscription>().toList();
  }

  /// Updates a subscription's lastRefreshedAt timestamp.
  ///
  /// Returns 1 if updated, 0 if not found.
  Future<int> updateLastRefreshed(String itunesId, DateTime timestamp) {
    // Read inside the transaction, as in [updateLastAccessed].
    return _isar.writeTxn(() async {
      final existing = await _isar.subscriptions.getByItunesId(itunesId);
      if (existing == null) return 0;
      existing.lastRefreshedAt = timestamp;
      await _isar.subscriptions.put(existing);
      return 1;
    });
  }

  /// Updates the description for a subscription.
  ///
  /// Does nothing if no subscription is found for the given [id].
  Future<void> updateDescription(int id, String? description) {
    // Read inside the transaction, as in [updateLastAccessed].
    return _isar.writeTxn(() async {
      final existing = await _isar.subscriptions.get(id);
      if (existing == null) return;
      existing.description = description;
      await _isar.subscriptions.put(existing);
    });
  }

  /// Records a read of the channel `<link>`, storing [websiteUrl] unless
  /// it is null.
  ///
  /// Does nothing if no subscription is found for the given [id].
  Future<void> updateWebsiteUrl(
    int id,
    String? websiteUrl, {
    required DateTime syncedAt,
  }) {
    return _isar.writeTxn(() async {
      final existing = await _isar.subscriptions.get(id);
      if (existing == null) return;
      existing
        ..websiteUrl = websiteUrl ?? existing.websiteUrl
        ..websiteSyncedAt = syncedAt;
      await _isar.subscriptions.put(existing);
    });
  }

  /// Updates podcast metadata parsed from the RSS channel.
  ///
  /// Null arguments leave the corresponding stored value untouched.
  /// Does nothing if no subscription is found for the given [id].
  ///
  /// Every read happens inside the transaction: a feed sync and a podcast
  /// detail visit can write the same subscription concurrently, and a
  /// snapshot taken outside the transaction would let the later put
  /// resurrect the fields the earlier one just wrote.
  Future<void> updateFeedMetadata(
    int id, {
    String? artworkUrl,
    String? artistName,
    String? description,
    DateTime? syncedAt,
  }) {
    return _isar.writeTxn(() async {
      final existing = await _isar.subscriptions.get(id);
      if (existing == null) return;

      existing
        ..artworkUrl = artworkUrl ?? existing.artworkUrl
        ..artistName = artistName ?? existing.artistName
        ..description = description ?? existing.description
        ..feedMetadataSyncedAt = syncedAt ?? existing.feedMetadataSyncedAt;
      await _isar.subscriptions.put(existing);
    });
  }

  /// Updates the auto-download setting for a subscription.
  ///
  /// Does nothing if no subscription is found for the given [id].
  Future<void> updateAutoDownload(int id, {required bool autoDownload}) {
    return _isar.writeTxn(() async {
      final existing = await _isar.subscriptions.get(id);
      if (existing == null) return;
      existing.autoDownload = autoDownload;
      if (autoDownload) _clearAutoDownloadActivity(existing);
      await _isar.subscriptions.put(existing);
    });
  }

  /// Adds [count] to the auto-downloads since last play and pauses
  /// auto-download once the total reaches [pauseThreshold], all inside one
  /// transaction so foreground and background syncs and playback resets
  /// cannot interleave. Returns true when this call paused it.
  Future<bool> recordAutoDownloads(
    int id,
    int count, {
    required int pauseThreshold,
    required DateTime at,
  }) {
    return _isar.writeTxn(() async {
      final existing = await _isar.subscriptions.get(id);
      if (existing == null) return false;
      existing.autoDownloadsSinceLastPlay += count;
      final pauses =
          existing.autoDownloadPausedAt == null &&
          pauseThreshold <= existing.autoDownloadsSinceLastPlay;
      if (pauses) existing.autoDownloadPausedAt = at;
      await _isar.subscriptions.put(existing);
      return pauses;
    });
  }

  /// Clears the inactivity pause and count. Skips the write when there is
  /// nothing to clear, since this runs on every playback start.
  Future<void> resetAutoDownloadActivity(int id) {
    return _isar.writeTxn(() async {
      final existing = await _isar.subscriptions.get(id);
      if (existing == null) return;
      if (existing.autoDownloadsSinceLastPlay == 0 &&
          existing.autoDownloadPausedAt == null) {
        return;
      }
      _clearAutoDownloadActivity(existing);
      await _isar.subscriptions.put(existing);
    });
  }

  static void _clearAutoDownloadActivity(Subscription subscription) {
    subscription
      ..autoDownloadsSinceLastPlay = 0
      ..autoDownloadPausedAt = null;
  }

  /// Updates the per-podcast auto-download keep count; null follows the
  /// global setting. Does nothing if no subscription is found for [id].
  Future<void> updateAutoDownloadKeepCount(int id, int? keepCount) {
    // Read inside the transaction so a concurrent sync's writes to the same
    // subscription are not overwritten with a stale copy.
    return _isar.writeTxn(() async {
      final existing = await _isar.subscriptions.get(id);
      if (existing == null) return;
      existing.autoDownloadKeepCount = keepCount;
      await _isar.subscriptions.put(existing);
    });
  }

  /// Updates HTTP cache headers for conditional requests.
  ///
  /// Does nothing if no subscription is found for the given [id].
  Future<void> updateHttpCacheHeaders(
    int id, {
    String? etag,
    String? lastModified,
  }) async {
    final existing = await _isar.subscriptions.get(id);
    if (existing == null) return;

    existing
      ..httpEtag = etag
      ..httpLastModified = lastModified;
    await _isar.writeTxn(() => _isar.subscriptions.put(existing));
  }

  /// Clears HTTP cache headers on all subscriptions so the
  /// next feed sync performs unconditional requests.
  Future<void> clearAllHttpCacheHeaders() async {
    final all = await _isar.subscriptions.where().findAll();
    if (all.isEmpty) return;

    for (final sub in all) {
      sub
        ..httpEtag = null
        ..httpLastModified = null;
    }
    await _isar.writeTxn(() => _isar.subscriptions.putAll(all));
  }
}
