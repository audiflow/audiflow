# Download Episode Feature - Design Document

## Overview

Enable users to download podcast episodes for offline playback. Supports single episode downloads, season-level bulk downloads, and background downloading with smart retry.

## Requirements Summary

- Single episode download from multiple entry points (tile, detail, context menu)
- "Download all" action at season level
- Sequential download queue (one at a time)
- WiFi-only by default with per-download override
- Auto-use local file for playback when available
- Optional auto-delete after episode played
- Smart retry with exponential backoff on network restore
- Background downloads continue when app suspended
- Dedicated downloads management screen

---

## Data Model

### DownloadTasks Table (Drift)

New table in schema v9:

| Field | Type | Purpose |
|-------|------|---------|
| `id` | int (PK) | Auto-increment identifier |
| `episodeId` | int (FK) | References Episodes table |
| `audioUrl` | text | Original remote URL |
| `localPath` | text (nullable) | File path when completed |
| `totalBytes` | int (nullable) | Total file size (from Content-Length) |
| `downloadedBytes` | int | Bytes downloaded so far |
| `status` | int | Enum: pending, downloading, paused, completed, failed, cancelled |
| `wifiOnly` | bool | Respect WiFi restriction for this download |
| `retryCount` | int | Number of retry attempts |
| `lastError` | text (nullable) | Last error message for debugging |
| `createdAt` | datetime | When download was requested |
| `completedAt` | datetime (nullable) | When download finished |

### DownloadStatus Enum

```
pending → downloading → completed
              ↓
           paused
              ↓
           failed (after retries exhausted)
```

The Episode model stays unchanged. Download state tracked via DownloadTasks table with foreign key relationship.

---

## Domain Layer Architecture

**Location:** `packages/audiflow_domain/lib/src/features/download/`

```
download/
├── models/
│   ├── download_task.dart          # Drift table definition
│   └── download_status.dart        # @freezed enum
├── repositories/
│   ├── download_repository.dart    # Interface
│   └── download_repository_impl.dart
├── datasources/
│   └── local/
│       └── download_local_datasource.dart  # Drift CRUD operations
├── services/
│   ├── download_service.dart       # Orchestrates downloads
│   ├── download_queue_service.dart # Sequential queue management
│   └── download_file_service.dart  # File I/O, storage paths
└── providers/
    └── download_providers.dart     # Riverpod providers
```

### Responsibilities

- **DownloadRepository** - CRUD operations on download tasks, query by status/episode
- **DownloadService** - Main API: `downloadEpisode()`, `downloadSeason()`, `pause()`, `resume()`, `cancel()`, `delete()`
- **DownloadQueueService** - Manages sequential execution, listens to network state, triggers smart retry
- **DownloadFileService** - Handles Dio download with progress callbacks, file path resolution, storage cleanup

No remote datasource - Dio download logic lives in DownloadFileService since it's not a typical REST API pattern.

---

## Download Queue & Network Behavior

### Queue Management (DownloadQueueService)

- Maintains a single active download at any time
- When a download completes/fails/cancels, automatically starts the next pending task
- Exposes `Stream<DownloadTask?>` for the currently active download
- Persists queue order via `createdAt` timestamp (FIFO)

### Network-Aware Behavior

- Listens to `connectivity_plus` for network state changes
- When network returns after being offline:
  - Resumes any `downloading` tasks that were interrupted
  - Retries `failed` tasks (respecting retry limits)
- Respects `wifiOnly` flag per download task:
  - If `wifiOnly=true` and on cellular, task stays `pending`
  - When WiFi connects, eligible tasks auto-start

### Smart Retry Logic

- Max 5 retry attempts per download
- Exponential backoff: 5s, 15s, 45s, 135s, 405s
- Retry triggers: network restored, app foregrounded, manual tap
- After max retries, status becomes `failed` - user must manually retry (resets counter)

### Background Execution

- Uses platform-specific background task APIs
- iOS: Background URL Session (continues even when app suspended)
- Android: WorkManager with foreground service for active downloads

---

## Playback Integration

### AudioPlayerService Changes

When playing an episode, the player checks for a completed download first:

```
play(episodeId) →
  1. Query DownloadRepository for completed download
  2. If found: use localPath
  3. If not found: use episode.audioUrl (stream)
```

This logic lives in AudioPlayerService - the UI doesn't need to know the source.

### Episode Query Extension

Add methods to DownloadRepository:
- `getCompletedDownloadForEpisode(episodeId)` returns `DownloadTask?`
- `watchDownloadForEpisode(episodeId)` returns `Stream<DownloadTask?>` for reactive UI

### Storage Cleanup Integration

When auto-delete is enabled and an episode is marked as played:
- `PlaybackHistoryService.markCompleted()` emits an event
- `DownloadService` listens and deletes the local file + database record
- Cleanup is async and non-blocking to playback

### File Path Strategy

Downloads stored in app's documents directory:
```
{documents}/downloads/{episodeId}_{sanitized_title}.mp3
```

Using `episodeId` prefix ensures uniqueness. File extension preserved from original URL.

---

## Presentation Layer - Entry Points

**Location:** `packages/audiflow_app/lib/features/download/`

### 1. Episode List Tile (SeasonEpisodeListTile)

Download action button shows contextual state:
- **Not downloaded:** Download icon (tap to start)
- **Pending/Queued:** Clock icon with position badge
- **Downloading:** Progress ring (0-100%) with pause icon inside
- **Paused:** Resume icon
- **Completed:** Checkmark icon (tap opens delete confirmation)
- **Failed:** Error icon with retry option

### 2. Long-Press Context Menu

Extend existing context menu with download actions:
- "Download Episode" (when not downloaded)
- "Pause Download" / "Resume Download" (when in progress)
- "Cancel Download" (when pending/downloading/paused)
- "Delete Download" (when completed)

### 3. Episode Detail Screen

Same download button as list tile, but larger and more prominent in the action bar area.

### 4. Season-Level Action

On the season episodes screen header/app bar:
- "Download All" button (overflow menu or icon)
- Shows confirmation with episode count: "Download 12 episodes?"
- Respects WiFi setting - warns if on cellular and WiFi-only enabled

---

## Downloads Management Screen

**Location:** `packages/audiflow_app/lib/features/download/presentation/screens/downloads_screen.dart`

### Navigation Access

Settings screen -> "Downloads" row -> Downloads screen

### Screen Sections

**1. Active Download (if any)**
- Large card at top showing current download
- Episode title, podcast name, artwork thumbnail
- Progress bar with percentage and downloaded/total size
- Pause/Cancel buttons

**2. Queue (pending downloads)**
- List of pending downloads in order
- Each item shows: episode title, podcast name, queue position
- Swipe to remove from queue

**3. Completed Downloads**
- List of successfully downloaded episodes
- Shows: title, podcast, file size, download date
- Tap to play, swipe to delete
- "Delete All" action in app bar overflow menu

**4. Failed Downloads**
- List of failed downloads (if any)
- Shows error reason
- Retry button per item, or "Retry All" in header

**Empty States:**
- "No downloads yet" with hint to download from episode pages

---

## Settings & Storage

### Download Settings (in Settings screen)

| Setting | Type | Default | Description |
|---------|------|---------|-------------|
| WiFi-only downloads | Toggle | ON | Only download on WiFi by default |
| Auto-delete played | Toggle | OFF | Delete downloads after episode marked played |
| Storage used | Display | - | Shows "X.X GB used by downloads" |
| Clear all downloads | Button | - | Deletes all downloaded files (with confirmation) |

### Storage Management

**DownloadFileService responsibilities:**
- Calculate total storage used by downloads
- Provide `Stream<int>` for reactive storage display
- Handle file deletion (single and bulk)
- Verify file integrity on app startup (remove orphaned DB records)

**Startup Cleanup:**

On app launch, `DownloadService.validateDownloads()`:
- Check each "completed" download has a valid file
- If file missing, mark as `failed` or delete record
- Resume any interrupted `downloading` tasks

**Storage Path:**
```
iOS: {app}/Documents/downloads/
Android: {app}/files/downloads/
```

Both are app-private and don't require storage permissions.

---

## Error Handling & Edge Cases

### Error Types (in audiflow_core)

```dart
class DownloadException extends AppException {
  final DownloadErrorType type;
  // types: networkUnavailable, serverError, insufficientStorage,
  //        fileWriteError, cancelled, unknown
}
```

### Edge Case Handling

| Scenario | Behavior |
|----------|----------|
| Download same episode twice | Ignore if already completed/downloading/pending; show toast |
| Delete while downloading | Cancel download first, then delete file and record |
| App killed during download | On restart, resume from `downloadedBytes` (if server supports Range) |
| Server doesn't support resume | Restart download from beginning |
| Disk full | Pause download, mark as failed with "Insufficient storage" message |
| Episode deleted from feed | Keep download, show "Episode no longer in feed" indicator |
| Podcast unsubscribed | Keep downloads; show in "Downloaded" section with podcast name |

### User Feedback

- Toast/snackbar for quick actions: "Download started", "Download cancelled"
- Error dialog for failures that need attention: "Storage full - free up space"
- Badge on Settings icon when downloads need attention (failed state)

### Logging

Use `namedLoggerProvider('Download')` for:
- Download start/complete/fail events
- Retry attempts
- Storage operations

---

## Implementation Checklist

### Phase 1: Domain Layer
- [ ] Add DownloadTasks table to Drift schema (v9 migration)
- [ ] Create DownloadStatus enum (@freezed)
- [ ] Implement DownloadLocalDataSource
- [ ] Implement DownloadRepository interface and impl
- [ ] Implement DownloadFileService (Dio downloads)
- [ ] Implement DownloadQueueService
- [ ] Implement DownloadService
- [ ] Add Riverpod providers
- [ ] Add DownloadException to audiflow_core

### Phase 2: Playback Integration
- [ ] Modify AudioPlayerService to check for local files
- [ ] Add watchDownloadForEpisode to repository
- [ ] Integrate auto-delete with PlaybackHistoryService

### Phase 3: UI - Inline Controls
- [ ] Add download button to SeasonEpisodeListTile
- [ ] Add download progress indicator widget
- [ ] Extend long-press context menu
- [ ] Add download button to episode detail screen
- [ ] Add "Download All" to season screen

### Phase 4: Downloads Screen
- [ ] Create downloads_screen.dart
- [ ] Implement active download card
- [ ] Implement queue list
- [ ] Implement completed downloads list
- [ ] Implement failed downloads list
- [ ] Add route to app_router.dart
- [ ] Add navigation from Settings

### Phase 5: Settings
- [ ] Add download settings section
- [ ] Implement storage used display
- [ ] Implement clear all downloads

### Phase 6: Background & Network
- [ ] Implement iOS background URL session
- [ ] Implement Android WorkManager integration
- [ ] Add network state listener for smart retry
- [ ] Test background download scenarios

### Phase 7: Testing
- [ ] Unit tests for services and repositories
- [ ] Widget tests for download UI components
- [ ] Integration tests for download flow
