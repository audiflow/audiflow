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
- **Normal case (automatic download)**: When a subscription has auto-download enabled, newly discovered episodes from a feed sync are enqueued for download automatically, with no listener action. A foreground sync that enqueues downloads starts the queue right away, so they begin without waiting for a network change or the next app resume.
- **Normal case (queue)**: A listener adds an episode with "Play Next" or "Play Later", or starts playing from an episode list. The Queue screen shows the current episode followed by an "Up Next" list. The current episode sits on a card in the player's artwork-derived color with a white progress line along its bottom edge. Each up-next row shows artwork, a two-line title, "duration · date" with its download state at the row's end (a check once downloaded, a progress ring with the percentage while downloading, or a waiting / paused / failed label), and a drag handle as its only control. Items can be reordered by the handle, which does nothing else (tapping or holding it never skips to the episode or opens the row menu), removed by swiping left, given the next download step by swiping right — the swipe shows that step for the current state (Download, Pause, Resume, Cancel, Retry, or Delete) and a first download confirms with a "Download started" message as the row springs back — tapped to skip directly to, or cleared all at once; remove and download are also offered as accessibility actions, and long-pressing the row anywhere but the handle opens a menu holding "Go to episode", "Keep download" for an auto download (see below), the same download step spelled out (e.g. "Pause download", "Delete download"), and "Share episode". Pausing a running download keeps it paused with its partial file, so resuming continues from where it stopped.
- **Edge case (already queued/downloading)**: Requesting a download for an episode that already has an active task is a no-op — duplicates are not created, and batch operations simply skip such episodes when counting what was queued.
- **Edge case (no network / Wi-Fi only)**: Downloads wait while offline and resume when connectivity returns. Wi-Fi-only downloads stay pending on cellular and start once Wi-Fi is available.
- **Failure case**: A failed download is retried automatically with exponential backoff (5s, 15s, 45s, 135s, 405s) up to five attempts. While a task waits out its backoff, the queue moves on to the tasks behind it rather than stalling. After retries are exhausted the task is marked failed and surfaces in the download screen for manual retry, which restores the full retry budget. Errors up to and including saving the completed status are retried this way; once the task is marked completed, a failure in follow-up work (station list updates, usage reporting) is logged and the episode is not downloaded again.
- **Recovery / fallback**: On app startup, download records are validated — orphaned records whose files are missing are removed, interrupted downloads are reset to pending and resumed. On iOS, where the app container path can change between launches, a stored file path that no longer resolves is reconstructed from the current documents directory.

## Capabilities

- Downloads a single episode on demand, deduplicating against any existing active task for that episode.
- Batch-downloads an arbitrary list of episode IDs (station or season/group pages), capped at a user-configurable limit clamped to a sane range.
- Downloads every episode of a season as a distinct operation.
- Automatically enqueues downloads for new episodes of auto-download-enabled subscriptions during feed sync, idempotently and from both foreground and background sync paths. Only the newest new episodes up to the podcast's keep count are enqueued; older ones are skipped for good.
- Keeps at most N unstarted auto downloads per podcast (default 3; choices 1, 2, 3, 5, 10). N is a global setting that each podcast can override from its settings sheet. After every feed sync, and immediately when N changes, the oldest unstarted auto downloads beyond N are deleted, ranked by publish date (download time when the feed omits it). Episodes the listener has started or finished, manual downloads, and failed or cancelled tasks neither count toward N nor get deleted by this rule. The background refresh applies the same rule but skips a task another isolate is still downloading; the next foreground sync removes it.
- Pauses auto-download for a podcast the listener has stopped playing: once 5 auto downloads have been created for it since its last play, new episodes are no longer downloaded (they are marked processed, so nothing is backfilled later). Counting downloads rather than days adapts to each feed's release cadence. Playing any episode of the podcast, turning its auto-download back on, or tapping Resume in its settings sheet (where the paused state is shown) resumes it. No notification is sent.
- Processes downloads sequentially through a queue that monitors network state, honors the Wi-Fi-only preference, throttles progress writes, and retries failures with exponential backoff without letting a backed-off task block the rest of the queue.
- Pauses, resumes, cancels, retries, and deletes individual downloads (including pending and paused ones), plus batch cancel/resume by episode. Deleting a download also removes the partial file a paused, cancelled, or failed download left behind, after any running transfer of it has stopped. A download of the same episode requested while those files are being deleted (or while a deleted download's leftover file is being discarded) keeps its own file: it is saved under the same name, so it is created only once the deletion is done.
- Bulk-deletes downloads by status group from the download management screen (completed; pending and paused; failed and cancelled; or all), after a confirmation dialog that states how many downloads will be removed. Active downloads in the group are cancelled before removal.
- Presents a download management screen grouping tasks by status (downloading, pending, paused, completed, failed, cancelled) and reports total storage used. Auto downloads that retention may remove carry an "Auto-downloaded" note in their status line (below the progress bar while downloading) and a keep button; kept (manual) downloads carry no note.
- Records whether each download was requested by the listener (manual) or by auto-download (auto). Requesting a manual download for an episode that already has an auto download promotes it to manual. Downloads created before origin tracking existed count as manual.
- Lets the listener keep an auto download so retention never removes it: "Keep download" promotes it to manual and confirms with a "Download kept" message. It is offered only for an auto download that is pending, downloading, paused, or completed (failed and cancelled tasks hold no file), in the episode detail `…` menu, the episode row menus (podcast episodes, smart playlist / series episodes), the queue long-press menu, and on the download management tile. Kept downloads are removed only by the listener.
- Removes the downloads of episodes that drop out of their feed, manual and auto alike, in both foreground and background sync: once the episode is gone nothing could reach its file. Pending, paused, and in-flight downloads are cancelled first. A download that cannot be removed (an undeletable file, or in the background a task another isolate is still writing or a background download worker is running) keeps its episode, so the next sync, which still finds it missing from the feed, retries both; one such failure does not stop the sync or the other removals. Until that retry succeeds, the sync does not keep the feed's cache validators, so an unchanged feed is fetched in full instead of being answered "not modified" and skipping the retry.
- Removes played auto downloads (on by default, toggleable): on app launch and resume, a completed auto download whose episode was finished at least 24 hours earlier is deleted. Manual downloads are never removed, marking an episode unplayed within the 24 hours keeps its file, and a file is kept while its episode is being replayed (the 24 hours restart when the replay finishes; see FR 04).
- Retention removes an auto download from every list as soon as it decides to delete it, then deletes its files. If the files cannot be deleted, or the app stops before they are, the next retention pass (launch, resume, or feed sync) deletes them; a download of the same episode requested in the meantime keeps its file. A keep request that arrives after retention removed the download finds nothing to keep.
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
  - `docs/superpowers/plans/2026-04-07-download-all-episodes-plan.md`
  - `docs/superpowers/specs/2026-04-07-download-all-episodes-design.md`
- **Source code**:
  - `packages/audiflow_app/lib/features/download/`
  - `packages/audiflow_app/lib/features/queue/`
  - `packages/audiflow_domain/lib/src/features/download/`
  - `packages/audiflow_domain/lib/src/features/queue/`
  - `packages/audiflow_domain/lib/src/features/feed/services/dropped_episode_remover.dart`
- A download worker that finishes or fails a task whose record was deleted meanwhile (for example by another isolate's dropped-episode cleanup) removes the file it wrote instead of leaving it on disk with no record pointing at it.
- **Related FR**: `04-audio-playback.md`
