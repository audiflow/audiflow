import 'package:logger/logger.dart';

import '../../download/repositories/download_repository.dart';
import '../../settings/repositories/app_settings_repository.dart';
import '../../subscription/models/subscriptions.dart';
import '../../subscription/repositories/subscription_repository.dart';
import '../models/episode.dart';
import '../models/feed_sync_result.dart';
import '../models/new_episode_notification.dart';
import '../repositories/episode_repository.dart';

/// Callback type for syncing a single podcast feed.
typedef SyncFeedCallback =
    Future<SingleFeedSyncResult> Function(Subscription sub);

/// Callback type for showing per-episode notifications.
typedef ShowNotificationCallback =
    Future<void> Function(List<NewEpisodeNotification> notifications);

/// Maximum number of notifications per background refresh cycle.
const _maxNotifications = 7;

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

    final notificationsEnabled = _settingsRepo.getNotifyNewEpisodes();
    final allNotifications = <NewEpisodeNotification>[];
    var totalNewEpisodes = 0;
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

      try {
        final result = await _syncFeed(sub);

        final newCount = result.newEpisodeCount ?? 0;
        if (0 < newCount) {
          totalNewEpisodes += newCount;

          // Fetch episodes once and reuse for both auto-download and
          // notification collection to avoid duplicate Isar reads.
          final needsEpisodes =
              sub.autoDownload ||
              (notificationsEnabled &&
                  allNotifications.length < _maxNotifications);

          final episodes = needsEpisodes
              ? await _episodeRepo.getByPodcastId(sub.id)
              : const <Episode>[];

          if (sub.autoDownload) {
            await _enqueueAutoDownloads(sub, newCount, episodes: episodes);
          }

          if (notificationsEnabled &&
              allNotifications.length < _maxNotifications) {
            final remaining = _maxNotifications - allNotifications.length;
            final newestCount = newCount < remaining ? newCount : remaining;
            final newest = episodes.take(newestCount);

            for (final episode in newest) {
              allNotifications.add(
                NewEpisodeNotification(
                  episodeId: episode.id,
                  podcastId: sub.id,
                  podcastTitle: sub.title,
                  episodeTitle: episode.title,
                ),
              );
            }
          }
        }
      } catch (e, stack) {
        _logger?.e(
          'BackgroundRefreshService: failed to process "${sub.title}"',
          error: e,
          stackTrace: stack,
        );
      }
    }

    if (allNotifications.isNotEmpty) {
      await _showNotification(allNotifications);
    }

    _logger?.i(
      'BackgroundRefreshService: finished — $totalNewEpisodes new episodes '
      '${notificationsEnabled ? "(${allNotifications.length} notified)" : "(notifications disabled)"}',
    );
  }

  List<Subscription> _sortByLastAccessed(List<Subscription> subscriptions) {
    final sorted = List<Subscription>.of(subscriptions);
    sorted.sort((a, b) {
      final aTime = a.lastAccessedAt ?? a.subscribedAt;
      final bTime = b.lastAccessedAt ?? b.subscribedAt;
      return bTime.compareTo(aTime);
    });
    return sorted;
  }

  Future<void> _enqueueAutoDownloads(
    Subscription sub,
    int newEpisodeCount, {
    required List<Episode> episodes,
  }) async {
    final toDownload = episodes.take(newEpisodeCount);
    final wifiOnly = _settingsRepo.getWifiOnlyDownload();

    for (final episode in toDownload) {
      if (episode.audioUrl.isEmpty) continue;
      await _downloadRepo.createDownload(
        episodeId: episode.id,
        audioUrl: episode.audioUrl,
        wifiOnly: wifiOnly,
      );
    }
  }
}
