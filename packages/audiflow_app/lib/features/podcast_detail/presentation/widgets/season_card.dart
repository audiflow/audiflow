import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:audiflow_ui/audiflow_ui.dart';
import 'package:flutter/material.dart';

/// Card displaying season information with tap to navigate.
class SeasonCard extends StatelessWidget {
  const SeasonCard({
    super.key,
    required this.season,
    required this.episodeCount,
    required this.playedCount,
    this.dateRange,
    this.thumbnailUrl,
    this.onTap,
  });

  final Season season;
  final int episodeCount;
  final int playedCount;
  final String? dateRange;
  final String? thumbnailUrl;
  final VoidCallback? onTap;

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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildThumbnail(colorScheme),
              const SizedBox(height: Spacing.sm),
              Text(
                season.displayName,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
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
                    color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                  ),
                ),
              ],
              const SizedBox(height: Spacing.sm),
              _buildProgressBar(colorScheme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThumbnail(ColorScheme colorScheme) {
    if (thumbnailUrl != null) {
      return AspectRatio(
        aspectRatio: 1,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            thumbnailUrl!,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => _buildPlaceholder(colorScheme),
          ),
        ),
      );
    }
    return AspectRatio(aspectRatio: 1, child: _buildPlaceholder(colorScheme));
  }

  Widget _buildPlaceholder(ColorScheme colorScheme) {
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        Icons.folder_outlined,
        size: 48,
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
