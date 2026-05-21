import 'package:audiflow_domain/audiflow_domain.dart'
    show EffectiveThumbnails, SmartPlaylistGroup, presetByFeedUrlProvider;
import 'package:audiflow_ui/audiflow_ui.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../l10n/app_localizations.dart';

/// Formats a date range in Apple Podcasts style.
String? formatDateRange(DateTime? earliest, DateTime? latest, {DateTime? now}) {
  if (earliest == null || latest == null) return null;
  final now0 = now ?? DateTime.now();
  final bothCurrentYear =
      earliest.year == now0.year && latest.year == now0.year;
  final startFmt = bothCurrentYear ? DateFormat.Md() : DateFormat.yMd();
  if (DateUtils.isSameDay(earliest, latest)) return startFmt.format(earliest);
  final sameYear = earliest.year == latest.year;
  final endFmt = bothCurrentYear || !sameYear ? startFmt : DateFormat.Md();
  return '${startFmt.format(earliest)}\u301c${endFmt.format(latest)}';
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
class InlineGroupCard extends ConsumerWidget {
  const InlineGroupCard({
    super.key,
    required this.group,
    required this.onTap,
    this.prependSeasonNumber = false,
    this.feedUrl,
    this.playlistId,
    this.episodeCountOverride,
    this.earliestDateOverride,
    this.latestDateOverride,
    this.totalDurationMsOverride,
  });

  final SmartPlaylistGroup group;
  final VoidCallback onTap;
  final bool prependSeasonNumber;

  /// Feed URL of the parent podcast. When set together with
  /// [playlistId], the card resolves the `showThumbnail` flag
  /// from the matched smart playlist config.
  final String? feedUrl;

  /// Parent playlist id. See [feedUrl].
  final String? playlistId;

  /// When set, overrides `group.episodeIds.length` for the
  /// episode count display (used in perEpisode year mode).
  final int? episodeCountOverride;

  /// When set, overrides `group.earliestDate`/`group.latestDate`
  /// for the date range display (used in split-by-year mode).
  final DateTime? earliestDateOverride;

  /// See [earliestDateOverride].
  final DateTime? latestDateOverride;

  /// When set, overrides `group.totalDurationMs` for the
  /// duration display (used in split-by-year mode).
  final int? totalDurationMsOverride;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);
    final dateRange = group.showDateRange
        ? formatDateRange(
            earliestDateOverride ?? group.earliestDate,
            latestDateOverride ?? group.latestDate,
          )
        : null;
    final duration = group.showDateRange
        ? formatGroupDuration(
            totalDurationMsOverride ?? group.totalDurationMs,
            l10n,
          )
        : null;

    final metaLine = StringBuffer(
      l10n.groupEpisodeCount(episodeCountOverride ?? group.episodeIds.length),
    );
    if (duration != null) {
      metaLine.write('  $duration');
    }

    final showThumbnail = _resolveShowThumbnail(ref);
    final hasThumbnail = showThumbnail && group.thumbnailUrl != null;

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
              vertical: Spacing.md,
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
                          parentPrependSeasonNumber: prependSeasonNumber,
                        ),
                        style: theme.textTheme.titleSmall,
                        maxLines: 2,
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

  bool _resolveShowThumbnail(WidgetRef ref) {
    final url = feedUrl;
    final id = playlistId;
    if (url == null || id == null) return true;

    final config = ref.watch(presetByFeedUrlProvider(url)).value;
    if (config == null) return true;

    final playlistDef = config.findPlaylist(id);
    if (playlistDef == null) return true;

    final groupDef = playlistDef.grouping.findStaticClassifier(group.id);

    return EffectiveThumbnails.groupCard(
      showEpisodeThumbnail: config.showEpisodeThumbnail,
      playlist: playlistDef,
      group: groupDef,
    );
  }
}

/// Helper for perEpisode year mode to carry filtered IDs
/// alongside the original group in inline view.
class YearFilteredInlineGroup {
  const YearFilteredInlineGroup({
    required this.group,
    required this.filteredEpisodeIds,
    this.earliestDate,
    this.latestDate,
    this.totalDurationMs,
  });

  final SmartPlaylistGroup group;
  final List<int> filteredEpisodeIds;

  /// Filtered earliest episode date (for split-by-year).
  final DateTime? earliestDate;

  /// Filtered latest episode date (for split-by-year).
  final DateTime? latestDate;

  /// Filtered total duration in ms (for split-by-year).
  final int? totalDurationMs;
}
