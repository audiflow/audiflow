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

class QueueScreen extends ConsumerStatefulWidget {
  const QueueScreen({super.key});

  @override
  ConsumerState<QueueScreen> createState() => _QueueScreenState();
}

class _QueueScreenState extends ConsumerState<QueueScreen> {
  /// Marks where the up-next list (and its backdrop) starts.
  final GlobalKey _listStartKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final queueAsync = ref.watch(queueControllerProvider);
    final l10n = AppLocalizations.of(context);
    final title = LargeTitle(
      l10n.queueTitle,
      trailing: ClearQueueButton(
        enabled: queueAsync.value?.hasItems ?? false,
        onClear: () => ref.read(queueControllerProvider.notifier).clearQueue(),
      ),
    );

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: queueAsync.when(
          data: (queue) => _buildContent(context, queue, title),
          loading: () => _withTitle(
            title,
            const Center(child: CircularProgressIndicator()),
          ),
          error: (error, stack) => _withTitle(
            title,
            _buildErrorState(
              context,
              error.toString(),
              () => ref.invalidate(queueControllerProvider),
            ),
          ),
        ),
      ),
    );
  }

  Widget _withTitle(Widget title, Widget body) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        title,
        Expanded(child: body),
      ],
    );
  }

  Widget _buildContent(
    BuildContext context,
    PlaybackQueue queue,
    Widget title,
  ) {
    final nowPlaying = ref.watch(nowPlayingControllerProvider);
    final hasNowPlaying = nowPlaying != null;

    if (!queue.hasItems && !hasNowPlaying) {
      return _withTitle(title, _buildEmptyState(context));
    }

    final upNextItems = queue.upNextItems(
      nowPlayingUrl: nowPlaying?.episodeUrl,
    );
    // upNextItems removes at most one item (the first match), so the
    // offset is 0 or 1. Safe to use as a constant shift for reorder.
    final reorderIndexOffset = queue.allItems.length - upNextItems.length;
    final l10n = AppLocalizations.of(context);

    return AnchoredContentBackdrop(
      anchorKey: _listStartKey,
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: title),
          if (hasNowPlaying) const SliverToBoxAdapter(child: NowPlayingCard()),
          if (upNextItems.isNotEmpty) ...[
            SliverToBoxAdapter(child: SectionHeader(title: l10n.queueUpNext)),
            SliverToBoxAdapter(child: SizedBox(key: _listStartKey)),
            SliverReorderableList(
              itemCount: upNextItems.length,
              onReorderStart: (_) =>
                  HapticsScope.of(context).play(HapticToken.dragPickUp),
              onReorderEnd: (_) =>
                  HapticsScope.of(context).play(HapticToken.dragDrop),
              onReorderItem: (oldIndex, newIndex) {
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
          const SliverToBoxAdapter(child: SizedBox(height: Spacing.xl)),
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
