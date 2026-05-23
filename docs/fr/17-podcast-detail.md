---
refs:
  id: fr:17-podcast-detail
  kind: fr
  title: "Podcast detail"
  related:
    - fr:03-subscription-feeds
    - fr:04-audio-playback
    - fr:08-transcript-chapters
    - fr:11-play-order
  modules:
    - packages/audiflow_app/lib/features/podcast_detail/
    - packages/audiflow_domain/lib/src/features/feed/models/podcast_view_preference.dart
    - packages/audiflow_domain/lib/src/features/feed/repositories/podcast_view_preference_repository.dart
    - packages/audiflow_domain/lib/src/features/feed/datasources/local/podcast_view_preference_local_datasource.dart
    - packages/audiflow_domain/lib/src/features/feed/providers/podcast_view_preference_providers.dart
---
# FR 17: Podcast detail

> The single-podcast browsing surface — its episode list, episodes-vs-playlists view modes, playback-status filter chips, and a sort order — together with the per-podcast view preferences that remember how each listener last looked at each podcast.

## Purpose

Every podcast a listener cares about needs one screen they can open to see what that show has published and decide what to play. The podcast detail screen is that surface. It is reached from search results, from the Library, from deep links, and from anywhere else the app names a podcast — and once open, its job is to make a potentially large episode catalogue fast to scan and quick to act on.

A podcast catalogue is not a uniform thing. Some shows publish a flat stream of episodes; others are best read grouped — by season, by series, by year. Some listeners want to see everything; others only want what they have not finished. A listener browsing a 600-episode back catalogue wants oldest-first; the same listener on a daily-news show wants newest-first. Because these preferences differ from podcast to podcast and the listener should not have to re-set them on every visit, the detail screen pairs each subscribed podcast with its own persisted view preferences. The screen remembers, per podcast, which view mode was last used, which filter was active, and which sort order applied — so reopening a podcast lands the listener exactly where they left it.

## User-visible Behavior

- **Normal case**: Opening a podcast shows its header (artwork, title, subscribe affordance) followed by its episode list. A search field at the top lets the listener narrow the list by text. Tapping an episode opens it; tapping play starts playback. The list is ordered by the podcast's remembered sort order.
- **View modes**: When a podcast has detectable smart-playlist groupings, a toggle appears above the list offering an "Episodes" flat-list view and one entry per playlist (season, series, year, and so on). Switching to a playlist shows just that grouping's episodes inline. The chosen mode is remembered for that podcast. When no usable grouping exists, the toggle is hidden and only the flat episode list is shown.
- **Filter chips**: In the flat-episode view, a row of chips — All, Unplayed, In Progress — filters the list by playback status. Selecting a chip re-filters the list immediately, and the choice persists per podcast across app restarts.
- **Sort order**: The episode list can be sorted oldest-first or newest-first. The current order is remembered per podcast; toggling it reorders the list in place.
- **Persistence**: For a subscribed podcast, every view-mode, filter, and sort change is written immediately — there is no save step — and the screen reactively reflects the stored value. Reopening the podcast restores the last-used view mode, filter, and sort.
- **Non-subscribed podcasts**: A podcast the listener has not subscribed to (opened from search or a deep link) still supports all the same controls, but the choices are held only for the duration of that visit and start from defaults — there is nothing yet to persist them against.
- **View-mode self-correction**: If a podcast's stored preference says "show a playlist" but the grouping that playlist belonged to is no longer available, the screen falls back to the flat episode list and rewrites the stored preference to match, so the view does not silently flip back later.
- **Empty and error cases**: A podcast with no feed URL, or whose feed fails to load, shows a dedicated empty or error state with a retry affordance rather than a blank list. A filter that matches nothing shows an empty list under the still-visible chips.

## Capabilities

- Presents one podcast's episode list as the primary browsing surface, with a header, an in-list text search field, and per-episode rows that open the episode or start playback.
- Offers two view modes — a flat episode list and a smart-playlist grouped view — surfacing the playlist toggle only when the podcast actually has a usable grouping, and hiding it otherwise.
- Provides playback-status filter chips (All / Unplayed / In Progress) over the flat episode list so the listener can focus on unfinished or untouched episodes.
- Supports an oldest-first / newest-first sort order over the episode list.
- Persists view mode, episode filter, episode sort order, smart-playlist sort, and the selected playlist as per-podcast view preferences, keyed by subscription, written immediately on each change and restored on the next visit.
- Reactively reflects stored preferences: the screen watches the per-podcast preference and re-renders when it changes, with sensible defaults (flat episodes, All filter, newest-first) when no preference has been stored yet.
- Handles non-subscribed podcasts gracefully by keeping the same controls live but holding their state only for the session, since there is no subscription to anchor persistence to.
- Self-heals a stale view preference: when a stored "show this playlist" choice can no longer be honored, it falls back to the flat list and rewrites the stored value to stay consistent.
- Renders distinct empty and error states for missing-feed and feed-load-failure cases, and supports pull-to-refresh to re-sync the podcast's feed from the detail screen.

## Boundaries

- Does not subscribe to or unsubscribe from podcasts, parse RSS feeds, or define how a feed syncs — that is FR 03 (Podcast subscription and feeds). The detail screen hosts a subscribe affordance and can trigger an existing refresh, but the subscription and feed mechanics belong to FR 03.
- Does not play episodes or define playback-completion semantics. Starting, pausing, resuming, and the played / in-progress / unplayed status that the filter chips key on all belong to FR 04 (Audio playback); this screen only reads that status to filter and only hands episodes off to be played.
- Does not display transcripts or chapters — that is FR 08 (Transcript and chapters). The detail screen routes into an episode; transcript and chapter rendering is owned there.
- Does not own the play-order cascade or the play-order bottom sheet. The group → playlist → podcast → global resolution and the sheet that edits a podcast's order are FR 11 (Play order); the detail screen only opens that sheet and consumes the resolved order.
- Does not download episodes or manage the download queue — that is FR 05 (Download and queue).
- Does not author, host, or resolve smart-playlist configuration, and does not decide whether a low-value auto-detected grouping should be suppressed; it consumes the resolved groupings and the visibility decision made upstream.

## Traceability

- **Source docs**:
  - `docs/specs/episode-management.md` (migrated; deleted — per-podcast view preferences and episode-list sections)
- **Source files**:
  - `packages/audiflow_app/lib/features/podcast_detail/presentation/screens/podcast_detail_screen.dart`
  - `packages/audiflow_app/lib/features/podcast_detail/presentation/controllers/podcast_view_mode_controller.dart`
  - `packages/audiflow_app/lib/features/podcast_detail/presentation/widgets/episode_filter_chips.dart`
  - `packages/audiflow_app/lib/features/podcast_detail/presentation/widgets/episode_sort_sheet.dart`
  - `packages/audiflow_domain/lib/src/features/feed/models/podcast_view_preference.dart`
  - `packages/audiflow_domain/lib/src/features/feed/repositories/podcast_view_preference_repository.dart`
  - `packages/audiflow_domain/lib/src/features/feed/providers/podcast_view_preference_providers.dart`
- **Related FR**: `03-subscription-feeds.md`, `04-audio-playback.md`, `08-transcript-chapters.md`, `11-play-order.md`
