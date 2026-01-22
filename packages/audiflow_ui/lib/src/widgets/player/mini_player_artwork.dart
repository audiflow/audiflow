import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

/// Artwork widget for the mini player.
///
/// Displays episode artwork with rounded corners and a fallback placeholder
/// when no image is available or while loading.
class MiniPlayerArtwork extends StatelessWidget {
  const MiniPlayerArtwork({
    super.key,
    this.imageUrl,
    this.size = 48.0,
    this.borderRadius = 8.0,
  });

  /// URL of the artwork image.
  final String? imageUrl;

  /// Size of the artwork (width and height).
  final double size;

  /// Border radius for rounded corners.
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: SizedBox(
        width: size,
        height: size,
        child: imageUrl != null
            ? Image.network(
                imageUrl!,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return _buildPlaceholder(colorScheme);
                },
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
        Symbols.podcasts,
        color: colorScheme.onSurfaceVariant,
        size: size * 0.5,
      ),
    );
  }
}
