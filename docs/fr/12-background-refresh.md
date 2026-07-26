---
refs:
  id: fr:12-background-refresh
  kind: fr
  title: "Background refresh and notifications"
  related:
    - fr:03-subscription-feeds
  modules:
    - packages/audiflow_app/lib/app/background/
    - packages/audiflow_app/lib/app/notification/
    - packages/audiflow_domain/lib/src/features/feed/services/background_refresh_service.dart
    - packages/audiflow_domain/lib/src/features/feed/services/background_notification_service.dart
    - packages/audiflow_domain/lib/src/features/feed/services/feed_sync_executor.dart
    - packages/audiflow_domain/lib/src/features/feed/models/new_episode_notification.dart
    - packages/audiflow_domain/lib/src/features/download/services/auto_download_enqueuer.dart
---

# FR 12: Background refresh and notifications

> Refreshes subscribed podcast feeds via the operating system's background task scheduler while the app is closed, then notifies the listener about each newly discovered episode.

## Purpose

Listeners expect new podcast episodes to be ready when they open the app, not to wait for a manual pull-to-refresh. Foreground feed sync (FR 03) only runs while the app is open, so a listener who never explicitly refreshes can miss episodes for days. This feature closes that gap: it lets the operating system wake the app periodically, sync feeds in the background, and surface results through local notifications.

It exists to make Audiflow feel current without the listener doing anything. New episodes appear in the library on next launch, optionally download themselves over Wi-Fi, and a tap on a notification takes the listener straight to the episode they care about. All of this runs within tight OS-imposed time and battery constraints, so the feature is built to do the most valuable work first and stop cleanly when its budget runs out.

## User-visible Behavior

- Normal case: With auto-sync enabled, the OS periodically wakes the app in the background at the listener's chosen interval (15 minutes to 12 hours). Subscribed feeds are refreshed, newly published episodes are stored locally, and — if new-episode notifications are on — the listener receives one notification per new episode (podcast name as the title, episode title as the body). Tapping a notification opens the app directly on that episode's detail screen.
- Prioritized work: Recently listened-to podcasts are refreshed first. If the background run hits its time budget before every feed is processed, the remaining feeds are simply picked up on a later run or on the next foreground sync, so the listener always sees fresh data for the podcasts they engage with most.
- Auto-download: For any podcast the listener has marked for auto-download, newly discovered episodes are queued for download. The actual file transfer is handled later by the download/queue feature (FR 05); the background run only enqueues the work and, when downloads are pending, schedules a separate background download task.
- Settings change: When the listener changes the refresh interval, Wi-Fi-only sync, or the notification toggle, the periodic background task is re-registered so the new preference takes effect; disabling auto-sync cancels the task entirely.
- Notification permission: The OS permission prompt appears only when the listener turns the new-episode notification toggle on — never at app launch. If permission was permanently denied, the toggle explains the situation and offers a shortcut to the system settings instead of re-prompting.
- Edge / failure case: Network errors, feed parse failures, or an unavailable database are caught and logged without crashing the background task. A failed run resolves itself on the next interval. If Wi-Fi-only sync is enabled and the device is on cellular, the run is skipped. Notifications degrade gracefully — if notification permission was never granted, refresh still updates feeds, the listener just receives no alerts. Already-played episodes are excluded from notifications so the listener is not pinged about content they have already heard.
- Recovery / fallback: Because the background isolate cannot signal the running UI, the foreground app reconciles on resume — it re-syncs and reloads subscriptions so any episodes written in the background become visible. Shared last-refreshed timestamps keep foreground and background runs from doing redundant work.

## Capabilities

- Schedules a periodic background feed-refresh task through the OS background scheduler (`workmanager`), with the listener-configurable interval and a network-connectivity constraint.
- Runs feed sync inside an isolated background context with no access to the app's normal dependency graph, bootstrapping its own database connection and reusing the shared feed-sync logic (`FeedSyncExecutor`) so foreground and background sync stay consistent.
- Reads sync-related settings (auto-sync, Wi-Fi-only sync, notification toggle, interval, Wi-Fi-only download) from a snapshot passed into the background task, since live settings storage is unavailable in the background isolate.
- Processes subscriptions in priority order — most recently accessed first — and stops cleanly once a fixed time budget is exhausted, leaving unfinished feeds for a later run.
- Detects newly published episodes and removes episodes that have dropped out of a feed, keeping the local store aligned with the publisher's current feed.
- Enqueues downloads for newly discovered episodes of auto-download-enabled podcasts, and schedules a follow-up background download task when pending or stuck downloads exist.
- Builds per-episode notification payloads (capped per refresh cycle), skipping episodes the listener has already played, and shows one local notification per new episode.
- Handles notification taps and cold-start launches by decoding the notification payload and deep-linking to the corresponding episode detail screen.
- Re-registers or cancels the background task in response to settings changes and app lifecycle events so the schedule always reflects current preferences.

## Boundaries

- Foreground feed subscription, manual refresh, and feed management are owned by FR 03 (Subscription and feeds); this feature only covers the unattended background path and its notifications.
- Actual download file transfer, progress tracking, and the download queue belong to FR 05 (Episode download and queue); background refresh only enqueues download work and schedules the download task.
- It does not perform smart playlist resolution or transcript/chapter extraction in the background — those time-consuming steps are left to the next foreground sync.
- It does not provide adaptive or per-podcast refresh intervals, exponential-backoff retry UI, failure indicators in the interface, or app-icon badge counts.
- It does not deliver server-pushed notifications; all notifications are local, generated on-device from background-refresh results.
- Settings screen presentation (the interval picker, notification toggle, per-podcast auto-download toggle) is part of the settings/feature UI, not this feature's core logic.

## Traceability

- **Source docs**:
  - `docs/plans/2026-03-20-background-refresh-plan.md`
  - `docs/plans/2026-03-20-background-refresh-design.md`
  - `docs/superpowers/plans/2026-04-02-per-episode-notification-plan.md`
  - `docs/superpowers/specs/2026-04-02-per-episode-notification-design.md`
- **Source files**:
  - `packages/audiflow_app/lib/app/background/background_callback.dart`
  - `packages/audiflow_app/lib/app/background/background_task_registrar.dart`
  - `packages/audiflow_app/lib/app/background/background_settings_repository.dart`
  - `packages/audiflow_app/lib/app/notification/notification_tap_handler.dart`
  - `packages/audiflow_domain/lib/src/features/feed/services/background_refresh_service.dart`
  - `packages/audiflow_domain/lib/src/features/feed/services/background_notification_service.dart`
  - `packages/audiflow_domain/lib/src/features/feed/services/feed_sync_executor.dart`
  - `packages/audiflow_domain/lib/src/features/feed/models/new_episode_notification.dart`
  - `packages/audiflow_domain/lib/src/features/download/services/auto_download_enqueuer.dart`
- **Related FR**: 03-subscription-feeds.md
