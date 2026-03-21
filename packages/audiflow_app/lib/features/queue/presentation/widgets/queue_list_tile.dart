import 'package:audiflow_core/audiflow_core.dart';
import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:audiflow_ui/audiflow_ui.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../../l10n/app_localizations.dart';

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
    final l10n = AppLocalizations.of(context);
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
        leading: MiniPlayerArtwork(
          imageUrl: item.artworkUrl,
          size: 40,
          borderRadius: 6,
        ),
        trailing: ReorderableDragStartListener(
          index: index,
          child: Icon(Symbols.drag_handle, color: colorScheme.onSurfaceVariant),
        ),
        title: Text(
          item.episode.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.bodyMedium,
        ),
        subtitle: Text(
          _buildSubtitleText(l10n),
          style: theme.textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: Spacing.md,
          vertical: Spacing.xs,
        ),
      ),
    );
  }

  String _buildSubtitleText(AppLocalizations l10n) {
    final parts = <String>[];

    if (item.episode.durationMs != null) {
      final duration = Duration(milliseconds: item.episode.durationMs!);
      final hours = duration.inHours;
      final minutes = duration.inMinutes.remainder(60);
      final seconds = duration.inSeconds.remainder(60);
      if (0 < hours) {
        parts.add(
          '$hours:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
        );
      } else {
        parts.add(
          '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
        );
      }
    }

    if (item.episode.publishedAt != null) {
      parts.add(
        item.episode.publishedAt!.formatEpisodeDate(
          todayLabel: l10n.dateToday,
          yesterdayLabel: l10n.dateYesterday,
        ),
      );
    }

    return parts.join('  ');
  }
}
