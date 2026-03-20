import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:audiflow_ui/audiflow_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../routing/app_router.dart';
import '../controllers/library_controller.dart';
import '../widgets/continue_listening_section.dart';
import '../../../station/presentation/controllers/station_list_controller.dart';
import '../../../station/presentation/widgets/station_list_tile.dart';

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
    final stationsAsync = ref.watch(stationListProvider);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.libraryTitle)),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push(AppRoutes.stationNew),
        tooltip: 'New Station',
        child: const Icon(Icons.add),
      ),
      body: subscriptionsAsync.when(
        data: (subscriptions) =>
            _buildContent(context, subscriptions, stationsAsync),
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
    AsyncValue<List<Station>> stationsAsync,
  ) {
    final stations = stationsAsync.value ?? [];
    final hasSubscriptions = subscriptions.where((s) => !s.isCached).isNotEmpty;

    if (!hasSubscriptions && stations.isEmpty) {
      return _buildEmptyState(context);
    }

    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: ContinueListeningSection(
              onEpisodeTap: (episode) =>
                  _onContinueListeningTap(context, episode),
            ),
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
                    'Stations',
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
                  'No stations yet. Tap + to create one.',
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
              child: Text(
                l10n.libraryYourPodcasts,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
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
                  'No subscriptions yet.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            )
          else
            SliverToBoxAdapter(
              child: ListTile(
                leading: const Icon(Icons.podcasts),
                title: Text(
                  '${subscriptions.where((s) => !s.isCached).length} podcasts',
                ),
                trailing: Icon(
                  Symbols.chevron_right,
                  color: theme.colorScheme.onSurfaceVariant.withValues(
                    alpha: 0.5,
                  ),
                ),
                onTap: () => context.push(AppRoutes.subscriptions),
              ),
            ),
          const SliverToBoxAdapter(child: SizedBox(height: Spacing.xl)),
        ],
      ),
    );
  }

  void _onContinueListeningTap(
    BuildContext context,
    EpisodeWithProgress episode,
  ) {
    final controller = ref.read(audioPlayerControllerProvider.notifier);
    final audioUrl = episode.episode.audioUrl;
    final position = Duration(milliseconds: episode.history?.positionMs ?? 0);

    controller.play(
      audioUrl,
      metadata: NowPlayingInfo(
        episodeUrl: audioUrl,
        episodeTitle: episode.episode.title,
        podcastTitle: '',
        artworkUrl: episode.episode.imageUrl,
        totalDuration: episode.episode.durationMs != null
            ? Duration(milliseconds: episode.episode.durationMs!)
            : null,
      ),
    );

    // Seek to saved position after playback starts
    Future.delayed(const Duration(milliseconds: 500), () {
      controller.seek(position);
    });
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
