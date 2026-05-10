# Library Inline Podcasts Design

## Goal

Show subscribed podcasts directly in the Library tab under "Your Podcasts" instead of the current collapsed `3 podcasts >` row that navigates to a separate screen. Provide a sort selector under the section header, mirroring the inline placement used in the podcast detail screen.

## Current Behavior

`LibraryScreen` shows a single `ListTile` ("3 podcasts >") under the "Your Podcasts" header. Tap navigates to `SubscriptionsListScreen` (`/library/subscriptions`), which renders the sorted podcast list with a sort `PopupMenuButton` in its `AppBar`.

## Target Behavior

- Library tab renders the sorted podcast list inline under "Your Podcasts".
- "Your Podcasts" section header has a row layout: title on the left, sort `PopupMenuButton<PodcastSortOrder>` (`Icons.sort`) on the right.
- Tapping a podcast tile pushes the existing podcast detail screen.
- The dedicated `SubscriptionsListScreen` and its route are removed.

## Scope

### In Scope
- Modify `library_screen.dart` to inline the sorted subscription list and inline sort button.
- Delete `subscriptions_list_screen.dart` and its widget test.
- Restructure routing so podcast detail (and its smart playlist / episode detail descendants) lives directly under `/library/podcast/:id`.
- Drop the `AppRoutes.subscriptions` constant.

### Out of Scope
- Changing sort options (`latestEpisode`, `subscribedAt`, `alphabetical` remain).
- Grid layout for wide screens (always list per user direction).
- Stations section behavior.
- `SubscriptionListTile` widget itself.

## UI Layout

```
Stations
  (existing)

Your Podcasts                                     [sort icon]
  [SubscriptionListTile]
  [SubscriptionListTile]
  ...
```

Header row uses the same `Padding` as the existing section title and adds a trailing `PopupMenuButton`. Empty subscriptions case keeps the `stationNoSubscriptionsYet` placeholder.

## Components

### `LibraryScreen` (modified)
- Watch `sortedSubscriptionsProvider` (in addition to `librarySubscriptionsProvider` already needed for empty-state and refresh invalidation).
- Watch `podcastSortOrderControllerProvider` for current sort order.
- Replace the collapsed `ListTile` slivers with:
  - `SliverToBoxAdapter` containing a header `Row` with the title and sort `PopupMenuButton`.
  - `SliverList` of `SubscriptionListTile` whose `onTap` pushes `'/library/podcast/${podcast.id}'`.
- Reuse the same `PopupMenuButton` markup as the deleted `_SortMenuButton` (3 items). Extract as a private widget inside `library_screen.dart` to keep the file self-contained.

### Routing (`app_router.dart`)
- Remove import of `SubscriptionsListScreen`.
- Remove the `subscriptions` `GoRoute` and lift its descendants:
  - `podcast/:id` becomes a sibling of `station/:stationId` directly under the library shell branch (`/library/podcast/:id`).
  - Its smart playlist / episode-detail nested routes move with it unchanged.
- Remove `AppRoutes.subscriptions`.

### Deletions
- `packages/audiflow_app/lib/features/library/presentation/screens/subscriptions_list_screen.dart`
- `packages/audiflow_app/test/features/library/presentation/screens/subscriptions_list_screen_test.dart`

## Data Flow

`librarySubscriptionsProvider` -> `sortedSubscriptionsProvider` (already exists; sorts by `podcastSortOrderControllerProvider`). The Library screen consumes the sorted list directly. Sort order writes go through `podcastSortOrderControllerProvider.notifier.setSortOrder`. Pull-to-refresh keeps invalidating `librarySubscriptionsProvider`; the sorted provider recomputes automatically.

## Error / Empty Handling

- Loading: `CircularProgressIndicator` (existing).
- Provider error: existing `_buildErrorState` with retry that invalidates `librarySubscriptionsProvider` (sorted provider depends on it).
- Empty subscriptions (and stations empty): existing full-screen `_buildEmptyState`.
- Empty subscriptions (stations non-empty): keep `stationNoSubscriptionsYet` body text.
- Sort provider error: fall back to `PodcastSortOrder.latestEpisode` for the menu's current selection (mirrors the previous `SubscriptionsListScreen` behavior).

## Testing

- Add widget test for `LibraryScreen` covering: header sort button visible, tapping it shows three options, selecting an option updates the controller. Reuse fixtures from the deleted `subscriptions_list_screen_test.dart`.
- Update or remove existing Library-related tests that rely on the collapsed-row UI.

## Migration Notes

- No persisted route URLs change inside the app aside from `/library/subscriptions/...` -> `/library/podcast/...`. Universal-link handling does not target the removed prefix.
