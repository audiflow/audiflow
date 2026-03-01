# Podcast Transcript & Chapter Support

## Overview

Add podcast transcript and chapter support to Audiflow, enabling read-along during playback, full-text search across episode transcripts, offline reading, and chapter-based navigation.

## Decisions

| Decision | Choice | Rationale |
|----------|--------|-----------|
| Transcript source | RSS `<podcast:transcript>` only | Podcasting 2.0 standard, widely adopted, matches existing models |
| File format priority | SRT + VTT first | Timed formats enable sync, search, and seeking |
| Storage | Drift tables for segments | Enables SQL full-text search and efficient range queries |
| Player UI | Tab in full player screen | Keeps transcript and controls together, Apple Podcasts pattern |
| Chapter + transcript | Unified timeline | Chapters as section headers in transcript flow |
| Fetch strategy | Lazy with metadata | Metadata on sync, content on first play or demand |

## Data Model

### New Drift Tables (migration v16 -> v17)

**`EpisodeTranscripts`** -- Metadata table (populated during feed sync)

| Column | Type | Notes |
|--------|------|-------|
| `id` | integer (PK) | auto-increment |
| `episodeId` | integer (FK) | references Episodes |
| `url` | text | remote transcript URL |
| `type` | text | MIME type: `text/vtt`, `application/srt`, etc. |
| `language` | text (nullable) | e.g. `en-US`, `ja-JP` |
| `rel` | text (nullable) | `captions` or `transcript` |
| `fetchedAt` | dateTime (nullable) | null = content not yet downloaded |

**`TranscriptSegments`** -- Content table (populated on demand)

| Column | Type | Notes |
|--------|------|-------|
| `id` | integer (PK) | auto-increment |
| `transcriptId` | integer (FK) | references EpisodeTranscripts |
| `startMs` | integer | segment start in milliseconds |
| `endMs` | integer | segment end in milliseconds |
| `text` | text | segment text content |
| `speaker` | text (nullable) | speaker name (VTT `<v>` tags) |
| `chapterIndex` | integer (nullable) | links to chapter ordering |

Index: `(transcriptId, startMs)`

**`EpisodeChapters`** -- Chapter table (populated during feed sync)

| Column | Type | Notes |
|--------|------|-------|
| `id` | integer (PK) | auto-increment |
| `episodeId` | integer (FK) | references Episodes |
| `index` | integer | chapter ordering |
| `title` | text | chapter title |
| `startMs` | integer | chapter start in milliseconds |
| `endMs` | integer (nullable) | chapter end in milliseconds |
| `url` | text (nullable) | chapter webpage |
| `imageUrl` | text (nullable) | chapter artwork |

Index: `(episodeId, startMs)`

**`TranscriptSegmentsFts`** -- FTS5 virtual table mirroring `TranscriptSegments.text` for full-text search.

### Feed Sync Flow

1. RSS parser extracts `<podcast:transcript>` and `<podcast:chapters>` tags
2. Transcript metadata upserted into `EpisodeTranscripts` (no file download)
3. Chapter data upserted into `EpisodeChapters` (chapters are small, stored immediately)

### Transcript Content Fetch (on first play / on demand)

1. Download SRT/VTT file from URL via Dio
2. Parse into segments with `TranscriptFileParser`
3. Bulk insert into `TranscriptSegments`
4. Set `fetchedAt` on the `EpisodeTranscripts` row

## Parsing Layer (audiflow_podcast)

### RSS Extraction (entity_factory.dart)

Complete the existing TODO methods:

- `_extractTranscripts()` -- Parse `<podcast:transcript>` elements. Each element has attributes: `url`, `type`, `language`, `rel`. Map to existing `PodcastTranscript` model.
- `_extractChapters()` -- Parse `<podcast:chapters>` element. Handle inline chapters via `<psc:chapters>` (Podlove Simple Chapters) and remote chapters via URL attribute.

### New Transcript File Parsers

Three classes in `audiflow_podcast/src/parser/`:

- **`SrtParser`** -- Parses SubRip format. Extracts sequence number, timestamps (`HH:MM:SS,mmm --> HH:MM:SS,mmm`), and text lines. Returns `List<TranscriptSegment>`.
- **`VttParser`** -- Parses WebVTT format. Similar to SRT but supports speaker identification via `<v SpeakerName>` tags and NOTE blocks.
- **`TranscriptFileParser`** -- Facade that selects the right parser based on MIME type. Entry point for the domain layer.

### New Model

`TranscriptSegment` -- Pure data class with `startMs`, `endMs`, `text`, `speaker` fields. Shared output type for all parsers.

## Repository & Service Layer (audiflow_domain)

### TranscriptRepository

Interface + implementation. Methods:

- `getTranscriptMetas(episodeId)` -- list available transcripts
- `getSegments(transcriptId, {startMs, endMs})` -- range query
- `getCurrentSegment(transcriptId, positionMs)` -- active segment lookup
- `searchSegments(query, {episodeIds})` -- FTS5 search
- `upsertMetas(episodeId, metas)` -- store metadata from feed sync
- `upsertSegments(transcriptId, segments)` -- bulk insert parsed content
- `isContentFetched(transcriptId)` -- check if file has been downloaded

### ChapterRepository

Interface + implementation. Methods:

- `getChapters(episodeId)` -- list chapters
- `getCurrentChapter(episodeId, positionMs)` -- active chapter lookup
- `upsertChapters(episodeId, chapters)` -- store from feed sync

### TranscriptService

Orchestrates the lazy fetch flow:

1. Check if content exists via `isContentFetched`
2. Download file from URL via Dio
3. Parse with `TranscriptFileParser`
4. Bulk insert segments
5. Mark transcript as fetched
6. Prefer VTT over SRT when both available (VTT supports speaker tags)

### Riverpod Providers

- `transcriptMetasProvider(episodeId)` -- watches transcript metadata (for UI icons)
- `transcriptSegmentsProvider(transcriptId)` -- streams all segments
- `currentSegmentProvider(transcriptId)` -- derives active segment from playback position
- `chaptersProvider(episodeId)` -- watches chapters
- `currentChapterProvider(episodeId)` -- derives active chapter from playback position
- `transcriptSearchProvider(query)` -- full-text search across stored segments

## Player Screen UI (audiflow_app)

### Tab Bar Addition

Add a tab bar to the full player screen:

- **"Now Playing"** -- current player content (artwork, description, controls)
- **"Transcript"** -- unified timeline view (visible only when episode has transcript or chapters)

### Unified Timeline Widget (TranscriptTimelineView)

A scrollable list merging chapters and transcript segments:

```
+-----------------------------+
| > Chapter 1: Introduction   |  <- chapter header (tappable to seek)
|-----------------------------|
|   Welcome to the show...    |  <- segment (highlighted when active)
|   Today we're talking...    |  <- segment
|-----------------------------|
| > Chapter 2: Main Topic     |  <- chapter header
|-----------------------------|
|   So let's dive into...     |  <- segment
+-----------------------------+
```

### Behaviors

- **Auto-scroll** -- list scrolls to keep the active segment visible, active segment highlighted with subtle background color
- **Tap-to-seek** -- tapping any segment seeks audio to that segment's `startMs`
- **Manual scroll pauses auto-scroll** -- user scroll pauses sync; a "Jump to current" floating button appears to re-sync
- **Chapter headers** -- sticky headers when chapters exist; tapping seeks to chapter start
- **Fallback** -- chapters only: show chapter list with durations; neither: hide tab

### Episode Detail Screen

- Transcript icon/badge on episodes with transcript metadata
- "Read transcript" button opens transcript in a standalone scrollable view (offline reading)

## Full-Text Search

### FTS5 Integration

- `TranscriptSegmentsFts` virtual table mirrors `TranscriptSegments.text`
- Kept in sync via Drift triggers on insert/delete

### Search Flow

1. User types query in search bar
2. `transcriptSearchProvider(query)` queries FTS5 with `MATCH`
3. Results join back to segments, transcripts, and episodes
4. Display: episode artwork + title + timestamp + highlighted snippet
5. Tapping a result navigates to player and seeks to segment timestamp

### Scope Limitation

Only fetched/parsed transcripts are searchable. UI shows: "Search covers episodes you've listened to or viewed transcripts for."

## Testing Strategy

| Layer | Coverage |
|-------|----------|
| `audiflow_podcast` | SRT parser, VTT parser (with/without speakers), RSS transcript/chapter extraction |
| `audiflow_domain` | Repository CRUD, TranscriptService fetch-and-store, FTS5 search, range queries, migration v16->v17 |
| `audiflow_app` | TranscriptTimelineView (auto-scroll, tap-to-seek, chapter headers), tab visibility, search results |

Existing test assets: `podcast_transcript_test.dart` (226 lines), `podcast_chapter_test.dart` (215 lines).

Add SRT/VTT fixture files for parser tests.

## Implementation Phases

1. RSS parsing extraction (complete the TODOs in entity_factory.dart)
2. Drift schema migration + new tables
3. SRT/VTT file parsers
4. Repository + TranscriptService
5. Chapters in player screen
6. Transcript timeline view with sync
7. Full-text search
8. Episode detail transcript indicators
