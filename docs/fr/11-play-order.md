---
refs:
  id: fr:11-play-order
  kind: fr
  title: "Play order"
  related:
    - fr:04-audio-playback
    - fr:05-download-and-queue
  modules:
    - packages/audiflow_core/lib/src/models/auto_play_order.dart
    - packages/audiflow_domain/lib/src/features/feed/models/podcast_sort_order.dart
    - packages/audiflow_domain/lib/src/features/feed/models/podcast_view_preference.dart
    - packages/audiflow_domain/lib/src/features/feed/models/smart_playlist_user_preference.dart
    - packages/audiflow_domain/lib/src/features/feed/models/smart_playlist_group_user_preference.dart
    - packages/audiflow_domain/lib/src/features/feed/repositories/play_order_preference_repository.dart
    - packages/audiflow_domain/lib/src/features/feed/datasources/local/play_order_preference_local_datasource.dart
    - packages/audiflow_domain/lib/src/features/queue/services/queue_service.dart
    - packages/audiflow_app/lib/features/podcast_detail/presentation/widgets/play_order_bottom_sheet.dart
    - packages/audiflow_app/lib/features/library/presentation/controllers/library_controller.dart
    - packages/audiflow_app/lib/features/settings/presentation/screens/playback_settings_screen.dart
---
# FR 11: Play order

> Decides the order in which episodes are queued for playback and the order in which subscribed podcasts are listed, with overrides that cascade from a fine-grained scope down to a single global default.

## Purpose

When a listener taps an episode in a podcast or playlist, the app does not just play that one episode — it builds an ad-hoc queue of what comes next. The order of that queue matters: a narrative or serialized show is best heard oldest-first, while a news or interview show is usually best heard in the order it appears on screen. A single app-wide setting cannot satisfy both at once, because a listener typically subscribes to a mix of show styles, and even a single podcast can contain several playlists with different listening conventions.

This feature exists to make play order a per-context decision instead of a single global toggle. A listener sets a global default once, then overrides it only where it differs — for a specific podcast, a specific smart playlist, or a specific group within a playlist. Any context with no explicit choice inherits from the next level up, so the listener never has to configure every show. The feature also covers a related ordering concern: how the listener's own subscribed-podcast list is sorted, so the library presents itself in whatever way the listener finds easiest to scan.

## User-visible Behavior

- Normal case (global default): In Playback settings the listener picks an "Auto-Play Order" — "Oldest First" (chronological) or "As Displayed" (current screen order). Every ad-hoc queue built from a podcast or playlist follows this order unless a narrower override applies.
- Normal case (per-scope override): On a podcast detail screen, a smart playlist screen, or a smart playlist group screen, the listener opens the overflow menu and taps "Play order". A bottom sheet offers three choices: "Default", "Oldest first", and "As displayed". The "Default" option is annotated with the value it currently resolves to (for example, "Default (oldest first)"), so the listener can see what inheriting means before choosing it. Selecting an explicit value records an override for that scope; selecting "Default" clears the override and restores inheritance.
- Cascade resolution: A scope with no override inherits from its parent. A smart playlist group resolves to its playlist; a playlist resolves to the global default; a podcast resolves directly to the global default. The first explicit, non-default value found while walking up wins. If nothing is set anywhere, the global default applies — and the global default itself is always defined (it falls back to oldest-first).
- Effect on the queue: Once the effective order is known, it is handed to the queue builder. With "Oldest First", the queue is sorted chronologically and contains the episodes that come after the tapped one. With "As Displayed", the queue keeps the on-screen order and contains the episodes listed after the tapped one.
- Edge case (last episode): If the listener starts from the final episode in the resolved order, the resulting ad-hoc queue is empty — there is nothing scheduled to follow.
- Edge case (stations): Stations do not expose a play-order menu. They always queue in the order the station presents episodes, which is the "as displayed" behavior.
- Podcast list sorting: In the library's podcast list, the listener picks a sort order from a menu — by latest episode date, by subscription date, or alphabetically. The current choice is marked, the list reorders immediately, and the choice persists across app restarts. Podcasts with no episodes yet sort last when sorting by latest episode.

## Capabilities

- Defines a global "Auto-Play Order" preference (oldest-first or as-displayed) editable from Playback settings and persisted across restarts.
- Records per-podcast, per-smart-playlist, and per-smart-playlist-group play-order overrides, each of which can also be explicitly set to "default" to mean "inherit".
- Resolves an effective play order for any context by cascading group to playlist to global, or podcast to global, taking the first explicit value encountered.
- Stores scope-level overrides in storage that is separate from config-synced playlist data, so re-syncing upstream preset configuration never overwrites a listener's play-order choices.
- Supplies the resolved play order to the ad-hoc queue builder so the queue that follows a tapped episode honors the context's chosen order.
- Presents a shared "Play order" picker (bottom sheet) on the podcast, smart playlist, and smart playlist group screens, showing the resolved inherited value alongside the explicit choices.
- Sorts the subscribed-podcast list by latest episode date, subscription date, or name, persisting the chosen sort across restarts and placing episode-less podcasts last for the latest-episode sort.

## Boundaries

- Does not play, pause, or otherwise control audio, and does not decide auto-advance behavior between tracks — that is FR 04 (Audio playback).
- Does not own the queue itself, queue persistence, or download management; it only computes the order in which the ad-hoc queue builder arranges episodes — the queue lifecycle is FR 05 (Episode download and queue).
- Does not change the on-screen sort of episode lists within a podcast or playlist; episode-list display sorting is a separate concern with its own controls.
- Does not provide a play-order override for stations; stations always queue in display order and intentionally have no play-order menu.
- Does not author or host smart playlist configuration; play-order overrides are user-only data kept apart from preset-synced playlist entities (see FR 06, Preset).
- Does not offer an ascending/descending toggle for the podcast list sort; each sort option uses its single most natural direction.

## Traceability

- **Source docs**:
  - `docs/superpowers/plans/2026-04-16-scope-level-play-order.md`
  - `docs/superpowers/specs/2026-04-16-scope-level-play-order-design.md`
  - `docs/superpowers/plans/2026-04-04-podcast-sort-order.md`
  - `docs/superpowers/specs/2026-04-04-podcast-sort-order-design.md`
  - `docs/plans/2026-03-07-auto-play-order.md`
- **Source files**:
  - `packages/audiflow_core/lib/src/models/auto_play_order.dart`
  - `packages/audiflow_domain/lib/src/features/feed/models/podcast_sort_order.dart`
  - `packages/audiflow_domain/lib/src/features/feed/models/podcast_view_preference.dart`
  - `packages/audiflow_domain/lib/src/features/feed/models/smart_playlist_user_preference.dart`
  - `packages/audiflow_domain/lib/src/features/feed/models/smart_playlist_group_user_preference.dart`
  - `packages/audiflow_domain/lib/src/features/feed/repositories/play_order_preference_repository.dart`
  - `packages/audiflow_domain/lib/src/features/feed/datasources/local/play_order_preference_local_datasource.dart`
  - `packages/audiflow_domain/lib/src/features/queue/services/queue_service.dart`
  - `packages/audiflow_app/lib/features/podcast_detail/presentation/widgets/play_order_bottom_sheet.dart`
  - `packages/audiflow_app/lib/features/library/presentation/controllers/library_controller.dart`
  - `packages/audiflow_app/lib/features/settings/presentation/screens/playback_settings_screen.dart`
- **Related FR**: `04-audio-playback.md`, `05-download-and-queue.md`
