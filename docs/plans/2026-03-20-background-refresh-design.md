# Background Feed Refresh

## Overview

Add native OS background task scheduling (iOS BGTaskScheduler, Android WorkManager) so podcast feeds refresh automatically while the app is closed. Users control the refresh interval, per-podcast auto-download, and new episode notifications.

## Decisions

| Decision | Choice | Rationale |
|----------|--------|-----------|
| Scheduling library | `workmanager` Flutter plugin | Unified Dart API for iOS BGTaskScheduler + Android WorkManager, avoids maintaining native code |
| Background service architecture | Standalone service with manual DI | Background callback runs in separate isolate, no Riverpod access; reuse existing repository classes with manual wiring |
| Refresh interval | User-configurable (15m/30m/1h/3h/6h/12h/manual) | Existing settings infrastructure supports this; 1h default |
| Prioritization | Sort by `lastAccessedAt` DESC | Users care most about recently listened podcasts; stops when time budget exhausted |
| Auto-download | Per-podcast toggle, WiFi only | Gives power users fine control without draining mobile data |
| Notifications | User-configurable toggle for new episodes | Grouped summary notification, not per-episode spam |
| Failure handling | Silent retry on next interval | Background tasks are inherently unreliable; transient failures resolve themselves |
| Time budget | 25 seconds hard limit | iOS `BGProcessingTask` gives ~30s; 5s buffer for cleanup. Same limit on Android for consistency |
| iOS task type | `BGProcessingTask` | `workmanager` with `networkType: connected` constraint maps to `BGProcessingTask` on iOS, which gives more execution time than `BGAppRefreshTask` but may run less frequently (deferred to charging/idle) |
| Sync coordination | Timestamp-based deduplication | Both foreground and background check `lastRefreshedAt` against sync interval; concurrent runs are harmless (upserts are idempotent) but avoided via shared timestamp |
| Background error pattern | Log-and-continue (no `Either`) | Background service has no UI consumer for typed errors; diverges from repository `Either` pattern intentionally |

## Architecture

```
┌──────────────────────────────────────────────────────┐
│                    audiflow_app                        │
│                                                        │
│  main.dart                                             │
│    ├─ Workmanager.initialize(backgroundCallback)       │
│    └─ registerBackgroundRefresh() on startup            │
│                                                        │
│  AppLifecycleObserver (existing)                       │
│    └─ Re-register task if settings changed on resume   │
│                                                        │
│  Settings UI (extend existing)                         │
│    ├─ Refresh interval picker                          │
│    ├─ New episode notification toggle                  │
│    └─ Per-podcast auto-download toggle (podcast page)  │
└────────────────────────┬─────────────────────────────┘
                         │
┌────────────────────────▼─────────────────────────────┐
│                   audiflow_domain                      │
│                                                        │
│  BackgroundRefreshService (NEW)                        │
│    ├─ bootstrap() — open Isar, create repos manually   │
│    ├─ execute() — prioritized feed sync loop           │
│    ├─ dispose() — close Isar, clean up                 │
│    └─ Reuses: FeedRepository, SubscriptionRepository,  │
│       EpisodeRepository, DownloadRepository,           │
│       AppSettingsRepository                            │
│                                                        │
│  BackgroundNotificationService (NEW)                   │
│    └─ Show grouped local notification for new episodes │
│                                                        │
│  Subscription model (EXTEND)                           │
│    └─ Add autoDownload bool field                      │
│                                                        │
│  AppSettingsRepository (EXTEND)                        │
│    └─ Add notifyNewEpisodes getter/setter              │
└──────────────────────────────────────────────────────┘
```

## Extracting Reusable Sync Logic

The existing `FeedSyncService` is tightly coupled to Riverpod (`Ref`-based dependency resolution). The background isolate cannot use Riverpod. To avoid duplicating feed sync logic:

**Extract a pure `FeedSyncExecutor` class** that accepts dependencies via constructor injection:

```dart
/// Pure feed sync logic, usable from both foreground (via Riverpod) and background (via manual DI).
class FeedSyncExecutor {
  FeedSyncExecutor({
    required SubscriptionRepository subscriptionRepo,
    required EpisodeRepository episodeRepo,
    required FeedRemoteDataSource feedRemoteDataSource,
    required AppSettingsRepository settingsRepo,
    required Logger logger,
  });

  Future<SingleFeedSyncResult> syncFeed(Subscription sub, {bool forceRefresh = false});
  Future<FeedSyncResult> syncAll(List<Subscription> subs, {bool forceRefresh = false});
}
```

- `FeedSyncService` (foreground) wraps `FeedSyncExecutor`, obtaining dependencies from `Ref`
- `BackgroundRefreshService` creates `FeedSyncExecutor` with manually constructed dependencies
- Core logic (RSS fetch, early-termination parse, upsert) lives in one place

This is a targeted refactor of `FeedSyncService`, not a rewrite. Smart playlist resolution and transcript/chapter extraction are skipped in background mode (not time-critical; handled on next foreground sync).

## Cross-Isolate Data Visibility

Isar supports concurrent access from multiple isolates on the same database. However, Isar watchers in the foreground isolate do **not** fire when the background isolate writes data.

**Solution:** When the app resumes after being backgrounded, `AppLifecycleObserver._onResume()` already triggers a foreground sync which invalidates `librarySubscriptionsProvider`. This ensures:
- If the background task wrote new episodes, the foreground picks them up on resume
- The `lastRefreshedAt` timestamps written by the background task cause `_shouldSync()` to skip recently-refreshed feeds, avoiding redundant work

No additional coordination mechanism is needed because:
- Upserts are idempotent (same GUID is not duplicated)
- `lastRefreshedAt` acts as a shared timestamp for both paths
- The worst case (both run simultaneously) wastes some network but produces correct data

## Background Refresh Flow

1. OS triggers periodic background task
2. `backgroundCallback()` invoked in fresh Dart isolate
3. `BackgroundRefreshService.bootstrap()`:
   - Open Isar instance (same DB name `audiflow`, shared with foreground)
   - Create `SharedPreferences` instance
   - Instantiate repositories and `FeedSyncExecutor` with manual dependency injection
   - Create named logger
4. Check preconditions:
   - Is auto-sync enabled? If not, return early
   - Is WiFi-only enabled? Check connectivity via `connectivity_plus` (method channels work in workmanager callbacks since Flutter engine is initialized), return early if on mobile data
5. Query subscriptions sorted by `lastAccessedAt` DESC (most recently interacted first); null `lastAccessedAt` falls back to `subscribedAt` for sorting
6. For each subscription in priority order:
   - Skip if `lastRefreshedAt` is within the configured sync interval
   - Fetch RSS feed via Dio
   - Parse with early termination using known episode GUIDs
   - Upsert new episodes to Isar
   - Track new episode count per podcast
   - If `subscription.autoDownload` is true AND on WiFi: enqueue download tasks
   - Update `lastRefreshedAt` timestamp
   - Check elapsed time; if 25s exceeded, stop processing
7. Post-sync:
   - If new episodes found AND notifications enabled: show grouped local notification
   - Close Isar, clean up resources

## Data Model Changes

### Subscription (extend existing Isar collection)

| Field | Type | Default | Notes |
|-------|------|---------|-------|
| `autoDownload` | `bool` | `false` | Per-podcast auto-download toggle |

### AppSettingsRepository (extend existing)

| Setting | Key | Type | Default | Notes |
|---------|-----|------|---------|-------|
| New episode notifications | `notifyNewEpisodes` | `bool` | `true` | Toggle for background refresh notifications |

### Existing settings already available

| Setting | Key | Current Default |
|---------|-----|-----------------|
| Auto sync | `autoSync` | `true` |
| Sync interval (minutes) | `syncIntervalMinutes` | `60` |
| WiFi-only sync | `wifiOnlySync` | `false` |
| WiFi-only download | `wifiOnlyDownload` | `true` |

## New Dependencies

| Package | Purpose |
|---------|---------|
| `workmanager` | Cross-platform background task scheduling |
| `flutter_local_notifications` | Local notification display |
| `connectivity_plus` | Network type check (already in audiflow_domain) |

## New Files

### audiflow_domain

| File | Purpose |
|------|---------|
| `features/feed/services/feed_sync_executor.dart` | Pure feed sync logic extracted from `FeedSyncService`, usable in both foreground and background |
| `features/feed/services/background_refresh_service.dart` | Standalone background sync service with manual DI, wraps `FeedSyncExecutor` |
| `features/feed/services/background_notification_service.dart` | Local notification display for new episodes |

### audiflow_app

| File | Purpose |
|------|---------|
| `app/background/background_callback.dart` | Top-level workmanager callback (must be top-level function with `@pragma('vm:entry-point')`) |
| `app/background/background_task_registrar.dart` | Register/unregister periodic tasks based on settings |

## Workmanager Registration

```dart
// background_callback.dart — MUST be top-level function
@pragma('vm:entry-point')
void backgroundCallback() {
  Workmanager().executeTask((taskName, inputData) async {
    if (taskName == BackgroundTaskRegistrar.taskName) {
      final service = BackgroundRefreshService();
      try {
        await service.bootstrap();
        await service.execute();
      } finally {
        await service.dispose();
      }
    }
    return true;
  });
}
```

```dart
// In main.dart during app startup
await Workmanager().initialize(backgroundCallback, isInDebugMode: false);

// Register periodic task
await BackgroundTaskRegistrar.register(
  intervalMinutes: settingsRepo.getSyncIntervalMinutes(),
);
```

```dart
// background_task_registrar.dart
class BackgroundTaskRegistrar {
  static const taskName = 'com.audiflow.backgroundRefresh';

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

  static Future<void> cancel() async {
    await Workmanager().cancelByUniqueName(taskName);
  }
}
```

## Notification Design

Single grouped notification when background refresh finds new episodes:

**Title:** "New episodes available"
**Body:** "3 new episodes from Podcast A, Podcast B, and 1 other"

Tapping the notification opens the app to the library screen. No per-episode notifications to avoid spam.

## iOS-Specific Configuration

- Register `BGTaskScheduler` identifier in `Info.plist`
- Add `BGTaskSchedulerPermittedIdentifiers` entry
- Background Modes capability: `fetch` and `processing`

## Android-Specific Configuration

- `workmanager` handles WorkManager setup automatically
- Add notification channel for background refresh notifications
- Notification permission request (Android 13+) — see Notification Permission Flow below

## Notification Permission Flow (Android 13+)

Android 13+ requires `POST_NOTIFICATIONS` runtime permission. The app requests it when the user **enables the "New episode notifications" toggle** in settings:

1. User toggles "New episode notifications" ON
2. App checks permission status via `permission_handler` (already a dependency)
3. If not granted: show rationale dialog, then request permission
4. If granted: save setting, done
5. If denied: revert toggle to OFF, show explanation that notifications require permission
6. If permanently denied: revert toggle, guide user to system settings

Notifications degrade gracefully — if permission is denied, background refresh still runs and updates feeds; the user just does not receive notification alerts.

## Settings UI Changes

### Existing Settings Page (extend)

Add under the existing sync section:
- **New episode notifications** toggle (on/off)

### Podcast Detail Page (extend)

Add to podcast subscription options:
- **Auto-download new episodes** toggle (per-podcast)

## Testing Strategy

### Unit Tests
- `BackgroundRefreshService`: mock repositories, verify prioritization order, time budget cutoff, auto-download enqueuing
- `BackgroundNotificationService`: verify grouped notification content formatting
- `BackgroundTaskRegistrar`: verify registration with correct interval and constraints

### Integration Tests
- End-to-end background callback: verify Isar bootstrap, sync execution, and cleanup
- Settings change triggers re-registration

## Error Handling

- All exceptions caught and logged; never crash the background task
- Network failures: silently skip, retry on next interval
- Isar open failure: log and return (likely foreground app has lock)
- Individual feed parse failure: skip that feed, continue with others

## Important Notes

- **Auto-download enqueuing vs execution:** The background service only writes `DownloadTask` records to Isar (status: `pending`). Actual download execution happens via `DownloadQueueService` when the app is next in foreground. This avoids the complexity of running the full download pipeline (file I/O, progress tracking) in the background isolate.
- **Isar index on `lastAccessedAt`:** Not needed. Typical subscription counts (tens to low hundreds) make in-memory sorting negligible. Can add later if subscription counts grow significantly.

## Out of Scope

- Smart/adaptive refresh intervals per podcast
- Failure UI indicators
- Exponential backoff retry
- Background audio download progress tracking
- Push notification from server (requires backend)
