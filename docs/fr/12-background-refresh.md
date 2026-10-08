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
    - packages/audiflow_domain/lib/src/features/feed/services/notification_artwork_files.dart
    - packages/audiflow_domain/lib/src/features/feed/services/notification_artwork_encoder.dart
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

- Normal case: With auto-sync enabled, the OS periodically wakes the app in the background at the listener's chosen interval (15 minutes to 12 hours). Subscribed feeds are refreshed, newly published episodes are stored locally, and — if new-episode notifications are on — the listener receives one notification per new episode (episode title as the title; podcast name with publish date and duration on a second line as the iOS subtitle; podcast name as the Android sub text, with date and duration as the expanded summary; a plain-text, length-capped excerpt of the show notes, keeping its line breaks, as the body, expanded in full on Android and on iOS long-press; podcast artwork as the thumbnail and iOS long-press image. Dates and durations follow the app's language setting, or the system language when none is set. Missing parts — artwork that cannot be fetched, an episode without show notes or duration — are simply left out). Tapping a notification opens the app directly on that episode's detail screen.
- Prioritized work: Recently listened-to podcasts are refreshed first. If the background run hits its time budget before every feed is processed, the remaining feeds are simply picked up on a later run or on the next foreground sync, so the listener always sees fresh data for the podcasts they engage with most.
- Auto-download: For any podcast the listener has marked for auto-download, newly discovered episodes are queued for download. The actual file transfer is handled later by the download/queue feature (FR 05); the background run enqueues the work and, when downloads are pending, schedules a separate background download task. On iOS, where that download task tends to run only while the device is charging, the refresh also spends whatever is left of its own short run window downloading pending episodes; a download cut off by the window resumes from its partial file on a later run.
- Settings change: When the listener changes the refresh interval, Wi-Fi-only sync, the notification toggle, or the app language, the periodic background task is re-registered so the new preference takes effect; disabling auto-sync cancels the task entirely.
- Notification permission: The OS permission prompt appears only when the listener turns the new-episode notification toggle on — never at app launch. If permission was permanently denied, the toggle explains the situation and offers a shortcut to the system settings instead of re-prompting. The toggle shows on only when the preference is on and the OS permission is granted, so a fresh install (preference on by default, permission not yet asked) or a listener who revoked permission in system settings sees it off; the state is re-checked whenever the screen opens or the app returns to the foreground. When permission is found missing, the preference itself is saved as off, so granting permission later in system settings does not silently turn notifications on; the listener re-enables them with the toggle. Taps while a permission dialog is already open are ignored.
- Edge / failure case: Network errors, feed parse failures, or an unavailable database are caught and logged without crashing the background task. A failed run resolves itself on the next interval. If Wi-Fi-only sync is enabled and the device is on cellular, the run is skipped. Notifications degrade gracefully — if notification permission was never granted, refresh still updates feeds, the listener just receives no alerts. Already-played episodes are excluded from notifications so the listener is not pinged about content they have already heard.
- Recovery / fallback: Because the background isolate cannot signal the running UI, the foreground app reconciles on resume — it re-syncs and reloads subscriptions so any episodes written in the background become visible. Shared last-refreshed timestamps keep foreground and background runs from doing redundant work.

## Capabilities

- Schedules a periodic background feed-refresh task through the OS background scheduler (`workmanager`), with the listener-configurable interval and a network-connectivity constraint.
- Runs feed sync inside an isolated background context with no access to the app's normal dependency graph, bootstrapping its own database connection and reusing the shared feed-sync logic (`FeedSyncExecutor`) so foreground and background sync stay consistent.
- Reads sync-related settings (auto-sync, Wi-Fi-only sync, notification toggle, interval, Wi-Fi-only download) and the language setting from a snapshot passed into the background task, since live settings storage is unavailable in the background isolate.
- Processes subscriptions in priority order — most recently accessed first — and stops cleanly once a fixed time budget is exhausted, leaving unfinished feeds for a later run.
- Detects newly published episodes and removes episodes that have dropped out of a feed, keeping the local store aligned with the publisher's current feed. Their downloads, manual and auto alike, are removed with them (FR 05); a download another isolate is still writing keeps its episode until a later sync can remove both.
- Writes the artwork, author, and description carried by the RSS channel back onto the subscription, on the same terms as foreground sync (FR 03), so a podcast imported from OPML gains the details its import could not supply even if it is only ever refreshed in the background.
- Enqueues downloads for newly discovered episodes of auto-download-enabled podcasts, trims each podcast to its auto-download keep count and skips podcasts whose auto-download is paused for inactivity (FR 05), and schedules a follow-up background download task when pending or stuck downloads exist.
- On iOS, downloads pending episodes in the time left in the refresh window (up to about 20 seconds into the run, skipped when under 5 seconds remain), honoring the Wi-Fi-only preference. It and the download task take a shared lock, so the two never transfer at once; whichever finds the lock held defers to the other.
- Builds per-episode notification payloads (capped per refresh cycle), skipping episodes the listener has already played, and shows one local notification per new episode.
- Attaches podcast artwork to each notification, downloading each artwork URL once per run (capped at 5 MB and a few seconds) and writing a separate file per notification, because iOS moves attachment files into its own store. The file differs by platform:
  - Android: the artwork is decoded and re-encoded as a 256 px wide PNG, because Android decodes the large icon at full size without sampling and podcast artwork is often 3000x3000.
  - iOS: the downloaded bytes are attached unchanged, named by their sniffed format (JPEG, PNG or GIF; the extension is how iOS identifies an attachment's type). Other formats are left out rather than attached under a wrong name. iOS disables the GPU while the app is in the background, and the Flutter engine then holds image decoding and PNG encoding until the app returns to the foreground, so decoding on iOS would leave most background-posted notifications without artwork. iOS scales attachments itself and accepts images up to 10 MB.
  - Artwork that fails or misses its deadline is left out and the notification is shown without it. If the OS rejects a notification that carries artwork (for example, iOS cannot read the attachment), it is posted again once without artwork, and counts as failed only if that retry also fails.
  - Actionable artwork failures (unsupported format, image decode or encode failure, bad HTTP status, oversize or empty response) are recorded as a Sentry breadcrumb from the background run. A notification rejected with its attachment but accepted by the text-only retry counts as an artwork failure; when the retry fails too, the attachment is not blamed. Expected network noise (timeouts, cancellations, connection errors) is not recorded. The breadcrumb and the diagnostic log hold only the artwork URL reduced to scheme and host (no credentials, path, query or fragment, since signed CDN URLs can carry tokens in the path) and an error category (error type, Dio failure type, HTTP status), never the error message.
- Handles notification taps and cold-start launches by decoding the notification payload and deep-linking to the corresponding episode detail screen.
- Re-registers or cancels the background task in response to settings changes and app lifecycle events so the schedule always reflects current preferences.

## Boundaries

- Foreground feed subscription, manual refresh, and feed management are owned by FR 03 (Subscription and feeds); this feature only covers the unattended background path and its notifications.
- Actual download file transfer, progress tracking, and the download queue belong to FR 05 (Episode download and queue); background refresh enqueues download work, schedules the download task, and on iOS reuses the shared background download service for its leftover window.
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
  - `packages/audiflow_app/lib/app/background/artwork_failure_report.dart`
  - `packages/audiflow_app/lib/app/background/background_task_registrar.dart`
  - `packages/audiflow_app/lib/app/background/background_settings_repository.dart`
  - `packages/audiflow_app/lib/app/notification/notification_tap_handler.dart`
  - `packages/audiflow_domain/lib/src/features/feed/services/background_refresh_service.dart`
  - `packages/audiflow_domain/lib/src/features/feed/services/background_notification_service.dart`
  - `packages/audiflow_domain/lib/src/features/feed/services/notification_artwork_files.dart`
  - `packages/audiflow_domain/lib/src/features/feed/services/notification_artwork_encoder.dart`
  - `packages/audiflow_domain/lib/src/features/feed/services/feed_sync_executor.dart`
  - `packages/audiflow_domain/lib/src/features/feed/models/new_episode_notification.dart`
  - `packages/audiflow_domain/lib/src/features/download/services/auto_download_enqueuer.dart`
- **Related FR**: 03-subscription-feeds.md
