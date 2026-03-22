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
    final query = _lastAttemptedQuery;
    if (query != null) {
      // Reset completed query so dedup doesn't skip retry
      _lastCompletedQuery = null;
      await searchImmediate(query);
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
      state = SearchRefreshing(
        previousResult: previousResult,
        pendingQuery: query,
      );
    } else {
      state = const SearchLoading();
    }

    try {
      final service = ref.read(podcastSearchServiceProvider);
      final result = await service.search(SearchQuery.validated(term: query));

      // Guard against disposed provider after async gap
      if (!ref.mounted) return;

      // Discard stale response if query has changed
      if (_pendingQuery != query) return;

      _lastCompletedQuery = query;
      state = SearchSuccess(result: result);
    } on SearchException catch (e) {
      // Guard against disposed provider after async gap
      if (!ref.mounted) return;

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
