import 'package:audiflow_search/audiflow_search.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'search_state.dart';

part 'search_controller.g.dart';

/// Provider for PodcastSearchService.
///
/// This provider creates a [PodcastSearchService] instance configured with
/// the iTunes provider for podcast search functionality.
///
/// Override this provider in tests to inject mock implementations.
@riverpod
PodcastSearchService podcastSearchService(Ref ref) {
  final provider = ItunesProvider();
  ref.onDispose(provider.close);
  return PodcastSearchService.create(providers: [provider]);
}

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
  Future<void> search(String query) async {
    // Prevent duplicate submissions (Requirement 3.2)
    if (state is SearchLoading) return;

    final trimmed = query.trim();
    if (trimmed.isEmpty) return;

    _lastQuery = trimmed;
    state = const SearchLoading();

    try {
      final service = ref.read(podcastSearchServiceProvider);
      final result = await service.search(
        SearchQuery.validated(term: trimmed),
      );
      state = SearchSuccess(result: result);
    } on SearchException catch (e) {
      state = SearchError(exception: e, lastQuery: trimmed);
    }
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
