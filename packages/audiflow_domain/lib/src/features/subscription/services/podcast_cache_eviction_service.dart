import 'package:isar_community/isar.dart';
import 'package:logger/logger.dart';

import '../../download/models/download_task.dart';
import '../../feed/models/episode.dart';
import '../../feed/models/podcast_view_preference.dart';
import '../../feed/models/smart_playlist_groups.dart';
import '../../feed/models/smart_playlists.dart';
import '../../player/models/playback_history.dart';
import '../models/subscriptions.dart';
import '../repositories/subscription_repository.dart';

/// Evicts stale cached podcast subscriptions to limit storage.
///
/// Cached subscriptions are created when users visit non-subscribed
/// podcasts, and when they unsubscribe. This service removes entries that
/// haven't been accessed recently and hold no playback history, cascading
/// deletes to episodes, smart playlists, groups, and view preferences.
class PodcastCacheEvictionService {
  PodcastCacheEvictionService({
    required SubscriptionRepository subscriptionRepository,
    required this._isar,
    required this._logger,
    this.maxAge = const Duration(days: 7),
    this.maxCachedPodcasts = 20,
  }) : _subscriptionRepo = subscriptionRepository;

  final SubscriptionRepository _subscriptionRepo;
  final Isar _isar;
  final Logger _logger;

  /// Maximum age before a cached subscription is evicted.
  final Duration maxAge;

  /// Maximum number of cached podcasts to retain.
  final int maxCachedPodcasts;

  /// Runs the eviction pass.
  ///
  /// Cached podcasts holding listener data -- playback history or downloads
  /// -- are never evicted and do not count toward the cap: an unsubscribed
  /// podcast is demoted to a cached entry so that resubscribing finds that
  /// data again, and deleting its episodes would orphan the downloads.
  ///
  /// 1. Evicts cached subscriptions older than [maxAge].
  /// 2. If more than [maxCachedPodcasts] remain, evicts the
  ///    oldest-accessed entries until within the cap.
  Future<int> evict() async {
    var evicted = 0;
    final cached = await _evictableSubscriptions();
    if (cached.isEmpty) return 0;

    _logger.i('Cache eviction: ${cached.length} evictable cached podcasts');

    final now = DateTime.now();
    final remaining = <Subscription>[];

    // Phase 1: Evict stale entries
    for (final sub in cached) {
      final lastAccessed = sub.lastAccessedAt ?? sub.subscribedAt;
      final age = now.difference(lastAccessed);
      if (maxAge <= age) {
        if (await _evictSubscription(sub)) evicted++;
      } else {
        remaining.add(sub);
      }
    }

    // Phase 2: Enforce cap on remaining cached entries
    // Sort in-memory to handle null lastAccessedAt consistently
    remaining.sort((a, b) {
      final aTime = a.lastAccessedAt ?? a.subscribedAt;
      final bTime = b.lastAccessedAt ?? b.subscribedAt;
      return aTime.compareTo(bTime);
    });
    if (maxCachedPodcasts < remaining.length) {
      final toEvict = remaining.length - maxCachedPodcasts;
      for (var i = 0; i < toEvict; i++) {
        if (await _evictSubscription(remaining[i])) evicted++;
      }
    }

    if (0 < evicted) {
      _logger.i('Cache eviction: removed $evicted entries');
    }

    return evicted;
  }

  Future<List<Subscription>> _evictableSubscriptions() async {
    final cached = await _subscriptionRepo.getCachedSubscriptions();
    final evictable = <Subscription>[];
    for (final sub in cached) {
      final episodeIds = await _episodeIdsOf(sub.id);
      if (!await _holdsListenerData(episodeIds)) evictable.add(sub);
    }
    return evictable;
  }

  Future<List<int>> _episodeIdsOf(int podcastId) {
    return _isar.episodes
        .filter()
        .podcastIdEqualTo(podcastId)
        .idProperty()
        .findAll();
  }

  Future<bool> _holdsListenerData(List<int> episodeIds) async {
    if (episodeIds.isEmpty) return false;
    final histories = await _isar.playbackHistorys.getAllByEpisodeId(
      episodeIds,
    );
    if (histories.any((history) => history != null)) return true;
    final downloads = await _isar.downloadTasks.getAllByEpisodeId(episodeIds);
    return downloads.any((download) => download != null);
  }

  /// Returns false when the podcast gained listener data after it was
  /// classified as evictable, e.g. playback started during the pass.
  Future<bool> _evictSubscription(Subscription subscription) async {
    final id = subscription.id;
    _logger.d(
      'Evicting cached podcast: '
      '${subscription.title} (id=$id)',
    );

    return _isar.writeTxn(() async {
      // Re-check inside the transaction so no write can land in between.
      if (await _holdsListenerData(await _episodeIdsOf(id))) return false;

      // Delete episodes
      await _isar.episodes.filter().podcastIdEqualTo(id).deleteAll();

      // Delete view preferences
      await _isar.podcastViewPreferences
          .filter()
          .podcastIdEqualTo(id)
          .deleteAll();

      // Delete smart playlist groups
      await _isar.smartPlaylistGroupEntitys
          .filter()
          .podcastIdEqualTo(id)
          .deleteAll();

      // Delete smart playlists
      await _isar.smartPlaylistEntitys
          .filter()
          .podcastIdEqualTo(id)
          .deleteAll();

      // Delete the subscription itself
      await _isar.subscriptions.delete(id);
      return true;
    });
  }
}
