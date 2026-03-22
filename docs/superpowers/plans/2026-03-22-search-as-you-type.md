# Search-as-you-type Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add debounced search-as-you-type with IME support and stale-result dimming to the podcast search screen.

**Architecture:** Extend the existing `SearchState` sealed class with `SearchRefreshing` state. Replace the one-shot `search()` method with debounced `onQueryChanged()` in the controller. Wire `TextEditingController.addListener` in the UI to detect IME composing and pass committed text to the controller.

**Tech Stack:** Flutter, Riverpod (code generation), `audiflow_search` package (unchanged)

**Spec:** `docs/superpowers/specs/2026-03-22-search-as-you-type-design.md`

---

## File Structure

| Action | File | Responsibility |
|--------|------|----------------|
| Modify | `packages/audiflow_app/lib/features/search/presentation/controllers/search_state.dart` | Add `SearchRefreshing`, update `SearchError` with optional `lastResult` |
| Modify | `packages/audiflow_app/lib/features/search/presentation/controllers/search_controller.dart` | Debounce timer, `onQueryChanged`, `searchImmediate`, IME guard, stale-response discard |
| Modify | `packages/audiflow_app/lib/features/search/presentation/screens/search_screen.dart` | Wire `addListener`, handle `SearchRefreshing` with dimmed results + progress bar |
| Modify | `packages/audiflow_app/lib/l10n/app_en.arb` | Add `searchErrorBanner` key |
| Modify | `packages/audiflow_app/lib/l10n/app_ja.arb` | Add `searchErrorBanner` key |
| Modify | `packages/audiflow_app/test/helpers/search_mocks.dart` | Add `QueryTrackingMockSearchService` |
| Modify | `packages/audiflow_app/test/features/search/presentation/controllers/search_controller_test.dart` | New test groups for debounce, IME, dedup, refreshing |
| Modify | `packages/audiflow_app/test/features/search/presentation/screens/search_screen_test.dart` | New tests for dimmed results, progress bar, error banner |

---

## Task 1: Add `SearchRefreshing` state and update `SearchError`

**Files:**
- Modify: `packages/audiflow_app/lib/features/search/presentation/controllers/search_state.dart`
- Modify: `packages/audiflow_app/test/features/search/presentation/controllers/search_controller_test.dart` (state group only)

- [ ] **Step 1: Write failing tests for new states**

Add a new group at the end of the `SearchState` group in `search_controller_test.dart`:

```dart
test('SearchRefreshing is a SearchState with previousResult and pendingQuery', () {
  final result = SearchResult(
    totalCount: 1,
    podcasts: const [],
    provider: 'test',
    timestamp: DateTime.now(),
  );
  final state = SearchRefreshing(previousResult: result, pendingQuery: 'new');

  expect(state, isA<SearchState>());
  expect(state.previousResult, equals(result));
  expect(state.pendingQuery, equals('new'));
});

test('SearchError with lastResult preserves previous results', () {
  final result = SearchResult(
    totalCount: 1,
    podcasts: const [],
    provider: 'test',
    timestamp: DateTime.now(),
  );
  final exception = SearchException.unavailable(
    providerId: 'test',
    message: 'Network error',
  );
  final state = SearchError(
    exception: exception,
    lastQuery: 'query',
    lastResult: result,
  );

  expect(state.lastResult, equals(result));
});

test('SearchError without lastResult has null lastResult', () {
  final exception = SearchException.unavailable(
    providerId: 'test',
    message: 'Network error',
  );
  final state = SearchError(exception: exception, lastQuery: 'query');

  expect(state.lastResult, isNull);
});
```

- [ ] **Step 2: Run tests to verify they fail**

Run: `cd packages/audiflow_app && flutter test test/features/search/presentation/controllers/search_controller_test.dart`
Expected: Compilation errors — `SearchRefreshing` not defined, `SearchError` doesn't accept `lastResult`

- [ ] **Step 3: Implement new states**

In `search_state.dart`, add `SearchRefreshing` class after `SearchLoading` and update `SearchError`:

```dart
/// Refreshing state with previous results visible.
///
/// Shown when a new search is triggered while results are already displayed.
/// The UI should dim previous results and show a progress indicator.
class SearchRefreshing extends SearchState {
  const SearchRefreshing({
    required this.previousResult,
    required this.pendingQuery,
  });

  /// The results from the previous successful search.
  final SearchResult previousResult;

  /// The query currently being searched.
  final String pendingQuery;
}
```

Update `SearchError` to add optional `lastResult`:

```dart
class SearchError extends SearchState {
  const SearchError({
    required this.exception,
    required this.lastQuery,
    this.lastResult,
  });

  final SearchException exception;
  final String lastQuery;

  /// Previous successful results, if any.
  /// When non-null, UI shows dimmed results with an inline error banner.
  final SearchResult? lastResult;
}
```

- [ ] **Step 4: Run tests to verify they pass**

Run: `cd packages/audiflow_app && flutter test test/features/search/presentation/controllers/search_controller_test.dart`
Expected: All tests PASS (including existing ones — `SearchError` constructor is backward-compatible since `lastResult` is optional)

- [ ] **Step 5: Run analyzer**

Run: `cd packages/audiflow_app && flutter analyze`
Expected: No issues (the new `SearchRefreshing` case will cause warnings in `search_screen.dart`'s exhaustive switch — that's expected, we'll fix it in Task 4)

Note: If the analyzer fails on exhaustive switch, add a temporary placeholder in `_buildContent`:
```dart
SearchRefreshing(:final previousResult) => _buildResultsList(previousResult),
```

- [ ] **Step 6: Commit**

```bash
git add packages/audiflow_app/lib/features/search/presentation/controllers/search_state.dart packages/audiflow_app/test/features/search/presentation/controllers/search_controller_test.dart
git commit -m "feat(search): add SearchRefreshing state and optional lastResult on SearchError"
```

---

## Task 2: Add `QueryTrackingMockSearchService` to test helpers

**Files:**
- Modify: `packages/audiflow_app/test/helpers/search_mocks.dart`

- [ ] **Step 1: Add new mock class**

Append to `search_mocks.dart`:

```dart
/// Mock service that tracks all queries and supports completer-based control.
///
/// Each call to search() creates a new Completer. The test controls
/// when each call resolves by completing the completer.
class QueryTrackingMockSearchService implements PodcastSearchService {
  final List<String> queries = [];
  final List<Completer<SearchResult>> completers = [];

  /// Default result returned when completer is completed without a value.
  final SearchResult defaultResult;

  QueryTrackingMockSearchService({SearchResult? defaultResult})
      : defaultResult = defaultResult ??
            SearchResult(
              totalCount: 0,
              podcasts: const [],
              provider: 'mock',
              timestamp: DateTime.now(),
            );

  @override
  Future<SearchResult> search(SearchQuery query) {
    queries.add(query.term);
    final completer = Completer<SearchResult>();
    completers.add(completer);
    return completer.future;
  }

  /// Complete the Nth search call (0-indexed) with a result.
  void complete(int index, [SearchResult? result]) {
    completers[index].complete(result ?? defaultResult);
  }

  /// Fail the Nth search call (0-indexed) with an exception.
  void fail(int index, SearchException exception) {
    completers[index].completeError(exception);
  }

  @override
  Future<SearchEntityResult<T>> searchWithBuilder<T>(
    SearchQuery query, {
    required PodcastSearchEntityBuilder<T> builder,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<SearchResult> getTopCharts(ChartsQuery query, {String? providerId}) {
    throw UnimplementedError();
  }

  @override
  Future<SearchEntityResult<T>> getTopChartsWithBuilder<T>(
    ChartsQuery query, {
    required PodcastSearchEntityBuilder<T> builder,
    String? providerId,
  }) {
    throw UnimplementedError();
  }
}
```

- [ ] **Step 2: Verify it compiles**

Run: `cd packages/audiflow_app && flutter analyze test/helpers/search_mocks.dart`
Expected: No issues

- [ ] **Step 3: Commit**

```bash
git add packages/audiflow_app/test/helpers/search_mocks.dart
git commit -m "test(search): add QueryTrackingMockSearchService for debounce tests"
```

---

## Task 3: Rewrite controller with debounce and IME guard

**Files:**
- Modify: `packages/audiflow_app/lib/features/search/presentation/controllers/search_controller.dart`
- Modify: `packages/audiflow_app/test/features/search/presentation/controllers/search_controller_test.dart`

- [ ] **Step 1: Write failing tests for debounce behavior**

Add new test groups in `search_controller_test.dart`:

```dart
group('PodcastSearchController debounce (search-as-you-type)', () {
  const debounceDuration = Duration(milliseconds: 500);

  test('onQueryChanged does not fire search before debounce elapses', () async {
    final mockService = QueryTrackingMockSearchService();

    final container = ProviderContainer(
      overrides: [
        podcastSearchServiceProvider.overrideWithValue(mockService),
      ],
    );
    addTearDown(container.dispose);

    final controller = container.read(
      podcastSearchControllerProvider.notifier,
    );

    controller.onQueryChanged('flutter');

    // Before debounce elapses
    await Future<void>.delayed(const Duration(milliseconds: 200));
    expect(mockService.queries, isEmpty);

    // Clean up: advance past debounce so timer fires
    await Future<void>.delayed(const Duration(milliseconds: 400));
    // Complete the search to avoid dangling futures
    if (mockService.completers.isNotEmpty) {
      mockService.complete(0);
    }
  });

  test('onQueryChanged fires search after 500ms debounce', () async {
    final mockService = MockPodcastSearchService(
      searchResult: SearchResult(
        totalCount: 0,
        podcasts: const [],
        provider: 'mock',
        timestamp: DateTime.now(),
      ),
    );

    final container = ProviderContainer(
      overrides: [
        podcastSearchServiceProvider.overrideWithValue(mockService),
      ],
    );
    addTearDown(container.dispose);

    final controller = container.read(
      podcastSearchControllerProvider.notifier,
    );

    controller.onQueryChanged('flutter');
    await Future<void>.delayed(debounceDuration + const Duration(milliseconds: 50));

    expect(mockService.searchCallCount, equals(1));
    expect(mockService.lastSearchTerm, equals('flutter'));
  });

  test('rapid typing resets debounce, only final query fires', () async {
    final mockService = QueryTrackingMockSearchService();

    final container = ProviderContainer(
      overrides: [
        podcastSearchServiceProvider.overrideWithValue(mockService),
      ],
    );
    addTearDown(container.dispose);

    final controller = container.read(
      podcastSearchControllerProvider.notifier,
    );

    controller.onQueryChanged('fl');
    await Future<void>.delayed(const Duration(milliseconds: 100));
    controller.onQueryChanged('flu');
    await Future<void>.delayed(const Duration(milliseconds: 100));
    controller.onQueryChanged('flutter');

    await Future<void>.delayed(debounceDuration + const Duration(milliseconds: 50));

    expect(mockService.queries.length, equals(1));
    expect(mockService.queries.first, equals('flutter'));

    mockService.complete(0);
  });

  test('searchImmediate bypasses debounce', () async {
    final mockService = MockPodcastSearchService(
      searchResult: SearchResult(
        totalCount: 0,
        podcasts: const [],
        provider: 'mock',
        timestamp: DateTime.now(),
      ),
    );

    final container = ProviderContainer(
      overrides: [
        podcastSearchServiceProvider.overrideWithValue(mockService),
      ],
    );
    addTearDown(container.dispose);

    final controller = container.read(
      podcastSearchControllerProvider.notifier,
    );

    await controller.searchImmediate('flutter');

    expect(mockService.searchCallCount, equals(1));
    expect(mockService.lastSearchTerm, equals('flutter'));
  });

  test('query below 2 characters does not fire search', () async {
    final mockService = MockPodcastSearchService();

    final container = ProviderContainer(
      overrides: [
        podcastSearchServiceProvider.overrideWithValue(mockService),
      ],
    );
    addTearDown(container.dispose);

    final controller = container.read(
      podcastSearchControllerProvider.notifier,
    );

    controller.onQueryChanged('a');
    await Future<void>.delayed(debounceDuration + const Duration(milliseconds: 50));

    expect(mockService.searchCallCount, equals(0));
  });
});

group('PodcastSearchController IME composing guard', () {
  test('composing input does not trigger search', () async {
    final mockService = MockPodcastSearchService();

    final container = ProviderContainer(
      overrides: [
        podcastSearchServiceProvider.overrideWithValue(mockService),
      ],
    );
    addTearDown(container.dispose);

    final controller = container.read(
      podcastSearchControllerProvider.notifier,
    );

    controller.onQueryChanged('ポッド', composing: true);
    await Future<void>.delayed(const Duration(milliseconds: 600));

    expect(mockService.searchCallCount, equals(0));
  });

  test('committed IME input triggers search', () async {
    final mockService = MockPodcastSearchService(
      searchResult: SearchResult(
        totalCount: 0,
        podcasts: const [],
        provider: 'mock',
        timestamp: DateTime.now(),
      ),
    );

    final container = ProviderContainer(
      overrides: [
        podcastSearchServiceProvider.overrideWithValue(mockService),
      ],
    );
    addTearDown(container.dispose);

    final controller = container.read(
      podcastSearchControllerProvider.notifier,
    );

    // Composing
    controller.onQueryChanged('ポッド', composing: true);
    await Future<void>.delayed(const Duration(milliseconds: 100));

    // Committed
    controller.onQueryChanged('ポッドキャスト');
    await Future<void>.delayed(const Duration(milliseconds: 600));

    expect(mockService.searchCallCount, equals(1));
    expect(mockService.lastSearchTerm, equals('ポッドキャスト'));
  });
});

group('PodcastSearchController dedup and stale discard', () {
  test('same query as last completed result skips API call', () async {
    final mockService = MockPodcastSearchService(
      searchResult: SearchResult(
        totalCount: 1,
        podcasts: [Podcast(id: '1', name: 'Test', artistName: 'Artist')],
        provider: 'mock',
        timestamp: DateTime.now(),
      ),
    );

    final container = ProviderContainer(
      overrides: [
        podcastSearchServiceProvider.overrideWithValue(mockService),
      ],
    );
    addTearDown(container.dispose);

    final controller = container.read(
      podcastSearchControllerProvider.notifier,
    );

    // First search
    await controller.searchImmediate('flutter');
    expect(mockService.searchCallCount, equals(1));

    // Same query again
    await controller.searchImmediate('flutter');
    expect(mockService.searchCallCount, equals(1)); // No additional call
  });

  test('stale response is discarded when query has changed', () async {
    final mockService = QueryTrackingMockSearchService();

    final container = ProviderContainer(
      overrides: [
        podcastSearchServiceProvider.overrideWithValue(mockService),
      ],
    );
    addTearDown(container.dispose);

    final stateHistory = <SearchState>[];
    container.listen(
      podcastSearchControllerProvider,
      (_, state) => stateHistory.add(state),
    );

    final controller = container.read(
      podcastSearchControllerProvider.notifier,
    );

    // Fire two immediate searches
    // ignore: unawaited_futures
    controller.searchImmediate('first');
    // ignore: unawaited_futures
    controller.searchImmediate('second');

    // Complete second first (newer)
    final secondResult = SearchResult(
      totalCount: 1,
      podcasts: [Podcast(id: '2', name: 'Second', artistName: 'Artist')],
      provider: 'mock',
      timestamp: DateTime.now(),
    );
    mockService.complete(1, secondResult);
    await Future<void>.delayed(Duration.zero);

    // Complete first (stale) — should be discarded
    final firstResult = SearchResult(
      totalCount: 1,
      podcasts: [Podcast(id: '1', name: 'First', artistName: 'Artist')],
      provider: 'mock',
      timestamp: DateTime.now(),
    );
    mockService.complete(0, firstResult);
    await Future<void>.delayed(Duration.zero);

    final finalState = container.read(podcastSearchControllerProvider);
    expect(finalState, isA<SearchSuccess>());
    expect((finalState as SearchSuccess).result.podcasts.first.name, equals('Second'));
  });
});

group('PodcastSearchController refreshing state transitions', () {
  test('subsequent search emits SearchRefreshing with previous result', () async {
    final result1 = SearchResult(
      totalCount: 1,
      podcasts: [Podcast(id: '1', name: 'First', artistName: 'Artist')],
      provider: 'mock',
      timestamp: DateTime.now(),
    );
    final result2 = SearchResult(
      totalCount: 1,
      podcasts: [Podcast(id: '2', name: 'Second', artistName: 'Artist')],
      provider: 'mock',
      timestamp: DateTime.now(),
    );

    final mockService = QueryTrackingMockSearchService();

    final container = ProviderContainer(
      overrides: [
        podcastSearchServiceProvider.overrideWithValue(mockService),
      ],
    );
    addTearDown(container.dispose);

    final stateHistory = <SearchState>[];
    container.listen(
      podcastSearchControllerProvider,
      (_, state) => stateHistory.add(state),
      fireImmediately: true,
    );

    final controller = container.read(
      podcastSearchControllerProvider.notifier,
    );

    // First search
    // ignore: unawaited_futures
    controller.searchImmediate('first');
    mockService.complete(0, result1);
    await Future<void>.delayed(Duration.zero);

    // Second search — should go through SearchRefreshing
    // ignore: unawaited_futures
    controller.searchImmediate('second');
    await Future<void>.delayed(Duration.zero);

    // Find the SearchRefreshing state
    final refreshingStates = stateHistory.whereType<SearchRefreshing>().toList();
    expect(refreshingStates, hasLength(1));
    expect(refreshingStates.first.previousResult, equals(result1));
    expect(refreshingStates.first.pendingQuery, equals('second'));

    mockService.complete(1, result2);
    await Future<void>.delayed(Duration.zero);

    final finalState = container.read(podcastSearchControllerProvider);
    expect(finalState, isA<SearchSuccess>());
    expect((finalState as SearchSuccess).result, equals(result2));
  });

  test('error during refresh preserves lastResult', () async {
    final result1 = SearchResult(
      totalCount: 1,
      podcasts: [Podcast(id: '1', name: 'First', artistName: 'Artist')],
      provider: 'mock',
      timestamp: DateTime.now(),
    );

    final mockService = QueryTrackingMockSearchService();

    final container = ProviderContainer(
      overrides: [
        podcastSearchServiceProvider.overrideWithValue(mockService),
      ],
    );
    addTearDown(container.dispose);

    final controller = container.read(
      podcastSearchControllerProvider.notifier,
    );

    // First search succeeds
    // ignore: unawaited_futures
    controller.searchImmediate('first');
    mockService.complete(0, result1);
    await Future<void>.delayed(Duration.zero);

    // Second search fails
    // ignore: unawaited_futures
    controller.searchImmediate('second');
    mockService.fail(
      1,
      SearchException.unavailable(providerId: 'mock', message: 'Network error'),
    );
    await Future<void>.delayed(Duration.zero);

    final finalState = container.read(podcastSearchControllerProvider);
    expect(finalState, isA<SearchError>());
    final errorState = finalState as SearchError;
    expect(errorState.lastResult, equals(result1));
    expect(errorState.lastQuery, equals('second'));
  });

  test('zero results on refresh shows empty state, not stale results', () async {
    final result1 = SearchResult(
      totalCount: 1,
      podcasts: [Podcast(id: '1', name: 'First', artistName: 'Artist')],
      provider: 'mock',
      timestamp: DateTime.now(),
    );
    final emptyResult = SearchResult(
      totalCount: 0,
      podcasts: const [],
      provider: 'mock',
      timestamp: DateTime.now(),
    );

    final mockService = QueryTrackingMockSearchService();

    final container = ProviderContainer(
      overrides: [
        podcastSearchServiceProvider.overrideWithValue(mockService),
      ],
    );
    addTearDown(container.dispose);

    final controller = container.read(
      podcastSearchControllerProvider.notifier,
    );

    // First search succeeds with results
    // ignore: unawaited_futures
    controller.searchImmediate('first');
    mockService.complete(0, result1);
    await Future<void>.delayed(Duration.zero);

    // Second search returns empty
    // ignore: unawaited_futures
    controller.searchImmediate('second');
    mockService.complete(1, emptyResult);
    await Future<void>.delayed(Duration.zero);

    final finalState = container.read(podcastSearchControllerProvider);
    expect(finalState, isA<SearchSuccess>());
    expect((finalState as SearchSuccess).isEmpty, isTrue);
  });

  test('first search error has null lastResult', () async {
    final mockService = QueryTrackingMockSearchService();

    final container = ProviderContainer(
      overrides: [
        podcastSearchServiceProvider.overrideWithValue(mockService),
      ],
    );
    addTearDown(container.dispose);

    final controller = container.read(
      podcastSearchControllerProvider.notifier,
    );

    // ignore: unawaited_futures
    controller.searchImmediate('test');
    mockService.fail(
      0,
      SearchException.unavailable(providerId: 'mock', message: 'Error'),
    );
    await Future<void>.delayed(Duration.zero);

    final finalState = container.read(podcastSearchControllerProvider);
    expect(finalState, isA<SearchError>());
    expect((finalState as SearchError).lastResult, isNull);
  });

  test('timer is cancelled on controller disposal', () async {
    final mockService = MockPodcastSearchService();

    final container = ProviderContainer(
      overrides: [
        podcastSearchServiceProvider.overrideWithValue(mockService),
      ],
    );

    final controller = container.read(
      podcastSearchControllerProvider.notifier,
    );

    // Start a debounced search
    controller.onQueryChanged('flutter');

    // Dispose before debounce fires
    container.dispose();

    // Wait past debounce duration — no search should fire
    await Future<void>.delayed(const Duration(milliseconds: 600));
    expect(mockService.searchCallCount, equals(0));
  });

  test('clear resets _lastCompletedQuery allowing re-search of same term', () async {
    final mockService = MockPodcastSearchService(
      searchResult: SearchResult(
        totalCount: 1,
        podcasts: [Podcast(id: '1', name: 'Test', artistName: 'Artist')],
        provider: 'mock',
        timestamp: DateTime.now(),
      ),
    );

    final container = ProviderContainer(
      overrides: [
        podcastSearchServiceProvider.overrideWithValue(mockService),
      ],
    );
    addTearDown(container.dispose);

    final controller = container.read(
      podcastSearchControllerProvider.notifier,
    );

    await controller.searchImmediate('test');
    expect(mockService.searchCallCount, equals(1));

    controller.clear();

    // Same term again after clear — should fire, not be deduped
    await controller.searchImmediate('test');
    expect(mockService.searchCallCount, equals(2));
  });

  test('clear resets to initial state', () async {
    final mockService = MockPodcastSearchService(
      searchResult: SearchResult(
        totalCount: 1,
        podcasts: [Podcast(id: '1', name: 'Test', artistName: 'Artist')],
        provider: 'mock',
        timestamp: DateTime.now(),
      ),
    );

    final container = ProviderContainer(
      overrides: [
        podcastSearchServiceProvider.overrideWithValue(mockService),
      ],
    );
    addTearDown(container.dispose);

    final controller = container.read(
      podcastSearchControllerProvider.notifier,
    );

    await controller.searchImmediate('test');
    expect(container.read(podcastSearchControllerProvider), isA<SearchSuccess>());

    controller.clear();
    expect(container.read(podcastSearchControllerProvider), isA<SearchInitial>());
  });
});
```

- [ ] **Step 2: Run tests to verify they fail**

Run: `cd packages/audiflow_app && flutter test test/features/search/presentation/controllers/search_controller_test.dart`
Expected: Compilation errors — `onQueryChanged`, `searchImmediate`, `clear` methods don't exist

- [ ] **Step 3: Implement the new controller**

Replace the contents of `search_controller.dart`:

```dart
import 'dart:async';

import 'package:audiflow_search/audiflow_search.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'search_state.dart';

part 'search_controller.g.dart';

/// Debounce duration for search-as-you-type.
const _kDebounceDuration = Duration(milliseconds: 500);

/// Minimum query length to trigger a search.
const _kMinQueryLength = 2;

/// Provider for PodcastSearchService.
///
/// This provider creates a [PodcastSearchService] instance configured with
/// the iTunes provider for podcast search functionality.
///
/// Override this provider in tests to inject mock implementations.
@Riverpod(keepAlive: true)
PodcastSearchService podcastSearchService(Ref ref) {
  final provider = ItunesProvider();
  ref.onDispose(provider.close);
  return PodcastSearchService.create(providers: [provider]);
}

/// Controller for managing podcast search state and operations.
///
/// Supports debounced search-as-you-type with IME composing guards
/// and stale-result display during loading.
@riverpod
class PodcastSearchController extends _$PodcastSearchController {
  Timer? _debounceTimer;
  String? _lastCompletedQuery;
  String? _lastAttemptedQuery;
  String? _pendingQuery;

  @override
  SearchState build() {
    ref.onDispose(() {
      _debounceTimer?.cancel();
    });
    return const SearchInitial();
  }

  /// Called on each text change. Debounces and fires search after 500ms.
  ///
  /// Set [composing] to true when the IME is still composing (e.g., CJK input).
  /// Composing input is ignored to avoid searching incomplete characters.
  void onQueryChanged(String query, {bool composing = false}) {
    if (composing) return;

    _debounceTimer?.cancel();

    final trimmed = query.trim();
    if (trimmed.length < _kMinQueryLength) {
      _clear();
      return;
    }

    _debounceTimer = Timer(_kDebounceDuration, () {
      _executeSearch(trimmed);
    });
  }

  /// Immediately executes a search, bypassing debounce.
  ///
  /// Used for keyboard submit (enter key) and retry.
  Future<void> searchImmediate(String query) async {
    _debounceTimer?.cancel();

    final trimmed = query.trim();
    if (trimmed.isEmpty) return;

    await _executeSearch(trimmed);
  }

  /// Retries the last attempted search.
  Future<void> retry() async {
    if (_lastAttemptedQuery != null) {
      // Reset completed query so dedup doesn't skip retry
      _lastCompletedQuery = null;
      await searchImmediate(_lastAttemptedQuery!);
    }
  }

  /// Clears results and resets to initial state.
  void clear() {
    _clear();
  }

  void _clear() {
    _debounceTimer?.cancel();
    _pendingQuery = null;
    _lastCompletedQuery = null;
    state = const SearchInitial();
  }

  Future<void> _executeSearch(String query) async {
    // Dedup: skip if same as last completed query
    if (query == _lastCompletedQuery) return;

    _lastAttemptedQuery = query;
    _pendingQuery = query;

    // Determine previous result for refreshing state
    final previousResult = switch (state) {
      SearchSuccess(:final result) => result,
      SearchRefreshing(:final previousResult) => previousResult,
      SearchError(:final lastResult) => lastResult,
      _ => null,
    };

    if (previousResult != null) {
      state = SearchRefreshing(previousResult: previousResult, pendingQuery: query);
    } else {
      state = const SearchLoading();
    }

    try {
      final service = ref.read(podcastSearchServiceProvider);
      final result = await service.search(SearchQuery.validated(term: query));

      // Discard stale response if query has changed
      if (_pendingQuery != query) return;

      _lastCompletedQuery = query;
      state = SearchSuccess(result: result);
    } on SearchException catch (e) {
      // Discard stale error if query has changed
      if (_pendingQuery != query) return;

      state = SearchError(
        exception: e,
        lastQuery: query,
        lastResult: previousResult,
      );
    }
  }
}
```

- [ ] **Step 4: Run code generation**

Run: `cd packages/audiflow_app && dart run build_runner build --delete-conflicting-outputs`
Expected: Generates updated `search_controller.g.dart`

- [ ] **Step 5: Run tests to verify they pass**

Run: `cd packages/audiflow_app && flutter test test/features/search/presentation/controllers/search_controller_test.dart`
Expected: All new and existing tests PASS

Note: Some existing tests call `controller.search()` which no longer exists. Update these calls:
- Replace `controller.search('...')` with `controller.searchImmediate('...')`
- Replace `controller.retry()` — this still exists, no change needed
- The `SearchLoading` duplicate prevention test needs updating: `searchImmediate` doesn't block during loading like `search` did. Instead, test that a second `searchImmediate` while one is in-flight results in the first response being discarded.

- [ ] **Step 6: Migrate existing tests to new controller API**

Specific changes required:

1. **All `controller.search('...')` calls** → replace with `controller.searchImmediate('...')`
   - Lines: 128, 166, 198, 216, 254, 262, 263, 288, 308, 361, 419, 444

2. **"duplicate calls during loading are ignored" test** (line 222 group) → **rewrite entirely** as "stale response discard" test. The old test relied on `search()` blocking during `SearchLoading` state. The new controller doesn't block — it fires concurrent requests and discards stale responses. Replace with:

```dart
test('concurrent searches discard stale responses', () async {
  final mockService = QueryTrackingMockSearchService();

  final container = ProviderContainer(
    overrides: [
      podcastSearchServiceProvider.overrideWithValue(mockService),
    ],
  );
  addTearDown(container.dispose);

  final controller = container.read(
    podcastSearchControllerProvider.notifier,
  );

  // Fire three searches rapidly
  // ignore: unawaited_futures
  controller.searchImmediate('first');
  // ignore: unawaited_futures
  controller.searchImmediate('second');
  // ignore: unawaited_futures
  controller.searchImmediate('third');

  expect(mockService.queries.length, equals(3));

  // Complete only the latest
  final thirdResult = SearchResult(
    totalCount: 1,
    podcasts: [Podcast(id: '3', name: 'Third', artistName: 'Artist')],
    provider: 'mock',
    timestamp: DateTime.now(),
  );
  mockService.complete(2, thirdResult);
  await Future<void>.delayed(Duration.zero);

  // Complete stale ones — should be ignored
  mockService.complete(0);
  mockService.complete(1);
  await Future<void>.delayed(Duration.zero);

  final finalState = container.read(podcastSearchControllerProvider);
  expect(finalState, isA<SearchSuccess>());
  expect(
    (finalState as SearchSuccess).result.podcasts.first.name,
    equals('Third'),
  );
});
```

3. **"empty query" and "whitespace-only query" tests** → these still work with `searchImmediate`, just swap the method name.

- [ ] **Step 7: Run full test suite and analyzer**

Run: `cd packages/audiflow_app && flutter test && flutter analyze`
Expected: All tests pass, no analyzer issues (except possibly `search_screen.dart` exhaustive switch if Task 1 Step 5 placeholder wasn't added)

- [ ] **Step 8: Commit migrated tests**

```bash
git add packages/audiflow_app/test/features/search/presentation/controllers/search_controller_test.dart
git commit -m "refactor(search): migrate existing tests to searchImmediate API"
```

- [ ] **Step 9: Commit new controller and new tests**

```bash
git add packages/audiflow_app/lib/features/search/presentation/controllers/search_controller.dart packages/audiflow_app/lib/features/search/presentation/controllers/search_controller.g.dart packages/audiflow_app/test/features/search/presentation/controllers/search_controller_test.dart
git commit -m "feat(search): add debounced search-as-you-type with IME guard"
```

---

## Task 4: Update search screen UI for refreshing state

**Files:**
- Modify: `packages/audiflow_app/lib/features/search/presentation/screens/search_screen.dart`
- Modify: `packages/audiflow_app/lib/l10n/app_en.arb`
- Modify: `packages/audiflow_app/lib/l10n/app_ja.arb`

- [ ] **Step 1: Add localization keys**

In `app_en.arb`, add after the existing search error keys:

```json
"searchErrorBanner": "Search failed. Showing previous results.",
"@searchErrorBanner": { "description": "Inline error banner when refresh fails but previous results exist" }
```

In `app_ja.arb`, add the equivalent:

```json
"searchErrorBanner": "検索に失敗しました。以前の結果を表示しています。",
"@searchErrorBanner": { "description": "Inline error banner when refresh fails but previous results exist" }
```

- [ ] **Step 2: Run localization generation**

Run: `cd packages/audiflow_app && flutter gen-l10n`
Expected: Generates updated localization files

- [ ] **Step 3: Write failing widget tests for refreshing UI**

Add new tests in `search_screen_test.dart`. Follow the existing test pattern: wrap `SearchScreen` in `ProviderScope` with `podcastSearchControllerProvider` overridden to emit the desired state. Use `SlowMockSearchService` or pre-set state via a custom notifier override.

```dart
group('SearchRefreshing state', () {
  testWidgets('shows dimmed previous results during refresh', (tester) async {
    // Setup: override controller to emit SearchRefreshing with a result containing 2 podcasts
    // Act: pump the SearchScreen
    // Assert:
    final opacityWidget = tester.widget<Opacity>(find.byType(Opacity));
    expect(opacityWidget.opacity, equals(0.4));
    expect(find.byType(LinearProgressIndicator), findsOneWidget);
    expect(find.byType(PodcastSearchResultTile), findsNWidgets(2));
  });

  testWidgets('progress indicator has loading semantics', (tester) async {
    // Setup: SearchRefreshing state
    // Assert:
    final semantics = tester.getSemantics(find.byType(LinearProgressIndicator));
    expect(semantics.label, isNotEmpty);
  });

  testWidgets('AnimatedSwitcher wraps results content area', (tester) async {
    // Setup: transition from SearchRefreshing to SearchSuccess
    // Assert: AnimatedSwitcher is present in widget tree
    expect(find.byType(AnimatedSwitcher), findsOneWidget);
  });
});

group('SearchError with lastResult', () {
  testWidgets('shows dimmed results with inline error banner', (tester) async {
    // Setup: SearchError with lastResult containing 2 podcasts
    // Assert:
    final opacityWidget = tester.widget<Opacity>(find.byType(Opacity));
    expect(opacityWidget.opacity, equals(0.4));
    expect(find.byType(MaterialBanner), findsOneWidget);
    expect(find.byType(PodcastSearchResultTile), findsNWidgets(2));
    expect(find.text('Retry'), findsOneWidget); // or l10n key
  });

  testWidgets('shows full error state when no lastResult', (tester) async {
    // Setup: SearchError without lastResult
    // Assert: same as existing error state test
    expect(find.byKey(const Key('search_error_state')), findsOneWidget);
    expect(find.byType(MaterialBanner), findsNothing);
  });
});
```

- [ ] **Step 4: Update search screen implementation**

Replace the `_SearchScreenState` class in `search_screen.dart` with the updated version:

Key changes:
1. Add `_textController.addListener(_onTextChanged)` in `initState` (or override `didChangeDependencies`)
2. Add `_onTextChanged()` method that reads `_textController.value.composing` and calls `controller.onQueryChanged`
3. Wire clear button to also call `controller.clear()`
4. Wrap the `Expanded(child: _buildContent(state))` in an `AnimatedSwitcher` for smooth transitions between stale and fresh results:

```dart
Expanded(
  child: AnimatedSwitcher(
    duration: const Duration(milliseconds: 300),
    child: _buildContent(state),
  ),
),
```

Ensure each state builder returns a widget with a unique `Key` so `AnimatedSwitcher` detects the change (the existing code already uses `Key('search_initial_state')`, `Key('search_loading_state')`, etc. — add `Key('search_refreshing_state')` and `Key('search_error_with_results_state')` to the new builders).

5. Update `_buildContent` switch to handle `SearchRefreshing`:

```dart
Widget _buildContent(SearchState state) {
  return switch (state) {
    SearchInitial() => _buildInitialState(),
    SearchLoading() => _buildLoadingState(),
    SearchRefreshing(:final previousResult) => _buildRefreshingState(previousResult),
    SearchSuccess(:final result) when result.isEmpty => _buildEmptyState(),
    SearchSuccess(:final result) => _buildResultsList(result),
    SearchError(:final exception, :final lastResult) when lastResult != null =>
      _buildErrorWithResults(exception, lastResult),
    SearchError(:final exception) => _buildErrorState(exception),
  };
}
```

5. Add `_buildRefreshingState`:

```dart
Widget _buildRefreshingState(SearchResult previousResult) {
  final l10n = AppLocalizations.of(context);
  return Column(
    children: [
      Semantics(
        label: l10n.searchTitle, // or a dedicated "loading" label
        child: const LinearProgressIndicator(),
      ),
      Expanded(
        child: Opacity(
          opacity: 0.4,
          child: _buildResultsList(previousResult),
        ),
      ),
    ],
  );
}
```

6. Add `_buildErrorWithResults`:

```dart
Widget _buildErrorWithResults(SearchException exception, SearchResult lastResult) {
  final l10n = AppLocalizations.of(context);
  final theme = Theme.of(context);
  return Column(
    children: [
      MaterialBanner(
        content: Text(l10n.searchErrorBanner),
        backgroundColor: theme.colorScheme.errorContainer,
        actions: [
          TextButton(
            onPressed: _onRetry,
            child: Text(l10n.commonRetry),
          ),
        ],
      ),
      Expanded(
        child: Opacity(
          opacity: 0.4,
          child: _buildResultsList(lastResult),
        ),
      ),
    ],
  );
}
```

7. Update `_onSearch` to use `searchImmediate`:

```dart
void _onSearch() {
  final query = _textController.text;
  if (query.trim().isEmpty) return;
  _focusNode.unfocus();
  ref.read(podcastSearchControllerProvider.notifier).searchImmediate(query);
}
```

8. Add text listener setup and disposal:

```dart
@override
void initState() {
  super.initState();
  _textController.addListener(_onTextChanged);
}

void _onTextChanged() {
  final value = _textController.value;
  final isComposing = value.composing.isValid;
  ref.read(podcastSearchControllerProvider.notifier).onQueryChanged(
    value.text,
    composing: isComposing,
  );
}
```

9. Wire clear button to also call controller clear:

```dart
onPressed: () {
  _textController.clear();
  ref.read(podcastSearchControllerProvider.notifier).clear();
},
```

- [ ] **Step 5: Run tests**

Run: `cd packages/audiflow_app && flutter test`
Expected: All tests pass

- [ ] **Step 6: Run analyzer**

Run: `cd packages/audiflow_app && flutter analyze`
Expected: No issues

- [ ] **Step 7: Commit**

```bash
git add packages/audiflow_app/lib/features/search/presentation/screens/search_screen.dart packages/audiflow_app/lib/l10n/app_en.arb packages/audiflow_app/lib/l10n/app_ja.arb packages/audiflow_app/lib/l10n/
git commit -m "feat(search): update search screen for search-as-you-type UX"
```

---

## Task 5: Update integration tests

**Files:**
- Modify: `packages/audiflow_app/test/features/search/presentation/screens/search_screen_test.dart`
- Modify any integration test files that reference `controller.search()`

- [ ] **Step 1: Update existing widget tests for new controller API**

Replace any `controller.search(...)` calls with `controller.searchImmediate(...)` in existing tests.

- [ ] **Step 2: Add integration-level tests for the debounce flow**

Add tests that:
- Simulate typing into the text field via `tester.enterText`
- Verify no search fires immediately
- Use `tester.pump(const Duration(milliseconds: 500))` to advance the debounce
- Verify search fires and results appear

- [ ] **Step 3: Run full test suite**

Run: `cd packages/audiflow_app && flutter test`
Expected: All tests pass

- [ ] **Step 4: Run analyzer**

Run: `cd packages/audiflow_app && flutter analyze`
Expected: No issues

- [ ] **Step 5: Commit**

```bash
git add packages/audiflow_app/test/
git commit -m "test(search): update integration tests for search-as-you-type"
```

---

## Task 6: Final verification

- [ ] **Step 1: Run full monorepo tests**

Run: `melos run test`
Expected: All packages pass

- [ ] **Step 2: Run full monorepo analysis**

Run: `flutter analyze`
Expected: Zero issues

- [ ] **Step 3: Run code generation to ensure nothing is stale**

Run: `melos run codegen`
Expected: No changes needed

- [ ] **Step 4: Review all changes**

Run: `git diff main...HEAD --stat`
Verify only expected files are changed.

- [ ] **Step 5: Squash-ready check**

Verify commit history is clean and each commit builds independently.
