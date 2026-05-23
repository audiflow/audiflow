---
refs:
  id: fr:02-podcast-discovery
  kind: fr
  title: "Podcast discovery and search"
  related:
    - fr:03-subscription-feeds
    - pkg:audiflow_search
  modules:
    - packages/audiflow_app/lib/features/search/
    - packages/audiflow_search/lib/
---
# FR 02: Podcast discovery and search

> Search-as-you-type podcast discovery: the user types a term and sees matching podcasts appear live, refined by country, ready to open.

## Purpose

A podcast player is only useful once the user has found podcasts to listen to. Discovery is the entry point for every new listener and the ongoing way existing users add to their library. This FR covers how a user searches for podcasts by name or topic and browses the matching results.

Discovery exists to make finding a podcast feel immediate and exploratory rather than transactional. Users frequently do not know the exact title they want — they type a topic, a host name, or a partial phrase and refine as they go. The feature is therefore built around live, debounced results that update while the user types, so the cost of trying another query is low. It also accounts for the fact that podcast catalogs are region-specific: results are scoped to a country so a user sees the podcasts actually relevant to where they are.

## User-visible Behavior

- **Search as you type**: As the user types into the search field, results appear automatically without needing to press a search or submit button. There is a short pause (half a second) after the last keystroke before a search runs, so rapid typing does not fire a request on every character.
- **Minimum query**: Typing only a single character does not trigger a search. At least two characters are required before any results are fetched.
- **Stale results stay visible**: When the user already has results on screen and types a new query, the previous results remain visible — dimmed — with a thin progress bar above them while the new results load. The screen never flashes blank between searches.
- **Submitting explicitly**: Pressing the keyboard's search/enter key runs the search immediately, skipping the debounce pause.
- **IME / CJK input**: While an input method editor is still composing a character (for example, mid-conversion Japanese or other CJK text), no search runs. The search fires only once the text is committed, so incomplete composed characters are never searched.
- **Country scope**: Results are scoped to a country. The country defaults to the device locale (falling back to the US if it cannot be determined), and the user can change it via a country picker. Changing the country re-runs the current search against the new region and the choice is remembered for future searches.
- **No matches**: A search that completes with zero results shows an explicit empty state rather than leaving the previous results on screen.
- **Network or service failure**: If a search fails and there are no earlier results, the user sees a full error state with a retry button. If a search fails while earlier results are still showing, those results stay visible (dimmed) under an inline error banner with a retry action, so a transient failure does not discard what the user already had.
- **Out-of-order responses**: If the user keeps typing while a request is in flight, a slow response for an old query is discarded — only the result matching the most recent query is shown.
- **Clearing**: Clearing the search field (or dropping below two characters) cancels any in-flight request and returns the screen to its initial prompt state.
- **Opening a result**: Tapping a result navigates to that podcast's detail screen, where the user can inspect it and decide whether to subscribe.

## Capabilities

- **Debounced incremental search**: A 500ms debounce after the last committed keystroke turns continuous typing into at most one search per pause, with a two-character minimum before any request is made.
- **Immediate search**: An explicit keyboard submit (and the retry action) bypasses the debounce and runs the search at once.
- **IME-aware input handling**: Composing input is ignored; only committed text triggers a search, making the feature correct for CJK and other multi-keystroke input methods.
- **Refreshing state with retained results**: While a follow-up search loads, the prior results are kept on screen dimmed with a progress indicator, avoiding blank flashes during exploratory refinement.
- **Stale-response discarding**: Each request is keyed by its query and country; a response whose key no longer matches the current pending search is dropped, so older responses cannot overwrite newer ones.
- **Query deduplication**: Re-running the exact same query and country that already produced the displayed results is skipped, avoiding a redundant network call.
- **Country-scoped results**: Searches carry a country code resolved from a saved preference, then the device locale, then a US fallback; the user can change it and the choice persists.
- **Result presentation**: Matching podcasts are shown as a scrollable list on phones and an artwork grid on wider tablet layouts, with explicit initial, loading, empty, and error states.
- **Discovery API client (`audiflow_search`)**: A dedicated package provides the search backend — a `PodcastSearchService` that runs a `SearchQuery` against one or more podcast providers, aggregates and deduplicates their results into a `SearchResult`, and surfaces typed `SearchException`s. The current provider is the iTunes Search API (`ItunesProvider`); the provider abstraction leaves room for additional backends and for top-charts retrieval.

## Boundaries

- **Not subscription**: Discovery ends at the podcast detail screen. Actually subscribing to a found podcast, fetching and storing its feed, and managing subscriptions belong to FR 03 (subscription and feeds). This FR only gets the user to the point of choosing a podcast.
- **Not feed parsing**: Parsing a podcast's RSS feed and extracting its episodes is not part of discovery; the search client returns catalog-level podcast metadata only.
- **Not persistence**: Search results are transient and not written to the local database. Storing podcasts is a subscription/library concern.
- **Not chart browsing in the app**: The `audiflow_search` package can retrieve top charts, but the in-app discovery screen covered here is term-driven search; chart browsing is not a user-facing feature of this FR as it stands.
- **Not implementation detail**: Controller state classes, Riverpod provider wiring, the HTTP client, and provider-aggregation internals are architecture concerns. This FR describes behavior, not the state machine or wire format.

## Traceability

- **Source docs**: `docs/superpowers/plans/2026-03-22-search-as-you-type.md`, `docs/superpowers/specs/2026-03-22-search-as-you-type-design.md`, `packages/audiflow_search/CLAUDE.md`, `packages/audiflow_app/lib/features/search/presentation/controllers/search_controller.dart`, `packages/audiflow_app/lib/features/search/presentation/controllers/search_state.dart`, `packages/audiflow_app/lib/features/search/presentation/screens/search_screen.dart`, `packages/audiflow_search/lib/src/services/podcast_search_service.dart`, `packages/audiflow_search/lib/src/providers/podcast_provider.dart`
- **Related FR**: `fr:03-subscription-feeds` — subscribing to a discovered podcast and managing its feed (forward reference; created separately).
