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

The feature exists because feeds now commonly publish transcript and chapter metadata through RSS: transcripts through the Podcasting 2.0 `<podcast:transcript>` tag, and chapters either inline as Podlove Simple Chapters (`<psc:chapters>`) or as a JSON file linked by the Podcasting 2.0 `<podcast:chapters>` tag. Audiflow consumes that metadata so the player is not just a playback surface but also a navigable, readable view of the episode. Metadata and links are captured cheaply during normal feed sync, while larger files (transcripts and JSON chapters) are fetched lazily only when they are needed, keeping sync fast and storage lean.

## User-visible Behavior

- **Normal case (read-along)**: When the current episode has a transcript that loads, the full player screen has a second page, "Transcript", alongside "Now Playing", reached by swiping the artwork or from the overflow menu. The player fetches and parses the transcript when it shows the episode, and adds the page once the content is stored. The page displays a merged timeline: chapter titles appear as section headers, and transcript text appears as a sequence of segments. As audio plays, the segment matching the current playback position is highlighted and the list auto-scrolls to keep it visible.
- **Tap to seek**: Tapping anywhere on a transcript segment — its text or the space around it — seeks playback to that segment's start time, so the transcript doubles as a fine-grained scrubber. A press held long enough to become a long press, or one that moves far enough to scroll, does not seek. Chapter headers serve the same role at coarser granularity.
- **Manual scroll**: While following playback, the active segment is kept about one third of the way down the viewport, regardless of how tall individual segments or chapter headers are. If the listener drags the transcript by hand, following pauses so their reading position is not yanked away; once they have stopped scrolling and lifted their finger for 5 seconds, following resumes and the list scrolls back to the active segment. A floating "jump to current" button appears only while following is paused and re-syncs immediately when tapped.
- **Standalone reading**: A transcript can also be opened in its own full-screen view (outside the player tab) for distraction-free reading of an episode.
- **Text selection and copy**: Transcript segment text, chapter titles, and speaker names support native long-press text selection and the system copy menu, so listeners can quote or save passages. Selection is scoped per segment so it does not interfere with the single-tap seek gesture. Long press starts a selection with drag handles and the copy menu, and double-tap word selection works where the platform offers it; each tap of a double tap also seeks to the segment's start, which is harmless because both land on the same position. A tap while a selection is showing both seeks and clears the selection, so a tap always means "play from here".
- **Chapters on the seek bar**: For an episode with chapters, the full player's seek bar is split at each chapter start by a 2 pt gap; if the first chapter starts after zero, the part before it is an untitled segment. While the listener drags the bar (and only then), a tooltip above it shows the title of the chapter under the scrub position along with the position, and the title changes as the drag crosses a gap. Before the first chapter, or for episodes without chapters, the tooltip shows the position only.
- **Current chapter row**: Under the episode and podcast titles on the Now Playing tab, a row reads `n. Title` with a chevron for the chapter being played, where the current chapter is the one with `startMs <= position < next.startMs` (the last chapter runs to the end). It updates as playback crosses a boundary; before the first chapter starts it reads "Chapters". Tapping it opens a bottom sheet listing every chapter with its number and start time, highlighting the current one; tapping a chapter closes the sheet and seeks to that chapter's start.
- **No chapters**: Episodes without chapter data show neither the row nor the gaps, so the player looks the same as before.
- **Edge case (chapters only)**: An episode may have chapters but no transcript. It gets no Transcript page; its chapters are reached from the current chapter row and the seek bar.
- **Edge / failure case (no transcript to show)**: The Transcript page is offered only for a transcript that actually loaded. When the episode declares no transcript, declares only unsupported formats, or every declared file fails to download, comes back empty, or holds no cues, the player has a single page: the artwork cannot be swiped to a transcript page and the overflow menu has no Transcript item (it is hidden, not disabled). Playback is never blocked. While the fetch is still running the player also shows a single page; the page and menu item appear once the transcript is stored. Because the page appears only after its content is stored, a fetch cannot fail after the page was shown. When the preferred file (VTT) is unusable, the next declared file (SRT) is tried.
- **Failure memory**: A file that downloads but holds no transcript (empty, or no cues for its declared type) is recorded as unusable and is neither fetched nor offered again, also after a feed sync re-declares it. A network or HTTP failure is not recorded on disk: the transcript is hidden for the rest of the session and tried again the next time the player shows the episode after a restart. Leaving the player while a transcript is still downloading abandons the download; that is not counted as a failure, so the next visit fetches again.
- **Transcript indicator on episode rows**: Episode list items show a CC indicator. A row never downloads a transcript to decide this, so the indicator answers from what is already known: once a fetch this session has settled whether the episode's transcript loads, the indicator follows that answer (and changes in place when the player finds a declared file unusable); otherwise it trusts the feed's declaration of a supported file not already recorded as unusable. A declared file that has never been fetched therefore shows the indicator until the episode is opened in the player.
- **Chapter sources**: An episode shows chapters from one source at a time, chosen by priority: the `<podcast:chapters>` JSON file first, then `<psc:chapters>` in the feed, then chapters derived from a timestamp list in the show notes. `<psc:chapters>` are stored during feed sync. For `<podcast:chapters>`, sync stores only the link; the JSON file is downloaded when the episode becomes the now-playing episode (starting playback or restoring it at launch), and its chapters then replace any `<psc:chapters>` and appear in the player without reopening it. JSON entries marked `toc: false` and entries without a title are skipped. A later sync never replaces stored chapters with chapters from a lower-priority source. When a synced feed links a different JSON file, it is fetched again; when the link disappears, the JSON chapters are removed.
- **Chapters from show notes**: Many feeds publish chapters only as a timestamp list in the episode description (for example `02:57 Topic` per line). When the feed has no chapters for an episode, Audiflow derives them from that list. After HTML is reduced to text lines (`<br>`, `<p>`, and `<li>` break lines), a line counts when it starts with a `m:ss`, `mm:ss`, or `h:mm:ss` time, optionally bulleted or bracketed (`[00:00]`, `【00:00】`), followed by `-`, `–`, `:`, `〜`, or a space (or directly by the title after a closing bracket), and then a title. Consecutive such lines form a list, and the first list that has at least 3 entries, starts at 0:00 (up to 0:10 for a short intro), has strictly increasing times, and stays within the episode duration when it is known, becomes the chapters; times inside sentences never do. If the description has no such list, `<content:encoded>` is tried. Derivation runs during feed sync for the episodes that sync parses and, because an incremental sync only parses episodes newer than the ones already stored, also when an episode without chapters becomes the now-playing episode, which covers episodes stored before this existed. Derived chapters are replaced as soon as feed or JSON chapters arrive. When an episode becomes now playing, chapters derived earlier are refreshed if its stored notes changed and removed if the notes no longer hold a list.
- **Failure case (JSON chapters)**: If the JSON file cannot be fetched or parsed, the episode keeps whatever chapters it already had (or none), playback is unaffected, and no error is shown. The download is retried the next time the episode becomes now playing, at most once every 10 minutes per file.

## Capabilities

- Captures transcript metadata (URL, MIME type, language, relationship), `<psc:chapters>` chapter data (title, start time, optional artwork and link), and the `<podcast:chapters>` JSON link during feed sync, without downloading transcript or chapter files.
- Lazily downloads and stores `<podcast:chapters>` JSON chapters for the now-playing episode, preferring them over `<psc:chapters>`.
- Derives chapters from a timestamp list in the show notes when the feed provides none, during feed sync and for the now-playing episode.
- Lazily downloads, parses, and stores transcript file content when the episode is shown in the full player, preferring richer formats (VTT, which carries speaker labels) over plainer ones (SRT) and falling back to the next declared file when one is unusable (`TranscriptService.ensureContent`, `usableTranscriptIdProvider`).
- Presents a unified player timeline that merges chapter headers and transcript segments in playback order.
- Synchronizes the timeline with playback: highlights the active segment and auto-scrolls to follow it, pausing auto-scroll on manual interaction.
- Lets listeners seek playback by tapping any segment or chapter in the timeline.
- Marks chapter starts on the full player's seek bar, names the chapter under the finger while scrubbing, and shows the current chapter with a chapter list for jumping between chapters (`currentChapterProvider` and `currentEpisodeChaptersProvider` in `audiflow_domain`).
- Offers a standalone transcript reading view independent of the player tab.
- Supports native, per-segment text selection and clipboard copy of transcript text, chapter titles, and speaker names.
- Indicates transcript availability on episode list items without fetching (`episodeHasTranscriptProvider`, which prefers this session's fetch outcomes from `transcriptFetchOutcomesProvider` over declared metadata).
- Records transcript files that hold no transcript (`EpisodeTranscript.unusableAt`) so they are not offered or fetched again.
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
  - `packages/audiflow_app/lib/features/player/presentation/widgets/transcript_timeline_view.dart`
  - `packages/audiflow_app/lib/features/player/presentation/screens/transcript_screen.dart`
  - `packages/audiflow_app/lib/features/player/presentation/screens/player_screen.dart`
  - `packages/audiflow_app/lib/features/player/presentation/widgets/current_chapter_row.dart`
  - `packages/audiflow_app/lib/features/player/presentation/widgets/chapter_list_sheet.dart`
  - `packages/audiflow_app/lib/features/player/helpers/chapter_seek_bar_segments.dart`
  - `packages/audiflow_domain/lib/src/features/player/providers/current_chapter_providers.dart`
  - `packages/audiflow_ui/lib/src/widgets/player/player_seek_bar.dart`
  - `packages/audiflow_app/lib/features/podcast_detail/presentation/widgets/episode_list_tile.dart`
  - `packages/audiflow_app/lib/features/podcast_detail/presentation/widgets/smart_playlist_episode_list_tile.dart`
  - `packages/audiflow_domain/lib/src/features/transcript/providers/transcript_availability_providers.dart`
  - `packages/audiflow_domain/lib/src/features/transcript/`
  - `packages/audiflow_domain/lib/src/features/transcript/services/chapter_service.dart`
  - `packages/audiflow_domain/lib/src/features/transcript/providers/chapter_loader_provider.dart`
  - `packages/audiflow_podcast/lib/src/parser/json_chapters_parser.dart`
  - `packages/audiflow_podcast/lib/src/parser/description_chapters_parser.dart`
- **Related FR**: `04-audio-playback.md`
