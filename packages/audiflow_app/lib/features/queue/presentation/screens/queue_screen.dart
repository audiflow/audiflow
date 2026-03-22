import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:audiflow_ui/audiflow_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../../l10n/app_localizations.dart';
import '../controllers/queue_controller.dart';
import '../widgets/clear_queue_button.dart';
import '../widgets/now_playing_card.dart';
import '../widgets/queue_list_tile.dart';

class QueueScreen extends ConsumerWidget {
  const QueueScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final queueAsync = ref.watch(queueControllerProvider);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.queueTitle),
        actions: [
          queueAsync.when(
            data: (queue) => ClearQueueButton(
              enabled: queue.hasItems,
              onClear: () =>
                  ref.read(queueControllerProvider.notifier).clearQueue(),
            ),
            loading: () =>
                const ClearQueueButton(enabled: false, onClear: _noOp),
            error: (_, _) =>
                const ClearQueueButton(enabled: false, onClear: _noOp),
          ),
        ],
      ),
      body: queueAsync.when(
        data: (queue) => _buildContent(context, ref, queue),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => _buildErrorState(
          context,
          error.toString(),
          () => ref.invalidate(queueControllerProvider),
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    PlaybackQueue queue,
  ) {
    final nowPlaying = ref.watch(nowPlayingControllerProvider);
    final hasNowPlaying = nowPlaying != null;

    if (!queue.hasItems && !hasNowPlaying) {
      return _buildEmptyState(context);
    }

    final upNextItems = queue.upNextItems(
      nowPlayingUrl: nowPlaying?.episodeUrl,
    );
    // Offset between filtered list and full list (accounts for the
    // now-playing item removed by upNextItems).
    final reorderIndexOffset = queue.allItems.length - upNextItems.length;
    final l10n = AppLocalizations.of(context);

    return CustomScrollView(
      slivers: [
        // Now Playing section
        if (hasNowPlaying) const SliverToBoxAdapter(child: NowPlayingCard()),

        // Up Next header
        if (upNextItems.isNotEmpty)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                Spacing.md,
                Spacing.md,
                Spacing.md,
                Spacing.sm,
              ),
              child: Text(
                l10n.queueUpNext,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ),

        // Queue items list
        if (upNextItems.isNotEmpty)
          SliverReorderableList(
            itemCount: upNextItems.length,
            onReorder: (oldIndex, newIndex) {
              // Adjust newIndex for removal
              if (oldIndex < newIndex) {
                newIndex -= 1;
              }
              final item = upNextItems[oldIndex];
              ref
                  .read(queueControllerProvider.notifier)
                  .reorderItem(
                    item.queueItem.id,
                    newIndex + reorderIndexOffset,
                  );
            },
            itemBuilder: (context, index) {
              final item = upNextItems[index];
              return QueueListTile(
                key: ValueKey(item.queueItem.id),
                item: item,
                index: index,
                onRemove: () => ref
                    .read(queueControllerProvider.notifier)
                    .removeItem(item.queueItem.id),
                onTap: () => ref
                    .read(queueControllerProvider.notifier)
                    .skipToItem(item.queueItem.id),
              );
            },
          ),
      ],
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
              Symbols.queue_music,
              size: 64,
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
            ),
            const SizedBox(height: Spacing.md),
            Text(l10n.queueEmpty, style: theme.textTheme.headlineSmall),
            const SizedBox(height: Spacing.sm),
            Text(
              l10n.queueEmptySubtitle,
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
              l10n.queueLoadError,
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

void _noOp() {}
