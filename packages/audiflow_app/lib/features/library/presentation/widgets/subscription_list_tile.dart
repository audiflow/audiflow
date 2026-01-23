import 'package:audiflow_domain/audiflow_domain.dart';
import 'package:audiflow_ui/audiflow_ui.dart';
import 'package:flutter/material.dart';

/// Displays a subscribed podcast with artwork and metadata.
///
/// This tile shows the podcast artwork, title, and artist name.
/// It handles tap gestures to navigate to the podcast detail screen.
class SubscriptionListTile extends StatelessWidget {
  const SubscriptionListTile({
    required this.subscription,
    required this.onTap,
    super.key,
  });

  /// Subscription data to display.
  final Subscription subscription;

  /// Callback when tile is tapped.
  final VoidCallback onTap;

  static const double _artworkSize = 64.0;

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
          children: [
            _buildArtwork(colorScheme),
            const SizedBox(width: Spacing.md),
            Expanded(child: _buildContent(textTheme, colorScheme)),
            Icon(
              Icons.chevron_right,
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildArtwork(ColorScheme colorScheme) {
    final artworkUrl = subscription.artworkUrl;

    return ClipRRect(
      borderRadius: AppBorders.sm,
      child: SizedBox(
        width: _artworkSize,
        height: _artworkSize,
        child: artworkUrl != null
            ? Image.network(
                artworkUrl,
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
        size: 28,
        color: colorScheme.onSurfaceVariant,
      ),
    );
  }

  Widget _buildContent(TextTheme textTheme, ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          subscription.title,
          style: textTheme.titleMedium,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: Spacing.xxs),
        Text(
          subscription.artistName,
          style: textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
