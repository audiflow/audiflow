import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:audiflow_ui/audiflow_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../controllers/queue_controller.dart';
import '../widgets/clear_queue_button.dart';
import '../widgets/now_playing_card.dart';
import '../widgets/queue_list_tile.dart';

/// Screen displaying the playback queue.
///
/// Shows the currently playing episode at the top, followed by a reorderable
/// list of upcoming queue items. Supports swipe-to-remove and drag-to-reorder.
class QueueScreen extends ConsumerWidget {
  const QueueScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final queueAsync = ref.watch(queueControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Queue'),
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

    final allItems = queue.allItems;

    return CustomScrollView(
      slivers: [
        // Now Playing section
        if (hasNowPlaying) const SliverToBoxAdapter(child: NowPlayingCard()),

        // Up Next header
        if (allItems.isNotEmpty)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                Spacing.md,
                Spacing.md,
                Spacing.md,
                Spacing.sm,
              ),
              child: Text(
                'UP NEXT',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ),

        // Queue items list
        if (allItems.isNotEmpty)
          SliverReorderableList(
            itemCount: allItems.length,
            onReorder: (oldIndex, newIndex) {
              // Adjust newIndex for removal
              if (oldIndex < newIndex) {
                newIndex -= 1;
              }
              final item = allItems[oldIndex];
              ref
                  .read(queueControllerProvider.notifier)
                  .reorderItem(item.queueItem.id, newIndex);
            },
            itemBuilder: (context, index) {
              final item = allItems[index];
              return ReorderableDragStartListener(
                key: ValueKey(item.queueItem.id),
                index: index,
                child: QueueListTile(
                  item: item,
                  onRemove: () => ref
                      .read(queueControllerProvider.notifier)
                      .removeItem(item.queueItem.id),
                  onTap: () => ref
                      .read(queueControllerProvider.notifier)
                      .skipToItem(item.queueItem.id),
                ),
              );
            },
          ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

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
            Text('Queue is empty', style: theme.textTheme.headlineSmall),
            const SizedBox(height: Spacing.sm),
            Text(
              'Add episodes to your queue from the library or podcast pages',
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
              'Failed to load queue',
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
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

void _noOp() {}
