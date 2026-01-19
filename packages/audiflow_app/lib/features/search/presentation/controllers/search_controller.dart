import 'package:audiflow_search/audiflow_search.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'search_state.dart';

part 'search_controller.g.dart';

/// Controller for managing podcast search state and operations.
///
/// This controller coordinates search requests and manages the UI state
/// transitions between initial, loading, success, and error states.
///
/// Note: Named `PodcastSearchController` to avoid collision with Flutter's
/// built-in `SearchController` from material library.
///
/// Usage:
/// ```dart
/// final state = ref.watch(podcastSearchControllerProvider);
/// final controller = ref.read(podcastSearchControllerProvider.notifier);
///
/// await controller.search('technology podcasts');
/// ```
@riverpod
class PodcastSearchController extends _$PodcastSearchController {
  String? _lastQuery;

  @override
  SearchState build() => const SearchInitial();

  /// Executes a podcast search with the given query.
  ///
  /// Preconditions:
  /// - query must not be empty or whitespace-only
  /// - no search currently in progress (state != SearchLoading)
  ///
  /// Postconditions:
  /// - state transitions to SearchLoading, then SearchSuccess or SearchError
  /// - _lastQuery is updated to the provided query
  ///
  /// This is a stub implementation that immediately returns an error state.
  /// The full implementation will be added in Phase 2.
  Future<void> search(String query) async {
    // Prevent duplicate submissions (Requirement 3.2)
    if (state is SearchLoading) return;

    final trimmed = query.trim();
    if (trimmed.isEmpty) return;

    _lastQuery = trimmed;
    state = const SearchLoading();

    // Stub implementation: immediately return error state
    // Full implementation will connect to PodcastSearchService
    state = SearchError(
      exception: SearchException.internal(
        providerId: 'stub',
        message: 'Search not yet implemented',
      ),
      lastQuery: trimmed,
    );
  }

  /// Retries the last failed search.
  ///
  /// Preconditions:
  /// - _lastQuery must not be null (a previous search must have been attempted)
  ///
  /// Postconditions:
  /// - Equivalent to calling search(_lastQuery)
  Future<void> retry() async {
    if (_lastQuery != null) {
      await search(_lastQuery!);
    }
  }
}
