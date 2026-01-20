import 'package:audiflow_search/audiflow_search.dart';
import 'package:audiflow_ui/audiflow_ui.dart';
import 'package:flutter/material.dart';

/// Displays a single podcast search result with artwork and metadata.
///
/// This tile shows the podcast artwork, title, author, first genre,
/// and a truncated description. It handles tap gestures to notify the parent.
///
/// Requirements covered:
/// - 2.1: Display result item info (artwork, title, author, genre, summary)
class PodcastSearchResultTile extends StatelessWidget {
  const PodcastSearchResultTile({
    required this.podcast,
    required this.onTap,
    super.key,
  });

  /// Podcast data to display.
  final Podcast podcast;

  /// Callback when tile is tapped.
  final VoidCallback onTap;

  static const double _artworkSize = 72.0;
  static const int _maxDescriptionLines = 2;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: Spacing.md,
          vertical: Spacing.sm,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildArtwork(colorScheme),
            const SizedBox(width: Spacing.md),
            Expanded(child: _buildContent(textTheme, colorScheme)),
          ],
        ),
      ),
    );
  }

  Widget _buildArtwork(ColorScheme colorScheme) {
    return ClipRRect(
      borderRadius: AppBorders.sm,
      child: SizedBox(
        width: _artworkSize,
        height: _artworkSize,
        child: podcast.artworkUrl != null
            ? Image.network(
                podcast.artworkUrl!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return _buildPlaceholder(colorScheme);
                },
              )
            : _buildPlaceholder(colorScheme),
      ),
    );
  }

  Widget _buildPlaceholder(ColorScheme colorScheme) {
    return Container(
      color: colorScheme.surfaceContainerHighest,
      child: Icon(
        Icons.podcasts,
        size: 32,
        color: colorScheme.onSurfaceVariant,
      ),
    );
  }

  Widget _buildContent(TextTheme textTheme, ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Title
        Text(
          podcast.name,
          style: textTheme.titleMedium,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: Spacing.xxs),
        // Author name
        Text(
          podcast.artistName,
          style: textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        // First genre
        if (podcast.genres.isNotEmpty) ...[
          const SizedBox(height: Spacing.xxs),
          Text(
            podcast.genres.first,
            style: textTheme.labelSmall?.copyWith(color: colorScheme.primary),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
        // Description
        if (podcast.description != null && podcast.description!.isNotEmpty) ...[
          const SizedBox(height: Spacing.xs),
          Text(
            podcast.description!,
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
            maxLines: _maxDescriptionLines,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ],
    );
  }
}
