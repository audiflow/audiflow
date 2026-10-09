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
import '../../../station/presentation/utils/station_recency.dart';
import '../../../station/presentation/widgets/station_grid_sliver.dart';
import '../controllers/library_controller.dart';
import '../widgets/continue_listening_section.dart';
import '../widgets/subscription_list_tile.dart';

class LibraryScreen extends ConsumerStatefulWidget {
  const LibraryScreen({super.key});

  @override
  ConsumerState<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends ConsumerState<LibraryScreen> {
  /// Narrows the podcast list by title or author; never persisted. Owned
  /// here, not by the field, so the query and the field cannot disagree
  /// when the field leaves the tree (an emptied library) and comes back.
  final _filterController = TextEditingController();

  @override
  void dispose() {
    _filterController.dispose();
    super.dispose();
  }

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

  /// Pushes only the episode detail, so back returns straight to the
  /// Library; the podcast stays one tap away through the episode's podcast
  /// link. `go` would rebuild the nested path and slip the never-visited
  /// podcast detail in between.
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
    context.push(
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
              podcastIds: {for (final s in subscriptions) s.id},
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
          else ...[
            SliverToBoxAdapter(
              child: _PodcastFilterField(
                controller: _filterController,
                onChanged: (_) => setState(() {}),
              ),
            ),
            _podcastsSliver(sortedSubscriptionsAsync),
          ],
          const SliverToBoxAdapter(child: SizedBox(height: Spacing.xl)),
        ],
      ),
    );
  }

  /// The Stations section caps the grid so it never pushes the podcasts
  /// far down; the rest are a "Show all" tap away.
  static const int _maxStationTiles = 4;

  List<Widget> _stationSlivers(BuildContext context, List<Station> stations) {
    final l10n = AppLocalizations.of(context);
    return [
      SliverToBoxAdapter(
        child: SectionHeader(
          title: l10n.stationSectionTitle,
          count: stations.isEmpty ? null : stations.length,
          trailing: _StationsHeaderActions(stationCount: stations.length),
        ),
      ),
      if (stations.isEmpty)
        SliverToBoxAdapter(child: _InlinePlaceholder(l10n.stationNoStationsYet))
      else
        StationGridSliver(
          stations: recentlyPlayedStations(stations, limit: _maxStationTiles),
        ),
    ];
  }

  Widget _podcastsSliver(
    AsyncValue<List<Subscription>> sortedSubscriptionsAsync,
  ) {
    return sortedSubscriptionsAsync.when(
      data: (all) {
        final sorted = filterPodcasts(all, _filterController.text);
        if (sorted.isEmpty) {
          return SliverToBoxAdapter(
            child: _InlinePlaceholder(
              AppLocalizations.of(context).libraryFilterNoMatch,
            ),
          );
        }
        return _podcastList(sorted);
      },
      loading: () => const SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: Spacing.md),
          child: Center(child: CircularProgressIndicator()),
        ),
      ),
      error: (_, _) => const SliverToBoxAdapter(child: SizedBox.shrink()),
    );
  }

  Widget _podcastList(List<Subscription> sorted) {
    return SliverList.separated(
      separatorBuilder: (context, _) => Divider(
        height: 1,
        thickness: 1,
        color: AppColors.of(context).hairline,
        // Starts at the text, past the 52dp artwork.
        indent: Spacing.screenHorizontal + 52 + Spacing.sm + Spacing.xs,
      ),
      itemCount: sorted.length,
      itemBuilder: (context, index) {
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
      },
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
    final sortOrder =
        ref.watch(podcastSortOrderControllerProvider).value ??
        PodcastSortOrder.latestEpisode;
    return SectionHeader(
      title: l10n.libraryPodcastsSection,
      count: podcastCount == 0 ? null : podcastCount,
      trailing: podcastCount == 0
          ? null
          : _SortMenuButton(
              currentOrder: sortOrder,
              onSelected: (order) => unawaited(
                ref
                    .read(podcastSortOrderControllerProvider.notifier)
                    .setSortOrder(order),
              ),
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

    return ActionMenuTrigger(
      onOpen: (anchor, drag) => _showMenu(anchor, drag, l10n),
      builder: (context, open) => Tooltip(
        message: l10n.librarySortTooltip,
        child: InkWell(
          onTap: open,
          borderRadius: AppBorders.sm,
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              minHeight: Spacing.minTouchTarget,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.sort, size: 16, color: colors.accent),
                const SizedBox(width: Spacing.xs),
                // Shortens only at extreme text sizes, when even the full
                // trailing share cannot fit it.
                Flexible(
                  child: Text(
                    _labelFor(l10n, currentOrder),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: style,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _choose(
    BuildContext anchor,
    ActionMenuDrag? drag,
    PodcastSortOrder order,
  ) {
    if (order != currentOrder && needsSelectionHaptic(drag) && anchor.mounted) {
      HapticsScope.of(anchor).play(HapticToken.selection);
    }
    onSelected(order);
  }

  void _showMenu(
    BuildContext anchor,
    ActionMenuDrag? drag,
    AppLocalizations l10n,
  ) {
    showActionMenu(
      context: anchor,
      placement: ActionMenuPlacement.below(anchor),
      sections: [
        [
          for (final order in PodcastSortOrder.values)
            ActionMenuEntry(
              label: _labelFor(l10n, order),
              checked: order == currentOrder,
              onSelected: () => _choose(anchor, drag, order),
            ),
        ],
      ],
      drag: drag,
    );
  }
}

/// "+" and, once the grid is capped, "Show all" for the Stations header.
class _StationsHeaderActions extends StatelessWidget {
  const _StationsHeaderActions({required this.stationCount});

  final int stationCount;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = AppColors.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          tooltip: l10n.stationAdd,
          icon: Icon(Icons.add_rounded, color: colors.accent),
          onPressed: () => context.push(AppRoutes.stationNew),
        ),
        if (_LibraryScreenState._maxStationTiles < stationCount)
          Flexible(
            child: TextButton(
              onPressed: () => context.push(AppRoutes.stationList),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: Text(
                      l10n.stationShowAll,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded, size: 18),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

/// The podcasts whose title or author contains [query], ignoring case and
/// surrounding spaces; all of them when [query] is blank.
@visibleForTesting
List<Subscription> filterPodcasts(List<Subscription> podcasts, String query) {
  final needle = query.trim().toLowerCase();
  if (needle.isEmpty) return podcasts;
  return [
    for (final podcast in podcasts)
      if (podcast.title.toLowerCase().contains(needle) ||
          podcast.artistName.toLowerCase().contains(needle))
        podcast,
  ];
}

/// Pill-shaped field under the Podcasts header that filters the list.
class _PodcastFilterField extends StatelessWidget {
  const _PodcastFilterField({
    required this.controller,
    required this.onChanged,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  void _clear() {
    controller.clear();
    onChanged('');
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        Spacing.screenHorizontal,
        0,
        Spacing.screenHorizontal,
        Spacing.sm,
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        // Touching anything else ends the filtering and hides the keyboard.
        onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
        textInputAction: TextInputAction.search,
        style: AppTextStyles.body.copyWith(color: colors.ink),
        decoration: InputDecoration(
          hintText: AppLocalizations.of(context).libraryFilterHint,
          hintStyle: AppTextStyles.body.copyWith(color: colors.inkTertiary),
          prefixIcon: Icon(Icons.search, color: colors.inkTertiary),
          suffixIcon: ListenableBuilder(
            listenable: controller,
            builder: (context, _) => controller.text.isEmpty
                ? const SizedBox.shrink()
                : IconButton(
                    tooltip: MaterialLocalizations.of(
                      context,
                    ).deleteButtonTooltip,
                    icon: Icon(Icons.cancel, color: colors.inkTertiary),
                    onPressed: _clear,
                  ),
          ),
          filled: true,
          fillColor: colors.surfaceSunken,
          isDense: true,
          // All three: the theme's enabled and focused borders would
          // otherwise replace the pill with its rounded rectangle.
          border: const OutlineInputBorder(
            borderRadius: AppBorders.pill,
            borderSide: BorderSide.none,
          ),
          enabledBorder: const OutlineInputBorder(
            borderRadius: AppBorders.pill,
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: AppBorders.pill,
            borderSide: BorderSide(color: colors.accent, width: 1.5),
          ),
        ),
      ),
    );
  }
}
