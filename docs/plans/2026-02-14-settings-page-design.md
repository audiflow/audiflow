# Settings Page Design

## Overview

Full-featured settings page for the Audiflow podcast app. The top-level screen displays six category cards in a 2-column grid. Each card navigates to a detail page with individual settings.

## Layout

Category cards with drill-down detail pages. Each detail page is a scrollable list with section headers and appropriate input controls (toggles, dropdowns, sliders, segmented buttons).

Routes:
- `/settings` - category cards grid
- `/settings/appearance`
- `/settings/playback`
- `/settings/downloads`
- `/settings/feed-sync`
- `/settings/storage`
- `/settings/about`

## Category Cards

| Card | Icon | Subtitle |
|------|------|----------|
| Appearance | `palette` | Theme, language, text size |
| Playback | `play_circle` | Speed, skipping, auto-complete |
| Downloads | `download` | WiFi, auto-delete, concurrency |
| Feed Sync | `sync` | Refresh interval, background sync |
| Storage & Data | `storage` | Cache, OPML, data management |
| About | `info` | Version, licenses, support |

## Settings Detail

### Appearance (`/settings/appearance`)

| Setting | Control | Options | Default |
|---------|---------|---------|---------|
| Theme Mode | Segmented button | Light / Dark / System | System |
| Language | Dropdown | English / Japanese | System locale |
| Text Size | Segmented button | Small (0.85x) / Medium (1.0x) / Large (1.15x) | Medium |

- Theme and language use existing `SharedPreferencesDataSource` keys (`themeModeKey`, `localeKey`).
- Text size adds a new `textScaleKey`.
- Text size applies via `MediaQuery.textScaler` at `MaterialApp` level.
- Language change shows a restart-recommended notice.
- Text size shows a preview below the selector.

### Playback (`/settings/playback`)

| Setting | Control | Options | Default |
|---------|---------|---------|---------|
| Default Playback Speed | Dropdown | 0.5x, 0.75x, 1.0x, 1.25x, 1.5x, 1.75x, 2.0x | 1.0x |
| Skip Forward Duration | Segmented button | 10s, 15s, 30s, 45s, 60s | 30s |
| Skip Backward Duration | Segmented button | 10s, 15s, 30s | 10s |
| Auto-Complete Threshold | Slider | 80% - 99% | 95% |
| Continuous Playback | Toggle | On / Off | On |

- Default playback speed applies when starting a new episode.
- Skip durations replace hard-coded 30s in the player.
- Auto-complete threshold replaces hard-coded 95% in `PlaybackHistoryService`.
- Continuous playback controls whether the next queue item auto-plays.

### Downloads (`/settings/downloads`)

| Setting | Control | Options | Default |
|---------|---------|---------|---------|
| WiFi-Only Downloads | Toggle | On / Off | On |
| Auto-Delete After Played | Toggle | On / Off | Off |
| Max Concurrent Downloads | Segmented button | 1, 2, 3 | 1 |

- WiFi-only sets the default for new download tasks.
- Auto-delete removes downloaded files after episode is marked complete.
- Max concurrent modifies `DownloadQueueService` behavior.

### Feed Sync (`/settings/feed-sync`)

| Setting | Control | Options | Default |
|---------|---------|---------|---------|
| Auto-Sync | Toggle | On / Off | On |
| Sync Interval | Dropdown (visible when auto-sync on) | 30 min, 1 hour, 2 hours, 4 hours | 1 hour |
| WiFi-Only Sync | Toggle | On / Off | Off |

- Sync interval replaces hard-coded `Duration(hours: 1)` in `FeedSyncService`.
- WiFi-only sync skips background refresh on cellular data.

### Storage & Data (`/settings/storage`)

**Cache:**
- Display current image/HTTP cache size (calculated on page load)
- "Clear Cache" button with confirmation dialog

**Search History:**
- "Clear Search History" button with confirmation dialog

**OPML:**
- "Export Subscriptions" - generates OPML file and opens share sheet
- "Import Subscriptions" - file picker for `.opml` files with preview

**Data Management:**
- Display database size
- "Reset All Data" - double-confirmation (type "RESET"). Clears database, cache, preferences.

### About (`/settings/about`)

- App icon and name
- Version and build number (from `packageInfoProvider`)
- "Open Source Licenses" - Flutter built-in `LicensePage`
- "Send Feedback" - opens email/URL via `url_launcher`
- "Rate the App" - App Store / Play Store link

## Architecture

### Persistence

All settings stored via `SharedPreferencesDataSource`. Each setting has a typed key constant defined in `audiflow_core`.

### Data Flow

Each setting is a Riverpod provider backed by `SharedPreferencesDataSource`. Services that currently use hard-coded values read from the settings provider instead. Changes apply immediately (no save button).

### Package Responsibilities

| Package | Responsibility |
|---------|---------------|
| `audiflow_core` | Setting key constants, default value constants |
| `audiflow_domain` | `AppSettingsRepository` (interface + impl), Riverpod providers for each setting |
| `audiflow_app` | Settings screens, category cards grid, detail pages, controllers |

### Services to Update

| Service | Current Hard-coded Value | Setting |
|---------|------------------------|---------|
| `FeedSyncService` | `_syncInterval = Duration(hours: 1)` | Sync interval |
| `PlaybackHistoryService` | 95% auto-complete threshold | Auto-complete threshold |
| Player (skip) | 30s skip duration | Skip forward/backward duration |
| `DownloadQueueService` | Sequential (1 at a time) | Max concurrent downloads |
| `DownloadTask` | `wifiOnly: true` | WiFi-only default |
