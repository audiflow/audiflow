import 'package:audiflow_search/audiflow_search.dart';
import 'package:audiflow_ui/audiflow_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../routing/app_router.dart';
import '../controllers/search_controller.dart';
import '../controllers/search_state.dart';
import '../widgets/country_picker_sheet.dart';
import '../widgets/podcast_search_result_tile.dart';
import '../widgets/search_country_chip.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _textController = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _textController.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _textController.removeListener(_onTextChanged);
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _onCountryTap() async {
    final controller = ref.read(podcastSearchControllerProvider.notifier);
    final selected = await CountryPickerSheet.show(
      context,
      selectedCountry: controller.currentCountry,
    );
    if (selected != null && mounted) {
      controller.onCountryChanged(selected);
    }
  }

  void _onTextChanged() {
    final value = _textController.value;
    final isComposing = value.composing.isValid;
    ref
        .read(podcastSearchControllerProvider.notifier)
        .onQueryChanged(value.text, composing: isComposing);
  }

  void _onSearch() {
    final query = _textController.text;
    if (query.trim().isEmpty) return;

    // Dismiss keyboard
    _focusNode.unfocus();

    ref.read(podcastSearchControllerProvider.notifier).searchImmediate(query);
  }

  void _onRetry() {
    ref.read(podcastSearchControllerProvider.notifier).retry();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(podcastSearchControllerProvider);
    final l10n = AppLocalizations.of(context);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _focusNode.unfocus(),
      child: Scaffold(
        appBar: AppBar(title: Text(l10n.searchTitle)),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(Spacing.md),
              child: TextField(
                controller: _textController,
                focusNode: _focusNode,
                textCapitalization: TextCapitalization.none,
                autocorrect: false,
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                  hintText: l10n.searchHint,
                  border: const OutlineInputBorder(),
                  prefixIcon: SearchCountryChip(
                    countryCode: ref
                        .read(podcastSearchControllerProvider.notifier)
                        .currentCountry,
                    onTap: _onCountryTap,
                  ),
                  suffixIcon: ValueListenableBuilder<TextEditingValue>(
                    valueListenable: _textController,
                    builder: (context, value, child) {
                      if (value.text.isEmpty) {
                        return const SizedBox.shrink();
                      }
                      return IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _textController.clear();
                          ref
                              .read(podcastSearchControllerProvider.notifier)
                              .clear();
                        },
                      );
                    },
                  ),
                ),
                textInputAction: TextInputAction.search,
                onSubmitted: (_) => _onSearch(),
              ),
            ),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _buildContent(state),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(SearchState state) {
    return switch (state) {
      SearchInitial() => _buildInitialState(),
      SearchLoading() => _buildLoadingState(),
      SearchRefreshing(:final previousResult) => _buildRefreshingState(
        previousResult,
      ),
      SearchSuccess(:final result) when result.isEmpty => _buildEmptyState(),
      SearchSuccess(:final result) => _buildResultsList(result),
      SearchError(:final exception, :final lastResult)
          when lastResult != null =>
        _buildErrorWithResults(exception, lastResult),
      SearchError(:final exception) => _buildErrorState(exception),
    };
  }

  Widget _buildInitialState() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);

    return Center(
      key: const Key('search_initial_state'),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.search,
              size: 64,
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
            ),
            const SizedBox(height: Spacing.md),
            Text(
              l10n.searchInitialTitle,
              style: theme.textTheme.titleMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: Spacing.sm),
            Text(
              l10n.searchInitialSubtitle,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      key: Key('search_loading_state'),
      child: CircularProgressIndicator(),
    );
  }

  Widget _buildEmptyState() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);

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
            l10n.searchEmpty,
            style: theme.textTheme.titleMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: Spacing.sm),
          Text(
            l10n.searchEmptySubtitle,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRefreshingState(SearchResult previousResult) {
    final l10n = AppLocalizations.of(context);
    return Column(
      key: const Key('search_refreshing_state'),
      children: [
        Semantics(
          label: l10n.searchRefreshingLabel,
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

  Widget _buildErrorWithResults(
    SearchException exception,
    SearchResult lastResult,
  ) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Column(
      key: const Key('search_error_with_results_state'),
      children: [
        MaterialBanner(
          content: Text(l10n.searchErrorBanner),
          backgroundColor: theme.colorScheme.errorContainer,
          actions: [
            TextButton(onPressed: _onRetry, child: Text(l10n.commonRetry)),
          ],
        ),
        Expanded(
          child: Opacity(opacity: 0.4, child: _buildResultsList(lastResult)),
        ),
      ],
    );
  }

  Widget _buildResultsList(SearchResult result) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columnCount = ResponsiveGrid.columnCount(
          availableWidth: constraints.maxWidth,
        );
        // Phone: keep list layout
        if (columnCount <= 3) {
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
        // Tablet: grid layout
        return GridView.builder(
          key: const Key('search_results_grid'),
          padding: const EdgeInsets.all(Spacing.md),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columnCount,
            mainAxisSpacing: Spacing.sm,
            crossAxisSpacing: Spacing.sm,
            childAspectRatio: 0.8,
          ),
          itemCount: result.podcasts.length,
          itemBuilder: (context, index) {
            final podcast = result.podcasts[index];
            return PodcastArtworkGridItem(
              artworkUrl: podcast.artworkUrl,
              title: podcast.name,
              onTap: () => _navigateToPodcastDetail(podcast),
            );
          },
        );
      },
    );
  }

  void _navigateToPodcastDetail(Podcast podcast) {
    context.push('${AppRoutes.podcastDetail}/${podcast.id}', extra: podcast);
  }

  Widget _buildErrorState(SearchException exception) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);

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
              _getErrorMessage(exception, l10n),
              style: theme.textTheme.titleMedium?.copyWith(
                color: colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: Spacing.lg),
            FilledButton.icon(
              onPressed: _onRetry,
              icon: const Icon(Icons.refresh),
              label: Text(l10n.commonRetry),
            ),
          ],
        ),
      ),
    );
  }

  String _getErrorMessage(SearchException exception, AppLocalizations l10n) {
    return switch (exception.code) {
      StatusCode.unavailable => l10n.searchErrorUnavailable,
      StatusCode.deadlineExceeded => l10n.searchErrorTimeout,
      StatusCode.resourceExhausted => l10n.searchErrorRateLimit,
      StatusCode.invalidArgument => l10n.searchErrorInvalid,
      _ => l10n.searchErrorGeneric,
    };
  }
}
