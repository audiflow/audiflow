import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../styles/borders.dart';
import 'artwork_image.dart';
import 'system/themed_system_ui_overlay.dart';

/// Full-screen overlay that displays artwork at near-full-screen size
/// with a Hero animation. Tapping anywhere dismisses the overlay.
///
/// Used by both podcast detail and episode detail screens; open it with
/// [show] so every caller gets the same scrim and status bar style.
class ArtworkOverlay extends StatelessWidget {
  const ArtworkOverlay({
    super.key,
    required this.imageUrl,
    required this.heroTag,
  });

  final String imageUrl;
  final String heroTag;

  static const Color barrierColor = Colors.black87;

  /// Pushes the overlay as a transparent route over [barrierColor].
  static Future<void> show(
    BuildContext context, {
    required String imageUrl,
    required String heroTag,
  }) {
    return Navigator.of(context).push(
      PageRouteBuilder<void>(
        opaque: false,
        barrierDismissible: true,
        barrierColor: barrierColor,
        transitionDuration: const Duration(milliseconds: 300),
        reverseTransitionDuration: const Duration(milliseconds: 250),
        pageBuilder: (context, animation, _) => _ScrimStatusBar(
          animation: animation,
          child: ArtworkOverlay(imageUrl: imageUrl, heroTag: heroTag),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final artworkSize = math.min(size.width, size.height) * 0.85;
    final colorScheme = Theme.of(context).colorScheme;

    return Semantics(
      label: 'Dismiss artwork',
      button: true,
      onTap: () => Navigator.of(context).pop(),
      child: GestureDetector(
        excludeFromSemantics: true,
        onTap: () => Navigator.of(context).pop(),
        behavior: HitTestBehavior.opaque,
        child: Center(
          child: Hero(
            tag: heroTag,
            child: ClipRRect(
              borderRadius: AppBorders.lg,
              child: ArtworkImage(
                url: imageUrl,
                width: artworkSize,
                height: artworkSize,
                loading: Container(
                  width: artworkSize,
                  height: artworkSize,
                  color: colorScheme.surfaceContainerHighest,
                  child: const Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
                placeholder: Container(
                  width: artworkSize,
                  height: artworkSize,
                  alignment: Alignment.center,
                  color: colorScheme.surfaceContainerHighest,
                  child: Icon(
                    Icons.broken_image,
                    size: 64,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Switches the status bar to light icons once the dark scrim is mostly
/// faded in, and back once it is mostly faded out, so the icons never sit
/// light-on-light over the page during the barrier transition.
class _ScrimStatusBar extends StatelessWidget {
  const _ScrimStatusBar({required this.animation, required this.child});

  final Animation<double> animation;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final pageBrightness = Theme.of(context).brightness;
    return AnimatedBuilder(
      animation: animation,
      child: child,
      builder: (context, child) => AnnotatedRegion<SystemUiOverlayStyle>(
        value: ThemedSystemUiOverlay.styleOn(
          0.5 <= animation.value ? Brightness.dark : pageBrightness,
        ),
        child: child!,
      ),
    );
  }
}
