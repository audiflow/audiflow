---
refs:
  id: fr:07-stations
  kind: fr
  title: "Stations"
  related:
    - fr:06-preset
    - fr:11-play-order
  modules:
    - packages/audiflow_app/lib/features/station/
    - packages/audiflow_domain/lib/src/features/station/
---

# FR 07: Stations

> Stations are user-defined collections of subscribed podcasts whose episodes are automatically gathered and filtered into a single, continuously-updated feed.

## Purpose

A listener who follows many podcasts often wants to consume them by theme rather than one show at a time -- "News" in the morning, "Tech" on the commute, "Comedy" in the evening. Stations let the user group their own subscribed podcasts into named collections and have the app surface the relevant episodes automatically, without manually building a playlist.

A Station differs from the Queue in a fundamental way: the Queue is the only place where the user manually adds individual episodes, whereas a Station never holds hand-picked episodes. Its contents are derived entirely from the podcasts it contains and the filter conditions configured on it. This makes a Station a "living" collection -- as new episodes are published, are played, or are downloaded, the Station's feed updates itself. Stations are a purely local feature: they live in on-device storage, work fully offline, and require no external configuration or cross-repository coordination, distinguishing them from the externally-authored smart playlists described in FR 06.

## User-visible Behavior

- **Creating a station**: From the Library tab the user opens the station editor, gives the station a name (required, up to 50 characters), and selects podcasts to include. Podcast selection uses a fullscreen picker that lists all subscribed podcasts with search and sort (by name, by recency of subscription, or by recency of update); cached/preset podcasts are excluded since only true subscriptions can belong to a station. Up to 15 stations can exist.
- **Configuring contents**: The editor exposes how many episodes each podcast contributes ("latest N", choosable from 1, 2, 3, 4, 5, 10, or all -- default 3), optional attribute filters (hide already-played episodes, downloaded-only, favorites-only, and a duration filter for "shorter than" or "longer than" a chosen number of minutes), the episode sort order (newest-first or oldest-first), and whether episodes are grouped by podcast.
- **Viewing a station**: The Library tab shows a Stations section listing each station with an artwork mosaic of its podcasts and a summary ("N podcasts, M episodes"). Tapping a station opens its detail screen -- a filtered episode feed with a play-all action and indicators for the active filters. Episodes can be played directly from this feed.
- **Normal update case**: When a podcast in the station publishes a new episode, or an episode is played, completed, downloaded, or favorited, the station's feed reconciles in the background and the detail screen updates reactively. The user does not trigger this manually.
- **Empty / no-match case**: If no episodes satisfy the station's filters, the detail screen shows an empty state. A station with no podcasts simply shows nothing until podcasts are added.
- **Edge case -- station limit**: Attempting to create a 16th station is rejected with a "station limit reached" message.
- **Edge case -- unsubscribing**: If the user unsubscribes from a podcast that belongs to a station, that podcast's membership and its episodes are removed from the station automatically, leaving the rest of the station intact.
- **Editing and deleting**: Re-opening the editor loads all current settings, including per-podcast episode limits and manual ordering. Saving recalculates the station's feed. Deleting a station removes it together with all of its podcast links and gathered episodes.

## Capabilities

- Lets users create, rename, reorder, edit, and delete named stations, up to a maximum of 15.
- Adds and removes subscribed podcasts to/from a station via a searchable, sortable fullscreen picker; only non-cached subscriptions are eligible.
- Gathers episodes per podcast using a count-based limit ("latest N episodes"), configurable as a station-wide default and overridable per podcast.
- Applies attribute filters across gathered episodes: hide completed episodes, downloaded-only, favorites-only, and a duration threshold (shorter-than / longer-than a minute value). The count limit is applied first, then attribute filters narrow the result further.
- Maintains a materialized, always-current feed per station through background reconciliation, triggered by feed sync, playback state changes, download state changes, favorite toggles, station configuration changes, and subscription deletion -- using full recalculation when a station's configuration changes and incremental per-episode updates for individual events.
- Orders the station feed either as a flat list by publish date (newest-first or oldest-first) or grouped by podcast, with podcast ordering by subscription order, podcast name, or a user-defined manual order.
- Presents stations in the Library tab as a dedicated section with artwork mosaics and content summaries, and provides per-station detail and edit screens plus a play-all action.
- Cleans up orphaned podcast links and episodes when a subscription is deleted, so stations never reference podcasts the user no longer follows.

## Boundaries

- Stations never contain manually added individual episodes -- hand-picked episode collection is exclusively the Queue's responsibility. A station's contents are always derived from its podcasts and filters.
- Stations only include podcasts the user is actually subscribed to; preset/cached podcasts and arbitrary search results cannot be added.
- Stations do not define or consume external configuration. They are entirely local and have no relationship to the externally-authored smart playlist config covered by FR 06; the two are separate collection mechanisms.
- Stations do not own playback ordering policy beyond their own newest/oldest and grouped/flat feed presentation -- cross-scope play order preferences (group, playlist, podcast, global cascade) are covered by FR 11.
- Stations do not provide export/import, per-station playback speed, manual per-episode ordering, or a queue-fallback "default station"; these remain out of scope (recorded as backlog ideas in the source design docs).
- Stations do not perform RSS fetching or episode extraction themselves; they consume episodes already stored locally by the feed/subscription features.

## Traceability

- **Source docs**:
  - `docs/superpowers/plans/2026-03-20-station-feature.md` (v1 implementation plan, historical context)
  - `docs/superpowers/specs/2026-03-20-station-design.md` (v1 design, historical context)
  - `docs/superpowers/plans/2026-04-05-station-v2.md` (v2 implementation plan)
  - `docs/superpowers/specs/2026-04-05-station-v2-design.md` (v2 design, current behavior)
  - `packages/audiflow_app/lib/features/station/` (presentation: screens, controllers, widgets)
  - `packages/audiflow_domain/lib/src/features/station/` (models, datasources, repositories, reconciler service)
- **Related FR**: `06-preset.md` (externally-authored smart playlists -- the complementary, non-local collection mechanism), `11-play-order.md` (per-scope play order preferences)
