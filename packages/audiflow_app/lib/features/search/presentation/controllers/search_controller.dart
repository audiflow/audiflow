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
  String? _lastAttemptedQuery;
  String? _pendingQuery;
  ({String query, String country})? _lastCompleted;
  late String _deviceCountry;

  @override
  SearchState build() {
    _deviceCountry = _resolveDeviceCountry();
    ref.onDispose(() {
      _debounceTimer?.cancel();
    });
    return const SearchInitial();
  }

  static String _resolveDeviceCountry() {
    try {
      return PodcastCountries.extractCountryCode(Platform.localeName);
    } catch (_) {
      return PodcastCountries.fallback;
    }
  }

  /// The effective country code for the current search.
  ///
  /// Priority: saved setting > device locale > fallback 'us'.
  String get currentCountry {
    final saved = ref.read(appSettingsRepositoryProvider).getSearchCountry();
    return saved ?? _deviceCountry;
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
    ref.read(appSettingsRepositoryProvider).setSearchCountry(country);

    final query = _lastAttemptedQuery;
    if (query != null) {
      _lastCompleted = null;
      _executeSearch(query);
    } else {
      // Force rebuild so the country chip updates even with no active search
      ref.notifyListeners();
    }
  }

  /// Retries the last attempted search.
  Future<void> retry() async {
    final query = _lastAttemptedQuery;
    if (query != null) {
      _lastCompleted = null;
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
    _lastCompleted = null;
    state = const SearchInitial();
  }

  Future<void> _executeSearch(String query) async {
    final country = currentCountry;

    if (_lastCompleted == (query: query, country: country)) return;

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

      if (!ref.mounted) return;
      if (_pendingQuery != query) return;

      _lastCompleted = (query: query, country: country);
      state = SearchSuccess(result: result);
    } on SearchException catch (e) {
      if (!ref.mounted) return;
      if (_pendingQuery != query) return;

      state = SearchError(
        exception: e,
        lastQuery: query,
        lastResult: previousResult,
      );
    }
  }
}
