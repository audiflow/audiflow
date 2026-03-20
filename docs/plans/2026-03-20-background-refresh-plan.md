# Background Feed Refresh Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add native OS background feed refresh using `workmanager` so podcasts sync automatically while the app is closed.

**Architecture:** Extract reusable feed sync logic from the Riverpod-coupled `FeedSyncService` into a standalone `FeedSyncExecutor`. A new `BackgroundRefreshService` bootstraps its own Isar instance and uses `FeedSyncExecutor` with manual DI. `workmanager` handles cross-platform scheduling.

**Tech Stack:** Flutter, Dart, workmanager, flutter_local_notifications, Isar, Riverpod, connectivity_plus

**Design Spec:** `docs/plans/2026-03-20-background-refresh-design.md`

---

## File Map

### New Files (audiflow_domain)

| File | Responsibility |
|------|----------------|
| `lib/src/features/feed/services/feed_sync_executor.dart` | Pure feed sync logic with constructor DI (no Riverpod) |
| `lib/src/features/feed/services/background_refresh_service.dart` | Bootstrap Isar + repos in background isolate, run prioritized sync |
| `lib/src/features/feed/services/background_notification_service.dart` | Format and show grouped local notifications |
| `test/features/feed/services/feed_sync_executor_test.dart` | Unit tests for extracted sync logic |
| `test/features/feed/services/background_refresh_service_test.dart` | Unit tests for background orchestration |
| `test/features/feed/services/background_notification_service_test.dart` | Unit tests for notification formatting |

### New Files (audiflow_app)

| File | Responsibility |
|------|----------------|
| `lib/app/background/background_callback.dart` | Top-level `@pragma('vm:entry-point')` workmanager callback |
| `lib/app/background/background_task_registrar.dart` | Register/cancel periodic tasks, update on settings change |
| `test/app/background/background_task_registrar_test.dart` | Unit tests for registration logic |

### Modified Files

| File | Change |
|------|--------|
| `packages/audiflow_domain/lib/src/features/subscription/models/subscriptions.dart` | Add `autoDownload` field |
| `packages/audiflow_core/lib/src/constants/settings_keys.dart` | Add `notifyNewEpisodes` key + default |
| `packages/audiflow_domain/lib/src/features/settings/repositories/app_settings_repository.dart` | Add `getNotifyNewEpisodes` / `setNotifyNewEpisodes` |
| `packages/audiflow_domain/lib/src/features/settings/repositories/app_settings_repository_impl.dart` | Implement new setting + add to `clearAll` |
| `packages/audiflow_domain/lib/src/features/feed/services/feed_sync_service.dart` | Delegate to `FeedSyncExecutor` |
| `packages/audiflow_domain/lib/audiflow_domain.dart` | Export new classes |
| `packages/audiflow_app/lib/main.dart` | Initialize workmanager + register background task |
| `packages/audiflow_app/lib/app/app_lifecycle_observer.dart` | Re-register task on resume if settings changed |
| `packages/audiflow_app/lib/features/settings/presentation/screens/feed_sync_settings_screen.dart` | Add notification toggle + more interval options |
| `packages/audiflow_domain/pubspec.yaml` | Add `flutter_local_notifications` |
| `packages/audiflow_app/pubspec.yaml` | Add `workmanager`, `flutter_local_notifications` |
| `packages/audiflow_app/lib/l10n/app_en.arb` | Add localization strings |
| `packages/audiflow_app/lib/l10n/app_ja.arb` | Add localization strings |

---

### Task 1: Add `notifyNewEpisodes` setting key and default

**Files:**
- Modify: `packages/audiflow_core/lib/src/constants/settings_keys.dart`

- [ ] **Step 1: Add the setting key to `SettingsKeys`**

In `settings_keys.dart`, add after the `wifiOnlySync` key (line 60):

```dart
  // -- Notifications --

  /// Whether to show local notifications for new episodes found
  /// during background refresh.
  static const String notifyNewEpisodes = 'settings_notify_new_episodes';
```

- [ ] **Step 2: Add the default to `SettingsDefaults`**

In `settings_keys.dart`, add after the `wifiOnlySync` default (line 104):

```dart
  /// Default new episode notification setting.
  static const bool notifyNewEpisodes = true;
```

- [ ] **Step 3: Commit**

```bash
git add packages/audiflow_core/lib/src/constants/settings_keys.dart
git commit -m "feat(core): add notifyNewEpisodes setting key and default"
```

---

### Task 2: Extend `AppSettingsRepository` with notification setting

**Files:**
- Modify: `packages/audiflow_domain/lib/src/features/settings/repositories/app_settings_repository.dart`
- Modify: `packages/audiflow_domain/lib/src/features/settings/repositories/app_settings_repository_impl.dart`
- Modify: `packages/audiflow_domain/test/features/settings/repositories/app_settings_repository_impl_test.dart`

- [ ] **Step 1: Add interface methods to `AppSettingsRepository`**

After the `setWifiOnlySync` method (line 106), add:

```dart
  // -- Notifications --

  /// Whether to show local notifications for new episodes.
  bool getNotifyNewEpisodes();

  /// Persists the new episode notification setting.
  Future<void> setNotifyNewEpisodes(bool enabled);
```

- [ ] **Step 2: Write failing tests for the new setting**

In `app_settings_repository_impl_test.dart`, add a test group for `notifyNewEpisodes`:

```dart
group('notifyNewEpisodes', () {
  test('returns default true when no value stored', () {
    final result = repo.getNotifyNewEpisodes();
    check(result).isTrue();
  });

  test('returns stored value', () async {
    await repo.setNotifyNewEpisodes(false);
    check(repo.getNotifyNewEpisodes()).isFalse();
  });

  test('clearAll resets to default', () async {
    await repo.setNotifyNewEpisodes(false);
    await repo.clearAll();
    check(repo.getNotifyNewEpisodes()).isTrue();
  });
});
```

- [ ] **Step 3: Run tests to verify they fail**

```bash
cd packages/audiflow_domain && flutter test test/features/settings/repositories/app_settings_repository_impl_test.dart
```

Expected: FAIL (methods not found)

- [ ] **Step 4: Implement in `AppSettingsRepositoryImpl`**

Add after the `setWifiOnlySync` method:

```dart
  // -- Notifications --

  @override
  bool getNotifyNewEpisodes() =>
      _ds.getBool(SettingsKeys.notifyNewEpisodes) ??
      SettingsDefaults.notifyNewEpisodes;

  @override
  Future<void> setNotifyNewEpisodes(bool enabled) async {
    await _ds.setBool(SettingsKeys.notifyNewEpisodes, enabled);
  }
```

Add `_ds.remove(SettingsKeys.notifyNewEpisodes)` to the `clearAll` method's `Future.wait` list.

- [ ] **Step 5: Run tests to verify they pass**

```bash
cd packages/audiflow_domain && flutter test test/features/settings/repositories/app_settings_repository_impl_test.dart
```

Expected: PASS

- [ ] **Step 6: Commit**

```bash
git add packages/audiflow_domain/lib/src/features/settings/repositories/app_settings_repository.dart packages/audiflow_domain/lib/src/features/settings/repositories/app_settings_repository_impl.dart packages/audiflow_domain/test/features/settings/repositories/app_settings_repository_impl_test.dart
git commit -m "feat(domain): add notifyNewEpisodes to AppSettingsRepository"
```

---

### Task 3: Add `autoDownload` field to Subscription model

**Files:**
- Modify: `packages/audiflow_domain/lib/src/features/subscription/models/subscriptions.dart`

- [ ] **Step 1: Add `autoDownload` field**

After the `lastAccessedAt` field (line 32), add:

```dart
  /// Whether new episodes should be auto-downloaded during background refresh.
  bool autoDownload = false;
```

- [ ] **Step 2: Add test verifying default value**

In the existing subscription model test file, add:

```dart
test('autoDownload defaults to false', () {
  final sub = Subscription()
    ..itunesId = 'test'
    ..feedUrl = 'https://example.com/feed.xml'
    ..title = 'Test'
    ..artistName = 'Artist'
    ..genres = ''
    ..subscribedAt = DateTime.now();

  check(sub.autoDownload).isFalse();
});
```

- [ ] **Step 3: Run code generation for Isar**

```bash
cd packages/audiflow_domain && dart run build_runner build --delete-conflicting-outputs
```

- [ ] **Step 4: Verify existing tests still pass**

```bash
cd packages/audiflow_domain && flutter test
```

- [ ] **Step 5: Commit**

```bash
git add packages/audiflow_domain/lib/src/features/subscription/models/subscriptions.dart packages/audiflow_domain/lib/src/features/subscription/models/subscriptions.g.dart
git commit -m "feat(domain): add autoDownload field to Subscription model"
```

---

### Task 4: Extract `FeedSyncExecutor` from `FeedSyncService`

**Files:**
- Create: `packages/audiflow_domain/lib/src/features/feed/services/feed_sync_executor.dart`
- Create: `packages/audiflow_domain/test/features/feed/services/feed_sync_executor_test.dart`
- Modify: `packages/audiflow_domain/lib/src/features/feed/services/feed_sync_service.dart`

- [ ] **Step 1: Write failing test for `FeedSyncExecutor.syncFeed`**

Create `feed_sync_executor_test.dart` using hand-written fakes (no mockito code generation per project rules):

```dart
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:checks/checks.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

// -- Fakes --

class FakeAppSettingsRepository extends Fake implements AppSettingsRepository {
  int syncIntervalMinutes = 60;

  @override
  int getSyncIntervalMinutes() => syncIntervalMinutes;
}

class FakeSubscriptionRepository extends Fake implements SubscriptionRepository {
  String? lastRefreshedItunesId;

  @override
  Future<void> updateLastRefreshed(String itunesId, DateTime timestamp) async {
    lastRefreshedItunesId = itunesId;
  }
}

class FakeEpisodeRepository extends Fake implements EpisodeRepository {
  Set<String> guidsToReturn = {};

  @override
  Future<Set<String>> getGuidsByPodcastId(int podcastId) async => guidsToReturn;

  @override
  Future<void> upsertEpisodes(List<Episode> episodes) async {}
}

class FakeFeedParserService extends Fake implements FeedParserService {
  int parsedTotal = 0;

  @override
  Stream<FeedParseProgress> parseWithProgress({
    required String xmlContent,
    required int podcastId,
    required Set<String> knownGuids,
    required Future<void> Function(List<Episode>, List<dynamic>) onBatchReady,
  }) {
    return Stream.fromIterable([FeedParseComplete(total: parsedTotal)]);
  }
}

class FakeDio extends Fake implements Dio {
  Response<String>? responseToReturn;
  Exception? exceptionToThrow;
  bool getCalled = false;

  @override
  Future<Response<T>> get<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  }) async {
    getCalled = true;
    if (exceptionToThrow != null) throw exceptionToThrow!;
    return responseToReturn! as Response<T>;
  }
}

// -- Helpers --

Subscription _subscription({
  int id = 1,
  String itunesId = 'itunes-1',
  String feedUrl = 'https://example.com/feed.xml',
  String title = 'Test Podcast',
  DateTime? lastRefreshedAt,
}) {
  return Subscription()
    ..id = id
    ..itunesId = itunesId
    ..feedUrl = feedUrl
    ..title = title
    ..artistName = 'Test Artist'
    ..genres = ''
    ..explicit = false
    ..subscribedAt = DateTime.now()
    ..lastRefreshedAt = lastRefreshedAt;
}

void main() {
  late FakeSubscriptionRepository fakeSubRepo;
  late FakeEpisodeRepository fakeEpisodeRepo;
  late FakeAppSettingsRepository fakeSettingsRepo;
  late FakeFeedParserService fakeFeedParser;
  late FakeDio fakeDio;
  late FeedSyncExecutor executor;

  setUp(() {
    fakeSubRepo = FakeSubscriptionRepository();
    fakeEpisodeRepo = FakeEpisodeRepository();
    fakeSettingsRepo = FakeAppSettingsRepository();
    fakeFeedParser = FakeFeedParserService();
    fakeDio = FakeDio();

    executor = FeedSyncExecutor(
      subscriptionRepo: fakeSubRepo,
      episodeRepo: fakeEpisodeRepo,
      settingsRepo: fakeSettingsRepo,
      feedParser: fakeFeedParser,
      dio: fakeDio,
    );
  });

  group('syncFeed', () {
    test('skips recently refreshed feed when forceRefresh is false', () async {
      final sub = _subscription(
        lastRefreshedAt: DateTime.now().subtract(const Duration(minutes: 30)),
      );

      final result = await executor.syncFeed(sub);

      check(result.skipped).isTrue();
      check(result.success).isTrue();
      check(fakeDio.getCalled).isFalse();
    });

    test('syncs feed when enough time has passed', () async {
      final sub = _subscription(
        lastRefreshedAt: DateTime.now().subtract(const Duration(hours: 2)),
      );
      fakeDio.responseToReturn = Response(
        data: '<rss><channel></channel></rss>',
        statusCode: 200,
        requestOptions: RequestOptions(),
      );

      final result = await executor.syncFeed(sub);

      check(result.success).isTrue();
      check(result.skipped).isFalse();
    });

    test('returns error result on network failure', () async {
      final sub = _subscription(lastRefreshedAt: null);
      fakeDio.exceptionToThrow = DioException(
        type: DioExceptionType.connectionTimeout,
        requestOptions: RequestOptions(),
      );

      final result = await executor.syncFeed(sub);

      check(result.success).isFalse();
      check(result.skipped).isFalse();
    });
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

```bash
cd packages/audiflow_domain && flutter test test/features/feed/services/feed_sync_executor_test.dart
```

Expected: FAIL (FeedSyncExecutor not found)

- [ ] **Step 4: Create `FeedSyncExecutor`**

Create `packages/audiflow_domain/lib/src/features/feed/services/feed_sync_executor.dart`:

```dart
import 'package:dio/dio.dart';
import 'package:logger/logger.dart';

import '../../../features/subscription/models/subscriptions.dart';
import '../../../features/subscription/repositories/subscription_repository.dart';
import '../../settings/repositories/app_settings_repository.dart';
import '../models/episode.dart';
import '../models/feed_parse_progress.dart';
import '../models/feed_sync_result.dart';
import '../repositories/episode_repository.dart';
import 'feed_parser_service.dart';

/// Pure feed sync logic with constructor-injected dependencies.
///
/// Usable from both the foreground (via [FeedSyncService] with Riverpod)
/// and the background isolate (via [BackgroundRefreshService] with manual DI).
///
/// Does NOT handle smart playlist resolution or transcript/chapter extraction.
/// Those are foreground-only concerns handled by [FeedSyncService].
class FeedSyncExecutor {
  FeedSyncExecutor({
    required SubscriptionRepository subscriptionRepo,
    required EpisodeRepository episodeRepo,
    required AppSettingsRepository settingsRepo,
    required FeedParserService feedParser,
    required Dio dio,
    Logger? logger,
  })  : _subscriptionRepo = subscriptionRepo,
        _episodeRepo = episodeRepo,
        _settingsRepo = settingsRepo,
        _feedParser = feedParser,
        _dio = dio,
        _logger = logger;

  final SubscriptionRepository _subscriptionRepo;
  final EpisodeRepository _episodeRepo;
  final AppSettingsRepository _settingsRepo;
  final FeedParserService _feedParser;
  final Dio _dio;
  final Logger? _logger;

  Duration get _syncInterval =>
      Duration(minutes: _settingsRepo.getSyncIntervalMinutes());

  /// Syncs a single podcast feed with early termination.
  ///
  /// Skips sync if less than the configured interval has elapsed
  /// since last refresh, unless [forceRefresh] is true.
  Future<SingleFeedSyncResult> syncFeed(
    Subscription sub, {
    bool forceRefresh = false,
  }) async {
    try {
      if (!forceRefresh && !_shouldSync(sub.lastRefreshedAt)) {
        _logger?.d('Skipping sync for "${sub.title}" (recently refreshed)');
        return SingleFeedSyncResult(
          podcastId: sub.id,
          success: true,
          skipped: true,
        );
      }

      _logger?.d('Syncing feed for "${sub.title}"');

      final response = await _dio.get<String>(
        sub.feedUrl,
        options: Options(
          headers: {
            'Accept': 'application/rss+xml, application/xml, text/xml',
          },
          responseType: ResponseType.plain,
        ),
      );

      final xmlContent = response.data;
      if (xmlContent == null || xmlContent.isEmpty) {
        _logger?.w('Empty RSS response for "${sub.title}"');
        return SingleFeedSyncResult(
          podcastId: sub.id,
          success: false,
          skipped: false,
          errorMessage: 'Empty RSS response',
        );
      }

      final knownGuids = await _episodeRepo.getGuidsByPodcastId(sub.id);

      var newEpisodeCount = 0;
      await for (final progress in _feedParser.parseWithProgress(
        xmlContent: xmlContent,
        podcastId: sub.id,
        knownGuids: knownGuids,
        onBatchReady: (episodes, mediaMetas) async {
          await _episodeRepo.upsertEpisodes(episodes);
        },
      )) {
        if (progress is FeedParseComplete) {
          newEpisodeCount = progress.total;
        }
      }

      await _subscriptionRepo.updateLastRefreshed(
        sub.itunesId,
        DateTime.now(),
      );

      _logger?.i(
        'Synced "${sub.title}": $newEpisodeCount episodes processed',
      );

      return SingleFeedSyncResult(
        podcastId: sub.id,
        success: true,
        skipped: false,
        newEpisodeCount: newEpisodeCount,
      );
    } catch (e, stack) {
      _logger?.e(
        'Failed to sync feed for "${sub.title}"',
        error: e,
        stackTrace: stack,
      );
      return SingleFeedSyncResult(
        podcastId: sub.id,
        success: false,
        skipped: false,
        errorMessage: e.toString(),
      );
    }
  }

  bool _shouldSync(DateTime? lastRefreshedAt) {
    if (lastRefreshedAt == null) return true;
    final elapsed = DateTime.now().difference(lastRefreshedAt);
    return _syncInterval <= elapsed;
  }
}
```

- [ ] **Step 5: Export `FeedSyncExecutor` from `audiflow_domain.dart`**

Add to the barrel file:

```dart
export 'src/features/feed/services/feed_sync_executor.dart';
```

- [ ] **Step 6: Run tests to verify they pass**

```bash
cd packages/audiflow_domain && flutter test test/features/feed/services/feed_sync_executor_test.dart
```

Expected: PASS

- [ ] **Step 7: Refactor `FeedSyncService` to delegate to `FeedSyncExecutor`**

Update `feed_sync_service.dart`:
- Create a `FeedSyncExecutor` in the constructor
- Delegate `syncFeed` to the executor for the base sync logic
- Keep smart playlist resolution and transcript/chapter extraction in `FeedSyncService.syncFeed` as a wrapper

The provider becomes:

```dart
@Riverpod(keepAlive: true)
FeedSyncService feedSyncService(Ref ref) {
  final logger = ref.watch(namedLoggerProvider('FeedSync'));
  return FeedSyncService(ref: ref, logger: logger);
}
```

The `FeedSyncService.syncFeed` method keeps its smart playlist logic but delegates the base RSS fetch/parse/upsert to `FeedSyncExecutor`. The `_shouldSync` and sync interval logic move to the executor.

- [ ] **Step 8: Run all existing feed sync tests to verify no regression**

```bash
cd packages/audiflow_domain && flutter test test/features/feed/services/
```

Expected: all PASS

- [ ] **Step 9: Commit**

```bash
git add packages/audiflow_domain/lib/src/features/feed/services/feed_sync_executor.dart packages/audiflow_domain/lib/src/features/feed/services/feed_sync_service.dart packages/audiflow_domain/test/features/feed/services/feed_sync_executor_test.dart packages/audiflow_domain/lib/audiflow_domain.dart
git commit -m "refactor(domain): extract FeedSyncExecutor from FeedSyncService"
```

---

### Task 5: Add dependencies (`workmanager`, `flutter_local_notifications`)

**Files:**
- Modify: `packages/audiflow_domain/pubspec.yaml`
- Modify: `packages/audiflow_app/pubspec.yaml`

- [ ] **Step 1: Add `workmanager` and `flutter_local_notifications` to audiflow_app**

```bash
cd packages/audiflow_app && flutter pub add workmanager flutter_local_notifications
```

- [ ] **Step 2: Add `flutter_local_notifications` to audiflow_domain**

```bash
cd packages/audiflow_domain && flutter pub add flutter_local_notifications
```

- [ ] **Step 3: Verify packages resolve**

```bash
cd packages/audiflow_app && flutter pub get
cd packages/audiflow_domain && flutter pub get
```

- [ ] **Step 4: Commit**

```bash
git add packages/audiflow_app/pubspec.yaml packages/audiflow_app/pubspec.lock packages/audiflow_domain/pubspec.yaml packages/audiflow_domain/pubspec.lock pubspec.lock
git commit -m "chore(deps): add workmanager and flutter_local_notifications"
```

---

### Task 6: Create `BackgroundNotificationService`

**Files:**
- Create: `packages/audiflow_domain/lib/src/features/feed/services/background_notification_service.dart`
- Create: `packages/audiflow_domain/test/features/feed/services/background_notification_service_test.dart`

- [ ] **Step 1: Write failing test for notification message formatting**

Create `background_notification_service_test.dart`:

```dart
import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:audiflow_domain/audiflow_domain.dart';

void main() {
  group('BackgroundNotificationService', () {
    group('formatNotificationBody', () {
      test('single podcast', () {
        final body = BackgroundNotificationService.formatNotificationBody({
          'Podcast A': 2,
        });
        check(body).equals('2 new episodes from Podcast A');
      });

      test('two podcasts', () {
        final body = BackgroundNotificationService.formatNotificationBody({
          'Podcast A': 1,
          'Podcast B': 3,
        });
        check(body).equals('4 new episodes from Podcast A and Podcast B');
      });

      test('three or more podcasts', () {
        final body = BackgroundNotificationService.formatNotificationBody({
          'Podcast A': 1,
          'Podcast B': 2,
          'Podcast C': 1,
        });
        check(body).equals('4 new episodes from Podcast A, Podcast B, and 1 other');
      });

      test('four or more podcasts', () {
        final body = BackgroundNotificationService.formatNotificationBody({
          'Podcast A': 1,
          'Podcast B': 1,
          'Podcast C': 1,
          'Podcast D': 1,
        });
        check(body).equals('4 new episodes from Podcast A, Podcast B, and 2 others');
      });

      test('empty map returns empty string', () {
        final body = BackgroundNotificationService.formatNotificationBody({});
        check(body).equals('');
      });
    });
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

```bash
cd packages/audiflow_domain && flutter test test/features/feed/services/background_notification_service_test.dart
```

Expected: FAIL

- [ ] **Step 3: Implement `BackgroundNotificationService`**

Create `background_notification_service.dart`:

```dart
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:logger/logger.dart';

/// Handles local notifications for new episodes found during
/// background refresh.
class BackgroundNotificationService {
  BackgroundNotificationService({Logger? logger}) : _logger = logger;

  final Logger? _logger;

  static const _channelId = 'audiflow_new_episodes';
  static const _channelName = 'New Episodes';
  static const _channelDescription = 'Notifications for new podcast episodes';
  static const _notificationId = 1001;

  /// Initializes the notification plugin for background use.
  Future<FlutterLocalNotificationsPlugin> initialize() async {
    final plugin = FlutterLocalNotificationsPlugin();
    const initSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
    );
    await plugin.initialize(initSettings);
    return plugin;
  }

  /// Shows a grouped notification for new episodes.
  ///
  /// [newEpisodesPerPodcast] maps podcast title to new episode count.
  Future<void> showNewEpisodesNotification(
    FlutterLocalNotificationsPlugin plugin,
    Map<String, int> newEpisodesPerPodcast,
  ) async {
    if (newEpisodesPerPodcast.isEmpty) return;

    final body = formatNotificationBody(newEpisodesPerPodcast);
    if (body.isEmpty) return;

    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription: _channelDescription,
        importance: Importance.defaultImportance,
        priority: Priority.defaultPriority,
      ),
      iOS: DarwinNotificationDetails(),
    );

    try {
      await plugin.show(
        _notificationId,
        'New episodes available',
        body,
        details,
      );
      _logger?.i('Showed notification: $body');
    } catch (e, stack) {
      _logger?.e(
        'Failed to show notification',
        error: e,
        stackTrace: stack,
      );
    }
  }

  /// Formats the notification body from a map of podcast names to
  /// new episode counts.
  static String formatNotificationBody(Map<String, int> episodesPerPodcast) {
    if (episodesPerPodcast.isEmpty) return '';

    final totalEpisodes = episodesPerPodcast.values.fold(0, (a, b) => a + b);
    final names = episodesPerPodcast.keys.toList();

    return switch (names.length) {
      1 => '$totalEpisodes new episodes from ${names[0]}',
      2 => '$totalEpisodes new episodes from ${names[0]} and ${names[1]}',
      _ => () {
          final otherCount = names.length - 2;
          final otherLabel = otherCount == 1 ? '1 other' : '$otherCount others';
          return '$totalEpisodes new episodes from ${names[0]}, ${names[1]}, '
              'and $otherLabel';
        }(),
    };
  }
}
```

- [ ] **Step 4: Export from `audiflow_domain.dart`**

```dart
export 'src/features/feed/services/background_notification_service.dart';
```

- [ ] **Step 5: Run tests to verify they pass**

```bash
cd packages/audiflow_domain && flutter test test/features/feed/services/background_notification_service_test.dart
```

Expected: PASS

- [ ] **Step 6: Commit**

```bash
git add packages/audiflow_domain/lib/src/features/feed/services/background_notification_service.dart packages/audiflow_domain/test/features/feed/services/background_notification_service_test.dart packages/audiflow_domain/lib/audiflow_domain.dart
git commit -m "feat(domain): add BackgroundNotificationService for new episode alerts"
```

---

### Task 7: Create `BackgroundRefreshService`

**Design note:** The design spec describes `bootstrap()`/`execute()`/`dispose()` methods. This implementation instead accepts all dependencies via constructor injection and only exposes `execute()`. Bootstrap and cleanup are handled by the `backgroundCallback` (Task 8). This is intentionally more testable — the service is a pure orchestrator with no side effects in construction.

**Files:**
- Create: `packages/audiflow_domain/lib/src/features/feed/services/background_refresh_service.dart`
- Create: `packages/audiflow_domain/test/features/feed/services/background_refresh_service_test.dart`

- [ ] **Step 1: Write failing test for prioritized sync with time budget**

Create `background_refresh_service_test.dart` using hand-written fakes (no mockito code generation):

```dart
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart';

// -- Fakes --

class FakeAppSettingsRepository extends Fake implements AppSettingsRepository {
  bool autoSync = true;
  bool wifiOnlySync = false;
  bool notifyNewEpisodes = true;
  bool wifiOnlyDownload = true;
  int syncIntervalMinutes = 60;

  @override
  bool getAutoSync() => autoSync;
  @override
  bool getWifiOnlySync() => wifiOnlySync;
  @override
  bool getNotifyNewEpisodes() => notifyNewEpisodes;
  @override
  bool getWifiOnlyDownload() => wifiOnlyDownload;
  @override
  int getSyncIntervalMinutes() => syncIntervalMinutes;
}

class FakeSubscriptionRepository extends Fake implements SubscriptionRepository {
  List<Subscription> subscriptions = [];
  bool getSubscriptionsCalled = false;

  @override
  Future<List<Subscription>> getSubscriptions() async {
    getSubscriptionsCalled = true;
    return subscriptions;
  }
}

class FakeEpisodeRepository extends Fake implements EpisodeRepository {
  @override
  Future<List<Episode>> getByPodcastId(int podcastId) async => [];
}

class FakeDownloadRepository extends Fake implements DownloadRepository {
  final createdDownloads = <int>[];

  @override
  Future<DownloadTask?> createDownload({
    required int episodeId,
    required String audioUrl,
    required bool wifiOnly,
  }) async {
    createdDownloads.add(episodeId);
    return null;
  }
}

class FakeFeedSyncExecutor extends Fake implements FeedSyncExecutor {
  final syncedSubscriptions = <Subscription>[];
  SingleFeedSyncResult resultToReturn = const SingleFeedSyncResult(
    podcastId: 0,
    success: true,
    skipped: false,
    newEpisodeCount: 0,
  );

  @override
  Future<SingleFeedSyncResult> syncFeed(
    Subscription sub, {
    bool forceRefresh = false,
  }) async {
    syncedSubscriptions.add(sub);
    return resultToReturn;
  }
}

class FakeBackgroundNotificationService extends Fake
    implements BackgroundNotificationService {}

// -- Helpers --

Subscription _sub({
  required int id,
  required String title,
  DateTime? lastAccessedAt,
  DateTime? subscribedAt,
  bool autoDownload = false,
}) {
  return Subscription()
    ..id = id
    ..itunesId = 'itunes-$id'
    ..feedUrl = 'https://example.com/$id/feed.xml'
    ..title = title
    ..artistName = 'Artist'
    ..genres = ''
    ..subscribedAt = subscribedAt ?? DateTime(2026)
    ..lastAccessedAt = lastAccessedAt
    ..autoDownload = autoDownload;
}

void main() {
  late FakeSubscriptionRepository fakeSubRepo;
  late FakeEpisodeRepository fakeEpisodeRepo;
  late FakeDownloadRepository fakeDownloadRepo;
  late FakeAppSettingsRepository fakeSettingsRepo;
  late FakeFeedSyncExecutor fakeExecutor;
  late FakeBackgroundNotificationService fakeNotificationService;
  late BackgroundRefreshService service;

  setUp(() {
    fakeSubRepo = FakeSubscriptionRepository();
    fakeEpisodeRepo = FakeEpisodeRepository();
    fakeDownloadRepo = FakeDownloadRepository();
    fakeSettingsRepo = FakeAppSettingsRepository();
    fakeExecutor = FakeFeedSyncExecutor();
    fakeNotificationService = FakeBackgroundNotificationService();

    service = BackgroundRefreshService(
      subscriptionRepo: fakeSubRepo,
      episodeRepo: fakeEpisodeRepo,
      downloadRepo: fakeDownloadRepo,
      settingsRepo: fakeSettingsRepo,
      syncExecutor: fakeExecutor,
      notificationService: fakeNotificationService,
    );
  });

  group('execute', () {
    test('returns early when auto-sync is disabled', () async {
      fakeSettingsRepo.autoSync = false;

      await service.execute();

      check(fakeSubRepo.getSubscriptionsCalled).isFalse();
    });

    test('sorts subscriptions by lastAccessedAt descending', () async {
      final older = _sub(
        id: 1,
        title: 'Older',
        lastAccessedAt: DateTime(2026, 1, 1),
      );
      final newer = _sub(
        id: 2,
        title: 'Newer',
        lastAccessedAt: DateTime(2026, 3, 1),
      );
      final noAccess = _sub(
        id: 3,
        title: 'Never Accessed',
        subscribedAt: DateTime(2026, 2, 1),
      );

      fakeSubRepo.subscriptions = [older, noAccess, newer];

      await service.execute();

      check(fakeExecutor.syncedSubscriptions.map((s) => s.title).toList())
          .deepEquals(['Newer', 'Never Accessed', 'Older']);
    });
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

```bash
cd packages/audiflow_domain && flutter test test/features/feed/services/background_refresh_service_test.dart
```

Expected: FAIL

- [ ] **Step 4: Implement `BackgroundRefreshService`**

Create `background_refresh_service.dart`:

```dart
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:logger/logger.dart';

import '../../../features/subscription/models/subscriptions.dart';
import '../../../features/subscription/repositories/subscription_repository.dart';
import '../../download/repositories/download_repository.dart';
import '../../settings/repositories/app_settings_repository.dart';
import '../repositories/episode_repository.dart';
import 'background_notification_service.dart';
import 'feed_sync_executor.dart';

/// Orchestrates background feed refresh in an isolated Dart isolate.
///
/// Accepts all dependencies via constructor injection (no Riverpod).
/// Syncs subscriptions in priority order (most recently accessed first)
/// within a configurable time budget.
class BackgroundRefreshService {
  BackgroundRefreshService({
    required SubscriptionRepository subscriptionRepo,
    required EpisodeRepository episodeRepo,
    required DownloadRepository downloadRepo,
    required AppSettingsRepository settingsRepo,
    required FeedSyncExecutor syncExecutor,
    required BackgroundNotificationService notificationService,
    Logger? logger,
    Duration timeBudget = const Duration(seconds: 25),
  })  : _subscriptionRepo = subscriptionRepo,
        _episodeRepo = episodeRepo,
        _downloadRepo = downloadRepo,
        _settingsRepo = settingsRepo,
        _syncExecutor = syncExecutor,
        _notificationService = notificationService,
        _logger = logger,
        _timeBudget = timeBudget;

  final SubscriptionRepository _subscriptionRepo;
  final EpisodeRepository _episodeRepo;
  final DownloadRepository _downloadRepo;
  final AppSettingsRepository _settingsRepo;
  final FeedSyncExecutor _syncExecutor;
  final BackgroundNotificationService _notificationService;
  final Logger? _logger;
  final Duration _timeBudget;

  /// Executes prioritized background feed sync.
  Future<void> execute() async {
    if (!_settingsRepo.getAutoSync()) {
      _logger?.i('Auto-sync disabled, skipping background refresh');
      return;
    }

    final startTime = DateTime.now();
    final subscriptions = await _subscriptionRepo.getSubscriptions();

    if (subscriptions.isEmpty) {
      _logger?.i('No subscriptions to sync');
      return;
    }

    // Sort by lastAccessedAt descending, falling back to subscribedAt
    final sorted = List<Subscription>.from(subscriptions)
      ..sort((a, b) {
        final aTime = a.lastAccessedAt ?? a.subscribedAt;
        final bTime = b.lastAccessedAt ?? b.subscribedAt;
        return bTime.compareTo(aTime);
      });

    _logger?.i(
      'Background refresh starting for ${sorted.length} subscriptions',
    );

    final newEpisodesPerPodcast = <String, int>{};

    for (final sub in sorted) {
      final elapsed = DateTime.now().difference(startTime);
      if (_timeBudget <= elapsed) {
        _logger?.i(
          'Time budget exhausted after ${elapsed.inSeconds}s, '
          'stopping refresh',
        );
        break;
      }

      final result = await _syncExecutor.syncFeed(sub);

      if (result.success &&
          !result.skipped &&
          result.newEpisodeCount != null &&
          0 < result.newEpisodeCount!) {
        newEpisodesPerPodcast[sub.title] = result.newEpisodeCount!;

        // Enqueue auto-downloads if enabled for this podcast
        if (sub.autoDownload) {
          await _enqueueAutoDownloads(sub, result.newEpisodeCount!);
        }
      }
    }

    // Show notification if new episodes found and notifications enabled
    if (newEpisodesPerPodcast.isNotEmpty &&
        _settingsRepo.getNotifyNewEpisodes()) {
      try {
        final plugin = await _notificationService.initialize();
        await _notificationService.showNewEpisodesNotification(
          plugin,
          newEpisodesPerPodcast,
        );
      } catch (e, stack) {
        _logger?.e(
          'Failed to show notification',
          error: e,
          stackTrace: stack,
        );
      }
    }

    final totalNew = newEpisodesPerPodcast.values.fold(0, (a, b) => a + b);
    _logger?.i('Background refresh complete: $totalNew new episodes');
  }

  Future<void> _enqueueAutoDownloads(
    Subscription sub,
    int newEpisodeCount,
  ) async {
    try {
      final episodes = await _episodeRepo.getByPodcastId(sub.id);
      final wifiOnly = _settingsRepo.getWifiOnlyDownload();

      // Take the newest episodes up to the new episode count
      final toDownload = episodes.take(newEpisodeCount);
      for (final episode in toDownload) {
        await _downloadRepo.createDownload(
          episodeId: episode.id,
          audioUrl: episode.audioUrl,
          wifiOnly: wifiOnly,
        );
      }

      _logger?.d(
        'Enqueued $newEpisodeCount downloads for "${sub.title}"',
      );
    } catch (e, stack) {
      _logger?.e(
        'Failed to enqueue downloads for "${sub.title}"',
        error: e,
        stackTrace: stack,
      );
    }
  }
}
```

- [ ] **Step 5: Export from `audiflow_domain.dart`**

```dart
export 'src/features/feed/services/background_refresh_service.dart';
```

- [ ] **Step 6: Run tests to verify they pass**

```bash
cd packages/audiflow_domain && flutter test test/features/feed/services/background_refresh_service_test.dart
```

Expected: PASS

- [ ] **Step 7: Commit**

```bash
git add packages/audiflow_domain/lib/src/features/feed/services/background_refresh_service.dart packages/audiflow_domain/test/features/feed/services/background_refresh_service_test.dart packages/audiflow_domain/lib/audiflow_domain.dart
git commit -m "feat(domain): add BackgroundRefreshService with prioritized sync"
```

---

### Task 8: Create `BackgroundTaskRegistrar` and `backgroundCallback`

**Files:**
- Create: `packages/audiflow_app/lib/app/background/background_task_registrar.dart`
- Create: `packages/audiflow_app/lib/app/background/background_callback.dart`

- [ ] **Step 1: Create `BackgroundTaskRegistrar`**

Create `background_task_registrar.dart`:

```dart
import 'package:workmanager/workmanager.dart';

/// Manages registration of periodic background refresh tasks
/// via `workmanager`.
class BackgroundTaskRegistrar {
  BackgroundTaskRegistrar._();

  static const taskName = 'com.audiflow.backgroundRefresh';

  /// Registers a periodic background refresh task.
  ///
  /// Replaces any existing task with the new [intervalMinutes].
  static Future<void> register({required int intervalMinutes}) async {
    await Workmanager().registerPeriodicTask(
      taskName,
      taskName,
      frequency: Duration(minutes: intervalMinutes),
      constraints: Constraints(
        networkType: NetworkType.connected,
      ),
      existingWorkPolicy: ExistingWorkPolicy.replace,
    );
  }

  /// Cancels the registered background refresh task.
  static Future<void> cancel() async {
    await Workmanager().cancelByUniqueName(taskName);
  }
}
```

- [ ] **Step 2: Create `backgroundCallback`**

Create `background_callback.dart`:

```dart
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:isar_community/isar.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';

import 'background_task_registrar.dart';

/// Top-level callback for workmanager background tasks.
///
/// Must be a top-level or static function. Runs in a separate
/// Dart isolate with no access to the foreground app's state.
@pragma('vm:entry-point')
void backgroundCallback() {
  Workmanager().executeTask((taskName, inputData) async {
    if (taskName != BackgroundTaskRegistrar.taskName) return true;

    final logger = Logger(
      printer: PrefixPrinter(PrettyPrinter(methodCount: 0)),
    );

    try {
      // Bootstrap dependencies
      final dir = await getApplicationDocumentsDirectory();
      final isar = await Isar.open(
        [
          SubscriptionSchema,
          EpisodeSchema,
          DownloadTaskSchema,
          PlaybackHistorySchema,
          SmartPlaylistEntitySchema,
          SmartPlaylistGroupEntitySchema,
          PodcastViewPreferenceSchema,
          QueueItemSchema,
          EpisodeTranscriptSchema,
          TranscriptSegmentSchema,
          EpisodeChapterSchema,
        ],
        directory: dir.path,
        name: 'audiflow',
      );

      final prefs = await SharedPreferences.getInstance();
      final ds = SharedPreferencesDataSource(prefs);
      final settingsRepo = AppSettingsRepositoryImpl(ds);

      // Check WiFi-only constraint
      if (settingsRepo.getWifiOnlySync()) {
        final connectivityResult = await Connectivity().checkConnectivity();
        if (!connectivityResult.contains(ConnectivityResult.wifi)) {
          logger.i('WiFi-only sync enabled but not on WiFi, skipping');
          await isar.close();
          return true;
        }
      }

      final dio = Dio(
        BaseOptions(
          connectTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 15),
        ),
      );

      // Create repositories with manual DI
      final subLocalDs = SubscriptionLocalDatasource(isar);
      final subRepo = SubscriptionRepositoryImpl(datasource: subLocalDs);

      final episodeLocalDs = EpisodeLocalDatasource(isar);
      final episodeRepo = EpisodeRepositoryImpl(datasource: episodeLocalDs);

      final downloadLocalDs = DownloadLocalDatasource(isar);
      final downloadRepo = DownloadRepositoryImpl(datasource: downloadLocalDs);

      final feedParser = FeedParserService(logger: logger);

      final syncExecutor = FeedSyncExecutor(
        subscriptionRepo: subRepo,
        episodeRepo: episodeRepo,
        settingsRepo: settingsRepo,
        feedParser: feedParser,
        dio: dio,
        logger: logger,
      );

      final notificationService = BackgroundNotificationService(
        logger: logger,
      );

      final refreshService = BackgroundRefreshService(
        subscriptionRepo: subRepo,
        episodeRepo: episodeRepo,
        downloadRepo: downloadRepo,
        settingsRepo: settingsRepo,
        syncExecutor: syncExecutor,
        notificationService: notificationService,
        logger: logger,
      );

      await refreshService.execute();

      // Cleanup
      dio.close();
      await isar.close();
    } catch (e, stack) {
      logger.e(
        'Background refresh failed',
        error: e,
        stackTrace: stack,
      );
    }

    return true;
  });
}
```

**Note:** The exact datasource and repository constructor names above are illustrative. The implementer must check the actual constructor signatures of `SubscriptionLocalDatasource`, `SubscriptionRepositoryImpl`, `EpisodeLocalDatasource`, `EpisodeRepositoryImpl`, `DownloadLocalDatasource`, and `DownloadRepositoryImpl` and adjust accordingly.

- [ ] **Step 3: Verify build compiles**

```bash
cd packages/audiflow_app && flutter analyze
```

- [ ] **Step 4: Commit**

```bash
git add packages/audiflow_app/lib/app/background/
git commit -m "feat(app): add background task registrar and workmanager callback"
```

---

### Task 9: Wire up workmanager in `main.dart` and `AppLifecycleObserver`

**Files:**
- Modify: `packages/audiflow_app/lib/main.dart`
- Modify: `packages/audiflow_app/lib/app/app_lifecycle_observer.dart`

- [ ] **Step 1: Initialize workmanager in `_startApp`**

In `main.dart`, add imports:

```dart
import 'package:workmanager/workmanager.dart';
import 'app/background/background_callback.dart';
import 'app/background/background_task_registrar.dart';
```

After the `_runCacheEviction` call (before `runApp`), add:

```dart
  // Initialize background refresh
  await Workmanager().initialize(backgroundCallback, isInDebugMode: false);
  final settingsRepo = container.read(appSettingsRepositoryProvider);
  if (settingsRepo.getAutoSync()) {
    await BackgroundTaskRegistrar.register(
      intervalMinutes: settingsRepo.getSyncIntervalMinutes(),
    );
  }
```

- [ ] **Step 2: Update `AppLifecycleObserver` to re-register on settings change**

In `app_lifecycle_observer.dart`, add import and update `_onResume`:

```dart
import '../app/background/background_task_registrar.dart';
```

Update `_onResume` to also re-register the background task:

```dart
  void _onResume() {
    _syncFeeds(forceRefresh: false);
    _updateBackgroundRegistration();
  }

  Future<void> _updateBackgroundRegistration() async {
    final settingsRepo = ref.read(appSettingsRepositoryProvider);
    if (settingsRepo.getAutoSync()) {
      await BackgroundTaskRegistrar.register(
        intervalMinutes: settingsRepo.getSyncIntervalMinutes(),
      );
    } else {
      await BackgroundTaskRegistrar.cancel();
    }
  }
```

- [ ] **Step 3: Verify build compiles**

```bash
cd packages/audiflow_app && flutter analyze
```

- [ ] **Step 4: Commit**

```bash
git add packages/audiflow_app/lib/main.dart packages/audiflow_app/lib/app/app_lifecycle_observer.dart
git commit -m "feat(app): wire workmanager initialization and lifecycle re-registration"
```

---

### Task 10: iOS and Android platform configuration

**Files:**
- Modify: `packages/audiflow_app/ios/Runner/Info.plist`
- Modify: `packages/audiflow_app/android/app/src/main/AndroidManifest.xml`

- [ ] **Step 1: Add BGTaskScheduler identifiers to iOS Info.plist**

Add to `Info.plist`:

```xml
<key>BGTaskSchedulerPermittedIdentifiers</key>
<array>
    <string>com.audiflow.backgroundRefresh</string>
</array>
```

Ensure Background Modes capability includes `fetch` and `processing` in Xcode.

- [ ] **Step 2: Add notification permission to AndroidManifest.xml**

Add permission (if not already present):

```xml
<uses-permission android:name="android.permission.POST_NOTIFICATIONS" />
```

- [ ] **Step 3: Commit**

```bash
git add packages/audiflow_app/ios/Runner/Info.plist packages/audiflow_app/android/app/src/main/AndroidManifest.xml
git commit -m "chore(platform): add background task and notification permissions"
```

---

### Task 11: Extend Settings UI with notification toggle and interval options

**Files:**
- Modify: `packages/audiflow_app/lib/features/settings/presentation/screens/feed_sync_settings_screen.dart`
- Modify: `packages/audiflow_app/lib/l10n/app_en.arb`
- Modify: `packages/audiflow_app/lib/l10n/app_ja.arb`

- [ ] **Step 1: Add localization strings**

In `app_en.arb`, add:

```json
"feedSyncNotifyNewEpisodesTitle": "New episode notifications",
"feedSyncNotifyNewEpisodesSubtitle": "Show a notification when new episodes are found during background refresh",
"feedSyncInterval15min": "Every 15 minutes",
"feedSyncInterval3hours": "Every 3 hours",
"feedSyncInterval6hours": "Every 6 hours",
"feedSyncInterval12hours": "Every 12 hours"
```

Add equivalent Japanese strings in `app_ja.arb`.

- [ ] **Step 2: Run localization generation**

```bash
cd packages/audiflow_app && flutter gen-l10n
```

- [ ] **Step 3: Add notification toggle and more interval options to `FeedSyncSettingsScreen`**

Add `SwitchListTile` for `notifyNewEpisodes` after the WiFi-only toggle. Add `15`, `180`, `360`, `720` minute options to the interval dropdown. Re-register background task when interval changes:

```dart
// After wifiOnly SwitchListTile, inside the autoSync Visibility block:
SwitchListTile(
  title: Text(l10n.feedSyncNotifyNewEpisodesTitle),
  subtitle: Text(l10n.feedSyncNotifyNewEpisodesSubtitle),
  value: repo.getNotifyNewEpisodes(),
  onChanged: (v) => _onNotifyToggleChanged(context, ref, repo, v),
),
```

The notification toggle requires Android 13+ permission handling:

```dart
Future<void> _onNotifyToggleChanged(
  BuildContext context,
  WidgetRef ref,
  AppSettingsRepository repo,
  bool enabled,
) async {
  if (!enabled) {
    _update(ref, () => repo.setNotifyNewEpisodes(false));
    return;
  }

  // Check and request notification permission (Android 13+)
  final status = await Permission.notification.status;
  if (status.isGranted) {
    _update(ref, () => repo.setNotifyNewEpisodes(true));
    return;
  }

  if (status.isPermanentlyDenied) {
    if (!context.mounted) return;
    // Guide user to system settings
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Permission required'),
        content: const Text(
          'Notification permission was denied. '
          'Please enable it in system settings.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              openAppSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
    return;
  }

  // Request permission
  final result = await Permission.notification.request();
  if (result.isGranted) {
    _update(ref, () => repo.setNotifyNewEpisodes(true));
  }
  // If denied, toggle stays off (no setting saved)
}
```

Add import: `import 'package:permission_handler/permission_handler.dart';`

Update `_update` to also re-register the background task when sync settings change:

```dart
void _update(WidgetRef ref, Future<void> Function() setter) {
  setter();
  ref.invalidate(appSettingsRepositoryProvider);
  _updateBackgroundRegistration(ref);
}

void _updateBackgroundRegistration(WidgetRef ref) {
  final repo = ref.read(appSettingsRepositoryProvider);
  if (repo.getAutoSync()) {
    BackgroundTaskRegistrar.register(
      intervalMinutes: repo.getSyncIntervalMinutes(),
    );
  } else {
    BackgroundTaskRegistrar.cancel();
  }
}
```

- [ ] **Step 4: Verify build compiles**

```bash
cd packages/audiflow_app && flutter analyze
```

- [ ] **Step 5: Commit**

```bash
git add packages/audiflow_app/lib/features/settings/presentation/screens/feed_sync_settings_screen.dart packages/audiflow_app/lib/l10n/
git commit -m "feat(ui): add notification toggle and interval options to feed sync settings"
```

---

### Task 12: Add per-podcast auto-download toggle

**Files:**
- Modify: podcast detail screen (find the subscription options area)
- Modify: `packages/audiflow_domain/lib/src/features/subscription/repositories/subscription_repository.dart`
- Modify: `packages/audiflow_domain/lib/src/features/subscription/repositories/subscription_repository_impl.dart`

- [ ] **Step 1: Add `updateAutoDownload` to `SubscriptionRepository`**

```dart
/// Updates the auto-download setting for a subscription.
Future<void> updateAutoDownload(int id, {required bool autoDownload});
```

- [ ] **Step 2: Implement in `SubscriptionRepositoryImpl`**

```dart
@override
Future<void> updateAutoDownload(int id, {required bool autoDownload}) async {
  await _datasource.updateAutoDownload(id, autoDownload: autoDownload);
}
```

Add the corresponding method to `SubscriptionLocalDatasource`.

- [ ] **Step 3: Add auto-download toggle to podcast detail UI**

Find the podcast detail screen's subscription options area and add a `SwitchListTile`:

```dart
SwitchListTile(
  title: Text(l10n.podcastAutoDownloadTitle),
  subtitle: Text(l10n.podcastAutoDownloadSubtitle),
  value: subscription.autoDownload,
  onChanged: (v) async {
    await ref.read(subscriptionRepositoryProvider).updateAutoDownload(
      subscription.id,
      autoDownload: v,
    );
    // Invalidate to refresh UI
    ref.invalidate(/* relevant provider */);
  },
),
```

- [ ] **Step 4: Add localization strings**

In `app_en.arb`:

```json
"podcastAutoDownloadTitle": "Auto-download new episodes",
"podcastAutoDownloadSubtitle": "Download new episodes automatically during background refresh (WiFi only)"
```

Add equivalent Japanese strings.

- [ ] **Step 5: Run localization generation and verify**

```bash
cd packages/audiflow_app && flutter gen-l10n && flutter analyze
```

- [ ] **Step 6: Commit**

```bash
git add packages/audiflow_domain/lib/src/features/subscription/ packages/audiflow_app/lib/ packages/audiflow_app/lib/l10n/
git commit -m "feat(ui): add per-podcast auto-download toggle"
```

---

### Task 13: Run full test suite and fix issues

**Files:**
- All test files

- [ ] **Step 1: Run all domain tests**

```bash
cd packages/audiflow_domain && flutter test
```

Fix any failures.

- [ ] **Step 2: Run all app tests**

```bash
cd packages/audiflow_app && flutter test
```

Fix any failures.

- [ ] **Step 3: Run analyzer across all packages**

```bash
melos run analyze
```

Or:

```bash
cd packages/audiflow_domain && flutter analyze
cd packages/audiflow_app && flutter analyze
cd packages/audiflow_core && dart analyze
```

Fix any warnings.

- [ ] **Step 4: Commit any fixes**

```bash
git add -A
git commit -m "fix: resolve test failures and analyzer warnings"
```

---

### Task 14: Final verification and cleanup

- [ ] **Step 1: Run full test suite**

```bash
melos run test
```

All tests must pass.

- [ ] **Step 2: Run analyzer**

```bash
flutter analyze
```

Zero issues required.

- [ ] **Step 3: Verify code generation is up to date**

```bash
melos run codegen
```

No diff should appear.

- [ ] **Step 4: Final commit if any changes**

```bash
git status
# If changes exist:
git add -A
git commit -m "chore: final cleanup and codegen update"
```
