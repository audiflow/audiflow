import 'dart:async';

import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:audiflow_ui/audiflow_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../routing/app_router.dart';
import '../controllers/library_controller.dart';
import '../../../station/presentation/controllers/station_list_controller.dart';
import '../../../station/presentation/widgets/station_list_tile.dart';
import '../widgets/subscription_list_tile.dart';

class LibraryScreen extends ConsumerStatefulWidget {
  const LibraryScreen({super.key});

  @override
  ConsumerState<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends ConsumerState<LibraryScreen> {
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
    final subscriptionsAsync = ref.watch(librarySubscriptionsProvider);
    final sortedSubscriptionsAsync = ref.watch(sortedSubscriptionsProvider);
    final stationsAsync = ref.watch(stationListProvider);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.libraryTitle)),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push(AppRoutes.stationNew),
        tooltip: l10n.stationNew,
        child: const Icon(Icons.add),
      ),
      body: subscriptionsAsync.when(
        data: (subscriptions) => _buildContent(
          context,
          subscriptions,
          sortedSubscriptionsAsync,
          stationsAsync,
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => _buildErrorState(
          context,
          error.toString(),
          () => ref.invalidate(librarySubscriptionsProvider),
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    List<Subscription> subscriptions,
    AsyncValue<List<Subscription>> sortedSubscriptionsAsync,
    AsyncValue<List<Station>> stationsAsync,
  ) {
    final stations = stationsAsync.value ?? [];
    final hasSubscriptions = subscriptions.where((s) => !s.isCached).isNotEmpty;

    if (!hasSubscriptions && stations.isEmpty) {
      return _buildEmptyState(context);
    }

    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final sortOrderAsync = ref.watch(podcastSortOrderControllerProvider);

    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                Spacing.md,
                Spacing.md,
                Spacing.md,
                Spacing.sm,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l10n.stationSectionTitle,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (stations.isEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: Spacing.md,
                  vertical: Spacing.sm,
                ),
                child: Text(
                  l10n.stationNoStationsYet,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                final station = stations[index];
                return StationListTile(
                  key: ValueKey(station.id),
                  station: station,
                  onTap: () => context.push(
                    '${AppRoutes.library}/station/${station.id}',
                  ),
                );
              }, childCount: stations.length),
            ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                Spacing.md,
                Spacing.md,
                Spacing.md,
                Spacing.sm,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l10n.libraryYourPodcasts,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (hasSubscriptions)
                    _SortMenuButton(
                      currentOrder:
                          sortOrderAsync.value ??
                          PodcastSortOrder.latestEpisode,
                      onSelected: (order) {
                        unawaited(
                          ref
                              .read(podcastSortOrderControllerProvider.notifier)
                              .setSortOrder(order),
                        );
                      },
                    ),
                ],
              ),
            ),
          ),
          if (!hasSubscriptions)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: Spacing.md,
                  vertical: Spacing.sm,
                ),
                child: Text(
                  l10n.stationNoSubscriptionsYet,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            )
          else
            ..._buildSubscriptionsSlivers(context, sortedSubscriptionsAsync),
          const SliverToBoxAdapter(child: SizedBox(height: Spacing.xl)),
        ],
      ),
    );
  }

  List<Widget> _buildSubscriptionsSlivers(
    BuildContext context,
    AsyncValue<List<Subscription>> sortedSubscriptionsAsync,
  ) {
    return [
      sortedSubscriptionsAsync.when(
        data: (sorted) => SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: Spacing.md),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              final subscription = sorted[index];
              return SubscriptionListTile(
                key: ValueKey(subscription.itunesId),
                subscription: subscription,
                onTap: () {
                  final podcast = subscription.toPodcast();
                  context.push(
                    '${AppRoutes.library}/podcast/${podcast.id}',
                    extra: podcast,
                  );
                },
              );
            }, childCount: sorted.length),
          ),
        ),
        loading: () => const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: Spacing.md),
            child: Center(child: CircularProgressIndicator()),
          ),
        ),
        error: (_, _) => const SliverToBoxAdapter(child: SizedBox.shrink()),
      ),
    ];
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
              Symbols.library_music,
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

  String _labelFor(AppLocalizations l10n, PodcastSortOrder order) {
    switch (order) {
      case PodcastSortOrder.latestEpisode:
        return l10n.librarySortByLatestEpisode;
      case PodcastSortOrder.subscribedAt:
        return l10n.librarySortBySubscribedAt;
      case PodcastSortOrder.alphabetical:
        return l10n.librarySortByAlphabetical;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);

    return PopupMenuButton<PodcastSortOrder>(
      tooltip: l10n.librarySortTooltip,
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
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: Spacing.sm,
          vertical: Spacing.xxs,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.sort, size: 16, color: colorScheme.onSurfaceVariant),
            const SizedBox(width: 4),
            Text(
              _labelFor(l10n, currentOrder),
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
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
