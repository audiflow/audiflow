import 'package:logger/logger.dart';

import '../../download/repositories/download_repository.dart';
import '../../settings/repositories/app_settings_repository.dart';
import '../../subscription/models/subscriptions.dart';
import '../../subscription/repositories/subscription_repository.dart';
import '../models/feed_sync_result.dart';
import '../repositories/episode_repository.dart';

/// Callback type for syncing a single podcast feed.
typedef SyncFeedCallback =
    Future<SingleFeedSyncResult> Function(Subscription sub);

/// Callback type for showing a new-episodes notification.
typedef ShowNotificationCallback =
    Future<void> Function(Map<String, int> newEpisodesPerPodcast);

/// Orchestrates background feed refresh for all subscriptions.
///
/// Designed for use inside a background isolate (e.g. workmanager).
/// All dependencies are constructor-injected; no Riverpod access required.
///
/// Subscriptions are processed in priority order (most recently accessed
/// first) so that frequently-visited podcasts are refreshed before the
/// [timeBudget] elapses.
class BackgroundRefreshService {
  BackgroundRefreshService({
    required SubscriptionRepository subscriptionRepo,
    required EpisodeRepository episodeRepo,
    required DownloadRepository downloadRepo,
    required AppSettingsRepository settingsRepo,
    required SyncFeedCallback syncFeed,
    required ShowNotificationCallback showNotification,
    Logger? logger,
    Duration timeBudget = const Duration(seconds: 25),
  }) : _subscriptionRepo = subscriptionRepo,
       _episodeRepo = episodeRepo,
       _downloadRepo = downloadRepo,
       _settingsRepo = settingsRepo,
       _syncFeed = syncFeed,
       _showNotification = showNotification,
       _logger = logger,
       _timeBudget = timeBudget;

  final SubscriptionRepository _subscriptionRepo;
  final EpisodeRepository _episodeRepo;
  final DownloadRepository _downloadRepo;
  final AppSettingsRepository _settingsRepo;
  final SyncFeedCallback _syncFeed;
  final ShowNotificationCallback _showNotification;
  final Logger? _logger;
  final Duration _timeBudget;

  /// Runs the background refresh cycle.
  ///
  /// 1. Exits early when auto-sync is disabled in settings.
  /// 2. Sorts subscriptions by last-accessed time (descending).
  /// 3. Syncs each feed in order, stopping when the time budget is exhausted.
  /// 4. Enqueues auto-downloads for newly discovered episodes.
  /// 5. Shows a notification if new episodes were found and notifications
  ///    are enabled.
  Future<void> execute() async {
    if (!_settingsRepo.getAutoSync()) {
      _logger?.d('BackgroundRefreshService: auto-sync disabled, skipping');
      return;
    }

    final subscriptions = await _subscriptionRepo.getSubscriptions();
    final sorted = _sortByLastAccessed(subscriptions);

    _logger?.i(
      'BackgroundRefreshService: syncing ${sorted.length} subscriptions',
    );

    final newEpisodesPerPodcast = <String, int>{};
    final stopwatch = Stopwatch()..start();

    for (final sub in sorted) {
      final elapsed = stopwatch.elapsed;
      if (_timeBudget <= elapsed) {
        _logger?.w(
          'BackgroundRefreshService: time budget exhausted after '
          '${elapsed.inSeconds}s, stopping early',
        );
        break;
      }

      final result = await _syncFeed(sub);

      final newCount = result.newEpisodeCount ?? 0;
      if (0 < newCount) {
        newEpisodesPerPodcast[sub.title] = newCount;

        if (sub.autoDownload) {
          await _enqueueAutoDownloads(sub, newCount);
        }
      }
    }

    if (newEpisodesPerPodcast.isNotEmpty &&
        _settingsRepo.getNotifyNewEpisodes()) {
      await _showNotification(newEpisodesPerPodcast);
    }

    _logger?.i(
      'BackgroundRefreshService: finished — '
      '${newEpisodesPerPodcast.values.fold(0, (a, b) => a + b)} new episodes '
      'across ${newEpisodesPerPodcast.length} podcasts',
    );
  }

  /// Sorts [subscriptions] by effective last-access time, descending.
  ///
  /// Uses [Subscription.lastAccessedAt] when available, falling back to
  /// [Subscription.subscribedAt] when it is null.
  List<Subscription> _sortByLastAccessed(List<Subscription> subscriptions) {
    final sorted = List<Subscription>.of(subscriptions);
    sorted.sort((a, b) {
      final aTime = a.lastAccessedAt ?? a.subscribedAt;
      final bTime = b.lastAccessedAt ?? b.subscribedAt;
      return bTime.compareTo(aTime);
    });
    return sorted;
  }

  /// Enqueues download tasks for the newest [newEpisodeCount] episodes of
  /// [sub].
  Future<void> _enqueueAutoDownloads(
    Subscription sub,
    int newEpisodeCount,
  ) async {
    final episodes = await _episodeRepo.getByPodcastId(sub.id);
    // Episodes are ordered newest-first by the repository contract.
    final toDownload = episodes.take(newEpisodeCount);
    final wifiOnly = _settingsRepo.getWifiOnlyDownload();

    for (final episode in toDownload) {
      await _downloadRepo.createDownload(
        episodeId: episode.id,
        audioUrl: episode.audioUrl,
        wifiOnly: wifiOnly,
      );
    }
  }
}
