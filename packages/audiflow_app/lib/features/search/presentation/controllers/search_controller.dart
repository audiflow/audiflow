import 'dart:async';
import 'dart:io' show Platform;

import 'package:audiflow_core/audiflow_core.dart';
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:audiflow_search/audiflow_search.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'search_state.dart';

part 'search_controller.g.dart';

/// Debounce duration for search-as-you-type.
const _kDebounceDuration = Duration(milliseconds: 500);

/// Minimum query length to trigger a search.
const _kMinQueryLength = 2;

/// Provider for PodcastSearchService.
@Riverpod(keepAlive: true)
PodcastSearchService podcastSearchService(Ref ref) {
  final provider = ItunesProvider();
  ref.onDispose(provider.close);
  return PodcastSearchService.create(providers: [provider]);
}

/// Controller for managing podcast search state and operations.
@riverpod
class PodcastSearchController extends _$PodcastSearchController {
  Timer? _debounceTimer;
  String? _lastCompletedQuery;
  String? _lastAttemptedQuery;
  String? _pendingQuery;
  String? _lastCompletedCountry;

  @override
  SearchState build() {
    ref.onDispose(() {
      _debounceTimer?.cancel();
    });
    return const SearchInitial();
  }

  /// Resolves the effective country code for search.
  ///
  /// Priority: saved setting > device locale > fallback 'us'.
  String _resolveCountry() {
    final settings = ref.read(appSettingsRepositoryProvider);
    try {
      return settings.getSearchCountry() ??
          PodcastCountries.extractCountryCode(Platform.localeName);
    } catch (_) {
      return PodcastCountries.fallback;
    }
  }

  /// Called on each text change. Debounces and fires search after 500ms.
  ///
  /// Set [composing] to true when the IME is still composing (e.g., CJK input).
  /// Composing input is ignored to avoid searching incomplete characters.
  void onQueryChanged(String query, {bool composing = false}) {
    _debounceTimer?.cancel();

    if (composing) return;

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
    if (trimmed.length < _kMinQueryLength) return;

    await _executeSearch(trimmed);
  }

  /// Called when the user changes the search country.
  ///
  /// Persists the selection and re-executes the current search if one exists.
  void onCountryChanged(String country) {
    final settings = ref.read(appSettingsRepositoryProvider);
    settings.setSearchCountry(country);

    final query = _lastAttemptedQuery;
    if (query != null) {
      _lastCompletedQuery = null;
      _lastCompletedCountry = null;
      _executeSearch(query);
    }
  }

  /// Retries the last attempted search.
  Future<void> retry() async {
    final query = _lastAttemptedQuery;
    if (query != null) {
      // Reset completed query so dedup doesn't skip retry
      _lastCompletedQuery = null;
      _lastCompletedCountry = null;
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
    _lastCompletedCountry = null;
    state = const SearchInitial();
  }

  Future<void> _executeSearch(String query) async {
    final country = _resolveCountry();

    // Dedup: skip if same query AND same country as last completed
    if (query == _lastCompletedQuery && country == _lastCompletedCountry) {
      return;
    }

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
      final result = await service.search(
        SearchQuery.validated(term: query, country: country),
      );

      // Guard against disposed provider after async gap
      if (!ref.mounted) return;

      // Discard stale response if query has changed
      if (_pendingQuery != query) return;

      _lastCompletedQuery = query;
      _lastCompletedCountry = country;
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
