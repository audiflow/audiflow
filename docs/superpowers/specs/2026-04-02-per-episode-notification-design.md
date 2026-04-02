# Per-Episode Local Notification Design

Date: 2026-04-02

## Problem

Background feed refresh detects new episodes and shows a single aggregated notification ("4 new episodes from Podcast A and Podcast B"). Users cannot act on individual episodes from the notification. Tapping the notification does nothing because there is no `onDidReceiveNotificationResponse` handler.

## Solution

Show one local notification per new episode (capped at 7 per refresh cycle). Each notification displays the podcast name as the title and episode title as the body. Tapping a notification navigates to that episode's detail screen.

## Constraints

- Max 7 notifications per refresh cycle; overflow silently dropped
- Permission handling and settings UI toggle already exist (no changes needed)
- Episode detail screen requires `PodcastItem`, `podcastTitle`, `artworkUrl`, `itunesId` — all must be looked up from Isar on tap
- Background isolate has no GoRouter access; notification payload must carry enough data for foreground navigation

## Design

### 1. Notification payload

Each notification carries a JSON payload string:

```json
{
  "type": "new_episode",
  "episodeId": 42,
  "podcastId": 7
}
```

Using Isar IDs keeps the payload minimal. The foreground app looks up full objects on tap.

### 2. Notification display

Each notification uses:
- **ID**: Episode Isar ID (ensures uniqueness, replaces duplicate if re-notified)
- **Title**: Podcast title (e.g. "The Daily")
- **Body**: Episode title (e.g. "Breaking News: April Update")
- **Channel**: `audiflow_new_episodes` (existing)
- **Payload**: JSON string above

### 3. Data flow changes

**Current flow:**
```
BackgroundRefreshService.execute()
  → collects Map<String, int> (itunesId → count)
  → calls ShowNotificationCallback(displayMap)
  → BackgroundNotificationService.showNewEpisodesNotification(plugin, displayMap)
```

**New flow:**
```
BackgroundRefreshService.execute()
  → after each feed sync with newEpisodeCount > 0:
     fetch newest N episodes from repo
  → collects List<NewEpisodeNotification> (max 7 total)
  → calls ShowNotificationsCallback(episodes)
  → BackgroundNotificationService.showPerEpisodeNotifications(plugin, episodes)
```

### 4. New types

```dart
/// Lightweight DTO for notification display, created in the background isolate.
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
}
```

Lives in `audiflow_domain/lib/src/features/feed/models/`.

### 5. BackgroundNotificationService changes

- Remove `showNewEpisodesNotification` (aggregated)
- Remove `formatNotificationBody` (no longer needed)
- Add `showPerEpisodeNotifications(plugin, List<NewEpisodeNotification>)`:
  - Iterates list, calls `plugin.show()` for each
  - Notification ID = `episodeId` (unique per episode)
  - Payload = JSON with `type`, `episodeId`, `podcastId`

### 6. BackgroundRefreshService changes

- Change `ShowNotificationCallback` from `Future<void> Function(Map<String, int>)` to `Future<void> Function(List<NewEpisodeNotification>)`
- After each successful feed sync with `newEpisodeCount > 0`:
  - Fetch newest episodes via `_episodeRepo.getByPodcastId(sub.id)` (already ordered newest-first)
  - Take up to `newEpisodeCount` episodes
  - Create `NewEpisodeNotification` for each
- Collect all notifications, cap at 7 total
- Call notification callback with the capped list

### 7. Notification tap handling

#### 7.1 Foreground/background tap

The background isolate only *shows* notifications — tap handling is purely foreground. Initialize `FlutterLocalNotificationsPlugin` in `main.dart` with `onDidReceiveNotificationResponse`. Create a `NotificationTapHandler` class in `audiflow_app`:

```dart
class NotificationTapHandler {
  NotificationTapHandler({required this.router});
  final GoRouter router;

  void handle(NotificationResponse response) {
    final payload = response.payload;
    if (payload == null || payload.isEmpty) return;

    final data = jsonDecode(payload) as Map<String, dynamic>;
    if (data['type'] != 'new_episode') return;

    final episodeId = data['episodeId'] as int;
    final podcastId = data['podcastId'] as int;

    // Navigate — episode lookup happens in the route builder
    router.push('/library/p/$podcastId/episode/$episodeId');
  }
}
```

#### 7.2 Cold start (app terminated)

On app startup in `main.dart`, after full initialization:
1. Call `plugin.getNotificationAppLaunchDetails()`
2. If `didNotificationLaunchApp == true`, extract payload and navigate

#### 7.3 Route for notification-based navigation

Add a new route that accepts `podcastId` + `episodeId` as path params (not extras), looks up Episode and Subscription from Isar, converts Episode to PodcastItem, and renders `EpisodeDetailScreen`. This avoids the need to pass complex objects through notification payloads.

New route: `/notification/episode/:podcastId/:episodeId`

This is a top-level GoRouter route (outside the shell), purpose-built for notification deep links.

### 8. Episode-to-PodcastItem conversion

Add a static helper on `Episode` or a standalone function in `audiflow_domain`:

```dart
PodcastItem episodeToPodcastItem(Episode episode) {
  return PodcastItem(
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
  );
}
```

### 9. Files to modify

| File | Change |
|------|--------|
| `audiflow_domain/.../models/new_episode_notification.dart` | New file: `NewEpisodeNotification` class |
| `audiflow_domain/.../services/background_notification_service.dart` | Replace aggregated with per-episode notifications |
| `audiflow_domain/.../services/background_refresh_service.dart` | Change callback type; collect episode details; cap at 7 |
| `audiflow_app/.../background/background_callback.dart` | Wire new callback signature |
| `audiflow_app/lib/main.dart` | Initialize notification plugin with tap handler; handle cold start |
| `audiflow_app/.../notification/notification_tap_handler.dart` | New file: tap handler with GoRouter navigation |
| `audiflow_app/lib/routing/app_router.dart` | Add notification deep link route |
| `audiflow_domain/lib/audiflow_domain.dart` | Export new model |

### 10. Files to add tests for

| Test file | Coverage |
|-----------|----------|
| `background_notification_service_test.dart` | Per-episode notification display, payload format, cap at 7 |
| `background_refresh_service_test.dart` | Update existing tests for new callback type |
| `notification_tap_handler_test.dart` | Payload parsing, navigation calls |
| `new_episode_notification_test.dart` | Model construction |

## Out of scope

- Notification grouping/summary (Android notification groups)
- Notification images/thumbnails
- Notification actions (play, mark as read)
- Badge count on app icon
