import 'package:flutter/material.dart';

import '../../styles/borders.dart';

/// A translucent squircle-shaped button for overlaying on artwork.
///
/// When [collapseRatio] is 0 (expanded), the button adapts to
/// [artworkBrightness]: dark artwork gets a light scrim with white icon,
/// light artwork gets a dark scrim with dark icon. As [collapseRatio]
/// approaches 1 (collapsed), the scrim fades out and the icon transitions
/// to the theme's [ColorScheme.onSurface].
///
/// When [onTap] is null the button is visually dimmed and marked disabled
/// in semantics.
class OverlayActionButton extends StatelessWidget {
  const OverlayActionButton({
    super.key,
    required this.icon,
    this.onTap,
    this.semanticLabel,
    this.collapseRatio = 0.0,
    this.artworkBrightness = Brightness.dark,
  });

  final IconData icon;
  final VoidCallback? onTap;
  final String? semanticLabel;

  /// 0.0 = fully expanded (overlay style), 1.0 = fully collapsed (theme style)
  final double collapseRatio;

  /// Brightness of the artwork underneath. Drives scrim and icon color
  /// when the app bar is expanded.
  final Brightness artworkBrightness;

  static const double _visualSize = 36.0;
  static const double _hitTargetSize = 48.0;
  static const double _iconSize = 20.0;
  static const double _disabledOpacity = 0.38;

  @override
  Widget build(BuildContext context) {
    final themeIconColor = Theme.of(context).colorScheme.onSurface;
    final isEnabled = onTap != null;

    // Overlay colors adapt to artwork brightness
    final overlayIconColor = artworkBrightness == Brightness.dark
        ? Colors.white
        : const Color(0xFF1A1A1A);
    final scrimColor = artworkBrightness == Brightness.dark
        ? Colors.white.withValues(alpha: 0.2)
        : Colors.black.withValues(alpha: 0.25);

    final clampedRatio = collapseRatio.clamp(0.0, 1.0);

    final iconColor = Color.lerp(
      overlayIconColor,
      themeIconColor,
      clampedRatio,
    );
    final scrimAlpha = (1.0 - clampedRatio);

    final button = SizedBox(
      width: _hitTargetSize,
      height: _hitTargetSize,
      child: Center(
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Color.lerp(scrimColor, Colors.transparent, 1.0 - scrimAlpha),
            borderRadius: AppBorders.md,
          ),
          child: SizedBox(
            width: _visualSize,
            height: _visualSize,
            child: Icon(icon, color: iconColor, size: _iconSize),
          ),
        ),
      ),
    );

    return Semantics(
      button: true,
      enabled: isEnabled,
      label: semanticLabel,
      child: Tooltip(
        message: semanticLabel ?? '',
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          child: isEnabled
              ? button
              : Opacity(opacity: _disabledOpacity, child: button),
        ),
      ),
    );
  }
}
