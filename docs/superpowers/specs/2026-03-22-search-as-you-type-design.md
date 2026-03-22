# Search-as-you-type with debounced live results

## Problem

Users must fully type a query and submit before seeing any results. This adds friction to podcast discovery — especially for exploratory searches where users refine as they go.

## Solution

Show live search results as the user types, debounced at 500ms, with IME-aware composing guards. Previous results remain visible (dimmed) while new results load, avoiding blank flashes.

## Behavior

- 500ms debounce after each committed keystroke (constant: `_kDebounceDuration`)
- IME-aware: ignore composing state, only fire on committed text
- Minimum 2 committed characters before first search fires
- Previous results stay visible at reduced opacity while new results load
- New results replace old with a smooth animated transition
- Clearing the field or going below 2 characters: cancel in-flight request, clear results, return to initial state
- Keyboard submit (enter key) triggers immediate search, bypassing debounce
- Zero results on refresh: show empty state, discard stale results

## Cancellation

No `CancelToken` changes to `audiflow_search`. Cancellation is handled at the controller level:

- Controller tracks the query string that triggered each request
- On response, compare the returned query against the current pending query
- If they differ (user typed further), discard the stale response
- This avoids stale results overwriting newer ones without requiring API-level cancellation

## Edge cases

- Empty or whitespace-only after trim: no search
- Same query as currently displayed results: skip API call (dedup via `_lastCompletedQuery` field)
- Network error: keep showing last good results with a subtle error indicator
- Fast typing: only the final debounced query fires

## State model changes

Current states:

```
SearchInitial -> SearchLoading -> SearchSuccess | SearchError
```

New states:

```
First search:      SearchInitial -> SearchLoading -> SearchSuccess | SearchError
Subsequent search: SearchSuccess -> SearchRefreshing -> SearchSuccess | SearchError
```

### State class definitions

```dart
sealed class SearchState {}

final class SearchInitial extends SearchState {}

final class SearchLoading extends SearchState {}

final class SearchRefreshing extends SearchState {
  final SearchResult previousResult;
  final String pendingQuery;
}

final class SearchSuccess extends SearchState {
  final SearchResult result;
}

final class SearchError extends SearchState {
  final SearchException exception;
  final String lastQuery;
  final SearchResult? lastResult; // nullable: present only when refreshing failed
}
```

| State | Description |
|-------|-------------|
| `SearchInitial` | No query, no results |
| `SearchLoading` | First search with no prior results to show |
| `SearchRefreshing` | Has previous `SearchResult` + pending query. UI shows stale results dimmed. |
| `SearchSuccess` | Fresh results displayed |
| `SearchError` | Error occurred. If `lastResult` is non-null, show dimmed results + inline error banner. Otherwise show full error state with retry. |

## Controller changes (search_controller.dart)

- Replace `search(String)` with `onQueryChanged(String, {bool composing = false})`
  - If `composing` is true, return immediately (IME guard)
  - Reset debounce timer on each call
  - After 500ms, fire `_executeSearch(query)`
- Add `searchImmediate(String)` for keyboard submit — cancels debounce timer, calls `_executeSearch` directly
- `retry()` calls `searchImmediate(_lastAttemptedQuery)` (replaces current `search()` call)
- `_executeSearch(String query)`:
  - Trim, validate length (2+ chars)
  - Dedup: skip if `query == _lastCompletedQuery`
  - If current state has results, emit `SearchRefreshing(previousResult, query)`; else emit `SearchLoading`
  - Await `_service.search(SearchQuery(term: query, ...))`
  - On response: if query still matches pending query, emit `SearchSuccess`; otherwise discard
  - On error: emit `SearchError` with `lastResult` from previous state if available
- `ref.onDispose()`: cancel debounce timer
- Track `_lastCompletedQuery` (String?) for dedup
- Track `_lastAttemptedQuery` (String?) for retry — updated before each `_executeSearch` call
- `retry()` reads `_lastAttemptedQuery` (not `_lastCompletedQuery`, which only updates on success)

## UI changes (search_screen.dart)

- Use `TextEditingController` + `addListener` instead of `onChanged` to access full `TextEditingValue` (needed for `composing` range detection)
- Pass `value.composing.isValid` as `composing` flag to controller
- Keep `onSubmitted` wired to `searchImmediate`
- `SearchRefreshing` state:
  - Render previous results at `Opacity(opacity: 0.4)`
  - Show thin `LinearProgressIndicator` below search field
- `SearchError` with `lastResult`:
  - Show dimmed results + inline `MaterialBanner` or `SnackBar` with error message and retry
- `AnimatedSwitcher` wrapping results list for stale-to-fresh transitions
- Accessibility: add `Semantics(label: 'Loading new results')` on the progress indicator

## Packages affected

| Package | Changes |
|---------|---------|
| `audiflow_app` | Controller, state, search screen UI |
| `audiflow_search` | None |

## Testing plan

### Unit tests (search_controller)
- Debounce fires after 500ms of inactivity
- Debounce resets on new input within window
- Composing input (`composing: true`) does not trigger search
- Committed input triggers search
- Stale response discarded when query has changed
- Dedup: same query as `_lastCompletedQuery` skips API call
- State transitions: Initial -> Loading -> Success
- State transitions: Success -> Refreshing -> Success
- State transitions: Success -> Refreshing -> Error (preserves lastResult)
- State transitions: Initial -> Loading -> Error (no lastResult)
- Keyboard submit bypasses debounce
- Query below 2 characters does not fire search
- Empty/whitespace query does not fire search
- Clear field cancels in-flight and returns to Initial
- Timer disposed on controller disposal
- Zero results on refresh shows empty state (not stale results)

### Widget tests (search_screen)
- Results dim to ~0.4 opacity during SearchRefreshing
- Linear progress indicator shown during SearchRefreshing
- Progress indicator has loading semantics label
- Previous results remain visible during loading
- Fresh results animate in on SearchSuccess
- Inline error banner shown over dimmed results (SearchError with lastResult)
- Full error state with retry shown (SearchError without lastResult)

### Integration tests
- Type query -> debounce -> results appear flow
- Type partial -> continue typing -> only final query fires
- Search -> get results -> modify query -> stale results dim -> new results appear
- IME composing -> commit -> search fires only on commit
