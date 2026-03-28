import 'package:flutter/material.dart';

/// A translucent squircle-shaped button for overlaying on artwork.
///
/// When [collapseRatio] is 0 (expanded), shows a dark scrim with white
/// icon. As [collapseRatio] approaches 1 (collapsed), the scrim fades
/// out and the icon transitions to the theme's [ColorScheme.onSurface].
class OverlayActionButton extends StatelessWidget {
  const OverlayActionButton({
    super.key,
    required this.icon,
    this.onTap,
    this.semanticLabel,
    this.collapseRatio = 0.0,
  });

  final IconData icon;
  final VoidCallback? onTap;
  final String? semanticLabel;

  /// 0.0 = fully expanded (overlay style), 1.0 = fully collapsed (theme style)
  final double collapseRatio;

  static const double _size = 36.0;
  static const double _borderRadius = 10.0;
  static const double _iconSize = 20.0;
  static const double _scrimAlpha = 0.35;

  @override
  Widget build(BuildContext context) {
    final themeIconColor = Theme.of(context).colorScheme.onSurface;
    final iconColor = Color.lerp(Colors.white, themeIconColor, collapseRatio);
    final scrimAlpha = _scrimAlpha * (1.0 - collapseRatio);

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
              color: Colors.black.withValues(alpha: scrimAlpha),
              borderRadius: BorderRadius.circular(_borderRadius),
            ),
            child: Icon(icon, color: iconColor, size: _iconSize),
          ),
        ),
      ),
    );
  }
}
