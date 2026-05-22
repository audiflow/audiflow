---
refs:
  id: fr:13-library
  kind: fr
  title: "Library"
  related:
    - fr:03-subscription-feeds
    - fr:11-play-order
  modules:
    - packages/audiflow_app/lib/features/library/
---
# FR 13: Library

> The listener's home for everything they have committed to — subscribed podcasts shown inline and sortable, alongside their custom stations — and the surface that decides whether a podcast's year-grouped smart-playlist tab is worth showing at all.

## Purpose

Once a listener has subscribed to podcasts and assembled stations, they need a single place to come back to and pick what to listen to next. The Library tab is that home. It is not a discovery surface — it deliberately shows only what the listener already owns — and it is not a player. Its job is to present the listener's committed content in a way that is fast to scan and quick to drill into.

Two design decisions shape this feature. First, the subscribed-podcast list is shown directly in the Library tab rather than hidden behind a collapsed "N podcasts" row that navigates to a separate screen. Inlining the list removes a navigation hop for the most common action — opening a podcast — and lets the listener see and re-sort their whole subscription set at a glance. Second, the Library is the boundary at which a low-value smart-playlist view is suppressed: when a podcast is small and the only grouping the app could auto-detect is "by year", that year tab adds little — a handful of single-episode "year" entries that merely duplicate the episode list — so it is hidden below a minimum-episode threshold.

## User-visible Behavior

- Normal case: Opening the Library tab shows two stacked sections — "Stations" first, then "Your Podcasts". The podcast section lists every subscribed podcast inline as a tile with artwork, title, and artist. Tapping a tile opens that podcast's detail screen.
- Sorting: The "Your Podcasts" header carries a sort control on the right. Tapping it offers three options — by latest episode, by subscription date, or alphabetically. The current choice is marked, the list reorders immediately, and the choice persists across app restarts. When sorting by latest episode, podcasts that have no episodes yet sort last.
- Reactive ordering: With the latest-episode sort active, the list reorders on its own when a background feed refresh brings in newer episodes — the listener does not need to re-trigger the sort.
- Pull to refresh: Pulling down on the Library forces a sync of all subscriptions. A snackbar reports the outcome — how many feeds synced successfully, or how many failed.
- Empty cases: With no subscriptions and no stations, the Library shows a full-screen empty state inviting the listener to subscribe. With stations present but no subscriptions, the "Your Podcasts" section keeps its header and shows a short "no subscriptions yet" placeholder; the same holds for the stations section when no stations exist.
- Edge case (load failure): If the subscription list fails to load, the Library shows an error state with the error text and a retry button. If only the persisted sort preference fails to load, the list still renders, falling back to the latest-episode order.
- Year-grouping suppression: When the listener opens a podcast with fewer than 30 episodes whose only auto-detected grouping is by year, no smart-playlist toggle appears on the detail screen — the podcast shows its episode list only. Once that feed grows past the threshold, the year-grouped view becomes available on the next read. Podcasts with a curated (preset-authored) year grouping are unaffected and always show the tab.

## Capabilities

- Presents the subscribed-podcast list inline within the Library tab as artwork-and-metadata tiles, each opening the podcast detail screen on tap.
- Provides a sort selector in the "Your Podcasts" header offering latest-episode, subscription-date, and alphabetical orders, with the active choice marked and persisted across restarts.
- Keeps the latest-episode sort reactive, recomputing the order when background feed refreshes deliver new episodes, and placing episode-less podcasts last for that sort.
- Renders the "Stations" section above the podcast list and offers an entry point to create a new station.
- Supports pull-to-refresh that force-syncs all subscriptions and reports the success and failure counts.
- Handles empty and error states distinctly: a full-screen empty state when nothing is owned, inline placeholders when one section is empty, and a retry-able error state when the subscription list fails to load.
- Suppresses the auto-detected year-grouping smart-playlist tab for small feeds (below a 30-episode threshold) so the smart-playlist toggle stays hidden when the year view would only duplicate the episode list, while leaving curated year configs and all other groupings untouched.

## Boundaries

- Does not subscribe to or unsubscribe from podcasts, parse feeds, or define how feeds sync — that is FR 03 (Podcast subscription and feeds). The Library only displays the subscription set and triggers an existing sync.
- Does not discover or search for new podcasts; it shows only content the listener already owns. Discovery is a separate feature.
- Does not own the play order of the podcast list or of playback queues; the sort options it surfaces are part of FR 11 (Play order), which the Library merely consumes.
- Does not create, edit, or manage stations beyond listing them and offering a "create" entry point; station behavior is its own feature.
- Does not author, host, or resolve smart-playlist configuration. The Library's only involvement is the minimum-episode gate that decides whether the auto-detected year tab is shown; the resolution and curated configs belong to the preset/feed features (FR 06, Preset).
- Does not change the threshold at runtime or make it user-configurable — it is a fixed compile-time constant — and does not suppress season, title-classifier, or title-discovery groupings; only the auto-detect year fallback is gated.

## Traceability

- **Source docs**:
  - `docs/superpowers/specs/2026-05-11-library-inline-podcasts-design.md`
  - `docs/superpowers/plans/2026-05-04-year-grouping-min-episodes.md`
  - `docs/superpowers/specs/2026-05-04-year-grouping-min-episodes-design.md`
- **Source files**:
  - `packages/audiflow_app/lib/features/library/presentation/screens/library_screen.dart`
  - `packages/audiflow_app/lib/features/library/presentation/controllers/library_controller.dart`
  - `packages/audiflow_app/lib/features/library/presentation/controllers/continue_listening_controller.dart`
  - `packages/audiflow_app/lib/features/library/presentation/widgets/subscription_list_tile.dart`
  - `packages/audiflow_app/lib/features/library/presentation/widgets/continue_listening_section.dart`
- **Related FR**: `03-subscription-feeds.md`, `11-play-order.md`
