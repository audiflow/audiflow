import 'package:audiflow_search/audiflow_search.dart';

/// Search screen state representation.
///
/// This sealed class hierarchy represents all possible states of the search
/// screen, enabling exhaustive pattern matching in the UI.
sealed class SearchState {
  const SearchState();
}

/// Initial state before any search has been performed.
///
/// This state is shown when the search screen is first displayed,
/// before the user has entered any query.
class SearchInitial extends SearchState {
  const SearchInitial();
}

/// Loading state during an active search request.
///
/// This state is shown while waiting for the search API to respond.
/// The UI should display a loading indicator and prevent duplicate submissions.
class SearchLoading extends SearchState {
  const SearchLoading();
}

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

/// Success state with search results.
///
/// This state is shown when a search completes successfully.
/// The results may be empty (no matching podcasts found).
class SearchSuccess extends SearchState {
  const SearchSuccess({required this.result});

  /// The search result containing podcasts and metadata.
  final SearchResult result;

  /// Whether the search returned no matching podcasts.
  bool get isEmpty => result.podcasts.isEmpty;
}

/// Error state with exception details and the last query for retry.
///
/// This state is shown when a search request fails.
/// The UI should display an error message and a retry button.
class SearchError extends SearchState {
  const SearchError({
    required this.exception,
    required this.lastQuery,
    this.lastResult,
  });

  /// The exception that caused the search to fail.
  final SearchException exception;

  /// The query that was being searched when the error occurred.
  ///
  /// This is preserved to enable retry functionality.
  final String lastQuery;

  /// Previous successful results, if any.
  /// When non-null, UI shows dimmed results with an inline error banner.
  final SearchResult? lastResult;
}
