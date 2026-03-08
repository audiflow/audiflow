import 'package:audiflow_domain/audiflow_domain.dart' show SmartPlaylistGroup;
import 'package:audiflow_ui/audiflow_ui.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../l10n/app_localizations.dart';

/// Formats a date range in Apple Podcasts style.
String? formatDateRange(DateTime? earliest, DateTime? latest, {DateTime? now}) {
  if (earliest == null || latest == null) return null;
  final now0 = now ?? DateTime.now();
  final bothCurrentYear =
      earliest.year == now0.year && latest.year == now0.year;
  final fmt = bothCurrentYear ? DateFormat('M/d') : DateFormat.yMMMd();
  if (DateUtils.isSameDay(earliest, latest)) return fmt.format(earliest);
  return '${fmt.format(earliest)}\u301c${fmt.format(latest)}';
}

/// Formats duration in ms using localized strings.
String? formatGroupDuration(int? totalMs, AppLocalizations l10n) {
  if (totalMs == null || totalMs == 0) return null;
  final minutes = totalMs ~/ 60000;
  final hours = minutes ~/ 60;
  final remainingMinutes = minutes % 60;
  if (0 < hours) {
    return l10n.groupDurationHoursMinutes(hours, remainingMinutes);
  }
  return l10n.groupDurationMinutes(minutes);
}

/// Card widget for displaying a smart playlist group inline.
class InlineGroupCard extends StatelessWidget {
  const InlineGroupCard({
    super.key,
    required this.group,
    required this.onTap,
    this.prependSeasonNumber = false,
    this.episodeCountOverride,
  });

  final SmartPlaylistGroup group;
  final VoidCallback onTap;
  final bool prependSeasonNumber;

  /// When set, overrides `group.episodeIds.length` for the
  /// episode count display (used in perEpisode year mode).
  final int? episodeCountOverride;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);
    final dateRange = group.showDateRange
        ? formatDateRange(group.earliestDate, group.latestDate)
        : null;
    final duration = group.showDateRange
        ? formatGroupDuration(group.totalDurationMs, l10n)
        : null;

    final metaLine = StringBuffer(
      l10n.groupEpisodeCount(episodeCountOverride ?? group.episodeIds.length),
    );
    if (duration != null) {
      metaLine.write('  $duration');
    }

    final hasThumbnail = group.thumbnailUrl != null;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.md,
        vertical: Spacing.xxs,
      ),
      child: Card(
        elevation: 0,
        color: colorScheme.surfaceContainerLow,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: Spacing.md,
              vertical: Spacing.sm,
            ),
            child: Row(
              crossAxisAlignment: hasThumbnail
                  ? CrossAxisAlignment.start
                  : CrossAxisAlignment.center,
              children: [
                if (hasThumbnail) ...[
                  _buildThumbnail(colorScheme),
                  const SizedBox(width: Spacing.sm),
                ],
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        group.formattedDisplayName(
                          prependSeasonNumber: prependSeasonNumber,
                        ),
                        style: theme.textTheme.titleSmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        metaLine.toString(),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      if (dateRange != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          dateRange,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, color: colorScheme.onSurfaceVariant),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static const _thumbnailSize = 56.0;

  Widget _buildThumbnail(ColorScheme colorScheme) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: ExtendedImage.network(
        group.thumbnailUrl!,
        width: _thumbnailSize,
        height: _thumbnailSize,
        fit: BoxFit.cover,
        cache: true,
        loadStateChanged: (state) {
          if (state.extendedImageLoadState == LoadState.failed) {
            return _buildPlaceholder(colorScheme);
          }
          return null;
        },
      ),
    );
  }

  Widget _buildPlaceholder(ColorScheme colorScheme) {
    return Container(
      width: _thumbnailSize,
      height: _thumbnailSize,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        Icons.folder_outlined,
        size: 24,
        color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
      ),
    );
  }
}

/// Helper for perEpisode year mode to carry filtered IDs
/// alongside the original group in inline view.
class YearFilteredInlineGroup {
  const YearFilteredInlineGroup({
    required this.group,
    required this.filteredEpisodeIds,
  });

  final SmartPlaylistGroup group;
  final List<int> filteredEpisodeIds;
}
