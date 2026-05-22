---
refs:
  id: fr:05-download-and-queue
  kind: fr
  title: "Episode download and queue"
  related:
    - fr:04-audio-playback
  modules:
    - packages/audiflow_app/lib/features/download/
    - packages/audiflow_app/lib/features/queue/
    - packages/audiflow_domain/lib/src/features/download/
    - packages/audiflow_domain/lib/src/features/queue/
---
# FR 05: Episode download and queue

> Downloads episodes for offline listening — singly, in bulk, or automatically — and maintains an ordered playback queue that decides what plays next.

## Purpose

A podcast player must work where the network does not: on a commute, on a plane, or on a metered connection. This feature lets listeners pull episode audio onto the device ahead of time so playback is instant and offline-capable, and it gives them a single place to see and manage everything that is downloading. It exists to remove the friction of tapping download on every episode individually and to make offline preparation predictable and bounded.

The queue exists for the complementary reason: once a listener finishes an episode, the player needs to know what comes next without forcing a manual choice each time. The queue is the ordered list of "what plays after this", combining episodes the listener explicitly lined up with episodes that follow naturally from the list they started playing from.

## User-visible Behavior

- **Normal case (single download)**: A listener taps download on an episode. A download task is created and the queue begins processing. Progress is visible on the episode and in the dedicated download management screen. When the file finishes, the episode is available for offline playback.
- **Normal case (download all)**: From a station page or a smart playlist season/group page, the listener opens the overflow menu and chooses "Download all episodes". A confirmation dialog states how many episodes will be downloaded. If the list is longer than the configured batch limit (default 25), the dialog notes that only the first N — in current display/sort order — will be taken. On confirm, a snackbar reports how many downloads were queued.
- **Normal case (automatic download)**: When a subscription has auto-download enabled, newly discovered episodes from a feed sync are enqueued for download automatically, with no listener action.
- **Normal case (queue)**: A listener adds an episode with "Play Next" or "Play Later", or starts playing from an episode list. The Queue screen shows the current episode followed by an "Up Next" list. Items can be reordered by drag, removed, tapped to skip directly to, or cleared all at once.
- **Edge case (already queued/downloading)**: Requesting a download for an episode that already has an active task is a no-op — duplicates are not created, and batch operations simply skip such episodes when counting what was queued.
- **Edge case (no network / Wi-Fi only)**: Downloads wait while offline and resume when connectivity returns. Wi-Fi-only downloads stay pending on cellular and start once Wi-Fi is available.
- **Failure case**: A failed download is retried automatically with exponential backoff (5s, 15s, 45s, 135s, 405s) up to five attempts. After retries are exhausted the task is marked failed and surfaces in the download screen for manual retry.
- **Recovery / fallback**: On app startup, download records are validated — orphaned records whose files are missing are removed, interrupted downloads are reset to pending and resumed. On iOS, where the app container path can change between launches, a stored file path that no longer resolves is reconstructed from the current documents directory.

## Capabilities

- Downloads a single episode on demand, deduplicating against any existing active task for that episode.
- Batch-downloads an arbitrary list of episode IDs (station or season/group pages), capped at a user-configurable limit clamped to a sane range.
- Downloads every episode of a season as a distinct operation.
- Automatically enqueues downloads for new episodes of auto-download-enabled subscriptions during feed sync, idempotently and from both foreground and background sync paths.
- Processes downloads sequentially through a queue that monitors network state, honors the Wi-Fi-only preference, throttles progress writes, and retries failures with exponential backoff.
- Pauses, resumes, cancels, retries, and deletes individual downloads, plus batch cancel/resume by episode and "delete all completed".
- Presents a download management screen grouping tasks by status (downloading, pending, paused, completed, failed, cancelled) and reports total storage used.
- Optionally auto-deletes a downloaded file when its episode is marked played.
- Maintains a playback queue with two tiers: manually added items (Play Next / Play Later) take priority over adhoc items generated from an episode list; the next item is always drawn from manual items first.
- Builds an adhoc queue from the episodes following a starting episode, respecting the effective play order (chronological or as-displayed) and excluding the starting episode itself; the adhoc tier is capped at 100 episodes, and creating a new adhoc queue replaces the previous one (prompting for confirmation only when manual items would be discarded).
- Lets the listener reorder, remove, skip-to, and clear queue items, and pops the next episode for playback when the current one ends.

## Boundaries

- This feature does **not** play audio. Starting, pausing, seeking, background continuation, and interruption handling belong to FR 04 (audio playback). The queue only decides *what* plays next and supplies the next episode; the player consumes it.
- It does **not** decide play order policy itself — the per-scope play-order cascade that yields the effective order is a separate concern; the queue merely applies the order it is handed.
- It does **not** parse RSS feeds or discover episodes; it consumes episodes already stored by the feed/subscription features.
- Batch "download all" is scoped to station and season/group pages. The podcast detail page, queue-based batch download, and background batch scheduling are out of scope.
- Schema and config authoring are owned by the external preset editor; this feature only consumes episode data.

## Traceability

- **Source docs**:
  - `docs/specs/episode-management.md`
  - `docs/superpowers/plans/2026-04-07-download-all-episodes-plan.md`
  - `docs/superpowers/specs/2026-04-07-download-all-episodes-design.md`
- **Source code**:
  - `packages/audiflow_app/lib/features/download/`
  - `packages/audiflow_app/lib/features/queue/`
  - `packages/audiflow_domain/lib/src/features/download/`
  - `packages/audiflow_domain/lib/src/features/queue/`
- **Related FR**: `04-audio-playback.md`
