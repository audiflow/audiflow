import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:audiflow_ui/audiflow_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../routing/app_router.dart';
import '../controllers/library_controller.dart';
import '../widgets/subscription_list_tile.dart';

/// Full-screen list of podcast subscriptions.
///
/// Extracted from [LibraryScreen] to allow direct navigation from the
/// collapsed subscriptions row in the redesigned Library tab.
class SubscriptionsListScreen extends ConsumerStatefulWidget {
  const SubscriptionsListScreen({super.key});

  @override
  ConsumerState<SubscriptionsListScreen> createState() =>
      _SubscriptionsListScreenState();
}

class _SubscriptionsListScreenState
    extends ConsumerState<SubscriptionsListScreen> {
  Future<void> _onRefresh() async {
    final syncService = ref.read(feedSyncServiceProvider);
    final result = await syncService.syncAllSubscriptions(forceRefresh: true);
    if (!mounted) return;

    ref.invalidate(librarySubscriptionsProvider);

    final l10n = AppLocalizations.of(context);

    if (0 < result.errorCount) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            l10n.librarySyncResult(result.successCount, result.errorCount),
          ),
        ),
      );
    } else if (0 < result.successCount) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.librarySyncSuccess(result.successCount))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final subscriptionsAsync = ref.watch(sortedSubscriptionsProvider);
    final sortOrderAsync = ref.watch(podcastSortOrderControllerProvider);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.libraryYourPodcasts),
        actions: [
          sortOrderAsync.when(
            data: (currentOrder) => _SortMenuButton(
              currentOrder: currentOrder,
              onSelected: (order) {
                ref
                    .read(podcastSortOrderControllerProvider.notifier)
                    .setSortOrder(order);
              },
            ),
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
        ],
      ),
      body: subscriptionsAsync.when(
        data: (subscriptions) => _buildContent(context, subscriptions),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _buildErrorState(
          context,
          error.toString(),
          () => ref.invalidate(sortedSubscriptionsProvider),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, List<Subscription> subscriptions) {
    if (subscriptions.isEmpty) {
      return _buildEmptyState(context);
    }

    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: Spacing.md),
            sliver: SliverLayoutBuilder(
              builder: (context, constraints) {
                final columnCount = ResponsiveGrid.columnCount(
                  availableWidth: constraints.crossAxisExtent,
                );
                if (columnCount <= 3) {
                  return SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final subscription = subscriptions[index];
                      return SubscriptionListTile(
                        key: ValueKey(subscription.itunesId),
                        subscription: subscription,
                        onTap: () {
                          final podcast = subscription.toPodcast();
                          context.push(
                            '${AppRoutes.subscriptions}/podcast/${podcast.id}',
                            extra: podcast,
                          );
                        },
                      );
                    }, childCount: subscriptions.length),
                  );
                }
                return SliverGrid(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: columnCount,
                    mainAxisSpacing: Spacing.sm,
                    crossAxisSpacing: Spacing.sm,
                    childAspectRatio: 0.8,
                  ),
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final subscription = subscriptions[index];
                    return PodcastArtworkGridItem(
                      artworkUrl: subscription.artworkUrl,
                      title: subscription.title,
                      onTap: () {
                        final podcast = subscription.toPodcast();
                        context.push(
                          '${AppRoutes.subscriptions}/podcast/${podcast.id}',
                          extra: podcast,
                        );
                      },
                    );
                  }, childCount: subscriptions.length),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(Spacing.lg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.podcasts,
              size: 64,
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
            ),
            const SizedBox(height: Spacing.md),
            Text(l10n.libraryEmpty, style: theme.textTheme.headlineSmall),
            const SizedBox(height: Spacing.sm),
            Text(
              l10n.libraryEmptySubtitle,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(
    BuildContext context,
    String error,
    VoidCallback onRetry,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);

    return Center(
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
              l10n.libraryLoadError,
              style: theme.textTheme.titleMedium?.copyWith(
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: Spacing.sm),
            Text(
              error,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: Spacing.lg),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: Text(l10n.commonRetry),
            ),
          ],
        ),
      ),
    );
  }
}

class _SortMenuButton extends StatelessWidget {
  const _SortMenuButton({required this.currentOrder, required this.onSelected});

  final PodcastSortOrder currentOrder;
  final ValueChanged<PodcastSortOrder> onSelected;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return PopupMenuButton<PodcastSortOrder>(
      icon: const Icon(Icons.sort),
      onSelected: onSelected,
      itemBuilder: (context) => [
        _buildItem(
          PodcastSortOrder.latestEpisode,
          l10n.librarySortByLatestEpisode,
        ),
        _buildItem(
          PodcastSortOrder.subscribedAt,
          l10n.librarySortBySubscribedAt,
        ),
        _buildItem(
          PodcastSortOrder.alphabetical,
          l10n.librarySortByAlphabetical,
        ),
      ],
    );
  }

  PopupMenuItem<PodcastSortOrder> _buildItem(
    PodcastSortOrder order,
    String label,
  ) {
    return PopupMenuItem<PodcastSortOrder>(
      value: order,
      child: Row(
        children: [
          if (order == currentOrder)
            const Padding(
              padding: EdgeInsets.only(right: 8),
              child: Icon(Icons.check, size: 20),
            )
          else
            const SizedBox(width: 28),
          Flexible(child: Text(label, overflow: TextOverflow.ellipsis)),
        ],
      ),
    );
  }
}
