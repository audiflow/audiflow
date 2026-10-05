---
refs:
  id: fr:08-transcript-chapters
  kind: fr
  title: "Transcript and chapters"
  related:
    - fr:04-audio-playback
  modules:
    - packages/audiflow_app/lib/features/player/
    - packages/audiflow_domain/lib/src/features/transcript/
---
# FR 08: Transcript and chapters

> Read-along transcripts and chapter navigation for episodes, surfaced in the player as a synced, tappable timeline with native text selection and copy.

## Purpose

Many podcasts publish timed transcripts and chapter markers alongside their audio. Audiflow uses this data to make episodes easier to follow, search, and reference. Listeners who want to read along while listening, jump to a specific moment, skim an episode before committing to it, or look back at something that was said gain a richer experience than audio alone provides. Accessibility also benefits: a visible transcript helps listeners in noisy environments and those who prefer reading.

The feature exists because the Podcasting 2.0 standard now makes transcript and chapter metadata broadly available through RSS (`<podcast:transcript>` and `<podcast:chapters>`). Audiflow consumes that metadata so the player is not just a playback surface but also a navigable, readable view of the episode. Transcript metadata is captured cheaply during normal feed sync, while the larger transcript file content is fetched lazily only when a listener actually opens the transcript, keeping sync fast and storage lean.

## User-visible Behavior

- **Normal case (read-along)**: When the current episode has transcript or chapter data, the full player screen shows a second tab, "Transcript", alongside "Now Playing". Opening it fetches and parses the transcript on first view, then displays a merged timeline: chapter titles appear as section headers, and transcript text appears as a sequence of segments. As audio plays, the segment matching the current playback position is highlighted and the list auto-scrolls to keep it visible.
- **Tap to seek**: Tapping anywhere on a transcript segment — its text or the space around it — seeks playback to that segment's start time, so the transcript doubles as a fine-grained scrubber. A press held long enough to become a long press, or one that moves far enough to scroll, does not seek. Chapter headers serve the same role at coarser granularity.
- **Manual scroll**: While following playback, the active segment is kept about one third of the way down the viewport, regardless of how tall individual segments or chapter headers are. If the listener drags the transcript by hand, following pauses so their reading position is not yanked away; once they have stopped scrolling and lifted their finger for 5 seconds, following resumes and the list scrolls back to the active segment. A floating "jump to current" button appears only while following is paused and re-syncs immediately when tapped.
- **Standalone reading**: A transcript can also be opened in its own full-screen view (outside the player tab) for distraction-free reading of an episode.
- **Text selection and copy**: Transcript segment text, chapter titles, and speaker names support native long-press text selection and the system copy menu, so listeners can quote or save passages. Selection is scoped per segment so it does not interfere with the single-tap seek gesture. Long press starts a selection with drag handles and the copy menu, and double-tap word selection works where the platform offers it; each tap of a double tap also seeks to the segment's start, which is harmless because both land on the same position. A tap while a selection is showing both seeks and clears the selection, so a tap always means "play from here".
- **Chapters on the seek bar**: For an episode with chapters, the full player's seek bar is split at each chapter start by a 2 pt gap; if the first chapter starts after zero, the part before it is an untitled segment. While the listener drags the bar (and only then), a tooltip above it shows the title of the chapter under the scrub position along with the position, and the title changes as the drag crosses a gap. Before the first chapter, or for episodes without chapters, the tooltip shows the position only.
- **Current chapter row**: Under the episode and podcast titles on the Now Playing tab, a row reads `n. Title` with a chevron for the chapter being played, where the current chapter is the one with `startMs <= position < next.startMs` (the last chapter runs to the end). It updates as playback crosses a boundary; before the first chapter starts it reads "Chapters". Tapping it opens a bottom sheet listing every chapter with its number and start time, highlighting the current one; tapping a chapter closes the sheet and seeks to that chapter's start.
- **No chapters**: Episodes without chapter data show neither the row nor the gaps, so the player looks the same as before.
- **Edge case (chapters only)**: An episode may have chapters but no transcript. In that case the timeline still shows the chapter list for navigation, without segment text.
- **Edge / failure case (no data)**: When an episode has neither transcript nor chapter data, the Transcript tab is not shown at all. If a transcript is advertised but its file cannot be fetched or parsed, the tab shows an empty or error state rather than blocking playback.
- **Recovery / fallback**: Transcript availability is also surfaced earlier, as an indicator on episode list items, so listeners know before opening the player whether read-along is available.

## Capabilities

- Captures transcript metadata (URL, MIME type, language, relationship) and chapter data (title, start time, optional artwork and link) during feed sync, without downloading transcript files.
- Lazily downloads, parses, and stores transcript file content on first demand, preferring richer formats (VTT, which carries speaker labels) over plainer ones (SRT) when both are offered.
- Presents a unified player timeline that merges chapter headers and transcript segments in playback order.
- Synchronizes the timeline with playback: highlights the active segment and auto-scrolls to follow it, pausing auto-scroll on manual interaction.
- Lets listeners seek playback by tapping any segment or chapter in the timeline.
- Marks chapter starts on the full player's seek bar, names the chapter under the finger while scrubbing, and shows the current chapter with a chapter list for jumping between chapters (`currentChapterProvider` and `currentEpisodeChaptersProvider` in `audiflow_domain`).
- Offers a standalone transcript reading view independent of the player tab.
- Supports native, per-segment text selection and clipboard copy of transcript text, chapter titles, and speaker names.
- Indicates transcript availability on episode list items so listeners can spot read-along-capable episodes ahead of time.
- Persists parsed transcript content locally so subsequent views and offline reading do not require re-fetching.

## Boundaries

- **RSS parsing is out of scope here**: Extraction of `<podcast:transcript>` and `<podcast:chapters>` tags from feed XML, and parsing of SRT and VTT transcript files into timed segments, are owned by the `audiflow_podcast` package. This FR covers only how that parsed data is stored, surfaced, and interacted with — not parsing internals or supported file formats.
- **No transcript authoring or editing**: Audiflow only consumes transcripts published by podcasters. It does not generate, transcribe, correct, or edit transcript or chapter content.
- **Playback engine is separate**: Seeking, position reporting, and the playback state that drives timeline synchronization belong to audio playback (see FR 04). This feature reads playback position and issues seek requests but does not own the player.
- **Schema and feed sync ownership**: Transcript and chapter metadata enters the database through the feed sync flow; the sync mechanism itself and its scheduling are not part of this FR.
- **Selection scope is limited**: Text selection is intentionally per-segment in the timeline rather than spanning the whole transcript, to preserve the tap-to-seek gesture. Cross-segment selection is not provided.

## Traceability

- **Source docs**:
  - `docs/plans/2026-03-01-podcast-transcript-plan.md`
  - `docs/plans/2026-03-01-podcast-transcript-design.md`
  - `docs/superpowers/plans/2026-04-07-text-selection-copy.md`
  - `docs/superpowers/specs/2026-04-07-text-selection-copy-design.md`
  - `packages/audiflow_podcast/CLAUDE.md`
- **Code referenced**:
  - `packages/audiflow_app/lib/features/player/presentation/widgets/transcript_tab.dart`
  - `packages/audiflow_app/lib/features/player/presentation/widgets/transcript_timeline_view.dart`
  - `packages/audiflow_app/lib/features/player/presentation/screens/transcript_screen.dart`
  - `packages/audiflow_app/lib/features/player/presentation/screens/player_screen.dart`
  - `packages/audiflow_app/lib/features/player/presentation/widgets/current_chapter_row.dart`
  - `packages/audiflow_app/lib/features/player/presentation/widgets/chapter_list_sheet.dart`
  - `packages/audiflow_app/lib/features/player/helpers/chapter_seek_bar_segments.dart`
  - `packages/audiflow_domain/lib/src/features/player/providers/current_chapter_providers.dart`
  - `packages/audiflow_ui/lib/src/widgets/player/player_seek_bar.dart`
  - `packages/audiflow_app/lib/features/podcast_detail/presentation/widgets/episode_list_tile.dart`
  - `packages/audiflow_domain/lib/src/features/transcript/`
- **Related FR**: `04-audio-playback.md`
