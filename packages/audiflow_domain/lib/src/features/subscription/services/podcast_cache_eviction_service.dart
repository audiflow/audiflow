import 'package:isar_community/isar.dart';
import 'package:logger/logger.dart';

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
/// podcasts. This service removes entries that haven't been accessed
/// recently, cascading deletes to episodes, smart playlists, groups,
/// playback history, and view preferences.
class PodcastCacheEvictionService {
  PodcastCacheEvictionService({
    required SubscriptionRepository subscriptionRepository,
    required Isar isar,
    required Logger logger,
    this.maxAge = const Duration(days: 7),
    this.maxCachedPodcasts = 20,
  }) : _subscriptionRepo = subscriptionRepository,
       _isar = isar,
       _logger = logger;

  final SubscriptionRepository _subscriptionRepo;
  final Isar _isar;
  final Logger _logger;

  /// Maximum age before a cached subscription is evicted.
  final Duration maxAge;

  /// Maximum number of cached podcasts to retain.
  final int maxCachedPodcasts;

  /// Runs the eviction pass.
  ///
  /// 1. Evicts cached subscriptions older than [maxAge].
  /// 2. If more than [maxCachedPodcasts] remain, evicts the
  ///    oldest-accessed entries until within the cap.
  Future<int> evict() async {
    var evicted = 0;
    final cached = await _subscriptionRepo.getCachedSubscriptions();
    if (cached.isEmpty) return 0;

    _logger.i('Cache eviction: ${cached.length} cached podcasts');

    final now = DateTime.now();

    // Phase 1: Evict stale entries
    for (final sub in cached) {
      final lastAccessed = sub.lastAccessedAt ?? sub.subscribedAt;
      final age = now.difference(lastAccessed);
      if (maxAge <= age) {
        await _evictSubscription(sub);
        evicted++;
      }
    }

    // Phase 2: Enforce cap on remaining cached entries
    final remaining = await _subscriptionRepo.getCachedSubscriptions();
    if (maxCachedPodcasts < remaining.length) {
      final toEvict = remaining.length - maxCachedPodcasts;
      // Already sorted by lastAccessedAt ascending (oldest first)
      for (var i = 0; i < toEvict; i++) {
        await _evictSubscription(remaining[i]);
        evicted++;
      }
    }

    if (0 < evicted) {
      _logger.i('Cache eviction: removed $evicted entries');
    }

    return evicted;
  }

  Future<void> _evictSubscription(Subscription subscription) async {
    final id = subscription.id;
    _logger.d(
      'Evicting cached podcast: '
      '${subscription.title} (id=$id)',
    );

    // Collect episode IDs first for cascading history deletes
    final episodeIds = await _isar.episodes
        .filter()
        .podcastIdEqualTo(id)
        .idProperty()
        .findAll();

    await _isar.writeTxn(() async {
      // Delete playback history for each episode
      if (episodeIds.isNotEmpty) {
        for (final episodeId in episodeIds) {
          await _isar.playbackHistorys
              .filter()
              .episodeIdEqualTo(episodeId)
              .deleteAll();
        }
      }

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
    });
  }
}
