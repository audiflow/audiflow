# Podcast Sort Order

Sort subscribed podcasts in the "Your Podcasts" screen by user-selectable criteria, persisted across app restarts.

## Sort Options

| Option | Enum value | Behavior | Default |
|--------|-----------|----------|---------|
| Latest episode | `latestEpisode` | Newest episode `publishedAt` per podcast, descending | Yes |
| Subscription date | `subscribedAt` | `Subscription.subscribedAt`, descending | |
| Alphabetical | `alphabetical` | `Subscription.title`, case-insensitive ascending | |

## Data Layer

### Model

New enum in `audiflow_domain/src/features/feed/models/podcast_sort_order.dart`:

```dart
enum PodcastSortOrder { latestEpisode, subscribedAt, alphabetical }
```

### Repository

New repository pair in `audiflow_domain/src/features/feed/repositories/`:

- `podcast_sort_order_repository.dart` -- interface with `get()`, `set()`, `watch()`.
- `podcast_sort_order_repository_impl.dart` -- SharedPreferences-backed implementation.

The repository stores the enum name as a string key in SharedPreferences and exposes a reactive `Stream` via `watch()`.

### Providers

New file `audiflow_domain/src/features/feed/providers/podcast_sort_order_providers.dart`:

- `podcastSortOrderRepositoryProvider` -- singleton repository instance.
- `podcastSortOrderProvider` -- watches the persisted sort order stream.

## Sorting Strategy

- `subscribedAt` and `alphabetical`: sort the subscription list in Dart (single collection, straightforward).
- `latestEpisode`: query the Episode collection for the max `publishedAt` per `podcastId`, then sort subscriptions by that date descending. Podcasts with no episodes sort last.

All sorting happens in a new `sortedSubscriptionsProvider` in `library_controller.dart` that combines:
1. `librarySubscriptionsProvider` (existing reactive subscription stream)
2. `podcastSortOrderProvider` (persisted sort order)
3. Episode queries (only for `latestEpisode` sort)

## Presentation Layer

### SubscriptionsListScreen

Add a `PopupMenuButton<PodcastSortOrder>` in the AppBar `actions`:
- Three menu items with labels from l10n.
- Current selection indicated with a leading check icon.
- On selection, update the persisted sort order via the repository.

Switch from `librarySubscriptionsProvider` to `sortedSubscriptionsProvider`.

### Localization

New keys in `app_en.arb` and `app_ja.arb`:
- `sortByLatestEpisode` -- "Latest episode"
- `sortBySubscribedAt` -- "Subscription date"
- `sortByAlphabetical` -- "Alphabetical"

## File Changes

| Layer | File | Change |
|-------|------|--------|
| Domain model | `audiflow_domain/.../feed/models/podcast_sort_order.dart` | New enum |
| Domain repo | `audiflow_domain/.../feed/repositories/podcast_sort_order_repository.dart` | Interface |
| Domain repo | `audiflow_domain/.../feed/repositories/podcast_sort_order_repository_impl.dart` | SharedPreferences impl |
| Domain providers | `audiflow_domain/.../feed/providers/podcast_sort_order_providers.dart` | Riverpod providers |
| Domain export | `audiflow_domain/lib/audiflow_domain.dart` | Export new files |
| App controller | `audiflow_app/.../library/presentation/controllers/library_controller.dart` | `sortedSubscriptionsProvider` |
| App screen | `audiflow_app/.../library/presentation/screens/subscriptions_list_screen.dart` | PopupMenuButton, use sorted provider |
| App l10n | `app_en.arb`, `app_ja.arb` | Sort option labels |
| Tests | Unit tests for repository, provider, sorting logic; widget test for sort menu | |

## Out of Scope

- Sort order for the Library screen summary row (it just shows a count).
- Sort within podcast detail / episode lists (already has its own sort system).
- Ascending/descending toggle (all sorts use the most natural direction).
