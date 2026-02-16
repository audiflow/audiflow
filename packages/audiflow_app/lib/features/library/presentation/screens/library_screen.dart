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
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.libraryTitle)),
      body: subscriptionsAsync.when(
        data: (subscriptions) => _buildContent(context, subscriptions),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => _buildErrorState(
          context,
          error.toString(),
          () => ref.invalidate(librarySubscriptionsProvider),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, List<Subscription> subscriptions) {
    if (subscriptions.isEmpty) {
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
              child: Text(
                l10n.libraryYourPodcasts,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              final subscription = subscriptions[index];
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
            }, childCount: subscriptions.length),
          ),
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
