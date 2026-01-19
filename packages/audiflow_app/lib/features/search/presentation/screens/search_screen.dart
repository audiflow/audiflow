import 'package:audiflow_search/audiflow_search.dart';
import 'package:audiflow_ui/audiflow_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../routing/app_router.dart';
import '../controllers/search_controller.dart';
import '../controllers/search_state.dart';
import '../widgets/podcast_search_result_tile.dart';

/// Search screen for discovering podcasts by keyword.
///
/// This screen provides a search input field with a submit button,
/// allowing users to search for podcasts. The screen displays appropriate
/// UI states: initial, loading, results, empty, and error.
///
/// Requirements covered:
/// - 1.1: Search text input field
/// - 1.2: Submit button with search icon
/// - 1.3: Submit button initiates search
/// - 1.4: Enter key initiates search
/// - 1.5: Dismiss keyboard on search
/// - 2.1, 2.2: Display search results
/// - 3.1, 3.2: Loading state with indicator
/// - 4.1: Initial empty state
/// - 4.2: No results found state
/// - 5.1, 5.2, 5.3: Error state with retry
class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _textController = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onSearch() {
    final query = _textController.text;
    if (query.trim().isEmpty) return;

    // Dismiss keyboard (Requirement 1.5)
    _focusNode.unfocus();

    // Call controller search method (Requirements 1.3, 1.4)
    ref.read(podcastSearchControllerProvider.notifier).search(query);
  }

  void _onRetry() {
    ref.read(podcastSearchControllerProvider.notifier).retry();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(podcastSearchControllerProvider);
    final isLoading = state is SearchLoading;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Podcasts'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(Spacing.md),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _textController,
                    focusNode: _focusNode,
                    decoration: const InputDecoration(
                      hintText: 'Search podcasts...',
                      border: OutlineInputBorder(),
                    ),
                    textInputAction: TextInputAction.search,
                    onSubmitted: (_) => _onSearch(),
                  ),
                ),
                const SizedBox(width: Spacing.sm),
                IconButton(
                  icon: const Icon(Icons.search),
                  // Disable submit button during loading (Requirement 3.2)
                  onPressed: isLoading ? null : _onSearch,
                ),
              ],
            ),
          ),
          Expanded(
            child: _buildContent(state),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(SearchState state) {
    return switch (state) {
      SearchInitial() => _buildInitialState(),
      SearchLoading() => _buildLoadingState(),
      SearchSuccess(:final result) when result.isEmpty => _buildEmptyState(),
      SearchSuccess(:final result) => _buildResultsList(result),
      SearchError(:final exception) => _buildErrorState(exception),
    };
  }

  /// Builds the initial state view shown before any search (Requirement 4.1).
  Widget _buildInitialState() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      key: const Key('search_initial_state'),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search,
            size: 64,
            color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
          ),
          const SizedBox(height: Spacing.md),
          Text(
            'Search for podcasts',
            style: theme.textTheme.titleMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: Spacing.sm),
          Text(
            'Enter a keyword to discover podcasts',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the loading state view with indicator (Requirement 3.1).
  Widget _buildLoadingState() {
    return const Center(
      key: Key('search_loading_state'),
      child: CircularProgressIndicator(),
    );
  }

  /// Builds the empty results state (Requirement 4.2).
  Widget _buildEmptyState() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      key: const Key('search_empty_state'),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
          ),
          const SizedBox(height: Spacing.md),
          Text(
            'No podcasts found',
            style: theme.textTheme.titleMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: Spacing.sm),
          Text(
            'Try a different search term',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the results list (Requirements 2.1, 2.2).
  Widget _buildResultsList(SearchResult result) {
    return ListView.builder(
      key: const Key('search_results_list'),
      itemCount: result.podcasts.length,
      itemBuilder: (context, index) {
        final podcast = result.podcasts[index];
        return PodcastSearchResultTile(
          key: Key('search_result_tile_$index'),
          podcast: podcast,
          onTap: () => _navigateToPodcastDetail(podcast),
        );
      },
    );
  }

  /// Navigates to the podcast detail page for the given podcast.
  ///
  /// Extracts the podcast identifier and navigates using go_router.
  /// Requirements: 2.3
  void _navigateToPodcastDetail(Podcast podcast) {
    context.push('${AppRoutes.podcastDetail}/${podcast.id}');
  }

  /// Builds the error state with retry button (Requirements 5.1, 5.2, 5.3).
  Widget _buildErrorState(SearchException exception) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      key: const Key('search_error_state'),
      child: Padding(
        padding: const EdgeInsets.all(Spacing.lg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: colorScheme.error.withValues(alpha: 0.7),
            ),
            const SizedBox(height: Spacing.md),
            Text(
              _getErrorMessage(exception),
              style: theme.textTheme.titleMedium?.copyWith(
                color: colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: Spacing.lg),
            FilledButton.icon(
              onPressed: _onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  /// Maps exception status codes to user-friendly error messages.
  String _getErrorMessage(SearchException exception) {
    return switch (exception.code) {
      StatusCode.unavailable =>
        'Unable to connect. Check your internet connection.',
      StatusCode.deadlineExceeded => 'Search timed out. Please try again.',
      StatusCode.resourceExhausted =>
        'Too many requests. Please wait a moment.',
      StatusCode.invalidArgument => 'Please enter a valid search term.',
      _ => 'Something went wrong. Please try again.',
    };
  }
}
