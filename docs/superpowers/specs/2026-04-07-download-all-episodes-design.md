# Download All Episodes

Batch download feature for station and season/group pages, with a user-configurable limit.

## Problem

Users cannot download all episodes from a station or season/group page at once. They must tap download on each episode individually.

## Scope

- Station detail page
- Smart playlist group episodes page (season/group)
- Settings: configurable batch download limit

Out of scope: podcast detail page, queue-based batch download, background batch scheduling.

## Settings: Max Batch Download Limit

New user preference in the download section of Settings:

| Field | Value |
|-------|-------|
| Label | "Max batch download" |
| Input | Free text number field |
| Default | 25 |
| Storage | New field in `AppSettings` Isar collection |
| Provider | `batchDownloadLimitProvider` in settings providers |

Validation: positive integer, clamped to a reasonable range (1-500).

## Domain: Batch Download by Episode IDs

New method in `DownloadService`:

```dart
Future<int> downloadEpisodes(List<int> episodeIds, {bool? wifiOnly})
```

- Accepts arbitrary episode ID list (not tied to season/podcast).
- Caps the list at the user's batch download limit setting (takes the first N from the provided list, which reflects the current display/sort order).
- Delegates to existing `downloadEpisode()` per item.
- Returns count of queued downloads.
- Works for both station and season/group pages since both already have episode ID lists.
- Existing `downloadSeason()` stays unchanged.

## UI: Station Page AppBar

Replace the single edit `IconButton` with a `PopupMenuButton` (three-dot icon):

| Menu Item | Icon | Action |
|-----------|------|--------|
| Edit station | `Symbols.edit` | Navigate to station edit screen (existing) |
| Download all episodes | download icon | Call `downloadEpisodes()` with station episode IDs |

Download item shows episode count. Disabled when episode list is empty.

## UI: Season/Group Page AppBar & Search

Replace `SearchableAppBar` with a standard `AppBar` + `PopupMenuButton`:

| Menu Item | Icon | Action |
|-----------|------|--------|
| Download all episodes | download icon | Call `downloadEpisodes()` with group episode IDs |

Search moves to a collapsible row below the AppBar:

- `SliverAppBar` with `floating: true`, search field in the `bottom` slot.
- Scrolling down hides the search field; scrolling up reveals it (iOS Settings pattern).

## Tablet

Both pages use the same `PopupMenuButton` on tablet. Only 2 actions max, not worth expanding to individual buttons. Keeps UI consistent across form factors.

## Confirmation & Feedback

When user taps "Download all episodes":

1. **Confirmation dialog**: "Download N episodes?" where N is `min(episodeCount, batchLimit)`. If episode count exceeds the limit, show note: "Limited to first 25 episodes" (substituting actual setting value).
2. On confirm: call `downloadEpisodes()`, show **snackbar**: "Queued N downloads".

No confirmation for the edit action (existing behavior unchanged).

## Localization

New l10n keys in `app_en.arb` and `app_ja.arb`:

- Menu label: download all episodes
- Confirmation dialog title and body (with count and limit note)
- Snackbar: queued count message
- Settings: batch download limit label and hint
