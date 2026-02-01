import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:audiflow_ui/audiflow_ui.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';

/// Card displaying smart playlist information with tap to navigate.
///
/// Uses a horizontal layout with thumbnail on left and info on right,
/// optimized for single-column list display.
class SmartPlaylistCard extends StatelessWidget {
  const SmartPlaylistCard({
    super.key,
    required this.smartPlaylist,
    required this.episodeCount,
    required this.playedCount,
    this.dateRange,
    this.thumbnailUrl,
    this.onTap,
  });

  final SmartPlaylist smartPlaylist;
  final int episodeCount;
  final int playedCount;
  final String? dateRange;
  final String? thumbnailUrl;
  final VoidCallback? onTap;

  static const _thumbnailSize = 72.0;

  /// Formats title as "#N title" for numbered playlists,
  /// or just title for others.
  String _formatTitle() {
    // Skip "#N" prefix for special playlists (sortKey=0)
    // and ungrouped (id='ungrouped')
    if (0 < smartPlaylist.sortKey && smartPlaylist.id != 'ungrouped') {
      return '#${smartPlaylist.sortKey} '
          '${smartPlaylist.displayName}';
    }
    return smartPlaylist.displayName;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(Spacing.md),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildThumbnail(colorScheme),
              const SizedBox(width: Spacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            _formatTitle(),
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (smartPlaylist.yearHeaderMode != YearHeaderMode.none)
                          Padding(
                            padding: const EdgeInsets.only(left: Spacing.xs),
                            child: Icon(
                              Icons.calendar_month_outlined,
                              size: 16,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: Spacing.xs),
                    Text(
                      '$episodeCount episodes',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    if (dateRange != null) ...[
                      const SizedBox(height: Spacing.xs),
                      Text(
                        dateRange!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant.withValues(
                            alpha: 0.7,
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: Spacing.sm),
                    _buildProgressBar(colorScheme),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: colorScheme.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThumbnail(ColorScheme colorScheme) {
    if (thumbnailUrl != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: ExtendedImage.network(
          thumbnailUrl!,
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
    return _buildPlaceholder(colorScheme);
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
        size: 32,
        color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
      ),
    );
  }

  Widget _buildProgressBar(ColorScheme colorScheme) {
    final progress = episodeCount == 0 ? 0.0 : playedCount / episodeCount;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LinearProgressIndicator(
          value: progress,
          backgroundColor: colorScheme.surfaceContainerHighest,
          valueColor: AlwaysStoppedAnimation(colorScheme.primary),
        ),
        const SizedBox(height: Spacing.xs),
        Text(
          '$playedCount/$episodeCount played',
          style: TextStyle(
            fontSize: 11,
            color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }
}
