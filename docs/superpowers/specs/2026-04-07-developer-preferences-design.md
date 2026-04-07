# Developer Preferences Page — Design Spec

## Overview

A new settings sub-screen at `/settings/developer` that surfaces smart playlist ecosystem information and provides a toggle for developer-oriented info in episode detail pages. Targets two audiences: audiflow contributors and podcast creators who want to understand how their feed is handled.

## Features

### 1. Contribute Link

A simple tappable text row at the top of the screen. Opens `https://github.com/audiflow/audiflow-smartplaylist` in the system browser via `url_launcher`. Displays repo short name (`audiflow/audiflow-smartplaylist`) as secondary text.

### 2. Developer Info Toggle

A `SwitchListTile` labeled "Show developer info" with subtitle "Display RSS feed URL and pattern links in episode details". Persisted across app restarts via `SharedPreferencesDataSource` with key `dev_show_developer_info`. Defaults to `false`.

### 3. Smart Playlist Pattern List

A compact list of all patterns from the smart playlist config repo. Each row shows only the `displayName` from `PatternSummary`, with a chevron indicating it is tappable. Tapping opens the pattern's GitHub repo directory (`https://github.com/audiflow/audiflow-smartplaylist/tree/main/{patternId}/`).

Data source: cache-first via `SmartPlaylistConfigRepository.fetchRootMeta()`. Pull-to-refresh triggers a fresh remote fetch. The list shows all patterns globally, regardless of the user's subscriptions.

### 4. Episode Detail Developer Info Widget

A conditional widget rendered at the bottom of the episode detail screen, separated by a thin divider with a "Developer" section label. Only visible when the dev info toggle is enabled.

Contains two items:

- **RSS Feed URL**: Displayed in monospace, with a "Copy" button that copies the URL to the clipboard via `Clipboard.setData`.
- **Smart Playlist Pattern**: If a matching pattern exists (determined via `SmartPlaylistConfigRepository.findMatchingPattern(podcastGuid, feedUrl)`), shows the pattern's `displayName` linking to its repo directory. If no pattern exists, shows "Not defined — add one?" linking to the repo root (`https://github.com/audiflow/audiflow-smartplaylist`).

## Architecture

### Providers (new)

| Provider | Package | Location | Type |
|----------|---------|----------|------|
| `devShowDeveloperInfoProvider` | `audiflow_domain` | `features/settings/providers/` | `Notifier<bool>` backed by SharedPreferences |
| `smartPlaylistPatternSummariesProvider` | `audiflow_domain` | `features/feed/providers/` | `FutureProvider<List<PatternSummary>>` via `fetchRootMeta()` |

### Widgets (new)

| Widget | Package | Location |
|--------|---------|----------|
| `DeveloperSettingsScreen` | `audiflow_app` | `features/settings/presentation/screens/developer_settings_screen.dart` |
| `EpisodeDevInfoWidget` | `audiflow_app` | `features/podcast_detail/presentation/widgets/episode_dev_info_widget.dart` |

### Routing

Add `settingsDeveloper` to `AppRoutes` and register a `GoRoute` under the settings branch in `app_router.dart`.

### Settings Grid

Add a new `SettingsCategoryCard` (icon: `Symbols.code`, title: localized "Developer", subtitle: localized "Smart playlist patterns and debug info") to the settings grid in `settings_screen.dart`.

### Localization

New keys in `app_en.arb` and `app_ja.arb`:
- `settingsDeveloperTitle` / `settingsDeveloperSubtitle` — settings card
- `developerContributeLabel` / `developerContributeRepo` — contribute link
- `developerShowInfoTitle` / `developerShowInfoSubtitle` — toggle
- `developerPatternsHeader` — section label
- `developerSectionLabel` — episode detail section header
- `developerRssFeedUrl` — RSS field label
- `developerCopyLabel` — copy button
- `developerPatternLabel` — pattern field label
- `developerPatternNotDefined` — "Not defined — add one?"
- `developerPullToRefresh` — pull to refresh hint

### Reused Components

- `SmartPlaylistConfigRepository` — `fetchRootMeta()`, `findMatchingPattern()`
- `PatternSummary` model — `id`, `displayName`, `playlistCount`, `feedUrlHint`
- `SharedPreferencesDataSource` — boolean read/write
- `url_launcher` — open GitHub links
- `Clipboard` — copy RSS URL

No new models or repositories are needed.

## Constants

GitHub repo URLs defined as constants (not hardcoded in widgets):

```
smartPlaylistRepoUrl = 'https://github.com/audiflow/audiflow-smartplaylist'
smartPlaylistRepoPatternUrl(String patternId) => '$smartPlaylistRepoUrl/tree/main/$patternId/'
```

Location: `audiflow_core/lib/src/constants/` (accessible from both `audiflow_app` screens).

## Testing

### Unit Tests

- `devShowDeveloperInfoProvider` — reads default `false`, persists `true`/`false` across reads
- `smartPlaylistPatternSummariesProvider` — returns cached `RootMeta.patterns`, invalidation triggers re-fetch

### Widget Tests

- `DeveloperSettingsScreen`:
  - Renders contribute link, toggle, and pattern list
  - Toggle changes persisted state
  - Pattern items are tappable
  - Pull-to-refresh triggers provider invalidation
- `EpisodeDevInfoWidget`:
  - Returns `SizedBox.shrink()` when toggle is off
  - Shows RSS feed URL and copy button when toggle is on
  - Shows pattern name with link when a matching pattern exists
  - Shows "Not defined — add one?" with repo root link when no pattern matches
