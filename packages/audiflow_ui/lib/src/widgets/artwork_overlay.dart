import 'dart:math' as math;

import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';

import '../styles/borders.dart';

/// Full-screen overlay that displays artwork at near-full-screen size
/// with a Hero animation. Tapping the background dismisses the overlay.
///
/// Used by both podcast detail and episode detail screens.
class ArtworkOverlay extends StatelessWidget {
  const ArtworkOverlay({
    super.key,
    required this.imageUrl,
    required this.heroTag,
  });

  final String imageUrl;
  final String heroTag;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final artworkSize = math.min(size.width, size.height) * 0.85;
    final colorScheme = Theme.of(context).colorScheme;

    return Semantics(
      label: 'Dismiss artwork',
      button: true,
      child: GestureDetector(
        excludeFromSemantics: true,
        onTap: () => Navigator.of(context).pop(),
        behavior: HitTestBehavior.opaque,
        child: Center(
          // Blocks taps from reaching the dismiss GestureDetector
          // while staying invisible to screen readers.
          child: GestureDetector(
            excludeFromSemantics: true,
            onTap: () {},
            child: Hero(
              tag: heroTag,
              child: ClipRRect(
                borderRadius: AppBorders.lg,
                child: ExtendedImage.network(
                  imageUrl,
                  width: artworkSize,
                  height: artworkSize,
                  fit: BoxFit.cover,
                  cache: true,
                  loadStateChanged: (state) {
                    if (state.extendedImageLoadState == LoadState.loading) {
                      return Container(
                        width: artworkSize,
                        height: artworkSize,
                        color: colorScheme.surfaceContainerHighest,
                        child: const Center(
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      );
                    }
                    if (state.extendedImageLoadState == LoadState.failed) {
                      return Container(
                        width: artworkSize,
                        height: artworkSize,
                        alignment: Alignment.center,
                        color: colorScheme.surfaceContainerHighest,
                        child: Icon(
                          Icons.broken_image,
                          size: 64,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      );
                    }
                    return null;
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
