import 'package:flutter/material.dart';

/// A translucent squircle-shaped button for overlaying on artwork.
///
/// Adapts its scrim and icon color based on [artworkBrightness]:
/// - [Brightness.dark]: light scrim (white 20%) + white icon
/// - [Brightness.light]: dark scrim (black 25%) + dark icon
class OverlayActionButton extends StatelessWidget {
  const OverlayActionButton({
    super.key,
    required this.icon,
    required this.artworkBrightness,
    this.onTap,
    this.semanticLabel,
  });

  final IconData icon;
  final Brightness artworkBrightness;
  final VoidCallback? onTap;
  final String? semanticLabel;

  static const double _size = 36.0;
  static const double _borderRadius = 10.0;
  static const double _iconSize = 20.0;

  @override
  Widget build(BuildContext context) {
    final isDarkArtwork = artworkBrightness == Brightness.dark;
    final scrimColor = isDarkArtwork
        ? Colors.white.withValues(alpha: 0.2)
        : Colors.black.withValues(alpha: 0.25);
    final iconColor = isDarkArtwork ? Colors.white : const Color(0xFF1A1A1A);

    return Semantics(
      button: true,
      label: semanticLabel,
      child: GestureDetector(
        onTap: onTap,
        child: SizedBox(
          width: _size,
          height: _size,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: scrimColor,
              borderRadius: BorderRadius.circular(_borderRadius),
            ),
            child: Icon(icon, color: iconColor, size: _iconSize),
          ),
        ),
      ),
    );
  }
}
