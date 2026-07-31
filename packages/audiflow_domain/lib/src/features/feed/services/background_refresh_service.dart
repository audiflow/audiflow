import 'package:logger/logger.dart';

import '../../download/services/auto_download_enqueuer.dart';
import '../../player/models/playback_history.dart';
import '../../player/repositories/playback_history_repository.dart';
import '../../settings/repositories/app_settings_repository.dart';
import '../../subscription/models/subscriptions.dart';
import '../../subscription/repositories/subscription_repository.dart';
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
    required this._subscriptionRepo,
    required this._episodeRepo,
    required this._autoDownloadEnqueuer,
    required this._playbackHistoryRepo,
    required this._settingsRepo,
    required this._syncFeed,
    required this._showNotification,
    this._logger,
    this._timeBudget = const Duration(seconds: 25),
  });

  final SubscriptionRepository _subscriptionRepo;
  final EpisodeRepository _episodeRepo;
  final AutoDownloadEnqueuer _autoDownloadEnqueuer;
  final PlaybackHistoryRepository _playbackHistoryRepo;
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
    final syncErrors = <(String, Object, StackTrace)>[];
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

        // Always run the auto-download enqueuer so backlog items left over
        // from a foreground sync that ingested episodes without enqueueing
        // them get picked up here. The enqueuer is a no-op when there are
        // no pending episodes for the podcast.
        await _autoDownloadEnqueuer.enqueueForSubscription(
          sub,
          wifiOnly: _settingsRepo.getWifiOnlyDownload(),
        );

        final newCount = result.newEpisodeCount ?? 0;
        if (0 < newCount) {
          totalNewEpisodes += newCount;

          if (notificationsEnabled &&
              allNotifications.length < _maxNotifications) {
            final episodes = await _episodeRepo.getByPodcastId(sub.id);
            final remaining = _maxNotifications - allNotifications.length;
            final newestCount = newCount < remaining ? newCount : remaining;
            final newest = episodes.take(newestCount);

            final history = await _playbackHistoryRepo.getByPodcastId(sub.id);
            for (final episode in newest) {
              if (_hasBeenPlayed(history[episode.id])) continue;
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
        syncErrors.add((sub.title, e, stack));
      }
    }

    if (allNotifications.isNotEmpty) {
      await _showNotification(allNotifications);
    }

    _logger?.i(
      'BackgroundRefreshService: finished — $totalNewEpisodes new episodes '
      '${notificationsEnabled ? "(${allNotifications.length} notified)" : "(notifications disabled)"}',
    );

    if (syncErrors.isNotEmpty) {
      final first = syncErrors.first;
      final titles = syncErrors.map((r) => r.$1).join(', ');
      Error.throwWithStackTrace(
        Exception('${syncErrors.length} feed(s) failed to sync: $titles'),
        first.$3,
      );
    }
  }

  bool _hasBeenPlayed(PlaybackHistory? history) {
    if (history == null) return false;
    return history.completedAt != null || 0 < history.positionMs;
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
}
