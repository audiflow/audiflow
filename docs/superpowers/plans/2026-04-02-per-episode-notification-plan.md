# Per-Episode Local Notification Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace the single aggregated "new episodes" notification with one notification per episode (max 7), each tapping through to that episode's detail screen.

**Architecture:** The background isolate collects per-episode metadata during refresh and shows individual notifications with JSON payloads. The foreground app initializes a notification tap handler that decodes payloads, looks up Episode + Subscription from Isar, converts to PodcastItem, and navigates via GoRouter. A dedicated notification deep-link route avoids coupling to shell tab routes.

**Tech Stack:** flutter_local_notifications, GoRouter, Isar, Riverpod, workmanager

---

## File Map

| File | Action | Responsibility |
|------|--------|---------------|
| `packages/audiflow_domain/lib/src/features/feed/models/new_episode_notification.dart` | Create | Lightweight DTO for per-episode notification data |
| `packages/audiflow_domain/lib/audiflow_domain.dart` | Modify | Export new model |
| `packages/audiflow_domain/lib/src/features/feed/services/background_notification_service.dart` | Modify | Replace aggregated notification with per-episode notifications |
| `packages/audiflow_domain/lib/src/features/feed/services/background_refresh_service.dart` | Modify | Change callback type; collect episode details; cap at 7 |
| `packages/audiflow_app/lib/app/background/background_callback.dart` | Modify | Wire new callback signature |
| `packages/audiflow_app/lib/app/notification/notification_tap_handler.dart` | Create | Decode notification payload, look up episode, navigate |
| `packages/audiflow_app/lib/routing/app_router.dart` | Modify | Add notification deep-link route |
| `packages/audiflow_app/lib/main.dart` | Modify | Initialize notification plugin with tap handler; handle cold start |
| `packages/audiflow_domain/test/features/feed/models/new_episode_notification_test.dart` | Create | Model tests |
| `packages/audiflow_domain/test/features/feed/services/background_notification_service_test.dart` | Modify | Replace aggregated tests with per-episode tests |
| `packages/audiflow_domain/test/features/feed/services/background_refresh_service_test.dart` | Modify | Update for new callback type + episode collection |
| `packages/audiflow_app/test/app/notification/notification_tap_handler_test.dart` | Create | Tap handler payload parsing + navigation |

---

### Task 1: NewEpisodeNotification model

**Files:**
- Create: `packages/audiflow_domain/lib/src/features/feed/models/new_episode_notification.dart`
- Create: `packages/audiflow_domain/test/features/feed/models/new_episode_notification_test.dart`
- Modify: `packages/audiflow_domain/lib/audiflow_domain.dart`

- [ ] **Step 1: Write the failing test**

Create `packages/audiflow_domain/test/features/feed/models/new_episode_notification_test.dart`:

```dart
import 'dart:convert';

import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('NewEpisodeNotification', () {
    test('constructs with required fields', () {
      final notification = NewEpisodeNotification(
        episodeId: 42,
        podcastId: 7,
        podcastTitle: 'The Daily',
        episodeTitle: 'Breaking News',
      );

      expect(notification.episodeId, 42);
      expect(notification.podcastId, 7);
      expect(notification.podcastTitle, 'The Daily');
      expect(notification.episodeTitle, 'Breaking News');
    });

    test('toPayload returns valid JSON with type and IDs', () {
      final notification = NewEpisodeNotification(
        episodeId: 42,
        podcastId: 7,
        podcastTitle: 'The Daily',
        episodeTitle: 'Breaking News',
      );

      final payload = notification.toPayload();
      final decoded = jsonDecode(payload) as Map<String, dynamic>;

      expect(decoded['type'], 'new_episode');
      expect(decoded['episodeId'], 42);
      expect(decoded['podcastId'], 7);
    });
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `cd packages/audiflow_domain && flutter test test/features/feed/models/new_episode_notification_test.dart`
Expected: FAIL — `NewEpisodeNotification` not defined

- [ ] **Step 3: Write the model**

Create `packages/audiflow_domain/lib/src/features/feed/models/new_episode_notification.dart`:

```dart
import 'dart:convert';

/// Lightweight DTO carrying per-episode data for local notifications.
///
/// Created in the background isolate after feed sync detects new episodes.
/// The [toPayload] method produces a JSON string stored as the notification
/// payload so the foreground app can look up the full episode on tap.
class NewEpisodeNotification {
  const NewEpisodeNotification({
    required this.episodeId,
    required this.podcastId,
    required this.podcastTitle,
    required this.episodeTitle,
  });

  final int episodeId;
  final int podcastId;
  final String podcastTitle;
  final String episodeTitle;

  /// Returns a JSON payload string for the notification.
  String toPayload() => jsonEncode(<String, dynamic>{
    'type': 'new_episode',
    'episodeId': episodeId,
    'podcastId': podcastId,
  });
}
```

- [ ] **Step 4: Add export to barrel file**

In `packages/audiflow_domain/lib/audiflow_domain.dart`, add after the `feed_sync_result.dart` export:

```dart
export 'src/features/feed/models/new_episode_notification.dart';
```

- [ ] **Step 5: Run test to verify it passes**

Run: `cd packages/audiflow_domain && flutter test test/features/feed/models/new_episode_notification_test.dart`
Expected: PASS

- [ ] **Step 6: Commit**

```bash
git add packages/audiflow_domain/lib/src/features/feed/models/new_episode_notification.dart packages/audiflow_domain/test/features/feed/models/new_episode_notification_test.dart packages/audiflow_domain/lib/audiflow_domain.dart
git commit -m "feat(domain): add NewEpisodeNotification model"
```

---

### Task 2: Replace aggregated notification with per-episode notifications in BackgroundNotificationService

**Files:**
- Modify: `packages/audiflow_domain/lib/src/features/feed/services/background_notification_service.dart`
- Modify: `packages/audiflow_domain/test/features/feed/services/background_notification_service_test.dart`

- [ ] **Step 1: Write failing tests**

Replace the contents of `packages/audiflow_domain/test/features/feed/services/background_notification_service_test.dart`:

```dart
import 'dart:convert';

import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('BackgroundNotificationService', () {
    group('buildNotificationDetails', () {
      test('returns per-episode details list', () {
        final notifications = [
          const NewEpisodeNotification(
            episodeId: 1,
            podcastId: 10,
            podcastTitle: 'Podcast A',
            episodeTitle: 'Episode 1',
          ),
          const NewEpisodeNotification(
            episodeId: 2,
            podcastId: 10,
            podcastTitle: 'Podcast A',
            episodeTitle: 'Episode 2',
          ),
        ];

        final details =
            BackgroundNotificationService.buildNotificationDetails(
              notifications,
            );

        expect(details.length, 2);

        expect(details[0].id, 1);
        expect(details[0].title, 'Podcast A');
        expect(details[0].body, 'Episode 1');
        final payload0 = jsonDecode(details[0].payload) as Map<String, dynamic>;
        expect(payload0['type'], 'new_episode');
        expect(payload0['episodeId'], 1);
        expect(payload0['podcastId'], 10);

        expect(details[1].id, 2);
        expect(details[1].title, 'Podcast A');
        expect(details[1].body, 'Episode 2');
      });

      test('returns empty list for empty input', () {
        final details =
            BackgroundNotificationService.buildNotificationDetails([]);
        expect(details, isEmpty);
      });
    });
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `cd packages/audiflow_domain && flutter test test/features/feed/services/background_notification_service_test.dart`
Expected: FAIL — `buildNotificationDetails` not defined, `NotificationDetail` not defined

- [ ] **Step 3: Rewrite BackgroundNotificationService**

Replace `packages/audiflow_domain/lib/src/features/feed/services/background_notification_service.dart`:

```dart
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:logger/logger.dart';

import '../models/new_episode_notification.dart';

/// Detail record for a single notification to display.
class NotificationDetail {
  const NotificationDetail({
    required this.id,
    required this.title,
    required this.body,
    required this.payload,
  });

  final int id;
  final String title;
  final String body;
  final String payload;
}

class BackgroundNotificationService {
  BackgroundNotificationService({Logger? logger}) : _logger = logger;

  final Logger? _logger;

  static const _channelId = 'audiflow_new_episodes';
  static const _channelName = 'New Episodes';
  static const _channelDescription =
      'Notifications for new podcast episodes';

  Future<FlutterLocalNotificationsPlugin> initialize() async {
    final plugin = FlutterLocalNotificationsPlugin();
    const initSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
    );
    await plugin.initialize(settings: initSettings);
    return plugin;
  }

  /// Shows one notification per [NewEpisodeNotification].
  Future<void> showPerEpisodeNotifications(
    FlutterLocalNotificationsPlugin plugin,
    List<NewEpisodeNotification> notifications,
  ) async {
    final details = buildNotificationDetails(notifications);

    const notificationDetails = NotificationDetails(
      android: AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription: _channelDescription,
        importance: Importance.defaultImportance,
        priority: Priority.defaultPriority,
      ),
      iOS: DarwinNotificationDetails(),
    );

    for (final detail in details) {
      try {
        await plugin.show(
          id: detail.id,
          title: detail.title,
          body: detail.body,
          payload: detail.payload,
          notificationDetails: notificationDetails,
        );
        _logger?.i(
          'Showed notification: ${detail.title} — ${detail.body}',
        );
      } catch (e, stack) {
        _logger?.e(
          'Failed to show notification',
          error: e,
          stackTrace: stack,
        );
      }
    }
  }

  /// Builds notification detail records from episode notifications.
  ///
  /// Uses [NewEpisodeNotification.episodeId] as the notification ID
  /// so re-notifying the same episode replaces the previous one.
  static List<NotificationDetail> buildNotificationDetails(
    List<NewEpisodeNotification> notifications,
  ) {
    return notifications
        .map(
          (n) => NotificationDetail(
            id: n.episodeId,
            title: n.podcastTitle,
            body: n.episodeTitle,
            payload: n.toPayload(),
          ),
        )
        .toList();
  }
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `cd packages/audiflow_domain && flutter test test/features/feed/services/background_notification_service_test.dart`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add packages/audiflow_domain/lib/src/features/feed/services/background_notification_service.dart packages/audiflow_domain/test/features/feed/services/background_notification_service_test.dart
git commit -m "feat(domain): replace aggregated notification with per-episode notifications"
```

---

### Task 3: Update BackgroundRefreshService to collect episode details

**Files:**
- Modify: `packages/audiflow_domain/lib/src/features/feed/services/background_refresh_service.dart`
- Modify: `packages/audiflow_domain/test/features/feed/services/background_refresh_service_test.dart`

- [ ] **Step 1: Update failing tests**

Replace `packages/audiflow_domain/test/features/feed/services/background_refresh_service_test.dart` with tests covering the new callback type and episode collection. Key changes:
- `FakeBackgroundNotificationService.showNewEpisodesNotification` changes to accept `List<NewEpisodeNotification>`
- Add tests for: collects episode details, caps at 7, skips when notify disabled

```dart
import 'package:audiflow_core/audiflow_core.dart'
    show AutoPlayOrder, SettingsDefaults;
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:flutter/material.dart' show ThemeMode;
import 'package:flutter_test/flutter_test.dart';

// ---------------------------------------------------------------------------
// Fakes
// ---------------------------------------------------------------------------

class FakeAppSettingsRepository implements AppSettingsRepository {
  FakeAppSettingsRepository({
    bool autoSync = true,
    bool wifiOnlySync = false,
    bool notifyNewEpisodes = false,
    bool wifiOnlyDownload = false,
    int syncIntervalMinutes = 60,
  }) : _autoSync = autoSync,
       _wifiOnlySync = wifiOnlySync,
       _notifyNewEpisodes = notifyNewEpisodes,
       _wifiOnlyDownload = wifiOnlyDownload,
       _syncIntervalMinutes = syncIntervalMinutes;

  final bool _autoSync;
  final bool _wifiOnlySync;
  final bool _notifyNewEpisodes;
  final bool _wifiOnlyDownload;
  final int _syncIntervalMinutes;

  @override
  bool getAutoSync() => _autoSync;
  @override
  bool getWifiOnlySync() => _wifiOnlySync;
  @override
  bool getNotifyNewEpisodes() => _notifyNewEpisodes;
  @override
  bool getWifiOnlyDownload() => _wifiOnlyDownload;
  @override
  int getSyncIntervalMinutes() => _syncIntervalMinutes;

  // Unused interface methods
  @override
  ThemeMode getThemeMode() => ThemeMode.system;
  @override
  Future<void> setThemeMode(ThemeMode mode) async {}
  @override
  String? getLocale() => null;
  @override
  Future<void> setLocale(String? locale) async {}
  @override
  double getTextScale() => 1.0;
  @override
  Future<void> setTextScale(double scale) async {}
  @override
  double getPlaybackSpeed() => 1.0;
  @override
  Future<void> setPlaybackSpeed(double speed) async {}
  @override
  int getSkipForwardSeconds() => 30;
  @override
  Future<void> setSkipForwardSeconds(int seconds) async {}
  @override
  int getSkipBackwardSeconds() => 15;
  @override
  Future<void> setSkipBackwardSeconds(int seconds) async {}
  @override
  double getAutoCompleteThreshold() => 0.9;
  @override
  Future<void> setAutoCompleteThreshold(double threshold) async {}
  @override
  bool getContinuousPlayback() => true;
  @override
  Future<void> setContinuousPlayback(bool enabled) async {}
  @override
  AutoPlayOrder getAutoPlayOrder() => AutoPlayOrder.oldestFirst;
  @override
  Future<void> setAutoPlayOrder(AutoPlayOrder order) async {}
  @override
  Future<void> setWifiOnlyDownload(bool enabled) async {}
  @override
  bool getAutoDeletePlayed() => false;
  @override
  Future<void> setAutoDeletePlayed(bool enabled) async {}
  @override
  int getMaxConcurrentDownloads() => 3;
  @override
  Future<void> setMaxConcurrentDownloads(int count) async {}
  @override
  Future<void> setAutoSync(bool enabled) async {}
  @override
  Future<void> setSyncIntervalMinutes(int minutes) async {}
  @override
  Future<void> setWifiOnlySync(bool enabled) async {}
  @override
  Future<void> setNotifyNewEpisodes(bool enabled) async {}
  @override
  String? getSearchCountry() => null;
  @override
  Future<void> setSearchCountry(String? country) async {}
  @override
  int getLastTabIndex() => 0;
  @override
  Future<void> setLastTabIndex(int index) async {}
  @override
  bool getVoiceEnabled() => SettingsDefaults.voiceEnabled;
  @override
  Future<void> setVoiceEnabled(bool enabled) async {}
  @override
  Future<void> clearAll() async {}
}

class FakeSubscriptionRepository implements SubscriptionRepository {
  FakeSubscriptionRepository({List<Subscription>? subscriptions})
    : _subscriptions = subscriptions ?? [];

  final List<Subscription> _subscriptions;
  bool getSubscriptionsCalled = false;

  @override
  Future<List<Subscription>> getSubscriptions() async {
    getSubscriptionsCalled = true;
    return List.unmodifiable(_subscriptions);
  }

  @override
  Future<Subscription> subscribe({
    required String itunesId,
    required String feedUrl,
    required String title,
    required String artistName,
    String? artworkUrl,
    String? description,
    List<String> genres = const [],
    bool explicit = false,
  }) async => throw UnimplementedError();
  @override
  Future<void> unsubscribe(String itunesId) async {}
  @override
  Future<bool> isSubscribed(String itunesId) async => false;
  @override
  Future<bool> isSubscribedByFeedUrl(String feedUrl) async => false;
  @override
  Stream<List<Subscription>> watchSubscriptions() => const Stream.empty();
  @override
  Future<Subscription?> getSubscription(String itunesId) async => null;
  @override
  Future<Subscription?> getByFeedUrl(String feedUrl) async => null;
  @override
  Future<Subscription?> getById(int id) async => null;
  @override
  Future<void> updateLastRefreshed(String itunesId, DateTime timestamp) async {}
  @override
  Future<Subscription> getOrCreateCached({
    required String itunesId,
    required String feedUrl,
    required String title,
    required String artistName,
    String? artworkUrl,
    String? description,
    List<String> genres = const [],
    bool explicit = false,
  }) async => throw UnimplementedError();
  @override
  Future<Subscription?> promoteToSubscribed(String itunesId) async => null;
  @override
  Future<void> updateLastAccessed(int id) async {}
  @override
  Future<List<Subscription>> getCachedSubscriptions() async => [];
  @override
  Future<bool> deleteById(int id) async => false;
  @override
  Future<void> updateAutoDownload(int id, {required bool autoDownload}) async {}
  @override
  Future<void> updateHttpCacheHeaders(
    int id, {
    String? etag,
    String? lastModified,
  }) async {}
}

class FakeEpisodeRepository implements EpisodeRepository {
  FakeEpisodeRepository({Map<int, List<Episode>>? episodesByPodcastId})
    : _episodesByPodcastId = episodesByPodcastId ?? {};

  final Map<int, List<Episode>> _episodesByPodcastId;

  @override
  Future<List<Episode>> getByPodcastId(int podcastId) async =>
      _episodesByPodcastId[podcastId] ?? [];

  @override
  Stream<List<Episode>> watchByPodcastId(int podcastId) => const Stream.empty();
  @override
  Future<Episode?> getById(int id) async => null;
  @override
  Future<Episode?> getByAudioUrl(String audioUrl) async => null;
  @override
  Future<void> upsertEpisodes(List<Episode> episodes) async {}
  @override
  Future<void> upsertFromFeedItems(
    int podcastId,
    List<PodcastItem> items, {
    SmartPlaylistEpisodeExtractor? extractor,
  }) async {}
  @override
  Future<void> upsertFromFeedItemsWithConfig(
    int podcastId,
    List<PodcastItem> items, {
    required SmartPlaylistPatternConfig config,
  }) async {}
  @override
  Future<List<Episode>> getByIds(List<int> ids) async => [];
  @override
  Future<Set<String>> getGuidsByPodcastId(int podcastId) async => {};
  @override
  Future<Episode?> getNewestByPodcastId(int podcastId) async => null;
  @override
  Future<void> storeTranscriptAndChapterDataFromParsed(
    int podcastId,
    List<ParsedEpisodeMediaMeta> mediaMetas,
  ) async {}
  @override
  Future<Episode?> getByPodcastIdAndGuid(int podcastId, String guid) async =>
      null;
  @override
  Future<List<Episode>> getSubsequentEpisodes({
    required int podcastId,
    required int? afterEpisodeNumber,
    required int limit,
  }) async => [];
}

class FakeDownloadRepository implements DownloadRepository {
  final List<({int episodeId, String audioUrl, bool wifiOnly})>
  createdDownloads = [];

  @override
  Future<DownloadTask?> createDownload({
    required int episodeId,
    required String audioUrl,
    required bool wifiOnly,
  }) async {
    createdDownloads.add((
      episodeId: episodeId,
      audioUrl: audioUrl,
      wifiOnly: wifiOnly,
    ));
    return null;
  }

  @override
  Future<DownloadTask?> getById(int id) async => null;
  @override
  Future<DownloadTask?> getByEpisodeId(int episodeId) async => null;
  @override
  Stream<DownloadTask?> watchByEpisodeId(int episodeId) => const Stream.empty();
  @override
  Future<List<DownloadTask>> getAll() async => [];
  @override
  Stream<List<DownloadTask>> watchAll() => const Stream.empty();
  @override
  Future<List<DownloadTask>> getByStatus(DownloadStatus status) async => [];
  @override
  Stream<List<DownloadTask>> watchByStatus(DownloadStatus status) =>
      const Stream.empty();
  @override
  Future<DownloadTask?> getCompletedForEpisode(int episodeId) async => null;
  @override
  Future<DownloadTask?> getNextPending({required bool isOnWifi}) async => null;
  @override
  Future<void> updateProgress({
    required int id,
    required int downloadedBytes,
    int? totalBytes,
  }) async {}
  @override
  Future<void> updateStatus({
    required int id,
    required DownloadStatus status,
    String? localPath,
    String? lastError,
  }) async {}
  @override
  Future<void> incrementRetryCount(int id) async {}
  @override
  Future<void> delete(int id) async {}
  @override
  Future<int> getActiveCount() async => 0;
  @override
  Future<int> getTotalStorageUsed() async => 0;
  @override
  Future<int> deleteAllCompleted() async => 0;
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

Subscription _makeSubscription({
  required int id,
  required String title,
  DateTime? subscribedAt,
  DateTime? lastAccessedAt,
  bool autoDownload = false,
}) {
  return Subscription()
    ..id = id
    ..itunesId = 'itunes_$id'
    ..feedUrl = 'https://example.com/feed/$id'
    ..title = title
    ..artistName = 'Artist $id'
    ..subscribedAt = subscribedAt ?? DateTime(2024, 1, id)
    ..lastAccessedAt = lastAccessedAt
    ..autoDownload = autoDownload;
}

Episode _makeEpisode({
  required int id,
  required int podcastId,
  required String title,
}) {
  return Episode()
    ..id = id
    ..podcastId = podcastId
    ..guid = 'guid_$id'
    ..title = title
    ..audioUrl = 'https://example.com/audio/$id.mp3';
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('BackgroundRefreshService', () {
    test('returns early when auto-sync is disabled', () async {
      final settings = FakeAppSettingsRepository(autoSync: false);
      final subscriptionRepo = FakeSubscriptionRepository(
        subscriptions: [_makeSubscription(id: 1, title: 'Podcast 1')],
      );
      final episodeRepo = FakeEpisodeRepository();
      final downloadRepo = FakeDownloadRepository();
      final captured = <List<NewEpisodeNotification>>[];

      final service = BackgroundRefreshService(
        subscriptionRepo: subscriptionRepo,
        episodeRepo: episodeRepo,
        downloadRepo: downloadRepo,
        settingsRepo: settings,
        syncFeed: (_) async => const SingleFeedSyncResult(
          podcastId: 0,
          success: true,
          skipped: false,
        ),
        showNotification: (list) async => captured.add(list),
      );

      await service.execute();

      expect(subscriptionRepo.getSubscriptionsCalled, isFalse);
      expect(captured, isEmpty);
    });

    test(
      'sorts subscriptions by lastAccessedAt descending',
      () async {
        final subA = _makeSubscription(
          id: 1,
          title: 'Sub A',
          subscribedAt: DateTime(2025, 1, 5),
        );
        final subB = _makeSubscription(
          id: 2,
          title: 'Sub B',
          subscribedAt: DateTime(2025, 1, 1),
          lastAccessedAt: DateTime(2025, 1, 9),
        );
        final subC = _makeSubscription(
          id: 3,
          title: 'Sub C',
          subscribedAt: DateTime(2025, 1, 1),
          lastAccessedAt: DateTime(2025, 1, 7),
        );

        final syncedIds = <int>[];

        final service = BackgroundRefreshService(
          subscriptionRepo: FakeSubscriptionRepository(
            subscriptions: [subA, subB, subC],
          ),
          episodeRepo: FakeEpisodeRepository(),
          downloadRepo: FakeDownloadRepository(),
          settingsRepo: FakeAppSettingsRepository(),
          syncFeed: (sub) async {
            syncedIds.add(sub.id);
            return SingleFeedSyncResult(
              podcastId: sub.id,
              success: true,
              skipped: false,
            );
          },
          showNotification: (_) async {},
          timeBudget: const Duration(seconds: 60),
        );

        await service.execute();

        expect(syncedIds, [2, 3, 1]);
      },
    );

    test(
      'collects per-episode notifications and calls callback',
      () async {
        final sub = _makeSubscription(id: 1, title: 'Podcast A');
        final episodes = [
          _makeEpisode(id: 101, podcastId: 1, title: 'Ep New 1'),
          _makeEpisode(id: 102, podcastId: 1, title: 'Ep New 2'),
          _makeEpisode(id: 103, podcastId: 1, title: 'Ep Old'),
        ];

        final captured = <List<NewEpisodeNotification>>[];

        final service = BackgroundRefreshService(
          subscriptionRepo: FakeSubscriptionRepository(
            subscriptions: [sub],
          ),
          episodeRepo: FakeEpisodeRepository(
            episodesByPodcastId: {1: episodes},
          ),
          downloadRepo: FakeDownloadRepository(),
          settingsRepo: FakeAppSettingsRepository(notifyNewEpisodes: true),
          syncFeed: (_) async => const SingleFeedSyncResult(
            podcastId: 1,
            success: true,
            skipped: false,
            newEpisodeCount: 2,
          ),
          showNotification: (list) async => captured.add(list),
          timeBudget: const Duration(seconds: 60),
        );

        await service.execute();

        expect(captured.length, 1);
        final notifications = captured.first;
        expect(notifications.length, 2);
        expect(notifications[0].episodeId, 101);
        expect(notifications[0].podcastTitle, 'Podcast A');
        expect(notifications[0].episodeTitle, 'Ep New 1');
        expect(notifications[1].episodeId, 102);
      },
    );

    test('caps notifications at 7', () async {
      // Create 3 subscriptions, each returning 4 new episodes = 12 total
      final subs = List.generate(
        3,
        (i) => _makeSubscription(id: i + 1, title: 'Podcast ${i + 1}'),
      );
      final episodesByPodcast = <int, List<Episode>>{};
      for (final sub in subs) {
        episodesByPodcast[sub.id] = List.generate(
          4,
          (j) => _makeEpisode(
            id: sub.id * 100 + j,
            podcastId: sub.id,
            title: 'Ep $j',
          ),
        );
      }

      final captured = <List<NewEpisodeNotification>>[];

      final service = BackgroundRefreshService(
        subscriptionRepo: FakeSubscriptionRepository(subscriptions: subs),
        episodeRepo: FakeEpisodeRepository(
          episodesByPodcastId: episodesByPodcast,
        ),
        downloadRepo: FakeDownloadRepository(),
        settingsRepo: FakeAppSettingsRepository(notifyNewEpisodes: true),
        syncFeed: (sub) async => SingleFeedSyncResult(
          podcastId: sub.id,
          success: true,
          skipped: false,
          newEpisodeCount: 4,
        ),
        showNotification: (list) async => captured.add(list),
        timeBudget: const Duration(seconds: 60),
      );

      await service.execute();

      expect(captured.length, 1);
      expect(captured.first.length, 7);
    });

    test('does not notify when setting is disabled', () async {
      final sub = _makeSubscription(id: 1, title: 'Podcast A');
      final captured = <List<NewEpisodeNotification>>[];

      final service = BackgroundRefreshService(
        subscriptionRepo: FakeSubscriptionRepository(subscriptions: [sub]),
        episodeRepo: FakeEpisodeRepository(
          episodesByPodcastId: {
            1: [_makeEpisode(id: 101, podcastId: 1, title: 'Ep 1')],
          },
        ),
        downloadRepo: FakeDownloadRepository(),
        settingsRepo: FakeAppSettingsRepository(notifyNewEpisodes: false),
        syncFeed: (_) async => const SingleFeedSyncResult(
          podcastId: 1,
          success: true,
          skipped: false,
          newEpisodeCount: 1,
        ),
        showNotification: (list) async => captured.add(list),
        timeBudget: const Duration(seconds: 60),
      );

      await service.execute();

      expect(captured, isEmpty);
    });
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `cd packages/audiflow_domain && flutter test test/features/feed/services/background_refresh_service_test.dart`
Expected: FAIL — type mismatch on `showNotification` callback

- [ ] **Step 3: Update BackgroundRefreshService**

Replace `packages/audiflow_domain/lib/src/features/feed/services/background_refresh_service.dart`:

```dart
import 'package:logger/logger.dart';

import '../../download/repositories/download_repository.dart';
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
  /// 5. Collects per-episode notification data (max [_maxNotifications]).
  /// 6. Shows notifications if new episodes were found and notifications
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

    final allNotifications = <NewEpisodeNotification>[];
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
        if (sub.autoDownload) {
          await _enqueueAutoDownloads(sub, newCount);
        }

        if (allNotifications.length < _maxNotifications) {
          final remaining = _maxNotifications - allNotifications.length;
          final episodes = await _episodeRepo.getByPodcastId(sub.id);
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
    }

    if (allNotifications.isNotEmpty &&
        _settingsRepo.getNotifyNewEpisodes()) {
      await _showNotification(allNotifications);
    }

    final totalNew = allNotifications.length;
    _logger?.i(
      'BackgroundRefreshService: finished — $totalNew new episodes notified',
    );
  }

  /// Sorts [subscriptions] by effective last-access time, descending.
  List<Subscription> _sortByLastAccessed(List<Subscription> subscriptions) {
    final sorted = List<Subscription>.of(subscriptions);
    sorted.sort((a, b) {
      final aTime = a.lastAccessedAt ?? a.subscribedAt;
      final bTime = b.lastAccessedAt ?? b.subscribedAt;
      return bTime.compareTo(aTime);
    });
    return sorted;
  }

  /// Enqueues download tasks for the newest [newEpisodeCount] episodes.
  Future<void> _enqueueAutoDownloads(
    Subscription sub,
    int newEpisodeCount,
  ) async {
    final episodes = await _episodeRepo.getByPodcastId(sub.id);
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
```

- [ ] **Step 4: Run test to verify it passes**

Run: `cd packages/audiflow_domain && flutter test test/features/feed/services/background_refresh_service_test.dart`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add packages/audiflow_domain/lib/src/features/feed/services/background_refresh_service.dart packages/audiflow_domain/test/features/feed/services/background_refresh_service_test.dart
git commit -m "feat(domain): collect per-episode notification data in background refresh"
```

---

### Task 4: Wire new callback in background_callback.dart

**Files:**
- Modify: `packages/audiflow_app/lib/app/background/background_callback.dart`

- [ ] **Step 1: Update the showNotification callback**

In `packages/audiflow_app/lib/app/background/background_callback.dart`, change the `showNotification` callback from:

```dart
        showNotification: (map) async {
          final plugin = await notificationService.initialize();
          await notificationService.showNewEpisodesNotification(plugin, map);
        },
```

to:

```dart
        showNotification: (notifications) async {
          final plugin = await notificationService.initialize();
          await notificationService.showPerEpisodeNotifications(
            plugin,
            notifications,
          );
        },
```

- [ ] **Step 2: Verify analyze passes**

Run: `cd packages/audiflow_app && flutter analyze lib/app/background/background_callback.dart`
Expected: No issues found

- [ ] **Step 3: Commit**

```bash
git add packages/audiflow_app/lib/app/background/background_callback.dart
git commit -m "feat(app): wire per-episode notification callback in background isolate"
```

---

### Task 5: Add notification deep-link route

**Files:**
- Modify: `packages/audiflow_app/lib/routing/app_router.dart`

- [ ] **Step 1: Add route constant**

In `AppRoutes` class, add:

```dart
  static const String notificationEpisode =
      '/notification/episode/:podcastId/:episodeId';
```

- [ ] **Step 2: Add the GoRoute**

After the existing `deepLinkPodcast` route block (around line 316, before the closing `]` of `routes:`), add:

```dart
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: AppRoutes.notificationEpisode,
        builder: (context, state) => _NotificationEpisodeScreen(
          podcastId:
              int.tryParse(state.pathParameters['podcastId'] ?? '') ?? 0,
          episodeId:
              int.tryParse(state.pathParameters['episodeId'] ?? '') ?? 0,
        ),
      ),
```

- [ ] **Step 3: Add the screen widget**

At the bottom of `app_router.dart`, add:

```dart
/// Resolves notification tap to the episode detail screen.
///
/// Looks up [Episode] and [Subscription] from Isar by ID, converts
/// to [PodcastItem], and renders [EpisodeDetailScreen]. Falls back
/// to [_EpisodeNotFoundScreen] if either lookup fails.
class _NotificationEpisodeScreen extends ConsumerStatefulWidget {
  const _NotificationEpisodeScreen({
    required this.podcastId,
    required this.episodeId,
  });

  final int podcastId;
  final int episodeId;

  @override
  ConsumerState<_NotificationEpisodeScreen> createState() =>
      _NotificationEpisodeScreenState();
}

class _NotificationEpisodeScreenState
    extends ConsumerState<_NotificationEpisodeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _resolve());
  }

  Future<void> _resolve() async {
    final episodeRepo = ref.read(episodeRepositoryProvider);
    final subscriptionRepo = ref.read(subscriptionRepositoryProvider);

    final episode = await episodeRepo.getById(widget.episodeId);
    if (episode == null || !mounted) {
      if (mounted) context.go(AppRoutes.library);
      return;
    }

    final subscription = await subscriptionRepo.getById(widget.podcastId);

    final podcastItem = PodcastItem(
      parsedAt: DateTime.now(),
      sourceUrl: episode.audioUrl,
      title: episode.title,
      description: episode.description ?? '',
      guid: episode.guid,
      enclosureUrl: episode.audioUrl,
      duration: episode.durationMs != null
          ? Duration(milliseconds: episode.durationMs!)
          : null,
      publishDate: episode.publishedAt,
      episodeNumber: episode.episodeNumber,
      seasonNumber: episode.seasonNumber,
      images: episode.imageUrl != null
          ? [PodcastImage(url: episode.imageUrl!)]
          : const [],
    );

    if (!mounted) return;

    final router = GoRouter.of(context);
    final itunesId = subscription?.itunesId ?? '';

    // Go to library first, then push podcast + episode
    router.go(AppRoutes.library);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final podcast = Podcast(
        id: itunesId,
        name: subscription?.title ?? '',
        artistName: subscription?.artistName ?? '',
        feedUrl: subscription?.feedUrl ?? '',
        artworkUrl: subscription?.artworkUrl,
      );
      router.push('${AppRoutes.library}/podcast/${widget.podcastId}',
          extra: podcast);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        final episodePath =
            '${AppRoutes.library}/podcast/${widget.podcastId}/${AppRoutes.episodeDetail}'
                .replaceAll(
                  ':episodeGuid',
                  Uri.encodeComponent(episode.guid),
                );
        router.push(
          episodePath,
          extra: <String, dynamic>{
            'episode': podcastItem,
            'podcastTitle': subscription?.title ?? '',
            'artworkUrl': subscription?.artworkUrl,
            'itunesId': itunesId,
          },
        );
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
```

- [ ] **Step 4: Add missing import**

Add at the top of `app_router.dart`:

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
```

(Only if not already imported — check first.)

- [ ] **Step 5: Verify analyze passes**

Run: `cd packages/audiflow_app && flutter analyze lib/routing/app_router.dart`
Expected: No issues found

- [ ] **Step 6: Commit**

```bash
git add packages/audiflow_app/lib/routing/app_router.dart
git commit -m "feat(app): add notification deep-link route for episode detail"
```

---

### Task 6: Create NotificationTapHandler and integrate in main.dart

**Files:**
- Create: `packages/audiflow_app/lib/app/notification/notification_tap_handler.dart`
- Modify: `packages/audiflow_app/lib/main.dart`
- Create: `packages/audiflow_app/test/app/notification/notification_tap_handler_test.dart`

- [ ] **Step 1: Write failing test for NotificationTapHandler**

Create `packages/audiflow_app/test/app/notification/notification_tap_handler_test.dart`:

```dart
import 'dart:convert';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:audiflow_app/app/notification/notification_tap_handler.dart';

void main() {
  group('NotificationTapHandler', () {
    group('parseNotificationRoute', () {
      test('returns route for valid new_episode payload', () {
        final payload = jsonEncode({
          'type': 'new_episode',
          'episodeId': 42,
          'podcastId': 7,
        });

        final route = NotificationTapHandler.parseNotificationRoute(payload);
        expect(route, '/notification/episode/7/42');
      });

      test('returns null for null payload', () {
        final route = NotificationTapHandler.parseNotificationRoute(null);
        expect(route, isNull);
      });

      test('returns null for empty payload', () {
        final route = NotificationTapHandler.parseNotificationRoute('');
        expect(route, isNull);
      });

      test('returns null for unknown type', () {
        final payload = jsonEncode({'type': 'unknown'});
        final route = NotificationTapHandler.parseNotificationRoute(payload);
        expect(route, isNull);
      });

      test('returns null for malformed JSON', () {
        final route =
            NotificationTapHandler.parseNotificationRoute('not json');
        expect(route, isNull);
      });
    });
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `cd packages/audiflow_app && flutter test test/app/notification/notification_tap_handler_test.dart`
Expected: FAIL — file not found

- [ ] **Step 3: Create NotificationTapHandler**

Create `packages/audiflow_app/lib/app/notification/notification_tap_handler.dart`:

```dart
import 'dart:convert';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:go_router/go_router.dart';

/// Handles notification tap responses by navigating to the
/// appropriate screen via GoRouter.
class NotificationTapHandler {
  const NotificationTapHandler({required this.router});

  final GoRouter router;

  /// Called when user taps a notification while the app is running.
  void onDidReceiveNotificationResponse(NotificationResponse response) {
    final route = parseNotificationRoute(response.payload);
    if (route != null) {
      router.push(route);
    }
  }

  /// Parses a notification payload and returns the route to navigate to,
  /// or null if the payload is invalid or unrecognized.
  static String? parseNotificationRoute(String? payload) {
    if (payload == null || payload.isEmpty) return null;

    try {
      final data = jsonDecode(payload) as Map<String, dynamic>;
      if (data['type'] != 'new_episode') return null;

      final episodeId = data['episodeId'] as int;
      final podcastId = data['podcastId'] as int;

      return '/notification/episode/$podcastId/$episodeId';
    } on Exception {
      return null;
    }
  }
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `cd packages/audiflow_app && flutter test test/app/notification/notification_tap_handler_test.dart`
Expected: PASS

- [ ] **Step 5: Integrate in main.dart**

In `packages/audiflow_app/lib/main.dart`, make these changes:

**Add imports** (at top):

```dart
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'app/notification/notification_tap_handler.dart';
```

**In `_MyAppState`, add notification init after router creation** — change `initState()`:

```dart
  @override
  void initState() {
    super.initState();
    _router = createAppRouter(
      lastTabIndex: ref.read(lastTabControllerProvider),
    );
    _initNotificationTapHandler();
  }
```

**Add the init method in `_MyAppState`:**

```dart
  Future<void> _initNotificationTapHandler() async {
    final handler = NotificationTapHandler(router: _router);
    final plugin = FlutterLocalNotificationsPlugin();
    const initSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
    );
    await plugin.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse:
          handler.onDidReceiveNotificationResponse,
    );

    // Handle cold start: check if app was launched by notification
    final launchDetails =
        await plugin.getNotificationAppLaunchDetails();
    if (launchDetails != null &&
        (launchDetails.didNotificationLaunchApp ?? false)) {
      final route = NotificationTapHandler.parseNotificationRoute(
        launchDetails.notificationResponse?.payload,
      );
      if (route != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _router.push(route);
        });
      }
    }
  }
```

- [ ] **Step 6: Verify analyze passes**

Run: `cd packages/audiflow_app && flutter analyze lib/main.dart lib/app/notification/notification_tap_handler.dart`
Expected: No issues found

- [ ] **Step 7: Commit**

```bash
git add packages/audiflow_app/lib/app/notification/notification_tap_handler.dart packages/audiflow_app/test/app/notification/notification_tap_handler_test.dart packages/audiflow_app/lib/main.dart
git commit -m "feat(app): add notification tap handler with cold start support"
```

---

### Task 7: Update test fakes that implement changed interfaces

**Files:**
- Modify: any test fakes that implement `ShowNotificationCallback` or reference `showNewEpisodesNotification`

- [ ] **Step 1: Search for all references to the old callback signature**

Run: `grep -r 'showNewEpisodesNotification\|Map<String, int>.*newEpisodes' packages/audiflow_domain/test/ packages/audiflow_app/test/` to find all test files referencing the old aggregated API.

- [ ] **Step 2: Update each reference**

For any fake or mock using the old `Map<String, int>` callback, update to accept `List<NewEpisodeNotification>`. For any test calling `formatNotificationBody`, remove or update the test.

Key files to check:
- `packages/audiflow_domain/test/helpers/fake_app_settings_repository.dart` (likely unchanged — settings interface didn't change)
- Any mock files generated by mockito (will need regeneration if they mock `BackgroundNotificationService`)

- [ ] **Step 3: Run all domain tests**

Run: `cd packages/audiflow_domain && flutter test`
Expected: All tests PASS

- [ ] **Step 4: Run all app tests**

Run: `cd packages/audiflow_app && flutter test`
Expected: All tests PASS

- [ ] **Step 5: Run analyze on all packages**

Run: `flutter analyze`
Expected: No issues found

- [ ] **Step 6: Commit if any fakes were updated**

```bash
git add -u
git commit -m "test: update test fakes for per-episode notification callback"
```

---

### Task 8: Final verification

- [ ] **Step 1: Run full test suite**

Run: `melos run test`
Expected: All tests pass

- [ ] **Step 2: Run analysis**

Run: `flutter analyze`
Expected: No issues found

- [ ] **Step 3: Verify git log**

Run: `git log --oneline main..HEAD`
Verify all commits are present and well-formed.
