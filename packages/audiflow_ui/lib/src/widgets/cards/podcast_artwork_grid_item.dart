import 'package:flutter/material.dart';

import '../../styles/borders.dart';
import '../../styles/spacing.dart';

/// Grid item displaying podcast artwork with a title label.
///
/// Designed for tablet grid layouts where podcasts are shown as
/// artwork cards rather than list tiles.
class PodcastArtworkGridItem extends StatelessWidget {
  const PodcastArtworkGridItem({
    super.key,
    required this.title,
    required this.onTap,
    this.artworkUrl,
  });

  /// URL of the podcast artwork image.
  final String? artworkUrl;

  /// Display title shown below the artwork.
  final String title;

  /// Called when the user taps the grid item.
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Semantics(
      button: true,
      label: title,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppBorders.sm,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: AppBorders.sm,
                child: _buildArtwork(colorScheme),
              ),
            ),
            const SizedBox(height: Spacing.xs),
            Text(
              title,
              style: theme.textTheme.bodySmall,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildArtwork(ColorScheme colorScheme) {
    if (artworkUrl == null) {
      return _buildPlaceholder(colorScheme);
    }

    return Image.network(
      artworkUrl!,
      fit: BoxFit.cover,
      loadingBuilder: (_, child, progress) {
        if (progress == null) return child;
        return _buildPlaceholder(colorScheme);
      },
      errorBuilder: (_, _, _) => _buildPlaceholder(colorScheme),
    );
  }

  Widget _buildPlaceholder(ColorScheme colorScheme) {
    return Container(
      color: colorScheme.surfaceContainerHighest,
      child: Icon(
        Icons.podcasts,
        size: 40,
        color: colorScheme.onSurfaceVariant,
      ),
    );
  }
}
