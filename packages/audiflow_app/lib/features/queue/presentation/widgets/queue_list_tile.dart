import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:audiflow_ui/audiflow_ui.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

/// Widget for displaying a queue item with swipe-to-remove and drag handle.
///
/// Shows episode title, duration, and a subtle indicator for adhoc items.
class QueueListTile extends StatelessWidget {
  const QueueListTile({
    super.key,
    required this.item,
    required this.index,
    required this.onRemove,
    required this.onTap,
  });

  final QueueItemWithEpisode item;
  final int index;
  final VoidCallback onRemove;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Dismissible(
      key: ValueKey(item.queueItem.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onRemove(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: Spacing.md),
        color: colorScheme.error,
        child: Icon(Symbols.delete, color: colorScheme.onError),
      ),
      child: ListTile(
        onTap: onTap,
        leading: ReorderableDragStartListener(
          index: index,
          child: Icon(Symbols.drag_handle, color: colorScheme.onSurfaceVariant),
        ),
        title: Text(
          item.episode.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.bodyMedium,
        ),
        subtitle: _buildSubtitle(theme, colorScheme),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: Spacing.md,
          vertical: Spacing.xs,
        ),
      ),
    );
  }

  Widget _buildSubtitle(ThemeData theme, ColorScheme colorScheme) {
    final parts = <Widget>[];

    // Format duration if available
    if (item.episode.durationMs != null) {
      final duration = Duration(milliseconds: item.episode.durationMs!);
      final formatted = _formatDuration(duration);
      parts.add(
        Text(
          formatted,
          style: theme.textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      );
    }

    // Add adhoc indicator dot
    if (item.queueItem.isAdhoc) {
      if (parts.isNotEmpty) {
        parts.add(const SizedBox(width: Spacing.sm));
      }
      parts.add(
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: colorScheme.outline,
          ),
        ),
      );
    }

    if (parts.isEmpty) {
      return const SizedBox.shrink();
    }

    return Row(mainAxisSize: MainAxisSize.min, children: parts);
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (0 < hours) {
      return '$hours:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}
