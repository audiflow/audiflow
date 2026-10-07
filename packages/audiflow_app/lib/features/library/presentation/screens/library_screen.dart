import 'dart:async';

import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:audiflow_ui/audiflow_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../routing/app_router.dart';
import '../../../station/presentation/controllers/station_list_controller.dart';
import '../../../station/presentation/widgets/station_grid_tile.dart';
import '../controllers/library_controller.dart';
import '../widgets/continue_listening_section.dart';
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

  /// Opens the episode detail on top of its podcast, so back leads to the
  /// podcast rather than straight to the Library.
  void _openEpisode(
    EpisodeWithProgress item,
    List<Subscription> subscriptions,
  ) {
    final episode = item.episode;
    final subscription = subscriptions
        .where((s) => s.id == episode.podcastId)
        .firstOrNull;
    if (subscription == null) return;
    final path =
        '${AppRoutes.library}/podcast/${subscription.itunesId}/'
                '${AppRoutes.episodeDetail}'
            .replaceAll(':episodeGuid', Uri.encodeComponent(episode.guid));
    context.go(
      path,
      extra: <String, dynamic>{
        'episode': episode.toPodcastItem(feedUrl: subscription.feedUrl),
        'podcastTitle': subscription.title,
        'artworkUrl': subscription.artworkUrl,
        'itunesId': subscription.itunesId,
        'progress': item,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Watch order matters: sortedSubscriptionsProvider depends on
    // librarySubscriptionsProvider, and watching the upstream first trips a
    // Riverpod < 3.3.2 debug assertion when this screen resumes from a
    // disabled TickerMode after the upstream was invalidated
    // (rrousselGit/riverpod#4709). Keep the dependent provider first until
    // riverpod can be upgraded.
    final sortedSubscriptionsAsync = ref.watch(sortedSubscriptionsProvider);
    final subscriptionsAsync = ref.watch(librarySubscriptionsProvider);
    final stationsAsync = ref.watch(stationListProvider);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: subscriptionsAsync.when(
          data: (subscriptions) => _buildContent(
            context,
            subscriptions,
            sortedSubscriptionsAsync,
            stationsAsync,
          ),
          loading: () => _withTitle(
            l10n,
            const Center(child: CircularProgressIndicator()),
          ),
          error: (error, stack) => _withTitle(
            l10n,
            _ErrorState(
              error: error.toString(),
              onRetry: () => ref.invalidate(librarySubscriptionsProvider),
            ),
          ),
        ),
      ),
    );
  }

  Widget _withTitle(AppLocalizations l10n, Widget body) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LargeTitle(l10n.libraryTitle),
        Expanded(child: body),
      ],
    );
  }

  Widget _buildContent(
    BuildContext context,
    List<Subscription> subscriptions,
    AsyncValue<List<Subscription>> sortedSubscriptionsAsync,
    AsyncValue<List<Station>> stationsAsync,
  ) {
    final l10n = AppLocalizations.of(context);
    final stations = stationsAsync.value ?? [];
    final owned = subscriptions.where((s) => !s.isCached).toList();

    if (owned.isEmpty && stations.isEmpty) {
      return _withTitle(l10n, const _EmptyState());
    }

    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: LargeTitle(l10n.libraryTitle)),
          SliverToBoxAdapter(
            child: ContinueListeningSection(
              onEpisodeTap: (item) => _openEpisode(item, subscriptions),
            ),
          ),
          ..._stationSlivers(context, stations),
          const SliverToBoxAdapter(child: SizedBox(height: Spacing.sectionGap)),
          SliverPersistentHeader(
            pinned: true,
            delegate: _PodcastsHeaderDelegate(
              child: _PodcastsHeader(podcastCount: owned.length),
            ),
          ),
          if (owned.isEmpty)
            SliverToBoxAdapter(
              child: _InlinePlaceholder(l10n.stationNoSubscriptionsYet),
            )
          else
            _podcastsSliver(sortedSubscriptionsAsync),
          const SliverToBoxAdapter(child: SizedBox(height: Spacing.xl)),
        ],
      ),
    );
  }

  List<Widget> _stationSlivers(BuildContext context, List<Station> stations) {
    final l10n = AppLocalizations.of(context);
    return [
      SliverToBoxAdapter(
        child: SectionHeader(
          title: l10n.stationSectionTitle,
          trailing: IconButton(
            tooltip: l10n.stationAdd,
            icon: Icon(Icons.add_rounded, color: AppColors.of(context).accent),
            onPressed: () => context.push(AppRoutes.stationNew),
          ),
        ),
      ),
      if (stations.isEmpty)
        SliverToBoxAdapter(child: _InlinePlaceholder(l10n.stationNoStationsYet))
      else
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(
            Spacing.screenHorizontal,
            Spacing.xs,
            Spacing.screenHorizontal,
            0,
          ),
          sliver: SliverList.separated(
            itemCount: (stations.length + 1) ~/ 2,
            separatorBuilder: (_, _) => const SizedBox(height: _gridGap),
            itemBuilder: (context, row) =>
                _stationRow(context, stations.skip(row * 2).take(2).toList()),
          ),
        ),
    ];
  }

  static const double _gridGap = 12;

  // Rows of two instead of a SliverGrid so each tile sizes to its content
  // and large text never overflows a fixed aspect ratio.
  Widget _stationRow(BuildContext context, List<Station> pair) {
    Widget tile(Station station) => StationGridTile(
      key: ValueKey(station.id),
      station: station,
      onTap: () => context.push('${AppRoutes.library}/station/${station.id}'),
    );
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: tile(pair.first)),
        const SizedBox(width: _gridGap),
        Expanded(child: 1 < pair.length ? tile(pair[1]) : const SizedBox()),
      ],
    );
  }

  Widget _podcastsSliver(
    AsyncValue<List<Subscription>> sortedSubscriptionsAsync,
  ) {
    return sortedSubscriptionsAsync.when(
      data: (sorted) => SliverToBoxAdapter(
        child: GroupedSection(
          // Aligns separators with the text, past the 52px artwork.
          separatorIndent: 76,
          children: [
            for (final subscription in sorted)
              SubscriptionListTile(
                key: ValueKey(subscription.itunesId),
                subscription: subscription,
                onTap: () {
                  final podcast = subscription.toPodcast();
                  context.push(
                    '${AppRoutes.library}/podcast/${podcast.id}',
                    extra: podcast,
                  );
                },
              ),
          ],
        ),
      ),
      loading: () => const SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: Spacing.md),
          child: Center(child: CircularProgressIndicator()),
        ),
      ),
      error: (_, _) => const SliverToBoxAdapter(child: SizedBox.shrink()),
    );
  }
}

/// Keeps the podcasts header row pinned under the status bar while the
/// list scrolls beneath it.
class _PodcastsHeaderDelegate extends SliverPersistentHeaderDelegate {
  const _PodcastsHeaderDelegate({required this.child});

  final Widget child;

  static const double _extent = Spacing.minTouchTarget + Spacing.sm;

  @override
  double get minExtent => _extent;

  @override
  double get maxExtent => _extent;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return ColoredBox(
      color: AppColors.of(context).bg,
      child: Align(alignment: Alignment.topCenter, child: child),
    );
  }

  @override
  bool shouldRebuild(_PodcastsHeaderDelegate oldDelegate) =>
      child != oldDelegate.child;
}

class _PodcastsHeader extends ConsumerWidget {
  const _PodcastsHeader({required this.podcastCount});

  final int podcastCount;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final colors = AppColors.of(context);
    final sortOrder =
        ref.watch(podcastSortOrderControllerProvider).value ??
        PodcastSortOrder.latestEpisode;
    return SectionHeader(
      title: l10n.libraryPodcastsSection,
      trailing: podcastCount == 0
          ? null
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  l10n.libraryPodcastCount(podcastCount),
                  style: AppTextStyles.meta.copyWith(color: colors.inkTertiary),
                ),
                Text(
                  ' · ',
                  style: AppTextStyles.meta.copyWith(color: colors.inkTertiary),
                ),
                _SortMenuButton(
                  currentOrder: sortOrder,
                  onSelected: (order) => unawaited(
                    ref
                        .read(podcastSortOrderControllerProvider.notifier)
                        .setSortOrder(order),
                  ),
                ),
              ],
            ),
    );
  }
}

class _InlinePlaceholder extends StatelessWidget {
  const _InlinePlaceholder(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.screenHorizontal,
        vertical: Spacing.sm,
      ),
      child: Text(
        text,
        style: AppTextStyles.meta.copyWith(
          color: AppColors.of(context).inkTertiary,
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final l10n = AppLocalizations.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(Spacing.lg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Symbols.library_music, size: 64, color: colors.inkQuaternary),
            const SizedBox(height: Spacing.md),
            Text(
              l10n.libraryEmpty,
              style: AppTextStyles.sectionTitle.copyWith(color: colors.ink),
            ),
            const SizedBox(height: Spacing.sm),
            Text(
              l10n.libraryEmptySubtitle,
              style: AppTextStyles.body.copyWith(color: colors.inkSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.error, required this.onRetry});

  final String error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
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
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: Spacing.md),
            Text(
              l10n.libraryLoadError,
              style: AppTextStyles.rowTitle.copyWith(color: colors.ink),
            ),
            const SizedBox(height: Spacing.sm),
            Text(
              error,
              style: AppTextStyles.meta.copyWith(color: colors.inkSecondary),
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
    return switch (order) {
      PodcastSortOrder.latestEpisode => l10n.librarySortByLatestEpisode,
      PodcastSortOrder.subscribedAt => l10n.librarySortBySubscribedAt,
      PodcastSortOrder.alphabetical => l10n.librarySortByAlphabetical,
    };
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final l10n = AppLocalizations.of(context);
    final style = AppTextStyles.meta.copyWith(
      color: colors.accent,
      fontWeight: FontWeight.w600,
    );

    return PopupMenuButton<PodcastSortOrder>(
      tooltip: l10n.librarySortTooltip,
      onSelected: onSelected,
      itemBuilder: (context) => [
        for (final order in PodcastSortOrder.values)
          _buildItem(order, _labelFor(l10n, order)),
      ],
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: Spacing.minTouchTarget),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.sort, size: 16, color: colors.accent),
            const SizedBox(width: Spacing.xs),
            Text(_labelFor(l10n, currentOrder), style: style),
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
